import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool attended = false;

  final List<Map<String, dynamic>> menus = [
    {'label': '미션', 'icon': Icons.track_changes, 'route': '/mission_categories', 'color': const Color(0xFFF59E0B)},
    {'label': '결제', 'icon': Icons.payment, 'route': '/payment', 'color': const Color(0xFF10B981)},
    {'label': '지도', 'icon': Icons.map, 'route': '/map', 'color': const Color(0xFF6366F1)},
    {'label': '마이페이지', 'icon': Icons.person, 'route': '/my_info', 'color': const Color(0xFFEC4899)},
    {'label': '고객센터', 'icon': Icons.headset_mic, 'route': '/customer_center', 'color': const Color(0xFF8B5CF6)},
    {'label': '설정', 'icon': Icons.settings, 'route': '/settings', 'color': const Color(0xFF64748B)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '배움페이',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '10,000P',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero card
                    Container(
                      padding: const EdgeInsets.all(22),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '안녕하세요, 홍길동님 👋',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '오늘도 열심히 연습해봐요!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.82),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '오늘 연습 진행도',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.75),
                                    ),
                                  ),
                                  const Text(
                                    '1 / 3',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: attended ? null : () => setState(() => attended = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: attended ? Colors.white.withValues(alpha: 0.25) : Colors.white,
                              foregroundColor: attended ? Colors.white.withValues(alpha: 0.85) : AppColors.primary,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              disabledBackgroundColor: Colors.white.withValues(alpha: 0.25),
                              disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
                            ),
                            child: Text(
                              attended ? '✅  출석 완료!' : '출석 체크하기  +10P',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Menu grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: menus.length,
                      itemBuilder: (context, index) {
                        final menu = menus[index];
                        return CustomCard(
                          onTap: () {
                            if (menu['route'] != null && (menu['route'] as String).isNotEmpty) {
                              Navigator.pushNamed(context, menu['route'] as String);
                            }
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(menu['icon'] as IconData, size: 34, color: menu['color'] as Color),
                              const SizedBox(height: 10),
                              Text(
                                menu['label'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Today's mission
                    const Text(
                      '오늘의 추천 미션',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    '음식점 키오스크',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                  ),
                                  SizedBox(width: 8),
                                  Pill(level: '보통'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Text('시뮬레이션', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/restaurant_kiosk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(0, 46),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: const Text('시작하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
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
