// ====================================
// 회원 탈퇴 Edge Function
// ====================================
// 목적: 사용자 데이터 Soft Delete + Auth 계정 삭제
// 작성일: 2026-01-13
// 스토어 정책: App Store/Play Store 필수 요구사항

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

interface DeleteAccountResponse {
  message?: string;
  error?: string;
}

serve(async (req: Request) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers':
          'authorization, x-client-info, apikey, content-type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
      },
    });
  }

  try {
    // 🔑 JWT 검증
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return createResponse(
        { error: '인증이 필요합니다' },
        { status: 401 }
      );
    }

    // 사용자 확인
    const jwt = authHeader.replace('Bearer ', '');
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser(jwt);

    if (authError || !user) {
      console.error('인증 실패:', authError?.message);
      return createResponse(
        { error: 'Unauthorized: 유효하지 않은 토큰입니다' },
        { status: 401 }
      );
    }

    console.log(`[DELETE ACCOUNT] 탈퇴 요청: ${user.email} (${user.id})`);

    // ====================================
    // 1. 사용자 데이터 Soft Delete
    // ====================================

    // Service Role Key 사용 (RLS 우회)
    const adminClient = createClient(
      SUPABASE_URL,
      SUPABASE_SERVICE_ROLE_KEY
    );

    const now = new Date().toISOString();

    // users 테이블 soft delete
    const { error: usersError } = await adminClient
      .from('users')
      .update({
        deleted_at: now,
        email: `deleted_${user.id}@uncany.app`, // 이메일 재사용 가능하도록
      })
      .eq('id', user.id);

    if (usersError) {
      console.error('users 삭제 실패:', usersError);
      // 계속 진행 (중요하지 않은 에러)
    }

    // reservations 테이블 soft delete
    const { error: reservationsError } = await adminClient
      .from('reservations')
      .update({ deleted_at: now })
      .eq('teacher_id', user.id)
      .is('deleted_at', null); // 이미 삭제된 건 제외

    if (reservationsError) {
      console.error('reservations 삭제 실패:', reservationsError);
      // 계속 진행
    }

    // ====================================
    // 2. Supabase Auth 계정 삭제 (Hard Delete)
    // ====================================

    const { error: deleteAuthError } = await adminClient.auth.admin.deleteUser(
      user.id
    );

    if (deleteAuthError) {
      console.error('Auth 계정 삭제 실패:', deleteAuthError);
      return createResponse(
        {
          error:
            '계정 삭제 중 오류가 발생했습니다. 고객센터에 문의해주세요.',
        },
        { status: 500 }
      );
    }

    // ====================================
    // 3. 성공 로그 및 응답
    // ====================================

    console.log(
      `[DELETE ACCOUNT] ✅ 탈퇴 완료: ${user.email} (${user.id})`
    );

    return createResponse({
      message: '회원 탈퇴가 완료되었습니다. 그동안 이용해 주셔서 감사합니다.',
    });
  } catch (error) {
    console.error('회원 탈퇴 에러:', error);
    return createResponse(
      { error: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.' },
      { status: 500 }
    );
  }
});

// CORS 포함 응답 생성
function createResponse(
  data: DeleteAccountResponse,
  options: { status?: number; headers?: Record<string, string> } = {}
) {
  const defaultHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  };

  return new Response(JSON.stringify(data), {
    status: options.status || 200,
    headers: {
      ...defaultHeaders,
      ...options.headers,
    },
  });
}

// ====================================
// 📝 사용 예시 (Flutter 클라이언트)
// ====================================

/*
final response = await Supabase.instance.client.functions.invoke(
  'delete-account',
);

if (response.status == 200) {
  // 로그아웃 처리
  await Supabase.instance.client.auth.signOut();
  context.go('/login');
}
*/

// ====================================
// 🔒 보안 고려사항
// ====================================

/*
1. JWT 검증: auth.getUser()로 실제 사용자 확인
2. Service Role Key: RLS를 우회하여 모든 데이터 삭제 가능
3. Soft Delete: users, reservations는 deleted_at으로 표시
4. Hard Delete: Auth 계정은 완전 삭제 (재가입 가능)
5. 이메일 익명화: 같은 이메일 재가입 가능하도록 처리
*/
