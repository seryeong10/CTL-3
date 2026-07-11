from fastapi import APIRouter, HTTPException
from app.core.config import supabase
from app.models.schemas import MerchantCreate, MerchantResponse
from typing import List

router = APIRouter()

@router.post("/", response_model=MerchantResponse)
async def create_merchant(data: MerchantCreate):
    """
    새로운 가맹점(상점) 등록
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    try:
        # 가맹점주(owner_user_id)가 실제 존재하는 사용자인지 점검 (있는 경우)
        if data.owner_user_id:
            user_check = supabase.table("users").select("user_id").eq("user_id", data.owner_user_id).execute()
            if not user_check.data:
                raise HTTPException(status_code=400, detail="가맹점주로 지정하려는 사용자 ID가 존재하지 않습니다.")
                
        response = supabase.table("merchants").insert({
            "owner_user_id": data.owner_user_id,
            "store_name": data.store_name,
            "address": data.address,
            "phone": data.phone
        }).execute()
        
        if not response.data:
            raise HTTPException(status_code=400, detail="가맹점 등록에 실패했습니다.")
        return response.data[0]
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=List[MerchantResponse])
async def list_merchants():
    """
    전체 가맹점 목록 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    try:
        response = supabase.table("merchants").select("*").execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{merchant_id}", response_model=MerchantResponse)
async def get_merchant(merchant_id: int):
    """
    특정 가맹점 상세 정보 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    try:
        response = supabase.table("merchants").select("*").eq("merchant_id", merchant_id).execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="가맹점을 찾을 수 없습니다.")
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
