import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack; // nullable - 미제공 시 자동 처리
  final Widget? rightWidget;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.rightWidget,
  });

  void _handleBack(BuildContext context) async {
    if (onBack != null) {
      onBack!();
    } else {
      // maybePop: pop이 불가능하면 false 반환 (assertion 오류 없음)
      final didPop = await Navigator.maybePop(context);
      if (!didPop && context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _handleBack(context),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.chevron_left, size: 28, color: AppColors.textMain),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
            ),
            if (rightWidget != null) rightWidget!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
