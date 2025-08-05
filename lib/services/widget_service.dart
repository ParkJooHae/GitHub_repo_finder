import 'package:home_widget/home_widget.dart';
import '../domain/entities/repository_entity.dart';

class WidgetService {
  static const String androidWidgetName = 'RepoWidgetProvider';
  static const String iOSWidgetName = 'RepoWidget';

  /// 위젯에 최신 북마크 데이터 전송
  static Future<void> updateWidget(List<RepositoryEntity> bookmarks) async {
    try {
      if (bookmarks.isNotEmpty) {
        final latestRepo = bookmarks.first; // 항상 첫 번째 (최신) 북마크만 표시

        // 최신 저장소 데이터
        await HomeWidget.saveWidgetData('repo_name', latestRepo.name);
        await HomeWidget.saveWidgetData('repo_full_name', latestRepo.fullName);
        await HomeWidget.saveWidgetData('repo_owner', latestRepo.ownerLogin);
        await HomeWidget.saveWidgetData('repo_stars', _formatNumber(latestRepo.stargazersCount));
        await HomeWidget.saveWidgetData('repo_language', latestRepo.language ?? '');
        await HomeWidget.saveWidgetData('repo_url', latestRepo.htmlUrl);
        await HomeWidget.saveWidgetData('avatar_url', latestRepo.avatarUrl ?? '');

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

      print('Widget updated: latest bookmark displayed');
    } catch (e) {
      print('Widget update error: $e');
    }
  }

  /// 위젯 데이터 초기화
  static Future<void> _clearWidgetData() async {
    await HomeWidget.saveWidgetData('repo_name', '');
    await HomeWidget.saveWidgetData('repo_full_name', '');
    await HomeWidget.saveWidgetData('repo_owner', '');
    await HomeWidget.saveWidgetData('repo_stars', '');
    await HomeWidget.saveWidgetData('repo_language', '');
    await HomeWidget.saveWidgetData('repo_url', '');
    await HomeWidget.saveWidgetData('avatar_url', '');
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

  /// 숫자 포맷팅 (1000 -> 1k)
  static String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}

/// 백그라운드 콜백 함수 (사용하지 않지만 호환성을 위해 유지)
@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri? data) async {
  // 더 이상 사용하지 않음
  print('Background callback received (not used): $data');
}