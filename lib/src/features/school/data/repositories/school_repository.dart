import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/school.dart';

/// 학교 Repository
///
/// 학교 검색 및 조회
class SchoolRepository {
  final SupabaseClient _supabase;

  SchoolRepository(this._supabase);

  /// 학교명으로 검색 (자동완성용)
  ///
  /// [query]로 시작하는 학교 목록 반환 (최대 10개)
  Future<List<School>> searchSchools(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _supabase
          .from('schools')
          .select()
          .ilike('name', '$query%')
          .limit(10)
          .order('name');

      return (response as List)
          .map((json) => School.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('학교 검색 실패: $e');
    }
  }

  /// 학교 ID로 조회
  Future<School?> getSchool(String id) async {
    try {
      final response = await _supabase
          .from('schools')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return School.fromJson(response);
    } catch (e) {
      throw Exception('학교 조회 실패: $e');
    }
  }

  /// 모든 초등학교 목록 (캐싱용)
  Future<List<School>> getAllElementarySchools() async {
    try {
      final response = await _supabase
          .from('schools')
          .select()
          .eq('type', 'elementary')
          .order('name');

      return (response as List)
          .map((json) => School.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('학교 목록 조회 실패: $e');
    }
  }

  /// 학교 추가 (관리자용 또는 공공데이터 연동시)
  Future<School> createSchool({
    required String name,
    String? address,
    String? educationOffice,
    String? neisCode,
    String type = 'elementary',
  }) async {
    try {
      final data = {
        'name': name,
        'address': address,
        'education_office': educationOffice,
        'neis_code': neisCode,
        'type': type,
      };

      final response = await _supabase
          .from('schools')
          .insert(data)
          .select()
          .single();

      return School.fromJson(response);
    } catch (e) {
      throw Exception('학교 추가 실패: $e');
    }
  }

  /// 학교 일괄 추가 (공공데이터 연동시)
  Future<void> bulkInsertSchools(List<Map<String, dynamic>> schools) async {
    try {
      await _supabase.from('schools').upsert(
        schools,
        onConflict: 'neis_code',
      );
    } catch (e) {
      throw Exception('학교 일괄 추가 실패: $e');
    }
  }
}
