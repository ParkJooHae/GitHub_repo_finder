// presentation/pages/main_page.dart
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'bookmark_page.dart';

class MainPage extends StatefulWidget {
  final int initialIndex; // 초기 탭 인덱스 추가

  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const SearchPage(),
    const BookmarkPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // 초기 인덱스 설정

    // 디버그 로그
    print('MainPage initialized with index: ${widget.initialIndex}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          print('Tab changed to index: $index');
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
}