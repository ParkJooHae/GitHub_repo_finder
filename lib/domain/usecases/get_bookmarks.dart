import '../entities/repository_entity.dart';
import '../repositories/bookmark_repository.dart';

class GetBookmarksUseCase {
  final BookmarkRepository _repository;

  GetBookmarksUseCase(this._repository);

  /// 북마크 목록 조회
  Future<List<RepositoryEntity>> call() async {
    return await _repository.getBookmarks();
  }

  /// 북마크 개수 조회
  Future<int> getCount() async {
    return await _repository.getBookmarkCount();
  }

  /// 가장 최근 북마크 조회 (위젯용)
  Future<RepositoryEntity?> getLatest() async {
    return await _repository.getLatestBookmark();
  }
}