import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatefulWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/search')) return 0;
    if (location.startsWith('/bookmarks')) return 1;

    return 0; // 첫 화면 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) {
          _onTap(context, index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: '북마크',
          ),
        ],
      ),
    );
  }

  /// 탭 선택 시 처리
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/search');
        break;
      case 1:
        context.go('/bookmarks');
        break;
    }
  }
}