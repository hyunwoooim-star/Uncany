/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  /// 앱 이름
  static const String appName = 'Uncany';

  /// 앱 버전
  static const String appVersion = '1.0.0';

  /// 앱 빌드 번호
  static const int buildNumber = 1;

  /// Deep Link 스킴
  static const String deepLinkScheme = 'uncany';

  /// 비밀번호 재설정 Deep Link (모바일용)
  static const String resetPasswordDeepLink = '$deepLinkScheme://reset-password';

  /// 이메일 인증 Deep Link (모바일용)
  static const String verifyEmailDeepLink = '$deepLinkScheme://verify-email';

  /// 웹 기본 URL (개발 환경)
  static const String webBaseUrlDev = 'http://localhost:3000';

  /// 웹 기본 URL (프로덕션 환경) - 배포 시 변경 필요
  static const String webBaseUrlProd = 'https://your-domain.com';

  /// 비밀번호 재설정 웹 URL
  static String get webResetPasswordUrl {
    // TODO: 프로덕션 환경 구분 로직 추가 (kReleaseMode 사용)
    const baseUrl = webBaseUrlDev;
    return '$baseUrl/auth/reset-password';
  }
}

/// 예약 관련 상수
class ReservationConstants {
  ReservationConstants._();

  /// 최소 예약 기간 (분)
  static const int minDurationMinutes = 30;

  /// 최대 예약 기간 (분)
  static const int maxDurationMinutes = 480; // 8시간

  /// 기본 예약 기간 (분)
  static const int defaultDurationMinutes = 60;

  /// 시간표 시작 시간 (시)
  static const int timetableStartHour = 8;

  /// 시간표 종료 시간 (시)
  static const int timetableEndHour = 18;

  /// 예약 가능한 최대 미래 일수
  static const int maxFutureDays = 90;

  /// 당일 예약 가능한 최소 시간 (분)
  static const int minAdvanceMinutes = 30;
}

/// 추천인 코드 관련 상수
class ReferralCodeConstants {
  ReferralCodeConstants._();

  /// 코드 최소 사용 횟수
  static const int minUses = 1;

  /// 코드 최대 사용 횟수
  static const int maxUses = 10;

  /// 코드 기본 사용 횟수
  static const int defaultUses = 5;

  /// 코드 최소 만료 일수
  static const int minExpiryDays = 7;

  /// 코드 최대 만료 일수
  static const int maxExpiryDays = 365;

  /// 코드 기본 만료 일수
  static const int defaultExpiryDays = 30;

  /// 코드 만료 옵션 (일)
  static const List<int> expiryOptions = [7, 30, 90];

  /// 추천 코드 길이 (학교명 제외)
  static const int codeLength = 6;
}

/// 교실 관련 상수
class ClassroomConstants {
  ClassroomConstants._();

  /// 최소 수용 인원
  static const int minCapacity = 1;

  /// 최대 수용 인원
  static const int maxCapacity = 100;

  /// 기본 수용 인원
  static const int defaultCapacity = 30;

  /// 교실 이름 최소 길이
  static const int minNameLength = 2;

  /// 교실 이름 최대 길이
  static const int maxNameLength = 50;

  /// 위치 설명 최대 길이
  static const int maxLocationLength = 100;

  /// 공지사항 최대 길이
  static const int maxNoticeLength = 500;

  /// 비밀번호 최소 길이
  static const int minPasswordLength = 4;

  /// 비밀번호 최대 길이
  static const int maxPasswordLength = 20;
}

/// 사용자 관련 상수
class UserConstants {
  UserConstants._();

  /// 이름 최소 길이 (한글)
  static const int minNameLength = 2;

  /// 이름 최대 길이 (한글)
  static const int maxNameLength = 10;

  /// 학교명 최소 길이
  static const int minSchoolNameLength = 2;

  /// 학교명 최대 길이
  static const int maxSchoolNameLength = 50;

  /// 비밀번호 최소 길이
  static const int minPasswordLength = 8;

  /// 비밀번호 최대 길이
  static const int maxPasswordLength = 100;

  /// 프로필 아바타 이니셜 길이
  static const int avatarInitialLength = 2;
}

/// 파일 업로드 관련 상수
class FileConstants {
  FileConstants._();

  /// 최대 파일 크기 (바이트) - 5MB
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// 이미지 최대 크기 (바이트) - 2MB
  static const int maxImageSizeBytes = 2 * 1024 * 1024;

  /// 문서 최대 크기 (바이트) - 10MB
  static const int maxDocumentSizeBytes = 10 * 1024 * 1024;

  /// 허용 이미지 확장자
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];

  /// 허용 문서 확장자
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];

  /// 압축 후 이미지 품질 (0-100)
  static const int compressedImageQuality = 85;

  /// 이미지 최대 너비
  static const int maxImageWidth = 1920;

  /// 이미지 최대 높이
  static const int maxImageHeight = 1920;
}

