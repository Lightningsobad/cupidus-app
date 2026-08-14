VISUAL_FIDELITY: PASS

# STORY-027 — Dream Jar visual fidelity

Round 3 changes no pixel of the captured state. Its fix (row 18) only takes
effect when the signed-in id is unresolved, and the preview entrypoint that
produced the capture passes an explicit id (`main_preview.dart:344-346`), so
`implemented-jar-emulator-5554.png` still shows the attributed comparison and
remains the correct evidence for this screen's design fidelity. The degraded
state is deliberately not a design state: it replaces the two bars with one
muted line and is pinned by test rather than by image.

Verdict restated for round 2 against the re-captured
`implemented-jar-emulator-5554.png` (taken after the A1 wiring fix and the A3
`vi` copy corrections). Every surface this story owns — header, hero card, jar
illustration, remaining pill, quick-add section, per-partner comparison card —
now matches `design-reference-jar-android.png` with no visible deviation. The
two copy strings that made round 1's `PASS` unsupportable (`Còn thiếu …` and
`Ai yêu hũ tiền hơn`) are corrected and visibly correct in the new capture. The
only differences still visible between the two images are the app-shell tab bar
and its floating action button, which belong to other REQ-002 stories and are
recorded as reviewer-deferred D3.

| Field | Value |
| --- | --- |
| Canvas screen id | `jar` |
| Platform / frame | Android 412×915 (canvas), captured 405×900 |
| Device | `emulator-5554` (sdk gphone64 arm64, API 36) |
| Theme / locale | dark / `vi` (the only enabled combination) |
| Design reference | `design-reference-jar-android.png` |
| Implemented | `implemented-jar-emulator-5554.png` |

## How the screen id was resolved

No UX phase ran (`UX Design — SKIPPED:trivial`), so no `Design-Screen:` line
was handed over. Resolved from the canvas inventory, not guessed:

- `jar` is the only id whose canvas state renders a savings-jar hero with a
  target amount, quick-add presets and a per-partner contribution comparison —
  exactly the surfaces AC3 and AC4 name.
- Ruled out `jarlist` (a list of jars, no hero/quick-add) and `jarnew` (the
  create-jar form, "Hũ mới").
- Confirmed by reading the rendered reference: it shows the header "Dream Jar",
  `3.900.000₫ / trên 5.000.000₫ · 78%`, the three `+100k/+200k/+500k` tiles and
  the "Ai thương cái hũ hơn" comparison card.

`Design-Screen: jar` is now recorded in `story_master.md`.

Both sides were used, per the reference's instruction: the `.dc.html` source
(`Cupid Screens.dc.html`, `sc-if value="{{ isJar }}"`) supplied exact
dimensions, colours and the jar SVG geometry; the rendered PNG verified the
result.

## Deviations found and corrected

