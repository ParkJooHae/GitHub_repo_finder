import '../repositories/bookmark_repository.dart';

/// 북마크 제거 UseCase
///
/// 비즈니스 로직:
/// - 존재하는 북마크만 제거 가능
/// - 제거 전 상태 검증
class RemoveBookmarkUseCase {
  final BookmarkRepository _repository;

  RemoveBookmarkUseCase(this._repository);

  /// 북마크 제거
  ///
  /// [repositoryId] 제거할 저장소 ID
  ///
  /// Throws: [ArgumentError] 저장소 ID가 유효하지 않은 경우
  /// Throws: [StateError] 북마크되지 않은 저장소인 경우
  Future<void> call(int repositoryId) async {
    // 비즈니스 규칙: 저장소 ID 유효성 검사
    if (repositoryId <= 0) {
      throw ArgumentError('유효하지 않은 저장소 ID입니다.');
    }

    // 비즈니스 규칙: 북마크 존재 여부 확인
    final isBookmarked = await _repository.isBookmarked(repositoryId);
    if (!isBookmarked) {
      throw StateError('북마크에서 찾을 수 없는 저장소입니다.');
    }

    // 북마크 제거
    await _repository.removeBookmark(repositoryId);
  }
}