# STORY-051 UX Spec — Inverse-text/on-accent token hardening

## Token

`colorOnAccent` — new field on `CupidColorTokens`
(`mobile/lib/design_system/tokens/cupid_color_tokens.dart`), defined the same
per-theme-value way as the existing `colorText` field (constructor param,
`.dark()` initializer value, `.light()` initializer value, `final` field
declaration, plus `copyWith` and `lerp` entries — mirror every place
`colorText` currently appears in that file).

| Theme | Value | Source |
|---|---|---|
| Dark | `Color(0xFFF7EEFB)` | Identical to `CupidColorTokens.dark().colorText` — verbatim copy, not a re-derivation, so AC3 (dark-theme render unchanged) holds by construction. |
| Light | `Color(0xFFFFFFFF)` | Design source's literal `color:#fff` intent for this element. |

## Rationale

**Why the value is a duplicate field, not a re-pointed reference.** `colorText`
is the general body/label text role and must stay free to diverge from this
one gradient-CTA-styled surface in future stories. `colorOnAccent` is scoped
to "text/icon glyph rendered on top of `gradientHot`" only.

**Dark theme.** `gradientHot` (the pink→purple bubble/send-button fill both
call sites use) is declared identically in `CupidColorTokens.dark()` and
`CupidColorTokens.light()` — not theme-overridden in the design source (see
the `gradientHot` dartdoc in `cupid_color_tokens.dart`). The dark-theme value
is set to the exact existing `colorText` dark hex so the rendered dark-theme
`chat` screen is byte-for-byte unchanged (AC3): no new color, no rounding, no
reinterpretation.

**Light theme.** Per AC4, the source of truth is the design source's literal
`color:#fff` intent for the own-message bubble text and send glyph, not an
invented AA-compliant substitute — because `gradientHot` itself does not
change between themes, the same white-on-gradient treatment the design
already specifies applies unchanged in light theme too. Value-inspection
contrast check against the two `gradientHot` light-theme stops
(`colorAccentPink` `#FF7FB6`, `colorAccentPurple` `#B78CF5`, per
`CupidColorTokens.light()` — these stops are the same hex pair used in dark
theme):

- White (`#FFFFFF`) vs `#FF7FB6`: ~2.34:1
- White (`#FFFFFF`) vs `#B78CF5`: ~2.60:1

For comparison, the **already-shipped, already-accepted** dark-theme
`colorText` (`#F7EEFB`) on this same identical gradient measures ~2.07:1 and
~2.30:1 against the same two stops. The light-theme `colorOnAccent` value is
therefore at least as good as — modestly better than — the contrast level
this exact surface already ships with today. Neither figure clears general
WCAG AA body-text (4.5:1) or large-text/UI-component (3:1) thresholds; this
mirrors the precedent already set by ADR-004b/ADR-004c in this same file,
which knowingly carries forward specific brand/gradient/CTA-context values
that don't clear AA rather than inventing a non-source color. `_bubbleFontSize`
(15.5, weight 400) does not qualify as WCAG "large text," and the send glyph
(`_sendIconSize` 19) is a decorative branded icon on the same CTA-style fill,
not general UI chrome — both are the same class of exception ADR-004b already
carves out for accent colors used on large/decorative/branded elements. No
UI/UX judgment call beyond "match the design source's literal `#fff` value on
an unchanged background" was required.

## Call sites (Mobile Developer implements, not this spec)

1. `mobile/lib/features/chat/presentation/widgets/message_bubble.dart:99` —
   own-message bubble `Text` `style.color`, currently `colors.colorText`.
   Background at this call site: `colors.gradientHot` (line 87, applied only
   when `isMine`). Replace with `colors.colorOnAccent`.
2. `mobile/lib/features/chat/presentation/widgets/chat_composer.dart:310` —
   send button `Icon.color`, currently `colors.colorText` (only in the
   `enabled` branch; the disabled branch's `colors.colorTextMuted` is
   out of scope and must not change). Background at this call site:
   `colors.gradientHot` (line 293, applied only when `enabled`). Replace the
   `enabled` branch value with `colors.colorOnAccent`.

## Out of scope (unchanged from story_master.md)

No other token, call site, or screen. No light-theme/`en` locale enablement
(OQ5). No dark-theme visual change — `colorOnAccent`'s dark value is a
verbatim copy of `colorText`'s dark value for this exact reason.
