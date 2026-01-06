import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import '../../data/services/school_api_service.dart';
import '../../data/providers/school_search_provider.dart';

/// 학교 검색 자동완성 위젯
///
/// 학교명 입력 시 자동완성 목록을 보여주고,
/// 선택 시 콜백으로 알림
class SchoolSearchField extends ConsumerStatefulWidget {
  final void Function(SchoolApiResult school)? onSchoolSelected;
  final String? initialValue;
  final String? errorText;

  const SchoolSearchField({
    super.key,
    this.onSchoolSelected,
    this.initialValue,
    this.errorText,
  });

  @override
  ConsumerState<SchoolSearchField> createState() => _SchoolSearchFieldState();
}

class _SchoolSearchFieldState extends ConsumerState<SchoolSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isSearching = false;
  String _lastQuery = '';
  SchoolApiResult? _selectedSchool;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
          setState(() => _isSearching = false);
        }
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: TossColors.surface,
            child: Consumer(builder: (context, ref, _) => _buildSearchResultsWithRef(ref)),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildSearchResultsWithRef(WidgetRef ref) {
    final query = _controller.text.trim();

    if (query.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          '학교명을 2글자 이상 입력해주세요',
          style: TextStyle(
            color: TossColors.textSub,
            fontSize: 14,
          ),
        ),
      );
    }

    final searchAsync = ref.watch(schoolSearchProvider(query));

    return searchAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
              SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TossColors.primary,
              ),
              ),
              const SizedBox(width: 12),
              Text(
              '검색 중...',
              style: TextStyle(
                color: TossColors.textSub,
                fontSize: 14,
              ),
              ),
          ],
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          '검색 중 오류가 발생했습니다',
          style: TextStyle(
            color: TossColors.error,
            fontSize: 14,
          ),
        ),
      ),
      data: (schools) {
        if (schools.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                color: TossColors.textSub,
                fontSize: 14,
              ),
            ),
          );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              return _SchoolListTile(
                school: school,
                onTap: () => _selectSchool(school),
              );
            },
          ),
        );
      },
    );
  }

  void _selectSchool(SchoolApiResult school) {
    setState(() {
      _selectedSchool = school;
      _controller.text = school.name;
      _isSearching = false;
    });
    _removeOverlay();
    ref.read(selectedSchoolProvider.notifier).state = school;
    widget.onSchoolSelected?.call(school);
  }

  void _onTextChanged(String value) {
    if (value != _lastQuery) {
      _lastQuery = value;
      _selectedSchool = null;

      if (value.length >= 2) {
        setState(() {
          _isSearching = true;
        });
        _showOverlay();
      } else {
        _removeOverlay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: '학교',
              hintText: '학교명을 검색하세요',
              prefixIcon: const Icon(Icons.school_outlined),
              suffixIcon: _selectedSchool != null
                  ? Icon(
                      Icons.check_circle,
                      color: TossColors.primary,
                    )
                  : (_isSearching && _controller.text.length >= 2)
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: TossColors.primary,
                            ),
                          ),
                        )
                      : null,
              errorText: widget.errorText,
            ),
            onChanged: _onTextChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '학교를 선택해주세요';
              }
              if (_selectedSchool == null) {
                return '목록에서 학교를 선택해주세요';
              }
              return null;
            },
          ),
          if (_selectedSchool?.address != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                _selectedSchool!.address!,
                style: TextStyle(
                  color: TossColors.textSub,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 학교 목록 아이템 위젯
class _SchoolListTile extends StatelessWidget {
  final SchoolApiResult school;
  final VoidCallback onTap;

  const _SchoolListTile({
    required this.school,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
              children: [
              Icon(
              Icons.school,
              color: TossColors.primary,
              size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (school.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      school.address!,
                      style: TextStyle(
                        fontSize: 12,
                        color: TossColors.textSub,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
