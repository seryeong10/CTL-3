import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/font_size_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _fontCtrl = FontSizeController();
  bool notif = true;

  void showWithdraw() {
    showCustomOverlay(
      context,
      title: '정말 회원 탈퇴하시겠습니까?',
      child: Column(
        children: [
          const Text('탈퇴 후에는 계정을 복구할 수 없습니다.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMain,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 52),
                  ),
                  child: const Text('취소', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context), // Would do logout/withdraw
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 52),
                  ),
                  child: const Text('탈퇴', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '설정'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomCard(
              margin: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('글씨 크기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  const SizedBox(height: 14),
                  Row(
                    children: ['작게', '보통', '크게'].map((s) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _fontCtrl.setFontSize(s);
                          setState(() {});
                        },
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _fontCtrl.fontSize == s ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _fontCtrl.fontSize == s ? AppColors.primary : AppColors.border, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: s == '작게' ? 13 : s == '보통' ? 16 : 20,
                              fontWeight: FontWeight.w700,
                              color: _fontCtrl.fontSize == s ? AppColors.primary : AppColors.textMain,
                            ),
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            
            CustomCard(
              margin: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('알림 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                      const SizedBox(height: 3),
                      Text(notif ? '알림 켜짐' : '알림 꺼짐', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => notif = !notif),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 54,
                      height: 30,
                      decoration: BoxDecoration(
                        color: notif ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeIn,
                            top: 3,
                            left: notif ? 27 : 3,
                            right: notif ? 3 : 27,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
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

            CustomCard(
              margin: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('개인정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  const SizedBox(height: 14),
                  ...[
                    ['이름', '홍길동'],
                    ['생년월일', '1959.03.15'],
                    ['전화번호', '010-3587-1245'],
                    ['아이디', 'hong01'],
                  ].map((r) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r[0], style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                        Text(r[1], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textMain)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            
            GestureDetector(
              onTap: showWithdraw,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                alignment: Alignment.center,
                child: const Text('회원 탈퇴', style: TextStyle(color: AppColors.danger, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
