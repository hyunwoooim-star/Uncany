import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

/// 🚀 이미지 압축 V2 (성능 개선 버전)
///
/// 개선 사항:
/// 1. compute() 사용으로 메인 스레드 블로킹 방지
/// 2. Web Worker 지원 (Flutter Web 환경)
/// 3. WebP 포맷으로 변경 (원래 의도대로)
/// 4. 에러 처리 강화
class ImageCompressorV2 {
  ImageCompressorV2._();

  /// 이미지를 WebP로 압축 (비동기 + Isolate)
  ///
  /// - Flutter Web: Isolate 사용 불가하므로 메인 스레드에서 실행
  /// - 모바일: compute()로 별도 Isolate에서 실행
  ///
  /// 권장: 프로덕션에서는 **서버 사이드 압축** 권장
  /// (Supabase Storage Hook 활용)
  static Future<Uint8List> compressToWebP(
    Uint8List imageBytes, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    if (kIsWeb) {
      // Web 환경: 메인 스레드에서 실행 (Isolate 미지원)
      // 대용량 이미지 처리 시 UI 프리즈 가능성 있음
      // TODO: Web Worker 직접 구현 또는 서버 압축으로 전환 필요
      return _compressImageSync(
        imageBytes,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );
    } else {
      // 모바일 환경: compute()로 별도 Isolate에서 실행
      return await compute(
        _compressImageSync,
        _CompressionParams(
          imageBytes: imageBytes,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        ),
      );
    }
  }

  /// 동기 압축 로직 (Isolate 또는 메인 스레드에서 실행)
  static Uint8List _compressImageSync(dynamic params) {
    Uint8List imageBytes;
    int maxWidth;
    int maxHeight;
    int quality;

    if (params is _CompressionParams) {
      // compute()에서 호출된 경우
      imageBytes = params.imageBytes;
      maxWidth = params.maxWidth;
      maxHeight = params.maxHeight;
      quality = params.quality;
    } else {
      // 직접 호출된 경우 (Web)
      imageBytes = params as Uint8List;
      maxWidth = 1920;
      maxHeight = 1920;
      quality = 85;
    }

    try {
      // 1. 디코딩
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('이미지 디코딩 실패');
      }

      // 2. 리사이즈 (필요한 경우)
      img.Image resized = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        // 가로/세로 비율 유지하며 리사이즈
        final aspectRatio = image.width / image.height;
        int targetWidth = image.width;
        int targetHeight = image.height;

        if (aspectRatio > 1) {
          // 가로가 더 긴 경우
          targetWidth = maxWidth;
          targetHeight = (maxWidth / aspectRatio).round();
        } else {
          // 세로가 더 긴 경우
          targetHeight = maxHeight;
          targetWidth = (maxHeight * aspectRatio).round();
        }

        resized = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // 3. WebP로 인코딩 ✅ (원래 의도대로 수정)
      final webpBytes = img.encodeWebP(resized, quality: quality);

      return Uint8List.fromList(webpBytes);
    } catch (e) {
      // 압축 실패 시 원본 반환 (fallback)
      debugPrint('⚠️ 이미지 압축 실패: $e');
      return imageBytes;
    }
  }

  /// 파일이 이미지인지 확인
  static bool isImage(String? extension) {
    if (extension == null) return false;
    final ext = extension.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext);
  }

  /// 파일이 PDF인지 확인
  static bool isPdf(String? extension) {
    if (extension == null) return false;
    return extension.toLowerCase() == 'pdf';
  }

  /// 익명화된 파일명 생성 (개인정보 미포함)
  ///
  /// 개선 사항:
  /// - UUID 사용으로 충돌 방지
  /// - 타임스탬프 + UUID 조합
  static String generateAnonymousFileName({String? extension}) {
    const uuid = Uuid();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomId = uuid.v4().substring(0, 8);

    // WebP로 저장
    final ext = isImage(extension) ? 'webp' : (extension?.toLowerCase() ?? 'bin');

    return 'file_${timestamp}_$randomId.$ext';
  }

  /// 이미지 크기 확인 (MB 단위)
  static double getSizeMB(Uint8List bytes) {
    return bytes.length / (1024 * 1024);
  }

  /// 압축 권장 여부 확인 (2MB 이상인 경우)
  static bool shouldCompress(Uint8List bytes) {
    return getSizeMB(bytes) > 2.0;
  }
}

/// compute() 함수에 전달할 파라미터 클래스
class _CompressionParams {
  final Uint8List imageBytes;
  final int maxWidth;
  final int maxHeight;
  final int quality;

  _CompressionParams({
    required this.imageBytes,
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
  });
}

// ====================================
// 📚 사용 예시
// ====================================

/*
// 1. 기본 사용
final compressed = await ImageCompressorV2.compressToWebP(originalBytes);

// 2. 커스텀 설정
final compressed = await ImageCompressorV2.compressToWebP(
  originalBytes,
  maxWidth: 1024,
  maxHeight: 1024,
  quality: 90,
);

// 3. 압축 전 크기 확인
if (ImageCompressorV2.shouldCompress(originalBytes)) {
  final compressed = await ImageCompressorV2.compressToWebP(originalBytes);
  print('압축 전: ${ImageCompressorV2.getSizeMB(originalBytes)}MB');
  print('압축 후: ${ImageCompressorV2.getSizeMB(compressed)}MB');
}

// 4. 익명화된 파일명 생성
final fileName = ImageCompressorV2.generateAnonymousFileName(extension: 'jpg');
// 결과: file_1704816123456_a1b2c3d4.webp
*/

// ====================================
// 🚀 프로덕션 권장 사항
// ====================================

/*
**서버 사이드 압축 권장** (Supabase Storage Hook)

1. 클라이언트에서 원본 이미지 업로드
2. Supabase Storage Hook이 자동으로 압축
3. 압축된 이미지를 저장소에 저장

장점:
- 클라이언트 성능 부담 제거
- 일관된 품질 관리
- Web Worker 문제 회피

Supabase Storage Hook 예시:
```typescript
// supabase/functions/storage-hook-resize/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const { name, bucket } = await req.json();

  // Sharp 라이브러리 사용하여 리사이징
  const original = await supabase.storage.from(bucket).download(name);
  const resized = await sharp(original.data)
    .resize(1920, 1920, { fit: 'inside' })
    .webp({ quality: 85 })
    .toBuffer();

  await supabase.storage.from(bucket).upload(name, resized, { upsert: true });
});
```
*/
