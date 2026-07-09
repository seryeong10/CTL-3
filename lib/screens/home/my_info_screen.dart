import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '마이페이지', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomCard(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Icon(Icons.person, size: 38, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  const Text('홍길동', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  const SizedBox(height: 4),
                  const Text('hong1234', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text('1959.03.15', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: const Text('현재 보유 포인트: 10,000P', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            ...[
              {'label': '포인트 내역', 'icon': '⭐', 'route': '/point_history'},
              {'label': '미션 수행 내역', 'icon': '📋', 'route': '/mission_history'},
            ].map((m) => CustomCard(
              onTap: () => Navigator.pushNamed(context, m['route']!),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(m['icon']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(m['label']!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            )),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false),
              child: Container(
                height: 64,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: AppColors.danger),
                    SizedBox(width: 12),
                    Text('로그아웃', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.danger)),
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

class PointHistoryScreen extends StatefulWidget {
  const PointHistoryScreen({super.key});

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  String tab = 'earn';

  final earns = [
    {'pts': '+10P', 'date': '2026.07.08', 'label': '출석 체크'},
    {'pts': '+20P', 'date': '2026.07.07', 'label': '미션 완료'},
    {'pts': '+10P', 'date': '2026.07.06', 'label': '출석 체크'},
    {'pts': '+30P', 'date': '2026.07.05', 'label': '미션 완료'},
  ];

  final uses = [
    {'place': '행복카페', 'pts': '-3,000P', 'date': '2026.07.08'},
    {'place': '우리분식', 'pts': '-5,000P', 'date': '2026.07.06'},
    {'place': '동네마트', 'pts': '-2,000P', 'date': '2026.07.04'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '포인트 내역', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: ['earn', 'use'].map((t) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => tab = t),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(color: tab == t ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: Text(t == 'earn' ? '적립 내역' : '결제 내역', style: TextStyle(color: tab == t ? AppColors.primary : AppColors.textSecondary, fontSize: 15, fontWeight: tab == t ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  ),
                )).toList(),
              ),
            ),
            if (tab == 'earn')
              ...earns.map((e) => _buildRow(
                leftTitle: e['pts']!,
                leftSub: e['label']!,
                right: e['date']!,
                titleColor: AppColors.success,
              ))
            else
              ...uses.map((u) => _buildRow(
                leftTitle: u['place']!,
                leftSub: u['date']!,
                right: u['pts']!,
                rightColor: AppColors.danger,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({required String leftTitle, required String leftSub, required String right, Color? titleColor, Color? rightColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leftTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: titleColor ?? AppColors.textMain)),
              const SizedBox(height: 3),
              Text(leftSub, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          Text(right, style: TextStyle(fontSize: 14, fontWeight: rightColor != null ? FontWeight.w700 : FontWeight.normal, color: rightColor ?? AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class MissionHistoryScreen extends StatelessWidget {
  const MissionHistoryScreen({super.key});

  final missions = const [
    {'name': '카페 키오스크', 'errors': 0},
    {'name': '병원 예약하기', 'errors': 0},
    {'name': '택배 배송 조회하기', 'errors': 0},
    {'name': '음식점 키오스크', 'errors': 2},
    {'name': '영화표 예매하기', 'errors': 1},
    {'name': '기차표 예매하기', 'errors': 3},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '미션 수행 내역', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: missions.map((m) {
            final err = m['errors'] as int;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: err > 0 ? const Color(0xFFFEF2F2) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: err > 0 ? const Color(0xFFFECACA) : AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: err > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(err > 0 ? '오답 $err회' : '완료', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: err > 0 ? AppColors.danger : AppColors.success)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
