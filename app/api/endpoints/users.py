from fastapi import APIRouter, HTTPException, Depends
from app.core.config import supabase
from app.core.security import get_current_user
from app.models.schemas import UserCreate, UserResponse, UserLogin
from typing import List, Optional
from app.core import local_db

router = APIRouter()

@router.post("/", response_model=UserResponse)
async def create_user(data: UserCreate):
    """
    신규 사용자 등록 및 포인트 지갑(point_wallets) 자동 생성
    """
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
    
    # 0. 아이디 중복 체크
    if data.login_id:
        existing = local_db.get_user_by_login(data.login_id)
        if existing:
            raise HTTPException(status_code=400, detail="이미 존재하는 아이디입니다.")
    
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
        
        # 로컬 SQLite에 로그인 계정 매핑 저장
        if data.login_id and data.password:
            local_db.add_local_user(new_user_id, data.login_id, data.password)
            new_user["login_id"] = data.login_id
        
        # 포인트 지갑 자동 생성 (시연용으로 기본 5000P 지급)
        supabase.table("point_wallets").insert({
            "user_id": new_user_id,
            "balance": 5000
        }).execute()
        
        return new_user
    except Exception as e:
        import traceback
        print("❌ 회원가입 에러 발생 상세:")
        traceback.print_exc()
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/login", response_model=UserResponse)
async def login_user(data: UserLogin):
    """
    아이디/비밀번호로 로그인
    """
    print(f"\n📥 [로그인 시도] ID: {data.login_id}, PW: {data.password}")
    if not supabase:
        print("❌ 에러: Supabase 클라이언트가 설정되지 않았습니다.")
        raise HTTPException(status_code=500, detail="Supabase 클라이언트가 설정되지 않았습니다.")
        
    user_id = None
    
    # 1. 로컬 SQLite에서 login_id 매핑 조회
    user_mapping = local_db.get_user_by_login(data.login_id)
    if user_mapping:
        if user_mapping["password"] != data.password:
            print(f"❌ 비밀번호 불일치: 입력값={data.password}, DB저장값={user_mapping['password']}")
            raise HTTPException(status_code=400, detail="비밀번호가 일치하지 않습니다.")
        user_id = user_mapping["user_id"]
        print(f"✅ SQLite 매핑 조회 성공: user_id={user_id}")
    else:
        # 2. 백워드 호환성: 전화번호 로그인 지원 (전화번호가 ID이고 비밀번호가 없거나 임의인 경우)
        try:
            print(f"ℹ️ SQLite 매핑 없음. Supabase에서 전화번호({data.login_id})로 조회 시도...")
            response = supabase.table("users").select("*").eq("phone", data.login_id).execute()
            if response.data:
                db_user = response.data[0]
                user_id = db_user["user_id"]
                print(f"✅ Supabase 전화번호 조회 성공: user_id={user_id}")
            else:
                print(f"❌ Supabase 전화번호 조회 실패: 일치하는 회원 없음")
                raise HTTPException(status_code=400, detail="가입 정보가 없거나 일치하는 회원 정보가 없습니다.")
        except Exception as e:
            print(f"❌ Supabase 조회 중 예외 발생: {str(e)}")
            raise HTTPException(status_code=400, detail=str(e))
            
    # 3. Supabase에서 사용자 상세 정보 재확인 및 반환
    try:
        response = supabase.table("users").select("*").eq("user_id", user_id).execute()
        if not response.data:
            print(f"❌ Supabase에서 user_id={user_id} 상세 정보 조회 실패 (404)")
            raise HTTPException(status_code=404, detail="사용자 정보를 데이터베이스에서 찾을 수 없습니다.")
        print(f"🎉 로그인 성공! 유저 정보: {response.data[0]}")
        db_user = response.data[0]
        db_user["login_id"] = local_db.get_login_id_by_user_id(user_id)
        return db_user
    except Exception as e:
        print(f"❌ 최종 로그인 확인 중 예외 발생: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/me", response_model=UserResponse)
async def read_my_info(current_user: dict = Depends(get_current_user)):
    """
    현재 로그인된 사용자의 정보 조회
    """
    # current_user는 이미 DB에서 조회된 딕셔너리 형태이므로 바로 반환
    if "user_id" not in current_user or current_user["user_id"] is None:
        raise HTTPException(status_code=400, detail="로컬 데이터베이스에 등록되지 않은 Supabase Auth 유저입니다. 먼저 회원가입을 완료해 주세요.")
    current_user_copy = dict(current_user)
    current_user_copy["login_id"] = local_db.get_login_id_by_user_id(current_user["user_id"])
    return current_user_copy

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
        user = response.data[0]
        user["login_id"] = local_db.get_login_id_by_user_id(user_id)
        return user
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
        user = response.data[0]
        user["login_id"] = local_db.get_login_id_by_user_id(user["user_id"])
        return user
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
        
        users_list = []
        for user in response.data:
            user_copy = dict(user)
            user_copy["login_id"] = local_db.get_login_id_by_user_id(user["user_id"])
            users_list.append(user_copy)
        return users_list
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
