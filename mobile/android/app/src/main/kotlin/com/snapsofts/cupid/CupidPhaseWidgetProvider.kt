package com.snapsofts.cupid

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import com.snapsofts.cupid_mobile.MainActivity
import com.snapsofts.cupid_mobile.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

// This provider deliberately lives in the application id package rather than
// the module namespace: home_widget resolves an updateWidget(androidName:)
// request as "<applicationId>.<className>", so the plain provider name in
// architecture/contract-summary.md 2 only matches from here.
class CupidPhaseWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val primary = widgetData.getString(KEY_PRIMARY_LINE, null)
        val secondary = widgetData.getString(KEY_SECONDARY_LINE, null)
        val cardId = widgetData.getString(KEY_CARD_ID, null)

        val hasPrimary = !primary.isNullOrBlank()
        val hasSecondary = !secondary.isNullOrBlank()

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.cupid_phase_widget)

            views.setTextViewText(R.id.cupid_phase_widget_primary, primary ?: EMPTY)
            views.setViewVisibility(
                R.id.cupid_phase_widget_primary,
                if (hasPrimary) View.VISIBLE else View.GONE,
            )

            views.setTextViewText(R.id.cupid_phase_widget_secondary, secondary ?: EMPTY)
            views.setViewVisibility(
                R.id.cupid_phase_widget_secondary,
                if (hasSecondary) View.VISIBLE else View.GONE,
            )

            views.setOnClickPendingIntent(
                R.id.cupid_phase_widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, deepLink(cardId)),
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun deepLink(cardId: String?): Uri {
        val builder = Uri.Builder().scheme(DEEP_LINK_SCHEME)
        return if (cardId.isNullOrBlank()) {
            builder.authority(DEEP_LINK_HOME_HOST).build()
        } else {
            builder.authority(DEEP_LINK_CARD_HOST).appendPath(cardId).build()
        }
    }

    private companion object {
        const val KEY_PRIMARY_LINE = "primary_line"
        const val KEY_SECONDARY_LINE = "secondary_line"
        const val KEY_CARD_ID = "card_id"

        const val DEEP_LINK_SCHEME = "cupidapp"
        const val DEEP_LINK_CARD_HOST = "card"
        const val DEEP_LINK_HOME_HOST = "home"

        const val EMPTY = ""
    }
}
