# REQ-016 Cross-Story Mobile Visual Audit

Scope: closes `review-report.md` F-I2 action item 6 (`mobile-visual-audit.md`
for cross-screen navigation / shell / consistency).

Branch: `codex/REQ-016_solo_stage1_relationship_assistant-integration`
HEAD audited: `0a8f421410e964ffec81033a7213adff35281858` (BaseHead == worktree
HEAD; `0a8f4214` is docs-only on top of `753d2a86`, the HEAD DevOps built and
installed per `build-runtime-evidence.md`, so the on-device binary is this code)
Date: 2026-09-26

## What this audit is, and is not

This walks the merged app as one whole, looking for seams **between** stories.
It deliberately does **not** re-check any single story's own already-passed
`visual-fidelity/` gate, and does not re-run any story's coding-plan phase test
scope. Everything below is a property of the merge, not of one story's diff.

## Capture method

Priority 1 (real device instance) was attempted and is only partially usable.
The merged debug APK is installed and launches (`build-runtime-evidence.md`),
but on cold launch it resolves to `PairGateShell`'s `_NetworkErrorView`: the app
targets `http://localhost:3000` and no backend listens there (and from inside
the guest, `localhost` is the guest itself — reaching the host would need
`10.0.2.2` or an `adb reverse`). `logcat` shows a `/users/me` call, so a session
token already exists; the failure is transport, not auth. Starting the backend
API or rewiring the host mapping is DevOps scope and explicitly forbidden to
mobile-dev, so the device path yielded one capture (seam 0) and the remaining
seams used the sanctioned fallback.

Priority 2 (RepaintBoundary widget-test capture) supplied seams A–C, following
the in-repo precedent `mobile/test/features/reminders/visual_capture_support.dart`
(`kAndroidReferenceViewport = 412x915`, off-disk `FontLoader`, no
`pumpAndSettle`). Each capture mounts the real production widget tree under the
real `CupidAppBackground` `MaterialApp.builder` layer, at `locale: vi`, with the
shipped design fonts plus the framework `MaterialIcons` font loaded.

No PASS below is written from static reading alone: every PNG listed was opened
and looked at.

## Seam results

| # | Seam | Capture | Result |
|---|------|---------|--------|
| 0 | Cold launch on a real device instance | device screencap | NOTE — reaches `_NetworkErrorView`, no local backend; not a merge defect |
| A | Solo stage-1 shell, all four tabs | widget-test PNG | PASS (re-captured at `893c3649` after the F-M1 fix; `Ý tưởng` placeholder is spec per OQ-1) |
| B | Hub → Gợi ý quà → Chân dung → back → Bảng tra ăn khớp | widget-test PNG | PASS |
| C | Me hub → Nhật ký riêng / Sổ tay người yêu / Những gì bạn giỏi | widget-test PNG | PASS |
| D | Android permission declarations and prompts | manifest + call-site read | PASS with NOTE |

### Seam 0 — cold launch (device)

Looked at: the first frame the merged binary shows on a real device instance.
Captured: `screencap` after `am start -W` (`Status: ok`).
Result: **NOTE.** The app renders `PairGateShell`'s `_NetworkErrorView`
(`pair_gate_shell.dart:84-97`). This is the correct shell branch for an
unreachable backend, not a broken screen and not a cross-story seam. Recorded so
the reviewer knows why the remaining seams are widget-test captures.

### Seam A — solo stage-1 shell, four tabs

Looked at: whether the four tabs of the solo surface feel like one app — same
shell chrome, persistent tab bar, no orphaned route, no visual break when
switching between tabs owned by different stories.
Captured: `seamA1`–`seamA4`, pumping the real `PairGateShell` with an unpaired
`PartnerLink` (the REQ-016 premise) and tapping each tab in the real tab bar.
Result on shell/consistency: **PASS.** The bottom tab bar persists across all
four tabs, the active-tab tint and icon treatment are consistent, the background
layer is continuous, and Vietnamese diacritics render correctly throughout
(`Muốn làm`, `Ý tưởng`, `Sổ tay`, `Nhật ký` — no tofu, no clipping). No orphaned
or dead-end route: every tab is reachable and returns.
Result on content: **PASS.** Re-captured 2026-09-27 at merged HEAD `893c3649`,
after the F-M1 fix (`3b51172f`) landed; `seamA1`–`seamA4` below are the post-fix
PNGs and were opened and looked at, not inferred from a green test run.

