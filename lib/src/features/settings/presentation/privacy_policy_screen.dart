import 'package:flutter/material.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';

/// 개인정보처리방침 화면
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('개인정보처리방침'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uncany(이하 "서비스")는 개인정보보호법에 따라 이용자의 개인정보 보호 및 권익을 보호하고 개인정보와 관련한 이용자의 고충을 원활하게 처리할 수 있도록 다음과 같은 처리방침을 두고 있습니다.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: TossColors.textSub,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection('제1조 (개인정보의 수집 및 이용 목적)', '''
서비스는 다음의 목적을 위하여 개인정보를 처리합니다.

1. 회원 가입 및 관리
   - 회원 가입의사 확인, 회원자격 유지·관리, 서비스 부정이용 방지

2. 서비스 제공
   - 교실 예약 서비스 제공, 예약 현황 관리

3. 교사 인증
   - 재직증명서를 통한 교사 자격 확인
'''),
            _buildSection('제2조 (수집하는 개인정보 항목)', '''
서비스는 다음의 개인정보 항목을 수집합니다.

1. 필수 항목
   - 이름, 이메일, 학교명, 학년, 반

2. 선택 항목
   - 재직증명서 (교사 인증 목적)

3. 자동 수집 항목
   - 서비스 이용 기록, 접속 로그, 접속 IP 정보
'''),
            _buildSection('제3조 (개인정보의 보유 및 이용 기간)', '''
서비스는 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다.

1. 회원 정보: 회원 탈퇴 시까지
2. 재직증명서: 인증 완료 후 30일 이내 삭제
3. 서비스 이용 기록: 3년 (전자상거래법)
'''),
            _buildSection('제4조 (개인정보의 제3자 제공)', '''
서비스는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다.

다만, 다음의 경우에는 예외로 합니다.
- 이용자가 사전에 동의한 경우
- 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우
'''),
            _buildSection('제5조 (개인정보의 파기)', '''
서비스는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체 없이 해당 개인정보를 파기합니다.

1. 파기 절차
   - 파기 사유가 발생한 개인정보를 선정하고, 개인정보 보호책임자의 승인을 받아 개인정보를 파기합니다.

2. 파기 방법
   - 전자적 파일: 복구 및 재생되지 않도록 안전하게 삭제
   - 종이 문서: 분쇄기로 분쇄하거나 소각
'''),
            _buildSection('제6조 (정보주체의 권리·의무 및 행사방법)', '''
이용자는 개인정보주체로서 다음과 같은 권리를 행사할 수 있습니다.

1. 개인정보 열람 요구
2. 오류 등이 있을 경우 정정 요구
3. 삭제 요구
4. 처리정지 요구

권리 행사는 서비스 내 설정 메뉴 또는 개인정보 보호책임자에게 연락하여 하실 수 있습니다.
'''),
            _buildSection('제7조 (개인정보의 안전성 확보조치)', '''
서비스는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다.

1. 관리적 조치: 내부관리계획 수립·시행, 정기적 직원 교육
2. 기술적 조치: 개인정보처리시스템 등의 접근권한 관리, 접근통제시스템 설치, 고유식별정보 등의 암호화
3. 물리적 조치: 전산실, 자료보관실 등의 접근통제
'''),
            _buildSection('제8조 (개인정보 보호책임자)', '''
서비스는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.

▶ 개인정보 보호책임자
- 성명: [사업자 정보 입력 필요]
- 연락처: [사업자 정보 입력 필요]
- 이메일: [사업자 정보 입력 필요]
'''),
            _buildSection('제9조 (개인정보 처리방침 변경)', '''
이 개인정보처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.
'''),
            _buildSection('제10조 (권익침해 구제방법)', '''
개인정보 침해에 대한 신고나 상담이 필요한 경우 아래 기관에 문의하시기 바랍니다.

- 개인정보침해신고센터 (privacy.kisa.or.kr / 118)
- 대검찰청 사이버수사과 (www.spo.go.kr / 1301)
- 경찰청 사이버안전국 (cyberbureau.police.go.kr / 182)
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
