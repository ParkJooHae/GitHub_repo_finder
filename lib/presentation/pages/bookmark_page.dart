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
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 스크롤 이벤트
  void _onScroll() {
    // 상단으로 올라가는 버튼 표시 여부 결정
    final shouldShowButton = _scrollController.position.pixels > 300;
    if (_showScrollToTopButton != shouldShowButton) {
      setState(() {
        _showScrollToTopButton = shouldShowButton;
      });
    }
  }

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
      floatingActionButton: _buildScrollToTopButton(),
    );
  }

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

  /// 에러 UI
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

  /// 비어있는 UI
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
          )
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                GestureDetector(
                  onTap: () {
                    provider.toggleSortOrder();
                    
                    // 정렬 변경 피드백
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.sortOrder == BookmarkSortOrder.newest 
                              ? '최신순으로 정렬되었습니다.' 
                              : '오래된순으로 정렬되었습니다.'
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.sortOrder == BookmarkSortOrder.newest ? '최신순' : '오래된순',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.swap_vert,
                          size: 14,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.bookmarks.length,
              itemBuilder: (context, index) {
                final repository = provider.bookmarks[index];

                return RepositoryItem(
                  repository: repository,
                  onItemTap: () => FocusScope.of(context).unfocus(),
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

  /// 북마크 제거
  Future<void> _removeBookmark(
      RepositoryEntity repository,
      BookmarkProvider provider
      ) async {

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

  /// 북마크 하나 제거 dialog
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

  /// 모든 북마크 삭제 dialog
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
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await context.read<BookmarkProvider>().clearAllBookmarks();

                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('모든 북마크가 삭제되었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
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

  /// 상단 버튼
  Widget? _buildScrollToTopButton() {
    return Consumer<BookmarkProvider>(
      builder: (context, provider, child) {
        // 30개 이상의 아이템이 있고, 스크롤이 일정이상 내려가면 보임
        if (provider.bookmarks.length >= 30 && _showScrollToTopButton) {
          return FloatingActionButton(
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            mini: true,
            child: const Icon(Icons.keyboard_arrow_up),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}