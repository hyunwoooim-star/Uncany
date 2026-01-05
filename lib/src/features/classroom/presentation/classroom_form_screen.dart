import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/classroom_repository_provider.dart';
import '../domain/models/classroom.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/constants/period_times.dart';

/// 교실 등록/수정 폼 화면 (v0.2)
///
/// 모든 선생님이 교실을 추가/수정할 수 있음
class ClassroomFormScreen extends ConsumerStatefulWidget {
  final Classroom? classroom; // null이면 생성, 있으면 수정

  const ClassroomFormScreen({
    super.key,
    this.classroom,
  });

  @override
  ConsumerState<ClassroomFormScreen> createState() =>
      _ClassroomFormScreenState();
}

class _ClassroomFormScreenState extends ConsumerState<ClassroomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accessCodeController = TextEditingController();
  final _noticeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();

  RoomType _selectedRoomType = RoomType.other;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _clearAccessCode = false;
  bool _clearNotice = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.classroom != null) {
      final classroom = widget.classroom!;
      _nameController.text = classroom.name;
      _noticeController.text = classroom.noticeMessage ?? '';
      _capacityController.text = classroom.capacity?.toString() ?? '';
      _locationController.text = classroom.location ?? '';
      _selectedRoomType = RoomType.fromCode(classroom.roomType);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accessCodeController.dispose();
    _noticeController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(classroomRepositoryProvider);
      final name = _nameController.text.trim();
      final accessCode = _accessCodeController.text.trim();
      final notice = _noticeController.text.trim();
      final capacity = int.tryParse(_capacityController.text.trim());
      final location = _locationController.text.trim();

      if (widget.classroom == null) {
        // 생성
        await repository.createClassroom(
          name: name,
          accessCode: accessCode.isEmpty ? null : accessCode,
          noticeMessage: notice.isEmpty ? null : notice,
          capacity: capacity,
          location: location.isEmpty ? null : location,
          roomType: _selectedRoomType.code,
        );
      } else {
        // 수정
        await repository.updateClassroom(
          widget.classroom!.id,
          name: name,
          accessCode: accessCode.isEmpty ? null : accessCode,
          clearAccessCode: _clearAccessCode,
          noticeMessage: notice.isEmpty ? null : notice,
          clearNotice: _clearNotice,
          capacity: capacity,
          location: location.isEmpty ? null : location,
          roomType: _selectedRoomType.code,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.classroom == null
                  ? '교실이 추가되었습니다'
                  : '교실이 수정되었습니다',
            ),
            backgroundColor: TossColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorMessages.fromError(e);
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.classroom != null;
    final hasExistingPassword = widget.classroom?.accessCodeHash != null;

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: Text(isEditing ? '교실 수정' : '교실 추가'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 교실 유형 선택
            _buildSectionTitle('교실 유형'),
            const SizedBox(height: 8),
            _buildRoomTypeSelector(),

            const SizedBox(height: 24),

            // 교실 이름 (필수)
            _buildSectionTitle('교실 정보'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '교실 이름',
                hintText: '예: ${_selectedRoomType.label} 1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: TossColors.surface,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '교실 이름을 입력해주세요';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),

            const SizedBox(height: 16),

            // 위치 (선택)
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: '위치',
                hintText: '예: 3층',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: TossColors.surface,
                helperText: '선택사항',
              ),
              enabled: !_isSubmitting,
            ),

            const SizedBox(height: 16),

            // 수용 인원 (선택)
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '수용 인원',
                hintText: '예: 30',
                suffixText: '명',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: TossColors.surface,
                helperText: '선택사항',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final number = int.tryParse(value.trim());
                  if (number == null || number <= 0) {
                    return '올바른 숫자를 입력해주세요';
                  }
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),

            const SizedBox(height: 24),

            // 출입 비밀번호 (선택)
            _buildSectionTitle('출입 비밀번호'),
            const SizedBox(height: 4),
            Text(
              '교실 자물쇠 비밀번호 등을 메모해두세요',
              style: TextStyle(
                fontSize: 13,
                color: TossColors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _accessCodeController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: hasExistingPassword
                        ? '변경하려면 새 비밀번호 입력'
                        : '예: 1234',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: TossColors.surface,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  enabled: !_isSubmitting && !_clearAccessCode,
                ),
                if (hasExistingPassword) ...[
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _clearAccessCode,
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _clearAccessCode = value ?? false;
                              if (_clearAccessCode) {
                                _accessCodeController.clear();
                              }
                            });
                          },
                    title: const Text(
                      '비밀번호 제거',
                      style: TextStyle(fontSize: 14),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // 공지사항 (선택)
            _buildSectionTitle('공지사항'),
            const SizedBox(height: 4),
            Text(
              '이용 안내, 주의사항, 고장 등을 알려주세요',
              style: TextStyle(
                fontSize: 13,
                color: TossColors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _noticeController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '공지사항',
                    hintText: '예: 에어컨 고장, 수리 중',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: TossColors.surface,
                  ),
                  enabled: !_isSubmitting && !_clearNotice,
                ),
                if (isEditing && widget.classroom!.noticeMessage != null) ...[
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _clearNotice,
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _clearNotice = value ?? false;
                              if (_clearNotice) {
                                _noticeController.clear();
                              }
                            });
                          },
                    title: const Text(
                      '공지사항 제거',
                      style: TextStyle(fontSize: 14),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ],
            ),

            // 에러 메시지
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TossColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 20, color: TossColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: TossColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 제출 버튼
            TossButton(
              onPressed: _submit,
              isLoading: _isSubmitting,
              child: Text(_isSubmitting
                  ? '저장 중...'
                  : isEditing
                      ? '수정하기'
                      : '교실 추가'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: TossColors.textMain,
      ),
    );
  }

  Widget _buildRoomTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RoomType.values.map((type) {
        final isSelected = _selectedRoomType == type;
        return GestureDetector(
          onTap: _isSubmitting
              ? null
              : () {
                  setState(() {
                    _selectedRoomType = type;
                  });
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? TossColors.primary
                  : TossColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? TossColors.primary
                    : TossColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRoomTypeIcon(type),
                  size: 18,
                  color: isSelected ? Colors.white : TossColors.textSub,
                ),
                const SizedBox(width: 6),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : TossColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getRoomTypeIcon(RoomType type) {
    switch (type) {
      case RoomType.computer:
        return Icons.computer;
      case RoomType.music:
        return Icons.music_note;
      case RoomType.science:
        return Icons.science;
      case RoomType.art:
        return Icons.palette;
      case RoomType.library:
        return Icons.menu_book;
      case RoomType.gym:
        return Icons.sports_basketball;
      case RoomType.auditorium:
        return Icons.theater_comedy;
      case RoomType.special:
        return Icons.star;
      case RoomType.other:
        return Icons.room;
    }
  }
}
