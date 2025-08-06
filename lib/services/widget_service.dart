import 'package:home_widget/home_widget.dart';
import '../domain/entities/repository_entity.dart';

class WidgetService {
  static const String androidWidgetName = 'RepoWidgetProvider';
  static const String iOSWidgetName = 'RepoWidget';

  /// 위젯에 최신 북마크 데이터 전송
  static Future<void> updateWidget(List<RepositoryEntity> bookmarks) async {
    try {
      if (bookmarks.isNotEmpty) {
        final latestRepo = bookmarks.first;
        await HomeWidget.saveWidgetData('repo_name', latestRepo.name);
        await HomeWidget.saveWidgetData('repo_full_name', latestRepo.fullName);
        await HomeWidget.saveWidgetData('repo_owner', latestRepo.ownerLogin);
        await HomeWidget.saveWidgetData('repo_stars', _formatNumber(latestRepo.stargazersCount));
        await HomeWidget.saveWidgetData('repo_language', latestRepo.language ?? '');
        await HomeWidget.saveWidgetData('repo_url', latestRepo.htmlUrl);
        await HomeWidget.saveWidgetData('avatar_url', latestRepo.avatarUrl ?? '');
        await HomeWidget.saveWidgetData('has_data', 'true');
      } else {
        await _clearWidgetData();
      }

      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );

      
    } catch (e) {
      
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
  }

  /// 위젯 설정 및 초기화
  static Future<void> initializeWidget() async {
    try {
      await HomeWidget.setAppGroupId('group.com.jhp.github_repo_finder');
      
    } catch (e) {
      
    }
  }

  static String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}

@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri? data) async {
  // 추가 기능이 필요하다면 여기서
}