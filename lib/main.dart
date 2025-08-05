// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/bookmark_model.dart';
import 'data/datasources/bookmark_local_datasource.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/bookmark_provider.dart';
import 'services/widget_service.dart'; // 추가

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
  await WidgetService.registerInteractivityCallback();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: MaterialApp(
        title: 'GitHub Repo Finder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) {
            // 위젯 클릭 이벤트 처리 설정
            _setupWidgetClickHandler(context);
            return const MainPage();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// 위젯 클릭 이벤트 핸들러 설정
  void _setupWidgetClickHandler(BuildContext context) {
    WidgetService.handleWidgetClick((String action) {
      print('Widget action received in main: $action');

      final bookmarkProvider = context.read<BookmarkProvider>();

      switch (action) {
        case 'next':
          print('Executing next action');
          bookmarkProvider.navigateWidgetNext();
          break;
        case 'previous':
          print('Executing previous action');
          bookmarkProvider.navigateWidgetPrevious();
          break;
        case 'open_app':
          print('Executing open app action');
          // 앱 열기 - 북마크 탭으로 이동
          _navigateToBookmarks(context);
          break;
        default:
          print('Unknown action: $action');
          // 기본적으로 앱 열기
          _navigateToBookmarks(context);
          break;
      }
    });
  }

  /// 북마크 탭으로 이동
  void _navigateToBookmarks(BuildContext context) {
    // 현재 화면이 MainPage가 아닌 경우 MainPage로 이동
    final navigator = Navigator.of(context);

    // 모든 라우트를 제거하고 MainPage로 이동 (북마크 탭)
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainPage(initialIndex: 1), // 북마크 탭 (인덱스 1)
      ),
          (route) => false,
    );
  }
}