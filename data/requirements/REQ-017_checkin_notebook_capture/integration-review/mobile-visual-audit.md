# REQ-017 Requirement-Level Mobile Visual Audit

Scope: F-I2 (rule 12g2) from the REQ-017 requirement integration review — a
requirement-level cross-screen visual audit on a real device, not a re-capture
of per-story visual fidelity (per-story frames already PASSED and were
deliberately not re-shot).

The audited risk is exactly the one a single story frame cannot show: REQ-017
modifies two screens that REQ-016 already shipped (`23h-vua-ve-j8` and
`2-so-tay-nguoi-yeu`) instead of adding a new screen, so the new ask block
pushes the check-in layout down and the new origin label adds a line to every
notebook item.

Branch: `codex/REQ-017_checkin_notebook_capture-integration`
Worktree HEAD audited: `cdbbb1f0e4b8aa54f8dad9d946bf6fdb1b78f98b`
Date: 2026-09-28
Design-Surface: `cupid-ch-ng-1`
Design-Screen ids: `23h-vua-ve-j8`, `2-so-tay-nguoi-yeu`

## Verdict

`MOBILE_VISUAL_AUDIT_COMPLETE: YES` — both changed screens plus one shell/nav
frame captured on a real device. No blocking defect. One advisory layout
observation (A-1 below) and one capture-method limitation (L-1) are recorded.

## Device And Build Provenance

- Device: Android emulator `emulator-5554`, already booted and provided for
  this wave. Confirmed with `adb devices` → `emulator-5554  device`. No
  device lifecycle action was taken: nothing was booted, created, wiped, or
  repaired, and no e2e automation framework was used. Screen 1080x2400.
- Installed app: `com.snapsofts.cupid`, launch activity
  `com.snapsofts.cupid_mobile.MainActivity`, local-debug flavor. The build
  already on the device is the one F-I1 installed at `c41c1556`
  (`build-runtime-evidence.md`), carried over install-over-existing-data with
  the authenticated session and the v11 Drift database intact.
- Source equivalence to the audited HEAD: `git diff --stat c41c1556..HEAD --
  mobile` returns **empty** — there is no change under `mobile/` between the
  installed build's commit and `cdbbb1f0`, so the running binary is
  source-identical to the HEAD under audit for every app-visible path.
- Independent rebuild at HEAD in this session:
  `flutter build apk --debug --split-per-abi` from `mobile/` → PASS, produced
  `app-armeabi-v7a-local-debug.apk`, `app-arm64-v8a-local-debug.apk`,
  `app-x86_64-local-debug.apk`. Only pre-existing non-fatal notices
  (restricted `java.lang.System` native-access warning; KGP notice for
  `home_widget`, `mobile_scanner`, `sign_in_with_apple`). No compile error,
  no task failure. Flutter 3.44.1 stable / Dart 3.12.1.
- Scoped test run at HEAD covering exactly the two audited screens:
  `flutter test test/features/phase_status/checkin_capture_block_test.dart
  test/features/phase_status/evening_check_in_sheet_test.dart
  test/features/context_notebook/notebook_screen_test.dart` → **All tests
  passed!** (60 passed, 2 skipped).

### How the check-in modal was reached

The modal is not reachable by ordinary in-app navigation — by design it opens
only from the 23h reminder tap (`story_master.md` `## System Integration And
Discoverability`: "không thêm điểm vào nào ... vốn chỉ tới được từ nhắc 23h").
`evening_check_in_scheduler.dart` requires `SoloPhase.dateDay`, so an activity
card scheduled for today was created **through the real app UI**, then the
reminder tap was replayed with the app's own documented intent contract read
from `flutter_local_notifications` 22.3.1
(`FlutterLocalNotificationsPlugin.java`: action `SELECT_NOTIFICATION`, extras
`payload` and `notificationId`):

