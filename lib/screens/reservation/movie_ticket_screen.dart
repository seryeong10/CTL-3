import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';
import '../../widgets/bounceable.dart';

class MovieTicketScreen extends StatefulWidget {
  const MovieTicketScreen({super.key});

  @override
  State<MovieTicketScreen> createState() => _MovieTicketScreenState();
}

class _MovieTicketScreenState extends State<MovieTicketScreen> {
  String step = 'movie'; // movie, datetime, people, seat, confirm
  String movie = '';
  String selDate = '';
  String selTime = '';
  String selHall = '';
  
  int adults = 1;
  int teens = 0;
  int srs = 0;
  
  List<String> seats = [];
  bool done = false;

  final dates = [
    {'d': '오늘', 'n': '08'},
    {'d': '목', 'n': '09'},
    {'d': '금', 'n': '10'},
    {'d': '토', 'n': '11'},
    {'d': '일', 'n': '12'},
    {'d': '월', 'n': '13'}
  ];
  
  final halls = [
    {'hall': '1관', 'times': ['10:00~12:00', '14:00~16:00', '18:30~20:30']},
    {'hall': '2관', 'times': ['11:00~13:00', '15:30~17:30', '19:00~21:00']}
  ];

  final rows = ['A', 'B', 'C', 'D'];
  final cols = [1, 2, 3, 4, 5, 6];
  final Set<String> taken = {'A2', 'B4', 'C1', 'C5', 'D3'};

  int get total => adults + teens + srs;
  int get price => adults * 12000 + teens * 9000 + srs * 7000;

  void toggleSeat(String s) {
    setState(() {
      if (seats.contains(s)) {
        seats.remove(s);
      } else {
        if (seats.length >= total) seats.removeAt(0);
        seats.add(s);
      }
    });
  }

  void backFn() {
    if (step == 'movie') {
      Navigator.pop(context);
    } else {
      const prev = {'datetime': 'movie', 'people': 'datetime', 'seat': 'people', 'confirm': 'seat'};
      setState(() => step = prev[step] ?? 'movie');
    }
  }

  String formatPrice(int p) => '${p.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '영화표 예매하기',
        points: 20,
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () => Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '영화표 예매하기', onBack: backFn),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == 'movie') ...[
              const Text('영화를 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...['별빛 여행', '우리들의 봄', '행복한 하루'].map((m) => Bounceable(
                onTap: () => setState(() { movie = m; step = 'datetime'; }),
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: movie == m ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: movie == m ? AppColors.primary : AppColors.border, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text('🎬  $m', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                ),
              )),
            ],

            if (step == 'datetime') ...[
              const Text('날짜를 선택해주세요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: dates.map((d) => Bounceable(
                    onTap: () => setState(() => selDate = d['d']!),
                    child: Container(
                      width: 52,
                      height: 64,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: selDate == d['d'] ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selDate == d['d'] ? AppColors.primary : AppColors.border, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(d['d']!, style: TextStyle(fontSize: 11, color: selDate == d['d'] ? Colors.white : AppColors.textMain)),
                          const SizedBox(height: 2),
                          Text(d['n']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: selDate == d['d'] ? Colors.white : AppColors.textMain)),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text('시간을 선택해주세요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 12),
              ...halls.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h['hall'] as String, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...(h['times'] as List<String>).map((t) => Bounceable(
                      onTap: () => setState(() { selTime = t; selHall = h['hall'] as String; }),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: selTime == t && selHall == h['hall'] ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selTime == t && selHall == h['hall'] ? AppColors.primary : AppColors.border, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                      ),
                    )),
                  ],
                ),
              )),
              if (selDate.isNotEmpty && selTime.isNotEmpty) PrimaryButton(text: '다음', onPressed: () => setState(() => step = 'people')),
            ],

            if (step == 'people') ...[
              const Text('인원을 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              _buildPeopleRow('성인', '12,000원', adults, 1, (v) => setState(() => adults = v)),
              _buildPeopleRow('청소년', '9,000원', teens, 0, (v) => setState(() => teens = v)),
              _buildPeopleRow('경로', '7,000원', srs, 0, (v) => setState(() => srs = v)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('총 $total명 · ${formatPrice(price)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              PrimaryButton(text: '좌석 선택', disabled: total == 0, onPressed: () => setState(() { seats.clear(); step = 'seat'; })),
            ],

            if (step == 'seat') ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Text('SCREEN', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 4)),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
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
                        borderRadius: BorderRadius.circular(8),
                        border: !tk && !sel ? Border.all(color: AppColors.border) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(s, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tk ? const Color(0xFF9CA3AF) : sel ? Colors.white : AppColors.textMain)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildLegend(Colors.white, '선택 가능', border: AppColors.border),
                  const SizedBox(width: 14),
                  _buildLegend(AppColors.primary, '선택됨'),
                  const SizedBox(width: 14),
                  _buildLegend(const Color(0xFFE5E7EB), '불가'),
                ],
              ),
              const SizedBox(height: 12),
              Text('선택: ${seats.isEmpty ? '없음' : seats.join(', ')} (${seats.length}/$total석)', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              PrimaryButton(text: '다음', disabled: seats.length != total, onPressed: () => setState(() => step = 'confirm')),
            ],

            if (step == 'confirm') ...[
              const Text('예매 정보 확인', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              CustomCard(
                child: Column(
                  children: [
                    _buildConfirmRow('영화', movie),
                    _buildConfirmRow('날짜', selDate),
                    _buildConfirmRow('상영관', selHall),
                    _buildConfirmRow('시간', selTime),
                    _buildConfirmRow('인원', '$total명'),
                    _buildConfirmRow('좌석', seats.join(', ')),
                    _buildConfirmRow('결제금액', formatPrice(price), isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(text: '결제하기', onPressed: () => setState(() => done = true)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleRow(String label, String priceStr, int val, int min, ValueChanged<int> onChanged) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
              Text(priceStr, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          QuantityControl(
            count: val,
            onDecrement: () => onChanged(val > min ? val - 1 : min),
            onIncrement: () => onChanged(val + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color bg, String label, {Color? border}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4), border: border != null ? Border.all(color: border) : null),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
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
