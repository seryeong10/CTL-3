import { useState } from "react";
import { ChevronLeft, ChevronRight, Check, X, Plus, Minus, Search, QrCode, LogOut, User, ShoppingCart } from "lucide-react";

// ─── Design tokens ────────────────────────────────────────────────────────────
const P   = "#4A90E2";   // primary blue
const BG  = "#F8FAFC";   // app background
const WH  = "#FFFFFF";   // card / white
const TX  = "#1F2937";   // main text
const SE  = "#6B7280";   // secondary text
const BR  = "#E5E7EB";   // border
const GR  = "#16A34A";   // green / 쉬움
const YL  = "#B45309";   // amber / 보통
const RD  = "#DC2626";   // red / 어려움 / error

// ─── Shared Types ─────────────────────────────────────────────────────────────
interface NavProps {
  navigate: (screen: string, params?: Record<string, any>) => void;
  goBack: () => void;
  params?: Record<string, any>;
}

// ─── Primitive Components ─────────────────────────────────────────────────────

/** Sticky back-navigation header */
const AppBar = ({
  title, onBack, right,
}: { title: string; onBack: () => void; right?: React.ReactNode }) => (
  <div style={{
    background: WH, borderBottom: `1px solid ${BR}`,
    padding: "14px 20px", display: "flex", alignItems: "center", gap: 8,
    position: "sticky", top: 0, zIndex: 20,
  }}>
    <button onClick={onBack} style={{ border: "none", background: "none", cursor: "pointer", padding: 4, lineHeight: 0 }}>
      <ChevronLeft size={28} color={TX} />
    </button>
    <span style={{ fontSize: 20, fontWeight: 700, color: TX, flex: 1 }}>{title}</span>
    {right}
  </div>
);

/** Full-width primary/outline/danger button  (h=64) */
const PBtn = ({
  children, onClick, variant = "primary", disabled = false,
}: { children: React.ReactNode; onClick: () => void; variant?: "primary" | "outline" | "danger"; disabled?: boolean }) => {
  const bg    = disabled ? BR : variant === "primary" ? P : variant === "danger" ? RD : WH;
  const color = disabled ? SE : variant === "outline" ? TX : "#fff";
  return (
    <button onClick={onClick} disabled={disabled} style={{
      width: "100%", height: 64, borderRadius: 16,
      border: variant === "outline" ? `1.5px solid ${BR}` : "none",
      background: bg, color, fontSize: 17, fontWeight: 700,
      cursor: disabled ? "not-allowed" : "pointer",
    }}>{children}</button>
  );
};

/** White card container */
const Card = ({
  children, onClick, style, selected,
}: { children: React.ReactNode; onClick?: () => void; style?: React.CSSProperties; selected?: boolean }) => (
  <div onClick={onClick} style={{
    background: WH, borderRadius: 16,
    border: `${selected ? 2 : 1}px solid ${selected ? P : BR}`,
    padding: 16, cursor: onClick ? "pointer" : "default", ...style,
  }}>{children}</div>
);

/** Difficulty pill */
const Pill = ({ level }: { level: "쉬움" | "보통" | "어려움" }) => {
  const c = level === "쉬움" ? GR : level === "보통" ? YL : RD;
  return (
    <span style={{ background: c + "18", color: c, fontSize: 11, fontWeight: 700, padding: "3px 9px", borderRadius: 6, whiteSpace: "nowrap" }}>
      {level}
    </span>
  );
};

/** [-] n [+] quantity control */
const QCtrl = ({ n, dec, inc }: { n: number; dec: () => void; inc: () => void }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
    <button onClick={dec} style={{ width: 36, height: 36, borderRadius: 10, border: `1px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}><Minus size={15} /></button>
    <span style={{ fontSize: 17, fontWeight: 700, minWidth: 20, textAlign: "center" }}>{n}</span>
    <button onClick={inc} style={{ width: 36, height: 36, borderRadius: 10, border: `1px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}><Plus size={15} /></button>
  </div>
);

/** Text input */
const TxtInput = ({ placeholder, value, onChange, type = "text" }: { placeholder: string; value: string; onChange: (v: string) => void; type?: string }) => (
  <input type={type} placeholder={placeholder} value={value} onChange={e => onChange(e.target.value)} style={{
    width: "100%", height: 56, borderRadius: 12, border: `1px solid ${BR}`,
    padding: "0 16px", fontSize: 16, color: TX, background: WH, outline: "none",
    boxSizing: "border-box",
  }} />
);

/** Modal overlay */
const Overlay = ({ title, children }: { title: string; children: React.ReactNode }) => (
  <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,.55)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 100, padding: "0 24px" }}>
    <div style={{ background: WH, borderRadius: 24, padding: 28, width: "100%" }}>
      <p style={{ fontSize: 20, fontWeight: 700, color: TX, textAlign: "center", marginBottom: 20 }}>{title}</p>
      {children}
    </div>
  </div>
);

/** Mission complete shared screen */
const Done = ({ name, pts, onHome, onOther }: { name: string; pts: number; onHome: () => void; onOther: () => void }) => (
  <div style={{ padding: "64px 24px 28px", display: "flex", flexDirection: "column", alignItems: "center", gap: 20, minHeight: 760 }}>
    <div style={{ width: 100, height: 100, borderRadius: 50, background: "#DCFCE7", display: "flex", alignItems: "center", justifyContent: "center" }}>
      <Check size={52} color={GR} />
    </div>
    <p style={{ fontSize: 28, fontWeight: 800, color: TX }}>연습 완료!</p>
    <p style={{ fontSize: 19, color: TX }}>{name} 성공</p>
    <div style={{ background: P + "15", borderRadius: 16, padding: "14px 40px", marginTop: 4 }}>
      <span style={{ fontSize: 26, fontWeight: 700, color: P }}>+{pts}P 획득!</span>
    </div>
    <div style={{ width: "100%", marginTop: "auto", display: "flex", flexDirection: "column", gap: 12 }}>
      <PBtn onClick={onHome}>홈으로</PBtn>
      <PBtn onClick={onOther} variant="outline">다른 연습하기</PBtn>
    </div>
  </div>
);

// ─── Cart helper types ────────────────────────────────────────────────────────
interface CartItem { name: string; price: number; qty: number; meta?: string; }

