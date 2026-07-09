import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  String step = 'hospital';
  String hospital = '';
  String dept = '';
  String date = '';
  String time = '';
  bool done = false;

  void backFn() {
    if (step == 'hospital') {
      Navigator.pop(context);
    } else {
      const prev = {'dept': 'hospital', 'date': 'dept', 'time': 'date', 'confirm': 'time'};
      setState(() => step = prev[step] ?? 'hospital');
    }
  }

  void showConfirmOverlay() {
    showCustomOverlay(
      context,
      title: '예약이 완료되었습니다.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('⚠️ 신분증 지참 안내', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                SizedBox(height: 6),
                Text('병원 방문 시 신분증을 꼭 지참해주세요.\n신분증이 없으면 진료 접수가 어려울 수 있습니다.', style: TextStyle(fontSize: 14, color: Color(0xFF92400E), height: 1.6)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => done = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('확인', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '병원 예약하기',
        points: 10,
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () => Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '병원 예약하기', onBack: backFn),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == 'hospital') ...[
              const Text('병원을 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...['우리병원', '행복병원', '중앙병원'].map((h) => _buildListBtn('🏥  $h', hospital == h, () => setState(() { hospital = h; step = 'dept'; }))),
            ],
            
            if (step == 'dept') ...[
              const Text('진료과를 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...['내과', '정형외과', '안과', '이비인후과', '피부과'].map((d) => _buildListBtn(d, dept == d, () => setState(() { dept = d; step = 'date'; }))),
            ],

            if (step == 'date') ...[
              const Text('예약 날짜를 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...['오늘', '내일', '7월 10일', '7월 11일', '7월 12일'].map((d) => _buildListBtn('📅  $d', date == d, () => setState(() { date = d; step = 'time'; }))),
            ],

            if (step == 'time') ...[
              const Text('예약 시간을 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.0,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final t = ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '14:00', '14:30', '15:00'][index];
                  return GestureDetector(
                    onTap: () => setState(() { time = t; step = 'confirm'; }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: time == t ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: time == t ? AppColors.primary : AppColors.border, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                    ),
                  );
                },
              ),
            ],

            if (step == 'confirm') ...[
              const Text('예약 정보를 확인해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              CustomCard(
                child: Column(
                  children: [
                    _buildConfirmRow('병원', hospital),
                    _buildConfirmRow('진료과', dept),
                    _buildConfirmRow('날짜', date),
                    _buildConfirmRow('시간', time),
                    _buildConfirmRow('이름', '홍길동'),
                    _buildConfirmRow('전화번호', '010-3587-1245', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(text: '예약하기', onPressed: showConfirmOverlay),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 68,
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
