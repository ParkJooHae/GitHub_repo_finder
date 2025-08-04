import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repository 검색'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 검색 입력창
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '저장소 검색...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: 디바운싱 로직 추가
                print('검색어: $value');
              },
            ),
          ),

          // 검색 결과 목록
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // 임시 더미 데이터로 UI 확인
    return ListView.builder(
      itemCount: 5, // 임시로 5개
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.code),
            ),
            title: Text('저장소 이름 $index'),
            subtitle: const Text('저장소 설명입니다.'),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // TODO: 북마크 추가 로직
                print('북마크 추가: $index');
              },
            ),
          ),
        );
      },
    );
  }
}