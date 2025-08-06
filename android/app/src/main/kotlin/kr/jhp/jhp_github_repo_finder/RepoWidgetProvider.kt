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
            views.setTextViewText(R.id.repo_name, repoName)
            views.setTextViewText(R.id.repo_owner, repoOwner ?: "")

            val statsText = if (!repoStars.isNullOrEmpty()) {
                "⭐ $repoStars"
            } else {
                ""
            }
            views.setTextViewText(R.id.repo_stats, statsText)

            if (!repoLanguage.isNullOrEmpty()) {
                views.setTextViewText(R.id.repo_language, repoLanguage)
                views.setViewVisibility(R.id.repo_language, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.repo_language, View.GONE)
            }
        } else {
            views.setTextViewText(R.id.repo_name, "GitHub Repo Finder")
            views.setTextViewText(R.id.repo_owner, "북마크한 저장소가 없습니다")
            views.setTextViewText(R.id.repo_stats, "")
            views.setTextViewText(R.id.repo_language, "")
            views.setViewVisibility(R.id.repo_language, View.GONE)
        }

        views.setOnClickPendingIntent(R.id.widget_card, null)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }
}