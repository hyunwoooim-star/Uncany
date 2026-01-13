// ====================================
// CORS 헬퍼 (Edge Functions 공통)
// ====================================

export function createResponse(
  data: any,
  options: { status?: number; headers?: Record<string, string> } = {}
) {
  const defaultHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type',
  };

  return new Response(JSON.stringify(data), {
    status: options.status || 200,
    headers: {
      ...defaultHeaders,
      ...options.headers,
    },
  });
}
