import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  Map<String, String> formData = {
    'name': '',
    'dob': '',
    'phone': '',
    'id': '',
    'pw': '',
  };

  final fields = [
    ['이름', 'name', '홍길동', false],
    ['생년월일', 'dob', 'YYYY.MM.DD', false],
    ['전화번호', 'phone', '010-0000-0000', false],
    ['아이디', 'id', '영문+숫자 조합', false],
    ['비밀번호', 'pw', '8자 이상 입력', true],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '회원가입',
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...fields.map((f) {
              final label = f[0] as String;
              final key = f[1] as String;
              final ph = f[2] as String;
              final isPassword = f[3] as bool;

              Widget inputWidget;
              if (key == 'dob') {
                inputWidget = GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1960, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        formData['dob'] = "${picked.year}.${picked.month.toString().padLeft(2, '0')}.${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formData['dob']?.isNotEmpty == true
                              ? formData['dob']!
                              : ph,
                          style: TextStyle(
                            fontSize: 16,
                            color: formData['dob']?.isNotEmpty == true
                                ? AppColors.textMain
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Icon(Icons.calendar_month, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                );
              } else {
                inputWidget = TextInputField(
                  placeholder: ph,
                  value: formData[key] ?? '',
                  onChange: (v) => setState(() => formData[key] = v),
                  isPassword: isPassword,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    inputWidget,
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            PrimaryButton(
              text: '회원가입 신청',
              onPressed: () async {
                final name = formData['name'] ?? '';
                final dob = formData['dob'] ?? '';
                final phone = formData['phone'] ?? '';
                final loginId = formData['id'] ?? '';
                final pw = formData['pw'] ?? '';

                if (name.isEmpty || phone.isEmpty || loginId.isEmpty || pw.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모든 항목을 입력해 주세요.')),
                  );
                  return;
                }

                // 생년월일에서 숫자만 추출하여 출생년도 4자리 파싱 (예: 2002.06.11 또는 20020611 -> 2002)
                int birthYear = 1960;
                if (dob.isNotEmpty) {
                  final digitsOnly = dob.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length >= 4) {
                    birthYear = int.tryParse(digitsOnly.substring(0, 4)) ?? 1960;
                  }
                }

                // 백엔드 회원가입 호출
                final result = await ApiService.signUp(
                  name: name,
                  phone: phone,
                  birthYear: birthYear,
                  userType: 'senior', // 기본값으로 senior 지정
                  id: loginId,
                  pw: pw,
                );

                if (result != null) {
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/signup_complete');
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원가입 신청에 실패했습니다. 다시 시도해 주세요.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SignupCompleteScreen extends StatelessWidget {
  const SignupCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 88, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                '회원가입 신청이\n완료되었습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '관리자 승인 후 이용할 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: '로그인 화면으로',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
