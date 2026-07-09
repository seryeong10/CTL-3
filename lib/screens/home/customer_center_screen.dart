import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_widgets.dart';

class CustomerCenterScreen extends StatefulWidget {
  const CustomerCenterScreen({super.key});

  @override
  State<CustomerCenterScreen> createState() => _CustomerCenterScreenState();
}

class _CustomerCenterScreenState extends State<CustomerCenterScreen> {
  String type = '';
  String title = '';
  String content = '';
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: '고객센터', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: submitted
            ? Container(
                padding: const EdgeInsets.only(top: 64),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Icons.check, size: 38, color: AppColors.success),
                    ),
                    const SizedBox(height: 20),
                    const Text('문의가 등록되었습니다.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                    const SizedBox(height: 8),
                    const Text('빠른 시일 내에 답변 드리겠습니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('문의 유형', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['일반 문의', '서비스 이용 문의', '버그 신고'].map((t) => GestureDetector(
                      onTap: () => setState(() => type = t),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: type == t ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: type == t ? AppColors.primary : AppColors.border, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(t, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: type == t ? AppColors.primary : AppColors.textMain)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('제목', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 7),
                  TextInputField(placeholder: '제목을 입력해주세요', value: title, onChange: (v) => setState(() => title = v)),
                  const SizedBox(height: 20),
                  
                  const Text('내용', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 7),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => content = v),
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(fontSize: 15, color: AppColors.textMain),
                      decoration: const InputDecoration(
                        hintText: '문의 내용을 입력해주세요',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  PrimaryButton(
                    text: '문의 등록',
                    disabled: type.isEmpty || title.isEmpty || content.isEmpty,
                    onPressed: () => setState(() => submitted = true),
                  ),
                ],
              ),
      ),
    );
  }
}