const CartRow = ({ item, idx, onQty, onRm }: { item: CartItem; idx: number; onQty: (i: number, d: number) => void; onRm: (i: number) => void }) => (
  <Card style={{ marginBottom: 10 }}>
    <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <p style={{ fontSize: 15, fontWeight: 600, color: TX, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{item.name}</p>
        {item.meta && <p style={{ fontSize: 12, color: SE, marginTop: 2 }}>{item.meta}</p>}
        <p style={{ fontSize: 15, color: P, fontWeight: 700, marginTop: 3 }}>{(item.price * item.qty).toLocaleString()}원</p>
      </div>
      <QCtrl n={item.qty} dec={() => onQty(idx, -1)} inc={() => onQty(idx, 1)} />
      <button onClick={() => onRm(idx)} style={{ marginLeft: 8, width: 32, height: 32, borderRadius: 8, border: `1px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
        <X size={15} color={SE} />
      </button>
    </div>
  </Card>
);

const CartTotal = ({ items }: { items: CartItem[] }) => {
  const total = items.reduce((s, i) => s + i.price * i.qty, 0);
  return (
    <div style={{ display: "flex", justifyContent: "space-between", borderTop: `1px solid ${BR}`, paddingTop: 16, marginBottom: 16 }}>
      <span style={{ fontSize: 18, fontWeight: 600, color: TX }}>합계</span>
      <span style={{ fontSize: 22, fontWeight: 700, color: P }}>{total.toLocaleString()}원</span>
    </div>
  );
};

// ═══════════════════════════════════════════════════════════════════════════════
// SCREENS
// ═══════════════════════════════════════════════════════════════════════════════

// ── 2. Login ──────────────────────────────────────────────────────────────────
const LoginScreen = ({ navigate }: { navigate: (s: string, p?: any) => void }) => {
  const [tab, setTab] = useState<"user" | "admin">("user");
  const [id, setId] = useState(""); const [pw, setPw] = useState("");
  return (
    <div style={{ padding: "52px 24px 28px", display: "flex", flexDirection: "column", gap: 28, minHeight: 808 }}>
      {/* Logo */}
      <div style={{ textAlign: "center" }}>
        <div style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 72, height: 72, borderRadius: 20, background: P + "15", marginBottom: 16 }}>
          <span style={{ fontSize: 36 }}>📱</span>
        </div>
        <p style={{ fontSize: 28, fontWeight: 800, color: P, letterSpacing: "-0.5px" }}>배움페이</p>
        <p style={{ fontSize: 14, color: SE, marginTop: 6 }}>시니어를 위한 디지털 생활 연습 앱</p>
      </div>

      {/* Tab */}
      <div style={{ display: "flex", background: BR, borderRadius: 14, padding: 4 }}>
        {(["user", "admin"] as const).map(t => (
          <button key={t} onClick={() => setTab(t)} style={{
            flex: 1, height: 48, borderRadius: 10, border: "none", cursor: "pointer",
            background: tab === t ? WH : "transparent",
            color: tab === t ? P : SE,
            fontWeight: tab === t ? 700 : 500, fontSize: 16,
            boxShadow: tab === t ? "0 1px 6px rgba(0,0,0,.1)" : "none",
            transition: "all .18s",
          }}>{t === "user" ? "일반 회원" : "관리자"}</button>
        ))}
      </div>

      {tab === "user" ? (
        <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <TxtInput placeholder="아이디" value={id} onChange={setId} />
          <TxtInput placeholder="비밀번호" value={pw} onChange={setPw} type="password" />
          <PBtn onClick={() => navigate("home")}>로그인</PBtn>
          <PBtn onClick={() => navigate("signup")} variant="outline">회원가입</PBtn>
        </div>
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <TxtInput placeholder="관리자 아이디" value={id} onChange={setId} />
          <TxtInput placeholder="관리자 비밀번호" value={pw} onChange={setPw} type="password" />
          <PBtn onClick={() => navigate("admin_home")}>관리자 로그인</PBtn>
          <p style={{ textAlign: "center", color: SE, fontSize: 14, marginTop: 4 }}>관리자 계정만 이용할 수 있습니다.</p>
        </div>
      )}
    </div>
  );
};

// ── 3. Signup ─────────────────────────────────────────────────────────────────
const SignupScreen = ({ navigate, goBack }: NavProps) => {
  const [f, setF] = useState({ name: "", dob: "", phone: "", id: "", pw: "" });
  const s = (k: string) => (v: string) => setF(x => ({ ...x, [k]: v }));
  const fields: [string, string, string, string][] = [
    ["이름", "name", "홍길동", "text"],
    ["생년월일", "dob", "YYYY.MM.DD", "text"],
    ["전화번호", "phone", "010-0000-0000", "tel"],
    ["아이디", "id", "영문+숫자 조합", "text"],
    ["비밀번호", "pw", "8자 이상 입력", "password"],
  ];
  return (
    <div>
      <AppBar title="회원가입" onBack={goBack} />
      <div style={{ padding: "24px 20px", display: "flex", flexDirection: "column", gap: 18 }}>
        {fields.map(([label, key, ph, type]) => (
          <div key={key}>
            <p style={{ fontSize: 14, color: SE, marginBottom: 8, fontWeight: 600 }}>{label}</p>
            <TxtInput placeholder={ph} value={(f as any)[key]} onChange={s(key)} type={type} />
          </div>
        ))}
        <div style={{ marginTop: 8 }}><PBtn onClick={() => navigate("signup_complete")}>회원가입 신청</PBtn></div>
      </div>
    </div>
  );
};

const SignupCompleteScreen = ({ navigate }: { navigate: (s: string) => void }) => (
  <div style={{ padding: "88px 24px 28px", display: "flex", flexDirection: "column", alignItems: "center", gap: 24, minHeight: 808 }}>
    <div style={{ width: 88, height: 88, borderRadius: 44, background: P + "15", display: "flex", alignItems: "center", justifyContent: "center" }}>
      <Check size={44} color={P} />
    </div>
    <p style={{ fontSize: 24, fontWeight: 700, color: TX, textAlign: "center", lineHeight: 1.4 }}>회원가입 신청이<br />완료되었습니다.</p>
    <p style={{ fontSize: 15, color: SE, textAlign: "center" }}>관리자 승인 후 이용할 수 있습니다.</p>
    <div style={{ marginTop: "auto", width: "100%" }}><PBtn onClick={() => navigate("login")}>로그인 화면으로</PBtn></div>
  </div>
);

// ── 4. Home ───────────────────────────────────────────────────────────────────
const HomeScreen = ({ navigate }: { navigate: (s: string, p?: any) => void }) => {
  const [attended, setAttended] = useState(false);
  const menus = [
    { label: "미션", icon: "🎯", s: "mission_categories" },
    { label: "결제", icon: "💳", s: "payment" },
    { label: "지도", icon: "🗺️", s: "map" },
    { label: "마이페이지", icon: "👤", s: "my_info" },
    { label: "고객센터", icon: "📞", s: "customer_center" },
    { label: "설정", icon: "⚙️", s: "settings" },
  ];
  return (
    <div style={{ background: BG, minHeight: 808, paddingBottom: 28 }}>
      {/* Header */}
      <div style={{ background: WH, padding: "16px 20px", display: "flex", justifyContent: "space-between", alignItems: "center", borderBottom: `1px solid ${BR}` }}>
        <span style={{ fontSize: 22, fontWeight: 800, color: P }}>배움페이</span>
        <div style={{ background: P + "15", borderRadius: 20, padding: "7px 16px" }}>
          <span style={{ fontSize: 15, fontWeight: 700, color: P }}>10,000P</span>
        </div>
      </div>

      <div style={{ padding: "20px" }}>
        {/* Hero card */}
        <div style={{ borderRadius: 20, background: "linear-gradient(135deg, #4A90E2 0%, #60A5FA 100%)", padding: 22, marginBottom: 20 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 20 }}>
            <div>
              <p style={{ fontSize: 20, fontWeight: 700, color: "#fff" }}>안녕하세요, 홍길동님 👋</p>
              <p style={{ fontSize: 14, color: "rgba(255,255,255,.82)", marginTop: 5 }}>오늘도 열심히 연습해봐요!</p>
            </div>
            <div style={{ textAlign: "right" }}>
              <p style={{ fontSize: 12, color: "rgba(255,255,255,.75)" }}>오늘 연습 진행도</p>
              <p style={{ fontSize: 26, fontWeight: 800, color: "#fff", lineHeight: 1.1 }}>1 / 3</p>
            </div>
          </div>
          <button onClick={() => setAttended(true)} disabled={attended} style={{
            width: "100%", height: 52, borderRadius: 14, border: "none",
            background: attended ? "rgba(255,255,255,.25)" : "#fff",
            color: attended ? "rgba(255,255,255,.85)" : P,
            fontSize: 16, fontWeight: 700, cursor: attended ? "default" : "pointer",
          }}>{attended ? "✅  출석 완료!" : "출석 체크하기  +10P"}</button>
        </div>

        {/* Menu grid */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 12, marginBottom: 24 }}>
          {menus.map(m => (
            <Card key={m.label} onClick={() => navigate(m.s)} style={{ textAlign: "center", padding: "18px 8px", cursor: "pointer" }}>
              <div style={{ fontSize: 30, marginBottom: 10 }}>{m.icon}</div>
              <p style={{ fontSize: 14, fontWeight: 600, color: TX }}>{m.label}</p>
            </Card>
          ))}
        </div>

        {/* Today's mission */}
        <p style={{ fontSize: 17, fontWeight: 700, color: TX, marginBottom: 12 }}>오늘의 추천 미션</p>
        <Card style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "18px 16px" }}>
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 5 }}>
              <p style={{ fontSize: 16, fontWeight: 700, color: TX }}>음식점 키오스크</p>
              <Pill level="보통" />
            </div>
            <p style={{ fontSize: 13, color: SE }}>시뮬레이션</p>
          </div>
          <button onClick={() => navigate("restaurant_kiosk")} style={{ height: 46, padding: "0 20px", background: P, color: "#fff", border: "none", borderRadius: 13, fontSize: 15, fontWeight: 600, cursor: "pointer" }}>
            시작하기
          </button>
        </Card>
      </div>
    </div>
  );
};

// ── 5. Mission categories ──────────────────────────────────────────────────────
const MissionCategoriesScreen = ({ navigate, goBack }: NavProps) => (
  <div>
    <AppBar title="연습하기" onBack={goBack} />
    <div style={{ padding: "20px", display: "flex", flexDirection: "column", gap: 14 }}>
      {[
        { title: "시뮬레이션", desc: "키오스크 실전 연습", icon: "🖥️", cat: "sim" },
        { title: "예약하기", desc: "병원 · 영화 · 기차 예약 연습", icon: "📅", cat: "book" },
        { title: "인터넷 주문하기", desc: "쇼핑 · 배달 · 배송 조회 연습", icon: "📦", cat: "order" },
      ].map(c => (
        <Card key={c.cat} onClick={() => navigate("mission_list", { cat: c.cat })} style={{ display: "flex", alignItems: "center", gap: 16, padding: 20, cursor: "pointer" }}>
          <div style={{ width: 60, height: 60, borderRadius: 16, background: P + "15", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 28, flexShrink: 0 }}>{c.icon}</div>
          <div style={{ flex: 1 }}>
            <p style={{ fontSize: 18, fontWeight: 700, color: TX }}>{c.title}</p>
            <p style={{ fontSize: 14, color: SE, marginTop: 3 }}>{c.desc}</p>
          </div>
          <ChevronRight size={22} color={SE} />
        </Card>
      ))}
    </div>
  </div>
);

// ── 6. Mission list ────────────────────────────────────────────────────────────
const MISSIONS: Record<string, Array<{ name: string; level: "쉬움" | "보통" | "어려움"; screen: string }>> = {
  sim: [
    { name: "카페 키오스크", level: "쉬움", screen: "cafe_kiosk" },
    { name: "음식점 키오스크", level: "보통", screen: "restaurant_kiosk" },
    { name: "셀프계산대 이용하기", level: "어려움", screen: "self_checkout" },
  ],
  book: [
    { name: "병원 예약하기", level: "쉬움", screen: "hospital" },
    { name: "영화표 예매하기", level: "보통", screen: "movie_ticket" },
    { name: "기차표 예매하기", level: "어려움", screen: "train_ticket" },
  ],
  order: [
    { name: "택배 배송 조회하기", level: "쉬움", screen: "package_tracking" },
    { name: "인터넷 쇼핑하기", level: "보통", screen: "online_shopping" },
    { name: "배달 음식 주문하기", level: "어려움", screen: "food_delivery" },
  ],
};
const CAT_TITLE: Record<string, string> = { sim: "시뮬레이션", book: "예약하기", order: "인터넷 주문하기" };

const MissionListScreen = ({ navigate, goBack, params }: NavProps) => {
  const cat = params?.cat ?? "sim";
  return (
    <div>
      <AppBar title={CAT_TITLE[cat]} onBack={goBack} />
      <div style={{ padding: "20px", display: "flex", flexDirection: "column", gap: 12 }}>
        {MISSIONS[cat].map(m => (
          <Card key={m.name} style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <div>
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
                <p style={{ fontSize: 17, fontWeight: 600, color: TX }}>{m.name}</p>
                <Pill level={m.level} />
              </div>
            </div>
            <button onClick={() => navigate(m.screen)} style={{ height: 48, padding: "0 22px", background: P, color: "#fff", border: "none", borderRadius: 13, fontSize: 15, fontWeight: 600, cursor: "pointer" }}>시작</button>
          </Card>
        ))}
      </div>
    </div>
  );
};

// ── 7. Cafe Kiosk ─────────────────────────────────────────────────────────────
type CStep = "store" | "menu" | "cart";
const CafeKioskScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<CStep>("store");
  const [storeType, setStoreType] = useState("매장");
  const [cart, setCart] = useState<CartItem[]>([]);
  const [pending, setPending] = useState<{ name: string; price: number } | null>(null);
  const [done, setDone] = useState(false);

  const MENUS = [{ name: "아메리카노", price: 3000 }, { name: "카페라떼", price: 4000 }, { name: "바닐라라떼", price: 4500 }, { name: "초코라떼", price: 4500 }];
  const addTemp = (temp: string) => {
    if (!pending) return;
    const key = `${pending.name} ${temp}`;
    setCart(p => { const e = p.find(i => i.name === key); return e ? p.map(i => i === e ? { ...i, qty: i.qty + 1 } : i) : [...p, { name: key, price: pending.price, qty: 1, meta: temp }]; });
    setPending(null);
  };
  const rm  = (i: number) => setCart(p => p.filter((_, j) => j !== i));
  const chQ = (i: number, d: number) => setCart(p => p.map((x, j) => j === i ? { ...x, qty: Math.max(1, x.qty + d) } : x));

  if (done) return <Done name="카페 키오스크" pts={10} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="카페 키오스크" onBack={step === "store" ? goBack : () => setStep(step === "cart" ? "menu" : "store")} />
      <div style={{ padding: "20px" }}>
        {step === "store" && (
          <>
            <p style={{ fontSize: 20, fontWeight: 700, textAlign: "center", marginBottom: 8, color: TX }}>어떻게 드실 건가요?</p>
            <p style={{ fontSize: 14, color: SE, textAlign: "center", marginBottom: 32 }}>이용 방식을 선택해주세요</p>
            <div style={{ display: "flex", gap: 16 }}>
              {["매장", "포장"].map(t => (
                <button key={t} onClick={() => { setStoreType(t); setStep("menu"); }} style={{ flex: 1, height: 168, borderRadius: 20, border: `2px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 12 }}>
                  <span style={{ fontSize: 52 }}>{t === "매장" ? "🏠" : "📦"}</span>
                  <span style={{ fontSize: 22, fontWeight: 700, color: TX }}>{t}</span>
                </button>
              ))}
            </div>
          </>
        )}
        {step === "menu" && (
          <>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
              <span style={{ fontSize: 15, color: SE }}>{storeType} 주문</span>
              <button onClick={() => setStep("cart")} style={{ background: P, color: "#fff", border: "none", borderRadius: 12, padding: "8px 18px", fontSize: 15, fontWeight: 600, cursor: "pointer" }}>
                장바구니{cart.length > 0 ? ` (${cart.reduce((s, i) => s + i.qty, 0)})` : ""}
              </button>
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
              {MENUS.map(m => (
                <Card key={m.name} style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div>
                    <p style={{ fontSize: 17, fontWeight: 600, color: TX }}>{m.name}</p>
                    <p style={{ fontSize: 15, color: P, fontWeight: 700, marginTop: 3 }}>{m.price.toLocaleString()}원</p>
                  </div>
                  <button onClick={() => setPending(m)} style={{ height: 48, padding: "0 22px", background: P, color: "#fff", border: "none", borderRadius: 13, fontSize: 15, fontWeight: 600, cursor: "pointer" }}>담기</button>
                </Card>
              ))}
            </div>
          </>
        )}
        {step === "cart" && (
          <>
            {cart.length === 0
              ? <p style={{ textAlign: "center", color: SE, padding: "60px 0", fontSize: 16 }}>장바구니가 비어있습니다</p>
              : <>{cart.map((item, i) => <CartRow key={i} item={item} idx={i} onQty={chQ} onRm={rm} />)}<CartTotal items={cart} /></>
            }
            <div style={{ display: "flex", gap: 12 }}>
              <PBtn onClick={() => setStep("menu")} variant="outline">메뉴 더 담기</PBtn>
              <PBtn onClick={() => setDone(true)} disabled={cart.length === 0}>결제하기</PBtn>
            </div>
          </>
        )}
      </div>

      {pending && (
        <Overlay title="온도를 선택해주세요">
          <p style={{ textAlign: "center", color: SE, marginBottom: 20 }}>{pending.name}</p>
          <div style={{ display: "flex", gap: 12 }}>
            <button onClick={() => addTemp("ICE")} style={{ flex: 1, height: 72, borderRadius: 16, border: "2px solid #93C5FD", background: "#EFF6FF", color: "#1D4ED8", fontSize: 20, fontWeight: 700, cursor: "pointer" }}>❄️ ICE</button>
            <button onClick={() => addTemp("HOT")} style={{ flex: 1, height: 72, borderRadius: 16, border: "2px solid #FCA5A5", background: "#FEF2F2", color: "#991B1B", fontSize: 20, fontWeight: 700, cursor: "pointer" }}>🔥 HOT</button>
          </div>
          <button onClick={() => setPending(null)} style={{ width: "100%", height: 48, marginTop: 12, border: `1px solid ${BR}`, borderRadius: 12, background: WH, color: SE, fontSize: 15, cursor: "pointer" }}>취소</button>
        </Overlay>
      )}
    </div>
  );
};

