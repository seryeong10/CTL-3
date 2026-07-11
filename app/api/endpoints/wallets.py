from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import WalletResponse, PointTransactionCreate, PointTransactionResponse
from typing import List

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
            # 지갑이 아직 없으면 새로 생성해서 지급
            insert_resp = supabase.table("point_wallets").insert({"user_id": user_id, "balance": 0}).execute()
            return insert_resp.data[0]
        return response.data[0]
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
            # 기본 지갑 생성
            insert_resp = supabase.table("point_wallets").insert({"user_id": user_id, "balance": 0}).execute()
            return insert_resp.data[0]
        return response.data[0]
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
        response = supabase.table("point_transactions").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
        return response.data
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
        response = supabase.table("point_transactions").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
        return response.data
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
            # 지갑 없으면 생성
            supabase.table("point_wallets").insert({"user_id": user_id, "balance": 0}).execute()
            current_balance = 0
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
            
        # 트랜잭션 추가
        tx_resp = supabase.table("point_transactions").insert({
            "user_id": user_id,
            "type": data.type,
            "amount": data.amount,
            "description": data.description,
            "merchant_id": data.merchant_id
        }).execute()
        
        if not tx_resp.data:
            raise HTTPException(status_code=400, detail="거래 생성에 실패했습니다.")
            
        # 지갑 잔액 업데이트
        supabase.table("point_wallets").update({
            "balance": new_balance,
            "updated_at": "now()"
        }).eq("user_id", user_id).execute()
        
        return tx_resp.data[0]
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
