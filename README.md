# jhp_github_repo_finder

GitHub Repository 검색 및 북마크 Flutter 애플리케이션

## 개요

GitHub REST API를 활용하여 저장소를 검색하고, 마음에 드는 저장소를 즐겨찾기에 추가할 수 있는 모바일 애플리케이션입니다. Android 홈화면 위젯을 통해 최근 즐겨찾기한 저장소를 확인할 수 있습니다.

## AI 도구 사용 내역

### 사용 도구
- **Claude (Anthropic)** - 프로젝트 분석, 아키텍처 설계, Flutter 학습 가이드

### 주요 프롬프트 및 활용 결과

**1. 초기 요구사항 분석**
```
해당 요구사항을 바탕으로 어떻게 개발을 진행할지 체크해줘
```
- 핵심 요구사항 분석 (GitHub API 연동, 즐겨찾기, 홈화면 위젯)
- 기술 스택 선정 (Hive, go_router 등 권장 라이브러리 채택)
- Phase별 개발 계획 수립 (8시간 분할)
- Clean Architecture 패턴 적용 결정

**2. Flutter 학습 전략 수립 및 프로젝트 설계**
```
안드로이드쪽을 기반으로 개발해야겠네. 나는 flutter개발이 처음이니 학습하며 개발을 진행하면 될거같아.
```
- Android 개발 경험 기반 Flutter 학습 로드맵 수립
- 개념 매핑 가이드 (Activity↔Widget, RecyclerView↔ListView 등)
- 단계별 학습 + 구현 계획 (프로젝트 셋업 → HTTP 통신 → 상태 관리 → 네비게이션 → Native 위젯)
- 실제 코드 예제를 통한 Flutter-Android 비교 학습

## 🛠 기술 스택

### Frontend
- **Flutter** 3.0+
- **Dart** 3.0+

### 상태 관리
- **Provider**

### 데이터 저장
- **Hive** - 로컬 NoSQL 데이터베이스
- **SharedPreferences** - 간단한 키값 저장

### 네트워킹
- **http** 또는 **dio** - REST API 통신

### 라우팅
- **go_router** - 선언적 라우팅

### Native 개발
- **Android (Kotlin)** - 홈화면 위젯 구현

## 🏗 아키텍처 설계

### 디렉토리 구조
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── providers/
│   ├── pages/
│   └── widgets/
└── main.dart
```
## 📱 주요 기능

### ✅ 구현 완료
- [ ] GitHub Repository 검색 (디바운싱 300ms)
- [ ] 검색 결과 페이지네이션
- [ ] 즐겨찾기 추가/제거
- [ ] 즐겨찾기 목록 조회
- [ ] 오프라인 즐겨찾기 데이터 접근
- [ ] Bottom Navigation
- [ ] Android 홈화면 위젯

### 🔄 개발 진행사항
- [x] 요구사항 분석 및 기술 스택 선정
- [x] 프로젝트 구조 설계
- [ ] Flutter 환경 설정
- [ ] GitHub API 연동
- [ ] UI 구현
- [ ] 로컬 데이터베이스 연동
- [ ] Android 위젯 구현

## 📖 학습 과정에서 참고한 자료

1. **Flutter 공식 문서**: [flutter.dev](https://flutter.dev)
2. **Android 개발자를 위한 Flutter**: [flutter.dev/docs/get-started/flutter-for/android-devs](https://flutter.dev/docs/get-started/flutter-for/android-devs)
3. **GitHub REST API 문서**: [docs.github.com/en/rest](https://docs.github.com/en/rest)

## 💡 추가 고려사항

### 성능 최적화
- 검색 결과 이미지 캐싱
- 무한 스크롤 최적화
- 메모리 사용량 모니터링

### 사용자 경험
- 로딩 상태 표시
- 에러 상태 처리
- 오프라인 상태 안내

### 접근성
- 스크린 리더 지원
- 적절한 터치 영역 크기
- 고대비 모드 지원

---

**개발자**: ParkJooHae  
**개발 기간**: 2025년 8월 4일 ~ 2025 8월 9일