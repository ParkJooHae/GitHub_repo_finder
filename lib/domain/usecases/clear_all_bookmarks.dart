import '../repositories/bookmark_repository.dart';

/// - 삭제 전 확인
/// - 삭제된 개수 반환
class ClearAllBookmarksUseCase {
  final BookmarkRepository _repository;

  ClearAllBookmarksUseCase(this._repository);

  /// 모든 북마크 삭제
  Future<int> call() async {
    final currentCount = await _repository.getBookmarkCount();

    if (currentCount == 0) {
      return 0;
    }

    await _repository.clearAllBookmarks();

    return currentCount;
  }

  /// 삭제할 북마크가 있는지 확인
  Future<bool> hasBookmarksToDelete() async {
    final count = await _repository.getBookmarkCount();
    return count > 0;
  }
}