// ====================================
// 나이스 Open API Proxy (보안 강화 버전)
// ====================================
// 목적: 클라이언트 API 키 노출 방지 + JWT 검증
// 작성일: 2026-01-13
// 수정: Gemini 보안 감사 지적 사항 반영

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { createResponse } from '../_shared/cors.ts';

const NEIS_API_KEY = Deno.env.get('NEIS_API_KEY');
const NEIS_BASE_URL = 'https://open.neis.go.kr/hub';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

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
    // 🔑 Critical: JWT 토큰 검증 (Gemini 지적 사항)
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return createResponse(
        { error: '인증이 필요합니다' },
        { status: 401 }
      );
    }

    // Supabase 클라이언트 생성 (인증 헤더 포함)
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: {
        headers: { Authorization: authHeader },
      },
    });

    // 실제 사용자 검증 (JWT 토큰 파싱 및 검증)
    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      console.error('인증 실패:', authError?.message);
      return createResponse(
        { error: 'Unauthorized: 유효하지 않은 토큰입니다' },
        { status: 401 }
      );
    }

    // 사용자 정보 로깅 (보안 감사용)
    console.log(`[NEIS API] 요청 사용자: ${user.email} (${user.id})`);

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

    // Rate Limiting (선택적 - Upstash Redis 사용 권장)
    // const rateLimitOk = await checkRateLimit(user.id);
    // if (!rateLimitOk) {
    //   return createResponse({ error: 'Too Many Requests' }, { status: 429 });
    // }

    switch (action) {
      case 'search_schools':
        return await handleSchoolSearch(url.searchParams, user.id);

      case 'get_school_info':
        return await handleSchoolInfo(url.searchParams, user.id);

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
async function handleSchoolSearch(params: URLSearchParams, userId: string) {
  const query = params.get('query');

  // 입력 검증 (XSS 방지)
  if (!query || query.length < 2) {
    return createResponse(
      { error: '검색어는 2자 이상이어야 합니다' },
      { status: 400 }
    );
  }

  // 특수문자 필터링 (SQL Injection 방지)
  const sanitizedQuery = query.replace(/[<>'\"&]/g, '');
  if (sanitizedQuery !== query) {
    return createResponse(
      { error: '특수문자는 사용할 수 없습니다' },
      { status: 400 }
    );
  }

  const page = params.get('page') || '1';
  const limit = Math.min(parseInt(params.get('limit') || '10'), 50); // 최대 50개 제한

  const apiUrl = new URL(`${NEIS_BASE_URL}/schoolInfo`);
  apiUrl.searchParams.set('KEY', NEIS_API_KEY!);
  apiUrl.searchParams.set('Type', 'json');
  apiUrl.searchParams.set('SCHUL_NM', sanitizedQuery);
  apiUrl.searchParams.set('pIndex', page);
  apiUrl.searchParams.set('pSize', limit.toString());

  try {
    const response = await fetch(apiUrl.toString(), {
      headers: {
        'User-Agent': 'Uncany/1.0',
      },
    });

    if (!response.ok) {
      throw new Error(`NEIS API 오류: ${response.status}`);
    }

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

    // 감사 로그 (선택적)
    console.log(
      `[NEIS] 검색: ${sanitizedQuery} by ${userId} - ${transformedSchools.length}건`
    );

    return createResponse({
      schools: transformedSchools,
      total: data?.schoolInfo?.[0]?.head?.[0]?.list_total_count || 0,
    });
  } catch (error) {
    console.error('NEIS API 호출 실패:', error);
    return createResponse(
      { error: '학교 정보를 가져올 수 없습니다' },
      { status: 502 }
    );
  }
}

// 학교 상세 정보
async function handleSchoolInfo(params: URLSearchParams, userId: string) {
  const schoolId = params.get('schoolId');
  if (!schoolId) {
    return createResponse(
      { error: 'schoolId가 필요합니다' },
      { status: 400 }
    );
  }

  // schoolId 형식 검증 (숫자만 허용)
  if (!/^\d+$/.test(schoolId)) {
    return createResponse(
      { error: '올바르지 않은 schoolId 형식입니다' },
      { status: 400 }
    );
  }

  const apiUrl = new URL(`${NEIS_BASE_URL}/schoolInfo`);
  apiUrl.searchParams.set('KEY', NEIS_API_KEY!);
  apiUrl.searchParams.set('Type', 'json');
  apiUrl.searchParams.set('SD_SCHUL_CODE', schoolId);

  try {
    const response = await fetch(apiUrl.toString());

    if (!response.ok) {
      throw new Error(`NEIS API 오류: ${response.status}`);
    }

    const data = await response.json();

    const school = data?.schoolInfo?.[1]?.row?.[0];
    if (!school) {
      return createResponse(
        { error: '학교 정보를 찾을 수 없습니다' },
        { status: 404 }
      );
    }

    console.log(`[NEIS] 상세: ${schoolId} by ${userId}`);

    return createResponse({
      schoolId: school.SD_SCHUL_CODE,
      name: school.SCHUL_NM,
      address: school.ORG_RDNMA,
      phone: school.ORG_TELNO,
      homepage: school.HMPG_ADRES,
      eduOfficeCode: school.ATPT_OFCDC_SC_CODE,
      eduOfficeName: school.ATPT_OFCDC_SC_NM,
    });
  } catch (error) {
    console.error('NEIS API 호출 실패:', error);
    return createResponse(
      { error: '학교 정보를 가져올 수 없습니다' },
      { status: 502 }
    );
  }
}

// ====================================
// Rate Limiting 예시 (Upstash Redis 사용)
// ====================================

/*
import { Redis } from 'https://esm.sh/@upstash/redis';

const redis = new Redis({
  url: Deno.env.get('UPSTASH_REDIS_URL')!,
  token: Deno.env.get('UPSTASH_REDIS_TOKEN')!,
});

async function checkRateLimit(userId: string): Promise<boolean> {
  const key = `rate_limit:neis:${userId}`;
  const limit = 60; // 분당 60회
  const ttl = 60; // 1분

  const current = await redis.incr(key);
  if (current === 1) {
    await redis.expire(key, ttl);
  }

  return current <= limit;
}
*/
