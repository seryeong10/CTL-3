import sqlite3
import os
from datetime import datetime

# DB file will be saved in the workspace root
DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "baeumpay_local.db")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # 1. point_transactions
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS point_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            type TEXT,
            amount INTEGER,
            description TEXT,
            created_at TEXT
        )
    """)
    
    # 2. user_mission_logs
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_mission_logs (
            log_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            mission_id INTEGER,
            status TEXT,
            score INTEGER,
            wrong_action TEXT,
            created_at TEXT,
            completed_at TEXT
        )
    """)
    
    # 3. touch_error_logs
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS touch_error_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            mission_id INTEGER,
            wrong_action TEXT,
            created_at TEXT
        )
    """)
    
    # 4. local_users for ID/PW login mapping
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS local_users (
            user_id INTEGER PRIMARY KEY,
            login_id TEXT UNIQUE,
            password TEXT
        )
    """)

    # 5. missions
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS missions (
            mission_id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT UNIQUE,
            description TEXT,
            category TEXT,
            difficulty TEXT,
            reward_point INTEGER,
            created_at TEXT
        )
    """)

    # 6. mission_steps
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS mission_steps (
            step_id INTEGER PRIMARY KEY AUTOINCREMENT,
            mission_id INTEGER,
            step_order INTEGER,
            instruction_text TEXT,
            correct_action TEXT,
            voice_guide_text TEXT,
            FOREIGN KEY(mission_id) REFERENCES missions(mission_id) ON DELETE CASCADE
        )
    """)
    
    conn.commit()
    conn.close()

# Initialize database tables on module import
init_db()


def add_local_user(user_id, login_id, password):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO local_users (user_id, login_id, password) VALUES (?, ?, ?)",
            (user_id, login_id, password)
        )
        conn.commit()
        conn.close()
        return True
    except sqlite3.IntegrityError:
        conn.close()
        return False

def get_user_by_login(login_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT user_id, login_id, password FROM local_users WHERE login_id = ?", (login_id,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return {
            "user_id": row[0],
            "login_id": row[1],
            "password": row[2]
        }
    return None

def get_login_id_by_user_id(user_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT login_id FROM local_users WHERE user_id = ?", (user_id,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return row[0]
    return None


def add_transaction(user_id, type_, amount, description):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    created_at = datetime.utcnow().isoformat()
    cursor.execute(
        "INSERT INTO point_transactions (user_id, type, amount, description, created_at) VALUES (?, ?, ?, ?, ?)",
        (user_id, type_, amount, description, created_at)
    )
    conn.commit()
    last_id = cursor.lastrowid
    conn.close()
    return {
        "transaction_id": last_id,
        "user_id": user_id,
        "type": type_,
        "amount": amount,
        "description": description,
        "created_at": created_at
    }

def get_transactions(user_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT id, user_id, type, amount, description, created_at FROM point_transactions WHERE user_id = ? ORDER BY id DESC", (user_id,))
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "transaction_id": r[0],
            "user_id": r[1],
            "type": r[2],
            "amount": r[3],
            "description": r[4],
            "created_at": r[5]
        } for r in rows
    ]

def add_mission_log(user_id, mission_id, status, score, wrong_action):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Check for existing "진행 중" log
    cursor.execute("SELECT log_id FROM user_mission_logs WHERE user_id = ? AND mission_id = ? AND status = '진행 중'", (user_id, mission_id))
    existing = cursor.fetchone()
    
    now_str = datetime.utcnow().isoformat()
    if existing:
        log_id = existing[0]
        completed_at = now_str if status in ["성공", "실패"] else None
        cursor.execute(
            "UPDATE user_mission_logs SET status = ?, score = ?, wrong_action = ?, completed_at = ? WHERE log_id = ?",
            (status, score, wrong_action, completed_at, log_id)
        )
        conn.commit()
        conn.close()
        return {
            "log_id": log_id,
            "user_id": user_id,
            "mission_id": mission_id,
            "status": status,
            "score": score,
            "wrong_action": wrong_action,
            "completed_at": completed_at
        }
    else:
        created_at = now_str
        completed_at = now_str if status in ["성공", "실패"] else None
        cursor.execute(
            "INSERT INTO user_mission_logs (user_id, mission_id, status, score, wrong_action, created_at, completed_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
            (user_id, mission_id, status, score, wrong_action, created_at, completed_at)
        )
        conn.commit()
        last_id = cursor.lastrowid
        conn.close()
        return {
            "log_id": last_id,
            "user_id": user_id,
            "mission_id": mission_id,
            "status": status,
            "score": score,
            "wrong_action": wrong_action,
            "created_at": created_at,
            "completed_at": completed_at
        }

