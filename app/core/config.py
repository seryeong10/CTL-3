import os
from dotenv import load_dotenv
from supabase import create_client, Client

from pathlib import Path
# backend/.env 파일의 절대 경로를 계산하여 로드 (어떤 경로에서 uvicorn을 실행해도 작동하도록 함)
current_file_path = Path(__file__).resolve()
backend_dir = current_file_path.parent.parent.parent
env_path = backend_dir / ".env"

if env_path.exists():
    load_dotenv(dotenv_path=env_path)
else:
    load_dotenv()

class Settings:
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")
    PROJECT_NAME: str = os.getenv("PROJECT_NAME", "배움페이 API")

settings = Settings()

# Supabase 클라이언트 지연 로딩 또는 체크
# 서버 구동시 편의를 위해 임시/빈 값이더라도 일단 에러를 내지 않고 런타임에 처리하게 할 수도 있지만, 
# 사용자 설정 유도를 위해 경고 메시지만 출력 후 생성하게 구현합니다.
if not settings.SUPABASE_URL or not settings.SUPABASE_KEY:
    print("⚠️ WARNING: SUPABASE_URL 또는 SUPABASE_KEY가 .env 파일에 설정되지 않았습니다.")
    supabase: Client = None # type: ignore
else:
    supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
