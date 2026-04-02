package com.voicetask.voicetask

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import android.app.PendingIntent
import android.content.Intent
import android.graphics.Color

class HomeScreenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Set task count
                val taskCount = widgetData.getInt("task_count", 0)

                // Task 1
                val title0 = widgetData.getString("task_title_0", "") ?: ""
                val status0 = widgetData.getString("task_status_0", "") ?: ""
                setTextViewText(R.id.task_title_1, if (title0.isNotEmpty()) title0 else "No tasks")
                setInt(R.id.task_dot_1, "setColorFilter", getStatusColor(status0))
                setViewVisibility(R.id.task_row_1, android.view.View.VISIBLE)

                // Task 2
                val title1 = widgetData.getString("task_title_1", "") ?: ""
                val status1 = widgetData.getString("task_status_1", "") ?: ""
                if (title1.isNotEmpty()) {
                    setTextViewText(R.id.task_title_2, title1)
                    setInt(R.id.task_dot_2, "setColorFilter", getStatusColor(status1))
                    setViewVisibility(R.id.task_row_2, android.view.View.VISIBLE)
                } else {
                    setViewVisibility(R.id.task_row_2, android.view.View.GONE)
                }

                // Task 3
                val title2 = widgetData.getString("task_title_2", "") ?: ""
                val status2 = widgetData.getString("task_status_2", "") ?: ""
                if (title2.isNotEmpty()) {
                    setTextViewText(R.id.task_title_3, title2)
                    setInt(R.id.task_dot_3, "setColorFilter", getStatusColor(status2))
                    setViewVisibility(R.id.task_row_3, android.view.View.VISIBLE)
                } else {
                    setViewVisibility(R.id.task_row_3, android.view.View.GONE)
                }

                // "Add via Voice" button — opens voice screen
                val voiceIntent = Intent(context, Class.forName("${context.packageName}.MainActivity")).apply {
                    data = Uri.parse("voicetask://voice")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val voicePendingIntent = PendingIntent.getActivity(
                    context, 1, voiceIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.btn_add_voice, voicePendingIntent)

                // Tapping the widget opens the app
                val appIntent = Intent(context, Class.forName("${context.packageName}.MainActivity")).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val appPendingIntent = PendingIntent.getActivity(
                    context, 0, appIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, appPendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun getStatusColor(status: String): Int {
        return when (status) {
            "todo" -> Color.parseColor("#7C3AED")       // Purple
            "inprogress" -> Color.parseColor("#F59E0B")  // Amber
            "done" -> Color.parseColor("#10B981")        // Green
            else -> Color.parseColor("#94A3B8")           // Gray
        }
    }
}
