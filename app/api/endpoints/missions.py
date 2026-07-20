from fastapi import APIRouter, HTTPException
from app.core.config import supabase
from app.models.schemas import (
    MissionCreate, MissionResponse, 
    MissionStepCreate, MissionStepResponse, 
    MissionDetailResponse
)
from typing import List, Optional
from app.core import local_db

router = APIRouter()

@router.post("/", response_model=MissionResponse)
async def create_mission(data: MissionCreate):
    """
    새로운 연습 미션 생성
    """
    try:
        # 1. 로컬 SQLite DB에 먼저 생성
        new_mission = local_db.add_mission(
            title=data.title,
            description=data.description,
            category=data.category,
            difficulty=data.difficulty,
            reward_point=data.reward_point
        )
        
        # 2. Supabase 동기화 시도 (RLS 정책 에러 방지용 try-except 우회)
        if supabase:
            try:
                supabase.table("missions").insert({
                    "mission_id": new_mission["mission_id"],
                    "title": data.title,
                    "description": data.description,
                    "category": data.category,
                    "difficulty": data.difficulty,
                    "reward_point": data.reward_point
                }).execute()
            except Exception as e:
                print(f"⚠️ [create_mission] Supabase 동기화 실패 (무시 가능): {e}")
                
        return new_mission
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=List[MissionResponse])
async def list_missions(category: Optional[str] = None, difficulty: Optional[str] = None):
    """
    미션 목록 조회 (카테고리 및 난이도 필터 가능)
    """
    try:
        # 로컬 DB에서 조회
        return local_db.get_missions(category=category, difficulty=difficulty)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{mission_id}", response_model=MissionDetailResponse)
async def get_mission_detail(mission_id: int):
    """
    특정 미션 상세 조회 (연관된 모든 미션 단계 step 포함, step_order 오름차순 정렬)
    """
    try:
        mission_data = local_db.get_mission_detail(mission_id)
        if not mission_data:
            raise HTTPException(status_code=404, detail="미션을 찾을 수 없습니다.")
        return mission_data
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/{mission_id}/steps", response_model=MissionStepResponse)
async def create_mission_step(mission_id: int, data: MissionStepCreate):
    """
    특정 미션에 단계(step) 추가
    """
    try:
        # 미션이 실제 존재하는지 로컬 DB 확인
        mission_check = local_db.get_mission_detail(mission_id)
        if not mission_check:
            raise HTTPException(status_code=404, detail="존재하지 않는 미션 ID입니다.")
        
        # 로컬 DB에 스텝 추가
        new_step = local_db.add_mission_step(
            mission_id=mission_id,
            step_order=data.step_order,
            instruction_text=data.instruction_text,
            correct_action=data.correct_action,
            voice_guide_text=data.voice_guide_text
        )
        
        # Supabase 동기화 시도 (RLS 등으로 에러 발생 가능하므로 예외 격리)
        if supabase:
            try:
                supabase.table("mission_steps").insert({
                    "step_id": new_step["step_id"],
                    "mission_id": mission_id,
                    "step_order": data.step_order,
                    "instruction_text": data.instruction_text,
                    "correct_action": data.correct_action,
                    "voice_guide_text": data.voice_guide_text
                }).execute()
            except Exception as e:
                print(f"⚠️ [create_mission_step] Supabase 동기화 실패 (무시 가능): {e}")
                
        return new_step
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{mission_id}")
async def delete_mission(mission_id: int):
    """
    미션 삭제 (연관된 step도 함께 제거됨)
    """
    try:
        local_db.delete_mission(mission_id)
        
        # Supabase에서도 삭제 시도
        if supabase:
            try:
                supabase.table("missions").delete().eq("mission_id", mission_id).execute()
            except Exception as e:
                print(f"⚠️ [delete_mission] Supabase 동기화 실패 (무시 가능): {e}")
                
        return {"status": "success", "message": f"미션 ID {mission_id} 삭제 성공"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

