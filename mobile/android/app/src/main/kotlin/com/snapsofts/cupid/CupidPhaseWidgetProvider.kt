package com.snapsofts.cupid

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
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
        val eyebrow = widgetData.getString(KEY_EYEBROW_LINE, null)
        val phaseId = widgetData.getString(KEY_PHASE_ID, null)
        val cardId = widgetData.getString(KEY_CARD_ID, null)

        val hasPrimary = !primary.isNullOrBlank()
        val hasSecondary = !secondary.isNullOrBlank()
        val hasEyebrow = !eyebrow.isNullOrBlank()
        val dotColor = CupidWidgetPalette.dotFor(phaseId)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.cupid_phase_widget)

            views.setTextViewText(R.id.cupid_phase_widget_eyebrow, eyebrow ?: EMPTY)
            views.setTextColor(R.id.cupid_phase_widget_eyebrow, dotColor)
            views.setImageViewBitmap(R.id.cupid_phase_widget_dot, dotBitmap(dotColor))
            views.setViewVisibility(
                R.id.cupid_phase_widget_eyebrow_row,
                if (hasEyebrow) View.VISIBLE else View.GONE,
            )

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

    private fun dotBitmap(color: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(CIRCLE_PX, CIRCLE_PX, Bitmap.Config.ARGB_8888)
        val radius = CIRCLE_PX / 2f
        Canvas(bitmap).drawCircle(
            radius,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color },
        )
        return bitmap
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
        const val KEY_PHASE_ID = "phase_id"
        const val KEY_PRIMARY_LINE = "primary_line"
        const val KEY_SECONDARY_LINE = "secondary_line"
        const val KEY_EYEBROW_LINE = "eyebrow_line"
        const val KEY_CARD_ID = "card_id"

        const val DEEP_LINK_SCHEME = "cupidapp"
        const val DEEP_LINK_CARD_HOST = "card"
        const val DEEP_LINK_HOME_HOST = "home"

        const val EMPTY = ""
        const val CIRCLE_PX = 24
    }
}

// D-12 on the Android side: the brand dark palette as colour literals, the same
// values cupid_phase_widget.xml carries and the same ones CupidWidgetPalette in
// CupidPhaseWidget.swift carries, copied from
// lib/design_system/tokens/cupid_color_tokens.dart (dark theme). A Kotlin object
// rather than res/values/colors.xml because res/values is outside this phase's
// write scope and this file already is the Android home of D-12.
//
// D-10 (architecture/contract-summary.md 3a): four dot token roles, one per
// phase_id of the closed set. No fifth role, no interpolation, and no system
// colour - an unknown or missing phase_id draws the neutral waiting role rather
// than whatever the launcher theme would supply.
private object CupidWidgetPalette {
    const val PHASE_ID_UPCOMING = "upcoming"
    const val PHASE_ID_DATE_DAY = "date_day"
    const val PHASE_ID_QUIET = "quiet"

    // colorTextMuted #B4A6CE, the neutral role
    val DOT_WAITING = 0xFFB4A6CE.toInt()
    // colorMint #79E2CD, the confirmed role
    val DOT_UPCOMING = 0xFF79E2CD.toInt()
    // colorAccentPink #FF7FB6, the primary-action role
    val DOT_TODAY = 0xFFFF7FB6.toInt()
    // colorAccentPurpleDark #8E5FD6, the desaturated role
    val DOT_QUIET = 0xFF8E5FD6.toInt()

    fun dotFor(phaseId: String?): Int = when (phaseId) {
        PHASE_ID_UPCOMING -> DOT_UPCOMING
        PHASE_ID_DATE_DAY -> DOT_TODAY
        PHASE_ID_QUIET -> DOT_QUIET
        else -> DOT_WAITING
    }
}
