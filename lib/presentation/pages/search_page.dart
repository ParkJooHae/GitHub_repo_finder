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
  late SearchProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 스크롤 이벤트 처리 (무한 스크롤)
  void _onScroll() {
    final provider = context.read<SearchProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      provider.loadMoreRepositories();
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
          // 검색 입력창
          _buildSearchField(),

          // 검색 결과 영역
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, child) {
                return _buildSearchContent(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 검색 입력 필드
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: '저장소 검색... (예: flutter, react)',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          context.read<SearchProvider>().searchRepositories(value);
        },
        onSubmitted: (value) {
          context.read<SearchProvider>().searchRepositories(value);
        },
      ),
    );
  }

  /// 검색 결과 컨텐츠
  Widget _buildSearchContent(SearchProvider provider) {
    // 초기 상태
    if (provider.status == SearchStatus.initial) {
      return _buildInitialState();
    }

    // 로딩 상태 (첫 검색)
    if (provider.status == SearchStatus.loading) {
      return _buildLoadingState();
    }

    // 에러 상태
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

  /// 초기 상태 UI
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
            'GitHub 저장소를 검색해보세요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 상태 UI
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

  /// 에러 상태 UI
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
          // 검색 결과 헤더
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

          // 검색 결과 리스트
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.repositories.length +
                  (provider.hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                // 로딩 더 보기 인디케이터
                if (index == provider.repositories.length) {
                  return _buildLoadMoreIndicator(provider);
                }

                // 저장소 아이템
                final repository = provider.repositories[index];
                return Consumer<BookmarkProvider>(
                  builder: (context, bookmarkProvider, child) {
                    // 저장소에 북마크 상태 정보 추가
                    final isBookmarked = bookmarkProvider.isBookmarked(repository.id);
                    final repositoryWithBookmarkState = isBookmarked
                        ? repository.copyWithBookmark()
                        : repository;

                    return RepositoryItem(
                      repository: repositoryWithBookmarkState,
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

  /// 더 로딩 인디케이터
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
}