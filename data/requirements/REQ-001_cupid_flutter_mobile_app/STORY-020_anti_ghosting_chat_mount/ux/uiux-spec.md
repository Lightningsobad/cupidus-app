# UX Spec: STORY-020 — Anti-Ghosting Chat Mount (placement confirmation)

Scope note: this is a RED-PATCH mount-placement confirmation, not a component
design. `GhostStateRow(partnerId:)` was already fully specified and built in
STORY-008; this spec only pins **where** it mounts inside STORY-007's
`ChatScreen` and what must hold true at that seam. No new anti-ghosting UI is
introduced here.

## 1. Placement Decision — confirmed from prior record, not newly invented

An explicit prior placement record exists in **three** independent STORY-008
artifacts, and all three agree. This spec adopts it unchanged:

1. `STORY-008_anti_ghosting/ux/uiux-spec.md` §2.4 (the AC2 gate section):
   reuse the design source's `showSeenRow`/`stormReady` inline row as the AC2
   surfacing point — it "already lives inside the chat screen the story asks
   for, requires no new chat-screen real estate, and is visually distinct from
   the Typing-Ghost bubble (STORY-007 scope) **it sits below** in the mockup."
2. `STORY-008_anti_ghosting/coding-plan/phase-P3-chat-ghost-state-row.md` §3:
   "STORY-007 mounts it with one line **below the message list and above the
   composer**."
3. The shipped widget's own doc comment
   (`mobile/lib/features/anti_ghosting/presentation/widgets/ghost_state_row.dart:11-18`):
   "place exactly one `GhostStateRow(partnerId: partner.id)` below the chat
   message list and above the composer, below the Typing-Ghost bubble."

**Confirmed mount point:** inside `_ChatViewState.build`'s `Column`
(`mobile/lib/features/chat/presentation/screens/chat_screen.dart`), as a new
child inserted **after** the `GhostBubble` `BlocBuilder` and **before** the
`ChatComposer` `BlocBuilder`. Current child order at that seam is:

```
_DegradedBanner (conditional)
_PrivacyChip
_OlderPageSpinner (conditional)
Expanded( message list / empty state )
BlocBuilder<GhostCubit> -> GhostBubble          (Typing-Ghost bubble)
>>> GhostStateRow(partnerId: ...)  <<<          (this story's mount)
BlocBuilder<GhostCubit> -> ChatComposer         (must stay last)
```

Rationale for that exact slot rather than the app bar or a top banner:

- It matches the design source's own `showSeenRow` position (inline, at the
  bottom of the thread), so the signal reads as "about the conversation you are
  looking at right now," not as a global chrome-level alert.
- The composer must remain the bottom-most element (one-thumb principle,
  `data/ux/system/ui_ux_system_memory.md` §2/§3) — the row goes above it, never
  between the composer and the screen edge.
- Sitting below `GhostBubble` keeps the two amber/ephemeral signals in a stable
  reading order (partner's live draft first, then the seen/no-reply state), and
  avoids the row shifting position as the Typing-Ghost bubble appears and
  disappears.
- `CupidHeader`'s frozen contract exposes a title string only, with no slot for
  a status row (`chat_screen.dart:138-141`) — an app-bar placement would
  require reopening a shared design-system component, which STORY-020
  explicitly excludes.

## 2. Behavior At The Seam (no new component behavior)

All render/branching/live-region behavior stays exactly as STORY-008 built it
(five render cases, penalty-branched CTA, CTA suppressed for `none`/no active
config, one-shot live-region announcement). The only mount-level requirements:

- **Zero-height when idle.** The row already returns `SizedBox.shrink()` when
  the storm status is not `eligible`, so it must be mounted unconditionally in
  the `Column` (not inside an `if`-on-state wrapper the chat screen invents) —
  it costs no layout when there is no signal, and the surrounding `Column`
  needs no spacing/divider added for it. Do not wrap it in extra `Padding`; the
  widget owns its own `CupidSpacing.md`/`sm` insets.
- **Pairing gate (STORY-008 UX §1, AC3) is already satisfied at this seam.**
  `ChatScreen` is only reachable through `ChatEntryGate`, which unlocks solely
  on `ChatPartnerStore.partnerId != null`. The `partnerId` the row needs is
  therefore already in hand at the mount point — pass
  `ChatPartnerStore.partnerId`. If it is somehow null, render nothing (no
  placeholder, no empty state, no error copy); an unpaired user must see no
  trace of anti-ghosting in chat.
- **No configuration entry point is added inside chat** (STORY-008 UX §2.4,
  unchanged): configuration stays on the Home dashboard card. Do not add a
  chat app-bar action, overflow item, or tap-through from this row to the
  anti-ghosting settings screen.
- **No change to any other chat surface.** Message list, typing indicator,
  privacy chip, degraded banner, and composer keep their current position,
  spacing, and behavior.

## 3. Accessibility At The Seam

- Traversal order follows the visual order above: message list → Typing-Ghost
  bubble → ghost-state row → composer. This puts the "seen, no reply" signal
  and its CTA immediately before the text input, so a screen-reader user
  reaches the state explaining the silence right before deciding what to type.
  Do not reorder for visual convenience.
- The row's live-region announcement is owned by the widget itself
  (`ghost_state_row.dart:138-141`). The chat screen must not add a second
  announcement for the same state change — `ChatScreen`'s existing
  `BlocListener` announcement stays scoped to ghost on/off consent
  transitions only.
- Nothing at this seam may rely on colour alone; already satisfied by the
  widget's icon + text pairing, which must not be stripped or restyled when
  mounted.

## 4. Verification Expectation (AC1)

Placement is verified when, for a paired user in the running app with an
eligible storm status, the amber "Seen, no reply" line renders between the
Typing-Ghost bubble area and the composer — and when no such state exists, the
chat screen's layout is pixel-identical to its pre-mount state.

## 5. Open Items For Downstream Roles

1. **[Mobile Developer] `partnerId` plumbing only.** `ChatScreen` holds
   `partnerStore` and already has `partnerStore.partnerId` available, but the
   inner `_ChatView` currently receives `partnerDisplayName` only. Threading
   `partnerId` through is mechanical wiring, not a design decision — no UX
   sign-off needed.
2. **[Flag only, out of STORY-020 scope] CTA pill is currently
   non-interactive.** `GhostStateRow`'s storm/noise pill renders as a
   `Container` with no gesture handler (`ghost_state_row.dart:142-163`), so it
   presently reads as a status affordance rather than an actionable CTA.
   STORY-008 UX §2.4 described it as a CTA. This is a pre-existing STORY-008
   widget-internal gap, explicitly out of this story's scope (which forbids
   changing `GhostStateRow`'s implementation) — raising it for backlog
   consideration, **not** as work to pick up here.
