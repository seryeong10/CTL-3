import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../services/api_service.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  int _balance = 0;
  bool _isLoading = true;
  String _name = '사용자';
  String _phone = '';
  String _birthYearStr = '';

  @override
  void initState() {
    super.initState();
    _name = ApiService.currentUserName ?? '사용자';
    _phone = ApiService.currentUserPhone ?? '';
    _birthYearStr = ApiService.currentUserBirthYear != null
        ? '${ApiService.currentUserBirthYear}년생'
        : '';
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await ApiService.getMyWallet();
      if (wallet != null) {
        setState(() {
          _balance = wallet['balance'] ?? 0;
        });
      }
    } catch (e) {
      print('지갑 조회 에러: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '마이페이지', onBack: () => Navigator.pop(context)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  const SizedBox(height: 4),
                  Text(_phone, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(_birthYearStr, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: Text(
                      '현재 보유 포인트: ${_balance.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}P',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
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
              onTap: () {
                ApiService.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
              },
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
  List<dynamic> earns = [];
  List<dynamic> uses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final txs = await ApiService.getMyPointTransactions();
      final List<dynamic> loadedEarns = [];
      final List<dynamic> loadedUses = [];
      for (var tx in txs) {
        final amount = tx['amount'] ?? 0;
        final description = tx['description'] ?? '';
        final createdAtStr = tx['created_at'] as String?;
        String dateStr = '';
        if (createdAtStr != null) {
          final dt = DateTime.tryParse(createdAtStr);
          if (dt != null) {
            dateStr = '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
          }
        }
        
        if (tx['type'] == 'earn') {
          loadedEarns.add({
            'pts': '+${amount}P',
            'date': dateStr,
            'label': description,
          });
        } else if (tx['type'] == 'use') {
          loadedUses.add({
            'place': description,
            'pts': '-${amount}P',
            'date': dateStr,
          });
        }
      }
      setState(() {
        earns = loadedEarns;
        uses = loadedUses;
      });
    } catch (e) {
      print('거래 내역 로드 에러: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '포인트 내역', onBack: () => Navigator.pop(context)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    earns.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Text('적립 내역이 없습니다.', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                          )
                        : Column(
                            children: earns.map((e) => _buildRow(
                              leftTitle: e['pts']!,
                              leftSub: e['label']!,
                              right: e['date']!,
                              titleColor: AppColors.success,
                            )).toList(),
                          )
                  else
                    uses.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Text('결제 내역이 없습니다.', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                          )
                        : Column(
                            children: uses.map((u) => _buildRow(
                              leftTitle: u['place']!,
                              leftSub: u['date']!,
                              right: u['pts']!,
                              rightColor: AppColors.danger,
                            )).toList(),
                          ),
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

class MissionHistoryScreen extends StatefulWidget {
  const MissionHistoryScreen({super.key});

  @override
  State<MissionHistoryScreen> createState() => _MissionHistoryScreenState();
}

class _MissionHistoryScreenState extends State<MissionHistoryScreen> {
  List<Map<String, dynamic>> missions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    try {
      if (ApiService.currentUserId == null) return;
      final userId = ApiService.currentUserId!;
      
      final logs = await ApiService.getUserMissionLogs(userId);
      final errors = await ApiService.getUserTouchErrorLogs(userId);
      final allMissions = await ApiService.getMissions();
      
      final Map<int, String> idToTitle = {};
      for (var m in allMissions) {
        final mId = m['mission_id'] as int?;
        final title = m['title'] as String?;
        if (mId != null && title != null) {
          idToTitle[mId] = title;
        }
      }

      final Map<int, int> missionErrors = {};
      for (var err in errors) {
        final mId = err['mission_id'] as int?;
        if (mId != null) {
          missionErrors[mId] = (missionErrors[mId] ?? 0) + 1;
        }
      }

      final Map<int, Map<String, dynamic>> grouped = {};
      for (var log in logs) {
        final mId = log['mission_id'] as int?;
        if (mId == null) continue;
        
        final title = idToTitle[mId] ?? '미션 (ID: $mId)';
        
        if (!grouped.containsKey(mId) || log['status'] == '성공') {
          grouped[mId] = {
            'name': title,
            'errors': missionErrors[mId] ?? 0,
            'status': log['status'],
          };
        }
      }

      setState(() {
        missions = grouped.values.map((v) => Map<String, dynamic>.from(v)).toList();
      });
    } catch (e) {
      print('미션 내역 로드 에러: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '미션 수행 내역', onBack: () => Navigator.pop(context)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : missions.isEmpty
              ? const Center(child: Text('수행한 미션 내역이 없습니다.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)))
              : SingleChildScrollView(
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
