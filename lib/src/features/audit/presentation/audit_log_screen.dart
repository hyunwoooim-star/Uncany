import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 감사 로그 화면
class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  String _filterAction = 'all';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

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
    // TODO: 실제 데이터 연결
    final mockLogs = _getMockLogs();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mockLogs.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final log = mockLogs[index];
        return _buildAuditLogItem(log);
      },
    );
  }

  Widget _buildAuditLogItem(Map<String, dynamic> log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildActionIcon(log['action'] as String),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log['description'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${log['user']} • ${log['timestamp']}',
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
        if (log['changes'] != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildChanges(log['changes'] as Map<String, dynamic>),
          ),
        ],
      ],
    );
  }

  Widget _buildActionIcon(String action) {
    IconData icon;
    Color color;

    switch (action) {
      case 'create':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'update':
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case 'delete':
        icon = Icons.delete;
        color = Colors.red;
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

  Widget _buildChanges(Map<String, dynamic> changes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: changes.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (entry.value['old'] != null) ...[
                Text(
                  entry.value['old'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.red[700],
                  ),
                ),
                const Text(' → '),
              ],
              Text(
                entry.value['new'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
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
              // TODO: 필터 적용
              Navigator.pop(context);
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockLogs() {
    return [
      {
        'action': 'create',
        'description': '새 예약 생성',
        'user': '김선생',
        'timestamp': '3분 전',
        'changes': {
          '교실': {'new': '과학실 1'},
          '시간': {'new': '2026-01-05 14:00 - 16:00'},
        },
      },
      {
        'action': 'update',
        'description': '예약 수정',
        'user': '이선생',
        'timestamp': '1시간 전',
        'changes': {
          '시간': {
            'old': '2026-01-05 10:00 - 12:00',
            'new': '2026-01-05 14:00 - 16:00',
          },
        },
      },
      {
        'action': 'delete',
        'description': '예약 취소',
        'user': '박선생',
        'timestamp': '2시간 전',
        'changes': null,
      },
      {
        'action': 'create',
        'description': '새 교실 등록',
        'user': '관리자',
        'timestamp': '어제',
        'changes': {
          '이름': {'new': '음악실 2'},
          '수용인원': {'new': '30명'},
        },
      },
    ];
  }
}
