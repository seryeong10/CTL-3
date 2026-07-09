import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';

class SelfCheckoutScreen extends StatefulWidget {
  const SelfCheckoutScreen({super.key});

  @override
  State<SelfCheckoutScreen> createState() => _SelfCheckoutScreenState();
}

class _SelfCheckoutScreenState extends State<SelfCheckoutScreen> {
  String step = 'start'; // start, scan, bag, pay
  List<Map<String, dynamic>> cart = [];
  bool? bag;
  bool done = false;

  final products = [
    {'name': '생수', 'price': 1000, 'icon': '💧'},
    {'name': '컵라면', 'price': 1500, 'icon': '🍜'},
    {'name': '과자', 'price': 2000, 'icon': '🍪'},
    {'name': '우유', 'price': 2500, 'icon': '🥛'},
    {'name': '바나나우유', 'price': 1800, 'icon': '🍌'},
    {'name': '휴지', 'price': 5000, 'icon': '🧻'},
  ];

  void scan(Map<String, dynamic> p) {
    setState(() {
      final existingIdx = cart.indexWhere((i) => i['name'] == p['name']);
      if (existingIdx >= 0) {
        cart[existingIdx]['qty']++;
      } else {
        cart.add({...p, 'qty': 1});
      }
    });
  }

  void rm(int i) => setState(() => cart.removeAt(i));
  void chQ(int i, int d) => setState(() {
    cart[i]['qty'] = (cart[i]['qty'] as int) + d;
    if (cart[i]['qty'] < 1) cart[i]['qty'] = 1;
  });

  int get subtotal =>
      cart.fold(0, (s, i) => s + (i['price'] as int) * (i['qty'] as int));
  int get total => subtotal + (bag == true ? 100 : 0);

  void backFn() {
    if (step == 'start') {
      Navigator.pop(context);
    } else {
      const prev = {'scan': 'start', 'bag': 'scan', 'pay': 'bag'};
      setState(() => step = prev[step] ?? 'start');
    }
  }

  String formatPrice(int p) =>
      '${p.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '셀프계산대',
        points: 30,
        onHome: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () =>
            Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '셀프계산대', onBack: backFn),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == 'start') ...[
              const SizedBox(height: 56),
              const Text(
                '🏪',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 84),
              ),
              const SizedBox(height: 24),
              const Text(
                '셀프계산대',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '상품을 직접 스캔하고 결제해보세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 52),
              PrimaryButton(
                text: '시작하기',
                onPressed: () => setState(() => step = 'scan'),
              ),
            ],

            if (step == 'scan') ...[
              const Text(
                '상품을 눌러 스캔하세요',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.0,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return GestureDetector(
                    onTap: () => scan(p),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['icon'] as String,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatPrice(p['price'] as int),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (cart.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  '담은 상품',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 12),
                ...cart.asMap().entries.map(
                  (e) => _buildCartItem(e.key, e.value),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: '다음',
                  onPressed: () => setState(() => step = 'bag'),
                ),
              ],
            ],

            if (step == 'bag') ...[
              const Text(
                '봉투가 필요하신가요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '봉투 추가 시 100원이 추가됩니다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildBagBtn('필요함  +100원', true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildBagBtn('필요 없음', false)),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: '다음',
                disabled: bag == null,
                onPressed: () => setState(() => step = 'pay'),
              ),
            ],

            if (step == 'pay') ...[
              const Text(
                '결제 방법을 선택해주세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 20),
              CustomCard(
                child: Column(
                  children: [
                    _buildSummaryRow('상품 금액', formatPrice(subtotal)),
                    if (bag == true) _buildSummaryRow('봉투', '100원'),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '합계',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          formatPrice(total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildPayBtn('💳  카드 결제'),
              const SizedBox(height: 12),
              _buildPayBtn('📱  간편결제'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(int idx, Map<String, dynamic> item) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  formatPrice((item['price'] as int) * (item['qty'] as int)),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          QuantityControl(
            count: item['qty'] as int,
            onDecrement: () => chQ(idx, -1),
            onIncrement: () => chQ(idx, 1),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => rm(idx),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.close,
                size: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBagBtn(String label, bool val) {
    return GestureDetector(
      onTap: () => setState(() => bag = val),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: bag == val
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: bag == val ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPayBtn(String label) {
    return GestureDetector(
      onTap: () => setState(() => done = true),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
      ),
    );
  }
}
