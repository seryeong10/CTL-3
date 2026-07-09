import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';

// --- Admin Home Screen ---
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: const [
                  Text('관리자 페이지', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ...[
                      {'label': '회원가입 신청 관리', 'icon': '📋', 'route': '/admin_signup', 'badge': '5'},
                      {'label': '회원 관리', 'icon': '👥', 'route': '/admin_members', 'badge': ''},
                      {'label': '문의 관리', 'icon': '💬', 'route': '/admin_inquiry', 'badge': '1'},
                    ].map((m) => CustomCard(
                      onTap: () => Navigator.pushNamed(context, m['route']!),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: Text(m['icon']!, style: const TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(m['label']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                          ),
                          if (m['badge']!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
                              child: Text(m['badge']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, color: AppColors.danger),
                            SizedBox(width: 10),
                            Text('로그아웃', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Admin Signup Screen ---
const applicants = [
  {'name': '홍길동', 'age': 67, 'date': '2026.07.08', 'phone': '010-3587-1245', 'id': 'hong01', 'dob': '1959.03.15'},
  {'name': '김영희', 'age': 71, 'date': '2026.07.07', 'phone': '010-4821-9305', 'id': 'kim01', 'dob': '1955.06.22'},
  {'name': '이철수', 'age': 64, 'date': '2026.07.07', 'phone': '010-2294-8810', 'id': 'lee01', 'dob': '1962.11.05'},
];

class AdminSignupScreen extends StatelessWidget {
  const AdminSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '회원가입 신청 관리', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: applicants.map((m) => CustomCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(m['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                        const SizedBox(width: 8),
                        Text('${m['age']}세', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${m['date']} 신청', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                      child: const Text('심사대기', style: TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/admin_signup_detail', arguments: m),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('상세보기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class AdminSignupDetailScreen extends StatefulWidget {
  const AdminSignupDetailScreen({super.key});

  @override
  State<AdminSignupDetailScreen> createState() => _AdminSignupDetailScreenState();
}

class _AdminSignupDetailScreenState extends State<AdminSignupDetailScreen> {
  String status = 'pending';

  @override
  Widget build(BuildContext context) {
    final m = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? applicants.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '신청 상세', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomCard(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  ['이름', m['name']],
                  ['나이', '${m['age']}세'],
                  ['생년월일', m['dob']],
                  ['전화번호', m['phone']],
                  ['아이디', m['id']],
                  ['신청일', m['date']],
                  ['상태', status == 'pending' ? '심사대기' : status == 'approved' ? '승인' : '거절'],
                ].map((r) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r[0] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      Text(
                        r[1] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: r[0] == '상태' ? (status == 'approved' ? AppColors.success : status == 'rejected' ? AppColors.danger : const Color(0xFFF59E0B)) : AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => status = 'rejected'),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECACA))),
                        alignment: Alignment.center,
                        child: const Text('거절', style: TextStyle(color: AppColors.danger, fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => status = 'approved'),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        child: const Text('승인', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: status == 'approved' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  status == 'approved' ? '✅  승인 완료' : '❌  거절 완료',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: status == 'approved' ? AppColors.success : AppColors.danger),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Admin Members Screen ---
class AdminMembersScreen extends StatelessWidget {
  const AdminMembersScreen({super.key});

  final members = const [
    {'name': '홍길동', 'age': 67, 'phone': '010-3587-1245', 'pts': '10,000P'},
    {'name': '김영희', 'age': 71, 'phone': '010-4821-9305', 'pts': '8,000P'},
    {'name': '이철수', 'age': 64, 'phone': '010-2294-8810', 'pts': '12,000P'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '회원 관리', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: members.map((m) => CustomCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(m['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                        const SizedBox(width: 8),
                        Text('${m['age']}세', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(m['phone'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(m['pts'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                      child: const Text('승인', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

// --- Admin Inquiry Screen ---
const inquiries = [
  {'id': 1, 'type': '서비스 이용 문의', 'author': '홍길동', 'title': '포인트가 적립되지 않습니다.', 'status': '답변 대기', 'content': '출석 체크를 했는데 포인트가 적립되지 않았습니다. 확인 부탁드립니다.', 'answer': ''},
  {'id': 2, 'type': '버그 신고', 'author': '김영희', 'title': '영화표 예매 화면이 넘어가지 않습니다.', 'status': '답변 완료', 'content': '영화표 예매를 하려고 했는데 좌석 선택 후 다음 버튼이 눌리지 않습니다.', 'answer': '안녕하세요. 불편을 드려 죄송합니다. 해당 버그를 확인하여 수정하였습니다. 감사합니다.'},
];

class AdminInquiryScreen extends StatelessWidget {
  const AdminInquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '문의 관리', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: inquiries.map((q) => CustomCard(
            onTap: () => Navigator.pushNamed(context, '/admin_inquiry_detail', arguments: q),
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(q['type'] as String, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: q['status'] == '답변 완료' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(q['status'] as String, style: TextStyle(color: q['status'] == '답변 완료' ? AppColors.success : const Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(q['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                      const SizedBox(height: 4),
                      Text('작성자: ${q['author']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class AdminInquiryDetailScreen extends StatefulWidget {
  const AdminInquiryDetailScreen({super.key});

  @override
  State<AdminInquiryDetailScreen> createState() => _AdminInquiryDetailScreenState();
}

class _AdminInquiryDetailScreenState extends State<AdminInquiryDetailScreen> {
  String answer = '';
  bool saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final q = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? inquiries.first;
    if (!saved && answer.isEmpty) {
      answer = q['answer'] as String;
      saved = answer.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? inquiries.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '문의 상세', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(q['type'] as String, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(q['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  const SizedBox(height: 8),
                  Text('작성자: ${q['author']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.border, height: 1),
                  ),
                  Text(q['content'] as String, style: const TextStyle(fontSize: 15, color: AppColors.textMain, height: 1.5)),
                ],
              ),
            ),
            const Text('답변 작성', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            const SizedBox(height: 12),
            if (saved)
              CustomCard(
                child: Text(answer, style: const TextStyle(fontSize: 15, color: AppColors.textMain, height: 1.5)),
              )
            else ...[
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => answer = v),
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontSize: 15, color: AppColors.textMain),
                  decoration: const InputDecoration(
                    hintText: '답변을 입력해주세요',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: '답변 등록',
                disabled: answer.isEmpty,
                onPressed: () => setState(() => saved = true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
