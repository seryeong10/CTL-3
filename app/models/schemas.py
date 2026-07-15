from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

# ==========================================
# 1. User Schemas
# ==========================================
class UserBase(BaseModel):
    name: str = Field(..., max_length=50)
    phone: Optional[str] = Field(None, max_length=20)
    birth_year: Optional[int] = None
    user_type: str = Field(..., description="senior, guardian, merchant, admin")

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# ==========================================
# 2. Mission & Step Schemas
# ==========================================
class MissionStepBase(BaseModel):
    step_order: int
    instruction_text: str
    correct_action: Optional[str] = Field(None, max_length=100)
    voice_guide_text: Optional[str] = None

class MissionStepCreate(MissionStepBase):
    pass

class MissionStepResponse(MissionStepBase):
    step_id: int
    mission_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class MissionBase(BaseModel):
    title: str = Field(..., max_length=100)
    description: Optional[str] = None
    category: Optional[str] = Field(None, max_length=50)
    difficulty: Optional[str] = Field(None, max_length=20)
    reward_point: int = 0

class MissionCreate(MissionBase):
    pass

class MissionResponse(MissionBase):
    mission_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class MissionDetailResponse(MissionResponse):
    steps: List[MissionStepResponse] = []

# ==========================================
# 3. Mission Log Schemas
# ==========================================
class MissionLogCreate(BaseModel):
    mission_id: int
    status: str = Field("진행 중", description="진행 중, 성공, 실패")
    score: int = 0

class MissionLogUpdate(BaseModel):
    status: str = Field(..., description="진행 중, 성공, 실패")
    score: Optional[int] = None

class MissionLogResponse(BaseModel):
    log_id: int
    user_id: int
    mission_id: int
    status: str
    score: int
    completed_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# ==========================================
# 4. Wallet & Transaction Schemas
# ==========================================
class WalletResponse(BaseModel):
    wallet_id: int
    user_id: int
    balance: int
    updated_at: datetime

    class Config:
        from_attributes = True

class PointTransactionCreate(BaseModel):
    type: str = Field(..., description="earn, use")
    amount: int
    description: Optional[str] = None
    merchant_id: Optional[int] = None

class PointTransactionResponse(BaseModel):
    transaction_id: int
    user_id: int
    type: str
    amount: int
    description: Optional[str] = None
    merchant_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True

# ==========================================
# 5. Merchant Schemas
# ==========================================
class MerchantBase(BaseModel):
    store_name: str = Field(..., max_length=100)
    address: Optional[str] = None
    phone: Optional[str] = Field(None, max_length=20)

class MerchantCreate(MerchantBase):
    owner_user_id: Optional[int] = None

class MerchantResponse(MerchantBase):
    merchant_id: int
    owner_user_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True

# ==========================================
# 6. Payment Schemas
# ==========================================
class PaymentCreate(BaseModel):
    merchant_id: int
    amount: int

class PaymentResponse(BaseModel):
    payment_id: int
    user_id: int
    merchant_id: int
    amount: int
    payment_status: str
    created_at: datetime

    class Config:
        from_attributes = True

# ==========================================
# 7. Guardian Link Schemas
# ==========================================
class GuardianLinkCreate(BaseModel):
    senior_user_id: int
    relation: Optional[str] = Field(None, max_length=50)

class GuardianLinkResponse(BaseModel):
    link_id: int
    senior_user_id: int
    guardian_user_id: int
    relation: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# ==========================================
# 8. Touch Error Log Schemas
# ==========================================
class TouchErrorLogCreate(BaseModel):
    mission_id: int
    step_id: int
    wrong_action: Optional[str] = Field(None, max_length=100)

class TouchErrorLogResponse(BaseModel):
    error_id: int
    user_id: int
    mission_id: int
    step_id: int
    wrong_action: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
