import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';

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
                    TextInputField(
                      placeholder: ph,
                      value: formData[key] ?? '',
                      onChange: (v) => setState(() => formData[key] = v),
                      isPassword: isPassword,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            PrimaryButton(
              text: '회원가입 신청',
              onPressed: () => Navigator.pushReplacementNamed(context, '/signup_complete'),
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