```
adb -s emulator-5554 shell am start -a SELECT_NOTIFICATION \
  -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity \
  --es payload a3488849-1dfe-4851-80ac-85a8630c08ae --ei notificationId 1
```

The already-running instance received it and opened the sheet. This exercises
the shipped entry point, not a test-only shortcut, and adds no route.

## Screen 1 — Check-in modal, optional ask block (`23h-vua-ve-j8`)

- **PASS — block position (AC-1, AC-7).** The optional ask "Hôm nay biết thêm
  gì về người ấy?" with its "Tuỳ chọn" affordance renders **after** the photo
  card and **after** the journal sentence block "Một câu để giữ tối nay".
  The two STORY-012 descriptor chips keep their meaning; the ask is visually
  separated from the journal-only area, so what goes to the journal and what
  goes to the notebook stay distinguishable.
  Frame: `mobile-screenshots/23h-vua-ve-j8-capture-block-empty.png`
- **PASS — empty state (AC-2, AC-6).** The field starts empty with only its
  placeholder, no pre-fill from the journal sentence, and no suggested item.
  Same frame as above.
- **PASS — filled state with a kind chosen (AC-3, AC-17).** With text typed
  and one loại selected, exactly two mutually exclusive chips are offered
  ("Sở thích" / "Sự kiện") — no third kind, no rating field, no second
  question, and no auto-guess of the kind from the typed text.
  Frame: `mobile-screenshots/23h-vua-ve-j8-capture-block-filled.png`
