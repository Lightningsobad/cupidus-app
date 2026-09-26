# Review Slice S4 — phase-P5 iOS WidgetKit extension

REVIEW_SLICE_COMPLETE: YES

Slice: S4 (`review/scope-gate.md:81-87`)
Story: STORY-012_phase_status_and_widget
Review type: `scoped-slice`
Baseline: `b58afbe073eff4e1ebb9151735221532a9cf5a82`
Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`

## Verification Method

Native iOS target. **No `flutter test` applies to this slice** — it contains no
Dart file and no Dart test file, so there is no unit/widget harness to run and
no test command result is claimed. No `xcodebuild` run was performed either
(compile/sign evidence for the new extension target is not part of this pass;
see residual risk R-2). Verification is code-level reading of the 6 slice files
plus the governing contract.

Diff scope confirmed with `git diff --name-status b58afbe0 -- mobile/ios`:
3 added (`CupidPhaseWidget.swift`, `CupidPhaseWidget.entitlements`,
`CupidPhaseWidget/Info.plist`), 1 added (`Runner/Runner.entitlements`),
2 modified (`Runner.xcodeproj/project.pbxproj` +406/-11,
`Runner/AppDelegate.swift` +7). No pre-existing entitlements file was
overwritten — both `.entitlements` are new.

Governing inputs read: `requirements/requirements.md:139-158` (Nhóm C,
AC-9..AC-13), `architecture/contract-summary.md:12-69` (§1 envelope, §2
identifiers, §3 payload fields), `architecture/solution.md:147`
(`WIDGET-STALE` risk row), `story_master.md` AC-2.

## AC And Invariant Verdicts

| Id | Verdict | Evidence |
|---|---|---|
| AC-9 | PASS (native side) | `CupidPhaseWidget.swift:35-51` reads `primary_line`/`secondary_line`/`card_id` from `UserDefaults(suiteName: "group.com.snapsofts.cupid")` and `:109-115` draws them verbatim. Contract §3 puts all phase selection and formatting in Dart; native correctly has zero phase branching. The four-phase mapping itself is Dart-side (S1/S2), cross-slice. |
| AC-10 | PASS (native side) | `getTimeline` (`:81-91`) rebuilds the entry from the shared store on every reload, so a Dart-pushed phase change is picked up on the next `WidgetCenter` reload. Nothing in the extension caches or pins a phase. The reload trigger itself lives in the Dart bridge (S3), cross-slice. |
| AC-11 | PASS | The extension reads exactly three keys (`:43-49`) and renders exactly two `Text` views (`:109-114`). No journal, notebook, card-title, note, or user-typed field is read or drawn. Matches contract §2 "khoá bị cấm tuyệt đối". |
| AC-12 | PASS | No other-party field exists in the read set; there is no other-party-derived value anywhere in the file. |
| AC-13 | PASS | The widget is a separate `com.apple.product-type.app-extension` target (`project.pbxproj:200-216`), embedded by Runner's `Embed App Extensions` phase (`:42-52`, `dstSubfolderSpec = 13` = PlugIns). Nothing in the app path depends on the extension being installed by the user; absence of the widget degrades to "no widget", not to a broken app. |
| `WIDGET-STALE` | PASS (native side) | `getTimeline` returns `policy: .never` (`:85-90`), so the system never self-refreshes and no background task is introduced — exactly what `solution.md:147` prescribes. `computed_on` is never compared against the system date (contract §3 forbids that), and the extension does not attempt to compensate for stale payload. The Dart-side refresh loop assertion (`AppLifecycleState.resumed` + post-mutation) is S2/S3 evidence, not verifiable here. |
| `PhaseWidgetPublisher` / `pushWidgetPayload` | NOT IN THIS SLICE | Both are Dart symbols owned by `mobile/lib/features/phase_status/data/home_widget_bridge.dart` (slice S3). Not present in, and not expected in, any S4 file. The native contract points they must satisfy are listed under "Cross-slice obligations" below. |

## Verified Consistency Checks

1. **App Group id matches in all three places** — `CupidPhaseWidget.swift:8`
   (`appGroupId = "group.com.snapsofts.cupid"`),
   `CupidPhaseWidget/CupidPhaseWidget.entitlements:7`, and
   `Runner/Runner.entitlements:7` all carry the identical string, and it matches
   `contract-summary.md:32`. Both entitlements files are byte-identical in
   structure (single `com.apple.security.application-groups` array).
2. **Widget kind** — `CupidWidgetContract.kind = "CupidPhaseWidget"`
   (`:9`, used at `:129`) matches `contract-summary.md:33`.
3. **Deep link shape** — `:53-63` builds `cupidapp://card/<card_id>`, and falls
   back to `cupidapp://home` when `card_id` is empty. Matches
   `contract-summary.md:40` exactly, including the fallback. (But see S4-F1.)
