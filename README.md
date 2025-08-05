# jhp_github_repo_finder

GitHub Repository 검색 및 북마크 Flutter 애플리케이션

## 개요

GitHub REST API를 활용하여 저장소를 검색하고, 마음에 드는 저장소를 즐겨찾기에 추가할 수 있는 모바일 애플리케이션입니다. Android 홈화면 위젯을 통해 최근 즐겨찾기한 저장소를 확인할 수 있습니다.

## AI 도구 사용 내역

### 사용 도구
Claude (Anthropic) - 프로젝트 분석, 아키텍처 설계, Flutter 학습 가이드

### 주요 프롬프트 및 활용 결과

1. **초기 요구사항 분석**
  - 해당 요구사항을 바탕으로 어떻게 개발을 진행할지 체크해줘
  - 핵심 요구사항 분석 (GitHub API 연동, 즐겨찾기, 홈화면 위젯)
  - 기술 스택 선정 (Hive, go_router 등 권장 라이브러리 채택)
  - Phase별 개발 계획 수립 (8시간 분할)
  - Clean Architecture 패턴 적용 결정

2. **Flutter 학습 전략 수립 및 프로젝트 설계**
  - 안드로이드쪽을 기반으로 개발해야겠네. 나는 flutter개발이 처음이니 학습하며 개발을 진행하면 될거같아.
  - Android 개발 경험 기반 Flutter 학습 로드맵 수립
  - 개념 매핑 가이드 (Activity↔Widget, RecyclerView↔ListView 등)
  - 단계별 학습 + 구현 계획 (프로젝트 셋업 → HTTP 통신 → 상태 관리 → 네비게이션 → Native 위젯)
  - 실제 코드 예제를 통한 Flutter-Android 비교 학습

3. **홈화면 위젯 개발**
  - 안드로이드와 ios를 둘 다 고려해서 구현하고 싶어. 좋음 방법이 있을까?
  - home_widget 패키지를 활용한 크로스플랫폼 위젯 구현
  - 카드형 디자인과 네비게이션 기능 설계 (이후 심플 버전으로 변경)
  - 최신 북마크 자동 표시 기능 구현

## 🛠 기술 스택

### Frontend
- **Flutter 3.0+**
- **Dart 3.0+**

### 상태 관리
- **Provider**

### 데이터 저장
- **Hive** - 로컬 NoSQL 데이터베이스

### 네트워킹
- **http** - REST API 통신

### 라우팅
- **go_router** - 선언적 라우팅 (기본 Navigator 사용으로 변경)

### 홈화면 위젯
- **home_widget** - 크로스플랫폼 위젯 지원
- **shared_preferences** - 위젯 상태 관리

### Native 개발
- **Android (Kotlin)** - 홈화면 위젯 구현

## 🏗 아키텍처 설계

### Clean Architecture 패턴 적용

```
lib/
├── core/                    # 공통 기능
│   ├── constants/
│   │   └── api_constants.dart
│   ├── errors/
│   │   └── exceptions.dart  
│   └── utils/
│       └── debouncer.dart
├── data/                    # 데이터 계층
│   ├── datasources/
│   │   ├── github_remote_datasource.dart
│   │   └── bookmark_local_datasource.dart
│   ├── models/
│   │   ├── repository_model.dart
│   │   ├── search_response_model.dart
│   │   └── bookmark_model.dart
│   └── repositories/
│       ├── github_repository_impl.dart
│       └── bookmark_repository_impl.dart
├── domain/                  # 비즈니스 로직 계층
│   ├── entities/
│   │   └── repository_entity.dart
│   ├── repositories/
│   │   ├── github_repository.dart
│   │   └── bookmark_repository.dart
│   └── usecases/
│       ├── search_repositories.dart
│       ├── add_bookmark.dart
│       └── get_bookmarks.dart
├── presentation/            # UI 계층
│   ├── providers/
│   │   ├── search_provider.dart
│   │   └── bookmark_provider.dart
│   ├── pages/
│   │   ├── main_page.dart
│   │   ├── search_page.dart
│   │   └── bookmark_page.dart
│   └── widgets/
│       └── repository_item.dart
├── services/                # 추가 서비스
│   └── widget_service.dart
└── main.dart
```

## 📱 주요 기능

### ✅ 구현 완료

- **GitHub Repository 검색** (디바운싱 300ms)
- **검색 결과 페이지네이션** (무한 스크롤)
- **즐겨찾기 추가/제거**
- **즐겨찾기 목록 조회** (최신순 정렬)
- **오프라인 즐겨찾기 데이터 접근**
- **Bottom Navigation** (검색/북마크 탭)
- **Android 홈화면 위젯** 

### 🎯 Android 홈화면 위젯 특징
- **최신 북마크 표시** - 가장 최근에 추가한 저장소 정보
- **컴팩트한 디자인** - 1줄 높이의 깔끔한 카드형 레이아웃
- **실시간 업데이트** - 앱에서 북마크 추가/제거 시 자동 갱신
- **오프라인 지원** - 네트워크 없이도 북마크 정보 표시
- **정보 표시**: 저장소명, 소유자, 스타 수, 프로그래밍 언어

## 🔧 개발 과정

### 1단계: Core 인프라 구축 
**소요 시간**: 1-2시간

