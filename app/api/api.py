from fastapi import APIRouter
from app.api.endpoints import (
    users,
    missions,
    logs,
    wallets,
    merchants,
    payments,
    guardians,
    errors
)

api_router = APIRouter()

api_router.include_router(users.router, prefix="/users", tags=["사용자 관리"])
api_router.include_router(missions.router, prefix="/missions", tags=["연습 미션 관리"])
api_router.include_router(logs.router, prefix="/logs", tags=["미션 수행 로그"])
api_router.include_router(wallets.router, prefix="/wallets", tags=["포인트 지갑 관리"])
api_router.include_router(merchants.router, prefix="/merchants", tags=["가맹점 관리"])
api_router.include_router(payments.router, prefix="/payments", tags=["결제 처리"])
api_router.include_router(guardians.router, prefix="/guardians", tags=["시니어-보호자 관리"])
api_router.include_router(errors.router, prefix="/errors", tags=["오동작 터치 에러 로그"])
