import '../entities/repository_entity.dart';
import '../repositories/bookmark_repository.dart';

/// 북마크 토글 UseCase
///
/// 비즈니스 로직:
/// - 북마크되어 있으면 제거, 없으면 추가
/// - 상태 변경 결과를 반환
class ToggleBookmarkUseCase {
  final BookmarkRepository _repository;

  ToggleBookmarkUseCase(this._repository);

  /// 북마크 토글 (추가/제거)
  ///
  /// [repository] 대상 저장소
  ///
  /// Returns: 토글 후 북마크 상태 (true: 추가됨, false: 제거됨)
  ///
  /// Throws: [ArgumentError] 저장소 정보가 유효하지 않은 경우
  Future<bool> call(RepositoryEntity repository) async {
    // 비즈니스 규칙: 저장소 정보 유효성 검사
    if (repository.id <= 0) {
      throw ArgumentError('유효하지 않은 저장소 ID입니다.');
    }

    if (repository.name.trim().isEmpty) {
      throw ArgumentError('저장소 이름이 유효하지 않습니다.');
    }

    // 현재 북마크 상태 확인
    final isCurrentlyBookmarked = await _repository.isBookmarked(repository.id);

    if (isCurrentlyBookmarked) {
      // 북마크 제거
      await _repository.removeBookmark(repository.id);
      return false; // 제거됨
    } else {
      // 북마크 추가
      await _repository.addBookmark(repository);
      return true; // 추가됨
    }
  }

  /// 북마크 상태 확인만 수행
  ///
  /// [repositoryId] 확인할 저장소 ID
  /// Returns: 현재 북마크 상태
  Future<bool> isBookmarked(int repositoryId) async {
    return await _repository.isBookmarked(repositoryId);
  }
}