import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/repository_entity.dart';
import '../../domain/usecases/get_bookmarks.dart';
import '../../domain/usecases/add_bookmark.dart';
import '../../domain/usecases/remove_bookmark.dart';
import '../../domain/usecases/toggle_bookmark.dart';
import '../../domain/usecases/clear_all_bookmarks.dart';
import '../../services/widget_service.dart';

/// 북마크 상태
enum BookmarkStatus {
  initial,  // 초기 상태
  loading,  // 로딩 중
  success,  // 성공
  error,    // 에러
}

class BookmarkProvider extends ChangeNotifier {
  // UseCase 의존성들
  final GetBookmarksUseCase _getBookmarksUseCase;
  final AddBookmarkUseCase _addBookmarkUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final ToggleBookmarkUseCase _toggleBookmarkUseCase;
  final ClearAllBookmarksUseCase _clearAllBookmarksUseCase;

  // 상태 관리
  BookmarkStatus _status = BookmarkStatus.initial;
  List<RepositoryEntity> _bookmarks = [];
  String _errorMessage = '';
  Set<int> _bookmarkedIds = {}; // 북마크된 저장소 ID 캐시

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

  /// 북마크 목록 로드 (UseCase 사용)
  Future<void> _loadBookmarks() async {
    try {
      _status = BookmarkStatus.loading;
      notifyListeners();

      // UseCase 호출 (기존 DataSource 직접 호출 대신)
      _bookmarks = await _getBookmarksUseCase.call();
      _updateBookmarkedIds();

      // 위젯 업데이트
      await WidgetService.updateWidget(_bookmarks);

      _status = BookmarkStatus.success;
      _errorMessage = '';

      if (kDebugMode) {
    
      }
    } catch (e) {
      _handleError(e);
    }

    notifyListeners();
  }

  /// 북마크 추가 (UseCase 사용)
  Future<void> addBookmark(RepositoryEntity repository) async {
    try {
      // UseCase 호출 (비즈니스 로직 포함)
      await _addBookmarkUseCase.call(repository);

      // 로컬 상태 업데이트
      final bookmarkedRepo = repository.copyWithBookmark();
      _bookmarks.insert(0, bookmarkedRepo); // 맨 앞에 추가 (최신)
      _bookmarkedIds.add(repository.id);

      // 위젯 업데이트 (항상 최신 북마크 표시)
      await WidgetService.updateWidget(_bookmarks);

      notifyListeners();

      if (kDebugMode) {

      }
    } catch (e) {
      _handleError(e);
      rethrow; // UI에서 에러 메시지를 표시할 수 있도록
    }
  }

  /// 북마크 제거 (UseCase 사용)
  Future<void> removeBookmark(int repositoryId) async {
    try {
      // UseCase 호출 (비즈니스 로직 포함)
      await _removeBookmarkUseCase.call(repositoryId);

      // 로컬 상태 업데이트
      final removedRepo = _bookmarks.firstWhere((repo) => repo.id == repositoryId);
      _bookmarks.removeWhere((repo) => repo.id == repositoryId);
      _bookmarkedIds.remove(repositoryId);

      // 위젯 업데이트
      await WidgetService.updateWidget(_bookmarks);

      notifyListeners();

      if (kDebugMode) {

      }
    } catch (e) {
      _handleError(e);
      rethrow; // UI에서 에러 메시지를 표시할 수 있도록
    }
  }

  /// 북마크 토글 (UseCase 사용)
  Future<void> toggleBookmark(RepositoryEntity repository) async {
    try {
      // UseCase 호출 (토글 로직 포함)
      final isNowBookmarked = await _toggleBookmarkUseCase.call(repository);

      // 전체 새로고침으로 상태 동기화 (간단하고 안전한 방법)
      await _loadBookmarks();

      if (kDebugMode) {

      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 북마크 새로고침
  Future<void> refreshBookmarks() async {
    await _loadBookmarks();
  }

  /// 모든 북마크 삭제 (UseCase 사용)
  Future<void> clearAllBookmarks() async {
    try {
      // UseCase 호출
      final deletedCount = await _clearAllBookmarksUseCase.call();

      if (deletedCount > 0) {
        _bookmarks.clear();
        _bookmarkedIds.clear();

        // 위젯 업데이트 (빈 리스트)
        await WidgetService.updateWidget(_bookmarks);

        notifyListeners();

        if (kDebugMode) {
  
        }
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
      return _bookmarks.isNotEmpty; // fallback
    }
  }

  /// 위젯 강제 업데이트 (디버깅용)
  Future<void> forceUpdateWidget() async {
    await WidgetService.updateWidget(_bookmarks);

    if (kDebugMode) {
      
    }
  }

  /// 북마크된 ID 캐시 업데이트
  void _updateBookmarkedIds() {
    _bookmarkedIds = _bookmarks.map((repo) => repo.id).toSet();
  }

  /// 에러 처리
  void _handleError(dynamic error) {
    String message;

    if (error is ArgumentError) {
      // UseCase에서 발생한 유효성 검사 에러
      message = error.message;
    } else if (error is StateError) {
      // UseCase에서 발생한 상태 에러 (중복 북마크, 존재하지 않는 북마크 등)
      message = error.message;
    } else if (error is LocalDatabaseException) {
      message = error.message;
    } else {
      message = '알 수 없는 오류가 발생했습니다.';
    }

    _errorMessage = message;
    _status = BookmarkStatus.error;

    if (kDebugMode) {

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