def get_mission_logs(user_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT log_id, user_id, mission_id, status, score, wrong_action, created_at, completed_at FROM user_mission_logs WHERE user_id = ? ORDER BY log_id DESC", (user_id,))
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "log_id": r[0],
            "user_id": r[1],
            "mission_id": r[2],
            "status": r[3],
            "score": r[4],
            "wrong_action": r[5],
            "created_at": r[6],
            "completed_at": r[7]
        } for r in rows
    ]

def add_error_log(user_id, mission_id, wrong_action):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    created_at = datetime.utcnow().isoformat()
    cursor.execute(
        "INSERT INTO touch_error_logs (user_id, mission_id, wrong_action, created_at) VALUES (?, ?, ?, ?)",
        (user_id, mission_id, wrong_action, created_at)
    )
    conn.commit()
    last_id = cursor.lastrowid
    conn.close()
    return {
        "id": last_id,
        "user_id": user_id,
        "mission_id": mission_id,
        "wrong_action": wrong_action,
        "created_at": created_at
    }

def get_error_logs(user_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT id, user_id, mission_id, wrong_action, created_at FROM touch_error_logs WHERE user_id = ? ORDER BY id DESC", (user_id,))
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "user_id": r[1],
            "mission_id": r[2],
            "wrong_action": r[3],
            "created_at": r[4]
        } for r in rows
    ]

def sync_local_users_from_supabase():
    from app.core.config import supabase
    if not supabase:
        print("⚠️ Supabase client not initialized. Skipping sync.")
        return
        
    try:
        response = supabase.table("users").select("*").execute()
        if not response.data:
            print("ℹ️ No users found in Supabase. Skipping sync.")
            return
            
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # 기본 데모 매핑 정의
        demo_mappings = {
            "010-3587-1245": ("hong01", "12345678"),
            "010-4821-9305": ("kim01", "12345678"),
            "010-2294-8810": ("lee01", "12345678"),
            "010-9222-5705": ("tjswjdghks", "wjdghks@123"),
            "01092225705": ("tjswjdghks", "wjdghks@123"),
        }
        
        for user in response.data:
            user_id = user["user_id"]
            phone = user.get("phone", "")
            
            # 데모 매핑에 속하는 경우, 기존에 있더라도 강제로 매핑을 갱신합니다.
            if phone in demo_mappings:
                login_id, password = demo_mappings[phone]
                
                # 중복되는 다른 user_id가 해당 login_id를 쓰고 있다면 제거하여 unique constraint 에러 방지
                cursor.execute("DELETE FROM local_users WHERE login_id = ? AND user_id != ?", (login_id, user_id))
                
                # 강제 UPSERT
                cursor.execute(
                    "INSERT INTO local_users (user_id, login_id, password) VALUES (?, ?, ?) "
                    "ON CONFLICT(user_id) DO UPDATE SET login_id=excluded.login_id, password=excluded.password",
                    (user_id, login_id, password)
                )
                print(f"✅ Forced demo mapping update for user {user.get('name')}: {login_id}")
                continue
            
            # user_id가 이미 존재하는지 체크
            cursor.execute("SELECT user_id FROM local_users WHERE user_id = ?", (user_id,))
            if cursor.fetchone():
                continue
                
            login_id = None
            password = "12345678" # 기본 비밀번호
            
            if phone:
                # 일반 유저인 경우 전화번호(숫자만)를 login_id로 매핑
                clean_phone = phone.replace("-", "").strip()
                if clean_phone:
                    login_id = clean_phone
                else:
                    login_id = f"user_{user_id}"
            else:
                login_id = f"user_{user_id}"
                
            # login_id가 중복될 수 있으므로 unique 확인 및 조정
            original_login_id = login_id
            counter = 1
            while True:
                cursor.execute("SELECT user_id FROM local_users WHERE login_id = ?", (login_id,))
                if not cursor.fetchone():
                    break
                login_id = f"{original_login_id}_{counter}"
                counter += 1
                
            try:
                cursor.execute(
                    "INSERT INTO local_users (user_id, login_id, password) VALUES (?, ?, ?)",
                    (user_id, login_id, password)
                )
                print(f"✅ Synced user {user.get('name')} to local_users: {login_id}")
            except sqlite3.IntegrityError:
                pass
                
        conn.commit()
        conn.close()
    except Exception as e:
        print(f"❌ Failed to sync users from Supabase: {e}")


