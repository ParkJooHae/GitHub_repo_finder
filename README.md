# jhp_github_repo_finder

GitHub Repository 검색 및 북마크 Flutter 애플리케이션

## 개요

GitHub REST API를 활용하여 저장소를 검색하고, 마음에 드는 저장소를 즐겨찾기에 추가할 수 있는 모바일 애플리케이션입니다. 

## 🏗 Clean Architecture 패턴

### 의존성 방향 (Dependency Inversion)

```
Provider → UseCase → Repository(Interface) ← Repository(Impl) → DataSource → External
```


## 📂 프로젝트 구조

```
lib/
├── core/                           # 🛠 공통 기능
│   ├── constants/
│   │   └── api_constants.dart      # API 상수
│   ├── errors/
│   │   └── exceptions.dart         # 예외 정의
│   └── utils/
│       └── debouncer.dart          # 디바운싱 유틸
│
├── data/                           # 💾 Data Layer
│   ├── datasources/               # 외부 데이터 접근
│   │   ├── github_remote_datasource.dart
│   │   └── bookmark_local_datasource.dart
│   ├── models/                    # JSON 직렬화 모델
│   │   ├── repository_model.dart
│   │   ├── search_response_model.dart
│   │   └── bookmark_model.dart
│   └── repositories/              # Repository 구현체
│       ├── github_repository_impl.dart
│       └── bookmark_repository_impl.dart
│
├── domain/                         # 💼 Domain Layer
│   ├── entities/                  # 비즈니스 엔티티
│   │   └── repository_entity.dart
│   ├── repositories/              # Repository 인터페이스
│   │   ├── github_repository.dart
│   │   └── bookmark_repository.dart
│   └── usecases/                  # 비즈니스 로직
│       ├── search_repositories.dart
│       ├── get_bookmarks.dart
│       ├── add_bookmark.dart
│       ├── remove_bookmark.dart
│       ├── toggle_bookmark.dart
│       └── clear_all_bookmarks.dart
│
├── presentation/                   # 🎨 Presentation Layer
│   ├── providers/                 # 상태 관리 (Clean)
│   │   ├── search_provider.dart
│   │   └── bookmark_provider.dart
│   ├── pages/                     # 화면 컴포넌트
│   │   ├── main_page.dart
│   │   ├── search_page.dart
│   │   └── bookmark_page.dart
│   └── widgets/                   # 재사용 UI 컴포넌트
│       └── repository_item.dart
│
├── services/                       # 🔧 추가 서비스
│   └── widget_service.dart        # 홈화면 위젯 관리
│
└── main.dart                      # 🚀 앱 진입점 & 의존성 주입
```

## 🛠 기술 스택

### Core Framework
- **Flutter 3.0+** - UI 프레임워크
- **Dart 3.0+** - 프로그래밍 언어

### Architecture & Patterns
- **Clean Architecture** - 전체 앱 아키텍처
- **Repository Pattern** - 데이터 접근 추상화
- **UseCase Pattern** - 비즈니스 로직 캡슐화
- **Provider Pattern** - 상태 관리
- **Dependency Injection** - 의존성 주입

### Data Management
- **Hive** - 로컬 NoSQL 데이터베이스
- **http** - REST API 통신
- **JSON Annotation** - 자동 직렬화

### UI & Navigation
- **Material 3** - 디자인 시스템
- **Provider** - 상태 관리
- **Navigator 2.0** - 기본 네비게이션

### Native Features
- **home_widget** - 크로스플랫폼 위젯
- **shared_preferences** - 위젯 상태 관리

## 📱 주요 기능

### ✅ 구현 완료 기능

- **GitHub Repository 검색**
  - 실시간 검색 (디바운싱 300ms)
  - 무한 스크롤 페이지네이션
  - 에러 처리 및 로딩 상태

- **즐겨찾기 관리**
  - 북마크 추가/제거/토글
  - 오프라인 데이터 접근
  - 최신순 정렬 및 관리

- **Android 홈화면 위젯**
  - 최신 북마크 실시간 표시
  - 컴팩트한 카드형 디자인
  - 자동 업데이트

### 🎯 비즈니스 로직 (UseCase 레벨)

#### 검색 로직
- 검색어 유효성 검사
- 페이지 파라미터 검증
- API 호출 및 결과 변환

#### 북마크 로직
- 중복 북마크 방지
- 존재하지 않는 북마크 제거 방지
- 저장소 정보 유효성 검사

## AI 도구 사용 내역

### 사용 도구

- Claude (Anthropic) - Clean Architecture 설계, Flutter 학습, 리팩토링 가이드

개발 초기 단계에서 요구사항 분석 및 전체적인 아키텍처 설계에 도움을 받았으며, Clean Architecture 패턴 적용과 문서 작성 과정에서 가이드를 제공받았습니다.

## 🚀 실행 방법
### 요구사항
- **Flutter 3.0+**
- **Java 17** (Android Gradle)
- **Android Studio** 

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

### 3. Integration Tests (통합 테스트)
- 전체 사용자 플로우 테스트
- API 연동 테스트
- 위젯 업데이트 테스트


## 📚 학습 리소스

### Clean Architecture
- [Clean Architecture: A Craftsman's Guide](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164)
- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture-tdd/)

### Flutter Architecture
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Provider State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple)

### Testing
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito for Flutter](https://pub.dev/packages/mockito)

---

**개발자**: ParkJooHae  
**개발 기간**: 2025년 8월 4일 ~ 2025년 8월 6일  
**총 소요 시간**: 12시간 (기능 구현 8시간 + Clean Architecture 리팩토링 4시간)  
**아키텍처**: Clean Architecture with Provider Pattern