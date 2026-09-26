package com.snapsofts.cupid

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.net.Uri
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.RelativeSizeSpan
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
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

            // B-2: set unconditionally, both phases of the table. A launcher
            // reapplies onto the view it already inflated, so skipping the flat
            // case would leave the date_day gradient on the next phase.
            views.setInt(
                R.id.cupid_phase_widget_root,
                METHOD_SET_BACKGROUND_RESOURCE,
                CupidWidgetPalette.backgroundFor(phaseId),
            )

            views.setTextViewText(R.id.cupid_phase_widget_eyebrow, eyebrow ?: EMPTY)
            views.setTextColor(R.id.cupid_phase_widget_eyebrow, dotColor)
            views.setImageViewBitmap(
                R.id.cupid_phase_widget_dot,
                if (phaseId == CupidWidgetPalette.PHASE_ID_DATE_DAY) {
                    boltBitmap(context, dotColor)
                } else {
                    dotBitmap(dotColor)
                },
            )
            views.setViewVisibility(
                R.id.cupid_phase_widget_eyebrow_row,
                if (hasEyebrow) View.VISIBLE else View.GONE,
            )

            views.setTextViewText(
                R.id.cupid_phase_widget_primary,
                displaySizedNumeral(primary ?: EMPTY, CupidWidgetPalette.numeralFor(phaseId)),
            )
            views.setViewVisibility(
                R.id.cupid_phase_widget_primary,
                if (hasPrimary) View.VISIBLE else View.GONE,
            )

            views.setTextViewText(R.id.cupid_phase_widget_secondary, secondary ?: EMPTY)
            // Pushed for the same reason as the background: the muted token the
            // layout carries is unreadable once this phase draws its gradient,
            // and iOS already switches here (`secondaryColor`, B-2 parity).
            views.setTextColor(
                R.id.cupid_phase_widget_secondary,
                CupidWidgetPalette.secondaryFor(phaseId),
            )
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

    // B-5 (architecture/contract-summary.md 3c): the first run of digits in the
    // payload line is drawn at display size, the same rule CupidPhaseSplit
    // applies on iOS - "has a digit cluster", never a branch on phase_id. Not a
    // character is dropped, reordered or rewritten: this re-sizes a substring of
    // the payload, so it adds no payload key and no content item.
    //
    // One TextView with spans rather than three views, so the line breaks where
    // iOS breaks it. RelativeSizeSpan and ForegroundColorSpan are both
    // ParcelableSpan and survive the RemoteViews trip; a size ratio rather than
    // an absolute dp so the numeral inherits the user's font scale.
    private fun displaySizedNumeral(line: String, numeralColor: Int): CharSequence {
        val start = line.indexOfFirst(Char::isDigit)
        if (start < 0) {
            return line
        }
        var stop = start
        while (stop < line.length && line[stop].isDigit()) {
            stop++
        }
        return SpannableString(line).apply {
            setSpan(
                RelativeSizeSpan(DISPLAY_SIZE_RATIO),
                start,
                stop,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
            )
            setSpan(
                ForegroundColorSpan(numeralColor),
                start,
                stop,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
            )
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

    // D-13: the date_day role keeps its token colour but changes shape. The app
    // rasterises the vector in its own process and ships a Bitmap, so this does
    // not depend on the launcher supporting VectorDrawable inside RemoteViews.
    private fun boltBitmap(context: Context, color: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(GLYPH_PX, GLYPH_PX, Bitmap.Config.ARGB_8888)
        val glyph = ContextCompat.getDrawable(context, R.drawable.dot_today_bolt)!!.mutate()
        glyph.setTint(color)
        glyph.setBounds(0, 0, GLYPH_PX, GLYPH_PX)
        glyph.draw(Canvas(bitmap))
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

        // View.setBackgroundResource, reached by name because RemoteViews has no
        // typed setter for it. A @RemotableViewMethod identifier, not copy.
        const val METHOD_SET_BACKGROUND_RESOURCE = "setBackgroundResource"

        // 34sp over the 14sp cupid_phase_widget_primary carries in the layout,
        // matching the 34 iOS uses. A ratio, so the body size stays defined in
        // exactly one place and the numeral scales with the rest of the layout.
        const val DISPLAY_SIZE_RATIO = 34f / 14f

        const val EMPTY = ""
        const val CIRCLE_PX = 24

        // Rasterised larger than the 8dp cell so the glyph edges stay clean;
        // the three circle roles keep CIRCLE_PX unchanged.
        const val GLYPH_PX = 48
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

    // colorText #F7EEFB, body copy on a flat surface
    val TEXT = 0xFFF7EEFB.toInt()
    // colorOnAccent #F7EEFB, the glyph-on-gradientHot role. Declared in its own
    // right rather than aliased onto TEXT: the two happen to share a value in
    // the dark theme, and the role is what the contract fixes (3a, B-6).
    val ON_ACCENT = 0xFFF7EEFB.toInt()
    // colorAccentPink #FF7FB6
    val ACCENT_PINK = 0xFFFF7FB6.toInt()

    // colorTextMuted #B4A6CE, the neutral role
    val TEXT_MUTED = 0xFFB4A6CE.toInt()
    // colorText at 85%, the supporting-copy role on the gradient. The alpha is
    // the token iOS applies to the same line, carried here as one value because
    // RemoteViews has no opacity call of its own.
    val TEXT_ON_GRADIENT = 0xD9F7EEFB.toInt()

    val DOT_WAITING = TEXT_MUTED
    // colorMint #79E2CD, the confirmed role
    val DOT_UPCOMING = 0xFF79E2CD.toInt()
    // B-6: the primary-action role now resolves to the on-accent token, because
    // the bolt sits on the gradientHot background B-2 gives this phase and the
    // pink it used to carry had no contrast against its own backdrop.
    val DOT_TODAY = ON_ACCENT
    // colorAccentPurpleDark #8E5FD6, the desaturated role
    val DOT_QUIET = 0xFF8E5FD6.toInt()

    fun dotFor(phaseId: String?): Int = when (phaseId) {
        PHASE_ID_UPCOMING -> DOT_UPCOMING
        PHASE_ID_DATE_DAY -> DOT_TODAY
        PHASE_ID_QUIET -> DOT_QUIET
        else -> DOT_WAITING
    }

    // B-2 (contract-summary.md 3b): two rows, looked up from phase_id exactly
    // like the dot role. No third background and no launcher default.
    fun backgroundFor(phaseId: String?): Int = when (phaseId) {
        PHASE_ID_DATE_DAY -> R.drawable.widget_bg_phase_date_day
        else -> R.drawable.widget_bg_phase_flat
    }

    // B-5 (contract-summary.md 3c): the digit cluster's colour, matching what
    // iOS already ships - text on the gradient, accent pink on the flat surface.
    fun numeralFor(phaseId: String?): Int = when (phaseId) {
        PHASE_ID_DATE_DAY -> TEXT
        else -> ACCENT_PINK
    }

    fun secondaryFor(phaseId: String?): Int = when (phaseId) {
        PHASE_ID_DATE_DAY -> TEXT_ON_GRADIENT
        else -> TEXT_MUTED
    }
}
