# 🏫 Uncany - 학교 커뮤니티 플랫폼

> 교사들이 학교 리소스를 예약하고 관리하는 신뢰 기반 커뮤니티 플랫폼

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🎯 프로젝트 비전

교육 현장의 리소스 관리를 **토스(Toss)** 수준의 직관적인 UX로 혁신합니다.

### 핵심 가치
- ✅ **신뢰 기반 인증**: 재직증명서 + 교육청 이메일 검증
- ⏰ **직관적 예약**: 복잡한 엑셀 시간표 → 터치 한 번
- 🔒 **데이터 무결성**: Soft Delete + Audit Log로 실수 방지
- 🎨 **아름다운 디자인**: 토스 스타일의 매끄러운 인터랙션

---

## 🚀 빠른 시작

### 사전 요구사항
- Flutter SDK 3.24 이상
- Supabase 계정
- Git

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/yourusername/uncany.git
cd uncany

# 2. 의존성 설치
flutter pub get

# 3. 환경 변수 설정
cp .env.example .env
# .env 파일에 Supabase URL/Key 입력

# 4. 코드 생성 (Freezed, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# 5. 실행
flutter run -d chrome        # Web
flutter run -d ios           # iOS
flutter run -d android       # Android
```

---

## 📚 문서

- [📋 프로젝트 계획서](PROJECT_PLAN.md) - 전체 개발 로드맵
- [📝 변경 이력](CHANGELOG.md) - 버전별 변경사항
- [🗄️ 데이터베이스 스키마](docs/DATABASE.md) - DB 구조 및 관계
- [🔌 API 문서](docs/API.md) - REST API 명세

---

## 🛠️ 기술 스택

### Frontend
```yaml
Flutter 3.24+          # 크로스 플랫폼 프레임워크
├─ Riverpod 2.5+      # 상태 관리
├─ GoRouter 14.0+     # 라우팅
├─ Freezed 2.5+       # 불변 모델
└─ flutter_animate    # 애니메이션
```

### Backend
```yaml
Supabase              # BaaS
├─ PostgreSQL 15+    # 관계형 DB
├─ Row Level Security # 권한 제어
├─ Storage           # 파일 저장소
└─ Auth              # 인증/인가
```

---

## 🏗️ 프로젝트 구조

```
uncany/
├── lib/src/
│   ├── features/         # 기능별 모듈
│   │   ├── auth/        # 인증
│   │   ├── reservation/ # 예약
│   │   └── audit/       # 감사 로그
│   ├── shared/          # 공통 위젯
│   └── core/            # 앱 설정
├── supabase/            # 백엔드
│   ├── migrations/      # DB 마이그레이션
│   └── functions/       # Edge Functions
├── docs/                # 문서
└── test/                # 테스트
```

자세한 내용은 [프로젝트 계획서](PROJECT_PLAN.md)를 참조하세요.

---

## 🎨 디자인 시스템

### 컬러 팔레트 (토스 스타일)
```dart
Primary:    #3182F6  // 토스 블루
Background: #F2F4F6  // 라이트 그레이
Surface:    #FFFFFF  // 화이트
TextMain:   #191F28  // 다크 그레이
TextSub:    #4E5968  // 미디엄 그레이
```

### 타이포그래피
- **헤딩**: Pretendard Bold (또는 Noto Sans KR)
- **본문**: Pretendard Regular
- **크기**: 24pt (Heading) / 16pt (Body) / 14pt (Caption)

---

## 🧪 테스트

```bash
# Unit 테스트
flutter test

# Widget 테스트
flutter test test/widget

# Integration 테스트
flutter test integration_test

# 커버리지 확인
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📦 배포

### Web
```bash
flutter build web --release
firebase deploy --only hosting
```

### iOS
```bash
flutter build ios --release
cd ios && fastlane beta
```

### Android
```bash
flutter build appbundle --release
cd android && fastlane beta
```

---

## 🤝 기여 가이드

현재는 AI 주도 개발 프로젝트입니다. 기여를 원하시면 이슈를 먼저 열어주세요.

### 개발 규칙
1. **Bypass 모드**: 모든 기능은 자동 진행
2. **자동 문서화**: Phase 완료 시 자동 업데이트
3. **자동 커밋**: Feature 완료 시 즉시 푸시

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

## 📞 연락처

- **GitHub**: [hyunwoooim-star/Uncany](https://github.com/hyunwoooim-star/Uncany)
- **이슈**: [Issues](https://github.com/hyunwoooim-star/Uncany/issues)

---

**Made with ❤️ by Claude & hyunwoooim-star**
