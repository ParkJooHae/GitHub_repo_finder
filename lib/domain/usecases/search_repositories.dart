import '../repositories/github_repository.dart';

/// - 검색어 유효성 검사
/// - 검색 파라미터 검증
class SearchRepositoriesUseCase {
  final GitHubRepository _repository;

  SearchRepositoriesUseCase(this._repository);

  /// repo 검색 실행
  Future<SearchResult> call({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const SearchResult(
        items: [],
        totalCount: 0,
        hasMorePages: false,
      );
    }

    if (page < 1) {
      throw ArgumentError('페이지 번호는 1 이상이어야 합니다.');
    }

    if (perPage < 1 || perPage > 100) {
      throw ArgumentError('페이지당 항목 수는 1~100 사이여야 합니다.');
    }

    return await _repository.searchRepositories(
      query: trimmedQuery,
      page: page,
      perPage: perPage,
    );
  }
}