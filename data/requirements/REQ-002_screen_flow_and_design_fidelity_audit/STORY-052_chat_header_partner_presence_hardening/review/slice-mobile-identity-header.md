# STORY-052 Review Slice — Mobile Identity / Header / Presence (AC2–AC7)

Reviewer: Iris-QC · Mode: `scoped-slice` · Date: 2026-08-18
Slice 2 of 2. Slice 1 (`slice-backend-contract.md`, AC1) is PASS and is **not**
re-reviewed here.

This slice does **not** decide the story-level `Outcome`. That is the
final-synthesis reviewer's call.

## 1. Slice Scope

Diff range actually reviewed:

```
git diff 25b92d884c555124e87ff7f1cd7d1cf3eb641c6b..212e50c4bdeb63808f647480bd70684c446db150 -- mobile/
```

11 files, +808 / −93. Confirmed from the diff (not from the handoff list):

| File | Role |
| --- | --- |
| `mobile/lib/features/chat/data/chat_partner_store.dart` | identity split (`data/`, not `domain/`) |
| `mobile/lib/design_system/adaptive/cupid_header.dart` | `trailing` + `titleSemanticLabel` slots |
| `mobile/lib/design_system/tokens/partner_chip_palette.dart` | NEW gradient token |
| `mobile/lib/design_system/design_system.dart` | barrel export |
| `mobile/lib/features/chat/presentation/widgets/partner_presence_chip.dart` | NEW chip |
| `mobile/lib/features/chat/presentation/chat_strings.dart` | pairing/chip strings |
| `mobile/lib/features/chat/presentation/screens/chat_screen.dart` | header composition |
| `mobile/lib/main_preview.dart` | preview fixture split |
| `mobile/test/design_system/adaptive_widgets_test.dart` | +7 slot tests |
| `mobile/test/features/chat/data/chat_repository_test.dart` | +store split tests |
| `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart` | +8 header/chip tests |

Evidence read: `coding-plan/test-results.md` §P1/§P2 (reused per the
evidence-reuse rule; spot-checked against the actual test sources, see §4),
`visual-fidelity/visual-fidelity-report.md` + **both PNGs opened**,
`ux/uiux-spec.md` §1.3/§1.4/§2/§3/§4 and §"Finding",
`data/devops/system/runtime-command-registry.json` (`mobile-app`),
`mobile/lib/core/navigation/app_shell.dart` (entry point, verified in code).

Touched risk surfaces: mobile interaction, mobile navigation/discoverability,
shared design-system component contract, app lifecycle (launch), accessibility.

## 2. Verification Table

