import 'package:flutter/material.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';

/// 사업자 정보 화면
///
/// 전자상거래법에 따른 통신판매업자 정보 표시
class BusinessInfoScreen extends StatelessWidget {
  const BusinessInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('사업자 정보'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 서비스 로고/이름
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TossColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: TossColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Uncany',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TossColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '학교 교실 예약 서비스',
                    style: TextStyle(
                      fontSize: 14,
                      color: TossColors.textSub,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 사업자 정보 (placeholder)
            const Text(
              '사업자 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoCard([
              _InfoItem(
                label: '상호',
                // TODO: 실제 사업자 정보로 변경
                value: '[사업자 정보 입력 필요]',
              ),
              _InfoItem(
                label: '대표자',
                value: '[사업자 정보 입력 필요]',
              ),
              _InfoItem(
                label: '사업자등록번호',
                value: '[000-00-00000]',
              ),
              _InfoItem(
                label: '통신판매업 신고번호',
                value: '[제0000-서울강남-00000호]',
              ),
            ]),

            const SizedBox(height: 24),

            const Text(
              '연락처',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoCard([
              _InfoItem(
                label: '소재지',
                value: '[사업자 주소 입력 필요]',
              ),
              _InfoItem(
                label: '이메일',
                value: '[이메일 입력 필요]',
              ),
              _InfoItem(
                label: '전화번호',
                value: '[전화번호 입력 필요]',
              ),
            ]),

            const SizedBox(height: 32),

            // 안내문구
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TossColors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: TossColors.textSub,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '본 서비스는 전자상거래 등에서의 소비자보호에 관한 법률에 따라 운영됩니다. '
                      '서비스 이용 중 불편사항이나 문의사항이 있으시면 위 연락처로 문의해주세요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: TossColors.textSub,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TossColors.divider),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (index > 0) const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: TossColors.textSub,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: TossColors.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });
}
