import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';

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

  final stations = ['서울', '대전', '청주', '부산', '광주'];
  final trains = [
    {'id': 't1', 'dep': '09:00', 'arr': '10:30'},
    {'id': 't2', 'dep': '11:00', 'arr': '12:30'},
    {'id': 't3', 'dep': '14:00', 'arr': '15:30'},
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
              ...['오늘 (7/8)', '내일 (7/9)', '7월 10일', '7월 11일', '7월 12일'].map((d) => _buildBtn('📅  $d', date == d, () => setState(() { date = d; step = 'train'; }))),
            ],

            if (step == 'train') ...[
              const Text('열차를 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 4),
              Text('$dep → $arr  ·  $date', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ...trains.map((t) => GestureDetector(
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
                  
                  return GestureDetector(
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
    return GestureDetector(
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
}