| AC | Verdict | Basis |
| --- | --- | --- |
| AC2 — header shows `<self> ↔ <partner>`, both from real backend data, not the caller twice | **PASS** (see F3 on the `↔` glyph) | `chat_screen.dart:174-178` composes `ChatStrings.headerPairingTitle`; `chat_partner_store.dart:46-53` maps `body['displayName']`→`selfDisplayName` and `body['partnerDisplayName']`→`partnerDisplayName` as two distinct fields. Asserted `find.text('Minh ↔ Linh')` via `_NamedPartnerStore` supplying the halves independently, so a wrong-getter wiring cannot pass. |
| AC3 — presence chip top-right: partner initial, online dot, `đang online` | **PASS** | `partner_presence_chip.dart:36-156`. Chip is `CupidHeader.trailing`, i.e. right-aligned on both branches. Initial uppercased from the **partner** name (`_avatarInitial`, matching the `home_screen.dart:381-383` precedent UX §1.4 cites); asserted `find.text('L')` + `find.text('M') findsNothing` with `self:'minh', partner:'linh'`. Geometry (pill `fromLTRB(6,5,10,5)`, gap 7, avatar 24, dot 8 at `right/bottom: -1`, radius 999) asserted and independently confirmed by pixel measurement in the fidelity report. Dot rings in `colorSurface` (UX §1.4's explicit trap), asserted positively **and** negatively against `colorBackground`. |
| AC4 — chip announces one coherent label; title semantics drops the `↔` glyph | **PASS** | `Semantics(container: true, label: '<partner> đang online')` wrapping `ExcludeSemantics`; asserted `chip.label == 'Linh đang online'`, `chip.childrenCount == 0`, `hasAction(tap) isFalse` (UX §4: status, not a control). Title: `titleSemanticLabel` → `Text(title, semanticsLabel:)`; asserted `getSemantics(find.text('Minh ↔ Linh')).label == 'Minh và Linh'`, localized `và`/`and`. |
| AC5 — the other 16 `CupidHeader` consumers render unchanged | **PASS** | Consumer count verified independently: 17 `CupidHeader(` sites in `mobile/lib`, one of which is the declaration and one of which is `chat_screen.dart` → exactly 16 others, all on the title-only path. Material proof is **tree identity**, not structural equality: `expect(appBar.actions, same(actions))` — the `trailing == null` ternary returns the caller's own list instance. iOS proof: header `Row` contains no `SizedBox` at all when unset. `titleSemanticLabel` asserted `isNull` on both platforms. |
| AC6 — `title`/`onBack`/`backLabel`/`actions` unchanged; new params optional with safe default | **PASS** | Both new params are `Widget?`/`String?` with no default value assigned, null-guarded at every use; existing four params untouched in signature and behavior. Both platform branches wired (a single-branch wiring would have shipped a platform-only feature); the `CupidPlatform.values` loop test covers both and is non-vacuous (`populatedWidth < unsetWidth`). |
| AC7 — reached through the existing navigation path, no new entry point | **PASS in code / FAIL on required evidence section** | Verified in code, not on trust: `app_shell.dart:126-127` declares a bottom-nav tab `Trò chuyện`/`Chat` (`Icons.chat_bubble_outline`) and `app_shell.dart:137-146` mounts `ChatScreen` at that index behind `chat_entry_gate`. Discoverable nav item, not direct-URL-only; the implemented capture shows that tab bar with `Trò chuyện` active. The diff changes nothing about reachability. **But** `coding-plan/test-results.md` carries no `## Entry Point Reachability` section with `Reachable: YES` — see F1. |
| Mobile design fidelity (rule 12e3) | **PASS with a disclosed visible delta** | Both PNGs opened. Implemented capture shows **this story's** chat screen in the built app — header `Minh ↔ Linh`, chip with `L` avatar + green dot + `đang online` — not a placeholder, spinner, error frame, or wrong screen. Reference depicts the same chat screen of the design. `VISUAL_FIDELITY: PASS` is backed by a real per-metric comparison naming screen, device and states, not a bare token. The `↔` delta is real and visible — see F3. |
| Runtime startup smoke (rule 12g) | **FAIL on evidence** | See F2. |

## 3. Blocking Findings

### F1 — `## Entry Point Reachability` section absent from `test-results.md`

Rule 12e1 makes this section mandatory and non-waivable for a UI-facing story.
`coding-plan/test-results.md` has no `## Entry Point Reachability` and no
`Reachable: YES` line (grepped for `Entry Point|Reachable`, no match).

Severity is documentation-only: I verified the entry point independently and it
is genuinely reachable and discoverable. The remedy is mechanical — record the
section with the already-true path:

```
## Entry Point Reachability
Reachable: YES
Path: AppShell bottom-nav tab "Trò chuyện" (mobile/lib/core/navigation/app_shell.dart:126-127)
      -> ChatScreen mounted at app_shell.dart:137-146 behind chat_entry_gate.
Unchanged by this story (AC7).
```

Owner: `mobile-dev`.

### F2 — no `## Story Runtime Startup Smoke` evidence, and no recorded waiver

Rule 12g makes registry-backed runtime startup smoke a mandatory story-level
gate for a non-trivial `mobile` story — the app must LAUNCH on the provided
device/emulator and reach its first screen without a crash or error screen —
unless `story_master.md` records `Runtime-Smoke: WAIVED — <reason>`.

- `story_master.md` has no `Runtime-Smoke:` line (grepped, no match).
- `test-results.md` has no smoke section (grepped `smoke|launch|boot`, only a
  cross-reference at line 244).
- `visual-fidelity-report.md` §7 asserts `Runtime startup smoke: —
  NOT_APPLICABLE per data/devops/system/runtime-command-registry.json
  (mobile-app)`. **The registry does not say that.** Its `mobile-app` entry
  (lines 89–153) documents a real launch path — `scripts/run-mobile.sh`,
  `"interactive": true, "ciSafe": false`, bounded device-boot timeouts and typed
  blockers. "The interactive launch path is not CI-safe" is a different claim
  from "the startup smoke does not apply", and there is no
  `startupSmoke`/`NOT_APPLICABLE` key anywhere in the registry.

Strong mitigation, which the synthesis reviewer should weigh: the visual-fidelity
capture demonstrably built a debug APK, `adb install`-ed it, launched it on
`emulator-5560` and reached the chat screen — and I have looked at the resulting
frame, which is a correctly rendered screen, not a crash or red error screen. So
the app does boot. The gap is that it was built from `-t lib/main_preview.dart`,
so production `main()` initialization is not exercised — which is precisely the
failure mode rule 12g was written for (the Firebase-init red-screen incident
named in the rule).

Remedy, either: (a) launch the ordinary `lib/main.dart` debug build on
`emulator-5560` and record a `## Story Runtime Startup Smoke` section, or
(b) record an explicit `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`
if Scrum Master judges the preview-build launch sufficient. Owner: `mobile-dev`
(a) or `scrum-master` (b).

## 4. Non-Blocking / Disclosed Items

### F3 — D-1, `↔` renders as a colour emoji tile on Android (**visually confirmed**)

Per the handoff this is OUT OF SCOPE for STORY-052 and routed to UI/UX Designer
plus Tech Lead, so I do not raise it as a blocking finding. Recording it as a
known/disclosed item, with one observation the synthesis reviewer needs:

I opened both images and the delta is real and clearly visible. The reference
renders a thin monochrome white `↔` between `Minh` and `Linh`; the implemented
capture renders a filled teal/blue rounded emoji tile in that position. It is
not subtle, and it sits inside AC2's own surface — the header pairing title.

This creates a genuine tension the synthesis pass must dispose of explicitly:
rule 12e2 states any visible discrepancy, however small, is `FAIL` with the
delta recorded, yet `visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS`
while documenting this exact deviation as OPEN in the same file (§4, D-1). The
mobile-dev's handling is otherwise exemplary — root cause identified (U+2194 has
an emoji presentation default), the U+FE0E fix attempted, proven ineffective,
**fully reverted**, and all gates re-run against the delivered source, with a
dartdoc on `ChatStrings.headerPairingTitle` so the next reader does not repeat
the failed experiment. The remaining fixes (declare a text-presentation font on
the header title style, or change the separator glyph) both require touching the
title style block that `ux/uiux-spec.md` §1.2 explicitly fences off from this
story.

