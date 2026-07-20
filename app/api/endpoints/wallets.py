from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import WalletResponse, PointTransactionCreate, PointTransactionResponse
from typing import List
from app.core import local_db

router = APIRouter()

@router.get("/me", response_model=WalletResponse)
async def get_my_wallet(current_user: dict = Depends(get_current_user)):
    """
    현재 사용자의 포인트 지갑 정보 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = current_user.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="사용자 ID가 세션에 없습니다.")
        
    try:
        response = supabase.table("point_wallets").select("*").eq("user_id", user_id).execute()
        if not response.data:
            # 지갑이 아직 없으면 새로 생성해서 지급 (시연용 기본 5000P)
            insert_resp = supabase.table("point_wallets").insert({"user_id": user_id, "balance": 5000}).execute()
            return insert_resp.data[0]
        wallet = response.data[0]
        # 시연용 특별 처리: 기존 회원의 잔액이 0이면 강제로 5000P 지급 및 업데이트
        if wallet.get("balance", 0) == 0:
            wallet["balance"] = 5000
            supabase.table("point_wallets").update({"balance": 5000, "updated_at": "now()"}).eq("user_id", user_id).execute()
        return wallet
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user/{user_id}", response_model=WalletResponse)
async def get_user_wallet(user_id: int):
    """
    특정 사용자의 지갑 잔액 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    try:
        response = supabase.table("point_wallets").select("*").eq("user_id", user_id).execute()
        if not response.data:
            # 기본 지갑 생성 (시연용 기본 5000P)
            insert_resp = supabase.table("point_wallets").insert({"user_id": user_id, "balance": 5000}).execute()
            return insert_resp.data[0]
        wallet = response.data[0]
        # 시연용 특별 처리: 기존 회원의 잔액이 0이면 강제로 5000P 지급 및 업데이트
        if wallet.get("balance", 0) == 0:
            wallet["balance"] = 5000
            supabase.table("point_wallets").update({"balance": 5000, "updated_at": "now()"}).eq("user_id", user_id).execute()
        return wallet
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/me/transactions", response_model=List[PointTransactionResponse])
async def get_my_transactions(current_user: dict = Depends(get_current_user)):
    """
    현재 사용자의 포인트 거래 내역 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = current_user.get("user_id")
    try:
        return local_db.get_transactions(user_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/transactions/user/{user_id}", response_model=List[PointTransactionResponse])
async def get_user_transactions(user_id: int):
    """
    특정 사용자의 포인트 거래 내역 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    try:
        return local_db.get_transactions(user_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/transaction", response_model=PointTransactionResponse)
async def create_manual_transaction(data: PointTransactionCreate, current_user: dict = Depends(get_current_user)):
    """
    수동 포인트 입출금 내역 생성 (충전/차감용)
    지갑의 잔액(balance)도 함께 업데이트됩니다.
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = current_user.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="사용자 ID가 필요합니다.")
        
    try:
        # 지갑 유효성 검사 및 정보 획득
        wallet_resp = supabase.table("point_wallets").select("balance").eq("user_id", user_id).execute()
        if not wallet_resp.data:
            # 지갑 없으면 생성 (시연용 기본 5000P 지급)
            supabase.table("point_wallets").insert({"user_id": user_id, "balance": 5000}).execute()
            current_balance = 5000
        else:
            current_balance = wallet_resp.data[0]["balance"]
            
        # 잔액 계산
        if data.type == "earn":
            new_balance = current_balance + data.amount
        elif data.type == "use":
            if current_balance < data.amount:
                raise HTTPException(status_code=400, detail="지갑의 포인트 잔액이 부족합니다.")
            new_balance = current_balance - data.amount
        else:
            raise HTTPException(status_code=400, detail="거래 종류(type)는 'earn' 또는 'use' 여야 합니다.")
            
        # 로컬 DB에 트랜잭션 추가
        desc = data.description or ("포인트 적립" if data.type == "earn" else "포인트 사용")
        tx = local_db.add_transaction(
            user_id=user_id,
            type_=data.type,
            amount=data.amount,
            description=desc
        )
        
        # 지갑 잔액 업데이트
        supabase.table("point_wallets").update({
            "balance": new_balance,
            "updated_at": "now()"
        }).eq("user_id", user_id).execute()
        
        return tx
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
