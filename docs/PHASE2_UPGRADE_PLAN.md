# Phase 2 업그레이드 계획

> 서비스 성장에 따른 인증 및 알림 시스템 고도화 방안

---

## 📋 개요

Phase 1에서는 무료 솔루션(Supabase 기본 이메일)으로 시작하며, 서비스 성장에 따라 유료 서비스로 업그레이드할 수 있도록 설계되었습니다.

### Phase 1 (현재 - 무료)
- ✅ 이메일/SMS 수신동의 체크박스
- ✅ 승인/반려 알림 이메일 준비 (Supabase Edge Function 배포 대기)
- ✅ 교육청 이메일 인증
- ✅ 재직증명서 업로드 인증

### Phase 2 (향후 - 유료)
- 🔜 실제 이메일 발송 (SendGrid/AWS SES)
- 🔜 SMS 알림 (알리고/네이버 클라우드)
- 🔜 PASS 인증 연동
- 🔜 커스텀 도메인 이메일 (noreply@uncany.com)

---

## 🎯 업그레이드 시점

다음 조건 중 하나라도 충족되면 업그레이드 고려:

1. **사용자 수**: 월 활성 사용자 100명 이상
2. **이메일 발송량**: 월 1,000건 초과
3. **SMS 필요성**: 사용자 요청 또는 보안 강화 필요 시
4. **PASS 인증 요청**: 교육청 또는 학교에서 공식 인증 요구 시

---

## 📧 Phase 2-A: 이메일 서비스 업그레이드

### 1. Supabase Edge Function (무료 → 저비용)

**장점**:
- Supabase 생태계 통합
- 월 500,000 요청까지 무료
- 코드 수정 최소화

**비용**:
- 무료 티어: 월 500,000 요청
- 초과 시: $0.002/요청

**구현 방법**:

```bash
# 1. Edge Function 생성
cd supabase/functions
supabase functions new send-email

# 2. send-email/index.ts 작성
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { to, subject, body } = await req.json()

  // Resend API 또는 SMTP 사용
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'noreply@uncany.com',
      to: to,
      subject: subject,
      html: body,
    }),
  })

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})

# 3. 배포
supabase functions deploy send-email

# 4. 시크릿 설정
supabase secrets set RESEND_API_KEY=your_key_here
```

**Flutter 코드 활성화**:

```dart
// user_repository.dart의 TODO 주석 해제
await _supabase.functions.invoke('send-email', body: emailData);
```

---

### 2. SendGrid (유료 - 안정적)

**장점**:
- 높은 전송률 (99%+)
- 월 100건 무료
- 상세한 분석 대시보드
- 템플릿 관리 UI

**비용**:
- 무료: 월 100건
- Essentials: $19.95/월 (월 50,000건)
- Pro: $89.95/월 (월 100,000건)

**구현 방법**:

1. **SendGrid 가입 및 API 키 발급**
   - https://sendgrid.com 회원가입
   - Settings → API Keys → Create API Key

2. **pubspec.yaml에 추가**
   ```yaml
   dependencies:
     http: ^1.2.0  # 이미 있음
   ```

3. **EmailService 클래스 생성**
   ```dart
   // lib/src/core/services/email_service.dart
   import 'package:http/http.dart' as http;
   import 'dart:convert';

   class EmailService {
     static const _apiKey = String.fromEnvironment('SENDGRID_API_KEY');
     static const _fromEmail = 'noreply@uncany.com';

     static Future<void> sendEmail({
       required String to,
       required String subject,
       required String body,
     }) async {
       if (_apiKey.isEmpty) {
         throw Exception('SENDGRID_API_KEY not configured');
       }

       final response = await http.post(
         Uri.parse('https://api.sendgrid.com/v3/mail/send'),
         headers: {
           'Authorization': 'Bearer $_apiKey',
           'Content-Type': 'application/json',
         },
         body: jsonEncode({
           'personalizations': [
             {'to': [{'email': to}]}
           ],
           'from': {'email': _fromEmail},
           'subject': subject,
           'content': [
             {'type': 'text/html', 'value': body}
           ],
         }),
       );

       if (response.statusCode != 202) {
         throw Exception('SendGrid API error: ${response.body}');
       }
     }
   }
   ```

4. **user_repository.dart 수정**
   ```dart
   // TODO 주석 부분을
   await EmailService.sendEmail(
     to: email,
     subject: emailData['subject'],
     body: emailData['body'],
   );
   ```

