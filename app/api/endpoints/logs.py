from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import MissionLogCreate, MissionLogUpdate, MissionLogResponse
from typing import List
from datetime import datetime

router = APIRouter()

async def process_points_reward(user_id: int, mission_id: int):
    """
    미션 성공 시 포인트 지갑 업데이트 및 거래 내역 추가 처리
    """
    if not supabase:
        return
        
    # 1. 미션 정보에서 reward_point 획득
    mission_resp = supabase.table("missions").select("title", "reward_point").eq("mission_id", mission_id).execute()
    if not mission_resp.data:
        return
    
    mission = mission_resp.data[0]
    reward = mission.get("reward_point", 0)
    title = mission.get("title", "연습 미션")
    
    if reward <= 0:
        return
        
    # 2. 지갑 잔액 조회 및 업데이트
    wallet_resp = supabase.table("point_wallets").select("balance").eq("user_id", user_id).execute()
    if not wallet_resp.data:
        # 지갑이 없는 유저면 임시 생성
        supabase.table("point_wallets").insert({"user_id": user_id, "balance": reward}).execute()
    else:
        current_balance = wallet_resp.data[0]["balance"]
        new_balance = current_balance + reward
        supabase.table("point_wallets").update({"balance": new_balance, "updated_at": "now()"}).eq("user_id", user_id).execute()
        
    # 3. 거래 내역(point_transactions) 생성
    supabase.table("point_transactions").insert({
        "user_id": user_id,
        "type": "earn",
        "amount": reward,
        "description": f"미션 완료 보상: {title}"
    }).execute()

@router.post("/", response_model=MissionLogResponse)
async def create_mission_log(data: MissionLogCreate, current_user: dict = Depends(get_current_user)):
    """
    미션 진행 상황 로그 작성 (진행 중 / 성공 / 실패)
    현재 로그인된 사용자의 ID를 기반으로 생성됩니다.
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = current_user.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="유효한 사용자 ID가 세션에 없습니다.")
        
    try:
        # 이미 이 유저와 미션에 대한 '진행 중'인 로그가 있는지 조회
        existing = supabase.table("user_mission_logs")\
            .select("*")\
            .eq("user_id", user_id)\
            .eq("mission_id", data.mission_id)\
            .eq("status", "진행 중")\
            .execute()
            
        completed_at = None
        if data.status in ["성공", "실패"]:
            completed_at = datetime.utcnow().isoformat()
            
        if existing.data:
            # 기존 진행 중이던 로그를 업데이트
            log_id = existing.data[0]["log_id"]
            response = supabase.table("user_mission_logs").update({
                "status": data.status,
                "score": data.score,
                "completed_at": completed_at
            }).eq("log_id", log_id).execute()
        else:
            # 신규 로그 삽입
            response = supabase.table("user_mission_logs").insert({
                "user_id": user_id,
                "mission_id": data.mission_id,
                "status": data.status,
                "score": data.score,
                "completed_at": completed_at
            }).execute()
            
        if not response.data:
            raise HTTPException(status_code=400, detail="로그를 남기지 못했습니다.")
            
        # 미션 성공 시 포인트 리워드 지급
        if data.status == "성공":
            await process_points_reward(user_id, data.mission_id)
            
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.patch("/{log_id}", response_model=MissionLogResponse)
async def update_mission_log(log_id: int, data: MissionLogUpdate, current_user: dict = Depends(get_current_user)):
    """
    미션 로그의 상태를 업데이트 (예: 진행 중 -> 성공 / 실패)
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = current_user.get("user_id")
    
    try:
        # 해당 로그 조회
        log_check = supabase.table("user_mission_logs").select("*").eq("log_id", log_id).execute()
        if not log_check.data:
            raise HTTPException(status_code=404, detail="해당 미션 로그를 찾을 수 없습니다.")
            
        log = log_check.data[0]
        if log["user_id"] != user_id:
            raise HTTPException(status_code=403, detail="본인의 미션 로그만 수정할 수 있습니다.")
            
        previous_status = log["status"]
        
        completed_at = None
        if data.status in ["성공", "실패"]:
            completed_at = datetime.utcnow().isoformat()
            
        update_fields = {
            "status": data.status,
            "completed_at": completed_at
        }
        if data.score is not None:
            update_fields["score"] = data.score
            
        response = supabase.table("user_mission_logs").update(update_fields).eq("log_id", log_id).execute()
        
        # '진행 중'이나 '실패' 상태에서 새롭게 '성공'으로 전환된 경우 포인트 지급
        if previous_status != "성공" and data.status == "성공":
            await process_points_reward(user_id, log["mission_id"])
            
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user/{user_id}", response_model=List[MissionLogResponse])
async def get_user_mission_logs(user_id: int):
    """
    특정 사용자의 전체 미션 로그 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    try:
        response = supabase.table("user_mission_logs").select("*").eq("user_id", user_id).order("log_id", desc=True).execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
