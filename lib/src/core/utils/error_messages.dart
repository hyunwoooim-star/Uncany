import 'package:supabase_flutter/supabase_flutter.dart';

/// 에러 메시지 한글화 유틸리티
/// 모든 에러 메시지는 한국어로 표시되어야 함
class ErrorMessages {
  ErrorMessages._();

  /// PostgrestException에서 사용자 친화적 메시지 추출
  ///
  /// DB 트리거에서 RAISE EXCEPTION으로 던진 한글 메시지를 추출
  static String fromPostgrestException(PostgrestException e) {
    // 1. message 필드에서 직접 한글 메시지 확인
    final message = e.message;

    // DB 트리거에서 던진 한글 메시지인 경우 그대로 반환
    if (_isKoreanMessage(message)) {
      return message;
    }

    // 2. details 필드 확인
    final details = e.details;
    if (details != null && details is String && _isKoreanMessage(details)) {
      return details;
    }

    // 3. hint 필드 확인
    final hint = e.hint;
    if (hint != null && _isKoreanMessage(hint)) {
      return hint;
    }

    // 4. 에러 코드 기반 변환
    return _fromPostgresErrorCode(e.code, message);
  }

  /// 한글이 포함된 메시지인지 확인
  static bool _isKoreanMessage(String text) {
    // 한글 유니코드 범위: 가-힣 (AC00-D7A3), ㄱ-ㅎ (3131-314E), ㅏ-ㅣ (314F-3163)
    return RegExp(r'[\uAC00-\uD7A3\u3131-\u314E\u314F-\u3163]').hasMatch(text);
  }

  /// PostgreSQL 에러 코드 기반 메시지 변환
  static String _fromPostgresErrorCode(String? code, String message) {
    switch (code) {
      case '23505': // unique_violation
        if (message.contains('reservations')) {
          return '이미 예약된 시간대입니다';
        }
        return '이미 존재하는 데이터입니다';
      case '23503': // foreign_key_violation
        return '연결된 데이터를 찾을 수 없습니다';
      case '23502': // not_null_violation
        return '필수 정보가 누락되었습니다';
      case 'P0001': // raise_exception (사용자 정의 에러)
        // 트리거에서 던진 메시지가 영어인 경우
        if (message.contains('already reserved') || message.contains('conflict')) {
          return '해당 시간은 이미 예약되어 있습니다';
        }
        return message;
      case '42501': // insufficient_privilege
        return '권한이 없습니다';
      case '42P01': // undefined_table
        return '데이터를 찾을 수 없습니다';
      default:
        return fromError(message);
    }
  }

  /// 예약 충돌 에러인지 확인
  static bool isReservationConflictError(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('예약') ||
           message.contains('교시') ||
           message.contains('이미') ||
           message.contains('conflict') ||
           message.contains('reserved');
  }

  /// 예약 충돌 에러 메시지 생성
  static String reservationConflictMessage(List<int>? conflictPeriods) {
    if (conflictPeriods == null || conflictPeriods.isEmpty) {
      return '앗, 방금 다른 선생님이 예약했어요!';
    }
    final periodsText = conflictPeriods.join(', ');
    return '앗, $periodsText교시는 방금 다른 선생님이 예약했어요!';
  }

  /// Supabase Auth 에러 메시지 한글화
  static String fromAuthError(String message) {
    final lowerMessage = message.toLowerCase();

    // 이메일 관련
    if (lowerMessage.contains('is invalid') && lowerMessage.contains('email')) {
      return '유효하지 않은 이메일 주소입니다';
    }
    if (lowerMessage.contains('invalid email')) {
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
    if (lowerMessage.contains('signup disabled') ||
        lowerMessage.contains('email_provider_disabled')) {
      return '현재 회원가입이 불가능합니다';
    }
    if (lowerMessage.contains('email_address_invalid')) {
      return '유효하지 않은 이메일 주소입니다';
    }
    if (lowerMessage.contains('over_email_send_rate_limit')) {
      return '이메일 발송 한도를 초과했습니다. 잠시 후 다시 시도해주세요';
    }
    if (lowerMessage.contains('otp_expired')) {
      return '인증 코드가 만료되었습니다. 다시 요청해주세요';
    }

    // 알 수 없는 에러는 일반 메시지로 반환
    return '오류가 발생했습니다. 다시 시도해주세요';
  }

  /// 일반 에러 메시지 한글화
  static String fromError(dynamic error) {
    final message = error.toString().toLowerCase();

    // 네트워크 관련
    if (message.contains('network') || message.contains('socket')) {
      return '네트워크 연결을 확인해주세요';
    }
    if (message.contains('timeout')) {
      return '요청 시간이 초과되었습니다';
    }

    // 권한 관련
    if (message.contains('permission') || message.contains('row-level security')) {
      return '권한이 없습니다';
    }

    // 중복 관련 (PostgrestException)
    if (message.contains('duplicate') || message.contains('unique constraint') ||
        message.contains('already exists') || message.contains('23505')) {
      if (message.contains('email')) {
        return '이미 가입된 이메일입니다';
      }
      if (message.contains('code')) {
        return '이미 사용 중인 코드입니다';
      }
      return '이미 존재하는 데이터입니다';
    }

    // 외래 키 관련
    if (message.contains('foreign key') || message.contains('23503')) {
      return '연결된 데이터를 찾을 수 없습니다';
    }

    // 필수 값 누락
    if (message.contains('not null') || message.contains('23502')) {
      return '필수 정보가 누락되었습니다';
    }

    // Storage 관련
    if (message.contains('storage') && message.contains('bucket')) {
      return '파일 저장소 오류가 발생했습니다';
    }
    if (message.contains('file too large') || message.contains('payload too large')) {
      return '파일 크기가 너무 큽니다 (최대 5MB)';
    }

    return '오류가 발생했습니다. 다시 시도해주세요';
  }

  /// 폼 검증 메시지
  static const String requiredField = '필수 입력 항목입니다';
  static const String invalidEmail = '유효한 이메일을 입력해주세요';
  static const String invalidPassword = '비밀번호는 6자 이상이어야 합니다';
  static const String passwordMismatch = '비밀번호가 일치하지 않습니다';
  static const String invalidPhone = '유효한 전화번호를 입력해주세요';
  static const String authRequired = '로그인이 필요합니다';

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
