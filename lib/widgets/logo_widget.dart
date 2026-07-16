import 'package:flutter/material.dart';
import '../core/theme.dart';

/// 배움페이 로고 위젯 (이미지 파일 없이 Flutter 코드로 직접 그림)
class BaeumPayLogo extends StatelessWidget {
  final double size;
  const BaeumPayLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 원형 배경 (파란색 그라데이션)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.08),
                ),
              ],
            ),
          ),
          // 책/학습 아이콘
          Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: size * 0.52,
          ),
          // 우측 하단 원형 포인트 배지
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
