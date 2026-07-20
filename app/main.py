from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.api import api_router
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="배움페이 시니어 디지털 생활 연습 앱을 위한 Supabase 연동 백엔드 API",
    version="1.0.0"
)

# CORS 설정 (모든 도메인 허용 - 플러터 모바일 & 웹 테스트 환경 대응)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# 통합 라우터 등록
app.include_router(api_router)

@app.on_event("startup")
async def startup_event():
    from app.core import local_db
    local_db.sync_local_users_from_supabase()

@app.get("/")
async def root():
    return {
        "status": "online",
        "project": settings.PROJECT_NAME,
        "message": "배움페이 백엔드 API 서버가 성공적으로 작동 중입니다."
    }

@app.get("/debug-db")
async def debug_db():
    from app.core import local_db
    import sqlite3
    import os
    try:
        conn = sqlite3.connect(local_db.DB_PATH)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM local_users")
        users = cursor.fetchall()
        conn.close()
        return {
            "db_path": local_db.DB_PATH,
            "exists": os.path.exists(local_db.DB_PATH),
            "users": users
        }
    except Exception as e:
        return {"error": str(e)}