4. **No hardcoded display copy in native widget code** (AC-37/BR-15/R-15a) —
   every string literal in `CupidPhaseWidget.swift` is a contract identifier
   (group id, kind, key names, URL scheme/host, `""`, `"/"`). No Vietnamese or
   English sentence is present. The empty-payload path renders `""`, it does not
   substitute a default sentence.
5. **`project.pbxproj` target wiring** — widget `PBXNativeTarget`
   (`:200-216`) with `productType = "com.apple.product-type.app-extension"`,
   build phases Sources/Frameworks/Resources; `CupidPhaseWidget.swift` is in the
   Sources phase (`:14`, `:387`); `CupidPhaseWidget.appex` is embedded into
   Runner with `RemoveHeadersOnCopy` (`:20`, `:48`); Runner declares a
   `PBXTargetDependency` on the widget target (`:249`, `:399-404`) so build order
   is correct.
6. **Signing/plist settings are complete across every configuration** —
   `CODE_SIGN_ENTITLEMENTS = CupidPhaseWidget/CupidPhaseWidget.entitlements` and
   `INFOPLIST_FILE = CupidPhaseWidget/Info.plist` appear on all 9 widget
   configurations, and the widget's `XCConfigurationList` (`:1538-1553`) carries
   the same 9 names as Runner's (`:1570-1585`):
   Debug/Release/Profile × plain, `-local`, `-prod`. No flavor is missing a
   widget configuration. `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`
   likewise appears on all 9 Runner configurations.
7. **Bundle identifier nesting** — `com.snapsofts.cupid.CupidPhaseWidget`
   (`:444` and the other 8 widget configs) is a strict prefix-child of the app's
   `com.snapsofts.cupid` (`:522` etc.), which iOS requires for an app extension.
   Consistent with `contract-summary.md:24-26` (one App Group, one bundle id for
   all flavors, no `applicationIdSuffix`).
8. **Deployment target** — widget configurations do not set
   `IPHONEOS_DEPLOYMENT_TARGET` and therefore inherit the project-level
   `14.0` (`project.pbxproj:498` and the sibling project configurations).
   WidgetKit requires iOS 14, so the extension is buildable at the inherited
   floor. The iOS-17-only `containerBackground` call is correctly guarded by
   `if #available(iOSApplicationExtension 17.0, *)` (`:96-101`), so no
   availability error is introduced at the 14.0 floor.
9. **Extension `Info.plist`** — `NSExtensionPointIdentifier =
   com.apple.widgetkit-extension` with no `NSExtensionPrincipalClass`, which is
   the correct shape for a SwiftUI `@main` widget (`:125-136` in the Swift file).
   Bundle keys are all `$(...)` build-setting references, none hardcoded.
10. **`AppDelegate.swift` change is unrelated to the widget** — the +7 lines are
    the P6 `UNUserNotificationCenter.current().delegate = self` setup
    (`:11-17`). The file contains **no** App Group or `WidgetCenter` code, and
    that is correct rather than a gap: the `home_widget` plugin owns the
    `UserDefaults` suite from Dart via `setAppGroupId`, so there is no native
    app-side counterpart to match. The handoff's "App Group container matches
    between `AppDelegate.swift` and `CupidPhaseWidget.swift`" check therefore
    resolves to entitlements-vs-Swift (item 1 above), which passes.

## Findings

### S4-F1 — MEDIUM — widget tap deep link has no registered URL scheme on iOS

`CupidPhaseWidget.swift:53-63` + `:120` attach
`widgetURL(cupidapp://card/<card_id>)` (or `cupidapp://home`) to the widget, and
`contract-summary.md:40` makes that deep link part of the contract. But the
`cupidapp` scheme is **not registered by the iOS app**:

- `/usr/bin/grep -n -e CFBundleURLSchemes -e cupidapp -e CFBundleURLTypes mobile/ios/Runner/Info.plist` → exit 1, no match.
- `/usr/bin/grep -n -e CFBundleURL -e INFOPLIST_KEY mobile/ios/Runner.xcodeproj/project.pbxproj` → exit 1, no match.
- `mobile/ios/Runner/Info.plist` is not in this story's diff at all
  (`git diff --name-status b58afbe0 -- mobile/ios` lists only the 6 slice files),
  so it was not registered by an earlier phase either.

Consequence: tapping the iOS widget cannot open the app through that URL, so the
widget's only interactive affordance is dead on iOS. `HomeWidget.widgetClicked`
on iOS depends on the host app receiving the custom-scheme URL. Android may be
unaffected (its intent wiring is in `AndroidManifest.xml`, slice S3) — this is an
iOS-only gap. Fix is a `CFBundleURLTypes` entry with scheme `cupidapp` in
`mobile/ios/Runner/Info.plist`.