def add_mission(title, description, category, difficulty, reward_point):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    created_at = datetime.utcnow().isoformat()
    try:
        cursor.execute(
            "INSERT INTO missions (title, description, category, difficulty, reward_point, created_at) VALUES (?, ?, ?, ?, ?, ?)",
            (title, description, category, difficulty, reward_point, created_at)
        )
        conn.commit()
        last_id = cursor.lastrowid
        conn.close()
        return {
            "mission_id": last_id,
            "title": title,
            "description": description,
            "category": category,
            "difficulty": difficulty,
            "reward_point": reward_point,
            "created_at": created_at
        }
    except sqlite3.IntegrityError:
        # 이미 존재하는 경우 해당 데이터 조회하여 반환
        cursor.execute("SELECT mission_id, title, description, category, difficulty, reward_point, created_at FROM missions WHERE title = ?", (title,))
        row = cursor.fetchone()
        conn.close()
        return {
            "mission_id": row[0],
            "title": row[1],
            "description": row[2],
            "category": row[3],
            "difficulty": row[4],
            "reward_point": row[5],
            "created_at": row[6]
        }

def get_missions(category=None, difficulty=None):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    query = "SELECT mission_id, title, description, category, difficulty, reward_point, created_at FROM missions"
    params = []
    conditions = []
    if category:
        conditions.append("category = ?")
        params.append(category)
    if difficulty:
        conditions.append("difficulty = ?")
        params.append(difficulty)
        
    if conditions:
        query += " WHERE " + " AND ".join(conditions)
        
    query += " ORDER BY mission_id ASC"
    cursor.execute(query, tuple(params))
    rows = cursor.fetchall()
    conn.close()
    
    return [
        {
            "mission_id": r[0],
            "title": r[1],
            "description": r[2],
            "category": r[3],
            "difficulty": r[4],
            "reward_point": r[5],
            "created_at": r[6]
        } for r in rows
    ]

def get_mission_detail(mission_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT mission_id, title, description, category, difficulty, reward_point, created_at FROM missions WHERE mission_id = ?", (mission_id,))
    m = cursor.fetchone()
    if not m:
        conn.close()
        return None
        
    cursor.execute("SELECT step_id, step_order, instruction_text, correct_action, voice_guide_text FROM mission_steps WHERE mission_id = ? ORDER BY step_order ASC", (mission_id,))
    steps = cursor.fetchall()
    conn.close()
    
    return {
        "mission_id": m[0],
        "title": m[1],
        "description": m[2],
        "category": m[3],
        "difficulty": m[4],
        "reward_point": m[5],
        "created_at": m[6],
        "steps": [
            {
                "step_id": s[0],
                "step_order": s[1],
                "instruction_text": s[2],
                "correct_action": s[3],
                "voice_guide_text": s[4]
            } for s in steps
        ]
    }

def add_mission_step(mission_id, step_order, instruction_text, correct_action, voice_guide_text):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO mission_steps (mission_id, step_order, instruction_text, correct_action, voice_guide_text) VALUES (?, ?, ?, ?, ?)",
        (mission_id, step_order, instruction_text, correct_action, voice_guide_text)
    )
    conn.commit()
    last_id = cursor.lastrowid
    conn.close()
    return {
        "step_id": last_id,
        "mission_id": mission_id,
        "step_order": step_order,
        "instruction_text": instruction_text,
        "correct_action": correct_action,
        "voice_guide_text": voice_guide_text
    }

def delete_mission(mission_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM missions WHERE mission_id = ?", (mission_id,))
    conn.commit()
    conn.close()
    return True

def seed_default_missions():
    default_missions = [
        ("영화표 예매하기", "영화표 예매하기 연습 미션", "book", "보통", 20),
        ("병원 예약하기", "병원 예약하기 연습 미션", "book", "쉬움", 10),
        ("기차표 예매하기", "기차표 예매하기 연습 미션", "book", "어려움", 30),
        ("택배 배송 조회하기", "택배 배송 조회하기 연습 미션", "order", "쉬움", 10),
        ("인터넷 쇼핑하기", "인터넷 쇼핑하기 연습 미션", "order", "보통", 20),
        ("배달 음식 주문하기", "배달 음식 주문하기 연습 미션", "order", "어려움", 30),
        ("셀프계산대", "셀프계산대 연습 미션", "sim", "어려움", 30),
        ("음식점 키오스크", "음식점 키오스크 연습 미션", "sim", "보통", 20),
        ("카페 키오스크", "카페 키오스크 연습 미션", "sim", "쉬움", 10)
    ]
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    created_at = datetime.utcnow().isoformat()
    for title, desc, cat, diff, pts in default_missions:
        try:
            cursor.execute(
                "INSERT INTO missions (title, description, category, difficulty, reward_point, created_at) VALUES (?, ?, ?, ?, ?, ?)",
                (title, desc, cat, diff, pts, created_at)
            )
            print(f"🌱 Seeded default mission: {title}")
        except sqlite3.IntegrityError:
            # 이미 있으면 무시
            pass
            
    conn.commit()
    conn.close()

# 모듈 로드 시 기본 미션 데이터 시딩 실행
seed_default_missions()


