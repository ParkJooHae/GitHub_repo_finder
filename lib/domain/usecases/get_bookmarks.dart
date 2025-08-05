import '../entities/repository_entity.dart';
import '../repositories/bookmark_repository.dart';

/// 북마크 목록 조회 UseCase
///
/// 비즈니스 로직:
/// - 북마크 목록을 최신순으로 정렬하여 반환
class GetBookmarksUseCase {
  final BookmarkRepository _repository;

  GetBookmarksUseCase(this._repository);

  /// 북마크 목록 조회
  ///
  /// Returns: 북마크된 저장소 목록 (최신순)
  Future<List<RepositoryEntity>> call() async {
    return await _repository.getBookmarks();
  }

  /// 북마크 개수 조회
  ///
  /// Returns: 총 북마크 개수
  Future<int> getCount() async {
    return await _repository.getBookmarkCount();
  }

  /// 가장 최근 북마크 조회 (위젯용)
  ///
  /// Returns: 최신 북마크 또는 null
  Future<RepositoryEntity?> getLatest() async {
    return await _repository.getLatestBookmark();
  }
}