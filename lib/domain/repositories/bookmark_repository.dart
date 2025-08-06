import '../entities/repository_entity.dart';

abstract class BookmarkRepository {

  /// 모든 북마크 조회
  Future<List<RepositoryEntity>> getBookmarks();

  /// 북마크 추가
  /// [repository] 추가할 저장소
  /// Throws: [StateError] 이미 북마크된 경우
  Future<void> addBookmark(RepositoryEntity repository);

  /// 북마크 제거
  /// [repositoryId] 제거할 저장소 ID
  /// Throws: [StateError] 북마크되지 않은 경우
  Future<void> removeBookmark(int repositoryId);

  /// 북마크 상태 확인
  /// [repositoryId] 확인할 저장소 ID
  /// Returns: 북마크 여부
  Future<bool> isBookmarked(int repositoryId);

  /// 가장 최근 북마크 조회 (위젯)
  /// Returns: 최신 북마크 또는 null
  Future<RepositoryEntity?> getLatestBookmark();

  /// 모든 북마크 삭제
  Future<void> clearAllBookmarks();

  /// 북마크 개수 조회
  /// Returns: 총 북마크 개수
  Future<int> getBookmarkCount();
}