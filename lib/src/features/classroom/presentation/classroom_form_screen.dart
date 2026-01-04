import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/classroom_repository_provider.dart';
import '../domain/models/classroom.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 교실 등록/수정 폼 화면
///
/// 교실 생성 또는 기존 교실 수정
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

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _clearAccessCode = false; // 비밀번호 제거 플래그
  bool _clearNotice = false; // 공지사항 제거 플래그

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
      // 비밀번호는 보안상 표시하지 않음
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
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // 성공 시 true 반환
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.classroom == null
                  ? '교실이 생성되었습니다'
                  : '교실이 수정되었습니다',
            ),
            backgroundColor: Colors.green,
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
        title: Text(isEditing ? '교실 수정' : '교실 등록'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 교실 이름 (필수)
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '교실 이름 *',
                hintText: '예: 컴퓨터실 1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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

            // 비밀번호 (선택)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _accessCodeController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 (선택)',
                    hintText: hasExistingPassword
                        ? '변경하려면 새 비밀번호 입력'
                        : '비밀번호로 보호하려면 입력',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: TossColors.surface,
                    helperText: '설정하면 예약 시 비밀번호가 필요합니다',
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
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // 공지사항 (선택)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _noticeController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '공지사항 (선택)',
                    hintText: '예: 사용 후 정리 부탁드립니다',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // 수용 인원 (선택)
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '수용 인원 (선택)',
                hintText: '예: 30',
                suffixText: '명',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: TossColors.surface,
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

            const SizedBox(height: 16),

            // 위치 (선택)
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: '위치 (선택)',
                hintText: '예: 3층',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: TossColors.surface,
              ),
              enabled: !_isSubmitting,
            ),

            // 에러 메시지
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 제출 버튼
            SizedBox(
              width: double.infinity,
              child: TossButton(
                onPressed: _submit,
                isLoading: _isSubmitting,
                child: Text(_isSubmitting
                    ? '저장 중...'
                    : isEditing
                        ? '수정하기'
                        : '등록하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
