package kr.jhp.jhp_github_repo_finder

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log

class WidgetNavigationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.getStringExtra("action")
        Log.d("WidgetNavigation", "Received action: $action")

        when (action) {
            "previous" -> navigatePrevious(context)
            "next" -> navigateNext(context)
        }
    }

    private fun navigatePrevious(context: Context) {
        val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // Flutter에서 저장된 값은 Long 타입이므로 getLong 사용
        val currentIndex = sharedPrefs.getLong("flutter.widget_current_index", 0L).toInt()
        val totalCount = sharedPrefs.getString("flutter.total_count", "0")?.toIntOrNull() ?: 0

        Log.d("WidgetNavigation", "Previous: currentIndex=$currentIndex, totalCount=$totalCount")

        // 임시로 조건 완화 - 일단 인덱스만 감소시켜보기 (0 이하로는 안 가게)
        if (currentIndex > 0) {
            val newIndex = currentIndex - 1
            sharedPrefs.edit().putLong("flutter.widget_current_index", newIndex.toLong()).apply()
            Log.d("WidgetNavigation", "Force updated index to: $newIndex")
            updateWidget(context)
        } else {
            Log.d("WidgetNavigation", "Already at first item")
        }
    }

    private fun navigateNext(context: Context) {
        val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // Flutter에서 저장된 값은 Long 타입이므로 getLong 사용
        val currentIndex = sharedPrefs.getLong("flutter.widget_current_index", 0L).toInt()
        val totalCount = sharedPrefs.getString("flutter.total_count", "0")?.toIntOrNull() ?: 0

        Log.d("WidgetNavigation", "Next: currentIndex=$currentIndex, totalCount=$totalCount")

        // 모든 SharedPreferences 키 출력 (디버깅용)
        val allPrefs = sharedPrefs.all
        for ((key, value) in allPrefs) {
            Log.d("WidgetNavigation", "SharedPrefs: $key = $value (${value?.javaClass?.simpleName})")
        }

        // 임시로 조건 완화 - 일단 인덱스만 증가시켜보기
        val newIndex = currentIndex + 1
        sharedPrefs.edit().putLong("flutter.widget_current_index", newIndex.toLong()).apply()
        Log.d("WidgetNavigation", "Force updated index to: $newIndex")
        updateWidget(context)
    }

    private fun updateWidget(context: Context) {
        Log.d("WidgetNavigation", "Updating widget...")

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, RepoWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)

        Log.d("WidgetNavigation", "Found ${appWidgetIds.size} widgets")

        val intent = Intent(context, RepoWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
        }
        context.sendBroadcast(intent)

        Log.d("WidgetNavigation", "Widget update broadcast sent")
    }
}