5. **GitHub Actions에 API 키 추가**
   ```yaml
   # .github/workflows/deploy-web-staging.yml
   env:
     SENDGRID_API_KEY: ${{ secrets.SENDGRID_API_KEY }}
   run: |
     flutter build web \
       --dart-define=SENDGRID_API_KEY=$SENDGRID_API_KEY
   ```

---

### 3. AWS SES (대용량 - 가장 저렴)

**장점**:
- 월 1,000건 무료 (EC2 호스팅 시 월 62,000건)
- 이후 $0.10/1,000건 (가장 저렴)
- AWS 생태계 통합

**비용**:
- 무료: 월 1,000건
- 유료: $0.10/1,000건 + $0.12/GB (첨부파일)

**구현 방법**:

1. **AWS SES 설정**
   - AWS Console → SES → Verified identities
   - 도메인 인증 (uncany.com)
   - DKIM/SPF 레코드 설정

2. **AWS SDK 설치**
   ```yaml
   dependencies:
     aws_ses_api: ^1.0.0
   ```

3. **EmailService 클래스 수정**
   ```dart
   import 'package:aws_ses_api/ses-2010-12-01.dart';

   class EmailService {
     static late SES _ses;

     static void initialize() {
       _ses = SES(
         region: 'ap-northeast-2',  // 서울 리전
         credentials: AwsClientCredentials(
           accessKey: const String.fromEnvironment('AWS_ACCESS_KEY'),
           secretKey: const String.fromEnvironment('AWS_SECRET_KEY'),
         ),
       );
     }

     static Future<void> sendEmail({
       required String to,
       required String subject,
       required String body,
     }) async {
       await _ses.sendEmail(
         source: 'noreply@uncany.com',
         destination: Destination(toAddresses: [to]),
         message: Message(
           subject: Content(data: subject),
           body: Body(html: Content(data: body)),
         ),
       );
     }
   }
   ```

---

## 📱 Phase 2-B: SMS 알림 추가

### 사용 케이스
- 비밀번호 재설정 (이메일 + SMS 선택)
- 2단계 인증 (OTP)
- 중요 알림 (승인/반려)

### 추천 서비스 비교

| 서비스 | 비용 | 장점 | 단점 |
|--------|------|------|------|
| **알리고** | 13원/건 | 간편한 API, 한국 특화 | 선불 충전 필요 |
| **네이버 클라우드** | 12원/건 | 대량 할인, 안정적 | 초기 설정 복잡 |
| **NHN Cloud** | 13원/건 | 토스트 연동 쉬움 | 최소 충전 5만원 |

### 추천: 알리고 (Aligo)

**비용**:
- 충전 최소: 5,000원 (약 385건)
- 단가: 13원/건 (SMS), 45원/건 (LMS)

**구현 방법**:

1. **알리고 가입 및 설정**
   - https://smartsms.aligo.in 회원가입
   - 발신번호 등록 (사업자 정보 필요)
   - API Key 발급

2. **pubspec.yaml에 추가**
   ```yaml
   dependencies:
     http: ^1.2.0
   ```

3. **SmsService 클래스 생성**
   ```dart
   // lib/src/core/services/sms_service.dart
   import 'package:http/http.dart' as http;
   import 'dart:convert';

   class SmsService {
     static const _userId = String.fromEnvironment('ALIGO_USER_ID');
     static const _apiKey = String.fromEnvironment('ALIGO_API_KEY');
     static const _sender = String.fromEnvironment('ALIGO_SENDER'); // 발신번호

     static Future<void> sendSMS({
       required String to,
       required String message,
     }) async {
       if (_userId.isEmpty || _apiKey.isEmpty) {
         throw Exception('Aligo credentials not configured');
       }

       final response = await http.post(
         Uri.parse('https://apis.aligo.in/send/'),
         body: {
           'key': _apiKey,
           'user_id': _userId,
           'sender': _sender,
           'receiver': to.replaceAll('-', ''), // 010-1234-5678 → 01012345678
           'msg': message,
           'msg_type': 'SMS',  // SMS(90바이트) 또는 LMS(2000바이트)
         },
       );

       final result = jsonDecode(response.body);
       if (result['result_code'] != '1') {
         throw Exception('SMS 발송 실패: ${result['message']}');
       }
     }
   }
   ```

