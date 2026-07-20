import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool showPopup = true;
  int _balance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
      print('결제 화면 지갑 조회 에러: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _simulateBarcodePayment() async {
    int selectedStoreId = 1;
    String selectedStoreName = '행복카페';
    final amountController = TextEditingController(text: '2000');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('바코드 결제 시뮬레이션', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('결제할 매장 선택:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  DropdownButton<int>(
                    value: selectedStoreId,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('행복카페')),
                      DropdownMenuItem(value: 2, child: Text('우리분식')),
                      DropdownMenuItem(value: 3, child: Text('동네마트')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedStoreId = val;
                          selectedStoreName = val == 1 ? '행복카페' : val == 2 ? '우리분식' : '동네마트';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('결제 금액 입력 (P):', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '금액을 입력하세요',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final amountText = amountController.text;
                    final amount = int.tryParse(amountText) ?? 0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('유효한 금액을 입력해 주세요.')),
                      );
                      return;
                    }
                    if (amount > _balance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('잔액이 부족합니다.')),
                      );
                      return;
                    }

                    try {
                      Navigator.pop(context); // close dialog
                      setState(() => _isLoading = true);
                      
                      await ApiService.payAtMerchant(
                        merchantId: selectedStoreId,
                        amount: amount,
                      );
                      
                      await _loadWallet(); // refresh balance
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$selectedStoreName에서 ${amount}P 결제되었습니다.')),
                        );
                      }
                    } catch (e) {
                      setState(() => _isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('결제 실패: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('결제 완료'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '결제', onBack: () => Navigator.pop(context)),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomCard(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      const Text('현재 보유 포인트', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Text(
                        '${_balance.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}P',
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
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
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: '바코드 결제 시뮬레이션',
                        onPressed: () => _simulateBarcodePayment(),
                        variant: ButtonVariant.outline,
                      ),
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