I flag it, I do not decide it. `DEFERRED_ONLY` looks defensible given the
documented out-of-scope routing; that judgment is the synthesis reviewer's.

### N1 — D-2 (`M` vs `L` initial) is correctly dispositioned, verified

The reference PNG shows `M`, the implementation shows `L`. I checked this against
`ux/uiux-spec.md` §"Finding" (lines 17–37): the design source's chip is
partner-scoped (`partnerInitial: this.mine ? 'L' : 'M'`), and the reference's
`M` is an artifact of the demo toggle's value at render time. The implementation
is spec-correct. Not a defect, and the report's disposition stands.

### N2 — `Design-Screen: <id>` not recorded as a field

The resolved screen appears only inside the render command (`--screen=chat`) in
`visual-fidelity-report.md`, not as a `Design-Screen:` field in
`story_master.md`. The substantive risk rule 12e2 warns about (a confident PASS
against the wrong screen) does not apply here — I opened the reference and it is
unambiguously the chat screen. Traceability nit only.

### N3 — `ExcludeSemantics` scope is wider than UX §4's literal wording

UX §4 says to exclude "the decorative avatar-initial glyph and dot"; the
implementation wraps the whole chip body including the visible `đang online`
text, with an in-code rationale (leaving the status text in the tree would make
assistive tech read the status twice). AC4's exact text — "announces one
coherent label" — is met, and `chip.childrenCount == 0` proves it. No action.