/// UI 관련 상수
class UIConstants {
  UIConstants._();

  /// 기본 패딩
  static const double defaultPadding = 16.0;

  /// 작은 패딩
  static const double smallPadding = 8.0;

  /// 큰 패딩
  static const double largePadding = 24.0;

  /// 기본 보더 반경
  static const double defaultBorderRadius = 12.0;

  /// 작은 보더 반경
  static const double smallBorderRadius = 8.0;

  /// 큰 보더 반경
  static const double largeBorderRadius = 16.0;

  /// 카드 높이 (Elevation)
  static const double cardElevation = 0.0;

  /// 모달 보더 반경
  static const double modalBorderRadius = 20.0;

  /// 아이콘 크기 - 작음
  static const double smallIconSize = 16.0;

  /// 아이콘 크기 - 보통
  static const double mediumIconSize = 24.0;

  /// 아이콘 크기 - 큼
  static const double largeIconSize = 32.0;

  /// 버튼 높이
  static const double buttonHeight = 48.0;

  /// 입력 필드 높이
  static const double inputFieldHeight = 56.0;

  /// 앱바 높이
  static const double appBarHeight = 56.0;

  /// 탭바 높이
  static const double tabBarHeight = 48.0;

  /// 바텀 시트 최대 높이 비율
  static const double bottomSheetMaxHeightRatio = 0.9;

  /// 리스트 아이템 최소 높이
  static const double listItemMinHeight = 56.0;

  /// 로딩 인디케이터 크기
  static const double loadingIndicatorSize = 24.0;

  /// 스낵바 표시 시간 (초)
  static const int snackBarDurationSeconds = 3;

  /// 애니메이션 기본 시간 (밀리초)
  static const int defaultAnimationDuration = 300;

  /// 페이지 전환 애니메이션 시간 (밀리초)
  static const int pageTransitionDuration = 250;
}

/// 네트워크 관련 상수
class NetworkConstants {
  NetworkConstants._();

  /// HTTP 요청 타임아웃 (초)
  static const int requestTimeoutSeconds = 30;

  /// 재시도 횟수
  static const int maxRetries = 3;

  /// 재시도 대기 시간 (밀리초)
  static const int retryDelayMilliseconds = 1000;

  /// 페이징 기본 크기
  static const int defaultPageSize = 20;

  /// 페이징 최대 크기
  static const int maxPageSize = 100;
}

/// 캐시 관련 상수
class CacheConstants {
  CacheConstants._();

  /// 캐시 만료 시간 (분) - 짧은 캐시
  static const int shortCacheDurationMinutes = 5;

  /// 캐시 만료 시간 (분) - 보통 캐시
  static const int mediumCacheDurationMinutes = 30;

  /// 캐시 만료 시간 (분) - 긴 캐시
  static const int longCacheDurationMinutes = 1440; // 24시간

  /// 이미지 캐시 최대 크기 (바이트) - 100MB
  static const int maxImageCacheSize = 100 * 1024 * 1024;

  /// 디스크 캐시 최대 크기 (바이트) - 500MB
  static const int maxDiskCacheSize = 500 * 1024 * 1024;
}

/// 정규식 패턴
class RegexPatterns {
  RegexPatterns._();

  /// 이메일 패턴
  static const String email = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// 한국 휴대폰 번호 패턴
  static const String koreanPhone = r'^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$';

  /// 비밀번호 패턴 (영문+숫자 포함, 8자 이상)
  static const String password = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$';

  /// 한글만 허용
  static const String koreanOnly = r'^[가-힣]+$';

  /// 영문만 허용
  static const String englishOnly = r'^[a-zA-Z]+$';

  /// 숫자만 허용
  static const String numbersOnly = r'^\d+$';

  /// 영문+숫자만 허용
  static const String alphanumeric = r'^[a-zA-Z0-9]+$';

  /// URL 패턴
  static const String url = r'^https?://[^\s]+$';
}

/// 에러 메시지 키
class ErrorKeys {
  ErrorKeys._();

  /// 네트워크 에러
  static const String networkError = 'network_error';

  /// 인증 에러
  static const String authError = 'auth_error';

  /// 권한 에러
  static const String permissionError = 'permission_error';

  /// 유효성 검증 에러
  static const String validationError = 'validation_error';

  /// 서버 에러
  static const String serverError = 'server_error';

  /// 알 수 없는 에러
  static const String unknownError = 'unknown_error';

  /// 타임아웃 에러
  static const String timeoutError = 'timeout_error';

  /// 데이터 없음
  static const String noDataError = 'no_data_error';
}
