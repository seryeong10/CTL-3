import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';

class FoodDeliveryScreen extends StatefulWidget {
  const FoodDeliveryScreen({super.key});

  @override
  State<FoodDeliveryScreen> createState() => _FoodDeliveryScreenState();
}

class _FoodDeliveryScreenState extends State<FoodDeliveryScreen> {
  String step = 'store'; // store, menu, option, cart, address, request, confirm
  String store = '';
  Map<String, dynamic>? selMenu;
  Map<String, String> opts = {};
  List<Map<String, dynamic>> cart = [];
  Map<String, String> addr = {
    'name': '홍길동',
    'phone': '010-3587-1245',
    'addr': '충청북도 청주시 ○○구 ○○로',
    'detail': '101동 1001호',
  };
  String reqSel = '';
  bool done = false;

  final storeMenus = {
    '우리분식': [{'name': '떡볶이', 'price': 4000, 'icon': '🥘'}, {'name': '순대', 'price': 4000, 'icon': '🍲'}, {'name': '튀김', 'price': 3000, 'icon': '🍤'}, {'name': '음료수', 'price': 2000, 'icon': '🥤'}],
    '동네치킨': [{'name': '후라이드 치킨', 'price': 20000, 'icon': '🍗'}, {'name': '양념치킨', 'price': 22000, 'icon': '🍗'}, {'name': '치즈볼', 'price': 5000, 'icon': '🧆'}, {'name': '음료', 'price': 2000, 'icon': '🥤'}],
    '행복피자': [{'name': '포테이토 피자', 'price': 28000, 'icon': '🍕'}, {'name': '고구마 피자', 'price': 28000, 'icon': '🍕'}, {'name': '음료', 'price': 2000, 'icon': '🥤'}],
  };

  final storeOpts = {
    '우리분식': [
      {'label': '맛 선택', 'options': [{'name': '순한맛', 'price': 0}, {'name': '보통맛', 'price': 0}, {'name': '매운맛', 'price': 0}]},
      {'label': '추가 선택', 'options': [{'name': '없음', 'price': 0}, {'name': '치즈 추가', 'price': 1000}]},
    ],
    '동네치킨': [
      {'label': '뼈/순살', 'options': [{'name': '뼈', 'price': 0}, {'name': '순살', 'price': 0}]}
    ],
    '행복피자': [
      {'label': '사이드', 'options': [{'name': '없음', 'price': 0}, {'name': '치즈오븐스파게티', 'price': 8000}]}
    ],
  };

  final storeIcons = {'우리분식': '🍜', '동네치킨': '🍗', '행복피자': '🍕'};
  final reqOpts = ['일회용 수저 주세요', '맵지 않게 해주세요', '문 앞에 놓아주세요', '직접 입력'];

