import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';

class MissionCategoriesScreen extends StatelessWidget {
  const MissionCategoriesScreen({super.key});

  final List<Map<String, String>> categories = const [
    {'title': '시뮬레이션', 'desc': '키오스크 실전 연습', 'icon': '🖥️', 'cat': 'sim'},
    {'title': '예약하기', 'desc': '병원 · 영화 · 기차 예약 연습', 'icon': '📅', 'cat': 'book'},
    {'title': '인터넷 주문하기', 'desc': '쇼핑 · 배달 · 배송 조회 연습', 'icon': '📦', 'cat': 'order'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '연습하기'),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final c = categories[index];
          return CustomCard(
            onTap: () => Navigator.pushNamed(context, '/mission_list', arguments: c['cat']),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(c['icon']!, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['title']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        c['desc']!,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 22, color: AppColors.textSecondary),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MissionListScreen extends StatelessWidget {
  const MissionListScreen({super.key});

  static const missions = {
    'sim': [
      {'name': '카페 키오스크', 'level': '쉬움', 'screen': '/cafe_kiosk'},
      {'name': '음식점 키오스크', 'level': '보통', 'screen': '/restaurant_kiosk'},
      {'name': '셀프계산대 이용하기', 'level': '어려움', 'screen': '/self_checkout'},
    ],
    'book': [
      {'name': '병원 예약하기', 'level': '쉬움', 'screen': '/hospital'},
      {'name': '영화표 예매하기', 'level': '보통', 'screen': '/movie_ticket'},
      {'name': '기차표 예매하기', 'level': '어려움', 'screen': '/train_ticket'},
    ],
    'order': [
      {'name': '택배 배송 조회하기', 'level': '쉬움', 'screen': '/package_tracking'},
      {'name': '인터넷 쇼핑하기', 'level': '보통', 'screen': '/online_shopping'},
      {'name': '배달 음식 주문하기', 'level': '어려움', 'screen': '/food_delivery'},
    ],
  };

  static const catTitles = {'sim': '시뮬레이션', 'book': '예약하기', 'order': '인터넷 주문하기'};

  @override
  Widget build(BuildContext context) {
    final cat = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'sim';
    final title = catTitles[cat] ?? '미션';
    final items = missions[cat] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: title),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final m = items[index];
          return CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      m['name']!,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textMain),
                    ),
                    const SizedBox(width: 8),
                    Pill(level: m['level']!),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (m['screen']!.isNotEmpty) {
                       Navigator.pushNamed(context, m['screen']!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                  child: const Text('시작', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
