# Uncany 트러블슈팅 가이드

## 목차
1. [학교 검색 드롭다운 클릭 안됨](#1-학교-검색-드롭다운-클릭-안됨)
2. [사용자 정보 없음 오류](#2-사용자-정보-없음-오류)
3. [Windows 빌드 셰이더 오류](#3-windows-빌드-셰이더-오류)
4. [DB 컬럼 없음 오류](#4-db-컬럼-없음-오류)

---

## 1. 학교 검색 드롭다운 클릭 안됨

### 증상
- 회원가입 페이지에서 학교명 검색 후 드롭다운 항목 클릭해도 반응 없음
- 로딩 스피너가 계속 돌아감

### 원인
Flutter Web에서 Overlay 위젯의 포커스/클릭 이벤트 처리 문제:
1. Overlay 클릭 시 TextField가 먼저 포커스를 잃음
2. `_onFocusChange`가 즉시 실행되어 overlay 제거
3. 클릭 이벤트가 처리되기 전에 overlay가 사라짐

### 해결 방법

`school_search_field.dart` 수정:

```dart
// 1. _onFocusChange에 딜레이 추가
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

// 2. InkWell 대신 MouseRegion + GestureDetector 사용
return MouseRegion(
  cursor: SystemMouseCursors.click,
  child: GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(...),
  ),
);

// 3. Overlay 내부에 Consumer 추가
child: Consumer(
  builder: (context, ref, _) => _buildSearchResultsWithRef(ref),
),
```

---

## 2. 사용자 정보 없음 오류

### 증상
- 로그인 성공 후 홈 화면에 "사용자 정보 없음" 표시
- 다른 UI 요소가 보이지 않음

### 원인
1. `users` 테이블에 해당 사용자 행이 없음
2. `school_name` 컬럼이 NULL (required 필드)
3. DB 스키마가 v0.2로 업데이트되지 않음

### 해결 방법

**Supabase SQL Editor에서 확인:**
```sql
SELECT id, email, name, school_name FROM users WHERE email = '사용자이메일';
```

**school_name이 NULL인 경우:**
```sql
UPDATE users SET school_name = '학교이름' WHERE school_name IS NULL;
```

---

## 3. Windows 빌드 셰이더 오류

### 증상
```
Target web_release_bundle failed: ShaderCompilerException:
Shader compilation of "ink_sparkle.frag" failed with exit code -1073741819
```

### 원인
Windows에서 Flutter의 Impeller 셰이더 컴파일러 문제

### 해결 방법

**방법 1: GitHub Actions 사용 (권장)**
```bash
git push origin main
# GitHub Actions가 Ubuntu에서 자동 빌드/배포
```

**방법 2: WSL 사용**
```bash
wsl -d Ubuntu
cd /mnt/c/Users/사용자/프로젝트
flutter build web --release
```

**방법 3: flutter clean 후 재시도**
```bash
flutter clean
flutter pub get
flutter build web --release
```

---

## 4. DB 컬럼 없음 오류

### 증상
```
ERROR: 42703: column "school_id" does not exist
```

### 원인
v0.2 데이터베이스 마이그레이션이 적용되지 않음

### 해결 방법

**Supabase SQL Editor에서 순서대로 실행:**

```sql
-- 1. schools 테이블 생성 (한 줄로)
CREATE TABLE IF NOT EXISTS schools (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), code VARCHAR(10) UNIQUE, name TEXT NOT NULL, address TEXT, school_type VARCHAR(20) DEFAULT 'elementary', office_code VARCHAR(10), created_at TIMESTAMPTZ DEFAULT now());

-- 2. users 테이블 컬럼 추가
ALTER TABLE users
ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id),
ADD COLUMN IF NOT EXISTS grade INTEGER,
ADD COLUMN IF NOT EXISTS class_num INTEGER,
ADD COLUMN IF NOT EXISTS username TEXT;

-- 3. reservations 테이블 컬럼 추가 (필요시)
ALTER TABLE reservations
ADD COLUMN IF NOT EXISTS periods INTEGER[];
```

---

## 일반 디버깅 팁

### Flutter 분석
```bash
flutter analyze lib/
flutter analyze lib/파일경로.dart --no-fatal-infos
```

### Supabase 로그 확인
- Supabase Dashboard → Logs → Postgres Logs

### 브라우저 콘솔 확인
- F12 → Console 탭에서 에러 메시지 확인

### Provider 상태 디버깅
```dart
// 임시 로그 추가
print('currentUser: ${ref.watch(currentUserProvider)}');
```
