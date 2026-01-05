import 'dart:convert';
import 'package:http/http.dart' as http;

/// 공공데이터 API를 통한 학교 검색 서비스
///
/// 나이스 교육정보 개방포털 API 또는 공공데이터포털 API 사용
class SchoolApiService {
  // TODO: 실제 API 키로 교체 필요
  // 공공데이터포털 (data.go.kr)에서 "학교기본정보" API 키 발급
  static const String _apiKey = '';
  static const String _baseUrl = 'https://open.neis.go.kr/hub/schoolInfo';

  /// 학교명으로 검색 (나이스 API)
  ///
  /// [schoolName] 검색할 학교명 (예: 나진)
  /// [schoolType] 학교 유형 (초등학교: 02, 중학교: 03, 고등학교: 04)
  Future<List<SchoolApiResult>> searchSchools({
    required String schoolName,
    String schoolType = '02', // 초등학교
  }) async {
    if (_apiKey.isEmpty) {
      // API 키가 없으면 로컬 데이터 사용
      return _searchLocalSchools(schoolName);
    }

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'KEY': _apiKey,
        'Type': 'json',
        'pIndex': '1',
        'pSize': '20',
        'SCHUL_NM': schoolName,
        'SCHUL_KND_SC_NM': _getSchoolTypeName(schoolType),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final schoolInfo = data['schoolInfo'];

        if (schoolInfo == null) return [];

        final rows = schoolInfo[1]['row'] as List?;
        if (rows == null) return [];

        return rows.map((row) => SchoolApiResult.fromNeisJson(row)).toList();
      }

      return [];
    } catch (e) {
      // API 실패 시 로컬 데이터 사용
      return _searchLocalSchools(schoolName);
    }
  }

  String _getSchoolTypeName(String code) {
    switch (code) {
      case '02': return '초등학교';
      case '03': return '중학교';
      case '04': return '고등학교';
      default: return '초등학교';
    }
  }

  /// 로컬 데이터에서 검색 (API 키 없을 때 fallback)
  List<SchoolApiResult> _searchLocalSchools(String query) {
    return _sampleElementarySchools
        .where((s) => s.name.contains(query))
        .take(10)
        .toList();
  }

  /// 샘플 초등학교 데이터 (API 키 없을 때 사용)
  /// 실제 운영 시 공공데이터 API 또는 DB에서 로드
  static final List<SchoolApiResult> _sampleElementarySchools = [
    SchoolApiResult(name: '나진초등학교', address: '인천광역시 서구', neisCode: 'E100000001', educationOffice: 'incheon'),
    SchoolApiResult(name: '나비초등학교', address: '서울특별시 강남구', neisCode: 'E100000002', educationOffice: 'seoul'),
    SchoolApiResult(name: '나래초등학교', address: '경기도 성남시', neisCode: 'E100000003', educationOffice: 'gyeonggi'),
    SchoolApiResult(name: '구래초등학교', address: '인천광역시 서구', neisCode: 'E100000004', educationOffice: 'incheon'),
    SchoolApiResult(name: '서울초등학교', address: '서울특별시 중구', neisCode: 'E100000005', educationOffice: 'seoul'),
    SchoolApiResult(name: '부산초등학교', address: '부산광역시 중구', neisCode: 'E100000006', educationOffice: 'busan'),
    SchoolApiResult(name: '대구초등학교', address: '대구광역시 중구', neisCode: 'E100000007', educationOffice: 'daegu'),
    SchoolApiResult(name: '인천초등학교', address: '인천광역시 중구', neisCode: 'E100000008', educationOffice: 'incheon'),
    SchoolApiResult(name: '광주초등학교', address: '광주광역시 동구', neisCode: 'E100000009', educationOffice: 'gwangju'),
    SchoolApiResult(name: '대전초등학교', address: '대전광역시 중구', neisCode: 'E100000010', educationOffice: 'daejeon'),
    SchoolApiResult(name: '청라초등학교', address: '인천광역시 서구', neisCode: 'E100000011', educationOffice: 'incheon'),
    SchoolApiResult(name: '송도초등학교', address: '인천광역시 연수구', neisCode: 'E100000012', educationOffice: 'incheon'),
    SchoolApiResult(name: '강남초등학교', address: '서울특별시 강남구', neisCode: 'E100000013', educationOffice: 'seoul'),
    SchoolApiResult(name: '분당초등학교', address: '경기도 성남시', neisCode: 'E100000014', educationOffice: 'gyeonggi'),
    SchoolApiResult(name: '판교초등학교', address: '경기도 성남시', neisCode: 'E100000015', educationOffice: 'gyeonggi'),
  ];
}

/// API 검색 결과 모델
class SchoolApiResult {
  final String name;
  final String? address;
  final String? neisCode;
  final String? educationOffice;

  SchoolApiResult({
    required this.name,
    this.address,
    this.neisCode,
    this.educationOffice,
  });

  /// 나이스 API 응답에서 변환
  factory SchoolApiResult.fromNeisJson(Map<String, dynamic> json) {
    return SchoolApiResult(
      name: json['SCHUL_NM'] ?? '',
      address: json['ORG_RDNMA'] ?? json['ORG_FAXNO'],
      neisCode: json['SD_SCHUL_CODE'],
      educationOffice: _parseEducationOffice(json['ATPT_OFCDC_SC_CODE']),
    );
  }

  static String? _parseEducationOffice(String? code) {
    if (code == null) return null;
    // 나이스 교육청 코드 → 우리 시스템 코드 매핑
    const mapping = {
      'B10': 'seoul',
      'C10': 'busan',
      'D10': 'daegu',
      'E10': 'incheon',
      'F10': 'gwangju',
      'G10': 'daejeon',
      'H10': 'ulsan',
      'I10': 'sejong',
      'J10': 'gyeonggi',
      'K10': 'gangwon',
      'M10': 'chungbuk',
      'N10': 'chungnam',
      'P10': 'jeonbuk',
      'Q10': 'jeonnam',
      'R10': 'gyeongbuk',
      'S10': 'gyeongnam',
      'T10': 'jeju',
    };
    return mapping[code];
  }

  /// Supabase 저장용 Map 변환
  Map<String, dynamic> toSupabaseMap() {
    return {
      'name': name,
      'address': address,
      'neis_code': neisCode,
      'education_office': educationOffice,
      'type': 'elementary',
    };
  }
}
