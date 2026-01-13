// ====================================
// 나이스 Open API Proxy (Supabase Edge Function)
// ====================================
// 목적: 클라이언트에서 API 키 노출 방지
// 작성일: 2026-01-13

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { create​Response } from '../_shared/cors.ts';

const NEIS_API_KEY = Deno.env.get('NEIS_API_KEY');
const NEIS_BASE_URL = 'https://open.neis.go.kr/hub';

interface SchoolSearchParams {
  query: string;
  eduOfficeCode?: string;
  page?: number;
  limit?: number;
}

serve(async (req: Request) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return createResponse(null, { status: 204 });
  }

  try {
    // 인증 확인
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return createResponse(
        { error: '인증이 필요합니다' },
        { status: 401 }
      );
    }

    // API 키 확인
    if (!NEIS_API_KEY) {
      console.error('NEIS_API_KEY가 설정되지 않았습니다');
      return createResponse(
        { error: '서버 설정 오류' },
        { status: 500 }
      );
    }

    const url = new URL(req.url);
    const action = url.searchParams.get('action');

    switch (action) {
      case 'search_schools':
        return await handleSchoolSearch(url.searchParams);

      case 'get_school_info':
        return await handleSchoolInfo(url.searchParams);

      default:
        return createResponse(
          { error: '지원하지 않는 액션입니다' },
          { status: 400 }
        );
    }
  } catch (error) {
    console.error('NEIS API Error:', error);
    return createResponse(
      { error: '서버 오류가 발생했습니다' },
      { status: 500 }
    );
  }
});

// 학교 검색
async function handleSchoolSearch(params: URLSearchParams) {
  const query = params.get('query');
  if (!query || query.length < 2) {
    return createResponse(
      { error: '검색어는 2자 이상이어야 합니다' },
      { status: 400 }
    );
  }

  const page = params.get('page') || '1';
  const limit = params.get('limit') || '10';

  const apiUrl = new URL(`${NEIS_BASE_URL}/schoolInfo`);
  apiUrl.searchParams.set('KEY', NEIS_API_KEY!);
  apiUrl.searchParams.set('Type', 'json');
  apiUrl.searchParams.set('SCHUL_NM', query);
  apiUrl.searchParams.set('pIndex', page);
  apiUrl.searchParams.set('pSize', limit);

  const response = await fetch(apiUrl.toString());
  const data = await response.json();

  // 응답 변환 (API 키 제거, 필요한 데이터만)
  const schools = data?.schoolInfo?.[1]?.row || [];
  const transformedSchools = schools.map((school: any) => ({
    schoolId: school.SD_SCHUL_CODE,
    name: school.SCHUL_NM,
    address: school.ORG_RDNMA,
    eduOfficeCode: school.ATPT_OFCDC_SC_CODE,
    eduOfficeName: school.ATPT_OFCDC_SC_NM,
  }));

  return createResponse({
    schools: transformedSchools,
    total: data?.schoolInfo?.[0]?.head?.[0]?.list_total_count || 0,
  });
}

// 학교 상세 정보
async function handleSchoolInfo(params: URLSearchParams) {
  const schoolId = params.get('schoolId');
  if (!schoolId) {
    return createResponse(
      { error: 'schoolId가 필요합니다' },
      { status: 400 }
    );
  }

  const apiUrl = new URL(`${NEIS_BASE_URL}/schoolInfo`);
  apiUrl.searchParams.set('KEY', NEIS_API_KEY!);
  apiUrl.searchParams.set('Type', 'json');
  apiUrl.searchParams.set('SD_SCHUL_CODE', schoolId);

  const response = await fetch(apiUrl.toString());
  const data = await response.json();

  const school = data?.schoolInfo?.[1]?.row?.[0];
  if (!school) {
    return createResponse(
      { error: '학교 정보를 찾을 수 없습니다' },
      { status: 404 }
    );
  }

  return createResponse({
    schoolId: school.SD_SCHUL_CODE,
    name: school.SCHUL_NM,
    address: school.ORG_RDNMA,
    phone: school.ORG_TELNO,
    homepage: school.HMPG_ADRES,
    eduOfficeCode: school.ATPT_OFCDC_SC_CODE,
    eduOfficeName: school.ATPT_OFCDC_SC_NM,
  });
}
