import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String search = '';

  List<Map<String, dynamic>> stores = [
    {'name': '행복카페', 'type': '카페', 'addr': '충청북도 청주시 ○○구 ○○로 12', 'hours': '09:00 ~ 21:00', 'pin': const Alignment(-0.44, -0.16)},
    {'name': '우리분식', 'type': '음식점', 'addr': '충청북도 청주시 ○○구 ○○로 25', 'hours': '10:00 ~ 20:00', 'pin': const Alignment(0.12, 0.12)},
    {'name': '동네마트', 'type': '마트', 'addr': '충청북도 청주시 ○○구 ○○로 40', 'hours': '09:00 ~ 22:00', 'pin': const Alignment(0.44, -0.4)},
  ];

  @override
  void initState() {
    super.initState();
    _loadMerchants();
  }

  Future<void> _loadMerchants() async {
    try {
      final merchants = await ApiService.getMerchants();
      final List<Map<String, dynamic>> loadedStores = List<Map<String, dynamic>>.from(stores);
      
      // Assign default IDs to static local stores if they are not already set
      for (var s in loadedStores) {
        if (s['merchant_id'] == null) {
          s['merchant_id'] = s['name'] == '우리분식' ? 2 : s['name'] == '동네마트' ? 3 : 1;
        }
      }
      
      int i = 0;
      final alignments = [
        const Alignment(-0.6, 0.4),
        const Alignment(0.5, 0.6),
        const Alignment(-0.2, -0.6),
        const Alignment(0.8, -0.1),
      ];
      
      for (var m in merchants) {
        final name = m['store_name'] as String?;
        final addr = m['address'] as String?;
        final id = m['merchant_id'] as int?;
        if (name == null) continue;
        
        final existingIdx = loadedStores.indexWhere((s) => s['name'] == name);
        if (existingIdx >= 0) {
          loadedStores[existingIdx]['merchant_id'] = id;
          if (addr != null) loadedStores[existingIdx]['addr'] = addr;
        } else {
          loadedStores.add({
            'merchant_id': id,
            'name': name,
            'type': '가맹점',
            'addr': addr ?? '청주시 가맹점',
            'hours': '09:00 ~ 21:00',
            'pin': alignments[i % alignments.length],
          });
          i++;
        }
      }
      
      if (mounted) {
        setState(() {
          stores = loadedStores;
        });
      }
    } catch (e) {
      print('가맹점 로드 실패: $e');
    }
  }

  Future<void> _handlePointPayment(Map<String, dynamic> store) async {
    final amountController = TextEditingController(text: '1000');
    final storeName = store['name'] as String;
    final int merchantId = store['merchant_id'] ?? (storeName == '우리분식' ? 2 : storeName == '동네마트' ? 3 : 1);

    int balance = 0;
    try {
      final wallet = await ApiService.getMyWallet();
      if (wallet != null) {
        balance = wallet['balance'] ?? 0;
      }
    } catch (e) {
      print('지갑 조회 실패: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('$storeName 포인트 결제', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('현재 보유 포인트: ${balance.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}P',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              const SizedBox(height: 14),
              const Text('결제할 포인트를 입력하세요 (P):', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '금액 입력',
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
                    const SnackBar(content: Text('유효한 포인트를 입력해 주세요.')),
                  );
                  return;
                }
                if (amount > balance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('잔액이 부족합니다.')),
                  );
                  return;
                }

                try {
                  Navigator.pop(context); // close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('결제 진행 중...')),
                  );

                  await ApiService.payAtMerchant(
                    merchantId: merchantId,
                    amount: amount,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$storeName에서 ${amount}P가 차감되었습니다.')),
                    );
                  }
                } catch (e) {
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
  }

  @override
  Widget build(BuildContext context) {
    final filtered = stores.where((s) => search.isEmpty || (s['name'] as String).contains(search) || (s['type'] as String).contains(search)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '지도', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('포인트 사용 가능 매장', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Stack(
                children: [
                  TextInputField(
                    placeholder: '매장명을 검색해보세요',
                    value: search,
                    onChange: (v) => setState(() => search = v),
                  ),
                  const Positioned(
                    right: 14,
                    top: 16,
                    child: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            
            // Map placeholder
            Container(
              height: 220,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                image: const DecorationImage(
                  image: NetworkImage('map_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                ),
              ),
              child: Stack(
                children: [
                  // Pins
                  ...stores.map((s) {
                    final align = s['pin'] as Alignment;
                    return Align(
                      alignment: align,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Text(s['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const Text('사용 가능처 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
            const SizedBox(height: 12),
            ...filtered.map((s) => CustomCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(s['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                              child: Text(s['type'] as String, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text('📍 ${s['addr']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text('🕐 ${s['hours']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handlePointPayment(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                      child: const Text('포인트 사용', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