4. **auth_repository.dart에 SMS 추가**
   ```dart
   // 비밀번호 재설정 시 SMS도 발송
   Future<void> resetPassword(String email, {String? phoneNumber}) async {
     // 이메일 발송
     await _supabase.auth.resetPasswordForEmail(email, ...);

     // SMS 발송 (선택사항)
     if (phoneNumber != null) {
       await SmsService.sendSMS(
         to: phoneNumber,
         message: '[Uncany] 비밀번호 재설정 링크가 이메일로 발송되었습니다.',
       );
     }
   }
   ```

5. **회원가입 시 전화번호 수집**
   ```dart
   // signup_screen.dart에 전화번호 필드 추가
   final _phoneController = TextEditingController();

   TextFormField(
     controller: _phoneController,
     decoration: InputDecoration(
       labelText: '휴대전화 (선택)',
       hintText: '010-1234-5678',
       helperText: 'SMS 알림을 받으려면 입력하세요',
     ),
     keyboardType: TextInputType.phone,
   )
   ```

---

## 🔐 Phase 2-C: PASS 인증 연동

### 개요
PASS(간편인증)는 NICE 평가정보에서 제공하는 본인인증 서비스로, 주민등록번호 없이 안전하게 본인을 확인할 수 있습니다.

### 사용 케이스
- 회원가입 시 본인 확인 (재직증명서 대체)
- 고위험 작업 시 추가 인증 (관리자 권한 변경 등)

### 비용
- **NICE 평가정보**: 300-500원/건
- 월 최소 계약: 보통 10만원 (약 200-300건)

### 구현 방법

1. **NICE 평가정보 계약**
   - https://www.nicepass.co.kr 문의
   - 사업자등록증 필요
   - 서비스 ID 및 암호화 키 발급

2. **flutter_nicepass 패키지 사용** (비공식)
   ```yaml
   dependencies:
     webview_flutter: ^4.0.0  # PASS 인증 웹뷰용
   ```

3. **PassAuthService 클래스 생성**
   ```dart
   // lib/src/core/services/pass_auth_service.dart
   import 'package:crypto/crypto.dart';
   import 'dart:convert';

   class PassAuthService {
     static const _siteCode = String.fromEnvironment('NICE_SITE_CODE');
     static const _sitePassword = String.fromEnvironment('NICE_SITE_PASSWORD');

     /// PASS 인증 요청 데이터 생성
     static Map<String, String> generateAuthRequest() {
       final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
       final authToken = _generateAuthToken(timestamp);

       return {
         'm': 'service',  // 인증 서비스
         'token_version_id': 'VER_01',
         'enc_data': authToken,
         'integrity_value': _generateIntegrityValue(authToken),
       };
     }

     static String _generateAuthToken(String timestamp) {
       // NICE PASS 암호화 로직
       // (실제로는 AES-128-CBC 암호화 필요)
       final data = {
         'requestno': timestamp,
         'sitecode': _siteCode,
         'returnurl': 'https://uncany.com/auth/pass-callback',
       };
       return base64Encode(utf8.encode(jsonEncode(data)));
     }

     static String _generateIntegrityValue(String encData) {
       final bytes = utf8.encode(encData + _sitePassword);
       return sha256.convert(bytes).toString();
     }
   }
   ```

4. **PassAuthScreen 생성**
   ```dart
   // lib/src/features/auth/presentation/pass_auth_screen.dart
   import 'package:webview_flutter/webview_flutter.dart';

   class PassAuthScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       final authData = PassAuthService.generateAuthRequest();

       return Scaffold(
         appBar: AppBar(title: Text('PASS 본인인증')),
         body: WebView(
           initialUrl: 'https://cert.vno.co.kr/ipin.cb',
           javascriptMode: JavascriptMode.unrestricted,
           onWebViewCreated: (controller) {
             // POST 요청으로 인증 시작
             controller.loadUrl(
               'https://cert.vno.co.kr/ipin.cb',
               headers: authData,
             );
           },
           navigationDelegate: (request) {
             if (request.url.startsWith('https://uncany.com/auth/pass-callback')) {
               // 인증 결과 파싱
               _handlePassResult(request.url);
               return NavigationDecision.prevent;
             }
             return NavigationDecision.navigate;
           },
         ),
       );
     }

     void _handlePassResult(String url) {
       final uri = Uri.parse(url);
       final encData = uri.queryParameters['enc_data'];

       // 복호화하여 이름, 생년월일, CI 값 추출
       // users 테이블에 CI 값 저장하여 중복 가입 방지
     }
   }
   ```

