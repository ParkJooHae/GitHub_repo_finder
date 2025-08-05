import '../repositories/github_repository.dart';

/// 저장소 검색 UseCase
///
/// 비즈니스 로직:
/// - 검색어 유효성 검사
/// - 검색 파라미터 검증
class SearchRepositoriesUseCase {
  final GitHubRepository _repository;

  SearchRepositoriesUseCase(this._repository);

  /// 저장소 검색 실행
  ///
  /// [query] 검색어
  /// [page] 페이지 번호 (기본값: 1)
  /// [perPage] 페이지당 항목 수 (기본값: 30)
  ///
  /// Returns: 검색 결과
  /// Throws: [ArgumentError] 검색어가 비어있는 경우
  Future<SearchResult> call({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    // 비즈니스 규칙: 검색어 유효성 검사
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      throw ArgumentError('검색어를 입력해주세요.');
    }

    // 비즈니스 규칙: 페이지 파라미터 검증
    if (page < 1) {
      throw ArgumentError('페이지 번호는 1 이상이어야 합니다.');
    }

    if (perPage < 1 || perPage > 100) {
      throw ArgumentError('페이지당 항목 수는 1~100 사이여야 합니다.');
    }

    // Repository를 통한 데이터 조회
    return await _repository.searchRepositories(
      query: trimmedQuery,
      page: page,
      perPage: perPage,
    );
  }
}