// ── 8. Restaurant Kiosk ───────────────────────────────────────────────────────
type RStep = "store" | "menu" | "type" | "side" | "drink" | "cart";
const RestKioskScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<RStep>("store");
  const [storeType, setStoreType] = useState("매장");
  const [cart, setCart] = useState<CartItem[]>([]);
  const [selMenu, setSelMenu] = useState<{ name: string; price: number } | null>(null);
  const [selSide, setSelSide] = useState("");
  const [done, setDone] = useState(false);

  const MENUS = [{ name: "치즈버거", price: 5500 }, { name: "불고기버거", price: 5800 }, { name: "새우버거", price: 6000 }, { name: "치킨버거", price: 6200 }];
  const SIDES = ["감자튀김", "치즈스틱", "해시브라운"];
  const DRINKS = ["콜라", "사이다", "오렌지주스"];

  const addSingle = () => {
    if (!selMenu) return;
    setCart(p => { const e = p.find(i => i.name === selMenu.name + " 단품"); return e ? p.map(i => i === e ? { ...i, qty: i.qty + 1 } : i) : [...p, { name: selMenu.name + " 단품", price: selMenu.price, qty: 1 }]; });
    setSelMenu(null); setStep("menu");
  };
  const addSet = (drink: string) => {
    if (!selMenu || !selSide) return;
    setCart(p => [...p, { name: `${selMenu.name} 세트`, price: selMenu.price + 2000, qty: 1, meta: `${selSide} · ${drink}` }]);
    setSelMenu(null); setSelSide(""); setStep("menu");
  };
  const rm  = (i: number) => setCart(p => p.filter((_, j) => j !== i));
  const chQ = (i: number, d: number) => setCart(p => p.map((x, j) => j === i ? { ...x, qty: Math.max(1, x.qty + d) } : x));
  const PREV: Record<string, RStep> = { menu: "store", type: "menu", side: "type", drink: "side", cart: "menu" };
  const backFn = () => { if (step === "store") goBack(); else setStep(PREV[step] as RStep || "store"); };

  if (done) return <Done name="음식점 키오스크" pts={20} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="음식점 키오스크" onBack={backFn} />
      <div style={{ padding: "20px" }}>
        {step === "store" && (
          <>
            <p style={{ fontSize: 20, fontWeight: 700, textAlign: "center", marginBottom: 32, color: TX }}>어떻게 드실 건가요?</p>
            <div style={{ display: "flex", gap: 16 }}>
              {["매장", "포장"].map(t => (
                <button key={t} onClick={() => { setStoreType(t); setStep("menu"); }} style={{ flex: 1, height: 168, borderRadius: 20, border: `2px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 12 }}>
                  <span style={{ fontSize: 52 }}>{t === "매장" ? "🏠" : "📦"}</span>
                  <span style={{ fontSize: 22, fontWeight: 700, color: TX }}>{t}</span>
                </button>
              ))}
            </div>
          </>
        )}
        {step === "menu" && (
          <>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 16, alignItems: "center" }}>
              <span style={{ color: SE }}>{storeType} 주문</span>
              <button onClick={() => setStep("cart")} style={{ background: P, color: "#fff", border: "none", borderRadius: 12, padding: "8px 18px", fontSize: 15, fontWeight: 600, cursor: "pointer" }}>
                장바구니{cart.length > 0 ? ` (${cart.reduce((s, i) => s + i.qty, 0)})` : ""}
              </button>
            </div>
            {MENUS.map(m => (
              <Card key={m.name} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
                <div><p style={{ fontSize: 17, fontWeight: 600, color: TX }}>{m.name}</p><p style={{ fontSize: 15, color: P, fontWeight: 700, marginTop: 3 }}>{m.price.toLocaleString()}원</p></div>
                <button onClick={() => { setSelMenu(m); setStep("type"); }} style={{ height: 48, padding: "0 20px", background: P, color: "#fff", border: "none", borderRadius: 13, fontSize: 15, fontWeight: 600, cursor: "pointer" }}>선택</button>
              </Card>
            ))}
          </>
        )}
        {step === "type" && (
          <>
            <p style={{ fontSize: 20, fontWeight: 700, textAlign: "center", marginBottom: 6, color: TX }}>{selMenu?.name}</p>
            <p style={{ fontSize: 14, color: SE, textAlign: "center", marginBottom: 32 }}>단품 또는 세트를 선택해주세요</p>
            <div style={{ display: "flex", gap: 16 }}>
              {[{ l: "단품", sub: `${selMenu?.price.toLocaleString()}원`, icon: "🍔", fn: addSingle }, { l: "세트", sub: `${((selMenu?.price || 0) + 2000).toLocaleString()}원`, icon: "🍔🍟🥤", fn: () => setStep("side") }].map(o => (
                <button key={o.l} onClick={o.fn} style={{ flex: 1, height: 148, borderRadius: 20, border: `2px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 10 }}>
                  <span style={{ fontSize: 32 }}>{o.icon}</span>
                  <span style={{ fontSize: 20, fontWeight: 700, color: TX }}>{o.l}</span>
                  <span style={{ fontSize: 14, color: SE }}>{o.sub}</span>
                </button>
              ))}
            </div>
          </>
        )}
        {step === "side" && (
          <>
            <p style={{ fontSize: 20, fontWeight: 700, marginBottom: 20, color: TX }}>사이드를 선택해주세요</p>
            {SIDES.map(s => <button key={s} onClick={() => { setSelSide(s); setStep("drink"); }} style={{ width: "100%", height: 68, borderRadius: 16, border: `2px solid ${selSide === s ? P : BR}`, background: selSide === s ? P + "10" : WH, fontSize: 18, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>{s}</button>)}
          </>
        )}
        {step === "drink" && (
          <>
            <p style={{ fontSize: 20, fontWeight: 700, marginBottom: 20, color: TX }}>음료를 선택해주세요</p>
            {DRINKS.map(d => <button key={d} onClick={() => addSet(d)} style={{ width: "100%", height: 68, borderRadius: 16, border: `2px solid ${BR}`, background: WH, fontSize: 18, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>{d}</button>)}
          </>
        )}
        {step === "cart" && (
          <>
            {cart.length === 0
              ? <p style={{ textAlign: "center", color: SE, padding: "60px 0", fontSize: 16 }}>장바구니가 비어있습니다</p>
              : <>{cart.map((item, i) => <CartRow key={i} item={item} idx={i} onQty={chQ} onRm={rm} />)}<CartTotal items={cart} /></>
            }
            <div style={{ display: "flex", gap: 12 }}>
              <PBtn onClick={() => setStep("menu")} variant="outline">메뉴 더 담기</PBtn>
              <PBtn onClick={() => setDone(true)} disabled={cart.length === 0}>결제하기</PBtn>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

// ── 9. Self Checkout ──────────────────────────────────────────────────────────
type SCStep = "start" | "scan" | "bag" | "pay";
const SelfCheckoutScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<SCStep>("start");
  const [cart, setCart] = useState<CartItem[]>([]);
  const [bag, setBag] = useState<boolean | null>(null);
  const [done, setDone] = useState(false);

  const PRODUCTS = [{ name: "생수", price: 1000 }, { name: "컵라면", price: 1500 }, { name: "과자", price: 2000 }, { name: "우유", price: 2500 }, { name: "바나나우유", price: 1800 }, { name: "휴지", price: 5000 }];
  const scan = (p: { name: string; price: number }) => setCart(prev => { const e = prev.find(i => i.name === p.name); return e ? prev.map(i => i === e ? { ...i, qty: i.qty + 1 } : i) : [...prev, { ...p, qty: 1 }]; });
  const rm  = (i: number) => setCart(p => p.filter((_, j) => j !== i));
  const chQ = (i: number, d: number) => setCart(p => p.map((x, j) => j === i ? { ...x, qty: Math.max(1, x.qty + d) } : x));
  const sub = cart.reduce((s, i) => s + i.price * i.qty, 0);
  const total = sub + (bag ? 100 : 0);
  const PREV: Record<string, SCStep> = { scan: "start", bag: "scan", pay: "bag" };
  const backFn = () => { if (step === "start") goBack(); else setStep(PREV[step] as SCStep || "start"); };

  if (done) return <Done name="셀프계산대" pts={30} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="셀프계산대" onBack={backFn} />
      <div style={{ padding: "20px" }}>
        {step === "start" && (
          <div style={{ textAlign: "center", paddingTop: 56 }}>
            <span style={{ fontSize: 84 }}>🏪</span>
            <p style={{ fontSize: 24, fontWeight: 700, marginTop: 24, marginBottom: 12, color: TX }}>셀프계산대</p>
            <p style={{ fontSize: 15, color: SE, marginBottom: 52 }}>상품을 직접 스캔하고 결제해보세요</p>
            <PBtn onClick={() => setStep("scan")}>시작하기</PBtn>
          </div>
        )}
        {step === "scan" && (
          <>
            <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 14, color: TX }}>상품을 눌러 스캔하세요</p>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 20 }}>
              {PRODUCTS.map(p => (
                <button key={p.name} onClick={() => scan(p)} style={{ height: 80, borderRadius: 16, border: `1px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 4 }}>
                  <span style={{ fontSize: 14, fontWeight: 600, color: TX }}>{p.name}</span>
                  <span style={{ fontSize: 13, color: P, fontWeight: 700 }}>{p.price.toLocaleString()}원</span>
                </button>
              ))}
            </div>
            {cart.length > 0 && (
              <>
                <p style={{ fontSize: 16, fontWeight: 700, marginBottom: 12, color: TX }}>담은 상품</p>
                {cart.map((item, i) => <CartRow key={i} item={item} idx={i} onQty={chQ} onRm={rm} />)}
                <div style={{ marginTop: 12 }}><PBtn onClick={() => setStep("bag")}>다음</PBtn></div>
              </>
            )}
          </>
        )}
        {step === "bag" && (
          <>
            <p style={{ fontSize: 20, fontWeight: 700, textAlign: "center", marginBottom: 8, color: TX }}>봉투가 필요하신가요?</p>
            <p style={{ fontSize: 14, color: SE, textAlign: "center", marginBottom: 32 }}>봉투 추가 시 100원이 추가됩니다</p>
            <div style={{ display: "flex", gap: 16, marginBottom: 32 }}>
              {[{ l: "필요함  +100원", v: true }, { l: "필요 없음", v: false }].map(o => (
                <button key={String(o.v)} onClick={() => setBag(o.v)} style={{ flex: 1, height: 100, borderRadius: 20, border: `2px solid ${bag === o.v ? P : BR}`, background: bag === o.v ? P + "10" : WH, fontSize: 15, fontWeight: 600, cursor: "pointer", color: TX }}>{o.l}</button>
              ))}
            </div>
            <PBtn onClick={() => setStep("pay")} disabled={bag === null}>다음</PBtn>
          </>
        )}
        {step === "pay" && (
          <>
            <p style={{ fontSize: 20, fontWeight: 700, marginBottom: 20, color: TX }}>결제 방법을 선택해주세요</p>
            <Card style={{ marginBottom: 20 }}>
              <div style={{ display: "flex", justifyContent: "space-between", padding: "9px 0", borderBottom: `1px solid ${BR}` }}><span style={{ color: SE }}>상품 금액</span><span style={{ fontWeight: 600 }}>{sub.toLocaleString()}원</span></div>
              {bag && <div style={{ display: "flex", justifyContent: "space-between", padding: "9px 0", borderBottom: `1px solid ${BR}` }}><span style={{ color: SE }}>봉투</span><span style={{ fontWeight: 600 }}>100원</span></div>}
              <div style={{ display: "flex", justifyContent: "space-between", padding: "9px 0" }}><span style={{ fontSize: 17, fontWeight: 700, color: TX }}>합계</span><span style={{ fontSize: 18, fontWeight: 700, color: P }}>{total.toLocaleString()}원</span></div>
            </Card>
            <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
              {["💳  카드 결제", "📱  간편결제"].map(m => (
                <button key={m} onClick={() => setDone(true)} style={{ height: 72, borderRadius: 16, border: `2px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 17, fontWeight: 600, color: TX }}>{m}</button>
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
};

// ── 10. Hospital Reservation ───────────────────────────────────────────────────
type HStep = "hospital" | "dept" | "date" | "time" | "confirm";
const HospitalScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<HStep>("hospital");
  const [hospital, setHospital] = useState(""); const [dept, setDept] = useState("");
  const [date, setDate] = useState(""); const [time, setTime] = useState("");
  const [popup, setPopup] = useState(false); const [done, setDone] = useState(false);
  const PREV: Record<string, HStep> = { dept: "hospital", date: "dept", time: "date", confirm: "time" };
  const backFn = () => { if (step === "hospital") goBack(); else setStep(PREV[step] as HStep || "hospital"); };
  if (done) return <Done name="병원 예약하기" pts={10} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="병원 예약하기" onBack={backFn} />
      <div style={{ padding: "20px" }}>
        {step === "hospital" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>병원을 선택해주세요</p>
          {["우리병원", "행복병원", "중앙병원"].map(h => <button key={h} onClick={() => { setHospital(h); setStep("dept"); }} style={{ width: "100%", height: 68, borderRadius: 16, border: `2px solid ${hospital === h ? P : BR}`, background: hospital === h ? P + "10" : WH, fontSize: 17, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>🏥  {h}</button>)}
        </>}
        {step === "dept" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>진료과를 선택해주세요</p>
          {["내과", "정형외과", "안과", "이비인후과", "피부과"].map(d => <button key={d} onClick={() => { setDept(d); setStep("date"); }} style={{ width: "100%", height: 64, borderRadius: 16, border: `2px solid ${dept === d ? P : BR}`, background: dept === d ? P + "10" : WH, fontSize: 17, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>{d}</button>)}
        </>}
        {step === "date" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>예약 날짜를 선택해주세요</p>
          {["오늘", "내일", "7월 10일", "7월 11일", "7월 12일"].map(d => <button key={d} onClick={() => { setDate(d); setStep("time"); }} style={{ width: "100%", height: 64, borderRadius: 16, border: `2px solid ${date === d ? P : BR}`, background: date === d ? P + "10" : WH, fontSize: 17, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>📅  {d}</button>)}
        </>}
        {step === "time" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>예약 시간을 선택해주세요</p>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
            {["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "14:00", "14:30", "15:00"].map(t => <button key={t} onClick={() => { setTime(t); setStep("confirm"); }} style={{ height: 56, borderRadius: 14, border: `2px solid ${time === t ? P : BR}`, background: time === t ? P + "10" : WH, fontSize: 16, fontWeight: 600, color: TX, cursor: "pointer" }}>{t}</button>)}
          </div>
        </>}
        {step === "confirm" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>예약 정보를 확인해주세요</p>
          <Card style={{ marginBottom: 20 }}>
            {[["병원", hospital], ["진료과", dept], ["날짜", date], ["시간", time], ["이름", "홍길동"], ["전화번호", "010-3587-1245"]].map(([k, v]) => (
              <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "11px 0", borderBottom: `1px solid ${BR}` }}>
                <span style={{ color: SE, fontSize: 15 }}>{k}</span>
                <span style={{ fontWeight: 600, fontSize: 15, color: TX }}>{v}</span>
              </div>
            ))}
          </Card>
          <PBtn onClick={() => setPopup(true)}>예약하기</PBtn>
        </>}
      </div>
      {popup && (
        <Overlay title="예약이 완료되었습니다.">
          <div style={{ background: "#FFFBEB", borderRadius: 12, padding: 16, marginBottom: 20, border: "1px solid #FDE68A" }}>
            <p style={{ fontSize: 14, fontWeight: 700, color: "#92400E", marginBottom: 6 }}>⚠️ 신분증 지참 안내</p>
            <p style={{ fontSize: 14, color: "#92400E", lineHeight: 1.6 }}>병원 방문 시 신분증을 꼭 지참해주세요.<br />신분증이 없으면 진료 접수가 어려울 수 있습니다.</p>
          </div>
          <button onClick={() => setDone(true)} style={{ width: "100%", height: 56, borderRadius: 14, border: "none", background: P, color: "#fff", fontSize: 17, fontWeight: 700, cursor: "pointer" }}>확인</button>
        </Overlay>
      )}
    </div>
  );
};

// ── 11. Movie Ticket ──────────────────────────────────────────────────────────
type MvStep = "movie" | "datetime" | "people" | "seat" | "confirm";
const MovieTicketScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<MvStep>("movie");
  const [movie, setMovie] = useState("");
  const [selDate, setSelDate] = useState(""); const [selTime, setSelTime] = useState(""); const [selHall, setSelHall] = useState("");
  const [adults, setAdults] = useState(1); const [teens, setTeens] = useState(0); const [srs, setSrs] = useState(0);
  const [seats, setSeats] = useState<string[]>([]);
  const [done, setDone] = useState(false);

  const DATES = [{ d: "오늘", n: "08" }, { d: "목", n: "09" }, { d: "금", n: "10" }, { d: "토", n: "11" }, { d: "일", n: "12" }, { d: "월", n: "13" }];
  const HALLS = [{ hall: "1관", times: ["10:00~12:00", "14:00~16:00", "18:30~20:30"] }, { hall: "2관", times: ["11:00~13:00", "15:30~17:30", "19:00~21:00"] }];
  const ROWS = ["A", "B", "C", "D"]; const COLS = [1, 2, 3, 4, 5, 6];
  const TAKEN = new Set(["A2", "B4", "C1", "C5", "D3"]);
  const total = adults + teens + srs;
  const price = adults * 12000 + teens * 9000 + srs * 7000;
  const toggleSeat = (s: string) => setSeats(p => p.includes(s) ? p.filter(x => x !== s) : p.length >= total ? [...p.slice(1), s] : [...p, s]);
  const PREV: Record<string, MvStep> = { datetime: "movie", people: "datetime", seat: "people", confirm: "seat" };
  const backFn = () => { if (step === "movie") goBack(); else setStep(PREV[step] as MvStep || "movie"); };
  if (done) return <Done name="영화표 예매하기" pts={20} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="영화표 예매하기" onBack={backFn} />
      <div style={{ padding: "20px" }}>
        {step === "movie" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>영화를 선택해주세요</p>
          {["별빛 여행", "우리들의 봄", "행복한 하루"].map(m => <button key={m} onClick={() => { setMovie(m); setStep("datetime"); }} style={{ width: "100%", height: 80, borderRadius: 16, border: `2px solid ${movie === m ? P : BR}`, background: movie === m ? P + "10" : WH, fontSize: 18, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12, display: "flex", alignItems: "center", justifyContent: "center", gap: 10 }}>🎬  {m}</button>)}
        </>}
        {step === "datetime" && <>
          <p style={{ fontSize: 16, fontWeight: 700, marginBottom: 12, color: TX }}>날짜를 선택해주세요</p>
          <div style={{ display: "flex", gap: 8, marginBottom: 24, overflowX: "auto", paddingBottom: 4 }}>
            {DATES.map(d => <button key={d.n} onClick={() => setSelDate(d.d)} style={{ minWidth: 52, height: 64, borderRadius: 14, border: `2px solid ${selDate === d.d ? P : BR}`, background: selDate === d.d ? P : WH, color: selDate === d.d ? "#fff" : TX, cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 2, flexShrink: 0 }}>
              <span style={{ fontSize: 11 }}>{d.d}</span>
              <span style={{ fontSize: 18, fontWeight: 700 }}>{d.n}</span>
            </button>)}
          </div>
          <p style={{ fontSize: 16, fontWeight: 700, marginBottom: 12, color: TX }}>시간을 선택해주세요</p>
          {HALLS.map(h => (
            <div key={h.hall} style={{ marginBottom: 16 }}>
              <p style={{ fontSize: 14, color: SE, fontWeight: 700, marginBottom: 8 }}>{h.hall}</p>
              {h.times.map(t => <button key={t} onClick={() => { setSelTime(t); setSelHall(h.hall); }} style={{ width: "100%", height: 52, borderRadius: 12, border: `2px solid ${selTime === t && selHall === h.hall ? P : BR}`, background: selTime === t && selHall === h.hall ? P + "10" : WH, fontSize: 15, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 8 }}>{t}</button>)}
            </div>
          ))}
          {selDate && selTime && <PBtn onClick={() => setStep("people")}>다음</PBtn>}
        </>}
        {step === "people" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>인원을 선택해주세요</p>
          {[{ label: "성인", price: "12,000원", val: adults, set: setAdults, min: 1 }, { label: "청소년", price: "9,000원", val: teens, set: setTeens, min: 0 }, { label: "경로", price: "7,000원", val: srs, set: setSrs, min: 0 }].map(p => (
            <Card key={p.label} style={{ marginBottom: 12, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div><p style={{ fontSize: 16, fontWeight: 600, color: TX }}>{p.label}</p><p style={{ fontSize: 13, color: SE }}>{p.price}</p></div>
              <QCtrl n={p.val} dec={() => p.set(Math.max(p.min, p.val - 1))} inc={() => p.set(p.val + 1)} />
            </Card>
          ))}
          <div style={{ background: P + "10", borderRadius: 12, padding: "12px 16px", marginBottom: 16 }}>
            <p style={{ fontSize: 16, fontWeight: 700, color: P }}>총 {total}명 · {price.toLocaleString()}원</p>
          </div>
          <PBtn onClick={() => setStep("seat")} disabled={total === 0}>좌석 선택</PBtn>
        </>}
        {step === "seat" && <>
          <div style={{ background: "#1F2937", borderRadius: 8, padding: "8px 0", textAlign: "center", marginBottom: 20 }}>
            <p style={{ color: "#9CA3AF", fontSize: 13, fontWeight: 700, letterSpacing: 4 }}>SCREEN</p>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(6,1fr)", gap: 6, marginBottom: 16 }}>
            {ROWS.map(r => COLS.map(c => {
              const s = `${r}${c}`; const tk = TAKEN.has(s); const sel = seats.includes(s);
              return <button key={s} onClick={() => !tk && toggleSeat(s)} disabled={tk} style={{ height: 42, borderRadius: 8, border: "none", fontSize: 11, fontWeight: 700, cursor: tk ? "default" : "pointer", background: tk ? "#E5E7EB" : sel ? P : WH, color: tk ? "#9CA3AF" : sel ? "#fff" : TX, boxShadow: !tk && !sel ? `inset 0 0 0 1px ${BR}` : "none" }}>{s}</button>;
            }))}
          </div>
          <div style={{ display: "flex", gap: 14, marginBottom: 14 }}>
            {[{ bg: WH, brd: BR, label: "선택 가능" }, { bg: P, label: "선택됨" }, { bg: "#E5E7EB", label: "불가" }].map(x => (
              <div key={x.label} style={{ display: "flex", alignItems: "center", gap: 6 }}>
                <div style={{ width: 18, height: 18, borderRadius: 4, background: x.bg, border: (x as any).brd ? `1px solid ${(x as any).brd}` : "none" }} />
                <span style={{ fontSize: 12, color: SE }}>{x.label}</span>
              </div>
            ))}
          </div>
          <p style={{ fontSize: 14, color: SE, marginBottom: 12 }}>선택: {seats.join(", ") || "없음"} ({seats.length}/{total}석)</p>
          <PBtn onClick={() => setStep("confirm")} disabled={seats.length !== total}>다음</PBtn>
        </>}
        {step === "confirm" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>예매 정보 확인</p>
          <Card style={{ marginBottom: 20 }}>
            {[["영화", movie], ["날짜", selDate], ["상영관", selHall], ["시간", selTime], ["인원", `${total}명`], ["좌석", seats.join(", ")], ["결제금액", `${price.toLocaleString()}원`]].map(([k, v]) => (
              <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "11px 0", borderBottom: `1px solid ${BR}` }}>
                <span style={{ color: SE, fontSize: 15 }}>{k}</span>
                <span style={{ fontWeight: 600, fontSize: 15, color: TX }}>{v}</span>
              </div>
            ))}
          </Card>
          <PBtn onClick={() => setDone(true)}>결제하기</PBtn>
        </>}
      </div>
    </div>
  );
};

// ── 12. Train Ticket ──────────────────────────────────────────────────────────
type TrStep = "depart" | "arrive" | "date" | "train" | "seat" | "confirm";
const TrainTicketScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<TrStep>("depart");
  const [dep, setDep] = useState(""); const [arr, setArr] = useState("");
  const [date, setDate] = useState(""); const [train, setTrain] = useState("");
  const [seats, setSeats] = useState<string[]>([]);
  const [done, setDone] = useState(false);

  const STATIONS = ["서울", "대전", "청주", "부산", "광주"];
  const TRAINS = [{ id: "t1", dep: "09:00", arr: "10:30" }, { id: "t2", dep: "11:00", arr: "12:30" }, { id: "t3", dep: "14:00", arr: "15:30" }];
  const ROWS = ["A", "B", "C", "D", "E"]; const COLS = [1, 2, 3, 4];
  const TAKEN = new Set(["A1", "B3", "C2", "D4", "E1"]);
  const PREV: Record<string, TrStep> = { arrive: "depart", date: "arrive", train: "date", seat: "train", confirm: "seat" };
  const backFn = () => { if (step === "depart") goBack(); else setStep(PREV[step] as TrStep || "depart"); };
  const selTrain = TRAINS.find(t => t.id === train);
  if (done) return <Done name="기차표 예매하기" pts={30} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="기차표 예매하기" onBack={backFn} />
      <div style={{ padding: "20px" }}>
        {step === "depart" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>출발역을 선택해주세요</p>
          {STATIONS.map(s => <button key={s} onClick={() => { setDep(s); setStep("arrive"); }} style={{ width: "100%", height: 64, borderRadius: 16, border: `2px solid ${dep === s ? P : BR}`, background: dep === s ? P + "10" : WH, fontSize: 17, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>🚉  {s}</button>)}
        </>}
        {step === "arrive" && <>
          <div style={{ background: P + "10", borderRadius: 12, padding: "12px 16px", marginBottom: 20 }}>
            <p style={{ fontSize: 12, color: SE }}>출발역</p>
            <p style={{ fontSize: 16, fontWeight: 700, color: P }}>🚉  {dep}</p>
          </div>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>도착역을 선택해주세요</p>
          {STATIONS.filter(s => s !== dep).map(s => <button key={s} onClick={() => { setArr(s); setStep("date"); }} style={{ width: "100%", height: 64, borderRadius: 16, border: `2px solid ${arr === s ? P : BR}`, background: arr === s ? P + "10" : WH, fontSize: 17, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>🚉  {s}</button>)}
        </>}
        {step === "date" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>날짜를 선택해주세요</p>
          {["오늘 (7/8)", "내일 (7/9)", "7월 10일", "7월 11일", "7월 12일"].map(d => <button key={d} onClick={() => { setDate(d); setStep("train"); }} style={{ width: "100%", height: 64, borderRadius: 16, border: `2px solid ${date === d ? P : BR}`, background: date === d ? P + "10" : WH, fontSize: 16, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>📅  {d}</button>)}
        </>}
        {step === "train" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 4, color: TX }}>열차를 선택해주세요</p>
          <p style={{ fontSize: 14, color: SE, marginBottom: 16 }}>{dep} → {arr}  ·  {date}</p>
          {TRAINS.map(t => (
            <button key={t.id} onClick={() => { setTrain(t.id); setStep("seat"); }} style={{ width: "100%", height: 80, borderRadius: 16, border: `2px solid ${train === t.id ? P : BR}`, background: train === t.id ? P + "10" : WH, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 20px", marginBottom: 12 }}>
              <div style={{ textAlign: "left" }}><p style={{ fontSize: 12, color: SE }}>KTX</p><p style={{ fontSize: 18, fontWeight: 700, color: TX }}>{t.dep}  →  {t.arr}</p></div>
              <span style={{ fontSize: 13, color: GR, fontWeight: 700 }}>잔여석 있음</span>
            </button>
          ))}
        </>}
        {step === "seat" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 4, color: TX }}>좌석을 선택해주세요</p>
          <p style={{ fontSize: 13, color: SE, marginBottom: 20 }}>1인 1좌석</p>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: 8, marginBottom: 16 }}>
            {ROWS.map(r => COLS.map(c => {
              const s = `${r}${c}`; const tk = TAKEN.has(s); const sel = seats.includes(s);
              return <button key={s} onClick={() => !tk && setSeats(sel ? [] : [s])} disabled={tk} style={{ height: 52, borderRadius: 10, border: "none", fontSize: 13, fontWeight: 700, cursor: tk ? "default" : "pointer", background: tk ? "#E5E7EB" : sel ? P : WH, color: tk ? "#9CA3AF" : sel ? "#fff" : TX, boxShadow: !tk && !sel ? `inset 0 0 0 1px ${BR}` : "none" }}>{s}</button>;
            }))}
          </div>
          <p style={{ fontSize: 14, color: SE, marginBottom: 12 }}>선택된 좌석: {seats[0] || "없음"}</p>
          <PBtn onClick={() => setStep("confirm")} disabled={seats.length === 0}>다음</PBtn>
        </>}
        {step === "confirm" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>예매 정보 확인</p>
          <Card style={{ marginBottom: 20 }}>
            {[["출발역", dep], ["도착역", arr], ["날짜", date], ["열차", selTrain ? `${selTrain.dep} → ${selTrain.arr}` : ""], ["좌석", seats[0] || ""], ["결제금액", "69,000원"]].map(([k, v]) => (
              <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "11px 0", borderBottom: `1px solid ${BR}` }}>
                <span style={{ color: SE, fontSize: 15 }}>{k}</span>
                <span style={{ fontWeight: 600, fontSize: 15, color: TX }}>{v}</span>
              </div>
            ))}
          </Card>
          <PBtn onClick={() => setDone(true)}>결제하기</PBtn>
        </>}
      </div>
    </div>
  );
};

// ── 13. Online Shopping ───────────────────────────────────────────────────────
type ShStep = "list" | "detail" | "cart" | "address" | "confirm";
const OnlineShoppingScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<ShStep>("list");
  const [selProd, setSelProd] = useState<{ name: string; price: number } | null>(null);
  const [qty, setQty] = useState(1);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [addr, setAddr] = useState({ name: "홍길동", phone: "010-3587-1245", addr: "충청북도 청주시 ○○구 ○○로", detail: "101동 1001호" });
  const [done, setDone] = useState(false);
  const PRODUCTS = [{ name: "물티슈", price: 5000, icon: "🧻" }, { name: "세탁세제", price: 12000, icon: "🫧" }, { name: "휴지", price: 18000, icon: "🧻" }, { name: "칫솔", price: 4000, icon: "🪥" }, { name: "샴푸", price: 9000, icon: "🧴" }];
  const addToCart = () => {
    if (!selProd) return;
    setCart(p => { const e = p.find(i => i.name === selProd.name); return e ? p.map(i => i === e ? { ...i, qty: i.qty + qty } : i) : [...p, { ...selProd, qty }]; });
    setQty(1); setStep("cart");
  };
  const rm  = (i: number) => setCart(p => p.filter((_, j) => j !== i));
  const chQ = (i: number, d: number) => setCart(p => p.map((x, j) => j === i ? { ...x, qty: Math.max(1, x.qty + d) } : x));
  const total = cart.reduce((s, i) => s + i.price * i.qty, 0);
  const PREV: Record<string, ShStep> = { detail: "list", cart: "list", address: "cart", confirm: "address" };
  const backFn = () => { if (step === "list") goBack(); else setStep(PREV[step] as ShStep || "list"); };
  if (done) return <Done name="인터넷 쇼핑하기" pts={20} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="인터넷 쇼핑하기" onBack={backFn}
        right={step === "list" && <button onClick={() => setStep("cart")} style={{ border: "none", background: "none", cursor: "pointer", position: "relative" }}>
          <ShoppingCart size={26} color={TX} />
          {cart.length > 0 && <span style={{ position: "absolute", top: -4, right: -4, width: 16, height: 16, borderRadius: 8, background: RD, color: "#fff", fontSize: 9, fontWeight: 700, display: "flex", alignItems: "center", justifyContent: "center" }}>{cart.length}</span>}
        </button>}
      />
      <div style={{ padding: "20px" }}>
        {step === "list" && <>
          <p style={{ fontSize: 16, fontWeight: 700, marginBottom: 14, color: TX }}>상품 목록</p>
          {PRODUCTS.map(p => (
            <Card key={p.name} onClick={() => { setSelProd(p); setQty(1); setStep("detail"); }} style={{ display: "flex", alignItems: "center", gap: 14, marginBottom: 10, cursor: "pointer" }}>
              <div style={{ width: 52, height: 52, borderRadius: 12, background: P + "10", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 24, flexShrink: 0 }}>{p.icon}</div>
              <div style={{ flex: 1 }}>
                <p style={{ fontSize: 16, fontWeight: 600, color: TX }}>{p.name}</p>
                <p style={{ fontSize: 15, color: P, fontWeight: 700, marginTop: 3 }}>{p.price.toLocaleString()}원</p>
              </div>
              <ChevronRight size={20} color={SE} />
            </Card>
          ))}
        </>}
        {step === "detail" && selProd && <>
          <div style={{ height: 188, background: P + "15", borderRadius: 16, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 20, fontSize: 80 }}>
            {PRODUCTS.find(p => p.name === selProd.name)?.icon}
          </div>
          <p style={{ fontSize: 22, fontWeight: 700, color: TX, marginBottom: 4 }}>{selProd.name}</p>
          <p style={{ fontSize: 21, color: P, fontWeight: 700, marginBottom: 24 }}>{selProd.price.toLocaleString()}원</p>
          <div style={{ display: "flex", alignItems: "center", gap: 16, marginBottom: 28 }}>
            <span style={{ fontSize: 16, color: TX, fontWeight: 600 }}>수량</span>
            <QCtrl n={qty} dec={() => setQty(Math.max(1, qty - 1))} inc={() => setQty(qty + 1)} />
          </div>
          <PBtn onClick={addToCart}>장바구니 담기</PBtn>
        </>}
        {step === "cart" && <>
          {cart.length === 0
            ? <p style={{ textAlign: "center", color: SE, padding: "60px 0" }}>장바구니가 비어있습니다</p>
            : <>{cart.map((item, i) => <CartRow key={i} item={item} idx={i} onQty={chQ} onRm={rm} />)}<CartTotal items={cart} /></>
          }
          <div style={{ display: "flex", gap: 12 }}>
            <PBtn onClick={() => setStep("list")} variant="outline">더 담기</PBtn>
            <PBtn onClick={() => setStep("address")} disabled={cart.length === 0}>배송지 입력</PBtn>
          </div>
        </>}
        {step === "address" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>배송지를 입력해주세요</p>
          {[["받는 사람", "name", "홍길동", "text"], ["전화번호", "phone", "010-3587-1245", "tel"], ["주소", "addr", "충청북도 청주시 ○○구 ○○로", "text"], ["상세주소", "detail", "101동 1001호", "text"]].map(([label, key, ph, type]) => (
            <div key={key} style={{ marginBottom: 14 }}>
              <p style={{ fontSize: 14, color: SE, marginBottom: 7, fontWeight: 600 }}>{label}</p>
              <TxtInput placeholder={ph} value={(addr as any)[key]} onChange={v => setAddr(a => ({ ...a, [key]: v }))} type={type} />
            </div>
          ))}
          <div style={{ marginTop: 8 }}><PBtn onClick={() => setStep("confirm")}>다음</PBtn></div>
        </>}
        {step === "confirm" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>주문 확인</p>
          <Card style={{ marginBottom: 14 }}>
            <p style={{ fontSize: 14, fontWeight: 700, color: TX, marginBottom: 10 }}>배송지</p>
            {[["받는 사람", addr.name], ["전화번호", addr.phone], ["주소", addr.addr], ["상세주소", addr.detail]].map(([k, v]) => (
              <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "7px 0", borderBottom: `1px solid ${BR}` }}>
                <span style={{ color: SE, fontSize: 14 }}>{k}</span>
                <span style={{ fontWeight: 600, fontSize: 14, color: TX, textAlign: "right", maxWidth: 200 }}>{v}</span>
              </div>
            ))}
          </Card>
          <Card style={{ marginBottom: 20 }}>
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <span style={{ fontSize: 16, fontWeight: 700, color: TX }}>결제금액</span>
              <span style={{ fontSize: 17, fontWeight: 700, color: P }}>{total.toLocaleString()}원</span>
            </div>
          </Card>
          <PBtn onClick={() => setDone(true)}>결제하기</PBtn>
        </>}
      </div>
    </div>
  );
};

// ── 14. Food Delivery ─────────────────────────────────────────────────────────
type FDStep = "store" | "menu" | "option" | "cart" | "address" | "request" | "confirm";

const STORE_MENUS: Record<string, Array<{ name: string; price: number }>> = {
  "우리분식": [{ name: "떡볶이", price: 4000 }, { name: "순대", price: 4000 }, { name: "튀김", price: 3000 }, { name: "음료수", price: 2000 }],
  "동네치킨": [{ name: "후라이드 치킨", price: 20000 }, { name: "양념치킨", price: 22000 }, { name: "치즈볼", price: 5000 }, { name: "음료", price: 2000 }],
  "행복피자": [{ name: "포테이토 피자", price: 28000 }, { name: "고구마 피자", price: 28000 }, { name: "음료", price: 2000 }],
};
const STORE_OPTS: Record<string, Array<{ label: string; options: Array<{ name: string; price: number }> }>> = {
  "우리분식": [
    { label: "맛 선택", options: [{ name: "순한맛", price: 0 }, { name: "보통맛", price: 0 }, { name: "매운맛", price: 0 }] },
    { label: "추가 선택", options: [{ name: "없음", price: 0 }, { name: "치즈 추가", price: 1000 }] },
  ],
  "동네치킨": [{ label: "뼈/순살", options: [{ name: "뼈", price: 0 }, { name: "순살", price: 0 }] }],
  "행복피자": [{ label: "사이드", options: [{ name: "없음", price: 0 }, { name: "치즈오븐스파게티", price: 8000 }] }],
};

const FoodDeliveryScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<FDStep>("store");
  const [store, setStore] = useState("");
  const [selMenu, setSelMenu] = useState<{ name: string; price: number } | null>(null);
  const [opts, setOpts] = useState<Record<string, string>>({});
  const [cart, setCart] = useState<CartItem[]>([]);
  const [addr, setAddr] = useState({ name: "홍길동", phone: "010-3587-1245", addr: "충청북도 청주시 ○○구 ○○로", detail: "101동 1001호" });
  const [reqSel, setReqSel] = useState("");
  const [done, setDone] = useState(false);

  const storeOpts = STORE_OPTS[store] || [];
  const addToCart = () => {
    if (!selMenu) return;
    const extra = storeOpts.flatMap(g => g.options).filter(o => Object.values(opts).includes(o.name)).reduce((s, o) => s + o.price, 0);
    const metaStr = Object.values(opts).join(" · ");
    setCart(p => [...p, { name: selMenu.name, price: selMenu.price + extra, qty: 1, meta: metaStr || undefined }]);
    setOpts({}); setSelMenu(null); setStep("cart");
  };
  const rm  = (i: number) => setCart(p => p.filter((_, j) => j !== i));
  const chQ = (i: number, d: number) => setCart(p => p.map((x, j) => j === i ? { ...x, qty: Math.max(1, x.qty + d) } : x));
  const total = cart.reduce((s, i) => s + i.price * i.qty, 0);
  const PREV: Record<string, FDStep> = { menu: "store", option: "menu", cart: "menu", address: "cart", request: "address", confirm: "request" };
  const backFn = () => { if (step === "store") goBack(); else setStep(PREV[step] as FDStep || "store"); };
  const STORE_ICONS: Record<string, string> = { "우리분식": "🍜", "동네치킨": "🍗", "행복피자": "🍕" };
  const REQ_OPTS = ["일회용 수저 주세요", "맵지 않게 해주세요", "문 앞에 놓아주세요", "직접 입력"];

  if (done) return <Done name="배달 음식 주문하기" pts={30} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="배달 음식 주문하기" onBack={backFn} />
      <div style={{ padding: "20px" }}>
        {step === "store" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>가게를 선택해주세요</p>
          {Object.keys(STORE_MENUS).map(s => (
            <button key={s} onClick={() => { setStore(s); setStep("menu"); }} style={{ width: "100%", height: 80, borderRadius: 16, border: `2px solid ${store === s ? P : BR}`, background: store === s ? P + "10" : WH, cursor: "pointer", display: "flex", alignItems: "center", padding: "0 22px", gap: 16, marginBottom: 12 }}>
              <span style={{ fontSize: 34 }}>{STORE_ICONS[s]}</span>
              <span style={{ fontSize: 18, fontWeight: 700, color: TX }}>{s}</span>
            </button>
          ))}
        </>}
        {step === "menu" && <>
          <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 16, alignItems: "center" }}>
            <p style={{ fontSize: 17, fontWeight: 700, color: TX }}>{store}</p>
            <button onClick={() => setStep("cart")} style={{ background: P, color: "#fff", border: "none", borderRadius: 12, padding: "8px 18px", fontSize: 15, fontWeight: 600, cursor: "pointer" }}>장바구니{cart.length > 0 ? ` (${cart.length})` : ""}</button>
          </div>
          {(STORE_MENUS[store] || []).map(m => (
            <Card key={m.name} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
              <div><p style={{ fontSize: 16, fontWeight: 600, color: TX }}>{m.name}</p><p style={{ fontSize: 14, color: P, fontWeight: 700, marginTop: 3 }}>{m.price.toLocaleString()}원</p></div>
              <button onClick={() => { setSelMenu(m); setOpts({}); setStep("option"); }} style={{ height: 44, padding: "0 18px", background: P, color: "#fff", border: "none", borderRadius: 12, fontSize: 14, fontWeight: 600, cursor: "pointer" }}>선택</button>
            </Card>
          ))}
        </>}
        {step === "option" && selMenu && <>
          <p style={{ fontSize: 18, fontWeight: 700, marginBottom: 20, color: TX }}>{selMenu.name} 옵션</p>
          {storeOpts.map(group => (
            <div key={group.label} style={{ marginBottom: 22 }}>
              <p style={{ fontSize: 15, fontWeight: 700, color: TX, marginBottom: 10 }}>{group.label}</p>
              {group.options.map(o => (
                <button key={o.name} onClick={() => setOpts(p => ({ ...p, [group.label]: o.name }))} style={{ width: "100%", height: 56, borderRadius: 12, border: `2px solid ${opts[group.label] === o.name ? P : BR}`, background: opts[group.label] === o.name ? P + "10" : WH, fontSize: 15, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 8, display: "flex", justifyContent: "space-between", alignItems: "center", padding: "0 16px" }}>
                  <span>{o.name}</span>
                  {o.price > 0 && <span style={{ color: P, fontSize: 14 }}>+{o.price.toLocaleString()}원</span>}
                </button>
              ))}
            </div>
          ))}
          <PBtn onClick={addToCart} disabled={Object.keys(opts).length < storeOpts.length}>장바구니 담기</PBtn>
        </>}
        {step === "cart" && <>
          {cart.length === 0
            ? <p style={{ textAlign: "center", color: SE, padding: "60px 0" }}>장바구니가 비어있습니다</p>
            : <>{cart.map((item, i) => <CartRow key={i} item={item} idx={i} onQty={chQ} onRm={rm} />)}<CartTotal items={cart} /></>
          }
          <div style={{ display: "flex", gap: 12 }}>
            <PBtn onClick={() => setStep("menu")} variant="outline">더 담기</PBtn>
            <PBtn onClick={() => setStep("address")} disabled={cart.length === 0}>배달 주소</PBtn>
          </div>
        </>}
        {step === "address" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>배달 주소를 입력해주세요</p>
          {[["받는 사람", "name", "홍길동", "text"], ["전화번호", "phone", "010-3587-1245", "tel"], ["주소", "addr", "충청북도 청주시 ○○구 ○○로", "text"], ["상세주소", "detail", "101동 1001호", "text"]].map(([label, key, ph, type]) => (
            <div key={key} style={{ marginBottom: 14 }}>
              <p style={{ fontSize: 14, color: SE, marginBottom: 7, fontWeight: 600 }}>{label}</p>
              <TxtInput placeholder={ph} value={(addr as any)[key]} onChange={v => setAddr(a => ({ ...a, [key]: v }))} type={type} />
            </div>
          ))}
          <div style={{ marginTop: 8 }}><PBtn onClick={() => setStep("request")}>다음</PBtn></div>
        </>}
        {step === "request" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>요청사항을 선택해주세요</p>
          {REQ_OPTS.map(r => (
            <button key={r} onClick={() => setReqSel(r === reqSel ? "" : r)} style={{ width: "100%", height: 58, borderRadius: 14, border: `2px solid ${reqSel === r ? P : BR}`, background: reqSel === r ? P + "10" : WH, fontSize: 15, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 10, textAlign: "left", padding: "0 18px" }}>{r}</button>
          ))}
          {reqSel === "직접 입력" && <div style={{ marginBottom: 14 }}><TxtInput placeholder="요청사항을 직접 입력해주세요" value="" onChange={() => {}} /></div>}
          <PBtn onClick={() => setStep("confirm")}>다음</PBtn>
        </>}
        {step === "confirm" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>주문 확인</p>
          <Card style={{ marginBottom: 14 }}>
            <p style={{ fontSize: 14, fontWeight: 700, color: TX, marginBottom: 8 }}>배달 주소</p>
            <p style={{ fontSize: 14, color: SE }}>{addr.name}  ·  {addr.phone}</p>
            <p style={{ fontSize: 14, color: SE, marginTop: 3 }}>{addr.addr}  {addr.detail}</p>
          </Card>
          {reqSel && <Card style={{ marginBottom: 14 }}><p style={{ fontSize: 14, color: SE }}>요청사항: {reqSel}</p></Card>}
          <Card style={{ marginBottom: 20 }}>
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <span style={{ fontSize: 16, fontWeight: 700, color: TX }}>결제금액</span>
              <span style={{ fontSize: 17, fontWeight: 700, color: P }}>{total.toLocaleString()}원</span>
            </div>
          </Card>
          <PBtn onClick={() => setDone(true)}>결제하기</PBtn>
        </>}
      </div>
    </div>
  );
};

