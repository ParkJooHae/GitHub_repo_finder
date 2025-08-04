import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/bookmark_local_datasource.dart';
import '../../domain/entities/repository_entity.dart';

/// 북마크 상태
enum BookmarkStatus {
  initial,  // 초기 상태
  loading,  // 로딩 중
  success,  // 성공
  error,    // 에러
}

class BookmarkProvider extends ChangeNotifier {
  final BookmarkLocalDataSource _dataSource;

  // 상태 관리
  BookmarkStatus _status = BookmarkStatus.initial;
  List<RepositoryEntity> _bookmarks = [];
  String _errorMessage = '';
  Set<int> _bookmarkedIds = {}; // 북마크된 저장소 ID 캐시

  BookmarkProvider({BookmarkLocalDataSource? dataSource})
      : _dataSource = dataSource ?? BookmarkLocalDataSourceImpl() {
    _loadBookmarks();
  }

  // Getters
  BookmarkStatus get status => _status;
  List<RepositoryEntity> get bookmarks => _bookmarks;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == BookmarkStatus.loading;
  bool get hasError => _status == BookmarkStatus.error;
  bool get hasBookmarks => _bookmarks.isNotEmpty;
  int get bookmarkCount => _bookmarks.length;

  /// 저장소가 북마크되어 있는지 확인
  bool isBookmarked(int repositoryId) {
    return _bookmarkedIds.contains(repositoryId);
  }

  /// 가장 최근 북마크 가져오기 (위젯용)
  RepositoryEntity? get latestBookmark {
    if (_bookmarks.isEmpty) return null;
    return _bookmarks.first; // 이미 최신순으로 정렬되어 있음
  }

  /// 북마크 목록 로드
  Future<void> _loadBookmarks() async {
    try {
      _status = BookmarkStatus.loading;
      notifyListeners();

      _bookmarks = await _dataSource.getBookmarks();
      _updateBookmarkedIds();

      _status = BookmarkStatus.success;
      _errorMessage = '';
    } catch (e) {
      _handleError(e);
    }

    notifyListeners();
  }

  /// 북마크 추가
  Future<void> addBookmark(RepositoryEntity repository) async {
    try {
      // 이미 북마크된 경우 중복 방지
      if (isBookmarked(repository.id)) {
        throw LocalDatabaseException('이미 북마크에 추가된 저장소입니다.');
      }

      await _dataSource.addBookmark(repository);

      // 로컬 상태 업데이트
      final bookmarkedRepo = repository.copyWithBookmark();
      _bookmarks.insert(0, bookmarkedRepo); // 맨 앞에 추가 (최신)
      _bookmarkedIds.add(repository.id);

      notifyListeners();

      if (kDebugMode) {
        print('북마크 추가됨: ${repository.name}');
      }
    } catch (e) {
      _handleError(e);
      rethrow; // UI에서 에러 메시지를 표시할 수 있도록
    }
  }

  /// 북마크 제거
  Future<void> removeBookmark(int repositoryId) async {
    try {
      await _dataSource.removeBookmark(repositoryId);

      // 로컬 상태 업데이트
      _bookmarks.removeWhere((repo) => repo.id == repositoryId);
      _bookmarkedIds.remove(repositoryId);

      notifyListeners();

      if (kDebugMode) {
        print('북마크 제거됨: $repositoryId');
      }
    } catch (e) {
      _handleError(e);
      rethrow; // UI에서 에러 메시지를 표시할 수 있도록
    }
  }

  /// 북마크 토글 (추가/제거)
  Future<void> toggleBookmark(RepositoryEntity repository) async {
    if (isBookmarked(repository.id)) {
      await removeBookmark(repository.id);
    } else {
      await addBookmark(repository);
    }
  }

  /// 북마크 새로고침
  Future<void> refreshBookmarks() async {
    await _loadBookmarks();
  }

  /// 모든 북마크 삭제
  Future<void> clearAllBookmarks() async {
    try {
      await _dataSource.clearAllBookmarks();
      _bookmarks.clear();
      _bookmarkedIds.clear();
      notifyListeners();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 북마크된 ID 캐시 업데이트
  void _updateBookmarkedIds() {
    _bookmarkedIds = _bookmarks.map((repo) => repo.id).toSet();
  }

  /// 에러 처리
  void _handleError(dynamic error) {
    String message;

    if (error is LocalDatabaseException) {
      message = error.message;
    } else {
      message = '알 수 없는 오류가 발생했습니다.';
    }

    _errorMessage = message;
    _status = BookmarkStatus.error;

    if (kDebugMode) {
      print('Bookmark Error: $error');
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    if (_status == BookmarkStatus.error) {
      _status = _bookmarks.isEmpty ? BookmarkStatus.initial : BookmarkStatus.success;
      _errorMessage = '';
      notifyListeners();
    }
  }
}