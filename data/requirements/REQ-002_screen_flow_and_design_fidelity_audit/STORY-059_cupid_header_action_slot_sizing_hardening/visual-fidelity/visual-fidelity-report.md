# Visual Fidelity Report: STORY-059 CupidHeader Action-Slot FAB Sizing Hardening

VISUAL_FIDELITY: PASS

Scope of that token, stated plainly so it is not over-read: **the surface this
story changes — the `jarlist` header action slot — matches the design in both
AC1-bearing states, on device.** The earlier
`MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` blocker is resolved: both states now
render from a real build on `emulator-5560` under the Scrum-Master-authorized
`PREVIEW_JARLIST_FIXTURE` extension.

This screen also carries several design deviations that are **not** in this
story's scope and that this story neither introduced nor could have introduced.
They are itemized in full below rather than omitted, and none of them is a
header-action deviation. No story currently owns them — see the recommendation
at the end.

Design-Screen: `jarlist` — resolved from
`node .ai-team-bundle/runtime/tools/render-design-canvas.js --list-screens`
against the configured entry (`Cupid App.dc.html`), where `jarlist` is a listed
id. Confirmed by looking at the render, not by name match: it draws the jar
collection, the create-jar CTA, and the shared bottom tab bar on the "Ví chung"
tab — the screen `dream_jar_list_screen.dart` implements.

## Evidence

| File | What it is |
|---|---|
| `design-reference-jarlist-android.png` | Rendered design reference, Android frame, dark + `vi`, 406x900 |
| `design-reference-jarlist-ready-emulator-5560.png` | Same render, paired to the ready capture |
| `design-reference-jarlist-empty-emulator-5560.png` | Same render, paired to the empty capture |
| `implemented-jarlist-ready-emulator-5560.png` | `DreamJarListReady`, `emulator-5560`, 405x900 |
| `implemented-jarlist-empty-emulator-5560.png` | `DreamJarListEmpty`, `emulator-5560`, 405x900 |
| `implemented-jarlist-emulator-5560.png` | `DreamJarListFailed`, retained from the first pass as supplementary evidence |

All paths are relative to this file's directory. The three design-reference
files are the same render: the design canvas has exactly one `jarlist` screen,
and it depicts the populated state. Consequences of that are recorded honestly
under "Empty state" below rather than papered over by the file naming.

### Capture setup

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --out=<this directory> --screen=jarlist --platform=android --theme=dark --lang=vi

cd mobile && flutter build apk --debug --target-platform=android-arm64 \
  -t lib/main_preview.dart --dart-define=PREVIEW=jarlist \
  --dart-define=PREVIEW_JARLIST_FIXTURE=empty      # then again with =ready

.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --lease-exec \
  --device=emulator-5560 -- bash -c '<install; force-stop; cold launch; nested capture>'
