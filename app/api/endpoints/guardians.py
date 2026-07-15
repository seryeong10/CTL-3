from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import GuardianLinkCreate, GuardianLinkResponse
from typing import List

router = APIRouter()

@router.post("/link", response_model=GuardianLinkResponse)
async def link_senior(data: GuardianLinkCreate, current_user: dict = Depends(get_current_user)):
    """
    시니어와 보호자 간의 연결 고리(guardian_links) 설정
    현재 사용자가 보호자(guardian)인 상태에서 대상 시니어(senior_user_id)를 등록합니다.
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    guardian_user_id = current_user.get("user_id")
    if not guardian_user_id:
        raise HTTPException(status_code=400, detail="보호자 인증 정보가 유효하지 않습니다.")
        
    try:
        # 시니어가 존재하는지 확인
        senior_check = supabase.table("users").select("*").eq("user_id", data.senior_user_id).execute()
        if not senior_check.data:
            raise HTTPException(status_code=404, detail="연결할 대상 시니어가 존재하지 않습니다.")
            
        senior = senior_check.data[0]
        if senior["user_type"] != "senior":
            raise HTTPException(status_code=400, detail="연결 대상 사용자는 시니어 유형이어야 합니다.")
            
        # 이미 링크가 존재하는지 확인
        existing = supabase.table("guardian_links")\
            .select("*")\
            .eq("senior_user_id", data.senior_user_id)\
            .eq("guardian_user_id", guardian_user_id)\
            .execute()
            
        if existing.data:
            return existing.data[0]
            
        # 신규 링크 등록
        response = supabase.table("guardian_links").insert({
            "senior_user_id": data.senior_user_id,
            "guardian_user_id": guardian_user_id,
            "relation": data.relation
        }).execute()
        
        if not response.data:
            raise HTTPException(status_code=400, detail="시니어 보호자 등록에 실패했습니다.")
        return response.data[0]
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/my-seniors")
async def get_my_seniors(current_user: dict = Depends(get_current_user)):
    """
    보호자 시점에서 자신이 등록한 시니어 목록 및 각 시니어의 미션 요약 정보(완료 수, 포인트 잔액) 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    guardian_id = current_user.get("user_id")
    
    try:
        # 링크 정보 로드
        links = supabase.table("guardian_links").select("*, senior:users(*)").eq("guardian_user_id", guardian_id).execute()
        
        result = []
        for link in links.data:
            senior = link.get("senior")
            if not senior:
                continue
                
            senior_id = senior["user_id"]
            
            # 1. 시니어 지갑 잔액 조회
            wallet_resp = supabase.table("point_wallets").select("balance").eq("user_id", senior_id).execute()
            balance = wallet_resp.data[0]["balance"] if wallet_resp.data else 0
            
            # 2. 미션 완료 성공률 계산
            logs_resp = supabase.table("user_mission_logs").select("status").eq("user_id", senior_id).execute()
            total_missions = len(logs_resp.data)
            success_missions = sum(1 for log in logs_resp.data if log["status"] == "성공")
            
            result.append({
                "link_id": link["link_id"],
                "relation": link["relation"],
                "created_at": link["created_at"],
                "senior_id": senior_id,
                "name": senior["name"],
                "phone": senior["phone"],
                "birth_year": senior["birth_year"],
                "wallet_balance": balance,
                "mission_stats": {
                    "total_attempts": total_missions,
                    "success_count": success_missions,
                    "success_rate": round(success_missions / total_missions * 100, 1) if total_missions > 0 else 0.0
                }
            })
            
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/my-guardians")
async def get_my_guardians(current_user: dict = Depends(get_current_user)):
    """
    시니어 시점에서 자신과 연결된 보호자 목록 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    senior_id = current_user.get("user_id")
    try:
        links = supabase.table("guardian_links").select("*, guardian:users(*)").eq("senior_user_id", senior_id).execute()
        
        result = []
        for link in links.data:
            guardian = link.get("guardian")
            if not guardian:
                continue
            result.append({
                "link_id": link["link_id"],
                "relation": link["relation"],
                "guardian_id": guardian["user_id"],
                "name": guardian["name"],
                "phone": guardian["phone"],
                "created_at": link["created_at"]
            })
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
