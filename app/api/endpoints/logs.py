from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import MissionLogCreate, MissionLogUpdate, MissionLogResponse
from typing import List
from datetime import datetime
from app.core import local_db

router = APIRouter()

async def process_points_reward(user_id: int, mission_id: int):
    """
    미션 성공 시 포인트 지갑 업데이트 및 거래 내역 추가 처리
    """
    if not supabase:
        print("❌ [process_points_reward] Supabase 클라이언트가 설정되지 않았습니다.")
        return
        
    try:
        # 1. 로컬 SQLite DB에서 먼저 미션 정보 조회 (Supabase RLS 이슈 등으로 없을 수 있으므로)
        local_mission = local_db.get_mission_detail(mission_id)
        if local_mission:
            reward = local_mission.get("reward_point", 0)
            title = local_mission.get("title", "연습 미션")
        else:
            # 로컬 DB에도 없으면 최종적으로 Supabase에서 조회
            mission_resp = supabase.table("missions").select("title", "reward_point").eq("mission_id", mission_id).execute()
            if not mission_resp.data:
                print(f"❌ [process_points_reward] 미션을 찾을 수 없습니다. mission_id: {mission_id}")
                return
            
            mission = mission_resp.data[0]
            reward = mission.get("reward_point", 0)
            title = mission.get("title", "연습 미션")
        
        print(f"ℹ️ [process_points_reward] 유저: {user_id}, 미션: {title}({mission_id}), 보상포인트: {reward}P")
        if reward <= 0:
            print("ℹ️ [process_points_reward] 보상 포인트가 0 이하이므로 처리를 생략합니다.")
            return

            
        # 2. 지갑 잔액 조회 및 업데이트
        wallet_resp = supabase.table("point_wallets").select("balance").eq("user_id", user_id).execute()
        if not wallet_resp.data:
            print(f"ℹ️ [process_points_reward] 지갑이 없는 유저이므로 생성 및 보상 적립 진행. user_id: {user_id}")
            # 지갑이 없는 유저면 임시 생성 (시연용 기본 5000P 지급)
            supabase.table("point_wallets").insert({"user_id": user_id, "balance": reward + 5000}).execute()
        else:
            current_balance = wallet_resp.data[0]["balance"]
            new_balance = current_balance + reward
            print(f"ℹ️ [process_points_reward] 기존잔액: {current_balance}P, 신규잔액: {new_balance}P")
            supabase.table("point_wallets").update({"balance": new_balance, "updated_at": "now()"}).eq("user_id", user_id).execute()
            
        # 3. 로컬 DB에 거래 내역(point_transactions) 생성
        local_db.add_transaction(
            user_id=user_id,
            type_="earn",
            amount=reward,
            description=f"미션 완료 보상: {title}"
        )
        print("✅ [process_points_reward] 포인트 지급 및 트랜잭션 저장 성공!")
    except Exception as e:
        print(f"❌ [process_points_reward 에러 발생] {e}")
        import traceback
        traceback.print_exc()
        raise e

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
        print(f"📥 [create_mission_log] 요청 접수. user_id: {user_id}, mission_id: {data.mission_id}, status: {data.status}")
        # 로컬 DB에 미션 로그 기록 (RLS 우회)
        log = local_db.add_mission_log(
            user_id=user_id,
            mission_id=data.mission_id,
            status=data.status,
            score=data.score,
            wrong_action=data.wrong_action
        )
        
        # 미션 성공 시 포인트 리워드 지급
        if data.status == "성공":
            await process_points_reward(user_id, data.mission_id)
            
        return log
    except Exception as e:
        print("❌ [create_mission_log 에러 발생]")
        import traceback
        traceback.print_exc()
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