// ── 15. Package Tracking ──────────────────────────────────────────────────────
type PKStep = "courier" | "number" | "result";
const PackageTrackingScreen = ({ navigate, goBack }: NavProps) => {
  const [step, setStep] = useState<PKStep>("courier");
  const [courier, setCourier] = useState(""); const [num, setNum] = useState("");
  const [done, setDone] = useState(false);
  const STAGES = ["상품 준비", "집화 완료", "이동 중", "배송 출발", "배송 완료"];
  const CUR = 3;
  const PREV: Record<string, PKStep> = { number: "courier", result: "number" };
  const backFn = () => { if (step === "courier") goBack(); else setStep(PREV[step] as PKStep || "courier"); };
  if (done) return <Done name="택배 배송 조회하기" pts={10} onHome={() => navigate("home")} onOther={() => navigate("mission_categories")} />;
  return (
    <div>
      <AppBar title="택배 배송 조회하기" onBack={backFn} />
      <div style={{ padding: "20px" }}>
        {step === "courier" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 16, color: TX }}>택배사를 선택해주세요</p>
          {["일반 택배", "우체국 택배", "편의점 택배"].map(c => <button key={c} onClick={() => { setCourier(c); setStep("number"); }} style={{ width: "100%", height: 68, borderRadius: 16, border: `2px solid ${courier === c ? P : BR}`, background: courier === c ? P + "10" : WH, fontSize: 17, fontWeight: 600, color: TX, cursor: "pointer", marginBottom: 12 }}>📦  {c}</button>)}
        </>}
        {step === "number" && <>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 8, color: TX }}>운송장 번호를 입력해주세요</p>
          <p style={{ fontSize: 14, color: SE, marginBottom: 20 }}>예시: 123456789012 (하이픈 없이)</p>
          <div style={{ marginBottom: 16 }}><TxtInput placeholder="운송장 번호 입력" value={num} onChange={setNum} type="tel" /></div>
          <PBtn onClick={() => setStep("result")} disabled={num.length < 10}>조회하기</PBtn>
        </>}
        {step === "result" && <>
          <Card style={{ marginBottom: 24 }}>
            <p style={{ fontSize: 13, color: SE, marginBottom: 3 }}>{courier}</p>
            <p style={{ fontSize: 15, fontWeight: 700, color: TX }}>{num}</p>
          </Card>
          <p style={{ fontSize: 17, fontWeight: 700, marginBottom: 20, color: TX }}>배송 상태</p>
          <div style={{ position: "relative", paddingLeft: 32 }}>
            <div style={{ position: "absolute", left: 10, top: 10, bottom: 10, width: 2, background: BR }} />
            {STAGES.map((s, i) => {
              const isCur = i === CUR; const isD = i < CUR;
              return (
                <div key={s} style={{ display: "flex", alignItems: "flex-start", gap: 16, marginBottom: 26, position: "relative" }}>
                  <div style={{ position: "absolute", left: -32, top: 0, width: 22, height: 22, borderRadius: 11, background: isCur ? P : isD ? GR : BR, display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1, flexShrink: 0 }}>
                    {isD && <Check size={12} color="#fff" />}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                      <p style={{ fontSize: 16, fontWeight: isCur ? 700 : 500, color: isCur ? P : isD ? TX : SE }}>{s}</p>
                      {isCur && <span style={{ background: P + "15", color: P, fontSize: 11, fontWeight: 700, padding: "2px 8px", borderRadius: 6 }}>현재</span>}
                    </div>
                    {isCur && <p style={{ fontSize: 13, color: SE, marginTop: 3 }}>2026.07.08  14:32</p>}
                    {isD && <p style={{ fontSize: 12, color: SE, marginTop: 2 }}>완료</p>}
                  </div>
                </div>
              );
            })}
          </div>
          <PBtn onClick={() => setDone(true)}>확인했어요</PBtn>
        </>}
      </div>
    </div>
  );
};

