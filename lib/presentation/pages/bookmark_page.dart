import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/repository_item.dart';
import '../../domain/entities/repository_entity.dart';

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
        actions: [
          // 새로고침 버튼
          IconButton(
            onPressed: () {
              context.read<BookmarkProvider>().refreshBookmarks();
            },
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),

          // 모든 북마크 삭제 버튼
          Consumer<BookmarkProvider>(
            builder: (context, provider, child) {
              if (!provider.hasBookmarks) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _showClearAllDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, color: Colors.red),
                        SizedBox(width: 8),
                        Text('모두 삭제'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, provider, child) {
          return _buildBookmarkContent(provider);
        },
      ),
    );
  }

  /// 북마크 컨텐츠 빌드
  Widget _buildBookmarkContent(BookmarkProvider provider) {
    // 로딩 상태
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('북마크를 불러오는 중...'),
          ],
        ),
      );
    }

    // 에러 상태
    if (provider.hasError) {
      return _buildErrorState(provider);
    }

    // 북마크가 없는 경우
    if (!provider.hasBookmarks) {
      return _buildEmptyState();
    }

    // 북마크 목록 표시
    return _buildBookmarkList(provider);
  }

  /// 에러 상태 UI
  Widget _buildErrorState(BookmarkProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.refreshBookmarks();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '북마크한 저장소가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '검색 화면에서 마음에 드는 저장소를\n북마크에 추가해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // 검색 탭으로 이동
              final mainPageState = context.findAncestorStateOfType<State>();
              if (mainPageState != null && mainPageState.mounted) {
                // MainPage에서 탭 변경하는 방법을 구현해야 함
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            icon: const Icon(Icons.search),
            label: const Text('저장소 검색하기'),
          ),
        ],
      ),
    );
  }

  /// 북마크 목록
  Widget _buildBookmarkList(BookmarkProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refreshBookmarks,
      child: Column(
        children: [
          // 북마크 개수 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                Icon(
                  Icons.bookmark,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '총 ${provider.bookmarkCount}개의 북마크',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '최신순',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 북마크 리스트
          Expanded(
            child: ListView.builder(
              itemCount: provider.bookmarks.length,
              itemBuilder: (context, index) {
                final repository = provider.bookmarks[index];

                return RepositoryItem(
                  repository: repository,
                  onBookmarkToggle: (repo) async {
                    await _removeBookmark(repo, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 북마크 제거 처리
  Future<void> _removeBookmark(
      RepositoryEntity repository,
      BookmarkProvider provider
      ) async {
    // 확인 다이얼로그 표시
    final shouldRemove = await _showRemoveBookmarkDialog(repository.name);
    if (!shouldRemove) return;

    try {
      await provider.removeBookmark(repository.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${repository.name}이(가) 북마크에서 제거되었습니다.'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: '실행취소',
              onPressed: () async {
                // 다시 북마크 추가
                try {
                  await provider.addBookmark(repository);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('실행취소 중 오류가 발생했습니다: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('북마크 제거 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 북마크 제거 확인 다이얼로그
  Future<bool> _showRemoveBookmarkDialog(String repositoryName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('북마크 제거'),
        content: Text('$repositoryName을(를) 북마크에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('제거'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 모든 북마크 삭제 확인 다이얼로그
  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 북마크 삭제'),
        content: const Text('정말로 모든 북마크를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await context.read<BookmarkProvider>().clearAllBookmarks();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('모든 북마크가 삭제되었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('북마크 삭제 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}