| # | Surface | Design | Was | Fix |
| --- | --- | --- | --- | --- |
| 1 | Screen chrome | Pink back arrow + 21px/800/-.01em title | Header title used the default AppBar style with no back affordance styling | `design_system/adaptive/cupid_header.dart` — Material header now renders the transparent AppBar, `colorAccentPink` 26px back glyph at the platform tap target, and the Nunito 21/w800/-0.21 title |
| 2 | Hero card | `border-radius:34px`, 172° `#5E4E9E→#8A5E9E 55%→#4E8A87`, hairline `--line`, card shadow | Plain surface card, no gradient | `dream_jar_hero_card.dart` + new `design_system/tokens/dream_jar_palette.dart` |
| 3 | Hero card | Chip, jar, amount, sub-line and pill all centred | Content hugged the left edge — the `Stack` gave the padded column loose width constraints, so it shrink-wrapped to its widest child | `Stack(fit: StackFit.passthrough)` |
| 4 | Hero card | Jar SVG `viewBox 0 0 120 168` at 148×207, liquid clipped to `rect(14,46,92,108,r28)`, bow, highlight, floating hearts/bubbles | No illustration | New `dream_jar_illustration.dart` — `CustomPainter` transcription of the SVG (ADR-014a forbids adding an SVG package) |
| 5 | Hero card | Decorative `✧` at `top:14%;right:12%` (13px) and `✦` at `top:34%;left:8%` (10px) | Absent | `_HeroDecorations` |
| 6 | Hero card | Amount Nunito 900 / 32 / 1.1 with `0 3px 14px rgba(40,20,70,.3)` | 28px, no shadow | `type.display.copyWith(...)` + `DreamJarPalette.heroAmountShadow` |
| 7 | Amount format | `3.900.000₫` — no space before the symbol | `3.900.000 ₫` | `dream_jar_amount_format.dart` |
| 8 | Quick-add | Own section below the card: centred 12.5px prompt, 11px gap, 3 tiles `r22`, `padding:13px 6px`, 20px glyph, 13.5/800 label, 3rd on `--grad-hot` + glow | Presets lived inside the hero card as an untitled row | New `dream_jar_quick_add_section.dart`; the tile block was removed from the hero card |
| 9 | Quick-add | 1st glyph `--butter`, 2nd `--mint`, 3rd `volunteer_activism` white | Single colour, single glyph | Same file; `expandMore`/`favorite`/`volunteerActivism`/`flightTakeoff` codepoints added to `cupid_icons.dart` |
| 10 | Comparison card | Two bars 48×88 `r16` on `--surf2`, mono 11.5/500 amounts, 36px initial avatars with 2.5px `--surf` ring pulled up 24px, 12/700 name, 26px gutter, 12px/1.5 footer | Card rendered a plain single-total row | `partner_split_card.dart` rewritten; `PartnerSplitTotals.of()` splits by `userId` |
| 11 | Comparison card | Leading bar fills 78% of the track, the other scales off it (62% for the 0.789 ratio) | Leading bar filled 100%, leaving no visible track | `_leadFillFraction = 0.78` |
| 12 | Comparison card | Compact amounts `2,18tr` / `1,72tr` | `2.180.000₫` | `DreamJarAmountFormat.compact` |
| 13 | Data | Comparison needs per-contributor totals | The screen never loaded contributions | `DreamJarDetailCubit._loadContributions()` — best-effort, after the jar is already on screen, so a slow or failing call never delays or breaks the jar |
| 14 | Hero remaining pill | `Còn 1.100.000₫ nữa thôi` | `Còn thiếu 1.100.000₫ nữa thôi` | `app_vi.arb` `dream_jar_remaining` (round 2, A3) — visible in the refreshed capture |
| 15 | Comparison card title | `Ai thương cái hũ hơn` | `Ai yêu hũ tiền hơn` | `app_vi.arb` `dream_jar_partner_split_title` (round 2, A3) — visible in the refreshed capture |
| 16 | Jar-full pill | `Đầy rồi! Đặt vé thôi` | `Đầy rồi! Đặt vé thôi nào` | `app_vi.arb` `dream_jar_completed` (round 2, A3) — the 100% state is not the captured state, so this one is verified in the ARB source against the design string, not in the image |
| 17 | Comparison data on the real route | Split attributed to the signed-in user | `DreamJarListScreen` never passed `currentUserId`, so `PartnerSplitTotals.of` gave the whole jar to the partner in the shipped app | `dream_jar_list_screen.dart` resolves `getIt<BackendUserIdStore>().backendUserId` and passes it to both `DreamJarDetailScreen` call sites (round 2, A1), which also gives `ContributionHistoryScreen` its self id. This delivers the correct split **only while that id is populated** — it is not an unconditional fix; see row 18 |
| 18 | Comparison when the id is unresolved | Never credit one partner with the other's money | Row 17's wiring still delivered `null` on a warm restart: only an explicit sign-in calls `AuthRepository._syncBackendProfile()`, while `SessionGateCubit._resolveSignedIn` restores a persisted session straight to Home, so a returning signed-in user spent the whole session with the entire jar credited to the partner | `PartnerSplitTotals.isAttributed` (round 3, A7): a `null` id attributes nothing, and `PartnerSplitCard` renders `dream_jar_partner_split_unresolved` in place of the two bars — the `AntiGhostPendingUnknownRole` "don't guess" precedent. The card, its heading and the rest of the screen are unchanged |

## Verified matching

Layout and gutters (`padding:8px 16px 40px`, 13px inter-section gaps), hero
gradient/radius/border/shadow, jar geometry and fill level, amount and
sub-line typography, remaining pill, all three quick-add tiles, comparison
title/amounts/bars/avatars/labels/footer, safe-area handling, and the `vi`
dark-theme colour set. No clipping or overflow at 412×915.

## Deltas NOT corrected

**Round 1's three deferred `vi` copy deltas are now corrected** (rows 14-16
above). Round 2 extended the write scope to `mobile/lib/l10n/arb`, so the
deferral no longer applies and nothing in this story's own surfaces is left
uncorrected.

The one design string with no ARB key at all (`Thả một chút vào hũ nào 🫙`)
does render correctly — it uses the in-repo `chat_strings.dart` `viEn`
precedent via `dream_jar_strings.dart`.

**OUT OF SCOPE — other stories' surfaces, visible in the capture:**

- The bottom tab bar shows 3 tabs (Trang chủ / Trò chuyện / Thư viện ảnh)
  where the design has 5 (Nhà / Trò chuyện / Pet / Ví chung / Tôi), and the
  capture also carries the shell's floating action button. Both belong to the
  app shell, not to `features/dream_jar/`.