// ── 16. Payment ───────────────────────────────────────────────────────────────
const PaymentScreen = ({ goBack }: NavProps) => {
  const [showPopup, setShowPopup] = useState(true);
  return (
    <div>
      <AppBar title="결제" onBack={goBack} />
      <div style={{ padding: "20px", display: "flex", flexDirection: "column", gap: 20 }}>
        <Card style={{ textAlign: "center", padding: "20px 16px" }}>
          <p style={{ fontSize: 15, fontWeight: 600, color: SE, marginBottom: 6 }}>현재 보유 포인트</p>
          <p style={{ fontSize: 30, fontWeight: 800, color: P }}>10,000P</p>
        </Card>
        <Card style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 20, padding: "28px 20px" }}>
          {/* QR code simulation */}
          <div style={{ width: 168, height: 168, background: "#111827", borderRadius: 14, display: "flex", alignItems: "center", justifyContent: "center", padding: 14 }}>
            <div style={{ width: "100%", height: "100%", backgroundImage: "linear-gradient(45deg,#fff 25%,transparent 25%),linear-gradient(-45deg,#fff 25%,transparent 25%),linear-gradient(45deg,transparent 75%,#fff 75%),linear-gradient(-45deg,transparent 75%,#fff 75%)", backgroundSize: "12px 12px", backgroundPosition: "0 0,0 6px,6px -6px,-6px 0", borderRadius: 4 }} />
          </div>
          {/* Barcode simulation */}
          <div style={{ width: "100%", height: 60, background: "#111827", borderRadius: 10, display: "flex", alignItems: "center", overflow: "hidden", padding: "0 8px" }}>
            {Array.from({ length: 42 }).map((_, i) => <div key={i} style={{ flex: i % 3 === 0 ? 2 : 1, height: "80%", background: "#fff", marginRight: i % 5 === 0 ? 4 : 2, borderRadius: 1 }} />)}
          </div>
          <p style={{ fontSize: 15, fontWeight: 600, color: SE }}>점원에게 보여주세요</p>
        </Card>
      </div>
      {showPopup && (
        <Overlay title="현장 결제 안내">
          <p style={{ textAlign: "center", color: SE, fontSize: 15, marginBottom: 24 }}>점원에게 이 화면을 보여주세요.</p>
          <button onClick={() => setShowPopup(false)} style={{ width: "100%", height: 56, borderRadius: 14, border: "none", background: P, color: "#fff", fontSize: 17, fontWeight: 700, cursor: "pointer" }}>확인</button>
        </Overlay>
      )}
    </div>
  );
};