- **PASS — AC-6 separation after save.** Re-opening the journal composer
  after saving shows its own empty placeholder ("Hôm nay có gì bạn muốn giữ
  lại?"); nothing typed into the notebook ask leaked into the journal.
  Frame: `mobile-screenshots/23h-vua-ve-j8-after-save-journal-composer-empty.png`
- **PASS — AC-8 one item per check-in.** Re-opening the sheet showed the ask
  block reset to empty, and the database holds exactly one `ask_on_the_spot`
  row for that check-in.
- **A-1 ADVISORY — kind chips sit under the pinned save CTA.** After typing
  into the ask, the "Sở thích" / "Sự kiện" chips are partially occluded by
  the pinned "Lưu vào nhật ký" CTA — both with the keyboard raised and
  immediately after dismissing it. A short scroll reveals and makes them fully
  tappable, so nothing is unreachable and no AC is violated. But AC-3/AC-16
  require the user to pick a kind for the idea to be written at all, so the
  affordance that gates the whole feature is the one the new block pushes
  under the CTA. This is the cross-screen layout-pressure effect F-I2 was
  raised to look for. Recorded as advisory, not blocking: behaviour is
  correct, discoverability is the concern.
  Frame: `mobile-screenshots/23h-vua-ve-j8-capture-block-kind-chips-occluded.png`

## Screen 2 — Notebook screen, origin label (`2-so-tay-nguoi-yeu`)

- **PASS — grouping and origin label (AC-4, AC-9, BR-11).** The check-in item
  renders under the existing "Sở thích" group as "Thich caphe rang moc" with a
  secondary line "từ buổi hẹn Ca phe sach Ho Tay". Directly below it sits the
  pre-existing manual item (`source = manual`) carrying **no** label —
  confirming on screen that the origin label is additive and appears only on
  check-in-sourced items. No third group appeared.
  Underlying row, read from the live database, is genuine app-written data:
  id `ed711682-8c3f-49f4-a480-90f4870d17ac`, kind `interest`,
  `source = ask_on_the_spot`,
  `origin_check_in_ref = req016.evening_check_in.a3488849-…`,
  `origin_card_title = Ca phe sach Ho Tay`.
  Frame: `mobile-screenshots/2-so-tay-nguoi-yeu-origin-label-grouped.png`
- **PASS — action parity, no new screen (AC-4, AC-5).** The "..." menu on the
  labelled check-in item offers exactly "Sửa" and "Xoá", identical to any
  other item, and edits happen in place with no new screen and no extra step.
  Frame: `mobile-screenshots/2-so-tay-nguoi-yeu-entry-actions-parity.png`
- **PASS — extra line does not break the row.** The added origin line does not
  clip, truncate mid-word, or collide with the "..." affordance, and group
  headers keep their spacing with labelled and unlabelled rows interleaved.

## Screen 3 — Shell / navigation, no new route

- **PASS — notebook reached only through the existing entry point.** The hub's
  KHO group / "Sổ tay" tab still leads to "Sổ tay người yêu"; no new tile, tab,
  or deep link was introduced for REQ-017.
  Frames: `mobile-screenshots/shell-nav-so-tay-group-entry-point.png`,
  `mobile-screenshots/shell-nav-hub-bottom-nav-no-new-route.png`
- **PASS — bottom nav unchanged.** Muốn làm / Ý tưởng / Sổ tay / Nhật ký,
  same four destinations as REQ-016 shipped, same order, same labels.
- **PASS — modal reached only from the reminder payload.** No in-app
  navigation path opens the check-in sheet; it appears only when the
  reminder-tap intent carries a card payload, matching
  `## System Integration And Discoverability` ("Direct URL: N/A").

## Limitations Disclosed

- **L-1 — user-typed test data is unaccented ASCII.** `adb shell input text`
  throws `java.lang.NullPointerException` at
  `InputShellCommand.sendText` for Vietnamese diacritics, and
  `cmd clipboard set-text` is unimplemented on this API level, so the card
  title and the notebook idea were typed as ASCII (`Ca phe sach Ho Tay`,
  `Thich caphe rang moc`). This affects **only data the tester typed**. All
  product copy under audit — "Hôm nay biết thêm gì về người ấy?", "Tuỳ chọn",
  "Sở thích", "Sự kiện", "từ buổi hẹn", "Một câu để giữ tối nay", "Sửa",
  "Xoá", and every nav label — renders from the app's own content packs with
  full diacritics in the frames, and was checked for missing-glyph boxes:
  none found.
- **L-2 — Android only.** The provided device is an Android emulator; no iOS
  simulator was provided and none was created. iOS-specific layout of the same
  two screens is not covered by this audit.

## Screenshot Index

All frames under `mobile-screenshots/`, captured with
`adb -s emulator-5554 exec-out screencap -p`, 1080x2400, unedited. Names
deliberately avoid the `implemented-` / `design-reference-` prefixes so the
per-story visual-fidelity pairing gate does not treat these cross-screen
frames as story fidelity evidence.

| File | Shows |
| --- | --- |
| `23h-vua-ve-j8-capture-block-empty.png` | ask block empty, after photo + journal sentence |
| `23h-vua-ve-j8-capture-block-filled.png` | text typed, one loại chosen, two chips only |
| `23h-vua-ve-j8-capture-block-kind-chips-occluded.png` | A-1 advisory: chips under the pinned CTA |
| `23h-vua-ve-j8-after-save-journal-composer-empty.png` | journal composer empty after save (AC-6) |
| `2-so-tay-nguoi-yeu-origin-label-grouped.png` | labelled check-in item grouped under Sở thích, unlabelled manual item below |
| `2-so-tay-nguoi-yeu-entry-actions-parity.png` | "..." menu = Sửa/Xoá only, no new screen |
| `shell-nav-so-tay-group-entry-point.png` | existing KHO / Sổ tay entry point |
| `shell-nav-hub-bottom-nav-no-new-route.png` | hub bottom nav unchanged, no new route |

## Follow-Up Recommendation

A-1 is the only item worth a decision. It is a discoverability advisory on an
AC-gating affordance, not an AC failure, so the recommendation is that Scrum
Master record it as a deferred UX observation against the check-in screen
rather than reopening STORY-001: the chips are reachable, labelled correctly,
and enforce the AC-3/AC-16 rules as specified.
