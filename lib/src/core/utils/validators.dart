/// 입력 검증 유틸리티
class Validators {
  Validators._();

  /// 이메일 검증 정규식
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// 한국 휴대폰 번호 정규식 (010-XXXX-XXXX 또는 01012345678)
  static final _phoneRegex = RegExp(
    r'^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$',
  );

  /// 비밀번호 정규식 (최소 8자, 영문+숫자 포함)
  static final _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  /// 이메일 유효성 검증
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }

  /// 교육청 이메일 검증
  /// @xxx.go.kr 또는 @xxx.kr (교육청 도메인)
  static bool isEducationOfficeEmail(String? email) {
    if (!isValidEmail(email)) return false;

    final domain = email!.split('@').last.toLowerCase();

    // 교육청 도메인 목록
    final educationDomains = [
      'sen.go.kr', // 서울특별시교육청
      'goe.go.kr', // 경기도교육청
      'ice.go.kr', // 인천광역시교육청
      'pen.go.kr', // 부산광역시교육청
      'dge.go.kr', // 대구광역시교육청
      'gen.go.kr', // 광주광역시교육청
      'dje.go.kr', // 대전광역시교육청
      'use.go.kr', // 울산광역시교육청
      'sje.go.kr', // 세종특별자치시교육청
      'gwe.go.kr', // 강원특별자치도교육청
      'cbe.go.kr', // 충청북도교육청
      'cne.go.kr', // 충청남도교육청
      'jbe.go.kr', // 전북특별자치도교육청
      'jne.go.kr', // 전라남도교육청
      'gbe.go.kr', // 경상북도교육청
      'gne.go.kr', // 경상남도교육청
      'jje.go.kr', // 제주특별자치도교육청
    ];

    return educationDomains.any((d) => domain.endsWith(d));
  }

  /// 비밀번호 유효성 검증
  /// 최소 8자, 영문+숫자 포함
  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    return _passwordRegex.hasMatch(password);
  }

  /// 비밀번호 강도 검사 (0-3)
  /// 0: 매우 약함, 1: 약함, 2: 보통, 3: 강함
  static int getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) return 0;

    int strength = 0;

    // 길이 체크
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // 문자 종류 체크
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    // 최대 3
    return strength.clamp(0, 3);
  }

  /// 휴대폰 번호 유효성 검증
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    return _phoneRegex.hasMatch(phone);
  }

  /// 빈 문자열 검증
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// 최소 길이 검증
  static bool hasMinLength(String? value, int minLength) {
    if (value == null) return false;
    return value.length >= minLength;
  }

  /// 최대 길이 검증
  static bool hasMaxLength(String? value, int maxLength) {
    if (value == null) return true; // null은 통과
    return value.length <= maxLength;
  }

  /// 숫자만 포함 검증
  static bool isNumericOnly(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(value);
  }

  /// 양수 검증
  static bool isPositiveNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    final number = int.tryParse(value);
    return number != null && number > 0;
  }

  /// URL 검증
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 파일 확장자 검증
  static bool hasValidExtension(String filename, List<String> allowedExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// 이미지 파일 확장자 검증
  static bool isImageFile(String filename) {
    return hasValidExtension(filename, ['jpg', 'jpeg', 'png', 'gif', 'webp']);
  }

  /// 문서 파일 확장자 검증
  static bool isDocumentFile(String filename) {
    return hasValidExtension(filename, ['pdf', 'doc', 'docx', 'txt']);
  }

  /// 날짜 범위 검증
  static bool isDateInRange(
    DateTime date,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate != null && date.isBefore(startDate)) {
      return false;
    }
    if (endDate != null && date.isAfter(endDate)) {
      return false;
    }
    return true;
  }

  /// 미래 날짜 검증
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// 과거 날짜 검증
  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// 학교 이름 검증 (한글 포함 필수)
  static bool isValidSchoolName(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    // 한글이 포함되어 있는지 확인
    return RegExp(r'[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]').hasMatch(name);
  }

  /// 이름 검증 (한글 2-10자)
  static bool isValidKoreanName(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    final trimmed = name.trim();
    // 한글만, 2-10자
    return RegExp(r'^[가-힣]{2,10}$').hasMatch(trimmed);
  }

  /// 추천인 코드 형식 검증 (예: SEOUL-ABC123)
  static bool isValidReferralCodeFormat(String? code) {
    if (code == null || code.isEmpty) return false;
    // 학교명-XXXXXX 형식
    return RegExp(r'^[A-Z가-힣]+-[A-Z0-9]{6}$').hasMatch(code);
  }

  /// 교실 이름 검증
  static bool isValidClassroomName(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    // 최소 2자, 최대 50자
    final trimmed = name.trim();
    return trimmed.length >= 2 && trimmed.length <= 50;
  }

  /// 예약 시간 검증 (종료 시간이 시작 시간보다 늦은지)
  static bool isValidTimeRange(DateTime start, DateTime end) {
    return end.isAfter(start);
  }

  /// 예약 시간 검증 (과거 시간이 아닌지)
  static bool isValidReservationTime(DateTime start) {
    return start.isAfter(DateTime.now());
  }

  /// 예약 기간 검증 (최소/최대 기간)
  static bool isValidReservationDuration(
    DateTime start,
    DateTime end, {
    int minMinutes = 30,
    int maxMinutes = 480, // 8시간
  }) {
    final duration = end.difference(start).inMinutes;
    return duration >= minMinutes && duration <= maxMinutes;
  }
}