// ── 17. Map ───────────────────────────────────────────────────────────────────
const MapScreen = ({ goBack }: NavProps) => {
  const [search, setSearch] = useState("");
  const STORES = [
    { name: "행복카페", type: "카페", addr: "충청북도 청주시 ○○구 ○○로 12", hours: "09:00 ~ 21:00", pin: { l: "28%", t: "42%" } },
    { name: "우리분식", type: "음식점", addr: "충청북도 청주시 ○○구 ○○로 25", hours: "10:00 ~ 20:00", pin: { l: "56%", t: "56%" } },
    { name: "동네마트", type: "마트", addr: "충청북도 청주시 ○○구 ○○로 40", hours: "09:00 ~ 22:00", pin: { l: "72%", t: "30%" } },
  ];
  const filtered = STORES.filter(s => !search || s.name.includes(search) || s.type.includes(search));
  return (
    <div>
      <AppBar title="지도" onBack={goBack} />
      <div style={{ padding: "20px" }}>
        <p style={{ fontSize: 14, color: SE, marginBottom: 12, fontWeight: 600 }}>포인트 사용 가능 매장</p>
        <div style={{ position: "relative", marginBottom: 16 }}>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="매장명을 검색해보세요"
            style={{ width: "100%", height: 52, borderRadius: 14, border: `1px solid ${BR}`, padding: "0 44px 0 16px", fontSize: 15, color: TX, background: WH, outline: "none", boxSizing: "border-box" }} />
          <Search size={20} color={SE} style={{ position: "absolute", right: 14, top: 16 }} />
        </div>
        {/* Map placeholder */}
        <div style={{ height: 200, borderRadius: 16, border: `1px solid ${BR}`, background: "#E8F0E8", position: "relative", overflow: "hidden", marginBottom: 20 }}>
          <div style={{ position: "absolute", inset: 0, backgroundImage: "linear-gradient(#D1E8D1 1px,transparent 1px),linear-gradient(90deg,#D1E8D1 1px,transparent 1px)", backgroundSize: "28px 28px" }} />
          {/* Roads */}
          <div style={{ position: "absolute", top: "50%", left: 0, right: 0, height: 3, background: "#C8D8C8" }} />
          <div style={{ position: "absolute", left: "40%", top: 0, bottom: 0, width: 3, background: "#C8D8C8" }} />
          {STORES.map(s => (
            <div key={s.name} style={{ position: "absolute", left: s.pin.l, top: s.pin.t, transform: "translate(-50%,-100%)" }}>
              <div style={{ background: P, color: "#fff", borderRadius: 20, padding: "4px 10px", fontSize: 11, fontWeight: 700, whiteSpace: "nowrap", boxShadow: "0 2px 8px rgba(74,144,226,.4)" }}>{s.name}</div>
              <div style={{ width: 8, height: 8, background: P, borderRadius: "50%", margin: "2px auto 0", boxShadow: "0 1px 4px rgba(0,0,0,.2)" }} />
            </div>
          ))}
        </div>
        <p style={{ fontSize: 16, fontWeight: 700, color: TX, marginBottom: 12 }}>사용 가능처 목록</p>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {filtered.map(s => (
            <Card key={s.name}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                <div style={{ flex: 1 }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 5 }}>
                    <p style={{ fontSize: 16, fontWeight: 700, color: TX }}>{s.name}</p>
                    <span style={{ background: P + "15", color: P, fontSize: 11, fontWeight: 600, padding: "2px 8px", borderRadius: 6 }}>{s.type}</span>
                  </div>
                  <p style={{ fontSize: 13, color: SE, marginBottom: 2 }}>📍 {s.addr}</p>
                  <p style={{ fontSize: 13, color: SE }}>🕐 {s.hours}</p>
                </div>
                <span style={{ background: "#DCFCE7", color: GR, fontSize: 11, fontWeight: 700, padding: "3px 9px", borderRadius: 8, whiteSpace: "nowrap", marginLeft: 8 }}>포인트 사용</span>
              </div>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
};

// ── 18. My Info ───────────────────────────────────────────────────────────────
const MyInfoScreen = ({ navigate, goBack }: NavProps) => (
  <div>
    <AppBar title="마이페이지" onBack={goBack} />
    <div style={{ padding: "20px" }}>
      <Card style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 12, padding: 28, marginBottom: 20 }}>
        <div style={{ width: 76, height: 76, borderRadius: 38, background: P + "20", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <User size={38} color={P} />
        </div>
        <p style={{ fontSize: 22, fontWeight: 700, color: TX }}>홍길동</p>
        <p style={{ fontSize: 15, color: SE }}>010-3587-1245</p>
        <p style={{ fontSize: 14, color: SE }}>1959.03.15</p>
        <div style={{ background: P + "12", borderRadius: 14, padding: "9px 24px", marginTop: 4 }}>
          <p style={{ fontSize: 16, fontWeight: 700, color: P }}>현재 보유 포인트: 10,000P</p>
        </div>
      </Card>
      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        {[{ label: "포인트 내역", icon: "⭐", s: "point_history" }, { label: "미션 수행 내역", icon: "📋", s: "mission_history" }].map(m => (
          <Card key={m.label} onClick={() => navigate(m.s)} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "18px 16px", cursor: "pointer" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
              <span style={{ fontSize: 24 }}>{m.icon}</span>
              <p style={{ fontSize: 17, fontWeight: 600, color: TX }}>{m.label}</p>
            </div>
            <ChevronRight size={22} color={SE} />
          </Card>
        ))}
        <button onClick={() => navigate("login")} style={{ height: 64, borderRadius: 16, border: `1px solid ${BR}`, background: WH, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 12, fontSize: 17, fontWeight: 600, color: RD, width: "100%" }}>
          <LogOut size={22} color={RD} /> 로그아웃
        </button>
      </div>
    </div>
  </div>
);

// ── 19. Point History ─────────────────────────────────────────────────────────
const PointHistoryScreen = ({ goBack }: NavProps) => {
  const [tab, setTab] = useState<"earn" | "use">("earn");
  const EARNS = [{ pts: "+10P", date: "2026.07.08", label: "출석 체크" }, { pts: "+20P", date: "2026.07.07", label: "미션 완료" }, { pts: "+10P", date: "2026.07.06", label: "출석 체크" }, { pts: "+30P", date: "2026.07.05", label: "미션 완료" }];
  const USES = [{ place: "행복카페", pts: "-3,000P", date: "2026.07.08" }, { place: "우리분식", pts: "-5,000P", date: "2026.07.06" }, { place: "동네마트", pts: "-2,000P", date: "2026.07.04" }];
  return (
    <div>
      <AppBar title="포인트 내역" onBack={goBack} />
      <div style={{ padding: "0 20px 20px" }}>
        <div style={{ display: "flex", background: BR, borderRadius: 12, padding: 4, margin: "20px 0" }}>
          {(["earn", "use"] as const).map(t => (
            <button key={t} onClick={() => setTab(t)} style={{ flex: 1, height: 44, borderRadius: 8, border: "none", cursor: "pointer", background: tab === t ? WH : "transparent", color: tab === t ? P : SE, fontWeight: tab === t ? 700 : 500, fontSize: 15 }}>
              {t === "earn" ? "적립 내역" : "결제 내역"}
            </button>
          ))}
        </div>
        {tab === "earn"
          ? EARNS.map((e, i) => (
            <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "16px 0", borderBottom: `1px solid ${BR}` }}>
              <div>
                <p style={{ fontSize: 16, fontWeight: 700, color: GR }}>{e.pts}</p>
                <p style={{ fontSize: 13, color: SE, marginTop: 3 }}>{e.label}</p>
              </div>
              <span style={{ fontSize: 14, color: SE }}>{e.date}</span>
            </div>
          ))
          : USES.map((u, i) => (
            <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "16px 0", borderBottom: `1px solid ${BR}` }}>
              <div>
                <p style={{ fontSize: 15, fontWeight: 600, color: TX }}>{u.place}</p>
                <p style={{ fontSize: 13, color: SE, marginTop: 3 }}>{u.date}</p>
              </div>
              <span style={{ fontSize: 16, fontWeight: 700, color: RD }}>{u.pts}</span>
            </div>
          ))
        }
      </div>
    </div>
  );
};

