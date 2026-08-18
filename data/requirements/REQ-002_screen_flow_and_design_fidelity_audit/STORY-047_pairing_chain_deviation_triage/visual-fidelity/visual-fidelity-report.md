# Visual Fidelity Report — STORY-047 Pairing Chain Deviation Triage

VISUAL_FIDELITY: PASS

Scope: `profile` (AC1) and `joincode` (AC3, AC4, AC5) only. `permissions` (AC2)
was descoped on 2026-08-18 into
`data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/req_master.md`
and is deliberately **not** captured here — see `story_master.md`
`## Blocker (2026-08-18)`.

All PNGs below were rendered fresh for this story. STORY-009/010/012's existing
PNG pairs were **not** reused: `story_master.md` §"Product Owner Triage"
records STORY-010's and STORY-009's on-disk references as stale and
non-representative of the current locked source.

## Capture Configuration

The audited configuration is the only one asserted: Android, dark theme, `vi`
locale.

| Setting | Value |
| --- | --- |
| Design source | `cupid-app-design-system/project/Cupid App.dc.html` (locked, `ui_surface: true`) |
| Reference tool | `.ai-team-bundle/runtime/tools/render-design-canvas.js --platform=android --theme=dark --lang=vi` |
| Implementation tool | `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh` |
| Preview entrypoint | `mobile/lib/main_preview.dart` via `cupidpreview://screen/<id>` |
| Device | `emulator-5560`, `--width=540 --density=240 --max-edge=900` |

## Evidence

| Screen / state | Implemented | Design reference |
| --- | --- | --- |
| `profile` | `implemented-profile-emulator-5560.png` | `design-reference-profile-android.png` |
| `joincode` (canonical pair) | `implemented-joincode-emulator-5560.png` | `design-reference-joincode-android.png` |
| `joincode` empty | `implemented-joincode-empty-emulator-5560.png` | shares `design-reference-joincode-android.png` |
| `joincode` partial | `implemented-joincode-partial-emulator-5560.png` | shares `design-reference-joincode-android.png` |
| `joincode` active | `implemented-joincode-active-emulator-5560.png` | shares `design-reference-joincode-android.png` |
| `joincode` error | `implemented-joincode-error-emulator-5560.png` | shares `design-reference-joincode-android.png` |

The canvas renders exactly one frame per screen id, so only one
`design-reference-joincode-*.png` is producible. AC3's four states are captured
against that single reference; the canonical pair uses the partial state
because that is the state the canvas frame itself draws.

Preview seeds used (state is faked, never driven):
`--dart-define=PREVIEW_PROFILE=fixture`, `PREVIEW_JOINCODE_CODE=""|3F9|3F9A2B`,
`PREVIEW_JOINCODE_STATE=error`.

## Per-AC Verification

**AC1 — `profile` continue CTA.** Implemented capture reads
`Tiếp tục → Ghép đôi`, matching the reference exactly. `onPressed` still routes
to `pairingChoice` (behavior untouched; asserted in
`onboarding_profile_setup_screen_test.dart` and `auth_leg_edges_test.dart`).

**AC3 — six segmented slots.** Every state matches the design's per-slot
treatment: `colorSurface` fill, `colorLine` idle border at 1.5px,
`radiusSmall` corners, Roboto Mono 21px/500.

- empty: six idle slots, pink caret in slot 1.
- partial (`3F9`): slot 3 carries the `colorAccentPink` border + `glowShadow`;
  slot 4 carries the caret.
- active (`3F9A2B`): slot 6 carries the active treatment, no caret.
- error: all six borders `colorRed`, glow suppressed, inline
  `Mã không đúng hoặc đã hết hạn` rendered below the row.

The control remains a single accessible field (uiux-spec §9) — the slots are an
`ExcludeSemantics`/`IgnorePointer` overlay above one `TextField`, so
paste-fills-multiple-slots, backspace-across-slots, the `errorText` association,
and the `JoincodeCubit` `submit`/`isBusy` flow are unchanged.

**AC4 — `Dán`.** Present in every joincode capture with the design's pill
styling (48px tall, `radiusButton`, 1.5px `colorLine` border, clipboard glyph).

**AC5 — cross-link.** `Tôi mới là người tạo mã →` present in every joincode
capture, `colorAccentPink` 13px/700, matching the reference's placement below
the CTA.

## Deviations

Every difference below is pre-adjudicated or explicitly out of this story's
scope. None is newly introduced by this story.

1. **No titled app-bar chrome** on `profile` and `joincode`, where the
   references draw a titled header (`Hồ sơ của bạn`, `Nhập mã ghép đôi`).
   Approved deviation governed by `ux/uiux-spec.md` Chrome Rules;
   `story_master.md` Background item 1 says explicitly "do not reopen".
2. **`joincode` reference says `8 ký tự` and draws 5 boxes plus a dash
   separator; the implementation ships 6 slots and `6 ký tự`.** This is the
   design source contradicting itself, adjudicated in `story_master.md` §3a as
   an ACCEPTED DIFFERENCE with no code change: backend
   (`invitations.service.ts:36`, `randomBytes(3)` → 6 hex chars) and every
   mobile surface already agree at 6. AC3 mandates 6 slots. The reference's
   dash separator is likewise part of that partially-drawn mockup and is not
   reproduced.
3. **`Quét QR` absent**, so `Dán` renders full-width rather than sharing the
   row. `story_master.md` §3d keeps QR scanning OUT OF SCOPE — it needs a new
   camera/QR package, `pubspec.yaml` changes, and platform camera-permission
   manifest entries, none of which exist in this app.
4. **`profile` avatar** is the app's filled person glyph, not the reference's
   dashed `Ảnh đại diện` ring. `story_master.md` §1a: ACCEPTED DIFFERENCE,
   already disclosed and reasoned in STORY-010's own report — the dashed ring
   is Claude Design's authoring-tool image-slot chrome, not product UI.
5. **`profile` zodiac helper wraps to two lines** at this capture width where
   the reference fits one. Cosmetic, caused by the 540px capture width; the
   11.5px size is asserted in `onboarding_profile_setup_screen_test.dart` and
   is unchanged by this story.

## Verification Commands

Run in this session, both passing:

- `flutter test` → `+1284 ~2: All other tests passed!` (0 failures)
- `flutter analyze lib test` → 80 issues, all `info`, identical to the
  pre-existing baseline, none from new code
