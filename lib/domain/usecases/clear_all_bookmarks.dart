import '../repositories/bookmark_repository.dart';

/// 모든 북마크 삭제 UseCase
///
/// 비즈니스 로직:
/// - 삭제 전 확인
/// - 삭제된 개수 반환
class ClearAllBookmarksUseCase {
  final BookmarkRepository _repository;

  ClearAllBookmarksUseCase(this._repository);

  /// 모든 북마크 삭제
  ///
  /// Returns: 삭제된 북마크 개수
  Future<int> call() async {
    // 삭제 전 현재 개수 확인
    final currentCount = await _repository.getBookmarkCount();

    if (currentCount == 0) {
      return 0; // 이미 비어있음
    }

    // 모든 북마크 삭제
    await _repository.clearAllBookmarks();

    return currentCount; // 삭제된 개수 반환
  }

  /// 삭제할 북마크가 있는지 확인
  ///
  /// Returns: 삭제 가능한 북마크 존재 여부
  Future<bool> hasBookmarksToDelete() async {
    final count = await _repository.getBookmarkCount();
    return count > 0;
  }
}