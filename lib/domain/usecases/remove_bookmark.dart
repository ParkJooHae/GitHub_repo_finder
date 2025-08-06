import '../repositories/bookmark_repository.dart';

/// - 존재하는 북마크만 제거 가능
/// - 제거 전 상태 검증
class RemoveBookmarkUseCase {
  final BookmarkRepository _repository;

  RemoveBookmarkUseCase(this._repository);

  /// 북마크 제거
  Future<void> call(int repositoryId) async {
    if (repositoryId <= 0) {
      throw ArgumentError('유효하지 않은 저장소 ID입니다.');
    }

    final isBookmarked = await _repository.isBookmarked(repositoryId);
    if (!isBookmarked) {
      throw StateError('북마크에서 찾을 수 없는 저장소입니다.');
    }

    await _repository.removeBookmark(repositoryId);
  }
}