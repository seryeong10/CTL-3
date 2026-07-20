import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'primary_button.dart';
import '../services/api_service.dart';

class MissionCompleteScreen extends StatefulWidget {
  final String missionName;
  final int points;
  final VoidCallback onHome;
  final VoidCallback onOther;

  const MissionCompleteScreen({
    super.key,
    required this.missionName,
    required this.points,
    required this.onHome,
    required this.onOther,
  });

  @override
  State<MissionCompleteScreen> createState() => _MissionCompleteScreenState();
}

class _MissionCompleteScreenState extends State<MissionCompleteScreen> {
  bool _isLogging = true;

  @override
  void initState() {
    super.initState();
    _saveLogToServer();
  }

  Future<void> _saveLogToServer() async {
    try {
      if (ApiService.currentUserId == null) {
        setState(() {
          _isLogging = false;
        });
        return;
      }

      // 1. DB 미션 목록 조회
      final missions = await ApiService.getMissions();
      Map<String, dynamic>? targetMission;
      for (var m in missions) {
        if (m['title'] == widget.missionName) {
          targetMission = Map<String, dynamic>.from(m);
          break;
        }
      }

      int missionId;
      if (targetMission != null) {
        missionId = targetMission['mission_id'];
      } else {
        // 2. 일치하는 미션이 없을 시 동적으로 생성
        String category = 'sim';
        if (widget.missionName.contains('예약') || widget.missionName.contains('예매')) {
          category = 'book';
        } else if (widget.missionName.contains('조회') || widget.missionName.contains('주문') || widget.missionName.contains('쇼핑')) {
          category = 'order';
        }

        String difficulty = '보통';
        if (widget.points <= 10) {
          difficulty = '쉬움';
        } else if (widget.points >= 30) {
          difficulty = '어려움';
        }

        final newMission = await ApiService.createMission(
          title: widget.missionName,
          category: category,
          difficulty: difficulty,
          rewardPoint: widget.points,
          description: '${widget.missionName} 연습 미션',
        );

        if (newMission != null) {
          missionId = newMission['mission_id'];
        } else {
          throw Exception('미션을 생성할 수 없습니다.');
        }
      }

      // 3. 미션 성공 로그 저장 (포인트도 백엔드에서 자동 적립됨)
      final log = await ApiService.saveMissionLog(
        missionId: missionId,
        status: '성공',
        score: 100,
      );

      if (log == null) {
        throw Exception('성공 로그 저장 실패');
      }
    } catch (e) {
      print('미션 성공 로그 저장 에러: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLogging = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 52, color: AppColors.success),
              ),
              const SizedBox(height: 20),
              const Text(
                '연습 완료!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.missionName} 성공',
                style: const TextStyle(
                  fontSize: 19,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isLogging
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : Text(
                        '+${widget.points}P 획득!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const Spacer(),
              Column(
                children: [
                  PrimaryButton(text: '홈으로', onPressed: widget.onHome),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: '다른 연습하기',
                    onPressed: widget.onOther,
                    variant: ButtonVariant.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showCustomOverlay(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      );
    },
  );
}
