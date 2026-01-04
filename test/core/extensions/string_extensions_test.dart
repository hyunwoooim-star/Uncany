import 'package:flutter_test/flutter_test.dart';
import 'package:uncany/src/core/extensions/string_extensions.dart';

void main() {
  group('StringExtensions -', () {
    group('capitalize', () {
      test('첫 글자를 대문자로 변환', () {
        expect('hello'.capitalize(), 'Hello');
        expect('test'.capitalize(), 'Test');
      });

      test('빈 문자열은 그대로 반환', () {
        expect(''.capitalize(), '');
      });
    });

    group('isBlank', () {
      test('공백만 있으면 true', () {
        expect('   '.isBlank, true);
        expect(''.isBlank, true);
      });

      test('내용이 있으면 false', () {
        expect('text'.isBlank, false);
        expect('  text  '.isBlank, false);
      });
    });

    group('getKoreanInitials', () {
      test('한글 이니셜 추출', () {
        expect('홍길동'.getKoreanInitials(), '홍길');
        expect('김철수'.getKoreanInitials(), '김철');
      });

      test('2자 미만은 그대로 반환', () {
        expect('김'.getKoreanInitials(), '김');
      });
    });

    group('maskEmail', () {
      test('이메일 마스킹', () {
        expect('user@example.com'.maskEmail(), 'u***@example.com');
        expect('test@test.com'.maskEmail(), 't***@test.com');
      });
    });

    group('formatPhoneNumber', () {
      test('휴대폰 번호 포맷팅', () {
        expect('01012345678'.formatPhoneNumber(), '010-1234-5678');
      });

      test('11자가 아니면 그대로 반환', () {
        expect('0101234567'.formatPhoneNumber(), '0101234567');
      });
    });

    group('maskPhoneNumber', () {
      test('휴대폰 번호 마스킹', () {
        expect('01012345678'.maskPhoneNumber(), '010-****-5678');
      });
    });

    group('isValidEmail', () {
      test('유효한 이메일은 true', () {
        expect('test@example.com'.isValidEmail, true);
      });

      test('유효하지 않은 이메일은 false', () {
        expect('invalid'.isValidEmail, false);
      });
    });

    group('ellipsize', () {
      test('문자열 말줄임', () {
        expect('Hello World'.ellipsize(8), 'Hello...');
      });

      test('길이 이하면 그대로 반환', () {
        expect('Short'.ellipsize(10), 'Short');
      });
    });
  });

  group('NullableStringExtensions -', () {
    test('null은 empty', () {
      String? nullString;
      expect(nullString.isNullOrEmpty, true);
      expect(nullString.orEmpty, '');
      expect(nullString.orDash, '-');
    });

    test('빈 문자열은 empty', () {
      expect(''.isNullOrEmpty, true);
    });

    test('값이 있으면 not empty', () {
      expect('text'.isNullOrEmpty, false);
    });
  });
}
