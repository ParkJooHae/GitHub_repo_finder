import '../entities/repository_entity.dart';
import '../repositories/bookmark_repository.dart';

/// - 북마크되어 있으면 제거, 없으면 추가
/// - 상태 변경 결과를 반환
class ToggleBookmarkUseCase {
  final BookmarkRepository _repository;

  ToggleBookmarkUseCase(this._repository);

  /// 북마크 토글 (추가/제거)
  Future<bool> call(RepositoryEntity repository) async {
    if (repository.id <= 0) {
      throw ArgumentError('유효하지 않은 저장소 ID입니다.');
    }

    if (repository.name.trim().isEmpty) {
      throw ArgumentError('저장소 이름이 유효하지 않습니다.');
    }

    final isCurrentlyBookmarked = await _repository.isBookmarked(repository.id);

    if (isCurrentlyBookmarked) {
      await _repository.removeBookmark(repository.id);
      return false;
    } else {
      await _repository.addBookmark(repository);
      return true;
    }
  }

  /// 북마크 상태 확인
  Future<bool> isBookmarked(int repositoryId) async {
    return await _repository.isBookmarked(repositoryId);
  }
}