from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import TouchErrorLogCreate, TouchErrorLogResponse
from typing import List

router = APIRouter()

@router.post("/", response_model=TouchErrorLogResponse)
async def create_touch_error_log(data: TouchErrorLogCreate, current_user: dict = Depends(get_current_user)):
    """
    미션 수행 중 사용자의 터치 오작동/잘못된 선택 행위 로그 기록
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = current_user.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="유효하지 않은 사용자 ID 입니다.")
        
    try:
        response = supabase.table("touch_error_logs").insert({
            "user_id": user_id,
            "mission_id": data.mission_id,
            "step_id": data.step_id,
            "wrong_action": data.wrong_action
        }).execute()
        
        if not response.data:
            raise HTTPException(status_code=400, detail="터치 에러 기록에 실패했습니다.")
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user/{user_id}", response_model=List[TouchErrorLogResponse])
async def get_user_error_logs(user_id: int):
    """
    특정 사용자의 전체 터치 에러 로그 조회 (보호자 역량 분석용)
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    try:
        response = supabase.table("touch_error_logs").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
