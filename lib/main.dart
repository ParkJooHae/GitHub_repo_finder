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
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/bookmark_provider.dart';
import 'presentation/router/router_config.dart'; // 추가

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
Future<AppDependencies> _setupDependencies() async {
  // === Data Layer 초기화 ===
  final githubDataSource = GitHubRemoteDataSourceImpl(
    client: http.Client(),
  );
  final bookmarkDataSource = BookmarkLocalDataSourceImpl();

  // Repositories
  final GitHubRepository githubRepository = GitHubRepositoryImpl(githubDataSource);
  final BookmarkRepository bookmarkRepository = BookmarkRepositoryImpl(bookmarkDataSource);

  // === Domain Layer 초기화 ===
  final searchRepositoriesUseCase = SearchRepositoriesUseCase(githubRepository);
  final getBookmarksUseCase = GetBookmarksUseCase(bookmarkRepository);
  final addBookmarkUseCase = AddBookmarkUseCase(bookmarkRepository);
  final removeBookmarkUseCase = RemoveBookmarkUseCase(bookmarkRepository);
  final toggleBookmarkUseCase = ToggleBookmarkUseCase(bookmarkRepository);
  final clearAllBookmarksUseCase = ClearAllBookmarksUseCase(bookmarkRepository);

  return AppDependencies(
    searchRepositoriesUseCase: searchRepositoriesUseCase,
    getBookmarksUseCase: getBookmarksUseCase,
    addBookmarkUseCase: addBookmarkUseCase,
    removeBookmarkUseCase: removeBookmarkUseCase,
    toggleBookmarkUseCase: toggleBookmarkUseCase,
    clearAllBookmarksUseCase: clearAllBookmarksUseCase,
  );
}

/// 애플리케이션 의존성 컨테이너
class AppDependencies {
  final SearchRepositoriesUseCase searchRepositoriesUseCase;
  final GetBookmarksUseCase getBookmarksUseCase;
  final AddBookmarkUseCase addBookmarkUseCase;
  final RemoveBookmarkUseCase removeBookmarkUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;
  final ClearAllBookmarksUseCase clearAllBookmarksUseCase;

  AppDependencies({
    required this.searchRepositoriesUseCase,
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
      child: MaterialApp.router(
        title: 'GitHub Repo Finder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}