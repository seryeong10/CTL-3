import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'bounceable.dart';

enum ButtonVariant { primary, outline, danger }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool disabled;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    if (disabled) {
      bgColor = AppColors.border;
      textColor = AppColors.textSecondary;
    } else {
      switch (variant) {
        case ButtonVariant.primary:
          bgColor = AppColors.primary;
          textColor = Colors.white;
          break;
        case ButtonVariant.outline:
          bgColor = Colors.white;
          textColor = AppColors.textMain;
          borderSide = const BorderSide(color: AppColors.border, width: 1.5);
          break;
        case ButtonVariant.danger:
          bgColor = AppColors.danger;
          textColor = Colors.white;
          break;
      }
    }

    return Bounceable(
      onTap: disabled ? null : onPressed,
      child: IgnorePointer(
        ignoring: !disabled,
        child: SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: disabled ? null : () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: borderSide,
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

