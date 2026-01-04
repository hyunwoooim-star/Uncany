import 'package:flutter/material.dart';

import 'package:uncany/src/shared/theme/toss_colors.dart';

/// 재직증명서 확인 다이얼로그
///
/// 이미지 확대/축소 및 다운로드 기능 제공
class DocumentViewer extends StatefulWidget {
  final String documentUrl;
  final String userName;

  const DocumentViewer({
    super.key,
    required this.documentUrl,
    required this.userName,
  });

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            color: TossColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.userName} 선생님',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TossColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '재직증명서',
                        style: TextStyle(
                          fontSize: 14,
                          color: TossColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.zoom_out_map),
                  tooltip: '확대/축소 초기화',
                  color: TossColors.textSub,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: '닫기',
                  color: TossColors.textSub,
                ),
              ],
            ),
          ),

          // 이미지 뷰어 (확대/축소 가능)
          Expanded(
            child: Container(
              color: Colors.black87,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.documentUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: TossColors.primary,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.white54,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '이미지를 불러올 수 없습니다',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.documentUrl,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // 하단 안내
          Container(
            padding: const EdgeInsets.all(16),
            color: TossColors.surface,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: TossColors.textSub.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '두 손가락으로 확대/축소할 수 있습니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: TossColors.textSub.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
