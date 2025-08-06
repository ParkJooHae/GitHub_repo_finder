import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../pages/main_page.dart';
import '../pages/search_page.dart';
import '../pages/bookmark_page.dart';

/// 앱의 라우팅 설정
class AppRouter {
  static final GoRouter router = GoRouter(
    // 앱 시작시 기본 경로
    initialLocation: '/search',

    debugLogDiagnostics: true,

    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainPage(child: child);
        },
        routes: [
          // 검색 페이지
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),

          // 북마크 페이지
          GoRoute(
            path: '/bookmarks',
            name: 'bookmarks',
            builder: (context, state) => const BookmarkPage(),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('경로를 찾을 수 없습니다: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/search'),
              child: const Text('검색 페이지로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
}