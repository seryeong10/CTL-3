import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool showPopup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '결제', onBack: () => Navigator.pop(context)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomCard(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: const [
                      Text('현재 보유 포인트', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      SizedBox(height: 6),
                      Text('10,000P', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                ),
                CustomCard(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Icon(Icons.qr_code_2, size: 140, color: Colors.black),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(45, (i) {
                                final widths = [2.0, 4.0, 1.0, 3.0, 2.0, 5.0, 1.0, 3.0];
                                final margins = [2.0, 1.0, 3.0, 1.0, 2.0, 1.0];
                                return Container(
                                  width: widths[i % widths.length],
                                  height: 60,
                                  margin: EdgeInsets.only(right: margins[i % margins.length]),
                                  color: Colors.black,
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '4839 2910 3948 5829',
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('점원에게 보여주세요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showPopup)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('현장 결제 안내', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                    const SizedBox(height: 14),
                    const Text('점원에게 이 화면을 보여주세요.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () => setState(() => showPopup = false),
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
              ),
            ),
        ],
      ),
    );
  }
}
