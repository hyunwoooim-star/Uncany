import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:lottie/lottie.dart';

/// 회원가입 완료 온보딩 화면
///
/// 토스 앱처럼 부드럽고 깔끔한 환영 화면
class OnboardingScreen extends StatefulWidget {
  final String userName;
  final bool needsApproval;

  const OnboardingScreen({
    super.key,
    required this.userName,
    this.needsApproval = true,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 애니메이션 아이콘
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: TossColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.celebration_rounded,
                            size: 64,
                            color: TossColors.primary,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 환영 메시지
                        Text(
                          '환영합니다!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: TossColors.textMain,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // 사용자 이름
                        Text(
                          '${widget.userName} 선생님',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: TossColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // 상태 메시지
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: widget.needsApproval
                                ? TossColors.info.withOpacity(0.1)
                                : TossColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: widget.needsApproval
                                  ? TossColors.info.withOpacity(0.3)
                                  : TossColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                widget.needsApproval
                                    ? Icons.pending_outlined
                                    : Icons.check_circle_outline,
                                size: 48,
                                color: widget.needsApproval
                                    ? TossColors.info
                                    : TossColors.success,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.needsApproval
                                    ? '관리자 승인 대기 중입니다'
                                    : '회원가입이 완료되었습니다',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: TossColors.textMain,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.needsApproval
                                    ? '재직증명서 검토 후 승인됩니다.\n이메일로 결과를 알려드릴게요.'
                                    : 'Uncany의 모든 기능을\n이용하실 수 있습니다.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: TossColors.textSub,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 주요 기능 소개
                        _buildFeatureItem(
                          Icons.event_available,
                          '상담실 예약',
                          '원하는 시간에 간편하게 예약',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          Icons.notifications_active,
                          '실시간 알림',
                          '예약 확정/취소 즉시 알림',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          Icons.history,
                          '예약 관리',
                          '내 예약 내역을 한눈에',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 시작하기 버튼
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TossColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: TossColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: TossColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TossColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: TossColors.textSub,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
