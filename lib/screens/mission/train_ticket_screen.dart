import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';
import '../../widgets/bounceable.dart';

class TrainTicketScreen extends StatefulWidget {
  const TrainTicketScreen({super.key});

  @override
  State<TrainTicketScreen> createState() => _TrainTicketScreenState();
}

class _TrainTicketScreenState extends State<TrainTicketScreen> {
  String step = 'depart'; // depart, arrive, date, train, seat, confirm
  String dep = '';
  String arr = '';
  String date = '';
  String train = '';
  List<String> seats = [];
  bool done = false;
  DateTime _calDate = DateTime.now();
  String _calMode = 'day';

  final stations = ['서울', '대전', '청주', '부산', '광주'];
  final trains = [
    {'id': 't1', 'dep': '09:00', 'arr': '10:30'},
    {'id': 't2', 'dep': '11:00', 'arr': '12:30'},
    {'id': 't3', 'dep': '14:00', 'arr': '15:30'},
    {'id': 't4', 'dep': '17:00', 'arr': '18:30'},
    {'id': 't5', 'dep': '19:30', 'arr': '21:00'},
  ];
  final rows = ['A', 'B', 'C', 'D', 'E'];
  final cols = [1, 2, 3, 4];
  final taken = {'A1', 'B3', 'C2', 'D4', 'E1'};

  void backFn() {
    if (step == 'depart') {
      Navigator.pop(context);
    } else {
      const prev = {'arrive': 'depart', 'date': 'arrive', 'train': 'date', 'seat': 'train', 'confirm': 'seat'};
      setState(() => step = prev[step] ?? 'depart');
    }
  }

  void toggleSeat(String s) {
    setState(() {
      if (seats.contains(s)) {
        seats.remove(s);
      } else {
        if (seats.isNotEmpty) seats.clear();
        seats.add(s);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '기차표 예매하기',
        points: 30,
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () => Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    final selTrain = trains.cast<Map<String, String>?>().firstWhere((t) => t?['id'] == train, orElse: () => null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '기차표 예매하기', onBack: backFn),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == 'depart') ...[
              const Text('출발역을 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...stations.map((s) => _buildBtn('🚉  $s', dep == s, () => setState(() { dep = s; step = 'arrive'; }))),
            ],

            if (step == 'arrive') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('출발역', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('🚉  $dep', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
              const Text('도착역을 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...stations.where((s) => s != dep).map((s) => _buildBtn('🚉  $s', arr == s, () => setState(() { arr = s; step = 'date'; }))),
            ],

            if (step == 'date') ...[
              const Text('날짜를 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: _buildCalendar(),
              ),
            ],

            if (step == 'train') ...[
              const Text('열차를 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 4),
              Text('$dep → $arr  ·  $date', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ...trains.map((t) => Bounceable(
                onTap: () => setState(() { train = t['id']!; step = 'seat'; }),
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: train == t['id'] ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: train == t['id'] ? AppColors.primary : AppColors.border, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('KTX', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('${t['dep']}  →  ${t['arr']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                        ],
                      ),
                      const Text('잔여석 있음', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ],
                  ),
                ),
              )),
            ],

            if (step == 'seat') ...[
              const Text('좌석을 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 4),
              const Text('1인 1좌석', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: rows.length * cols.length,
                itemBuilder: (context, index) {
                  final r = rows[index ~/ cols.length];
                  final c = cols[index % cols.length];
                  final s = '$r$c';
                  final tk = taken.contains(s);
                  final sel = seats.contains(s);
                  
                  return Bounceable(
                    onTap: tk ? null : () => toggleSeat(s),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tk ? const Color(0xFFE5E7EB) : sel ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: !tk && !sel ? Border.all(color: AppColors.border) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tk ? const Color(0xFF9CA3AF) : sel ? Colors.white : AppColors.textMain)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text('선택된 좌석: ${seats.isEmpty ? '없음' : seats.first}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              PrimaryButton(text: '다음', disabled: seats.isEmpty, onPressed: () => setState(() => step = 'confirm')),
            ],

            if (step == 'confirm') ...[
              const Text('예매 정보 확인', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              CustomCard(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    _buildConfirmRow('출발역', dep),
                    _buildConfirmRow('도착역', arr),
                    _buildConfirmRow('날짜', date),
                    _buildConfirmRow('열차', selTrain != null ? '${selTrain['dep']} → ${selTrain['arr']}' : ''),
                    _buildConfirmRow('좌석', seats.isNotEmpty ? seats.first : ''),
                    _buildConfirmRow('결제금액', '69,000원', isLast: true),
                  ],
                ),
              ),
              PrimaryButton(text: '결제하기', onPressed: () => setState(() => done = true)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(String label, bool isSelected, VoidCallback onTap) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textMain)),
      ),
    );
  }

  Widget _buildConfirmRow(String label, String val, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: isLast ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textMain)),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    if (_calMode == 'year') {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 2, crossAxisSpacing: 10, mainAxisSpacing: 10
          ),
          itemCount: 6,
          itemBuilder: (context, i) {
            final y = DateTime.now().year + i;
            return Bounceable(
              onTap: () => setState(() { _calDate = DateTime(y, _calDate.month, 1); _calMode = 'month'; }),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text('$y년', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            );
          }
        ),
      );
    } else if (_calMode == 'month') {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, childAspectRatio: 1.5, crossAxisSpacing: 10, mainAxisSpacing: 10
          ),
          itemCount: 12,
          itemBuilder: (context, i) {
            final m = i + 1;
            return Bounceable(
              onTap: () => setState(() { _calDate = DateTime(_calDate.year, m, 1); _calMode = 'day'; }),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text('$m월', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            );
          }
        ),
      );
    } else {
      final firstDay = DateTime(_calDate.year, _calDate.month, 1);
      final daysInMonth = DateTime(_calDate.year, _calDate.month + 1, 0).day;
      final startingWeekday = firstDay.weekday % 7; // 0 for Sunday
      
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() { _calDate = DateTime(_calDate.year, _calDate.month - 1, 1); }),
                ),
                Row(
                  children: [
                    Bounceable(
                      onTap: () => setState(() => _calMode = 'year'),
                      child: Text('${_calDate.year}년 ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    Bounceable(
                      onTap: () => setState(() => _calMode = 'month'),
                      child: Text('${_calDate.month}월', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ]
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() { _calDate = DateTime(_calDate.year, _calDate.month + 1, 1); }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['일', '월', '화', '수', '목', '금', '토'].map((d) => Text(d, style: TextStyle(color: d == '일' ? Colors.red : d == '토' ? Colors.blue : AppColors.textSecondary, fontWeight: FontWeight.w600))).toList(),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, childAspectRatio: 1
              ),
              itemCount: startingWeekday + daysInMonth,
              itemBuilder: (context, i) {
                if (i < startingWeekday) return const SizedBox();
                final day = i - startingWeekday + 1;
                final isToday = _calDate.year == DateTime.now().year && _calDate.month == DateTime.now().month && day == DateTime.now().day;
                
                return Bounceable(
                  onTap: () {
                    setState(() {
                      date = '${_calDate.month}월 $day일';
                      step = 'train';
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('$day', style: TextStyle(fontSize: 15, color: isToday ? Colors.white : AppColors.textMain, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              }
            ),
          ],
        ),
      );
    }
  }
}