**구현 내용**:
- API 상수 정의 (api_constants.dart)
- 예외 처리 클래스 구조 설계 (exceptions.dart)
- 검색 디바운서 유틸리티 (debouncer.dart)
- 도메인 엔티티 정의 (repository_entity.dart)
- JSON 직렬화 모델 구조 설계

### 2단계: GitHub API 연동 🔌
**소요 시간**: 2-3시간

**구현 내용**:
- HTTP 통신 데이터소스 (github_remote_datasource.dart)
- 검색 상태 관리 Provider (search_provider.dart)
- SearchPage UI 구현
  - 실시간 검색 입력창
  - 디바운싱 적용 검색 (300ms)
  - 무한 스크롤 페이지네이션
  - 로딩/에러/빈결과 상태 UI
- RepositoryItem 위젯 구현
  - 저장소 정보 표시
  - 소유자 아바타, 언어 칩
  - 상세 정보 다이얼로그

### 3단계: 로컬 데이터베이스 연동 
**소요 시간**: 2-3시간

**구현 내용**:
- Hive 데이터베이스 설정
- 북마크 모델 및 TypeAdapter (bookmark_model.dart)
- 로컬 데이터소스 (bookmark_local_datasource.dart)
- 북마크 상태 관리 Provider (bookmark_provider.dart)
- BookmarkPage UI 구현
  - 북마크 목록 표시 (최신순)
  - 개별/전체 삭제 기능
  - 실행취소 기능
  - Pull-to-refresh
- 검색-북마크 화면 간 상태 동기화

### 4단계: Android 홈화면 위젯 📱
**소요 시간**: 3-4시간

**구현 내용**:
- **Flutter 측 구현**:
  - WidgetService 클래스 (widget_service.dart)
  - BookmarkProvider와 위젯 연동
  - 자동 위젯 업데이트 로직

- **Android 네이티브 구현**:
  - RepoWidgetProvider (Kotlin)
  - 위젯 레이아웃 XML
  - AndroidManifest 설정
  - Drawable 리소스들

- **주요 도전과제 해결**:
  - home_widget 패키지 버전 호환성 문제 해결
  - Java 17 버전 요구사항 대응
  - SharedPreferences 타입 캐스팅 이슈 해결
  - 위젯 네비게이션 기능 구현 후 단순화 결정

## 🚀 실행 방법

### 요구사항
- **Flutter 3.0+**
- **Java 17** (Android 개발용)
- **Android Studio** (권장)

### 설치 및 실행
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

### 위젯 사용법
1. 앱에서 GitHub 저장소 검색 및 북마크 추가
2. Android 홈화면에서 길게 눌러 위젯 메뉴 진입
3. "GitHub Repo Finder" 위젯 추가
4. 최신 북마크 정보가 위젯에 자동 표시

## 📖 학습 과정에서 참고한 자료

- **Flutter 공식 문서**: [flutter.dev](https://flutter.dev)
- **Android 개발자를 위한 Flutter**: [flutter.dev/docs/get-started/flutter-for/android-devs](https://flutter.dev/docs/get-started/flutter-for/android-devs)
- **GitHub REST API 문서**: [docs.github.com/en/rest](https://docs.github.com/en/rest)
- **Hive 데이터베이스**: [pub.dev/packages/hive](https://pub.dev/packages/hive)
- **home_widget 패키지**: [pub.dev/packages/home_widget](https://pub.dev/packages/home_widget)

## 💡 추가 고려사항

### 성능 최적화
- 검색 결과 이미지 캐싱
- 무한 스크롤 최적화
- 메모리 사용량 모니터링
- 위젯 업데이트 최적화

### 사용자 경험
- 로딩 상태 표시
- 에러 상태 처리
- 오프라인 상태 안내
- 위젯 자동 갱신

### 접근성
- 스크린 리더 지원
- 적절한 터치 영역 크기
- 고대비 모드 지원

## 🎯 학습 성과

### Flutter 개발 역량 습득
- **Widget 기반 UI 구조 이해**
- **Provider 패턴 상태 관리 학습**
- **Clean Architecture 적용 경험**
- **JSON 직렬화 자동 생성 도구 활용**
- **Hive 로컬 데이터베이스 사용법**

### Android 개발 경험과의 비교 학습
- **Activity ↔ Widget 개념 매핑**
- **RecyclerView ↔ ListView 구조 이해**
- **상태 관리 패턴 차이점 학습**
- **네이티브-Flutter 하이브리드 개발 경험**

### 크로스플랫폼 위젯 개발
- **home_widget 패키지 활용법**
- **Flutter-Android 데이터 통신**
- **위젯 생명주기 이해**
- **네이티브 코드와 Flutter 연동**

## 🚧 향후 개발 계획

### Phase 2: iOS 위젯 구현
- SwiftUI 기반 iOS 위젯 개발
- WidgetKit 활용한 iOS 위젯 구현

### Phase 3: 기능 확장
- 저장소 카테고리별 분류
- 검색 히스토리 기능
- 북마크 태그 및 메모 기능
- 다크 테마 지원

### Phase 4: 성능 최적화
- 이미지 캐싱 시스템
- 검색 결과 캐싱
- 백그라운드 데이터 동기화

---

**개발자**: ParkJooHae  
**개발 기간**: 2025년 8월 4일 ~ 2025년 8월 5일  
**총 소요 시간**: 8시간