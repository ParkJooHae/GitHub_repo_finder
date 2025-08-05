import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

// Data Layer
import 'data/models/bookmark_model.dart';
import 'data/datasources/bookmark_local_datasource.dart';
import 'data/datasources/github_remote_datasource.dart';
import 'data/repositories/github_repository_impl.dart';
import 'data/repositories/bookmark_repository_impl.dart';

// Domain Layer
import 'domain/repositories/github_repository.dart';
import 'domain/repositories/bookmark_repository.dart';
import 'domain/usecases/search_repositories.dart';
import 'domain/usecases/get_bookmarks.dart';
import 'domain/usecases/add_bookmark.dart';
import 'domain/usecases/remove_bookmark.dart';
import 'domain/usecases/toggle_bookmark.dart';
import 'domain/usecases/clear_all_bookmarks.dart';

// Presentation Layer
import 'presentation/pages/main_page.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/bookmark_provider.dart';

// Services
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // Hive 어댑터 등록
  Hive.registerAdapter(BookmarkModelAdapter());

  // 북마크 데이터베이스 초기화
  await BookmarkLocalDataSourceImpl.initialize();

  // 위젯 서비스 초기화
  await WidgetService.initializeWidget();

  // 의존성 주입 설정
  final dependencies = await _setupDependencies();

  runApp(MyApp(dependencies: dependencies));
}

/// 의존성 주입 설정
///
/// Clean Architecture의 의존성 역전 원칙을 적용하여
/// 모든 계층의 의존성을 주입합니다.
Future<AppDependencies> _setupDependencies() async {
  // === Data Layer 초기화 ===

  // DataSources
  final githubDataSource = GitHubRemoteDataSourceImpl(
    client: http.Client(),
  );
  final bookmarkDataSource = BookmarkLocalDataSourceImpl();

  // Repositories (Domain 인터페이스를 Data에서 구현)
  final GitHubRepository githubRepository = GitHubRepositoryImpl(githubDataSource);
  final BookmarkRepository bookmarkRepository = BookmarkRepositoryImpl(bookmarkDataSource);

  // === Domain Layer 초기화 ===

  // GitHub UseCases
  final searchRepositoriesUseCase = SearchRepositoriesUseCase(githubRepository);

  // Bookmark UseCases
  final getBookmarksUseCase = GetBookmarksUseCase(bookmarkRepository);
  final addBookmarkUseCase = AddBookmarkUseCase(bookmarkRepository);
  final removeBookmarkUseCase = RemoveBookmarkUseCase(bookmarkRepository);
  final toggleBookmarkUseCase = ToggleBookmarkUseCase(bookmarkRepository);
  final clearAllBookmarksUseCase = ClearAllBookmarksUseCase(bookmarkRepository);

  return AppDependencies(
    // Search 관련
    searchRepositoriesUseCase: searchRepositoriesUseCase,

    // Bookmark 관련
    getBookmarksUseCase: getBookmarksUseCase,
    addBookmarkUseCase: addBookmarkUseCase,
    removeBookmarkUseCase: removeBookmarkUseCase,
    toggleBookmarkUseCase: toggleBookmarkUseCase,
    clearAllBookmarksUseCase: clearAllBookmarksUseCase,
  );
}

/// 애플리케이션 의존성 컨테이너
///
/// 모든 UseCase들을 담고 있어서 Provider들에게 주입됩니다.
class AppDependencies {
  // Search 관련 UseCase
  final SearchRepositoriesUseCase searchRepositoriesUseCase;

  // Bookmark 관련 UseCases
  final GetBookmarksUseCase getBookmarksUseCase;
  final AddBookmarkUseCase addBookmarkUseCase;
  final RemoveBookmarkUseCase removeBookmarkUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;
  final ClearAllBookmarksUseCase clearAllBookmarksUseCase;

  AppDependencies({
    // Search
    required this.searchRepositoriesUseCase,

    // Bookmark
    required this.getBookmarksUseCase,
    required this.addBookmarkUseCase,
    required this.removeBookmarkUseCase,
    required this.toggleBookmarkUseCase,
    required this.clearAllBookmarksUseCase,
  });
}

class MyApp extends StatelessWidget {
  final AppDependencies dependencies;

  const MyApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // SearchProvider에 UseCase 주입
        ChangeNotifierProvider(
          create: (_) => SearchProvider(
            dependencies.searchRepositoriesUseCase,
          ),
        ),

        // BookmarkProvider에 UseCases 주입
        ChangeNotifierProvider(
          create: (_) => BookmarkProvider(
            getBookmarksUseCase: dependencies.getBookmarksUseCase,
            addBookmarkUseCase: dependencies.addBookmarkUseCase,
            removeBookmarkUseCase: dependencies.removeBookmarkUseCase,
            toggleBookmarkUseCase: dependencies.toggleBookmarkUseCase,
            clearAllBookmarksUseCase: dependencies.clearAllBookmarksUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'GitHub Repo Finder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MainPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}