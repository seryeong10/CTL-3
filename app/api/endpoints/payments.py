from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import PaymentCreate, PaymentResponse
from typing import List

router = APIRouter()

@router.post("/", response_model=PaymentResponse)
async def process_payment(data: PaymentCreate, current_user: dict = Depends(get_current_user)):
    """
    포인트 결제 처리
    - 지갑 포인트 잔액 검사 -> 잔액 차감 -> 결제 로그 기록 -> 포인트 이용 트랜잭션 기록
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = current_user.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="유효하지 않은 사용자 ID 입니다.")
        
    try:
        # 가맹점 존재 확인
        merchant_check = supabase.table("merchants").select("store_name").eq("merchant_id", data.merchant_id).execute()
        if not merchant_check.data:
            raise HTTPException(status_code=404, detail="존재하지 않는 가맹점입니다.")
            
        store_name = merchant_check.data[0]["store_name"]
            
        # 1. 지갑 조회
        wallet_resp = supabase.table("point_wallets").select("balance").eq("user_id", user_id).execute()
        if not wallet_resp.data:
            # 결제 실패 기록 생성
            supabase.table("payments").insert({
                "user_id": user_id,
                "merchant_id": data.merchant_id,
                "amount": data.amount,
                "payment_status": "failed_no_wallet"
            }).execute()
            raise HTTPException(status_code=400, detail="지갑이 활성화되지 않은 사용자입니다.")
            
        current_balance = wallet_resp.data[0]["balance"]
        
        # 2. 잔액 체크
        if current_balance < data.amount:
            # 결제 실패 기록 생성
            supabase.table("payments").insert({
                "user_id": user_id,
                "merchant_id": data.merchant_id,
                "amount": data.amount,
                "payment_status": "failed_insufficient_points"
            }).execute()
            raise HTTPException(status_code=400, detail=f"포인트가 부족합니다. (보유 포인트: {current_balance}P / 필요 포인트: {data.amount}P)")
            
        # 3. 결제 성공 기록 생성
        pay_insert = supabase.table("payments").insert({
            "user_id": user_id,
            "merchant_id": data.merchant_id,
            "amount": data.amount,
            "payment_status": "success"
        }).execute()
        
        if not pay_insert.data:
            raise HTTPException(status_code=400, detail="결제 처리에 실패했습니다.")
            
        payment_record = pay_insert.data[0]
        
        # 4. 지갑 잔액 차감
        new_balance = current_balance - data.amount
        supabase.table("point_wallets").update({
            "balance": new_balance,
            "updated_at": "now()"
        }).eq("user_id", user_id).execute()
        
        # 5. 포인트 차감 거래 내역 기록 (use)
        supabase.table("point_transactions").insert({
            "user_id": user_id,
            "type": "use",
            "amount": data.amount,
            "description": f"가맹점 결제 사용: {store_name}",
            "merchant_id": data.merchant_id
        }).execute()
        
        return payment_record
        
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/me", response_model=List[PaymentResponse])
async def get_my_payments(current_user: dict = Depends(get_current_user)):
    """
    현재 사용자의 결제 내역 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = current_user.get("user_id")
    try:
        response = supabase.table("payments").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user/{user_id}", response_model=List[PaymentResponse])
async def get_user_payments(user_id: int):
    """
    특정 사용자의 결제 내역 조회 (보호자가 시니어 결제를 확인할 때 사용 등)
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    try:
        response = supabase.table("payments").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
