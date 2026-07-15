from fastapi import APIRouter, HTTPException
from app.core.config import supabase
from app.models.schemas import (
    MissionCreate, MissionResponse, 
    MissionStepCreate, MissionStepResponse, 
    MissionDetailResponse
)
from typing import List, Optional

router = APIRouter()

@router.post("/", response_model=MissionResponse)
async def create_mission(data: MissionCreate):
    """
    새로운 연습 미션 생성
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        response = supabase.table("missions").insert({
            "title": data.title,
            "description": data.description,
            "category": data.category,
            "difficulty": data.difficulty,
            "reward_point": data.reward_point
        }).execute()
        
        if not response.data:
            raise HTTPException(status_code=400, detail="미션 등록에 실패했습니다.")
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=List[MissionResponse])
async def list_missions(category: Optional[str] = None, difficulty: Optional[str] = None):
    """
    미션 목록 조회 (카테고리 및 난이도 필터 가능)
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        query = supabase.table("missions").select("*")
        if category:
            query = query.eq("category", category)
        if difficulty:
            query = query.eq("difficulty", difficulty)
        
        response = query.execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{mission_id}", response_model=MissionDetailResponse)
async def get_mission_detail(mission_id: int):
    """
    특정 미션 상세 조회 (연관된 모든 미션 단계 step 포함, step_order 오름차순 정렬)
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        # 미션 정보 조회
        mission_resp = supabase.table("missions").select("*").eq("mission_id", mission_id).execute()
        if not mission_resp.data:
            raise HTTPException(status_code=404, detail="미션을 찾을 수 없습니다.")
        
        mission_data = mission_resp.data[0]
        
        # 단계 정보 조회 (step_order로 정렬)
        steps_resp = supabase.table("mission_steps").select("*").eq("mission_id", mission_id).order("step_order").execute()
        
        mission_data["steps"] = steps_resp.data
        return mission_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/{mission_id}/steps", response_model=MissionStepResponse)
async def create_mission_step(mission_id: int, data: MissionStepCreate):
    """
    특정 미션에 단계(step) 추가
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        # 미션이 실제 존재하는지 확인
        mission_check = supabase.table("missions").select("mission_id").eq("mission_id", mission_id).execute()
        if not mission_check.data:
            raise HTTPException(status_code=404, detail="존재하지 않는 미션 ID입니다.")
        
        response = supabase.table("mission_steps").insert({
            "mission_id": mission_id,
            "step_order": data.step_order,
            "instruction_text": data.instruction_text,
            "correct_action": data.correct_action,
            "voice_guide_text": data.voice_guide_text
        }).execute()
        
        if not response.data:
            raise HTTPException(status_code=400, detail="미션 단계 추가에 실패했습니다.")
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{mission_id}")
async def delete_mission(mission_id: int):
    """
    미션 삭제 (ON DELETE CASCADE 설정으로 연관된 step도 함께 제거됨)
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        supabase.table("missions").delete().eq("mission_id", mission_id).execute()
        return {"status": "success", "message": f"미션 ID {mission_id} 삭제 성공"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