### N4 — end-to-end real-data path is covered link-by-link, not as one run

AC2 requires both names sourced from real backend data. Each link is covered:
backend `partnerDisplayName` (slice 1, PASS) → `refreshFromServer` key mapping
(`chat_repository_test.dart`, incl. missing-key and null cases, plus a
source-text guard that no compatibility `displayName` alias was re-added) →
screen composition (widget tests). The device capture necessarily uses the
`_PreviewChatPartnerStore` fixture because it is a preview build; that does not
weaken AC2, since the production path is the one under unit test. Noting it so
the synthesis pass is not surprised by the fixture in the capture.

## 5. Spot-Checks Performed on Reused Evidence

Per the evidence-reuse rule I did not rerun `flutter test`/`analyze`/`build`, but
I read the actual test sources against the claims rather than trusting §P1/§P2:

- The Material tree-identity assertion is literally `same(actions)` as claimed —
  an identity check a rebuilt-but-equal list would not satisfy. Confirmed.
- The non-vacuity guard is real: `populatedWidth < unsetWidth` across
  `CupidPlatform.values`. Confirmed.
- The partner-identity assertion is non-vacuous: `self:'minh'` / `partner:'linh'`
  differ, and `find.text('M')` is `findsNothing`. Confirmed.
- Degradation cases exist and assert `findsNothing` for both `↔` and the string
  `null`. Confirmed.
- Call-site sweep (rule 12d): no residual `ChatPartnerStore.displayName` reader
  survives the split anywhere in `mobile/lib`; the remaining `.displayName` hits
  are all on the unrelated `CupidProfile` type. `main_preview.dart:745-752`
  carries `@override` on both new fields. Confirmed.
- ADR-004 / no-fork: the new gradient lives in `design_system/tokens/` with a
  documented justification for why no existing token matched, and the barrel
  export (D-5) is the one line needed to make it reachable. Confirmed.

## 6. Traceability

| Input | Coverage |
| --- | --- |
| `story_master.md` AC2–AC7 | all six verified above; AC7 passes in code, fails on the required evidence section (F1) |
| `ux/uiux-spec.md` §1.3 (10dp gap) | `_trailingGap = 10` in `cupid_header.dart`, asserted on both branches |
| `ux/uiux-spec.md` §1.4 (chip geometry, dot ring trap) | implemented, asserted positively and negatively, pixel-measured |
| `ux/uiux-spec.md` §2 (unset state, no dead space) | tree-identity + no-`SizedBox` assertions |
| `ux/uiux-spec.md` §3 (title yields width) | `Expanded` + ellipsis retained; yield asserted |
| `ux/uiux-spec.md` §4 (accessibility) | title label + single chip label + no `button` role; see N3 |
| `architecture/contract-summary.md` §6 (no compatibility alias) | source-text guard test present and passing |
| `coding-plan/test-results.md` §P1/§P2 | reused, spot-checked (§5) |
| `visual-fidelity/` | both PNGs opened; verdict backed by a real comparison |

## 7. Recommendation (slice-level input only)

The AC2–AC7 implementation is correct, well-tested, and traceable; I found no
correctness, regression, security, or maintainability defect in the delivered
mobile code. Every substantive acceptance criterion in this slice passes on the
code itself.

The two blocking items (F1, F2) are both **missing required evidence sections**,
not broken behavior — F1's fact is already true in code and F2's app-boots claim
is already de-facto demonstrated by the capture, just from the preview
entrypoint. If the synthesis reviewer accepts both as evidence gaps, the natural
disposition is `PATCH_REQUIRED` scoped to `mobile-dev` recording two sections
(plus a Scrum Master decision on the F2 waiver), with no code change required.

F3 (the `↔` emoji tile) is the one genuine judgment call and is deliberately
left open for the synthesis pass.

REVIEW_SLICE_COMPLETE: YES
