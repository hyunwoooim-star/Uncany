import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

/// 감사 로그 화면
class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  final _supabase = Supabase.instance.client;
  String _filterAction = 'all';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  /// 감사 로그 조회
  Future<List<Map<String, dynamic>>> _fetchAuditLogs() async {
    var query = _supabase
        .from('audit_logs')
        .select('*, users!audit_logs_user_id_fkey(name)')
        .order('created_at', ascending: false)
        .limit(100);

    // 액션 필터
    if (_filterAction != 'all') {
      query = query.eq('operation', _filterAction.toUpperCase());
    }

    // 날짜 필터
    if (_filterStartDate != null) {
      query = query.gte('created_at', _filterStartDate!.toIso8601String());
    }
    if (_filterEndDate != null) {
      query = query.lte('created_at', _filterEndDate!.toIso8601String());
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('활동 기록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildAuditLogList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('전체'),
            selected: _filterAction == 'all',
            onSelected: (selected) {
              if (selected) setState(() => _filterAction = 'all');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('예약'),
            selected: _filterAction == 'reservation',
            onSelected: (selected) {
              if (selected) setState(() => _filterAction = 'reservation');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('교실'),
            selected: _filterAction == 'classroom',
            onSelected: (selected) {
              if (selected) setState(() => _filterAction = 'classroom');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('사용자'),
            selected: _filterAction == 'user',
            onSelected: (selected) {
              if (selected) setState(() => _filterAction = 'user');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchAuditLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('오류가 발생했습니다: ${snapshot.error}'),
              ],
            ),
          );
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('활동 기록이 없습니다'),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildAuditLogItem(log);
          },
        );
      },
    );
  }

  Widget _buildAuditLogItem(Map<String, dynamic> log) {
    final operation = log['operation'] as String;
    final tableName = log['table_name'] as String;
    final userName = log['users']?['name'] ?? '알 수 없음';
    final createdAt = DateTime.parse(log['created_at'] as String);
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

    // 설명 생성
    String description = _getOperationDescription(operation, tableName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildActionIcon(operation.toLowerCase()),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$userName • $formattedTime',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (log['new_snapshot'] != null || log['old_snapshot'] != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildSnapshot(
              log['old_snapshot'] as Map<String, dynamic>?,
              log['new_snapshot'] as Map<String, dynamic>?,
            ),
          ),
        ],
      ],
    );
  }

  String _getOperationDescription(String operation, String tableName) {
    final tableKorean = _getTableKoreanName(tableName);
    switch (operation.toUpperCase()) {
      case 'INSERT':
        return '$tableKorean 생성';
      case 'UPDATE':
        return '$tableKorean 수정';
      case 'DELETE':
        return '$tableKorean 삭제';
      case 'RESTORE':
        return '$tableKorean 복원';
      default:
        return '$tableKorean $operation';
    }
  }

  String _getTableKoreanName(String tableName) {
    switch (tableName) {
      case 'users':
        return '사용자';
      case 'reservations':
        return '예약';
      case 'classrooms':
        return '교실';
      case 'schools':
        return '학교';
      default:
        return tableName;
    }
  }

  Widget _buildActionIcon(String action) {
    IconData icon;
    Color color;

    switch (action.toUpperCase()) {
      case 'INSERT':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'UPDATE':
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case 'DELETE':
        icon = Icons.delete;
        color = Colors.red;
        break;
      case 'RESTORE':
        icon = Icons.restore;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildSnapshot(
    Map<String, dynamic>? oldSnapshot,
    Map<String, dynamic>? newSnapshot,
  ) {
    if (oldSnapshot == null && newSnapshot == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (oldSnapshot != null) ...[
          const Text(
            '이전 값:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatSnapshot(oldSnapshot),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontFamily: 'monospace',
            ),
          ),
        ],
        if (oldSnapshot != null && newSnapshot != null)
          const SizedBox(height: 8),
        if (newSnapshot != null) ...[
          const Text(
            '새로운 값:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatSnapshot(newSnapshot),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    );
  }

  String _formatSnapshot(Map<String, dynamic> snapshot) {
    // 중요한 필드만 표시 (password, 민감정보 제외)
    final filtered = Map<String, dynamic>.from(snapshot);
    filtered.remove('password');
    filtered.remove('hashed_password');
    filtered.remove('email_verified_token');

    return filtered.entries
        .map((e) => '${e.key}: ${e.value}')
        .take(5) // 최대 5개 필드만 표시
        .join('\n');
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: 날짜 범위 선택기 추가
            const Text('날짜 범위 필터 (추후 구현)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                // 필터 적용 후 화면 새로고침
              });
              Navigator.pop(context);
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }
}
