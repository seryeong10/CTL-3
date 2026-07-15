from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import UserCreate, UserResponse
from typing import List, Optional

router = APIRouter()

@router.post("/", response_model=UserResponse)
async def create_user(data: UserCreate):
    """
    신규 사용자 등록 및 포인트 지갑(point_wallets) 자동 생성
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        # 사용자 추가
        user_insert = supabase.table("users").insert({
            "name": data.name,
            "phone": data.phone,
            "birth_year": data.birth_year,
            "user_type": data.user_type
        }).execute()
        
        if not user_insert.data:
            raise HTTPException(status_code=400, detail="사용자 등록에 실패했습니다.")
        
        new_user = user_insert.data[0]
        new_user_id = new_user["user_id"]
        
        # 포인트 지갑 자동 생성
        supabase.table("point_wallets").insert({
            "user_id": new_user_id,
            "balance": 0
        }).execute()
        
        return new_user
    except Exception as e:
        import traceback
        print("❌ 회원가입 에러 발생 상세:")
        traceback.print_exc()
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/me", response_model=UserResponse)
async def read_my_info(current_user: dict = Depends(get_current_user)):
    """
    현재 로그인된 사용자의 정보 조회
    """
    # current_user는 이미 DB에서 조회된 딕셔너리 형태이므로 바로 반환
    if "user_id" not in current_user or current_user["user_id"] is None:
        raise HTTPException(status_code=400, detail="로컬 데이터베이스에 등록되지 않은 Supabase Auth 유저입니다. 먼저 회원가입을 완료해 주세요.")
    return current_user

@router.get("/{user_id}", response_model=UserResponse)
async def read_user(user_id: int):
    """
    특정 ID의 사용자 정보 조회
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        response = supabase.table("users").select("*").eq("user_id", user_id).execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/phone/{phone}", response_model=UserResponse)
async def get_user_by_phone(phone: str):
    """
    전화번호로 사용자 조회 (보호자 연결 등에서 번호로 시니어 검색시 활용)
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        response = supabase.table("users").select("*").eq("phone", phone).execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="해당 연락처의 사용자가 존재하지 않습니다.")
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=List[UserResponse])
async def list_users(user_type: Optional[str] = None):
    """
    사용자 목록 조회 (user_type 필터 기능 제공)
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    try:
        query = supabase.table("users").select("*")
        if user_type:
            query = query.eq("user_type", user_type)
        response = query.execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
