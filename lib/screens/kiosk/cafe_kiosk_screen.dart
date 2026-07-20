import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/overlay_widgets.dart';
import '../../widgets/bounceable.dart';

class CafeKioskScreen extends StatefulWidget {
  const CafeKioskScreen({super.key});

  @override
  State<CafeKioskScreen> createState() => _CafeKioskScreenState();
}

class _CafeKioskScreenState extends State<CafeKioskScreen> {
  String step = 'store'; // store, menu, cart
  String storeType = '매장';
  
  List<Map<String, dynamic>> cart = [];
  Map<String, dynamic>? pending;
  bool done = false;

  final menus = [
    {'name': '아메리카노', 'price': 3000, 'icon': '☕'},
    {'name': '카페라떼', 'price': 4000, 'icon': '☕'},
    {'name': '바닐라라떼', 'price': 4500, 'icon': '☕'},
    {'name': '초코라떼', 'price': 4500, 'icon': '🍫'},
  ];

  void addTemp(String temp) {
    if (pending == null) return;
    final String key = '${pending!['name']} $temp';
    final existingIdx = cart.indexWhere((i) => i['name'] == key);
    
    setState(() {
      if (existingIdx >= 0) {
        cart[existingIdx]['qty']++;
      } else {
        cart.add({
          'name': key,
          'price': pending!['price'],
          'qty': 1,
          'meta': temp,
        });
      }
      pending = null;
    });
    Navigator.pop(context); // close overlay
  }

  void rm(int i) {
    setState(() => cart.removeAt(i));
  }

  void chQ(int i, int d) {
    setState(() {
      cart[i]['qty'] = (cart[i]['qty'] as int) + d;
      if (cart[i]['qty'] < 1) cart[i]['qty'] = 1;
    });
  }

  void backFn() {
    if (step == 'store') {
      Navigator.pop(context);
    } else {
      setState(() => step = step == 'cart' ? 'menu' : 'store');
    }
  }

  int get cartCount => cart.fold(0, (s, i) => s + (i['qty'] as int));
  int get cartTotal => cart.fold(0, (s, i) => s + (i['price'] as int) * (i['qty'] as int));

  @override
  Widget build(BuildContext context) {
    if (done) {
      return MissionCompleteScreen(
        missionName: '카페 키오스크',
        points: 10,
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        onOther: () => Navigator.pushReplacementNamed(context, '/mission_categories'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '카페 키오스크', onBack: backFn),
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
              const Text(
                '어떻게 드실 건가요?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              const Text(
                '이용 방식을 선택해주세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  _buildStoreTypeBtn('매장', '🏠'),
                  const SizedBox(width: 16),
                  _buildStoreTypeBtn('포장', '📦'),
                ],
              ),
            ],
            
            if (step == 'menu') ...[
              Text('$storeType 주문', style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ...menus.map((m) => _buildMenuItem(m)),
            ],

            if (step == 'cart') ...[
              if (cart.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Text(
                    '장바구니가 비어있습니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                )
              else ...[
                ...cart.asMap().entries.map((e) => _buildCartItem(e.key, e.value)),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('합계', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMain)),
                      Text('${cartTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: '메뉴 더 담기',
                      onPressed: () => setState(() => step = 'menu'),
                      variant: ButtonVariant.outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: '결제하기',
                      disabled: cart.isEmpty,
                      onPressed: () => setState(() => done = true),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoreTypeBtn(String type, String icon) {
    return Expanded(
      child: Bounceable(
        onTap: () => setState(() { storeType = type; step = 'menu'; }),
        child: Container(
          height: 168,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(type, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> m) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
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
                  Text('${(m['price'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}원', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ],
          ),
          Bounceable(
            onTap: () => _showTempOverlay(m),
            child: IgnorePointer(
              ignoring: true,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                ),
                child: const Text('담기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTempOverlay(Map<String, dynamic> m) {
    setState(() => pending = m);
    showCustomOverlay(
      context,
      title: '온도를 선택해주세요',
      child: Column(
        children: [
          Text(m['name'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTempBtn('❄️ ICE', const Color(0xFFEFF6FF), const Color(0xFF93C5FD), const Color(0xFF1D4ED8), 'ICE'),
              const SizedBox(width: 12),
              _buildTempBtn('🔥 HOT', const Color(0xFFFEF2F2), const Color(0xFFFCA5A5), const Color(0xFF991B1B), 'HOT'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () { setState(() => pending = null); Navigator.pop(context); },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('취소', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempBtn(String label, Color bg, Color border, Color text, String val) {
    return Expanded(
      child: Bounceable(
        onTap: () => addTemp(val),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w700)),
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
                Text('${((item['price'] as int) * (item['qty'] as int)).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
          QuantityControl(
            count: item['qty'] as int,
            onDecrement: () => chQ(idx, -1),
            onIncrement: () => chQ(idx, 1),
          ),
          const SizedBox(width: 8),
          Bounceable(
            onTap: () => rm(idx),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.close, size: 15, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
