import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:confetti/confetti.dart';

/// 승인 완료 온보딩 화면
///
/// 관리자 승인 완료 후 첫 로그인 시 보여지는 축하 화면
/// 토스 스타일의 화려하고 따뜻한 디자인
class ApprovalCompleteScreen extends StatefulWidget {
  final String userName;

  const ApprovalCompleteScreen({
    super.key,
    required this.userName,
  });

  @override
  State<ApprovalCompleteScreen> createState() => _ApprovalCompleteScreenState();
}

class _ApprovalCompleteScreenState extends State<ApprovalCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _controller.forward();
    // 축하 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      body: Stack(
        children: [
          // Confetti 효과
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57, // 아래로
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 15,
              minBlastForce: 8,
              gravity: 0.3,
              colors: const [
                TossColors.primary,
                TossColors.success,
                TossColors.warning,
                Color(0xFFFF6B9D),
                Color(0xFFC770F0),
              ],
            ),
          ),
          SafeArea(
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
                            // 축하 아이콘 (스케일 애니메이션)
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      TossColors.success,
                                      TossColors.success.withOpacity(0.7),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: TossColors.success.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 축하 메시지
                            Text(
                              '승인이 완료되었습니다!',
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
                                color: TossColors.success,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 32),

                            // 안내 카드
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: TossColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.celebration_rounded,
                                    size: 56,
                                    color: TossColors.primary,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Uncany에 오신 것을 환영합니다!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: TossColors.textMain,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '이제 모든 기능을 자유롭게 이용하실 수 있습니다.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: TossColors.textSub,
                                      height: 1.6,
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
                              '교실 예약',
                              '원하는 시간에 간편하게',
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
                          backgroundColor: TossColors.success,
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
        ],
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
            color: TossColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: TossColors.success,
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
