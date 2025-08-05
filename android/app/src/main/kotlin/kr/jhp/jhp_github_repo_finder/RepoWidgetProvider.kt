package kr.jhp.jhp_github_repo_finder

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class RepoWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.repo_widget)

        val hasData = widgetData.getString("has_data", "false") == "true"
        val repoName = widgetData.getString("repo_name", "")
        val repoOwner = widgetData.getString("repo_owner", "")
        val repoStars = widgetData.getString("repo_stars", "")
        val repoLanguage = widgetData.getString("repo_language", "")

        if (hasData && repoName?.isNotEmpty() == true) {
            // 저장소 정보 표시
            views.setTextViewText(R.id.repo_name, repoName)
            views.setTextViewText(R.id.repo_owner, repoOwner ?: "")

            // 통계 정보 (stars만 표시)
            val statsText = if (!repoStars.isNullOrEmpty()) {
                "⭐ $repoStars"
            } else {
                ""
            }
            views.setTextViewText(R.id.repo_stats, statsText)

            // 언어 정보
            if (!repoLanguage.isNullOrEmpty()) {
                views.setTextViewText(R.id.repo_language, repoLanguage)
                views.setViewVisibility(R.id.repo_language, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.repo_language, View.GONE)
            }
        } else {
            // 빈 상태
            views.setTextViewText(R.id.repo_name, "GitHub Repo Finder")
            views.setTextViewText(R.id.repo_owner, "북마크한 저장소가 없습니다")
            views.setTextViewText(R.id.repo_stats, "")
            views.setTextViewText(R.id.repo_language, "")
            views.setViewVisibility(R.id.repo_language, View.GONE)
        }

        // 클릭 이벤트 제거 - 위젯 클릭 불가
        views.setOnClickPendingIntent(R.id.widget_card, null)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    override fun onEnabled(context: Context) {
        // 첫 위젯이 생성될 때 호출
        super.onEnabled(context)
        println("RepoWidget: Widget enabled")
    }

    override fun onDisabled(context: Context) {
        // 마지막 위젯이 제거될 때 호출
        super.onDisabled(context)
        println("RepoWidget: Widget disabled")
    }
}