```

`emulator-5560` was already running and was reused. No device was created,
booted, wiped, or repaired; the temporary `--width=405 --density=160` is
reverted by the capture script on exit. Theme and locale are the app's shipped
dark + `vi` configuration, not overridden. Both captures come from post-fix
builds of this worktree.

One capture note: at `--settle-ms=8000` the first attempt captured the Flutter
splash screen, not the app. The state is faked, not driven, but a cold debug
build still needs time to reach first frame; 20-25 s produced the real screen.
Recorded because a splash capture is exactly the kind of artifact that can be
mistaken for a rendered screen.

## AC1 verdict — the surface this story changes

| | Design reference | Implemented (both states) | Verdict |
|---|---|---|---|
| Header right side | Nothing — no icon, no action slot, no FAB | Nothing | **MATCH** |

`DreamJarListEmpty` renders the jar glyph, "Bắt đầu để dành cho một điều gì đó
cùng nhau" and the gradient CTA pill under a header carrying title only.
`DreamJarListReady` renders the three jar cards and the CTA pill under the same
bare header. Neither shows a header add action; both retain the body CTA. That
is AC1 in both states, on device, against the design.

The pink rounded square at the bottom right of both captures is the `AppShell`
account-hub FAB, not a `CupidAddAction` — the same control STORY-055's reviewer
flagged as easy to misread on this exact screen. It is unrelated to this story
and is part of the shell, not the header.

## What is NOT visually evidenced here

The `hasOversizedAction: true` path (AC2) has **no consumer in the app** after
this story: the Dream Jar list was the only `CupidHeader.actions` call site with
an oversized action, and it no longer has one. So the 60pt band is not
exercisable on device and is not in either capture. It is covered by widget test
only — `adaptive_widgets_test.dart`, `expect(size, const Size(60, 60))`. Stating
it rather than letting the PASS token imply an on-device 60x60 render that does
not exist.

## Empty state — comparison limit

The design canvas has no empty-state `jarlist` screen. For
`implemented-jarlist-empty-emulator-5560.png` the header contract is therefore
compared against the design's header (valid — the header is state-independent in
the design), and the body is **not** compared, because there is nothing to
compare it against. The empty-state body is not claimed to match the design and
was not audited here.

## Out-of-scope deviations observed (pre-existing, not introduced by this story)

Recorded because they are visible in the captures and a reader deserves to see
them named, not because this story owns them. This story's entire production
diff is: a new opt-in parameter on `CupidHeader` and the removal of the Dream
Jar header `actions` list. Nothing in that diff can affect any row below.

| # | Design reference | Implemented | Note |
|---|---|---|---|
| 1 | Title "Các hũ ước mơ" | "Hũ Ước Mơ" | Copy mismatch |
| 2 | Pink back chevron | No back affordance | Screen is a shell tab root at runtime, not a pushed route |
| 3 | Summary pill "Tổng cả nhà đang để dành 7.150.000₫ trong 3 cái hũ" | Absent | Whole element unimplemented |
| 4 | Jar illustration thumbnail per card | Absent | |
| 5 | Per-jar leading glyph next to the name | Absent | |
| 6 | Deadline date per card (30/09/2026 etc.) | Absent | Data exists in the model; not rendered |
| 7 | "Đang xem" badge + pink border/tint on the active card | Absent | |
| 8 | "3.900.000₫ / 5.000.000₫", percent on its own row | "3.900.000₫ trên 5.000.000₫ · 78%" | Format and layout differ |
| 9 | CTA "+ Tạo hũ mới" with leading plus | "Tạo Dream Jar mới", no glyph | Copy + missing glyph; English noun in a `vi` build |
| 10 | "Hũ đã hoàn thành" completed-jars row | Absent | Whole element unimplemented |
| 11 | 5 tabs (Nhà / Trò chuyện / Pet / Ví chung / Tôi), "Ví chung" active | 3 tabs (Trang chủ / Trò chuyện / Thư viện ảnh) + separate account FAB | Shell-level; already recorded in STORY-055's report |

Rows 1 and 9 are copy defects a reader will notice immediately; rows 3, 6, 7 and
10 are unimplemented design elements, not styling drift. **Recommendation for
Scrum Master:** these are real REQ-002-class findings on an audited screen and
no open story covers them. They warrant a new RWB item (UI/UX Designer + Product
Owner scoping) rather than being absorbed silently into this story's PASS.

## Authorized write-scope extension

`mobile/lib/main_preview.dart` was edited under the explicit Scrum Master
authorization of 2026-08-19, which named it as the exact unblock. Added:
`PREVIEW_JARLIST_FIXTURE=empty|ready` and `_PreviewDreamJarListRepository`,
overriding `fetchJars` only, mirroring the existing
`PREVIEW_EXPENSE_FIXTURE` / `PREVIEW_JAR_FIXTURE` / `_PreviewDreamJarRepository`
pattern in that same file. Precedent: STORY-020 `architecture/solution.md` §7,
"Authorized Write-Scope Extension — Preview Harness". Omitting the define leaves
the live-repository path byte-for-byte unchanged.

The ready fixture uses **three** jars carrying the design source's own names and
amounts (Du lịch Đà Lạt 3.9tr/5tr, Nhẫn đôi 2.4tr/8tr, Dọn về ở chung
850k/30tr). Three rather than two for two reasons: it matches the design's jar
set so the comparison is like-for-like, and any count above one avoids the
single-non-archived-jar bypass at `dream_jar_list_screen.dart:59`, which would
otherwise swap this screen for the detail screen and capture the wrong widget
entirely. The rendered percentages (78% / 30% / 3%) match the design reference
exactly, which is independent confirmation the fixture is wired correctly.

No file outside `main_preview.dart` was touched for this extension.

VISUAL_FIDELITY: PASS