// ── 20. Mission History ───────────────────────────────────────────────────────
const MissionHistoryScreen = ({ goBack }: NavProps) => {
  const MISSIONS = [
    { name: "카페 키오스크", errors: 0 }, { name: "병원 예약하기", errors: 0 }, { name: "택배 배송 조회하기", errors: 0 },
    { name: "음식점 키오스크", errors: 2 }, { name: "영화표 예매하기", errors: 1 }, { name: "기차표 예매하기", errors: 3 },
  ];
  return (
    <div>
      <AppBar title="미션 수행 내역" onBack={goBack} />
      <div style={{ padding: "20px", display: "flex", flexDirection: "column", gap: 10 }}>
        {MISSIONS.map(m => (
          <div key={m.name} style={{ background: m.errors > 0 ? "#FEF2F2" : WH, borderRadius: 14, border: `1px solid ${m.errors > 0 ? "#FECACA" : BR}`, padding: "16px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <p style={{ fontSize: 16, fontWeight: 600, color: TX }}>{m.name}</p>
            {m.errors > 0
              ? <span style={{ fontSize: 14, fontWeight: 700, color: RD, background: "#FEE2E2", padding: "4px 12px", borderRadius: 8 }}>오답 {m.errors}회</span>
              : <span style={{ fontSize: 14, fontWeight: 700, color: GR, background: "#DCFCE7", padding: "4px 12px", borderRadius: 8 }}>완료</span>
            }
          </div>
        ))}
      </div>
    </div>
  );
};

// ── 21. Customer Center ───────────────────────────────────────────────────────
const CustomerCenterScreen = ({ goBack }: NavProps) => {
  const [type, setType] = useState(""); const [title, setTitle] = useState(""); const [content, setContent] = useState("");
  const [submitted, setSubmitted] = useState(false);
  return (
    <div>
      <AppBar title="고객센터" onBack={goBack} />
      <div style={{ padding: "20px" }}>
        {submitted ? (
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 20, paddingTop: 64 }}>
            <div style={{ width: 76, height: 76, borderRadius: 38, background: "#DCFCE7", display: "flex", alignItems: "center", justifyContent: "center" }}><Check size={38} color={GR} /></div>
            <p style={{ fontSize: 20, fontWeight: 700, color: TX }}>문의가 등록되었습니다.</p>
            <p style={{ fontSize: 15, color: SE, textAlign: "center" }}>빠른 시일 내에 답변 드리겠습니다.</p>
          </div>
        ) : <>
          <p style={{ fontSize: 16, fontWeight: 700, marginBottom: 12, color: TX }}>문의 유형</p>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 24 }}>
            {["일반 문의", "서비스 이용 문의", "버그 신고"].map(t => (
              <button key={t} onClick={() => setType(t)} style={{ height: 44, padding: "0 16px", borderRadius: 12, border: `2px solid ${type === t ? P : BR}`, background: type === t ? P + "10" : WH, fontSize: 14, fontWeight: 600, color: type === t ? P : TX, cursor: "pointer" }}>{t}</button>
            ))}
          </div>
          <div style={{ marginBottom: 16 }}>
            <p style={{ fontSize: 14, color: SE, marginBottom: 7, fontWeight: 600 }}>제목</p>
            <TxtInput placeholder="제목을 입력해주세요" value={title} onChange={setTitle} />
          </div>
          <div style={{ marginBottom: 20 }}>
            <p style={{ fontSize: 14, color: SE, marginBottom: 7, fontWeight: 600 }}>내용</p>
            <textarea value={content} onChange={e => setContent(e.target.value)} placeholder="문의 내용을 입력해주세요"
              style={{ width: "100%", height: 160, borderRadius: 12, border: `1px solid ${BR}`, padding: 16, fontSize: 15, color: TX, background: WH, outline: "none", resize: "none", boxSizing: "border-box", fontFamily: "inherit" }} />
          </div>
          <PBtn onClick={() => setSubmitted(true)} disabled={!type || !title || !content}>문의 등록</PBtn>
        </>}
      </div>
    </div>
  );
};

// ── 22. Settings ──────────────────────────────────────────────────────────────
const SettingsScreen = ({ goBack }: NavProps) => {
  const [fontSize, setFontSize] = useState<"작게" | "보통" | "크게">("보통");
  const [notif, setNotif] = useState(true);
  const [showWithdraw, setShowWithdraw] = useState(false);
  return (
    <div>
      <AppBar title="설정" onBack={goBack} />
      <div style={{ padding: "20px", display: "flex", flexDirection: "column", gap: 14 }}>
        <Card>
          <p style={{ fontSize: 16, fontWeight: 700, color: TX, marginBottom: 14 }}>글씨 크기</p>
          <div style={{ display: "flex", gap: 8 }}>
            {(["작게", "보통", "크게"] as const).map(s => (
              <button key={s} onClick={() => setFontSize(s)} style={{ flex: 1, height: 50, borderRadius: 12, border: `2px solid ${fontSize === s ? P : BR}`, background: fontSize === s ? P + "10" : WH, fontSize: s === "작게" ? 13 : s === "보통" ? 16 : 20, fontWeight: 700, color: fontSize === s ? P : TX, cursor: "pointer" }}>{s}</button>
            ))}
          </div>
        </Card>
        <Card style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <p style={{ fontSize: 16, fontWeight: 700, color: TX }}>알림 설정</p>
            <p style={{ fontSize: 13, color: SE, marginTop: 3 }}>{notif ? "알림 켜짐" : "알림 꺼짐"}</p>
          </div>
          <button onClick={() => setNotif(!notif)} style={{ width: 54, height: 30, borderRadius: 15, border: "none", background: notif ? P : BR, cursor: "pointer", position: "relative", transition: "background .2s", flexShrink: 0 }}>
            <div style={{ position: "absolute", top: 3, left: notif ? 28 : 3, width: 24, height: 24, borderRadius: 12, background: WH, transition: "left .2s", boxShadow: "0 1px 4px rgba(0,0,0,.2)" }} />
          </button>
        </Card>
        <Card>
          <p style={{ fontSize: 16, fontWeight: 700, color: TX, marginBottom: 14 }}>개인정보</p>
          {[["이름", "홍길동"], ["생년월일", "1959.03.15"], ["전화번호", "010-3587-1245"], ["아이디", "hong01"]].map(([k, v]) => (
            <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "11px 0", borderBottom: `1px solid ${BR}` }}>
              <span style={{ color: SE, fontSize: 15 }}>{k}</span>
              <span style={{ fontWeight: 600, fontSize: 15, color: TX }}>{v}</span>
            </div>
          ))}
        </Card>
        <button onClick={() => setShowWithdraw(true)} style={{ height: 60, borderRadius: 16, border: `1px solid #FECACA`, background: "#FEF2F2", color: RD, fontSize: 16, fontWeight: 600, cursor: "pointer" }}>회원 탈퇴</button>
      </div>
      {showWithdraw && (
        <Overlay title="정말 회원 탈퇴하시겠습니까?">
          <p style={{ textAlign: "center", color: SE, fontSize: 14, marginBottom: 24 }}>탈퇴 후에는 계정을 복구할 수 없습니다.</p>
          <div style={{ display: "flex", gap: 10 }}>
            <button onClick={() => setShowWithdraw(false)} style={{ flex: 1, height: 52, borderRadius: 12, border: `1px solid ${BR}`, background: WH, color: TX, fontSize: 16, fontWeight: 600, cursor: "pointer" }}>취소</button>
            <button onClick={() => setShowWithdraw(false)} style={{ flex: 1, height: 52, borderRadius: 12, border: "none", background: RD, color: "#fff", fontSize: 16, fontWeight: 700, cursor: "pointer" }}>탈퇴</button>
          </div>
        </Overlay>
      )}
    </div>
  );
};

// ── 23. Admin Home ────────────────────────────────────────────────────────────
const AdminHomeScreen = ({ navigate }: NavProps) => (
  <div style={{ minHeight: 808, background: BG }}>
    <div style={{ background: WH, padding: "18px 20px", display: "flex", alignItems: "center", justifyContent: "space-between", borderBottom: `1px solid ${BR}` }}>
      <span style={{ fontSize: 20, fontWeight: 800, color: P }}>관리자 페이지</span>
    </div>
    <div style={{ padding: "24px 20px", display: "flex", flexDirection: "column", gap: 12 }}>
      {[
        { label: "회원가입 신청 관리", icon: "📋", s: "admin_signup", badge: "5" },
        { label: "회원 관리", icon: "👥", s: "admin_members", badge: "" },
        { label: "문의 관리", icon: "💬", s: "admin_inquiry", badge: "1" },
      ].map(m => (
        <Card key={m.label} onClick={() => navigate(m.s)} style={{ display: "flex", alignItems: "center", gap: 16, padding: 20, cursor: "pointer" }}>
          <div style={{ width: 56, height: 56, borderRadius: 14, background: P + "15", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 26, flexShrink: 0 }}>{m.icon}</div>
          <p style={{ flex: 1, fontSize: 18, fontWeight: 700, color: TX }}>{m.label}</p>
          {m.badge && <span style={{ background: RD, color: "#fff", fontSize: 13, fontWeight: 700, padding: "3px 11px", borderRadius: 10 }}>{m.badge}</span>}
          <ChevronRight size={22} color={SE} />
        </Card>
      ))}
      <button onClick={() => navigate("login")} style={{ height: 64, borderRadius: 16, border: `1px solid ${BR}`, background: WH, color: RD, fontSize: 16, fontWeight: 600, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 10, marginTop: 8 }}>
        <LogOut size={22} color={RD} /> 로그아웃
      </button>
    </div>
  </div>
);

// ── 24. Admin Signup Management ───────────────────────────────────────────────
const APPLICANTS = [
  { name: "홍길동", age: 67, date: "2026.07.08", phone: "010-3587-1245", id: "hong01", dob: "1959.03.15" },
  { name: "김영희", age: 71, date: "2026.07.07", phone: "010-4821-9305", id: "kim01", dob: "1955.06.22" },
  { name: "이철수", age: 64, date: "2026.07.07", phone: "010-2294-8810", id: "lee01", dob: "1962.11.05" },
  { name: "박순자", age: 76, date: "2026.07.06", phone: "010-5512-3309", id: "park01", dob: "1950.02.14" },
  { name: "최영수", age: 69, date: "2026.07.06", phone: "010-7823-4401", id: "choi01", dob: "1957.09.30" },
];

