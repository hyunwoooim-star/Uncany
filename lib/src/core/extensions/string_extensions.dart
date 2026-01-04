/// String 확장 메서드
extension StringExtensions on String {
  /// 첫 글자를 대문자로 변환
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// 각 단어의 첫 글자를 대문자로 변환
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// null 또는 빈 문자열 체크
  bool get isNullOrEmpty => isEmpty;

  /// null이 아니고 빈 문자열이 아닌지 체크
  bool get isNotNullOrEmpty => isNotEmpty;

  /// 공백 제거 후 빈 문자열 체크
  bool get isBlank => trim().isEmpty;

  /// 공백 제거 후 빈 문자열이 아닌지 체크
  bool get isNotBlank => trim().isNotEmpty;

  /// 한글 이니셜 추출 (성+이름 첫 글자)
  /// 예: "홍길동" -> "홍길"
  String getKoreanInitials({int length = 2}) {
    if (isEmpty) return '';
    final trimmed = trim();
    if (trimmed.length <= length) return trimmed;
    return trimmed.substring(0, length);
  }

  /// 이메일 마스킹
  /// 예: "user@example.com" -> "u***@example.com"
  String maskEmail() {
    if (!contains('@')) return this;
    final parts = split('@');
    if (parts[0].length <= 1) return this;

    final masked = parts[0][0] + '*' * (parts[0].length - 1);
    return '$masked@${parts[1]}';
  }

  /// 전화번호 포맷팅
  /// 예: "01012345678" -> "010-1234-5678"
  String formatPhoneNumber() {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return this;

    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
  }

  /// 전화번호 마스킹
  /// 예: "010-1234-5678" -> "010-****-5678"
  String maskPhoneNumber() {
    final formatted = formatPhoneNumber();
    if (!formatted.contains('-')) return this;

    final parts = formatted.split('-');
    if (parts.length != 3) return this;

    return '${parts[0]}-****-${parts[2]}';
  }

  /// 추천 코드 포맷팅 (대시 추가)
  /// 예: "SEOULABC123" -> "SEOUL-ABC123"
  String formatReferralCode() {
    if (length < 7) return this;
    if (contains('-')) return this;

    // 마지막 6자를 분리
    final prefix = substring(0, length - 6);
    final suffix = substring(length - 6);
    return '$prefix-$suffix';
  }

  /// 파일명에서 확장자 추출
  String getFileExtension() {
    if (!contains('.')) return '';
    return split('.').last.toLowerCase();
  }

  /// 파일명에서 이름 부분만 추출 (확장자 제외)
  String getFileNameWithoutExtension() {
    if (!contains('.')) return this;
    return substring(0, lastIndexOf('.'));
  }

  /// 바이트 크기를 사람이 읽기 쉬운 형식으로 변환
  /// 예: "1024" -> "1 KB"
  String formatBytes() {
    final bytes = int.tryParse(this);
    if (bytes == null) return this;

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// URL 검증
  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 이메일 검증
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// 숫자만 포함되어 있는지 검증
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// 한글만 포함되어 있는지 검증
  bool get isKorean {
    return RegExp(r'^[가-힣]+$').hasMatch(this);
  }

  /// 영문만 포함되어 있는지 검증
  bool get isEnglish {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// 영문+숫자만 포함되어 있는지 검증
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// 문자열을 int로 안전하게 파싱
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  /// 문자열을 double로 안전하게 파싱
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  /// 문자열을 DateTime으로 안전하게 파싱
  DateTime? toDateTimeOrNull() {
    return DateTime.tryParse(this);
  }

  /// 문자열 길이 제한 (말줄임표 추가)
  /// 예: "Hello World".ellipsize(8) -> "Hello..."
  String ellipsize(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// 문자열을 특정 길이만큼 자르기 (중간 생략)
  /// 예: "Hello World".truncateMiddle(8) -> "Hel...ld"
  String truncateMiddle(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;

    final sideLength = (maxLength - ellipsis.length) ~/ 2;
    final start = substring(0, sideLength);
    final end = substring(length - sideLength);

    return '$start$ellipsis$end';
  }

  /// 특수문자 제거
  String removeSpecialCharacters() {
    return replaceAll(RegExp(r'[^a-zA-Z0-9가-힣\s]'), '');
  }

  /// HTML 태그 제거
  String stripHtml() {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 연속된 공백을 하나로 변환
  String normalizeWhitespace() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// 검색어 하이라이트용 패턴 매칭
  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }

  /// 여러 검색어 중 하나라도 포함하는지 체크
  bool containsAny(List<String> keywords) {
    return keywords.any((keyword) => containsIgnoreCase(keyword));
  }

  /// 모든 검색어가 포함되어 있는지 체크
  bool containsAll(List<String> keywords) {
    return keywords.every((keyword) => containsIgnoreCase(keyword));
  }
}

/// nullable String 확장 메서드
extension NullableStringExtensions on String? {
  /// null-safe isEmpty
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  /// null-safe isNotEmpty
  bool get isNotNullOrEmpty => this?.isNotEmpty ?? false;

  /// null-safe isBlank (trim 후 체크)
  bool get isNullOrBlank => this?.trim().isEmpty ?? true;

  /// null-safe isNotBlank
  bool get isNotNullOrBlank => this?.trim().isNotEmpty ?? false;

  /// null이면 기본값 반환
  String orDefault(String defaultValue) => this ?? defaultValue;

  /// null이면 빈 문자열 반환
  String get orEmpty => this ?? '';

  /// null이면 '-' 반환
  String get orDash => this ?? '-';
}