  void addToCart({bool skipOptions = false}) {
    if (selMenu == null) return;
    int extra = 0;
    
    if (!skipOptions) {
      final optsList = storeOpts[store] ?? [];
      for (var g in optsList) {
        final selectedOpt = opts[g['label'] as String];
        final options = g['options'] as List;
        int p = 0;
        for (var o in options) {
          if ((o as Map)['name'] == selectedOpt) {
            p = (o['price'] as num).toInt();
            break;
          }
        }
        extra += p;
      }
    }

    final metaStr = skipOptions ? '' : opts.values.where((v) => v.isNotEmpty).join(' · ');
    
    setState(() {
      final metaToSave = metaStr.isEmpty ? null : metaStr;
      final existingIdx = cart.indexWhere((item) => item['name'] == selMenu!['name'] && item['meta'] == metaToSave);
      
      if (existingIdx != -1) {
        cart[existingIdx]['qty'] = (cart[existingIdx]['qty'] as int) + 1;
      } else {
        cart.add({
          'name': selMenu!['name'],
          'price': (selMenu!['price'] as int) + extra,
          'qty': 1,
          'meta': metaToSave,
        });
      }
      opts.clear();
      selMenu = null;
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
    if (step == 'store') {
      Navigator.pop(context);
    } else {
      const prev = {'menu': 'store', 'option': 'menu', 'cart': 'menu', 'address': 'cart', 'request': 'address', 'confirm': 'request'};
      setState(() => step = prev[step] ?? 'store');
    }
  }

  String formatPrice(int p) => '${p.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '배달 음식 주문하기',
        points: 30,
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () => Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    final currentOpts = storeOpts[store] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '배달 음식 주문하기', onBack: backFn),
      bottomNavigationBar: step == 'menu'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => setState(() => step = 'cart'),
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
                          cart.isNotEmpty ? '장바구니 보기  (${cart.length}개)' : '장바구니 보기',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
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
              const Text('가게를 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...storeMenus.keys.map((s) => GestureDetector(
                onTap: () => setState(() { store = s; step = 'menu'; }),
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: store == s ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: store == s ? AppColors.primary : AppColors.border, width: 2),
                  ),
                  child: Row(
                    children: [
                      Text(storeIcons[s]!, style: const TextStyle(fontSize: 34)),
                      const SizedBox(width: 16),
                      Text(s, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                    ],
                  ),
                ),
              )),
            ],

            if (step == 'menu') ...[
              Text(store, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...(storeMenus[store] ?? []).map((m) => CustomCard(
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
                            Text(m['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                            const SizedBox(height: 3),
                            Text(formatPrice(m['price'] as int), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selMenu = m;
                          opts.clear();
                          if (['음료', '음료수', '치즈볼'].contains(m['name'])) {
                            addToCart(skipOptions: true);
                          } else {
                            step = 'option';
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: const Text('선택', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )),
            ],

            if (step == 'option' && selMenu != null) ...[
              Text('${selMenu!['name']} 옵션', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 20),
              ...currentOpts.map((group) {
                final label = group['label'] as String;
                final options = group['options'] as List<Map<String, dynamic>>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                      const SizedBox(height: 10),
                      ...options.map((o) {
                        final oName = o['name'] as String;
                        final oPrice = o['price'] as int;
                        return GestureDetector(
                          onTap: () => setState(() => opts[label] = oName),
                          child: Container(
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: opts[label] == oName ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: opts[label] == oName ? AppColors.primary : AppColors.border, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(oName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: opts[label] == oName ? AppColors.primary : AppColors.textMain)),
                                if (oPrice > 0) Text('+${formatPrice(oPrice)}', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
              PrimaryButton(
                text: '장바구니 담기',
                disabled: opts.length < currentOpts.length,
                onPressed: addToCart,
              ),
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
                  Expanded(child: PrimaryButton(text: '더 담기', onPressed: () => setState(() => step = 'menu'), variant: ButtonVariant.outline)),
                  const SizedBox(width: 12),
                  Expanded(child: PrimaryButton(text: '주문하기', disabled: cart.isEmpty, onPressed: () => setState(() => step = 'address'))),
                ],
              ),
            ],

            if (step == 'address') ...[
              const Text('배달 주소를 입력해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
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
              PrimaryButton(text: '다음', onPressed: () => setState(() => step = 'request')),
            ],

            if (step == 'request') ...[
              const Text('요청사항을 선택해주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...reqOpts.map((r) => GestureDetector(
                onTap: () => setState(() => reqSel = reqSel == r ? '' : r),
                child: Container(
                  width: double.infinity,
                  height: 58,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: reqSel == r ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: reqSel == r ? AppColors.primary : AppColors.border, width: 2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(r, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: reqSel == r ? AppColors.primary : AppColors.textMain)),
                ),
              )),
              if (reqSel == '직접 입력')
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: TextInputField(placeholder: '요청사항을 직접 입력해주세요', value: '', onChange: (v) {}),
                ),
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
                    const Text('배달 주소', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                    const SizedBox(height: 8),
                    Text('${addr['name']}  ·  ${addr['phone']}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text('${addr['addr']}  ${addr['detail']}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (reqSel.isNotEmpty)
                CustomCard(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Text('요청사항: $reqSel', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
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
                if (item['meta'] != null) ...[
                  const SizedBox(height: 2),
                  Text(item['meta'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
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
