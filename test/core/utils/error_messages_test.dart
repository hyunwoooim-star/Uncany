import 'package:flutter_test/flutter_test.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

void main() {
  group('ErrorMessages', () {
    group('fromAuthError', () {
      test('이메일 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromAuthError('email is invalid'),
          '유효하지 않은 이메일 주소입니다',
        );
        expect(
          ErrorMessages.fromAuthError('Invalid email format'),
          '유효하지 않은 이메일 형식입니다',
        );
        expect(
          ErrorMessages.fromAuthError('Email not confirmed'),
          '이메일 인증이 필요합니다. 메일함을 확인해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('User already registered'),
          '이미 가입된 이메일입니다',
        );
        expect(
          ErrorMessages.fromAuthError('email rate limit exceeded'),
          '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요',
        );
      });

      test('비밀번호 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromAuthError('Weak password'),
          '비밀번호가 너무 약합니다. 6자 이상 입력해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('Password should be at least 6 characters'),
          '비밀번호가 너무 약합니다. 6자 이상 입력해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('Invalid login credentials'),
          '이메일 또는 비밀번호가 올바르지 않습니다',
        );
        expect(
          ErrorMessages.fromAuthError('Invalid password'),
          '이메일 또는 비밀번호가 올바르지 않습니다',
        );
      });

      test('사용자 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromAuthError('User not found'),
          '등록되지 않은 사용자입니다',
        );
        expect(
          ErrorMessages.fromAuthError('User banned'),
          '이용이 제한된 계정입니다',
        );
      });

      test('네트워크 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromAuthError('Network error'),
          '네트워크 연결을 확인해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('Connection failed'),
          '네트워크 연결을 확인해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('Failed to fetch'),
          '네트워크 연결을 확인해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('Request timeout'),
          '요청 시간이 초과되었습니다. 다시 시도해주세요',
        );
      });

      test('권한 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromAuthError('Permission denied'),
          '권한이 없습니다',
        );
        expect(
          ErrorMessages.fromAuthError('Not authorized'),
          '권한이 없습니다',
        );
        expect(
          ErrorMessages.fromAuthError('Session expired'),
          '로그인이 만료되었습니다. 다시 로그인해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('Refresh token expired'),
          '로그인이 만료되었습니다. 다시 로그인해주세요',
        );
      });

      test('서버 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromAuthError('Internal server error'),
          '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('Rate limit exceeded'),
          '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요',
        );
      });

      test('기타 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromAuthError('Signup disabled'),
          '현재 회원가입이 불가능합니다',
        );
        expect(
          ErrorMessages.fromAuthError('email_address_invalid'),
          '유효하지 않은 이메일 주소입니다',
        );
        expect(
          ErrorMessages.fromAuthError('over_email_send_rate_limit'),
          '이메일 발송 한도를 초과했습니다. 잠시 후 다시 시도해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('otp_expired'),
          '인증 코드가 만료되었습니다. 다시 요청해주세요',
        );
      });

      test('알 수 없는 에러는 기본 메시지를 반환한다', () {
        expect(
          ErrorMessages.fromAuthError('Some unknown error'),
          '오류가 발생했습니다. 다시 시도해주세요',
        );
        expect(
          ErrorMessages.fromAuthError('Random error message'),
          '오류가 발생했습니다. 다시 시도해주세요',
        );
      });

      test('대소문자를 구분하지 않는다', () {
        expect(
          ErrorMessages.fromAuthError('INVALID LOGIN CREDENTIALS'),
          '이메일 또는 비밀번호가 올바르지 않습니다',
        );
        expect(
          ErrorMessages.fromAuthError('USER NOT FOUND'),
          '등록되지 않은 사용자입니다',
        );
      });
    });

    group('fromError', () {
      test('네트워크 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromError('Network error occurred'),
          '네트워크 연결을 확인해주세요',
        );
        expect(
          ErrorMessages.fromError('Socket exception'),
          '네트워크 연결을 확인해주세요',
        );
        expect(
          ErrorMessages.fromError('Request timeout'),
          '요청 시간이 초과되었습니다',
        );
      });

      test('권한 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromError('Permission denied'),
          '권한이 없습니다',
        );
        expect(
          ErrorMessages.fromError('Row-level security policy'),
          '권한이 없습니다',
        );
      });

      test('중복 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromError('Duplicate key value'),
          '이미 존재하는 데이터입니다',
        );
        expect(
          ErrorMessages.fromError('Unique constraint violation'),
          '이미 존재하는 데이터입니다',
        );
        expect(
          ErrorMessages.fromError('Already exists'),
          '이미 존재하는 데이터입니다',
        );
        expect(
          ErrorMessages.fromError('Error code 23505'),
          '이미 존재하는 데이터입니다',
        );
      });

      test('이메일 중복 에러를 특별히 처리한다', () {
        expect(
          ErrorMessages.fromError('Duplicate email value'),
          '이미 가입된 이메일입니다',
        );
      });

      test('코드 중복 에러를 특별히 처리한다', () {
        expect(
          ErrorMessages.fromError('Duplicate code value'),
          '이미 사용 중인 코드입니다',
        );
      });

      test('외래 키 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromError('Foreign key violation'),
          '연결된 데이터를 찾을 수 없습니다',
        );
        expect(
          ErrorMessages.fromError('Error code 23503'),
          '연결된 데이터를 찾을 수 없습니다',
        );
      });

      test('필수 값 누락 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromError('Not null violation'),
          '필수 정보가 누락되었습니다',
        );
        expect(
          ErrorMessages.fromError('Error code 23502'),
          '필수 정보가 누락되었습니다',
        );
      });

      test('Storage 관련 에러를 올바르게 변환한다', () {
        expect(
          ErrorMessages.fromError('Storage bucket not found'),
          '파일 저장소 오류가 발생했습니다',
        );
        expect(
          ErrorMessages.fromError('File too large'),
          '파일 크기가 너무 큽니다 (최대 5MB)',
        );
        expect(
          ErrorMessages.fromError('Payload too large'),
          '파일 크기가 너무 큽니다 (최대 5MB)',
        );
      });

      test('알 수 없는 에러는 기본 메시지를 반환한다', () {
        expect(
          ErrorMessages.fromError('Unknown error'),
          '오류가 발생했습니다. 다시 시도해주세요',
        );
      });
    });

    group('isReservationConflictError', () {
      test('예약 충돌 에러를 감지한다', () {
        expect(ErrorMessages.isReservationConflictError('예약이 충돌합니다'), true);
        expect(ErrorMessages.isReservationConflictError('3교시는 이미 예약되었습니다'), true);
        expect(ErrorMessages.isReservationConflictError('이미 존재합니다'), true);
        expect(ErrorMessages.isReservationConflictError('conflict detected'), true);
        expect(ErrorMessages.isReservationConflictError('Already reserved'), true);
      });

      test('일반 에러는 예약 충돌로 감지하지 않는다', () {
        expect(ErrorMessages.isReservationConflictError('Network error'), false);
        expect(ErrorMessages.isReservationConflictError('Permission denied'), false);
      });
    });

    group('reservationConflictMessage', () {
      test('충돌 교시가 없을 때 기본 메시지를 반환한다', () {
        expect(
          ErrorMessages.reservationConflictMessage(null),
          '앗, 방금 다른 선생님이 예약했어요!',
        );
        expect(
          ErrorMessages.reservationConflictMessage([]),
          '앗, 방금 다른 선생님이 예약했어요!',
        );
      });

      test('충돌 교시가 있을 때 해당 교시를 포함한 메시지를 반환한다', () {
        expect(
          ErrorMessages.reservationConflictMessage([3]),
          '앗, 3교시는 방금 다른 선생님이 예약했어요!',
        );
        expect(
          ErrorMessages.reservationConflictMessage([1, 2, 3]),
          '앗, 1, 2, 3교시는 방금 다른 선생님이 예약했어요!',
        );
      });
    });

    group('상수 메시지', () {
      test('폼 검증 메시지가 정의되어 있다', () {
        expect(ErrorMessages.requiredField, '필수 입력 항목입니다');
        expect(ErrorMessages.invalidEmail, '유효한 이메일을 입력해주세요');
        expect(ErrorMessages.invalidPassword, '비밀번호는 6자 이상이어야 합니다');
        expect(ErrorMessages.passwordMismatch, '비밀번호가 일치하지 않습니다');
        expect(ErrorMessages.invalidPhone, '유효한 전화번호를 입력해주세요');
        expect(ErrorMessages.authRequired, '로그인이 필요합니다');
      });

      test('성공 메시지가 정의되어 있다', () {
        expect(ErrorMessages.signupSuccess, '회원가입이 완료되었습니다');
        expect(
          ErrorMessages.signupPending,
          '회원가입이 완료되었습니다. 관리자 승인 후 이용 가능합니다',
        );
        expect(ErrorMessages.loginSuccess, '로그인되었습니다');
        expect(ErrorMessages.logoutSuccess, '로그아웃되었습니다');
      });

      test('확인 메시지가 정의되어 있다', () {
        expect(ErrorMessages.confirmLogout, '로그아웃 하시겠습니까?');
        expect(ErrorMessages.confirmDelete, '정말 삭제하시겠습니까?');
        expect(
          ErrorMessages.confirmCancel,
          '작성 중인 내용이 사라집니다. 취소하시겠습니까?',
        );
      });
    });
  });
}
