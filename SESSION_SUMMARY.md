# Uncany v0.2 세션 요약

## 최종 업데이트: 2026-01-06

---

## 완료된 작업

### 1. 학교 검색 드롭다운 클릭 이슈 수정

**문제:**
- 회원가입 시 학교 검색 후 드롭다운에서 항목 클릭해도 선택 안됨
- 로딩 스피너가 계속 돌아감

**원인:**
1. 웹에서 Overlay 클릭 시 TextField 포커스가 먼저 이동
2. `_onFocusChange`가 즉시 overlay를 제거해서 클릭 이벤트 처리 전 사라짐
3. `InkWell`이 웹에서 클릭 이벤트를 제대로 받지 못함
4. Overlay 내부에서 `ref.watch()` 사용해도 재빌드 안됨

**해결:**
1. `_onFocusChange`에 200ms 딜레이 추가
2. `InkWell` → `MouseRegion + GestureDetector`로 변경
3. `_selectSchool`에서 `_isSearching = false` 설정
4. Overlay 내부에 `Consumer` 위젯 추가하여 Provider 변경 감지

**수정 파일:**
- `lib/src/features/school/presentation/widgets/school_search_field.dart`

---

### 2. 데이터베이스 마이그레이션 (v0.2)

**문제:**
- 로그인 후 "사용자 정보 없음" 표시
- `school_id` 컬럼이 존재하지 않음

**원인:**
- v0.2 DB 스키마 변경이 적용되지 않음
- `users` 테이블에 새 컬럼 없음
- `schools` 테이블 미생성

**해결 - SQL 실행:**

```sql
-- 1. schools 테이블 생성
CREATE TABLE IF NOT EXISTS schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(10) UNIQUE,
  name TEXT NOT NULL,
  address TEXT,
  school_type VARCHAR(20) DEFAULT 'elementary',
  office_code VARCHAR(10),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. users 테이블에 새 컬럼 추가
ALTER TABLE users
ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id),
ADD COLUMN IF NOT EXISTS grade INTEGER,
ADD COLUMN IF NOT EXISTS class_num INTEGER,
ADD COLUMN IF NOT EXISTS username TEXT;

-- 3. 기존 사용자 school_name 업데이트 (null인 경우)
UPDATE users SET school_name = '테스트학교' WHERE school_name IS NULL;
```

---

## 알려진 이슈

### Windows Flutter 빌드 셰이더 오류

**증상:**
```
Target web_release_bundle failed: ShaderCompilerException:
Shader compilation of "ink_sparkle.frag" failed with exit code -1073741819
```

**해결:**
- GitHub Actions (Ubuntu)에서 빌드 → 자동 배포
- 또는 WSL Ubuntu에서 빌드

---

## 프로젝트 구조

```
lib/
├── src/
│   ├── core/
│   │   ├── providers/
│   │   │   └── auth_provider.dart      # currentUserProvider
│   │   └── router/
│   ├── features/
│   │   ├── auth/
│   │   │   └── domain/models/user.dart # User 모델 (v0.2)
│   │   ├── school/
│   │   │   ├── data/
│   │   │   │   ├── providers/school_search_provider.dart
│   │   │   │   └── services/school_api_service.dart
│   │   │   └── presentation/widgets/
│   │   │       └── school_search_field.dart  # 수정됨
│   │   └── reservation/
│   │       └── presentation/home_screen.dart
│   └── shared/
```

---

## 배포 정보

- **Staging URL:** https://uncany-staging.web.app
- **GitHub Actions:** main 브랜치 푸시 시 자동 빌드/배포
- **워크플로우:** `.github/workflows/deploy-web-staging.yml`

---

## 다음 작업 (TODO)

- [ ] 회원가입 전체 플로우 테스트
- [ ] 예약 시스템 테스트
- [ ] 관리자 승인 기능 테스트
- [ ] Production 배포

---

## 참고 명령어

```bash
# Flutter 분석
flutter analyze lib/

# 웹 빌드 (Windows에서 오류 시 GitHub Actions 사용)
flutter build web --release

# 로컬 실행
flutter run -d chrome
```
