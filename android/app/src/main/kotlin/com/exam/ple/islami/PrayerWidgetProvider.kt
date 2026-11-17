package com.exam.ple.islami

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout).apply {
                val nextPrayer = widgetData.getString("next_prayer", "المغرب")
                val remaining = widgetData.getString("remaining_time", "00:00:00")
                val location = widgetData.getString("location", "مصر")
                setTextViewText(R.id.widget_location, location)
                setTextViewText(R.id.widget_next_prayer, "المتبقي على أذان $nextPrayer")
                setTextViewText(R.id.widget_remaining_time, remaining)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
