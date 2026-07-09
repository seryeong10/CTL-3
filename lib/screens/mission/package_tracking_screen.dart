import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';

class PackageTrackingScreen extends StatefulWidget {
  const PackageTrackingScreen({super.key});

  @override
  State<PackageTrackingScreen> createState() => _PackageTrackingScreenState();
}

class _PackageTrackingScreenState extends State<PackageTrackingScreen> {
  String step = 'courier'; // courier, number, result
  String courier = '';
  String num = '';
  bool done = false;

  final stages = ['상품 준비', '집화 완료', '이동 중', '배송 출발', '배송 완료'];
  final int currentStage = 3;

  void backFn() {
    if (step == 'courier') {
      Navigator.pop(context);
    } else {
      setState(() => step = step == 'result' ? 'number' : 'courier');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '택배 배송 조회하기',
        points: 10,
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () => Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '택배 배송 조회하기', onBack: backFn),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == 'courier') ...[
              const Text('택배사를 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...['일반 택배', '우체국 택배', '편의점 택배'].map((c) => GestureDetector(
                onTap: () => setState(() { courier = c; step = 'number'; }),
                child: Container(
                  width: double.infinity,
                  height: 68,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: courier == c ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: courier == c ? AppColors.primary : AppColors.border, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text('📦  $c', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                ),
              )),
            ],

            if (step == 'number') ...[
              const Text('운송장 번호를 입력해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 8),
              const Text('예시: 123456789012 (하이픈 없이)', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: TextInputField(
                  placeholder: '운송장 번호 입력',
                  value: num,
                  onChange: (v) => setState(() => num = v),
                  keyboardType: TextInputType.phone,
                ),
              ),
              PrimaryButton(
                text: '조회하기',
                disabled: num.length < 10,
                onPressed: () => setState(() => step = 'result'),
              ),
            ],

            if (step == 'result') ...[
              CustomCard(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(courier, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text(num, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  ],
                ),
              ),
              const Text('배송 상태', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Stack(
                  children: [
                    Positioned(
                      left: -22,
                      top: 10,
                      bottom: 10,
                      width: 2,
                      child: Container(color: AppColors.border),
                    ),
                    Column(
                      children: stages.asMap().entries.map((e) {
                        final i = e.key;
                        final s = e.value;
                        final isCur = i == currentStage;
                        final isD = i < currentStage;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 26),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: -32,
                                top: 0,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isCur ? AppColors.primary : (isD ? AppColors.success : AppColors.border),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: isD ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(s, style: TextStyle(fontSize: 16, fontWeight: isCur ? FontWeight.w700 : FontWeight.w500, color: isCur ? AppColors.primary : (isD ? AppColors.textMain : AppColors.textSecondary))),
                                      if (isCur) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                          child: const Text('현재', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (isCur) const Padding(padding: EdgeInsets.only(top: 3), child: Text('2026.07.08  14:32', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                                  if (isD) const Padding(padding: EdgeInsets.only(top: 2), child: Text('완료', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              PrimaryButton(text: '확인했어요', onPressed: () => setState(() => done = true)),
            ],
          ],
        ),
      ),
    );
  }
}
