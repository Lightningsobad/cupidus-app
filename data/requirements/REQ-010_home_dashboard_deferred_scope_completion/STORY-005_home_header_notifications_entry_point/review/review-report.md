Outcome: DEFERRED_ONLY

# Review Report — STORY-005 Home Header Notifications Entry Point

Mode: compact-story-review
Story-Class: trivial (mobile lane)
Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-005`
BaseHead: `e8d9ade360dc29da86394423b9b5890e8cf6a690`
Worktree HEAD: `b60774f5c081120e103b5ec61eb98d292d3b61bc`
Reviewer: Iris-QC

## Scope Confirmation

`git diff e8d9ade --stat` matches the implementer's declared files-changed
exactly. Source changes are confined to three files:

- `mobile/lib/features/home/presentation/home_screen.dart` (+144 -7)
- `mobile/lib/features/account/data/notification_preferences_store.dart` (+9 -0)
- `mobile/test/features/home/presentation/home_header_notifications_test.dart` (new, 125)

The remaining diff entries are this story's own evidence artifacts
(`test-results.md`, `visual-fidelity/`) and `story_master.md`. The
`story_master.md` change is limited to adding `Design-Screen: home` and
ticking the Implementation checkbox — no acceptance criterion, scope, or
dependency line was edited. No file outside the declared write scope was
touched; `notification_settings_screen.dart` is unmodified, matching the
story's "no change to the destination screen" constraint.

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — notifications icon in the header, design position/style, dark theme + `vi` | PASS | `_NotificationsAction` rendered from the header `Row`; test case 1 pumps the dark/`vi` harness and finds the action; confirmed visually in `implemented-home-android.png` |
| AC2 — tap navigates to the existing Notifications screen, no new screen built | PASS | `_open()` pushes the already-shipped `NotificationSettingsScreen`; test case 4 asserts `findsOneWidget` on that type. No new screen or route class exists in the diff |
| AC3 — dot does not show when no unconfigured state exists | PASS | Dot is conditionally constructed (`if (unconfigured)`), i.e. omitted rather than hidden, as the UX spec required; test case 2 asserts `findsNothing`, case 3 asserts the inverse |

## UX Spec Conformance

Checked against `ux/uiux-spec.md` and the quoted `Cupid Screens.dc.html`
`goNotifs` block. Verified in source, not merely accepted from the report:

- Tap target `SizedBox(width: context.cupidPlatform.tapTarget, height: 38)` —
  uses the platform token as instructed, does not hardcode a new tap constant.
- `Stack(alignment: Alignment.centerRight)` implements the source's
  `justify-content:flex-end`; the glyph is trailing-flush, not centered, which
  the spec called out explicitly as a must-not-change.
- Glyph `CupidIcons.notifications` / `CupidIconVariant.line` / size 24 /
  `colors.colorTextMuted` matches `font-size:24px; color:var(--tx2)`.
- Dot: 8×8 `BoxShape.circle`, `Positioned(top: 4, right: 1)`,
  `colorAccentPink`, `BoxShadow(blurRadius: 9)` — matches
  `top:4px;right:1px;width:8px;height:8px;background:var(--pink);box-shadow:0 0 9px var(--pink)`.
  No animation and no numeric badge were added.
- Header becomes the two-side `space-between` layout the spec asked for, reusing
  the hero block's existing horizontal inset — no new outer padding.
- AC3 signal is a device-local read of state the Notifications feature already
  persists. `hasStoredPreferences()` reads the existing storage key; no remote
  call, no new "seen" flag, no new tracking system — the constraint the story
  and spec both drew a hard line around.
- Accessibility: `Semantics(button: true, ...)` with the unread state folded
  into the label ("Thông báo · chưa xem" / "Notifications · unread"), so the
  dot's meaning is not sighted-only.
- `goShareDays` was correctly left out (STORY-004 scope).

## Production Defect Fix — Verified Real And Scoped

The implementer reports that new test case 5 caught a runtime defect:
`setState(() => _unconfigured = widget.resolveUnconfigured())` returned a
`Future` from the `setState` callback, which Flutter asserts against. The
branch is a single squashed commit, so the pre-fix state is not in history, but
the fix is verifiable in the delivered code:

```dart
final Future<bool> refreshed = widget.resolveUnconfigured();
setState(() {
  _unconfigured = refreshed;
});
```

The resolve call is hoisted out and the callback body returns `void`. The fix is
scoped exactly to that hoist — the diff contains no other behavioural change to
the refresh path, no defensive wrapper, and no unrelated refactor. Test case 5
exercises the real store round-trip (tap → `setEnabled` → pop) and asserts the
dot clears, so the path is genuinely covered rather than asserted in prose.

## Independent Verification

Re-run in the story worktree rather than accepted from `test-results.md`:

- `flutter analyze` on the three changed files → `No issues found! (ran in 1.4s)`. Matches claim.
- `flutter test test/features/home/presentation/home_header_notifications_test.dart` → `+5: All tests passed!`. All five AC-covering cases pass.
- `flutter test test/features/home test/features/account --reporter=failures-only` → `+110: All tests passed!`. Matches the claimed count exactly; no regression in the account suite that owns the destination screen and the modified store.
- Visual evidence inspected directly: `implemented-home-android.png` is a genuine loaded Home frame (dark theme, `vi` strings, 247-day counter, populated cards) — not a splash or pre-load frame — and the outline bell with its pink indicator dot is present at the header's trailing edge. The report's own capture note discloses that an earlier capture missed the bell due to a stale APK on the device, and that the capture now reinstalls inside the device-lease window; the delivered artifact is consistent with that corrected procedure.
- Build and runtime startup smoke are accepted as reported (emulator-dependent, not reproducible in this review session). The disclosed `DioException` for `GET /users/me` is an offline-emulator artifact, unrelated to this story's surface.

## Findings (all deferred — none block DONE)

1. **DEFERRED — header label has no overflow protection, and this story narrows
   its width budget.** `_PresenceRow`'s `displayName` and `coupleTypeLabel`
   `Text` widgets have no `Flexible`/`Expanded` wrapper and no
   `overflow: TextOverflow.ellipsis`. They are now a non-flexible child of a
   `spaceBetween` `Row` that also hosts a fixed 44/48dp tap target, so the space
   available to a long Vietnamese display name shrinks by one tap target versus
   before. The missing ellipsis is pre-existing, not introduced here, and no AC
   or spec line requires it, so this is not a patch condition for STORY-005.
   It should be fixed in STORY-004, which adds `goShareDays` and narrows the
   same budget by a second tap target — that is where the risk actually
   materialises.

2. **DEFERRED — semantic label uses the file's inline `_viEn` helper rather
   than an l10n key.** The UX spec asked for the label to be added "under the
   existing home-header l10n key namespace." The implementation instead uses
   `_viEn(context, 'Thông báo', 'Notifications')`. That is the convention every
   other string in `home_screen.dart` already follows (e.g. the hero caption at
   line 389), so it satisfies the spec's "matching neighbouring header labels'
   naming convention" clause while diverging from its "l10n key" wording.
   Introducing a lone l10n key in a file that uses none would have been the
   larger inconsistency. Flagging for whoever migrates this screen to generated
   l10n; not a defect in this story.

3. **OBSERVATION — action is a direct `Row` child, not the one-child icon row
   the spec sketched.** Spec item 2 described an action-icon row with `gap: 2px`
   between icons. With only `goNotifs` shipped, a one-child `Row` and a direct
   child render identically, so nothing is wrong today. STORY-004 will need to
   introduce that wrapper `Row` with the 2px gap when it adds the share glyph.

## Residual Risks For Scrum Master

- **Merge-order coupling with STORY-004.** Both stories edit the same header
  region of `mobile/lib/features/home/presentation/home_screen.dart`. If
  STORY-004 is in flight in parallel, expect a conflict at the header `Row`.
  Merging STORY-005 to the integration branch first and rebasing STORY-004 onto
  it is the cheaper order, since STORY-004 must extend the `Row` this story
  creates.
- Build and runtime startup smoke were not independently re-executed here
  (emulator/device dependency). They are accepted on the implementer's evidence.

## Gate

Outcome: DEFERRED_ONLY
REVIEW_COMPLETE: YES
