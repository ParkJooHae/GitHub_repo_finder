// lib/services/widget_service.dart
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/repository_entity.dart';

class WidgetService {
  static const String androidWidgetName = 'RepoWidgetProvider';
  static const String iOSWidgetName = 'RepoWidget';
  static const String currentIndexKey = 'widget_current_index';

  /// 위젯에 모든 북마크 데이터 전송
  static Future<void> updateWidget(List<RepositoryEntity> bookmarks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int currentIndex = prefs.getInt(currentIndexKey) ?? 0;

      // 인덱스 유효성 검사
      if (currentIndex >= bookmarks.length) {
        currentIndex = 0;
        await prefs.setInt(currentIndexKey, currentIndex);
      }

      if (bookmarks.isNotEmpty) {
        final currentRepo = bookmarks[currentIndex];

        // 현재 저장소 데이터
        await HomeWidget.saveWidgetData('repo_name', currentRepo.name);
        await HomeWidget.saveWidgetData('repo_full_name', currentRepo.fullName);
        await HomeWidget.saveWidgetData('repo_owner', currentRepo.ownerLogin);
        await HomeWidget.saveWidgetData('repo_description', currentRepo.description ?? '설명 없음');
        await HomeWidget.saveWidgetData('repo_stars', _formatNumber(currentRepo.stargazersCount));
        await HomeWidget.saveWidgetData('repo_forks', _formatNumber(currentRepo.forksCount));
        await HomeWidget.saveWidgetData('repo_language', currentRepo.language ?? '');
        await HomeWidget.saveWidgetData('repo_url', currentRepo.htmlUrl);
        await HomeWidget.saveWidgetData('avatar_url', currentRepo.avatarUrl ?? '');

        // 네비게이션 정보
        await HomeWidget.saveWidgetData('current_index', currentIndex.toString());
        await HomeWidget.saveWidgetData('total_count', bookmarks.length.toString());
        await HomeWidget.saveWidgetData('has_previous', (currentIndex > 0).toString());
        await HomeWidget.saveWidgetData('has_next', (currentIndex < bookmarks.length - 1).toString());

        // 페이지 표시 (1/3 형태)
        await HomeWidget.saveWidgetData('page_info', '${currentIndex + 1}/${bookmarks.length}');

        // 위젯에 데이터가 있음을 표시
        await HomeWidget.saveWidgetData('has_data', 'true');
      } else {
        // 북마크가 없는 경우
        await _clearWidgetData();
      }

      // 위젯 업데이트 트리거
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );

      print('Widget updated: ${bookmarks.length} bookmarks, current index: $currentIndex');
    } catch (e) {
      print('Widget update error: $e');
    }
  }

  /// 다음 북마크로 이동
  static Future<void> navigateNext(List<RepositoryEntity> bookmarks) async {
    if (bookmarks.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    int currentIndex = prefs.getInt(currentIndexKey) ?? 0;

    if (currentIndex < bookmarks.length - 1) {
      currentIndex++;
      await prefs.setInt(currentIndexKey, currentIndex);
      await updateWidget(bookmarks);
      print('Widget navigate next: index $currentIndex');
    }
  }

  /// 이전 북마크로 이동
  static Future<void> navigatePrevious(List<RepositoryEntity> bookmarks) async {
    if (bookmarks.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    int currentIndex = prefs.getInt(currentIndexKey) ?? 0;

    if (currentIndex > 0) {
      currentIndex--;
      await prefs.setInt(currentIndexKey, currentIndex);
      await updateWidget(bookmarks);
      print('Widget navigate previous: index $currentIndex');
    }
  }

  /// 위젯 인덱스 리셋 (새 북마크 추가 시)
  static Future<void> resetToFirst() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(currentIndexKey, 0);
    print('Widget index reset to first');
  }

  /// 현재 인덱스 가져오기
  static Future<int> getCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(currentIndexKey) ?? 0;
  }

  /// 위젯 데이터 초기화
  static Future<void> _clearWidgetData() async {
    await HomeWidget.saveWidgetData('repo_name', '');
    await HomeWidget.saveWidgetData('repo_full_name', '');
    await HomeWidget.saveWidgetData('repo_owner', '');
    await HomeWidget.saveWidgetData('repo_description', '북마크한 저장소가 없습니다');
    await HomeWidget.saveWidgetData('repo_stars', '');
    await HomeWidget.saveWidgetData('repo_forks', '');
    await HomeWidget.saveWidgetData('repo_language', '');
    await HomeWidget.saveWidgetData('repo_url', '');
    await HomeWidget.saveWidgetData('avatar_url', '');
    await HomeWidget.saveWidgetData('current_index', '0');
    await HomeWidget.saveWidgetData('total_count', '0');
    await HomeWidget.saveWidgetData('has_previous', 'false');
    await HomeWidget.saveWidgetData('has_next', 'false');
    await HomeWidget.saveWidgetData('page_info', '0/0');
    await HomeWidget.saveWidgetData('has_data', 'false');

    print('Widget data cleared');
  }

  /// 위젯 설정 및 초기화
  static Future<void> initializeWidget() async {
    try {
      await HomeWidget.setAppGroupId('group.com.jhp.github_repo_finder');
      print('Widget initialized');
    } catch (e) {
      print('Widget initialization error: $e');
    }
  }

  /// 위젯 클릭 이벤트 처리
  static void handleWidgetClick(Function(String) onActionReceived) {
    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null) {
        final action = uri.queryParameters['action'] ?? 'open_app';
        print('Widget clicked with action: $action');
        onActionReceived(action);
      }
    });
  }

  /// 백그라운드에서의 액션 처리 등록
  static Future<void> registerInteractivityCallback() async {
    try {
      HomeWidget.registerInteractivityCallback(backgroundCallback);
      print('Interactivity callback registered');
    } catch (e) {
      print('Interactivity callback registration error: $e');
    }
  }

  /// 숫자 포맷팅 (1000 -> 1k)
  static String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}

/// 백그라운드 콜백 함수 (위젯에서 버튼 클릭 시 호출)
@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri? data) async {
  // 백그라운드에서 위젯 액션 처리
  print('Background callback received: $data');

  if (data != null) {
    final action = data.queryParameters['action'];
    print('Action received: $action');

    // 필요한 경우 여기서 데이터 업데이트 로직 추가
    // 예: SharedPreferences 업데이트 등
  }
}