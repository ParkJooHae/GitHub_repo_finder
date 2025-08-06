import '../entities/repository_entity.dart';
import '../repositories/bookmark_repository.dart';

/// - 중복 북마크 방지
/// - 저장소 정보 유효성 검사
class AddBookmarkUseCase {
  final BookmarkRepository _repository;

  AddBookmarkUseCase(this._repository);

  /// 북마크 추가
  Future<void> call(RepositoryEntity repository) async {
    if (repository.name.trim().isEmpty) {
      throw ArgumentError('저장소 이름이 유효하지 않습니다.');
    }

    if (repository.htmlUrl.trim().isEmpty) {
      throw ArgumentError('저장소 URL이 유효하지 않습니다.');
    }

    final isAlreadyBookmarked = await _repository.isBookmarked(repository.id);
    if (isAlreadyBookmarked) {
      throw StateError('이미 북마크에 추가된 저장소입니다.');
    }

    await _repository.addBookmark(repository);
  }
}