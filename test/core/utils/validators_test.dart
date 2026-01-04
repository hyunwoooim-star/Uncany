import 'package:flutter_test/flutter_test.dart';
import 'package:uncany/src/core/utils/validators.dart';

void main() {
  group('Validators -', () {
    group('이메일 검증', () {
      test('유효한 이메일은 true 반환', () {
        expect(Validators.isValidEmail('test@example.com'), true);
        expect(Validators.isValidEmail('user.name@domain.co.kr'), true);
      });

      test('유효하지 않은 이메일은 false 반환', () {
        expect(Validators.isValidEmail(''), false);
        expect(Validators.isValidEmail('invalid'), false);
        expect(Validators.isValidEmail('@example.com'), false);
        expect(Validators.isValidEmail('test@'), false);
      });
    });

    group('교육청 이메일 검증', () {
      test('서울교육청 이메일은 true 반환', () {
        expect(Validators.isEducationOfficeEmail('teacher@sen.go.kr'), true);
      });

      test('경기교육청 이메일은 true 반환', () {
        expect(Validators.isEducationOfficeEmail('user@goe.go.kr'), true);
      });

      test('일반 이메일은 false 반환', () {
        expect(Validators.isEducationOfficeEmail('user@gmail.com'), false);
        expect(Validators.isEducationOfficeEmail('test@naver.com'), false);
      });
    });

    group('비밀번호 검증', () {
      test('유효한 비밀번호는 true 반환', () {
        expect(Validators.isValidPassword('password123'), true);
        expect(Validators.isValidPassword('Test1234'), true);
      });

      test('8자 미만은 false 반환', () {
        expect(Validators.isValidPassword('pass123'), false);
      });

      test('영문 또는 숫자 없으면 false 반환', () {
        expect(Validators.isValidPassword('12345678'), false);
        expect(Validators.isValidPassword('password'), false);
      });
    });

    group('비밀번호 강도 검사', () {
      test('약한 비밀번호는 낮은 점수', () {
        expect(Validators.getPasswordStrength('12345'), lessThan(2));
      });

      test('강한 비밀번호는 높은 점수', () {
        expect(Validators.getPasswordStrength('Test1234!@#'), greaterThanOrEqualTo(2));
      });
    });

    group('한국 이름 검증', () {
      test('유효한 한국 이름은 true 반환', () {
        expect(Validators.isValidKoreanName('홍길동'), true);
        expect(Validators.isValidKoreanName('김철수'), true);
      });

      test('2자 미만은 false 반환', () {
        expect(Validators.isValidKoreanName('김'), false);
      });

      test('10자 초과는 false 반환', () {
        expect(Validators.isValidKoreanName('가나다라마바사아자차카'), false);
      });

      test('영문/숫자 포함은 false 반환', () {
        expect(Validators.isValidKoreanName('Hong'), false);
        expect(Validators.isValidKoreanName('김123'), false);
      });
    });

    group('휴대폰 번호 검증', () {
      test('유효한 휴대폰 번호는 true 반환', () {
        expect(Validators.isValidPhone('01012345678'), true);
        expect(Validators.isValidPhone('010-1234-5678'), true);
      });

      test('유효하지 않은 번호는 false 반환', () {
        expect(Validators.isValidPhone('02-1234-5678'), false);
        expect(Validators.isValidPhone('010-123-456'), false);
      });
    });

    group('예약 시간 검증', () {
      test('미래 시간은 true 반환', () {
        final future = DateTime.now().add(const Duration(hours: 1));
        expect(Validators.isValidReservationTime(future), true);
      });

      test('과거 시간은 false 반환', () {
        final past = DateTime.now().subtract(const Duration(hours: 1));
        expect(Validators.isValidReservationTime(past), false);
      });
    });

    group('예약 기간 검증', () {
      test('30분~8시간은 true 반환', () {
        final start = DateTime.now();
        final end1Hour = start.add(const Duration(hours: 1));
        expect(Validators.isValidReservationDuration(start, end1Hour), true);
      });

      test('30분 미만은 false 반환', () {
        final start = DateTime.now();
        final end20Min = start.add(const Duration(minutes: 20));
        expect(Validators.isValidReservationDuration(start, end20Min), false);
      });

      test('8시간 초과는 false 반환', () {
        final start = DateTime.now();
        final end10Hours = start.add(const Duration(hours: 10));
        expect(Validators.isValidReservationDuration(start, end10Hours), false);
      });
    });
  });
}