const AdminSignupScreen = ({ navigate, goBack }: NavProps) => (
  <div>
    <AppBar title="회원가입 신청 관리" onBack={goBack} />
    <div style={{ padding: "20px", display: "flex", flexDirection: "column", gap: 10 }}>
      {APPLICANTS.map(m => (
        <Card key={m.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
              <p style={{ fontSize: 16, fontWeight: 700, color: TX }}>{m.name}</p>
              <span style={{ fontSize: 14, color: SE }}>{m.age}세</span>
            </div>
            <p style={{ fontSize: 13, color: SE, marginBottom: 5 }}>{m.date} 신청</p>
            <span style={{ background: "#FEF3C7", color: "#92400E", fontSize: 11, fontWeight: 700, padding: "3px 9px", borderRadius: 6 }}>심사대기</span>
          </div>
          <button onClick={() => navigate("admin_signup_detail", m)} style={{ height: 44, padding: "0 16px", background: P, color: "#fff", border: "none", borderRadius: 12, fontSize: 14, fontWeight: 600, cursor: "pointer" }}>상세보기</button>
        </Card>
      ))}
    </div>
  </div>
);

const AdminSignupDetailScreen = ({ goBack, params }: NavProps) => {
  const m = params as typeof APPLICANTS[0] || APPLICANTS[0];
  const [status, setStatus] = useState<"pending" | "approved" | "rejected">("pending");
  return (
    <div>
      <AppBar title="신청 상세" onBack={goBack} />
      <div style={{ padding: "20px" }}>
        <Card style={{ marginBottom: 20 }}>
          {[["이름", m.name], ["나이", `${m.age}세`], ["생년월일", m.dob], ["전화번호", m.phone], ["아이디", m.id], ["신청일", m.date], ["상태", status === "pending" ? "심사대기" : status === "approved" ? "승인" : "거절"]].map(([k, v]) => (
            <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "12px 0", borderBottom: `1px solid ${BR}` }}>
              <span style={{ color: SE, fontSize: 15 }}>{k}</span>
              <span style={{ fontWeight: 700, fontSize: 15, color: k === "상태" ? (status === "approved" ? GR : status === "rejected" ? RD : YL) : TX }}>{v as string}</span>
            </div>
          ))}
        </Card>
        {status === "pending" ? (
          <div style={{ display: "flex", gap: 12 }}>
            <button onClick={() => setStatus("rejected")} style={{ flex: 1, height: 64, borderRadius: 16, border: `1px solid #FECACA`, background: "#FEF2F2", color: RD, fontSize: 17, fontWeight: 700, cursor: "pointer" }}>거절</button>
            <button onClick={() => setStatus("approved")} style={{ flex: 1, height: 64, borderRadius: 16, border: "none", background: P, color: "#fff", fontSize: 17, fontWeight: 700, cursor: "pointer" }}>승인</button>
          </div>
        ) : (
          <div style={{ background: status === "approved" ? "#DCFCE7" : "#FEF2F2", borderRadius: 14, padding: 20, textAlign: "center" }}>
            <p style={{ fontSize: 18, fontWeight: 700, color: status === "approved" ? GR : RD }}>{status === "approved" ? "✅  승인 완료" : "❌  거절 완료"}</p>
          </div>
        )}
      </div>
    </div>
  );
};

// ── 25. Admin Member Management ───────────────────────────────────────────────
const AdminMembersScreen = ({ goBack }: NavProps) => (
  <div>
    <AppBar title="회원 관리" onBack={goBack} />
    <div style={{ padding: "20px", display: "flex", flexDirection: "column", gap: 10 }}>
      {[{ name: "홍길동", age: 67, phone: "010-3587-1245", pts: "10,000P" }, { name: "김영희", age: 71, phone: "010-4821-9305", pts: "8,000P" }, { name: "이철수", age: 64, phone: "010-2294-8810", pts: "12,000P" }].map(m => (
        <Card key={m.name}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <div>
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
                <p style={{ fontSize: 16, fontWeight: 700, color: TX }}>{m.name}</p>
                <span style={{ fontSize: 14, color: SE }}>{m.age}세</span>
              </div>
              <p style={{ fontSize: 13, color: SE }}>{m.phone}</p>
            </div>
            <div style={{ textAlign: "right" }}>
              <p style={{ fontSize: 16, fontWeight: 700, color: P, marginBottom: 4 }}>{m.pts}</p>
              <span style={{ background: "#DCFCE7", color: GR, fontSize: 11, fontWeight: 700, padding: "2px 9px", borderRadius: 6 }}>승인</span>
            </div>
          </div>
        </Card>
      ))}
    </div>
  </div>
);

// ── 26. Admin Inquiry Management ──────────────────────────────────────────────
const INQUIRIES = [
  { id: 1, type: "서비스 이용 문의", author: "홍길동", title: "포인트가 적립되지 않습니다.", status: "답변 대기", content: "출석 체크를 했는데 포인트가 적립되지 않았습니다. 확인 부탁드립니다.", answer: "" },
  { id: 2, type: "버그 신고", author: "김영희", title: "영화표 예매 화면이 넘어가지 않습니다.", status: "답변 완료", content: "영화표 예매를 하려고 했는데 좌석 선택 후 다음 버튼이 눌리지 않습니다.", answer: "안녕하세요. 불편을 드려 죄송합니다. 해당 버그를 확인하여 수정하였습니다. 감사합니다." },
];

const AdminInquiryScreen = ({ navigate, goBack }: NavProps) => (
  <div>
    <AppBar title="문의 관리" onBack={goBack} />
    <div style={{ padding: "20px", display: "flex", flexDirection: "column", gap: 10 }}>
      {INQUIRIES.map(q => (
        <Card key={q.id} onClick={() => navigate("admin_inquiry_detail", { ...q })} style={{ cursor: "pointer" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
            <div style={{ flex: 1 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 7 }}>
                <span style={{ background: P + "15", color: P, fontSize: 11, fontWeight: 600, padding: "2px 8px", borderRadius: 6 }}>{q.type}</span>
                <span style={{ background: q.status === "답변 완료" ? "#DCFCE7" : "#FEF3C7", color: q.status === "답변 완료" ? GR : "#92400E", fontSize: 11, fontWeight: 700, padding: "2px 8px", borderRadius: 6 }}>{q.status}</span>
              </div>
              <p style={{ fontSize: 16, fontWeight: 600, color: TX, marginBottom: 4 }}>{q.title}</p>
              <p style={{ fontSize: 13, color: SE }}>작성자: {q.author}</p>
            </div>
            <ChevronRight size={20} color={SE} />
          </div>
        </Card>
      ))}
    </div>
  </div>
);

const AdminInquiryDetailScreen = ({ goBack, params }: NavProps) => {
  const q = (params || INQUIRIES[0]) as typeof INQUIRIES[0];
  const [answer, setAnswer] = useState(q.answer || "");
  const [saved, setSaved] = useState(!!q.answer);
  return (
    <div>
      <AppBar title="문의 상세" onBack={goBack} />
      <div style={{ padding: "20px" }}>
        <Card style={{ marginBottom: 20 }}>
          <div style={{ display: "flex", gap: 6, marginBottom: 14 }}>
            <span style={{ background: P + "15", color: P, fontSize: 12, fontWeight: 600, padding: "3px 10px", borderRadius: 6 }}>{q.type}</span>
          </div>
          {[["작성자", q.author], ["제목", q.title]].map(([k, v]) => (
            <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "9px 0", borderBottom: `1px solid ${BR}` }}>
              <span style={{ color: SE, fontSize: 15 }}>{k}</span>
              <span style={{ fontWeight: 600, fontSize: 15, color: TX }}>{v}</span>
            </div>
          ))}
          <div style={{ marginTop: 14 }}>
            <p style={{ fontSize: 14, color: SE, marginBottom: 7 }}>내용</p>
            <p style={{ fontSize: 15, color: TX, lineHeight: 1.65 }}>{q.content}</p>
          </div>
        </Card>
        <Card>
          <p style={{ fontSize: 16, fontWeight: 700, color: TX, marginBottom: 14 }}>답변</p>
          {saved && answer ? (
            <>
              <div style={{ background: BG, borderRadius: 10, padding: 14, marginBottom: 14 }}>
                <p style={{ fontSize: 14, color: TX, lineHeight: 1.65 }}>{answer}</p>
              </div>
              <button onClick={() => setSaved(false)} style={{ width: "100%", height: 52, borderRadius: 12, border: `1px solid ${BR}`, background: WH, color: P, fontSize: 15, fontWeight: 600, cursor: "pointer" }}>답변 수정</button>
            </>
          ) : (
            <>
              <textarea value={answer} onChange={e => setAnswer(e.target.value)} placeholder="답변을 입력해주세요"
                style={{ width: "100%", height: 120, borderRadius: 12, border: `1px solid ${BR}`, padding: 14, fontSize: 14, color: TX, background: WH, outline: "none", resize: "none", boxSizing: "border-box", fontFamily: "inherit", marginBottom: 12 }} />
              <button onClick={() => setSaved(true)} disabled={!answer.trim()} style={{ width: "100%", height: 56, borderRadius: 14, border: "none", background: answer.trim() ? P : BR, color: answer.trim() ? "#fff" : SE, fontSize: 16, fontWeight: 700, cursor: answer.trim() ? "pointer" : "not-allowed" }}>답변 등록</button>
            </>
          )}
        </Card>
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT APP — navigation stack
// ═══════════════════════════════════════════════════════════════════════════════
export default function App() {
  const [stack, setStack] = useState<Array<{ screen: string; params?: Record<string, any> }>>([{ screen: "login" }]);
  const cur = stack[stack.length - 1];
  const navigate = (screen: string, params?: Record<string, any>) => setStack(p => [...p, { screen, params }]);
  const goBack   = () => setStack(p => p.length > 1 ? p.slice(0, -1) : [{ screen: "login" }]);
  const props: NavProps = { navigate, goBack, params: cur.params };

  const Screen = () => {
    switch (cur.screen) {
      case "login":                return <LoginScreen navigate={navigate} />;
      case "signup":               return <SignupScreen {...props} />;
      case "signup_complete":      return <SignupCompleteScreen navigate={navigate} />;
      case "home":                 return <HomeScreen navigate={navigate} />;
      case "mission_categories":   return <MissionCategoriesScreen {...props} />;
      case "mission_list":         return <MissionListScreen {...props} />;
      case "cafe_kiosk":           return <CafeKioskScreen {...props} />;
      case "restaurant_kiosk":     return <RestKioskScreen {...props} />;
      case "self_checkout":        return <SelfCheckoutScreen {...props} />;
      case "hospital":             return <HospitalScreen {...props} />;
      case "movie_ticket":         return <MovieTicketScreen {...props} />;
      case "train_ticket":         return <TrainTicketScreen {...props} />;
      case "package_tracking":     return <PackageTrackingScreen {...props} />;
      case "online_shopping":      return <OnlineShoppingScreen {...props} />;
      case "food_delivery":        return <FoodDeliveryScreen {...props} />;
      case "payment":              return <PaymentScreen {...props} />;
      case "map":                  return <MapScreen {...props} />;
      case "my_info":              return <MyInfoScreen {...props} />;
      case "point_history":        return <PointHistoryScreen {...props} />;
      case "mission_history":      return <MissionHistoryScreen {...props} />;
      case "customer_center":      return <CustomerCenterScreen {...props} />;
      case "settings":             return <SettingsScreen {...props} />;
      case "admin_home":           return <AdminHomeScreen {...props} />;
      case "admin_signup":         return <AdminSignupScreen {...props} />;
      case "admin_signup_detail":  return <AdminSignupDetailScreen {...props} />;
      case "admin_members":        return <AdminMembersScreen {...props} />;
      case "admin_inquiry":        return <AdminInquiryScreen {...props} />;
      case "admin_inquiry_detail": return <AdminInquiryDetailScreen {...props} />;
      default:                     return <LoginScreen navigate={navigate} />;
    }
  };

  return (
    <div style={{
      minHeight: "100vh", background: "#94A3B8",
      display: "flex", alignItems: "flex-start", justifyContent: "center",
      padding: "24px 16px",
      fontFamily: "'Noto Sans KR', -apple-system, 'Apple SD Gothic Neo', sans-serif",
    }}>
      {/* iPhone shell */}
      <div style={{
        width: 393, background: BG, borderRadius: 48,
        overflow: "hidden",
        boxShadow: "0 0 0 1px rgba(0,0,0,.12), 0 32px 80px rgba(0,0,0,.36), inset 0 0 0 2px rgba(255,255,255,.08)",
      }}>
        {/* Status bar */}
        <div style={{ background: WH, height: 44, display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 28px", borderBottom: `1px solid ${BR}` }}>
          <span style={{ fontSize: 14, fontWeight: 700, color: TX }}>9:41</span>
          <div style={{ display: "flex", gap: 5, alignItems: "center", fontSize: 12 }}>
            <span>●●●</span>
            <span style={{ fontSize: 10 }}>▲▲</span>
            <span style={{ fontSize: 14 }}>🔋</span>
          </div>
        </div>

        {/* Screen content */}
        <div style={{ height: 808, overflowY: "auto", overflowX: "hidden", background: BG }}>
          <Screen />
        </div>

        {/* Home indicator */}
        <div style={{ background: WH, height: 22, display: "flex", alignItems: "center", justifyContent: "center", borderTop: `1px solid ${BR}` }}>
          <div style={{ width: 120, height: 5, borderRadius: 3, background: "#D1D5DB" }} />
        </div>
      </div>
    </div>
  );
}