- The design's "Chi tiêu chung" expense summary row and the dashed "Tạo Dream
  Jar mới" CTA sit below the comparison card on the canvas; neither is part of
  this story's named surfaces (AC3/AC4).
- Partner display names: the canvas shows "Minh"/"Linh", but `Contribution`
  carries only `userId` with no name on this screen, so the localized role
  labels ("Bạn"/"Người ấy") and their initials are used.

## Entry Point Reachability

Reachable: YES

Path: Home → Dream Jar list → tap a jar card → Dream Jar detail.

| Step | Code |
| --- | --- |
| Home entry affordance pushes the jar list | `home_screen.dart:123` → `DreamJarListScreen` |
| Jar card tap pushes the detail screen | `dream_jar_list_screen.dart` `_JarCard.onTap` → `DreamJarDetailScreen` |
| One non-archived jar skips the list | `dream_jar_list_screen.dart` `DreamJarListReady && jars.length == 1` → `DreamJarDetailScreen` |

Both are real, visible list actions rather than a URL-only route, and this diff
does not add or move an entry point, matching AC5. Both hops are now covered by
`dream_jar_list_screen_test.dart` ("single-jar bypass …" and "jar card tap …"),
which mount the screen through its production wiring.

## How the capture was reached

Faked, not driven, per the visual-fidelity reference. `main_preview.dart`
gained a dev-only `--dart-define=PREVIEW_JAR_FIXTURE=design` fixture
repository (mirroring the existing `_PreviewLoveContractRepository`
precedent), because every contribution on the shared dev seed belongs to one
account — the comparison card would have had no partner bar to draw. Launch
and capture ran inside one `--lease-exec` window on `emulator-5554`, whose
display is already 1080×2400 @ 420dpi ≈ 411×914 dp, so no `--width` override
was needed to match the canvas frame.

## Regression guard

`test/features/dream_jar/presentation/dream_jar_design_fidelity_test.dart` —
7 tests pinning the values above (hero gradient/border/shadow/radius, hero
content centring, Nunito 32 amount, the three preset tiles and the emphasized
third, the 78% lead-bar fill, the 48×88 bar, the 8/16/40 page padding). This
repo's design-fidelity precedent asserts structural values rather than
`matchesGoldenFile` (`pet_design_fidelity_test.dart`,
`chat_design_fidelity_test.dart`); this file follows it, so it needs no
`--update-goldens` baseline and costs no image tokens to run.

Round 2 adds two tests in
`test/features/dream_jar/presentation/dream_jar_list_screen_test.dart` that
guard row 17 on both real call sites — "single-jar bypass attributes the
comparison card to the signed-in user" and "jar card tap attributes the
comparison card to the signed-in user". They mount `DreamJarListScreen` through
its production wiring with no `currentUserId` override, register the real
`BackendUserIdStore` in `getIt`, and assert `2,18tr` / `1,72tr` / "You're
460.000₫ ahead". Both were confirmed to fail (`Found 0 widgets with text
"2,18tr"`) when the fix is reverted to `currentUserId: null`.

Round 3 adds `test/features/dream_jar/presentation/partner_split_card_test.dart`
(attributed split with a known id; unattributed notice with a `null` id, which
also asserts the whole-jar `3,9tr` bar and the "partner is ahead" line are
absent) and rewrites the `PartnerSplitTotals.of` null case in
`contribution_history_cubit_test.dart`, which previously pinned the defective
behavior. Both were confirmed to fail when row 18's guard is removed.

`test/features/home/home_screen_test.dart` now registers `BackendUserIdStore`
alongside `DreamJarRepository` (A6). Round 2 added a `getIt` dependency to
`DreamJarListScreen` without it, which broke that suite; the gate command is
widened accordingly so a caller's suite cannot fail unseen again.

`flutter test test/features/dream_jar test/design_system test/features/home` →
123 passing.
`flutter analyze lib/features/dream_jar lib/design_system lib/main_preview.dart
test/features/dream_jar test/features/home` → 2 pre-existing
`prefer_initializing_formals` infos in the untouched
`contribution_history_cubit.dart`; nothing new.

Not fixed here, by review decision: the app-wide session-restore/auth-sync gap
that leaves `backendUserId` null after a warm restart (reviewer Residual Risk
R1). Row 18 is the card-level mitigation, not a cure.
`flutter build apk --debug --dart-define=PREVIEW=jar
--dart-define=PREVIEW_JAR_FIXTURE=design -t lib/main_preview.dart` → built, and
that build is what produced the refreshed capture
(`MOBILE_CAPTURE: OK … implemented-jar-emulator-5554.png 405x900 141083`).
