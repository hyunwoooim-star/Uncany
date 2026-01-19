import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/auth_repository_provider.dart';
import 'package:uncany/src/core/providers/auth_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';

/// 프로필 수정 화면 (v0.2)
///
/// 이름, 학년, 반 수정 가능
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int? _selectedGrade;
  int? _selectedClassNum;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      _selectedGrade = user.grade;
      _selectedClassNum = user.classNum;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGrade == null || _selectedClassNum == null) {
      setState(() {
        _errorMessage = '학년과 반을 선택해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updateProfile(
        name: _nameController.text.trim(),
        grade: _selectedGrade,
        classNum: _selectedClassNum,
      );

      // Provider 갱신
      ref.invalidate(currentUserProvider);

      if (mounted) {
        TossSnackBar.success(context, message: '프로필이 업데이트되었습니다');
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('프로필 수정'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 안내
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: TossColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '이름, 학년, 반을 수정할 수 있습니다.\n학교와 아이디는 변경할 수 없습니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: TossColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 학교 (읽기 전용)
            TextFormField(
              initialValue: currentUser?.schoolName ?? '',
              decoration: InputDecoration(
                labelText: '학교',
                prefixIcon: const Icon(Icons.school_outlined),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: TossColors.disabled.withOpacity(0.1),
              ),
              readOnly: true,
              enabled: false,
            ),

            const SizedBox(height: 16),

            // 이름
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                hintText: '홍길동',
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
                suffixText: '선생님',
                suffixStyle: TextStyle(
                  color: TossColors.textSub,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return ErrorMessages.requiredField;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // 학년/반 선택
            Row(
              children: [
                // 학년 선택
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      labelText: '학년',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(6, (index) {
                      final grade = index + 1;
                      return DropdownMenuItem(
                        value: grade,
                        child: Text('$grade학년'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedGrade = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return '선택';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // 반 선택
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedClassNum,
                    decoration: const InputDecoration(
                      labelText: '반',
                      prefixIcon: Icon(Icons.groups_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(15, (index) {
                      final classNum = index + 1;
                      return DropdownMenuItem(
                        value: classNum,
                        child: Text('$classNum반'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedClassNum = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return '선택';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 미리보기
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TossColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '예약 시 표시되는 이름',
                    style: TextStyle(
                      fontSize: 12,
                      color: TossColors.textSub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPreviewDisplayName(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TossColors.textMain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 에러 메시지
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_errorMessage != null) const SizedBox(height: 16),

            // 저장 버튼
            TossButton(
              onPressed: _saveProfile,
              isLoading: _isLoading,
              child: const Text('저장'),
            ),

            const SizedBox(height: 8),

            // 취소 버튼
            OutlinedButton(
              onPressed: _isLoading ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: TossColors.textSub,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('취소'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPreviewDisplayName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '이름을 입력해주세요';

    if (_selectedGrade != null && _selectedClassNum != null) {
      return '$name 선생님 ($_selectedGrade학년 $_selectedClassNum반)';
    } else if (_selectedGrade != null) {
      return '$name 선생님 ($_selectedGrade학년)';
    }
    return '$name 선생님';
  }
}
