import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'primary_button.dart';

class MissionCompleteScreen extends StatelessWidget {
  final String missionName;
  final int points;
  final VoidCallback onHome;
  final VoidCallback onOther;

  const MissionCompleteScreen({
    super.key,
    required this.missionName,
    required this.points,
    required this.onHome,
    required this.onOther,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 52, color: AppColors.success),
              ),
              const SizedBox(height: 20),
              const Text(
                '연습 완료!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$missionName 성공',
                style: const TextStyle(
                  fontSize: 19,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+${points}P 획득!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  PrimaryButton(text: '홈으로', onPressed: onHome),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: '다른 연습하기',
                    onPressed: onOther,
                    variant: ButtonVariant.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showCustomOverlay(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      );
    },
  );
}
