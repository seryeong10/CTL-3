import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/logo_widget.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String tab = 'user';
  String id = '';
  String pw = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Column(
                children: [
                  const BaeumPayLogo(size: 80),
                  const SizedBox(height: 14),
                  const Text(
                    '배움페이',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '시니어를 위한 디지털 생활 연습 앱',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              // Tab
              Container(
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTab('user', '일반 회원'),
                    _buildTab('admin', '관리자'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              
              if (tab == 'user')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextInputField(
                      placeholder: '아이디',
                      value: id,
                      onChange: (v) => setState(() => id = v),
                    ),
                    const SizedBox(height: 14),
                    TextInputField(
                      placeholder: '비밀번호',
                      value: pw,
                      onChange: (v) => setState(() => pw = v),
                      isPassword: true,
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: '로그인',
                      onPressed: () async {
                        if (id.isEmpty || pw.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해 주세요.')),
                          );
                          return;
                        }

                        // ID와 PW로 로그인 시도
                        final user = await ApiService.loginWithIdPw(id, pw);

                        if (user != null) {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        } else {
                          if (mounted) {
                            final errorMsg = ApiService.lastError ?? '등록되지 않은 회원 정보이거나 비밀번호가 다릅니다.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMsg)),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: '회원가입',
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      variant: ButtonVariant.outline,
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextInputField(
                      placeholder: '관리자 아이디',
                      value: id,
                      onChange: (v) => setState(() => id = v),
                    ),
                    const SizedBox(height: 14),
                    TextInputField(
                      placeholder: '관리자 비밀번호',
                      value: pw,
                      onChange: (v) => setState(() => pw = v),
                      isPassword: true,
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: '관리자 로그인',
                      onPressed: () async {
                        if (id.isEmpty || pw.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('관리자 아이디와 비밀번호를 입력해 주세요.')),
                          );
                          return;
                        }

                        // ID와 PW로 로그인 시도
                        final user = await ApiService.loginWithIdPw(id, pw);

                        if (user != null && (user['user_type'] == 'admin' || user['user_type'] == 'merchant')) {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/admin_home');
                          }
                        } else {
                          if (mounted) {
                            final errorMsg = ApiService.lastError ?? '관리자 또는 점주 계정이 아니거나 등록되지 않은 회원입니다.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMsg)),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '관리자 계정만 이용할 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String tabValue, String label) {
    final isSelected = tab == tabValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = tabValue),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
