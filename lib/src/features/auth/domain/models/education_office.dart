import 'package:freezed_annotation/freezed_annotation.dart';

part 'education_office.freezed.dart';
part 'education_office.g.dart';

/// 교육청 정보 모델
@freezed
class EducationOffice with _$EducationOffice {
  const factory EducationOffice({
    required String code, // 예: "seoul"
    required String nameKo, // 예: "서울특별시교육청"
    required String emailDomain, // 예: "sen.go.kr"
    DateTime? createdAt,
  }) = _EducationOffice;

  factory EducationOffice.fromJson(Map<String, dynamic> json) =>
      _$EducationOfficeFromJson(json);
}

/// 17개 시도교육청 상수
class EducationOffices {
  EducationOffices._();

  static const List<EducationOffice> all = [
    EducationOffice(
      code: 'seoul',
      nameKo: '서울특별시교육청',
      emailDomain: 'sen.go.kr',
    ),
    EducationOffice(
      code: 'busan',
      nameKo: '부산광역시교육청',
      emailDomain: 'pen.go.kr',
    ),
    EducationOffice(
      code: 'daegu',
      nameKo: '대구광역시교육청',
      emailDomain: 'dge.go.kr',
    ),
    EducationOffice(
      code: 'incheon',
      nameKo: '인천광역시교육청',
      emailDomain: 'ice.go.kr',
    ),
    EducationOffice(
      code: 'gwangju',
      nameKo: '광주광역시교육청',
      emailDomain: 'gen.go.kr',
    ),
    EducationOffice(
      code: 'daejeon',
      nameKo: '대전광역시교육청',
      emailDomain: 'dje.go.kr',
    ),
    EducationOffice(
      code: 'ulsan',
      nameKo: '울산광역시교육청',
      emailDomain: 'use.go.kr',
    ),
    EducationOffice(
      code: 'sejong',
      nameKo: '세종특별자치시교육청',
      emailDomain: 'sje.go.kr',
    ),
    EducationOffice(
      code: 'gyeonggi',
      nameKo: '경기도교육청',
      emailDomain: 'goe.go.kr',
    ),
    EducationOffice(
      code: 'gangwon',
      nameKo: '강원도교육청',
      emailDomain: 'kwe.go.kr',
    ),
    EducationOffice(
      code: 'chungbuk',
      nameKo: '충청북도교육청',
      emailDomain: 'cbe.go.kr',
    ),
    EducationOffice(
      code: 'chungnam',
      nameKo: '충청남도교육청',
      emailDomain: 'cne.go.kr',
    ),
    EducationOffice(
      code: 'jeonbuk',
      nameKo: '전라북도교육청',
      emailDomain: 'jbe.go.kr',
    ),
    EducationOffice(
      code: 'jeonnam',
      nameKo: '전라남도교육청',
      emailDomain: 'jne.go.kr',
    ),
    EducationOffice(
      code: 'gyeongbuk',
      nameKo: '경상북도교육청',
      emailDomain: 'gbe.go.kr',
    ),
    EducationOffice(
      code: 'gyeongnam',
      nameKo: '경상남도교육청',
      emailDomain: 'gne.go.kr',
    ),
    EducationOffice(
      code: 'jeju',
      nameKo: '제주특별자치도교육청',
      emailDomain: 'jje.go.kr',
    ),
  ];

  /// 이메일 도메인으로 교육청 찾기
  static EducationOffice? findByEmailDomain(String email) {
    final domain = email.split('@').lastOrNull;
    if (domain == null) return null;

    try {
      return all.firstWhere((office) => office.emailDomain == domain);
    } catch (e) {
      return null;
    }
  }

  /// 코드로 교육청 찾기
  static EducationOffice? findByCode(String code) {
    try {
      return all.firstWhere((office) => office.code == code);
    } catch (e) {
      return null;
    }
  }
}

extension _ListExtension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
