import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String search = '';

  final stores = [
    {'name': '행복카페', 'type': '카페', 'addr': '충청북도 청주시 ○○구 ○○로 12', 'hours': '09:00 ~ 21:00', 'pin': const Alignment(-0.44, -0.16)},
    {'name': '우리분식', 'type': '음식점', 'addr': '충청북도 청주시 ○○구 ○○로 25', 'hours': '10:00 ~ 20:00', 'pin': const Alignment(0.12, 0.12)},
    {'name': '동네마트', 'type': '마트', 'addr': '충청북도 청주시 ○○구 ○○로 40', 'hours': '09:00 ~ 22:00', 'pin': const Alignment(0.44, -0.4)},
  ];

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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                    child: const Text('포인트 사용', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
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