- `Sổ tay` (`seamA3`) renders the `_SoloDestinationBlock` of
  `fm1-solo-tabs-solution.md` §2/§5.4: a small muted caption header `Sổ tay`
  over one surface card holding exactly two rows — `Sổ tay người yêu`
  (lilac `menuBook` badge) and `Những gì bạn giỏi` (butter `checklist` badge) —
  each with a trailing chevron and a single hairline divider between them.
- `Nhật ký` (`seamA4`) renders the same block with its one row,
  `Nhật ký riêng` (mint `lock` badge) and a chevron, correctly with no divider.
- Both blocks are visually identical in badge size/tint, radius, row height,
  type scale, and chevron treatment to the `_PrivateStorageBlock` already
  captured as PASS in `seamC1` — the shape the solution doc required. Nothing
  heavier appears: no counts, no content preview, no large card, no floating
  CTA, and no activity card (`Đi biển` asserted `findsNothing` on every
  non-`Muốn làm` tab, preserving AC-21/SC-1').
- No layout overflow, clipping, or text truncation at 412x915; all Vietnamese
  diacritics render correctly (`Sổ tay người yêu`, `Những gì bạn giỏi`,
  `Nhật ký riêng`) with no tofu.
- `Ý tưởng` (`seamA2`) still renders `'Ý tưởng — sắp có'`. That is the
  specified outcome, not a residual defect: it is the neutral placeholder
  `ux/uiux-spec.md` §6 prescribes for an entry point whose owning story has not
  shipped, deliberately left in place by `fm1-solo-tabs-solution.md` §2/§6 and
  tracked for PO as non-blocking OQ-1.

The F-M1 section below is kept as the historical finding record; this seam no
longer fails.

### Seam B — cross-story push chain and back-stack

Looked at: a screen from one story pushed from inside another story's screen —
does the pushed route keep the app's chrome, does the tab bar correctly *not*
leak into it, and does back return to the originating story rather than the hub.
Captured: `seamB1` (hub tile → `Gợi ý quà`, STORY-001 → STORY-004), `seamB1b`
(the two keyed cross-story entry rows, `gift_ideas_screen.dart:183-207`),
`seamB2` (→ `Chân dung tưởng tượng`, STORY-009), `seamB3` (back), `seamB4`
(→ `Bảng tra ăn khớp`, STORY-010).
Result: **PASS.**
- Each pushed route carries its own app bar with a working back affordance, and
  the solo tab bar is correctly absent from pushed routes
  (`solo_stage_one_tab_bar` asserted `findsNothing`).
- Back from the portrait returns to `Gợi ý quà`, not to the hub — the AC-4
  contract in `your_view_portrait_entry_point.dart:24-27` holds at merged HEAD.
- Visual continuity holds across the three stories' screens: same background,
  same card radius/elevation, same type scale, diacritics intact.

Two things looked like defects and are not; both were run down rather than
reported:

- `Bảng tra ăn khớp` first captured with a completely empty body. That is the
  deliberate `state.loading → SizedBox.shrink()` at
  `compatibility_lookup_screen.dart:66-73` (AC-28: no "đang tra cứu" spinner).
  Draining real async (bundled pack read + drift) shows the screen populating
  normally — `progress=0 listTiles=1 texts=48`. Harness artifact, not a defect.
  It is still worth knowing that a real user sees a blank body for the duration
  of that asset read; flagged as NOTE-1.
- The provenance banner's leading icon on `Chân dung tưởng tượng` first rendered
  as an empty square. `your_view_portrait_screen.dart:89` uses
  `Icons.info_outline`, which lives in the framework `MaterialIcons` font, not a
  repo asset — the capture harness had not loaded it. With that font loaded the
  icon renders correctly. Harness artifact, not a tofu defect.

### Seam C — where the private-storage screens actually live

Looked at: whether `JournalScreen`, `NotebookScreen`, and `SkillProfileScreen`
render correctly when reached through their real production entry point, to
establish that F-M1 is a reachability seam and not three broken screens.
Captured: `seamC1` (the `Tôi` hub's private-storage block), `seamC2`
(`Nhật ký riêng`), `seamC3` + `seamC3b` (`Sổ tay người yêu`), `seamC4`
(`Những gì bạn giỏi`), each pushed from the real `_MenuRow` taps at
`me_screen.dart:560/568/577`.
Result: **PASS.** All three render correctly with app bar, back affordance,
correct empty states (`Chỉ mình bạn đọc được ở đây.` + `Viết điều gì đó`), and
correct group headers and add affordances. Back returns to the hub each time.

One apparent rendering anomaly was investigated and dismissed: in `seamC3` the
first group's `+ tự thêm` label looked malformed. Zoomed pixel inspection
(`zoom-c3-addrows.png`, `zoom-c3b-addrows.png`) plus a control capture reached
without the preceding push (`seamC3b`) shows a `_CupidSkyStars` particle sitting
in the transparent gap between the `+` and the text. The particle's colour
differs between runs because the sky animates, and screen bodies are
intentionally transparent over the background layer
(`cupid_app_background.dart:96-108`, `widget.child` last in the `Stack`).
Cosmetic, by design, not a defect.

### Seam D — Android permissions

Looked at: duplicate or conflicting permission declarations, and whether two
stories can prompt for the same OS permission.
Read: `mobile/android/app/src/main/AndroidManifest.xml` and every runtime
request call site at merged HEAD.
Result: **PASS with NOTE.** Three runtime permissions are declared, each once,
each with an attributed comment and no duplication or conflict:
`READ_MEDIA_IMAGES` (STORY-013 P3), `POST_NOTIFICATIONS`, `CAMERA` (STORY-003
P1, with `android.hardware.camera` correctly `required="false"`). The debug and
profile manifests add only `INTERNET`.

NOTE-2: on Android 13+, two independent code paths request the *same*
`POST_NOTIFICATIONS` permission — `in_app_notification_manager.dart:46-54`
(FCM, fired from the constructor of the lazy singleton at
`service_locator.dart:145`) and `evening_check_in_scheduler.dart:90` (REQ-016).
This is not a duplicate *dialog*: the REQ-016 request is deliberately deferred
(date-day only, enabled only, at most once per card — see the comment at
`evening_check_in_scheduler.dart:87-89`), and the OS shows its dialog once. The
consequence worth recording is that if the user denied at FCM init, the REQ-016
evening check-in silently receives `granted=false`, writes `markReminded`, and
the feature is off with no user-visible explanation. The onboarding permissions
screen is **not** a third requester — `permissions_screen.dart:55-61` only
mutates a local `Set` and fires no OS request.

## F-M1 — solo stage-1 tabs are dead ends while their screens ship behind the paired-only hub

Severity: requirement-level integration gap. Needs a Scrum Master / PO decision;
it is **not** a regression in any single story and must not be routed as one.

What is true at merged HEAD, each verified in code and visible in the captures:

1. The solo shell's four-tab bar renders `Muốn làm`, `Ý tưởng`, `Sổ tay`,
   `Nhật ký`. Only `Muốn làm` has content; the other three render
   `'<label> — sắp có'` (`home_screen.dart:281`, `:323-332`, `:364-370`).
   Captured: `seamA2`, `seamA3`, `seamA4`.
2. `JournalScreen`, `NotebookScreen`, and `SkillProfileScreen` are fully built
   and render correctly (seam C).
3. Their only production entry points are `me_screen.dart:560`, `:568`, `:577`.
4. `MeScreen` is mounted in exactly one place, `app_shell.dart:182`, as the
   `Tôi` tab.
5. `AppShell` is constructed only on the `PairGatePaired()` branch of
   `pair_gate_shell.dart`; the unpaired branch resolves to `HomeScreen` with
   `_soloPairingStatus` pinned.

Therefore, in a solo / unpaired stage-1 session — REQ-016's own premise — the
`Sổ tay` and `Nhật ký` screens the requirement scopes as `màn 2`/`màn 4`
(`req_master.md:131-132`) are unreachable, while the tabs named for them sit in
the shell showing `sắp có`. `Hồ sơ kỹ năng` (`màn 3`) is likewise solo-unreachable.

This contradicts decision D-3 (`req_master.md:155`, 2026-09-07), which resolved
the STORY-001 canvas-vs-AC conflict in favour of the canvas and patched AC-22
and UX §1 to *require* the four-tab bar **and its routes** for the solo stage-1
surface. The tab bar shipped; the routes behind three of its tabs did not.

Why no single-story gate could catch it: STORY-001 legitimately shipped
placeholders and pins them green in its own passing test
(`activity_card_hub_view_test.dart:820-907`, which asserts the three tabs *are*
placeholders); STORY-003 and STORY-004 legitimately shipped working screens with
a working `MeScreen` entry and their own passing fidelity gates. Each story is
internally correct. The gap exists only in the composition, which is precisely
what this requirement-level audit is for.

Suggested routing (Scrum Master / PO to decide, not mobile-dev): either wire the
three solo tabs to the shipped screens, or record an explicit PO deferral that
supersedes D-3's "and its routes" clause for stage 1. Both are scope decisions
outside this audit's mandate.

## Notes carried forward

- NOTE-1: `Bảng tra ăn khớp` shows a fully blank body while its packs load, by
  AC-28 design (no spinner). Confirmed the load completes. Worth a PO glance at
  whether the blank window is acceptable on a cold, slow read.
- NOTE-2: see seam D — a denial at FCM init silently disables the REQ-016
  evening check-in with no explanation surface.

## Evidence inventory

Screenshots were written **outside** the repository, to `/tmp/req016-visual-audit/`,
because this handoff narrows WriteScope to this single markdown file. Scrum
Master: if these should be committed as requirement evidence, a WriteScope
extension is required — mobile-dev did not write them into the repo.

```
/tmp/req016-visual-audit/seam00-cold-launch-device.png
/tmp/req016-visual-audit/seamA1-solo-shell-muonlam.png
/tmp/req016-visual-audit/seamA2-solo-tab-yTuong.png
/tmp/req016-visual-audit/seamA3-solo-tab-soTay.png
/tmp/req016-visual-audit/seamA4-solo-tab-nhatKy.png
/tmp/req016-visual-audit/seamB1-giftideas-from-hub.png
/tmp/req016-visual-audit/seamB1b-giftideas-entry-rows.png
/tmp/req016-visual-audit/seamB2-portrait-from-giftideas.png
/tmp/req016-visual-audit/seamB3-back-to-giftideas.png
/tmp/req016-visual-audit/seamB4-compatibility-from-giftideas.png
/tmp/req016-visual-audit/seamC1-me-hub-private-storage.png
/tmp/req016-visual-audit/seamC2-journal-from-me-hub.png
/tmp/req016-visual-audit/seamC3-notebook-from-me-hub.png
/tmp/req016-visual-audit/seamC3b-notebook-standalone.png
/tmp/req016-visual-audit/seamC4-skill-profile-from-me-hub.png
/tmp/req016-visual-audit/zoom-c3-addrows.png
/tmp/req016-visual-audit/zoom-c3b-addrows.png
/tmp/req016-visual-audit/logcat.txt
```

The three capture suites are scratch harnesses, also kept outside the repo so
no story's test scope is modified:

```
/tmp/req016-visual-audit/solo_shell_seam_capture_test.dart
/tmp/req016-visual-audit/cross_story_push_capture_test.dart
/tmp/req016-visual-audit/me_hub_destinations_capture_test.dart
```

## Verification run in this session

All from `mobile/` on this worktree, `flutter` on PATH from
`/Users/alantravala/flutter/bin`:

```
flutter test --no-pub /tmp/req016-visual-audit/solo_shell_seam_capture_test.dart
  -> 00:01 +1: All tests passed!

flutter test --no-pub /tmp/req016-visual-audit/cross_story_push_capture_test.dart
  -> 00:04 +1: All tests passed!    (COMPAT_DIAG progress=0 listTiles=1 texts=48 state=PRESENT)

flutter test --no-pub /tmp/req016-visual-audit/me_hub_destinations_capture_test.dart
  -> 00:01 +2: All tests passed!
```

`flutter analyze` is not cited as gate evidence here: its baseline on this repo
is non-zero (pre-existing warnings, zero errors), so it cannot distinguish a
regression.

Worktree left clean apart from this file; nothing committed.
