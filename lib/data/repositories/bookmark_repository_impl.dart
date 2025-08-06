import '../../domain/entities/repository_entity.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_datasource.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkLocalDataSource _localDataSource;

  BookmarkRepositoryImpl(this._localDataSource);

  @override
  Future<List<RepositoryEntity>> getBookmarks() async {
    try {
      return await _localDataSource.getBookmarks();
    } catch (e) {
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
      return await _localDataSource.getBookmarkCount();
    } catch (e) {
      rethrow;
    }
  }
}