import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/logo_widget.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool attended = false;
  int _balance = 0;
  String _userName = '사용자';
  int _completedMissionsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userName = ApiService.currentUserName ?? '사용자';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final wallet = await ApiService.getMyWallet();
      if (wallet != null) {
        _balance = wallet['balance'] ?? 0;
      }
      
      if (ApiService.currentUserId != null) {
        final logs = await ApiService.getUserMissionLogs(ApiService.currentUserId!);
        final today = DateTime.now();
        int completedToday = 0;
        for (var log in logs) {
          if (log['status'] == '성공') {
            final completedAtStr = log['completed_at'] as String?;
            if (completedAtStr != null) {
              final completedAt = DateTime.tryParse(completedAtStr);
              if (completedAt != null &&
                  completedAt.year == today.year &&
                  completedAt.month == today.month &&
                  completedAt.day == today.day) {
                completedToday++;
              }
            }
          }
        }
        _completedMissionsCount = completedToday;

        final txs = await ApiService.getMyPointTransactions();
        bool foundAttendanceToday = false;
        for (var tx in txs) {
          if (tx['type'] == 'earn' && tx['description'] == '출석 체크') {
            final createdAtStr = tx['created_at'] as String?;
            if (createdAtStr != null) {
              final createdAt = DateTime.tryParse(createdAtStr);
              if (createdAt != null &&
                  createdAt.year == today.year &&
                  createdAt.month == today.month &&
                  createdAt.day == today.day) {
                foundAttendanceToday = true;
                break;
              }
            }
          }
        }
        attended = foundAttendanceToday;
      }
    } catch (e) {
      print('데이터 로드 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAttendance() async {
    if (attended) return;
    try {
      final tx = await ApiService.createPointTransaction(
        type: 'earn',
        amount: 10,
        description: '출석 체크',
      );
      if (tx != null) {
        setState(() {
          attended = true;
          _balance += 10;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('출석체크 완료! 10P가 적립되었습니다.')),
          );
        }
      } else {
        throw Exception('출석체크 실패');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('출석체크 실패: $e')),
        );
      }
    }
  }

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
                  Row(
                    children: [
                      const BaeumPayLogo(size: 32),
                      const SizedBox(width: 8),
                      const Text(
                        '배움페이',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_balance.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}P',
                      style: const TextStyle(
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
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
                                  Text(
                                    '안녕하세요, $_userName님 👋',
                                    style: const TextStyle(
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
                                  Text(
                                    '$_completedMissionsCount / 3',
                                    style: const TextStyle(
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
                            onPressed: attended ? null : _handleAttendance,
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
                    
                    // Today's missions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '오늘의 추천 미션',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_completedMissionsCount / 3 완료',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        {
                          'title': '음식점\n키오스크',
                          'sub': '시뮬레이션',
                          'level': '보통',
                          'icon': '🍔',
                          'route': '/restaurant_kiosk',
                          'point': '+20P',
                        },
                        {
                          'title': '카페\n키오스크',
                          'sub': '시뮬레이션',
                          'level': '쉬움',
                          'icon': '☕',
                          'route': '/cafe_kiosk',
                          'point': '+10P',
                        },
                        {
                          'title': '배달 음식\n주문',
                          'sub': '앱 주문 실습',
                          'level': '어려움',
                          'icon': '🛵',
                          'route': '/food_delivery',
                          'point': '+30P',
                        },
                      ].asMap().entries.map((entry) {
                        final idx = entry.key;
                        final m = entry.value;
                        return Expanded(
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: idx == 0 ? 0 : 6,
                                  right: idx == 2 ? 0 : 6,
                                ),
                                padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(m['icon']!, style: const TextStyle(fontSize: 32)),
                                    const SizedBox(height: 10),
                                    Text(
                                      m['title']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(m['point']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pushNamed(context, m['route']!),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          minimumSize: const Size(0, 38),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Text('시작', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: idx == 2 ? 8 : 14,
                                child: Pill(level: m['level']!),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
