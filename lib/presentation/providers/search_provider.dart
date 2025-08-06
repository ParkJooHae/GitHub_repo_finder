import 'package:flutter/foundation.dart';
import '../../core/utils/debouncer.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/repository_entity.dart';
import '../../domain/usecases/search_repositories.dart';

/// 검색 상태
enum SearchStatus {
  initial,    // 초기 상태
  loading,    // 로딩 중
  success,    // 성공
  error,      // 에러
  loadingMore, // 더 많은 데이터 로딩 중
}

class SearchProvider extends ChangeNotifier {
  final SearchRepositoriesUseCase _searchRepositoriesUseCase;
  final Debouncer _debouncer;

  // 상태 관리
  SearchStatus _status = SearchStatus.initial;
  List<RepositoryEntity> _repositories = [];
  String _errorMessage = '';
  String _currentQuery = '';

  // 페이지네이션
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMorePages = false;
  static const int _perPage = 30;

  SearchProvider(this._searchRepositoriesUseCase)
      : _debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  // Getters
  SearchStatus get status => _status;
  List<RepositoryEntity> get repositories => _repositories;
  String get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;
  int get totalCount => _totalCount;
  bool get hasMorePages => _hasMorePages;
  bool get isLoading => _status == SearchStatus.loading;
  bool get isLoadingMore => _status == SearchStatus.loadingMore;
  bool get hasError => _status == SearchStatus.error;
  bool get hasData => _repositories.isNotEmpty;

  /// 검색 실행
  void searchRepositories(String query) {
    _currentQuery = query.trim();

    // 디바운싱 적용
    _debouncer.call(() {
      if (_currentQuery.isEmpty) {
        _clearResults();
      } else {
        _performSearch(_currentQuery, isNewSearch: true);
      }
    });
  }

  /// 현재 쿼리 설정 (TextField 동기화용)
  void setCurrentQuery(String query) {
    _currentQuery = query.trim();
    notifyListeners();
  }

  /// 다음 페이지 로드
  Future<void> loadMoreRepositories() async {
    // 이미 로딩 중이거나 더 이상 페이지가 없으면 스킵
    if (!_hasMorePages || _isLoadingAny() || _currentQuery.isEmpty) {
      return;
    }

    await _performSearch(_currentQuery, isNewSearch: false);
  }

  /// 검색 새로고침
  Future<void> refreshSearch() async {
    if (_currentQuery.isEmpty) return;
    await _performSearch(_currentQuery, isNewSearch: true);
  }

  Future<void> _performSearch(String query, {required bool isNewSearch}) async {
    try {
      // 새 검색인 경우 페이지 초기화
      if (isNewSearch) {
        _currentPage = 1;
        _status = SearchStatus.loading;
      } else {
        _currentPage++;
        _status = SearchStatus.loadingMore;
      }

      notifyListeners();

      final result = await _searchRepositoriesUseCase.call(
        query: query,
        page: _currentPage,
        perPage: _perPage,
      );

      final newRepositories = result.items;

      if (isNewSearch) {
        _repositories = newRepositories;
      } else {
        _repositories.addAll(newRepositories);
      }

      _totalCount = result.totalCount;
      _hasMorePages = result.hasMorePages;
      _status = SearchStatus.success;
      _errorMessage = '';

    } catch (e) {
      _handleError(e, isNewSearch);
    }

    notifyListeners();
  }

  /// 에러 처리
  void _handleError(dynamic error, bool isNewSearch) {
    String message;

    if (error is RateLimitException) {
      final resetTime = error.resetTime;
      if (resetTime != null) {
        final waitMinutes = resetTime.difference(DateTime.now()).inMinutes;
        message = 'API 사용량 한도 초과. ${waitMinutes}분 후 다시 시도해주세요.';
      } else {
        message = 'API 사용량 한도를 초과했습니다. 잠시 후 다시 시도해주세요.';
      }
    } else if (error is NetworkException) {
      message = error.message;
    } else if (error is GitHubApiException) {
      message = error.message;
    } else {
      message = '알 수 없는 오류가 발생했습니다.';
    }

    _errorMessage = message;
    _status = SearchStatus.error;

    // 새 검색이 아닌 경우 페이지 롤백
    if (!isNewSearch && _currentPage > 1) {
      _currentPage--;
    }
  }

  /// 결과 초기화
  void _clearResults() {
    _repositories.clear();
    _currentPage = 1;
    _totalCount = 0;
    _hasMorePages = false;
    _status = SearchStatus.initial;
    _errorMessage = '';
    _currentQuery = ''; // 현재 쿼리도 초기화
    notifyListeners();
  }

  /// 로딩 상태 확인
  bool _isLoadingAny() {
    return _status == SearchStatus.loading || _status == SearchStatus.loadingMore;
  }

  /// 에러 상태 초기화
  void clearError() {
    if (_status == SearchStatus.error) {
      _status = _repositories.isEmpty ? SearchStatus.initial : SearchStatus.success;
      _errorMessage = '';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}