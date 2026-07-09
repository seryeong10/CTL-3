import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';

class OnlineShoppingScreen extends StatefulWidget {
  const OnlineShoppingScreen({super.key});

  @override
  State<OnlineShoppingScreen> createState() => _OnlineShoppingScreenState();
}

class _OnlineShoppingScreenState extends State<OnlineShoppingScreen> {
  String step = 'list'; // list, detail, cart, address, confirm
  Map<String, dynamic>? selProd;
  int qty = 1;
  List<Map<String, dynamic>> cart = [];
  Map<String, String> addr = {
    'name': '홍길동',
    'phone': '010-3587-1245',
    'addr': '충청북도 청주시 ○○구 ○○로',
    'detail': '101동 1001호',
  };
  bool done = false;

  final products = [
    {'name': '물티슈', 'price': 5000, 'icon': '🧻'},
    {'name': '세탁세제', 'price': 12000, 'icon': '🫧'},
    {'name': '휴지', 'price': 18000, 'icon': '🧻'},
    {'name': '칫솔', 'price': 4000, 'icon': '🪥'},
    {'name': '샴푸', 'price': 9000, 'icon': '🧴'},
  ];

  void addToCart() {
    if (selProd == null) return;
    setState(() {
      final existingIdx = cart.indexWhere((i) => i['name'] == selProd!['name']);
      if (existingIdx >= 0) {
        cart[existingIdx]['qty'] += qty;
      } else {
        cart.add({...selProd!, 'qty': qty});
      }
      qty = 1;
      step = 'cart';
    });
  }

  void rm(int i) => setState(() => cart.removeAt(i));
  void chQ(int i, int d) => setState(() {
    cart[i]['qty'] = (cart[i]['qty'] as int) + d;
    if (cart[i]['qty'] < 1) cart[i]['qty'] = 1;
  });

  int get total => cart.fold(0, (s, i) => s + (i['price'] as int) * (i['qty'] as int));

  void backFn() {
    if (step == 'list') {
      Navigator.pop(context);
    } else {
      const prev = {'detail': 'list', 'cart': 'list', 'address': 'cart', 'confirm': 'address'};
      setState(() => step = prev[step] ?? 'list');
    }
  }

  String formatPrice(int p) => '${p.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '인터넷 쇼핑하기',
        points: 20,
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () => Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '인터넷 쇼핑하기',
        onBack: backFn,
        rightWidget: step == 'list' ? IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: AppColors.textMain),
                if (cart.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            onPressed: () => setState(() => step = 'cart'),
          ) : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == 'list') ...[
              const Text('상품 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 14),
              ...products.map((p) => CustomCard(
                onTap: () => setState(() { selProd = p; qty = 1; step = 'detail'; }),
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Text(p['icon'] as String, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                          const SizedBox(height: 3),
                          Text(formatPrice(p['price'] as int), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              )),
            ],

            if (step == 'detail' && selProd != null) ...[
              Container(
                height: 188,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(selProd!['icon'] as String, style: const TextStyle(fontSize: 80)),
              ),
              Text(selProd!['name'] as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 4),
              Text(formatPrice(selProd!['price'] as int), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('수량', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                  const SizedBox(width: 16),
                  QuantityControl(
                    count: qty,
                    onDecrement: () => setState(() { if (qty > 1) qty--; }),
                    onIncrement: () => setState(() => qty++),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              PrimaryButton(text: '장바구니 담기', onPressed: addToCart),
            ],

            if (step == 'cart') ...[
              if (cart.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Text('장바구니가 비어있습니다', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                )
              else ...[
                ...cart.asMap().entries.map((e) => _buildCartItem(e.key, e.value)),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('합계', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                      Text(formatPrice(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(child: PrimaryButton(text: '더 담기', onPressed: () => setState(() => step = 'list'), variant: ButtonVariant.outline)),
                  const SizedBox(width: 12),
                  Expanded(child: PrimaryButton(text: '배송지 입력', disabled: cart.isEmpty, onPressed: () => setState(() => step = 'address'))),
                ],
              ),
            ],

            if (step == 'address') ...[
              const Text('배송지를 입력해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              ...[
                ['받는 사람', 'name', '홍길동', TextInputType.text],
                ['전화번호', 'phone', '010-3587-1245', TextInputType.phone],
                ['주소', 'addr', '충청북도 청주시 ○○구 ○○로', TextInputType.text],
                ['상세주소', 'detail', '101동 1001호', TextInputType.text],
              ].map((f) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f[0] as String, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 7),
                    TextInputField(
                      placeholder: f[2] as String,
                      value: addr[f[1] as String]!,
                      onChange: (v) => setState(() => addr[f[1] as String] = v),
                      keyboardType: f[3] as TextInputType,
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
              PrimaryButton(text: '다음', onPressed: () => setState(() => step = 'confirm')),
            ],

            if (step == 'confirm') ...[
              const Text('주문 확인', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              CustomCard(
                margin: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('배송지', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                    const SizedBox(height: 10),
                    ...[
                      ['받는 사람', addr['name']],
                      ['전화번호', addr['phone']],
                      ['주소', addr['addr']],
                      ['상세주소', addr['detail']],
                    ].map((r) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r[0]!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          Text(r[1]!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textMain), textAlign: TextAlign.right),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              CustomCard(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('결제금액', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                    Text(formatPrice(total), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary)),
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

  Widget _buildCartItem(int idx, Map<String, dynamic> item) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(formatPrice((item['price'] as int) * (item['qty'] as int)), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
          QuantityControl(count: item['qty'] as int, onDecrement: () => chQ(idx, -1), onIncrement: () => chQ(idx, 1)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => rm(idx),
            child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)), child: const Icon(Icons.close, size: 15, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
