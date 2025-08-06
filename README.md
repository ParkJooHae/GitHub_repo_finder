# jhp_github_repo_finder

GitHub Repository 검색 및 북마크 Flutter 애플리케이션

## 개요

GitHub REST API를 활용하여 저장소를 검색하고, 마음에 드는 저장소를 즐겨찾기에 추가할 수 있는 모바일 애플리케이션입니다. 

안드로이드 기반 위젯을 구현하였고, 위젯의 UI는 xml 기반의 View로 개발했습니다. 위젯에는 가장 최근에 추가한 북마크 저장소가 표시됩니다.

클린 아키텍쳐를 제대로 구현하기 위해 구조 설계에 시간을 들였습니다. 

## 설계 고려사항 및 기술 선택

### Clean Architecture 
- 개발에 있어서 제일 중요하다고 생각하는 부분이 유지 보수와 확장성 이라고 생각했기 때문에 Clean Architecture를 적용했습니다.
- 비즈니스 로직을 분리하여 핵심 로직을 외부 변경으로부터 보호하는것도 설계의 이유입니다.
- 평소에 Android Native개발을 통해 조금씩 연습해 왔던 부분들을 한번에 Flutter로 적용하는게 재미있었습니다.
### Provider
- Android Native개발에서 적용하던 ViewModel을 Flutter에선 어떻게 사용하는지 찾아보고 그대로 적용했습니다.
- 공식 문서로 권장하는 패턴이었고, MVVM과 마찬가지로 Clean Architecture와 자연스럽게 연결되는 구조였습니다.
- 기존 경험이 있었기 때문에 더 이해하기가 쉬웠습니다.
### Repository
- 데이터 접근 로직을 추상화 하여 의존성을 분리했습니다.
### UseCase
- 각 기능별로 UseCase를 정의하여 비즈니스 로직을 캡슐화 하였습니다.
- 검색 유효성검사, 중복 북마크 방지 등을 UseCase에서 처리합니다.
### 에러 처리
- 에러 타입 정의 후 에러 핸들링을 진행했습니다.
- 기존에 경험해본 api 에러들을 다르게 처리하도록 구현했습니다.
### go_router
- Navigator는 많이 사용해봤지만 URL기반 라우팅은 다른 느낌이라 신선했습니다. 권장 라이브러리로 적용했습니다.
### HIve
- Android Native개발에서 주로 사용하던 라이브러리는 Room 이었지만, 과제의 권장사항에 맞춰 새로운 데이터 베이스를 사용해보고 싶었습니다.
- Hive가 sqflite 보다  가볍다는 분석을 보고 적용하기로 했습니다.
### Json 직렬화
- Android Native개발에서 Json 데이터 관리는 serialization이나 Gson을 이용했었지만, Flutter에서는 build_runner를 이용해 직렬화 코드를 자동 생성 가능하다고 하여 적용해 봤습니다.
- 명령어를 이용해 코드를 생성해봤고, 단순 노가다성 코딩을 줄일 수 있어서 좋았습니다.
### AppWidgetProvider
- Android Native에서 위젯 개발 경험이 있기 때문에, 간단하게 네이티브 위젯을 개발했습니다. 
- xml기반으로 제작해서, card view형태로 보이도록 했습니다. 
- SharedPreferences를 사용하여 데이터를 주고받을 수 있습니다.

## 프로젝트 구조

```
lib/
├── core/                           # 공통 기능
│   ├── constants/
│   │   └── api_constants.dart      # API 상수
│   ├── errors/
│   │   └── exceptions.dart         # 예외 정의
│   └── utils/
│       └── debouncer.dart          # 디바운싱 유틸
│
├── data/                           # Data Layer
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
├── domain/                         # Domain Layer
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
├── presentation/                   # Presentation Layer
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
├── services/                       # 추가 서비스
│   └── widget_service.dart        # 홈화면 위젯 관리
│
└── main.dart                      # 앱 진입점 & 의존성 주입
```

##  기술 스택

### Core Framework
- **Flutter 3.0+** - UI 프레임워크
- **Dart 3.0+** - 프로그래밍 언어

### Data Management
- **Hive** - 로컬 NoSQL 데이터베이스
- **http** - REST API 통신
- **JSON Annotation** - 자동 직렬화

### UI & Navigation
- **Material 3** - 디자인 시스템
- **Provider** - 상태 관리
- **go_router** - 선언적 라우팅

### Native Features
- **home_widget** - 크로스플랫폼 위젯
- **shared_preferences** - 위젯 상태 관리

## 주요 기능

### 구현 완료 기능

- **GitHub Repository 검색**
  - 실시간 검색 (디바운싱 300ms)
  - 스크롤 페이지네이션
  - 에러 처리 및 로딩 상태 표시

- **북마크**
  - 북마크 추가/제거/토글
  - 로컬 기반 데이터 베이스
  - 북마크 전체 삭제 기능
  - 최신순 정렬

- **Android 홈화면 위젯**
  - 최신 북마크 표시

### 비즈니스 로직 (UseCase)

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

익숙하지 않은 flutter개발을 위해 Native개발에서 익혔던 기능들을 flutter에선 어떤 명칭으로 어떻게 사용중인지 질문하고 대체 가능한 부분을 학습 후 적용했습니다.

## 학습 리소스

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
**개발 기간**: 2025년 8월 4일 ~ 2025년 8월 5일  
**총 소요 시간**: 8시간