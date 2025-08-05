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

### 네트워킹
- **http** - REST API 통신

### 라우팅
- **go_router** - 선언적 라우팅

### Native 개발
- **Android (Kotlin)** - 홈화면 위젯 구현

## 🏗 아키텍처 설계

### 디렉토리 구조
```
lib/
├── core/ # 공통 기능
│   ├── constants/
│   ├── errors/
│   └── utils/
├── data/ # 데이터 계층
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/ # 비즈니스 로직 계층
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/ # UI 계층
│   ├── providers/
│   ├── pages/
│   └── widgets/
└── main.dart
```

## 📱 주요 기능

### ✅ 구현 완료
- [x] GitHub Repository 검색 (디바운싱 300ms)
- [x] 검색 결과 페이지네이션
- [x] 즐겨찾기 추가/제거
- [x] 즐겨찾기 목록 조회
- [x] 오프라인 즐겨찾기 데이터 접근
- [x] Bottom Navigation
- [ ] Android 홈화면 위젯 (예정)

## 🔧 개발 과정

### 1단계: Core 인프라 구축 ⚡
**소요 시간**: 1-2시간

**구현 내용**:
- API 상수 정의 (`api_constants.dart`)
- 예외 처리 클래스 구조 설계 (`exceptions.dart`)
- 검색 디바운서 유틸리티 (`debouncer.dart`)
- 도메인 엔티티 정의 (`repository_entity.dart`)
- JSON 직렬화 모델 구조 설계

### 2단계: GitHub API 연동 🔌
**소요 시간**: 2-3시간

**구현 내용**:
- HTTP 통신 데이터소스 (`github_remote_datasource.dart`)
- 검색 상태 관리 Provider (`search_provider.dart`)
- SearchPage UI 구현
    - 실시간 검색 입력창
    - 디바운싱 적용 검색
    - 무한 스크롤 페이지네이션
    - 로딩/에러/빈결과 상태 UI
- RepositoryItem 위젯 구현
    - 저장소 정보 표시
    - 소유자 아바타, 언어 칩
    - 상세 정보 다이얼로그

### 3단계: 로컬 데이터베이스 연동 💾
**소요 시간**: 2-3시간

**구현 내용**:
- Hive 데이터베이스 설정
- 북마크 모델 및 TypeAdapter (`bookmark_model.dart`)
- 로컬 데이터소스 (`bookmark_local_datasource.dart`)
- 북마크 상태 관리 Provider (`bookmark_provider.dart`)
- BookmarkPage UI 구현
    - 북마크 목록 표시 (최신순)
    - 개별/전체 삭제 기능
    - 실행취소 기능
    - Pull-to-refresh
- 검색-북마크 화면 간 상태 동기화

### 4단계: 홈화면 위젯 📱
**예정 소요 시간**: 1-2시간

**구현 예정**:
- Android 네이티브 위젯 코드 (Kotlin)
- 최근 북마크 저장소 표시
- Flutter와 네이티브 간 데이터 통신

## 🚀 실행 방법

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (JSON 직렬화, Hive TypeAdapter)
dart run build_runner build --delete-conflicting-outputs

# Android 에뮬레이터 실행
flutter run

# 빌드
flutter build apk
```

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

## 🎯 학습 성과

### Flutter 개발 역량 습득
- **Widget 기반 UI 구조** 이해
- **Provider 패턴** 상태 관리 학습
- **Clean Architecture** 적용 경험
- **JSON 직렬화** 자동 생성 도구 활용

### Android 개발 경험과의 비교 학습
- Activity ↔ Widget 개념 매핑
- RecyclerView ↔ ListView 구조 이해
- 상태 관리 패턴 차이점 학습
- 네이티브-Flutter 하이브리드 개발 경험

---

**개발자**: ParkJooHae  
**개발 기간**: 2025년 8월 4일 ~ 2025년 8월 5일  
**총 소요 시간**: 6시간