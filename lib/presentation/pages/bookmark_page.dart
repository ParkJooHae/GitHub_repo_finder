import 'package:flutter/material.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('북마크'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBookmarkList(),
    );
  }

  Widget _buildBookmarkList() {
    // 임시 더미 데이터로 UI 확인
    final hasBookmarks = true; // 나중에 실제 데이터로 교체

    if (!hasBookmarks) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '북마크한 저장소가 없습니다.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: 3, // 임시로 3개
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.code),
            ),
            title: Text('북마크된 저장소 $index'),
            subtitle: const Text('북마크된 저장소 설명입니다.'),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.blue),
              onPressed: () {
                // TODO: 북마크 제거 로직
                print('북마크 제거: $index');
                _showRemoveBookmarkDialog(index);
              },
            ),
          ),
        );
      },
    );
  }

  void _showRemoveBookmarkDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('북마크 제거'),
        content: const Text('이 저장소를 북마크에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 실제 북마크 제거 로직
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('북마크가 제거되었습니다.')),
              );
            },
            child: const Text('제거'),
          ),
        ],
      ),
    );
  }
}