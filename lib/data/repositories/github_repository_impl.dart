import '../../domain/repositories/github_repository.dart';
import '../datasources/github_remote_datasource.dart';

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
      final response = await _remoteDataSource.searchRepositories(
        query: query,
        page: page,
        perPage: perPage,
      );

      final entities = response.items
          .map((model) => model.toEntity())
          .toList();

      return SearchResult(
        items: entities,
        totalCount: response.totalCount,
        hasMorePages: response.hasMorePages(page, perPage),
      );
    } catch (e) {
      rethrow;
    }
  }
}