from fastapi import Depends, HTTPException, Header
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.config import supabase
from typing import Optional

# Bearer 토큰 보안 설정 (옵션)
security = HTTPBearer(auto_error=False)

async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    x_user_id: Optional[str] = Header(None, alias="X-User-Id")
):
    """
    사용자 인증을 검증합니다.
    1. 헤더에 X-User-Id 가 있으면 우선 적용 (개발 및 빠른 테스트용)
    2. Bearer 토큰이 전달된 경우 Supabase Auth를 통해 사용자 이메일/UID를 얻어온 후 매핑
    """
    if x_user_id:
        try:
            # X-User-Id가 DB에 실제 존재하는 사용자인지 간략 확인
            user_id = int(x_user_id)
            if not supabase:
                return {"user_id": user_id, "name": "Test User"}
            
            response = supabase.table("users").select("*").eq("user_id", user_id).execute()
            if not response.data:
                raise HTTPException(status_code=401, detail="존재하지 않는 사용자 ID입니다.")
            return response.data[0]
        except ValueError:
            raise HTTPException(status_code=400, detail="X-User-Id 헤더는 숫자 형식이어야 합니다.")
        except Exception as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

    if credentials:
        token = credentials.credentials
        try:
            if not supabase:
                raise HTTPException(status_code=500, detail="Supabase 클라이언트가 초기화되지 않았습니다.")
            
            # 토큰을 사용하여 Supabase에서 사용자 정보 조회
            user_response = supabase.auth.get_user(token)
            if not user_response.user:
                raise HTTPException(status_code=401, detail="유효하지 않은 토큰 사용자입니다.")
            
            # Supabase Auth 사용자 정보(이메일 혹은 phone)와 users 테이블 매핑 시도
            # 여기서는 phone 또는 auth user_id로 users 테이블을 매핑할 수 있습니다.
            # 기본적으로 phone 번호가 있다면 phone 번호로 찾도록 지원
            user_phone = user_response.user.phone or ""
            if user_phone:
                # DB의 phone 양식과 맞추기 (예: +8210... -> 010...)
                clean_phone = user_phone.replace("+82", "0")
                db_user = supabase.table("users").select("*").eq("phone", clean_phone).execute()
                if db_user.data:
                    return db_user.data[0]
            
            # 매핑 실패 시 auth 유저 기본 정보 반환
            return {
                "user_id": None,
                "email": user_response.user.email,
                "phone": user_phone,
                "supabase_uid": user_response.user.id
            }
        except Exception as e:
            raise HTTPException(
                status_code=401, 
                detail=f"인증 실패: 유효하지 않거나 만료된 토큰입니다. ({str(e)})"
            )
            
    raise HTTPException(status_code=401, detail="인증 헤더가 누락되었습니다. (X-User-Id 또는 Authorization Bearer 토큰이 필요합니다.)")
