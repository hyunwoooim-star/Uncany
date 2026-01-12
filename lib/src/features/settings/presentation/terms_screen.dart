import 'package:flutter/material.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';

/// 이용약관 화면
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('이용약관'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('제1조 (목적)', '''
본 약관은 Uncany(이하 "서비스")가 제공하는 교실 예약 서비스의 이용조건 및 절차, 회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.
'''),
            _buildSection('제2조 (정의)', '''
1. "서비스"란 회사가 제공하는 교실 예약 관련 제반 서비스를 의미합니다.
2. "회원"이란 본 약관에 동의하고 서비스 이용 자격을 부여받은 자를 말합니다.
3. "교사"란 학교에 재직 중인 것이 확인된 회원을 말합니다.
4. "관리자"란 서비스 운영 권한을 가진 회원을 말합니다.
'''),
            _buildSection('제3조 (약관의 효력 및 변경)', '''
1. 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 회원에게 공지함으로써 효력이 발생합니다.
2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본 약관을 변경할 수 있습니다.
3. 변경된 약관은 공지사항을 통해 공지하며, 공지 후 7일 이내에 거부의사를 표시하지 않으면 동의한 것으로 간주합니다.
'''),
            _buildSection('제4조 (이용계약의 체결)', '''
1. 이용계약은 회원이 되고자 하는 자가 약관의 내용에 동의한 후 회원가입 신청을 하고, 회사가 이를 승낙함으로써 체결됩니다.
2. 회사는 다음 각 호에 해당하는 신청에 대해서는 승낙을 하지 않거나 사후에 이용계약을 해지할 수 있습니다.
   - 실명이 아니거나 타인의 정보를 이용한 경우
   - 허위의 정보를 기재하거나, 필수 정보를 기재하지 않은 경우
   - 교사 자격이 확인되지 않는 경우
'''),
            _buildSection('제5조 (서비스의 제공)', '''
1. 회사는 다음과 같은 서비스를 제공합니다.
   - 교실 예약 서비스
   - 예약 현황 조회 서비스
   - 기타 회사가 정하는 서비스

2. 서비스는 연중무휴 24시간 제공을 원칙으로 합니다. 다만, 시스템 점검 등의 사유로 일시 중단될 수 있습니다.
'''),
            _buildSection('제6조 (회원의 의무)', '''
1. 회원은 다음 행위를 하여서는 안 됩니다.
   - 타인의 정보 도용
   - 서비스 운영 방해
   - 허위 정보 등록
   - 다른 회원에 대한 비방, 명예훼손

2. 회원은 관계 법령, 본 약관의 규정, 이용안내 및 서비스와 관련하여 공지한 주의사항을 준수하여야 합니다.
'''),
            _buildSection('제7조 (서비스 제공자의 의무)', '''
1. 회사는 관련 법령과 본 약관이 금지하거나 공서양속에 반하는 행위를 하지 않습니다.
2. 회사는 계속적이고 안정적인 서비스의 제공을 위해 최선을 다합니다.
3. 회사는 회원의 개인정보를 보호하기 위해 보안시스템을 구축하며 개인정보처리방침을 준수합니다.
'''),
            _buildSection('제8조 (계약 해지 및 이용 제한)', '''
1. 회원은 언제든지 서비스 내 설정 메뉴를 통해 이용계약 해지를 신청할 수 있습니다.
2. 회사는 회원이 본 약관을 위반한 경우 서비스 이용을 제한하거나 이용계약을 해지할 수 있습니다.
'''),
            _buildSection('제9조 (손해배상)', '''
1. 회사는 무료로 제공되는 서비스와 관련하여 회원에게 발생한 손해에 대해서는 책임을 지지 않습니다.
2. 회원이 본 약관을 위반하여 회사에 손해가 발생한 경우, 해당 회원은 회사에 그 손해를 배상하여야 합니다.
'''),
            _buildSection('제10조 (분쟁 해결)', '''
1. 회사와 회원 간에 발생한 분쟁에 관한 소송은 회사의 본사 소재지를 관할하는 법원을 합의관할로 합니다.
2. 회사와 회원 간에 제기된 소송에는 대한민국 법을 적용합니다.
'''),
            const SizedBox(height: 20),
            Text(
              '시행일: 2026년 1월 1일',
              style: TextStyle(
                color: TossColors.textSub,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TossColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: TossColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}
