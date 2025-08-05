import '../../domain/entities/repository_entity.dart';
import '../../domain/repositories/github_repository.dart';
import '../datasources/github_remote_datasource.dart';

/// GitHub Repository 구현체
///
/// GitHubRemoteDataSource를 사용하여 실제 GitHub API와 통신
class GitHubRepositoryImpl implements GitHubRepository {
  final GitHubRemoteDataSource _remoteDataSource;

  GitHubRepositoryImpl(this._remoteDataSource);

  @override
  Future<SearchResult> searchRepositories({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    try {
      // DataSource를 통한 API 호출
      final response = await _remoteDataSource.searchRepositories(
        query: query,
        page: page,
        perPage: perPage,
      );

      // Model을 Entity로 변환
      final entities = response.items
          .map((model) => model.toEntity())
          .toList();

      // SearchResult 생성
      return SearchResult(
        items: entities,
        totalCount: response.totalCount,
        hasMorePages: response.hasMorePages(page, perPage),
      );
    } catch (e) {
      // 예외를 그대로 전파 (UseCase에서 처리)
      rethrow;
    }
  }
}