Note on scope: the deep link is not itself an AC-9..AC-13 clause, so it does not
flip an AC verdict above; it is a contract (`contract-summary.md` §2) violation
that final synthesis should route back to the mobile lane.

### S4-F2 — MEDIUM — widget gallery entry has no display name or description

`StaticConfiguration` at `CupidPhaseWidget.swift:128-134` sets neither
`.configurationDisplayName(...)` nor `.description(...)`. WidgetKit then falls
back to the extension's bundle display name, which `Info.plist:7-8` defines as
`$(PRODUCT_NAME)` → the literal target name `CupidPhaseWidget`, with an empty
description.

AC-9 is premised on "người dùng tự thêm widget theo cơ chế của hệ điều hành":
the gallery is that mechanism's entry point, and it currently presents an
untranslated developer identifier and no explanation of what the widget shows.
This also sits awkwardly against R-15a/AC-37, which push user-visible widget copy
into the preset content packages rather than into native code or plist literals —
whichever way it is fixed, the chosen label needs a home consistent with that
rule rather than a raw `$(PRODUCT_NAME)` fallback.

### S4-F3 — LOW — empty-payload state is blank, not the specified neutral frame

`contract-summary.md:65-67` specifies that with no payload yet (fresh install, or
widget added before the first app launch) native must draw a neutral frame
**without text** — "icon + nền". `CupidPhaseEntry.blank` (`:26-33`) yields empty
strings, so `CupidPhaseWidgetView` renders two empty `Text` views inside padding:
no icon, and on iOS < 17 no explicit background either (the
`containerBackground` modifier at `:96-101` only applies from iOS 17).

The important half of that rule is satisfied — no default sentence is hardcoded,
so AC-37/BR-15 is not violated. What is missing is the positive half (icon +
background), which leaves the pre-first-launch widget visually empty rather than
deliberately neutral.

### S4-F4 — INFO — two contract keys are written but never read natively

`contract-summary.md:57-61` defines five payload keys; the extension reads three
(`primary_line`, `secondary_line`, `card_id`) and ignores `phase_id` and
`computed_on`. This is consistent with the same document's rule that native has
no branch by phase and must not compare `computed_on` to the system date, so it
is **not** a defect. Recorded only so final synthesis does not read the
three-key/five-key difference as a Dart↔native key mismatch.

## Cross-Slice Obligations (for final synthesis, not verifiable here)

These native-side constants only hold if the Dart bridge in slice S3 matches
them character for character (`contract-summary.md:20-22` warns the failure mode
is silent):

- `HomeWidget.setAppGroupId('group.com.snapsofts.cupid')` must be called before
  any save, or every `UserDefaults(suiteName:)` read here returns `nil`.
- `updateWidget(iOSName: 'CupidPhaseWidget')` must match
  `CupidWidgetContract.kind`.
- Key strings `primary_line`, `secondary_line`, `card_id` must match
  `CupidPhaseWidget.swift:10-12`.
- The `.never` timeline policy means the widget refreshes **only** when Dart
  calls `updateWidget`; the `AppLifecycleState.resumed` + post-mutation refresh
  loop required by `solution.md:147` must exist on the Dart side or
  `WIDGET-STALE` degrades from "accepted staleness" to "never updates".

## Residual Risks

- **R-1** — App Group capability provisioning. Both targets use
  `CODE_SIGN_STYLE = Automatic` with `DEVELOPMENT_TEAM = 7TG552SW73`. The App
  Group `group.com.snapsofts.cupid` must be enabled on the Apple Developer
  portal for **both** `com.snapsofts.cupid` and
  `com.snapsofts.cupid.CupidPhaseWidget`, otherwise automatic signing fails at
  build time. Not verifiable from the repository.
- **R-2** — No compile evidence. The new Swift target, the hand-written
  `project.pbxproj` additions (all object refs are non-Xcode-generated 24-hex
  ids, i.e. the project file was edited by tooling/hand, not by Xcode), and the
  entitlements wiring have not been proven to build. A single
  `xcodebuild -scheme Runner -configuration Debug-local` (or a
  `flutter build ios --config-only` + archive) on a macOS host with Xcode is the
  cheapest proof that the 406-line `project.pbxproj` edit is well-formed.
- **R-3** — iOS 17+ `containerBackground` uses `Color.clear`, so the widget has
  no opaque surface of its own on modern iOS. Combined with S4-F3 this means the
  visual treatment of the widget has not been validated against the UX spec at
  all in this slice; no visual-fidelity artifact exists for a native widget
  surface.