5. **회원가입 시 PASS 인증 옵션 추가**
   ```dart
   // signup_screen.dart
   ElevatedButton(
     onPressed: () {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => PassAuthScreen()),
       );
     },
     child: Text('PASS 인증으로 간편 가입'),
   )
   ```

---

## 🌐 Phase 2-D: 커스텀 도메인 이메일

### 목적
`noreply@gmail.com` 대신 `noreply@uncany.com`으로 발송하여 신뢰도 향상

### 필요 조건
1. **도메인 구매**: uncany.com (연 15,000원)
2. **도메인 인증**: DKIM, SPF, DMARC 레코드 설정
3. **이메일 서비스**: SendGrid/AWS SES에 도메인 등록

### 구현 방법

1. **도메인 구매** (가비아, Cloudflare 등)
   - uncany.com 구매
   - DNS 관리 콘솔 접근

2. **SendGrid 도메인 인증**
   - SendGrid → Settings → Sender Authentication
   - Domain Authentication 선택
   - DNS 레코드 추가 (CNAME 3개)
     ```
     s1._domainkey.uncany.com → s1.domainkey.u12345678.wl123.sendgrid.net
     s2._domainkey.uncany.com → s2.domainkey.u12345678.wl123.sendgrid.net
     em1234.uncany.com → u12345678.wl123.sendgrid.net
     ```

3. **SPF/DMARC 레코드 추가**
   ```
   TXT @ v=spf1 include:sendgrid.net ~all
   TXT _dmarc v=DMARC1; p=none; rua=mailto:dmarc@uncany.com
   ```

4. **코드 수정**
   ```dart
   // EmailService 클래스에서 from 주소 변경
   static const _fromEmail = 'noreply@uncany.com';
   static const _fromName = 'Uncany 팀';
   ```

---

## 📊 비용 예상 (월 1,000명 기준)

### 이메일 발송 (월 3,000건 가정)
- Supabase Edge Function: **무료** (50만건까지)
- SendGrid Essentials: **$19.95** (5만건까지)
- AWS SES: **$0.20** (1,000건 이후)

### SMS 발송 (월 500건 가정)
- 알리고: **6,500원** (13원 × 500건)
- 네이버 클라우드: **6,000원** (12원 × 500건)

### PASS 인증 (월 100건 가정)
- NICE 평가정보: **40,000원** (400원 × 100건)

### 도메인
- uncany.com: **15,000원/년** (월 1,250원)

### 총 예상 비용
- **최소 (Supabase + 도메인)**: 월 **1,250원**
- **중간 (AWS SES + SMS)**: 월 **6,720원**
- **풀 스택 (모두 포함)**: 월 **46,970원**

---

## 🚀 단계별 업그레이드 로드맵

### Step 1: 도메인 + Supabase Edge Function (무료)
- [ ] uncany.com 도메인 구매
- [ ] Supabase Edge Function으로 이메일 발송
- [ ] 커스텀 도메인 이메일 설정

### Step 2: SMS 추가 (월 6,000원)
- [ ] 알리고 가입 및 발신번호 등록
- [ ] 회원가입 시 전화번호 수집
- [ ] 중요 알림 SMS 발송

### Step 3: SendGrid/AWS SES 업그레이드 (선택)
- [ ] 발송량 증가 시 AWS SES로 전환
- [ ] 이메일 템플릿 디자인 개선
- [ ] 오픈률/클릭률 분석

### Step 4: PASS 인증 (월 40,000원+)
- [ ] NICE 평가정보 계약
- [ ] PASS 인증 화면 구현
- [ ] 재직증명서 인증을 PASS로 대체

---

## 📝 결론

**Phase 1 (현재)**:
- 무료로 시작 가능
- 이메일/SMS 수신동의 체크박스 준비 완료
- Supabase Edge Function 배포 시 즉시 이메일 발송 가능

**Phase 2 권장 시점**:
- 사용자 100명 이상: 도메인 + Edge Function
- 사용자 500명 이상: SMS 추가
- 사용자 1,000명 이상: SendGrid/AWS SES 고려
- 공식 서비스 시: PASS 인증 검토

**업그레이드 시 작업량**:
- 각 단계마다 1-2일 개발
- 코드 수정 최소화 (TODO 주석 해제 수준)
- 단계적 업그레이드 가능

---

**작성일**: 2026-01-12
**문서 버전**: 1.0
