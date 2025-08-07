import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/repository_entity.dart';
import '../../domain/usecases/get_bookmarks.dart';
import '../../domain/usecases/add_bookmark.dart';
import '../../domain/usecases/remove_bookmark.dart';
import '../../domain/usecases/toggle_bookmark.dart';
import '../../domain/usecases/clear_all_bookmarks.dart';
import '../../services/widget_service.dart';

/// 북마크 정렬 방식
enum BookmarkSortOrder {
  newest,  // 최신순
  oldest,  // 오래된순
}

/// 북마크 상태
enum BookmarkStatus {
  initial,  // 기본
  loading,  // 로딩 중
  success,  // 성공
  error,    // 에러
}

class BookmarkProvider extends ChangeNotifier {

  // UseCase
  final GetBookmarksUseCase _getBookmarksUseCase;
  final AddBookmarkUseCase _addBookmarkUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final ToggleBookmarkUseCase _toggleBookmarkUseCase;
  final ClearAllBookmarksUseCase _clearAllBookmarksUseCase;

  // 상태 관리 변수
  BookmarkStatus _status = BookmarkStatus.initial;  // 현재 북마크 상태
  List<RepositoryEntity> _bookmarks = []; // 북마크된 저장소 목록
  String _errorMessage = '';  // 에러 메시지
  Set<int> _bookmarkedIds = {};  // 북마크된 저장소 ID 캐시 (빠른 조회용)
  BookmarkSortOrder _sortOrder = BookmarkSortOrder.newest;  // 정렬 순서

  BookmarkProvider({
    required GetBookmarksUseCase getBookmarksUseCase,
    required AddBookmarkUseCase addBookmarkUseCase,
    required RemoveBookmarkUseCase removeBookmarkUseCase,
    required ToggleBookmarkUseCase toggleBookmarkUseCase,
    required ClearAllBookmarksUseCase clearAllBookmarksUseCase,
  })  : _getBookmarksUseCase = getBookmarksUseCase,
        _addBookmarkUseCase = addBookmarkUseCase,
        _removeBookmarkUseCase = removeBookmarkUseCase,
        _toggleBookmarkUseCase = toggleBookmarkUseCase,
        _clearAllBookmarksUseCase = clearAllBookmarksUseCase {
    _loadBookmarks();
  }

  // Getter 메서드들
  BookmarkStatus get status => _status;
  List<RepositoryEntity> get bookmarks => _bookmarks;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == BookmarkStatus.loading;
  bool get hasError => _status == BookmarkStatus.error;
  bool get hasBookmarks => _bookmarks.isNotEmpty;
  int get bookmarkCount => _bookmarks.length;
  BookmarkSortOrder get sortOrder => _sortOrder;

  /// 정렬 순서 토글
  void toggleSortOrder() {
    _sortOrder = _sortOrder == BookmarkSortOrder.newest 
        ? BookmarkSortOrder.oldest 
        : BookmarkSortOrder.newest;
    
    // 현재 정렬 상태에 따라 리스트를 뒤집기
    if (_bookmarks.isNotEmpty) {
      _bookmarks = _bookmarks.reversed.toList();
    }
    
    notifyListeners();
  }

  /// 저장소가 북마크되어 있는지 확인
  bool isBookmarked(int repositoryId) {
    return _bookmarkedIds.contains(repositoryId);
  }

  /// 가장 최근 북마크 가져오기 (위젯용)
  RepositoryEntity? get latestBookmark {
    if (_bookmarks.isEmpty) return null;
    return _bookmarks.first;
  }

  /// 북마크 목록 로드 (UseCase 사용)
  Future<void> _loadBookmarks() async {
    try {
      _status = BookmarkStatus.loading;
      notifyListeners();

      _bookmarks = await _getBookmarksUseCase.call();
      _updateBookmarkedIds();

      await WidgetService.updateWidget(_bookmarks);

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
      await _addBookmarkUseCase.call(repository);

      final bookmarkedRepo = repository.copyWithBookmark();
      _bookmarks.insert(0, bookmarkedRepo);
      _bookmarkedIds.add(repository.id);

      await WidgetService.updateWidget(_bookmarks);

      notifyListeners();

    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 북마크 제거
  Future<void> removeBookmark(int repositoryId) async {
    try {
      await _removeBookmarkUseCase.call(repositoryId);

      final removedRepo = _bookmarks.firstWhere((repo) => repo.id == repositoryId);
      _bookmarks.removeWhere((repo) => repo.id == repositoryId);
      _bookmarkedIds.remove(repositoryId);

      await WidgetService.updateWidget(_bookmarks);

      notifyListeners();

    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 북마크 토글 (UseCase 사용)
  Future<void> toggleBookmark(RepositoryEntity repository) async {
    try {
      final isNowBookmarked = await _toggleBookmarkUseCase.call(repository);

      await _loadBookmarks();

    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 북마크 새로고침
  Future<void> refreshBookmarks() async {
    await _loadBookmarks();
  }

  /// 모든 북마크 삭제
  Future<void> clearAllBookmarks() async {
    try {
      final deletedCount = await _clearAllBookmarksUseCase.call();

      if (deletedCount > 0) {
        _bookmarks.clear();
        _bookmarkedIds.clear();

        await WidgetService.updateWidget(_bookmarks);

        notifyListeners();

      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 삭제할 북마크가 있는지 확인
  Future<bool> hasBookmarksToDelete() async {
    try {
      return await _clearAllBookmarksUseCase.hasBookmarksToDelete();
    } catch (e) {
      return _bookmarks.isNotEmpty;
    }
  }

  /// 위젯 강제 업데이트 (디버깅용)
  Future<void> forceUpdateWidget() async {
    await WidgetService.updateWidget(_bookmarks);
  }

  /// 북마크된 ID 캐시 업데이트
  void _updateBookmarkedIds() {
    _bookmarkedIds = _bookmarks.map((repo) => repo.id).toSet();
  }

  /// 에러 처리
  void _handleError(dynamic error) {
    String message;

    if (error is ArgumentError) {
      // 유효성 검사 에러
      message = error.message;
    } else if (error is StateError) {
      // 북마크 상태 에러
      message = error.message;
    } else if (error is LocalDatabaseException) {
      message = error.message;
    } else {
      message = '알 수 없는 오류가 발생했습니다.';
    }

    _errorMessage = message;
    _status = BookmarkStatus.error;
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