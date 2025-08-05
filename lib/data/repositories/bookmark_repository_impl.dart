import '../../domain/entities/repository_entity.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_datasource.dart';

/// 북마크 Repository 구현체
///
/// BookmarkLocalDataSource를 사용하여 로컬 데이터베이스(Hive)와 통신
class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkLocalDataSource _localDataSource;

  BookmarkRepositoryImpl(this._localDataSource);

  @override
  Future<List<RepositoryEntity>> getBookmarks() async {
    try {
      return await _localDataSource.getBookmarks();
    } catch (e) {
      // 예외를 그대로 전파 (UseCase에서 처리)
      rethrow;
    }
  }

  @override
  Future<void> addBookmark(RepositoryEntity repository) async {
    try {
      await _localDataSource.addBookmark(repository);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeBookmark(int repositoryId) async {
    try {
      await _localDataSource.removeBookmark(repositoryId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isBookmarked(int repositoryId) async {
    try {
      return await _localDataSource.isBookmarked(repositoryId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RepositoryEntity?> getLatestBookmark() async {
    try {
      return await _localDataSource.getLatestBookmark();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearAllBookmarks() async {
    try {
      await _localDataSource.clearAllBookmarks();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getBookmarkCount() async {
    try {
      // DataSource의 getBookmarkCount 메서드 사용 (효율적)
      return await _localDataSource.getBookmarkCount();
    } catch (e) {
      rethrow;
    }
  }
}