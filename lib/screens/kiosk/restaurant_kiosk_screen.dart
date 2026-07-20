import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';
import '../../widgets/bounceable.dart';

class RestKioskScreen extends StatefulWidget {
  const RestKioskScreen({super.key});

  @override
  State<RestKioskScreen> createState() => _RestKioskScreenState();
}

class _RestKioskScreenState extends State<RestKioskScreen> {
  String step = 'store'; // store, menu, type, side, drink, cart
  String storeType = '매장';
  
  List<Map<String, dynamic>> cart = [];
  Map<String, dynamic>? selMenu;
  String selSide = '';
  bool done = false;

  final menus = [
    {'name': '치즈버거', 'price': 5500, 'icon': '🍔'},
    {'name': '불고기버거', 'price': 5800, 'icon': '🍔'},
    {'name': '새우버거', 'price': 6000, 'icon': '🍔'},
    {'name': '치킨버거', 'price': 6200, 'icon': '🍗'},
  ];
  final sides = ['감자튀김', '치즈스틱', '해시브라운'];
  final drinks = ['콜라', '사이다', '오렌지주스'];

  void addSingle() {
    if (selMenu == null) return;
    final String key = '${selMenu!['name']} 단품';
    final existingIdx = cart.indexWhere((i) => i['name'] == key);
    setState(() {
      if (existingIdx >= 0) {
        cart[existingIdx]['qty']++;
      } else {
        cart.add({'name': key, 'price': selMenu!['price'], 'qty': 1});
      }
      selMenu = null;
      step = 'menu';
    });
  }

  void addSet(String drink) {
    if (selMenu == null || selSide.isEmpty) return;
    setState(() {
      cart.add({
        'name': '${selMenu!['name']} 세트',
        'price': (selMenu!['price'] as int) + 2000,
        'qty': 1,
        'meta': '$selSide · $drink'
      });
      selMenu = null;
      selSide = '';
      step = 'menu';
    });
  }

  void rm(int i) => setState(() => cart.removeAt(i));
  void chQ(int i, int d) => setState(() {
    cart[i]['qty'] = (cart[i]['qty'] as int) + d;
    if (cart[i]['qty'] < 1) cart[i]['qty'] = 1;
  });

  void backFn() {
    if (step == 'store') {
      Navigator.pop(context);
    } else {
      const prev = {'menu': 'store', 'type': 'menu', 'side': 'type', 'drink': 'side', 'cart': 'menu'};
      setState(() => step = prev[step] ?? 'store');
    }
  }

  int get cartCount => cart.fold(0, (s, i) => s + (i['qty'] as int));
  int get cartTotal => cart.fold(0, (s, i) => s + (i['price'] as int) * (i['qty'] as int));

  String formatPrice(int p) => '${p.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '음식점 키오스크',
        points: 20,
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () => Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '음식점 키오스크', onBack: backFn),
      bottomNavigationBar: step == 'menu'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Bounceable(
                  onTap: () => setState(() => step = 'cart'),
                  child: IgnorePointer(
                    ignoring: true,
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              cartCount > 0 ? '장바구니 보기  ($cartCount개)' : '장바구니 보기',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (step == 'store') ...[
              const Text('어떻게 드실 건가요?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildBoxBtn('🏠', '매장', () => setState(() { storeType = '매장'; step = 'menu'; }))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildBoxBtn('📦', '포장', () => setState(() { storeType = '포장'; step = 'menu'; }))),
                ],
              ),
            ],

            if (step == 'menu') ...[
              Text('$storeType 주문', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ...menus.map((m) => CustomCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(m['icon'] as String, style: const TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['name'] as String, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                            const SizedBox(height: 3),
                            Text(formatPrice(m['price'] as int), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                    Bounceable(
                      onTap: () => setState(() { selMenu = m; step = 'type'; }),
                      child: IgnorePointer(
                        ignoring: true,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('선택', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            if (step == 'type') ...[
              Text(selMenu?['name'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 6),
              const Text('단품 또는 세트를 선택해주세요', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildTypeBtn('단품', formatPrice(selMenu?['price'] ?? 0), '🍔', addSingle)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTypeBtn('세트', formatPrice((selMenu?['price'] ?? 0) + 2000), '🍔🍟🥤', () => setState(() => step = 'side'))),
                ],
              ),
            ],

            if (step == 'side') ...[
              const Text('사이드를 선택해주세요', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              ...sides.map((s) => _buildSelectBtn(s, selSide == s, () => setState(() { selSide = s; step = 'drink'; }))),
            ],

            if (step == 'drink') ...[
              const Text('음료를 선택해주세요', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              ...drinks.map((d) => _buildSelectBtn(d, false, () => addSet(d))),
            ],

            if (step == 'cart') ...[
              if (cart.isEmpty)
                const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Text('장바구니가 비어있습니다', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 16)))
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
                      Text(formatPrice(cartTotal), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(child: PrimaryButton(text: '메뉴 더 담기', onPressed: () => setState(() => step = 'menu'), variant: ButtonVariant.outline)),
                  const SizedBox(width: 12),
                  Expanded(child: PrimaryButton(text: '결제하기', disabled: cart.isEmpty, onPressed: () => setState(() => done = true))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBoxBtn(String icon, String label, VoidCallback onTap) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        height: 168,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border, width: 2)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain)),
        ]),
      ),
    );
  }

  Widget _buildTypeBtn(String label, String sub, String icon, VoidCallback onTap) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        height: 148,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border, width: 2)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain)),
          Text(sub, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildSelectBtn(String label, bool isSelected, VoidCallback onTap) {
    return Bounceable(
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
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMain)),
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
                if (item['meta'] != null) ...[const SizedBox(height: 2), Text(item['meta'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))],
                const SizedBox(height: 3),
                Text(formatPrice((item['price'] as int) * (item['qty'] as int)), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
          QuantityControl(count: item['qty'] as int, onDecrement: () => chQ(idx, -1), onIncrement: () => chQ(idx, 1)),
          const SizedBox(width: 8),
          Bounceable(
            onTap: () => rm(idx),
            child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)), child: const Icon(Icons.close, size: 15, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
