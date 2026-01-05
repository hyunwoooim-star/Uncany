import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/school_api_service.dart';

/// 학교 검색 서비스 Provider
final schoolApiServiceProvider = Provider<SchoolApiService>((ref) {
  return SchoolApiService();
});

/// 학교 검색 결과 Provider
/// 검색어를 받아서 학교 목록 반환
final schoolSearchProvider = FutureProvider.family<List<SchoolApiResult>, String>((ref, query) async {
  if (query.isEmpty || query.length < 2) {
    return [];
  }

  final apiService = ref.watch(schoolApiServiceProvider);
  return apiService.searchSchools(schoolName: query);
});

/// 선택된 학교 상태 Provider
final selectedSchoolProvider = StateProvider<SchoolApiResult?>((ref) => null);
