import 'package:hive/hive.dart';
import '../../core/errors/exceptions.dart';
import '../models/bookmark_model.dart';
import '../../domain/entities/repository_entity.dart';

abstract class BookmarkLocalDataSource {
  Future<List<RepositoryEntity>> getBookmarks();
  Future<void> addBookmark(RepositoryEntity repository);
  Future<void> removeBookmark(int repositoryId);
  Future<bool> isBookmarked(int repositoryId);
  Future<RepositoryEntity?> getLatestBookmark();
  Future<void> clearAllBookmarks();
}

class BookmarkLocalDataSourceImpl implements BookmarkLocalDataSource {
  static const String _boxName = 'bookmarks';
  late final Box<BookmarkModel> _bookmarkBox;

  BookmarkLocalDataSourceImpl() {
    _bookmarkBox = Hive.box<BookmarkModel>(_boxName);
  }

  /// Hive 박스 초기화 (앱 시작 시 호출)
  static Future<void> initialize() async {
    await Hive.openBox<BookmarkModel>(_boxName);
  }

  @override
  Future<List<RepositoryEntity>> getBookmarks() async {
    try {
      final bookmarks = _bookmarkBox.values.toList();

      // 북마크 추가 시간 역순으로 정렬 (최신이 먼저)
      bookmarks.sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));

      return bookmarks.map((bookmark) => bookmark.toEntity()).toList();
    } catch (e) {
      throw LocalDatabaseException('북마크 목록을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> addBookmark(RepositoryEntity repository) async {
    try {
      // 이미 북마크된 저장소인지 확인
      final existingKey = _findBookmarkKey(repository.id);
      if (existingKey != null) {
        throw LocalDatabaseException('이미 북마크에 추가된 저장소입니다.');
      }

      // 북마크 추가
      final bookmark = BookmarkModel.fromEntity(repository);
      await _bookmarkBox.add(bookmark);
    } catch (e) {
      if (e is LocalDatabaseException) rethrow;
      throw LocalDatabaseException('북마크 추가 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> removeBookmark(int repositoryId) async {
    try {
      final key = _findBookmarkKey(repositoryId);
      if (key == null) {
        throw LocalDatabaseException('북마크에서 찾을 수 없는 저장소입니다.');
      }

      await _bookmarkBox.delete(key);
    } catch (e) {
      if (e is LocalDatabaseException) rethrow;
      throw LocalDatabaseException('북마크 제거 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<bool> isBookmarked(int repositoryId) async {
    try {
      return _findBookmarkKey(repositoryId) != null;
    } catch (e) {
      throw LocalDatabaseException('북마크 상태 확인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<RepositoryEntity?> getLatestBookmark() async {
    try {
      final bookmarks = _bookmarkBox.values.toList();
      if (bookmarks.isEmpty) return null;

      // 가장 최근에 추가된 북마크 찾기
      bookmarks.sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));
      return bookmarks.first.toEntity();
    } catch (e) {
      throw LocalDatabaseException('최근 북마크를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> clearAllBookmarks() async {
    try {
      await _bookmarkBox.clear();
    } catch (e) {
      throw LocalDatabaseException('모든 북마크 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 저장소 ID로 북마크 키 찾기
  dynamic _findBookmarkKey(int repositoryId) {
    for (final key in _bookmarkBox.keys) {
      final bookmark = _bookmarkBox.get(key);
      if (bookmark != null && bookmark.id == repositoryId) {
        return key;
      }
    }
    return null;
  }

  /// 북마크 개수 가져오기
  int get bookmarkCount => _bookmarkBox.length;

  /// 박스 닫기 (앱 종료 시 호출)
  Future<void> close() async {
    await _bookmarkBox.close();
  }
}