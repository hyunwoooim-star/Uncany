/// 에러 메시지 한글화 유틸리티
/// 모든 에러 메시지는 한국어로 표시되어야 함
class ErrorMessages {
  ErrorMessages._();

  /// Supabase Auth 에러 메시지 한글화
  static String fromAuthError(String message) {
    final lowerMessage = message.toLowerCase();

    // 이메일 관련
    if (lowerMessage.contains('email address is invalid') ||
        lowerMessage.contains('invalid email')) {
      return '유효하지 않은 이메일 형식입니다';
    }
    if (lowerMessage.contains('email not confirmed')) {
      return '이메일 인증이 필요합니다. 메일함을 확인해주세요';
    }
    if (lowerMessage.contains('already registered') ||
        lowerMessage.contains('user already registered')) {
      return '이미 가입된 이메일입니다';
    }
    if (lowerMessage.contains('email rate limit exceeded')) {
      return '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요';
    }

    // 비밀번호 관련
    if (lowerMessage.contains('weak password') ||
        lowerMessage.contains('password should be')) {
      return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요';
    }
    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid password')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다';
    }

    // 사용자 관련
    if (lowerMessage.contains('user not found')) {
      return '등록되지 않은 사용자입니다';
    }
    if (lowerMessage.contains('user banned')) {
      return '이용이 제한된 계정입니다';
    }

    // 네트워크 관련
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('failed to fetch')) {
      return '네트워크 연결을 확인해주세요';
    }
    if (lowerMessage.contains('timeout')) {
      return '요청 시간이 초과되었습니다. 다시 시도해주세요';
    }

    // 권한 관련
    if (lowerMessage.contains('permission denied') ||
        lowerMessage.contains('not authorized')) {
      return '권한이 없습니다';
    }
    if (lowerMessage.contains('session expired') ||
        lowerMessage.contains('refresh token')) {
      return '로그인이 만료되었습니다. 다시 로그인해주세요';
    }

    // 서버 관련
    if (lowerMessage.contains('server error') ||
        lowerMessage.contains('internal error')) {
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
    }
    if (lowerMessage.contains('rate limit')) {
      return '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요';
    }

    // 기타
    if (lowerMessage.contains('signup disabled')) {
      return '현재 회원가입이 불가능합니다';
    }

    // 알 수 없는 에러는 일반 메시지로 반환
    return '오류가 발생했습니다. 다시 시도해주세요';
  }

  /// 일반 에러 메시지 한글화
  static String fromError(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') || message.contains('socket')) {
      return '네트워크 연결을 확인해주세요';
    }
    if (message.contains('timeout')) {
      return '요청 시간이 초과되었습니다';
    }
    if (message.contains('permission')) {
      return '권한이 없습니다';
    }

    return '오류가 발생했습니다. 다시 시도해주세요';
  }

  /// 폼 검증 메시지
  static const String requiredField = '필수 입력 항목입니다';
  static const String invalidEmail = '유효한 이메일을 입력해주세요';
  static const String invalidPassword = '비밀번호는 6자 이상이어야 합니다';
  static const String passwordMismatch = '비밀번호가 일치하지 않습니다';
  static const String invalidPhone = '유효한 전화번호를 입력해주세요';

  /// 성공 메시지
  static const String signupSuccess = '회원가입이 완료되었습니다';
  static const String signupPending = '회원가입이 완료되었습니다. 관리자 승인 후 이용 가능합니다';
  static const String loginSuccess = '로그인되었습니다';
  static const String logoutSuccess = '로그아웃되었습니다';

  /// 확인 메시지
  static const String confirmLogout = '로그아웃 하시겠습니까?';
  static const String confirmDelete = '정말 삭제하시겠습니까?';
  static const String confirmCancel = '작성 중인 내용이 사라집니다. 취소하시겠습니까?';
}
