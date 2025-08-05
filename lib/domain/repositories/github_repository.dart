import '../entities/repository_entity.dart';

/// GitHub Repository 인터페이스
///
/// GitHub API 관련 작업을 추상화한 Repository 패턴
abstract class GitHubRepository {
  /// 저장소 검색
  ///
  /// [query] 검색어
  /// [page] 페이지 번호 (기본값: 1)
  /// [perPage] 페이지당 항목 수 (기본값: 30)
  ///
  /// Returns: 검색 결과와 메타데이터를 포함한 [SearchResult]
  Future<SearchResult> searchRepositories({
    required String query,
    int page = 1,
    int perPage = 30,
  });
}

/// 검색 결과 데이터 클래스
class SearchResult {
  final List<RepositoryEntity> items;
  final int totalCount;
  final bool hasMorePages;

  const SearchResult({
    required this.items,
    required this.totalCount,
    required this.hasMorePages,
  });

  /// 결과가 비어있는지 확인
  bool get isEmpty => items.isEmpty;

  /// 결과가 있는지 확인
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() {
    return 'SearchResult{items: ${items.length}, totalCount: $totalCount, hasMorePages: $hasMorePages}';
  }
}