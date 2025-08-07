import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/repository_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SearchProvider>();
      if (provider.currentQuery.isNotEmpty) {
        _searchController.text = provider.currentQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 스크롤 이벤트
  void _onScroll() {
    final provider = context.read<SearchProvider>();

    // 이미 로딩 중이거나 더 이상 페이지가 없으면 스킵
    if (provider.isLoadingMore || !provider.hasMorePages) {
      return;
    }

    // 스크롤 위치가 끝에서 200px 이내일 때만 로드
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      provider.loadMoreRepositories();
    }

    // 이동 버튼 표시 여부 결정
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
        title: const Text('GitHub Repository 검색'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildSearchField(),

          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, child) {
                return _buildSearchContent(provider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildScrollToTopButton(),
    );
  }

  /// 검색 입력 필드
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Git Hub 저장소를 검색해 주세요.',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          final provider = context.read<SearchProvider>();
          provider.searchRepositories(value);
        },
      ),
    );
  }

  /// 검색 결과
  Widget _buildSearchContent(SearchProvider provider) {
    if (provider.status == SearchStatus.initial) {
      return _buildInitialState();
    }

    // 로딩
    if (provider.status == SearchStatus.loading) {
      return _buildLoadingState();
    }

    // 에러
    if (provider.hasError) {
      return _buildErrorState(provider);
    }

    // 검색 결과가 없는 경우
    if (provider.status == SearchStatus.success && !provider.hasData) {
      return _buildEmptyState();
    }

    // 검색 결과 표시
    return _buildSearchResults(provider);
  }

  /// 처음 UI
  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'GitHub 저장소를 검색해주세요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 UI
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('검색 중...'),
        ],
      ),
    );
  }

  /// 에러 UI
  Widget _buildErrorState(SearchProvider provider) {
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
                provider.refreshSearch();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 검색 결과 없음 UI
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '다른 키워드로 검색해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 검색 결과 리스트
  Widget _buildSearchResults(SearchProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refreshSearch,
      child: Column(
        children: [
          if (provider.totalCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Text(
                '총 ${provider.totalCount.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},'
                )}개 결과',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Expanded(
            child: Consumer<BookmarkProvider>(
              builder: (context, bookmarkProvider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.repositories.length +
                      (provider.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.repositories.length) {
                      return _buildLoadMoreIndicator(provider);
                    }

                    final repository = provider.repositories[index];

                    final isBookmarked = bookmarkProvider.isBookmarked(repository.id);
                    final repositoryWithBookmarkState = isBookmarked
                        ? repository.copyWithBookmark()
                        : repository;

                    return RepositoryItem(
                      key: ValueKey(repository.id),
                      repository: repositoryWithBookmarkState,
                      onItemTap: _unfocusTextField,
                      onBookmarkToggle: (repo) async {
                        try {
                          await bookmarkProvider.toggleBookmark(repo);

                          final message = bookmarkProvider.isBookmarked(repo.id)
                              ? '${repo.name}이(가) 북마크에 추가되었습니다.'
                              : '${repo.name}이(가) 북마크에서 제거되었습니다.';

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('오류가 발생했습니다: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  /// 로딩
  Widget _buildLoadMoreIndicator(SearchProvider provider) {
    if (provider.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 포커스 해제
  void _unfocusTextField() {
    FocusScope.of(context).unfocus();
  }

  /// 버튼
  Widget? _buildScrollToTopButton() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        // 30개 이상의 아이템이 있고, 스크롤 버튼이 표시되어야 할 때만 보임
        if (provider.repositories.length >= 30 && _showScrollToTopButton) {
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
            child: const Icon(Icons.keyboard_arrow_up),
            mini: true,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}