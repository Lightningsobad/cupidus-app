# 001_design_system-solution.md

## 0. Metadata

- User Story ID: REQ-001 / STORY-001_design_system
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/story_master.md`
- Complexity: L (shared-foundation, Depends-On NONE)
- Referenced Inputs: `story_master.md`; `ux/uiux-spec.md` (S1, S5, S6, S7, S8 by anchor); `req_master.md` (D3 row, foundation note, R7); `requirements/requirements.md` (OQ5); `system_architecture_memory.md` (ADR-004, ADR-005, ADR-009); `mobile/pubspec.yaml`
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md`
- Solution Number: 001
- Version: v1.0
- Date: 2026-07-29
- Status: Final

## 1. Decision Summary

- Mode: Greenfield (design-system layer is net-new inside the existing bare `flutter create` scaffold at `mobile/`)
- Branch Action: Research Architecture
- Architecture Drivers: R7 (retrofitting tokens later touches all 31 screens), D3/ADR-004 (one widget tree), OQ5 (build 4 combos, expose 1), ADR-009 (`mobile/`, package `cupid_mobile`, feature-first).
- Invariants: platform axis and theme axis stay orthogonal and composable; platform branching exists in exactly four adaptive widgets; feature code never reads a raw color/radius/size literal; light theme and `en` always compile and are always constructible in tests regardless of enablement flags.
- Non-goals: screen implementation, ARB string extraction, remote/runtime-served flags, melos split, Cupertino widget tree.
- Technical direction: three composed `ThemeExtension`s (platform, color, typography) plus a const spacing class, one `MaterialApp`, a const build-time `CupidFeatureFlags` façade gating **exposure** only, and `flutter_localizations` + `gen-l10n` ARB codegen for `vi`/`en`.
- Fit: matches ADR-004/ADR-005 exactly and adds no dependency beyond `flutter_localizations` + `intl`.

## 2. Downstream Contract Summary

- Backend contract: none. STORY-001 has no network surface.
- Frontend contract: N/A (no web lane).
- Mobile contract (authoritative for every later REQ-001 story):
  - Single import surface `package:cupid_mobile/design_system/design_system.dart`. Feature code imports nothing else from `design_system/`.
  - Token access only via `BuildContext` extensions: `context.cupidColors`, `context.cupidPlatform`, `context.cupidType`, plus const `CupidSpacing.*`.
  - Platform variance is consumed only through `CupidTabBar`, `CupidHeader`, `CupidPrimaryButton`, `CupidAddAction`. Screens must not branch on `Platform.is*` / `defaultTargetPlatform`.
  - Strings come only from `AppL10n.of(context)`; new keys are added to **both** `app_vi.arb` and `app_en.arb` in the same change.
- DevOps / environment contract: `--dart-define` keys `CUPID_ENABLE_LIGHT_THEME`, `CUPID_ENABLE_EN_LOCALE` (default `false`). Release/store builds pass neither. Fonts are bundled assets — no runtime font download. Runtime registry id `mobile-app` must exist for startup smoke (absent today per system memory §8).
- Requirement configuration guide impact: REQUIRED — the two `--dart-define` keys and the font-asset/`--no-tree-shake-icons` build note must be recorded in `deployment/configuration-guide.md`.
- Data model / migration contract: none.
- API / event / worker queue contract: none.
- Test and verification expectations: `flutter analyze` clean; `flutter test` green including the four guard tests in §4 Risk Surfaces; mobile visual audit limited to the v1-exposed combination (dark + `vi`).
- OQ constraints downstream must preserve: OQ5 — light theme and `en` stay built, tested and switchable in code; they must never become user-selectable in v1 settings UI.

## 3. Scope And Assumptions

- In Scope: token classes for 4 combinations, theme assembly, platform resolution + test override, the 4 adaptive widget contracts, icon family + variant tokens, enablement flags, ARB pipeline wiring, guard tests.
- Out Of Scope: any screen, any ARB copy beyond a smoke key set, settings UI (a later story consumes the flags), dark/light user toggle UX.
- Assumptions: (a) SF Pro cannot be bundled (Apple licence), so iOS-style typography is verified on iOS targets only; (b) Nunito / Roboto / Roboto Mono / Material Symbols Rounded are redistributable (SIL OFL / Apache-2.0) and ship as repo assets; (c) `cupid-mobile-design/` stays read-only reference.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ5 | RESOLVED (PO) | Exposing light theme or `en` in user-facing settings at v1 | Building, theming and testing all 4 platform x theme combos and both locales | Const build-time `CupidFeatureFlags` gates exposure, not existence (§4 ADR-004a) |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/design_system/` (new), plus `mobile/lib/core/config/`, `mobile/lib/l10n/`, `mobile/lib/app/`.
- New boundary: `design_system` is a leaf layer — it may not import `features/` or `core/network`. `core/config/cupid_feature_flags.dart` is also leaf; `app/cupid_app.dart` is the only place that composes flags + theme + localization.
- Contract owner: Tech Lead for this file; Mobile Developer owns implementation and may not change the public names in §2 without a new architecture pass.

### Affected Components And Layers

- Mobile:
  - `design_system/tokens/cupid_platform_tokens.dart` — `CupidPlatformTokens extends ThemeExtension<CupidPlatformTokens>`; fields `radiusCard, radiusButton, radiusSheet, radiusSmall, safeTop, safeBottom, tapTarget, uiFontFamily, elevationShadow`; `const CupidPlatformTokens.ios()` / `.material()` per UX spec §2.
  - `design_system/tokens/cupid_color_tokens.dart` — `CupidColorTokens extends ThemeExtension<CupidColorTokens>`; one field per UX spec §3 token (`colorBackground … gradientHot`); `const CupidColorTokens.dark()` / `.light()`.
  - `design_system/tokens/cupid_typography_tokens.dart` — `CupidTypographyTokens extends ThemeExtension<…>`; roles `display, cardTitle, body, caption, labelMono` (UX §4), built via `CupidTypographyTokens.forPlatform(CupidPlatform)` so `body` picks up `uiFontFamily`; colorless (color applied at use site from `CupidColorTokens`).
  - `design_system/tokens/cupid_spacing.dart` — `abstract final class CupidSpacing` with const `xs/sm/md/lg/xl/xxl` (UX §4). Not a `ThemeExtension`: invariant across all 4 combos, so theme lookup would add cost without variance.
  - `design_system/theme/cupid_theme.dart` — `ThemeData buildCupidTheme({required CupidPlatform platform, required Brightness brightness})`; registers the three extensions and derives a `ColorScheme` from `CupidColorTokens` so stock Material widgets inherit brand color without a second source of truth.
  - `design_system/theme/cupid_platform.dart` — `enum CupidPlatform { ios, material }`, resolved from `defaultTargetPlatform` (iOS/macOS → `ios`, else `material`) with a `CupidPlatformOverride` inherited widget so tests and QA can render all 4 combos on one device.
  - `design_system/theme/cupid_theme_context.dart` — the three `BuildContext` getters (non-null; assert on missing extension).
  - `design_system/icons/` — `CupidIcons` façade over Material Symbols Rounded + `enum CupidIconVariant { filled, line, soft }` mapped to `fontVariations` (`FILL/wght/GRAD/opsz` per UX §2).
  - `design_system/adaptive/` — `CupidTabBar`, `CupidHeader`, `CupidPrimaryButton`, `CupidAddAction` (behaviors per UX §6). These four files are the **only** files in the repo allowed to branch on `CupidPlatform`.
  - `design_system/design_system.dart` — barrel export.
  - `core/config/cupid_feature_flags.dart`, `l10n/arb/app_{vi,en}.arb`, `mobile/l10n.yaml`, `app/cupid_app.dart`.
- Infrastructure: `mobile/assets/fonts/` (Nunito, Roboto, Roboto Mono, MaterialSymbolsRounded variable TTF) declared in `pubspec.yaml`; `generate: true` under `flutter:`.

### ADR-004a — Enablement flag mechanism (gates AC 3)

`CupidFeatureFlags` exposes two `static const bool` fields initialised with `bool.fromEnvironment('CUPID_ENABLE_LIGHT_THEME' | 'CUPID_ENABLE_EN_LOCALE', defaultValue: false)`.

- Flags gate **exposure**, never existence. `buildCupidTheme(...)` for light and the `en` ARB are always compiled and always directly constructible in tests, which is what keeps AC 1 and AC 3 compatible.
- `CupidApp` behavior: flag off → `themeMode: ThemeMode.dark`, `locale: const Locale('vi')`, and any future settings screen must hide the corresponding picker by reading the flag. Flag on → `themeMode`/`locale` follow the device with `vi` fallback.
- `localizationsDelegates` and `supportedLocales` always advertise both locales regardless of flags; the pinned `locale` is what enforces `vi` at v1.
- Const evaluation means release builds tree-shake the disabled branches, and there is no runtime toggle surface to abuse.
- Rejected: `--dart-define` read at runtime through a mutable config object (no tree-shaking, adds a toggle surface v1 does not want); remote/served flags (no backend support, out of REQ-001 scope).

### ADR-004b — Light-theme accent contrast constraint (binding on all screen stories)

From UX §5: light `colorAccentPink` `#E8558F` on `colorSurface` `#FFFFFF` is ~3.4:1 — below the 4.5:1 AA threshold for normal text, above the 3:1 threshold for large text and non-text UI. Dark theme (~6.8:1) and both `colorText`-on-background pairs pass.

Rule: in **light** theme, `colorAccentPink`, `colorAccentPinkDark`, `colorAccentPurple`, `colorAccentPurpleDark` may be used for large text (≥18pt, or ≥14pt bold), icons, borders, focus rings, gradients and decorative accents only. Body and caption text on `colorSurface`/`colorBackground` must use `colorText` or `colorTextMuted`. Enforced by (a) dartdoc on each affected field in `CupidColorTokens.light()` and (b) the contrast tripwire test in Risk Surfaces below. No AA-safe light accent value is invented here — if a screen story needs accent-colored small text in light theme, that is a UI/UX Designer decision, not a Mobile Developer substitution.

### ADR-004c — `colorAccentPurpleDark` light-theme gap (resolves UX §8 item 1)

The design source has no light override. Decision for v1: carry the dark value `#8E5FD6` unchanged into `CupidColorTokens.light()`, with a dartdoc marking it a design-source gap. It measures ~4.4:1 on white — non-text-safe under ADR-004b, which is exactly the usage this token already has (gradient stop, pressed/darker accent state). No escalation is required unless a screen story requests it as small-text color, in which case route to UI/UX Designer.

### ADR-004d — Icon family (resolves UX §8 item 2)

Adopt **Material Symbols Rounded on both platforms** for v1. Rationale: the design source's fill states are variable-font axes (`FILL/wght/GRAD/opsz`) with no SF Symbols equivalent; SF Symbols has no first-class Flutter API and its licence blocks redistribution as an app asset; a second icon set would add a fifth platform fork point and contradict D3. Implementation constraint: bundling the variable font and using non-const `IconData` disables Flutter's icon tree-shaking — prefer const `IconData` in `CupidIcons`, and if the build fails, pass `--no-tree-shake-icons` and record it in the configuration guide. Revisiting this is a new story, never a per-screen fork.

### ADR-004e — i18n / ARB pipeline

`flutter_localizations` (SDK) + `intl`; `generate: true` in `pubspec.yaml`; `mobile/l10n.yaml` with `arb-dir: lib/l10n/arb`, `template-arb-file: app_vi.arb`, `output-localization-file: app_l10n.dart`, `output-class: AppL10n`, `output-dir: lib/l10n/generated`, `synthetic-package: false`, `nullable-getter: false`, `untranslated-messages-file: l10n-untranslated.json`. Generated output is gitignored; `flutter gen-l10n` runs via `flutter pub get`/build preflight. `vi` is the template locale, so a missing `en` translation is a reported gap rather than a silent fallback. Key convention: `snake_case` `<feature>_<screen>_<element>`. STORY-001 ships only a smoke key set proving resolution in both locales; per-screen copy extraction from `cupid-mobile-design/` `[data-vi]`/`[data-en]` belongs to each screen story.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| 4-combination completeness (AC 1) | `ux/uiux-spec.md` §2–§5 | `buildCupidTheme` | Unit test builds all 4 `ThemeData` and asserts every extension resolves non-null | Cannot claim AC 1 — return BLOCKED |
| Light-accent contrast (ADR-004b) | ADR-004b + UX §5 | `CupidColorTokens.light()` | Tripwire test asserting computed ratios (light pink-on-surface < 4.5, ≥ 3.0; dark pink-on-surface ≥ 4.5; both `colorText` pairs ≥ 4.5) | Contrast rule unenforced — return BLOCKED |
| Locale parity (AC 2) | `app_vi.arb` | `AppL10n` | Test asserting identical key sets in both ARBs, plus `l10n-untranslated.json` empty; resolution test for `vi` and `en` | AC 2 unproven — return BLOCKED |
| No-fork discipline (AC 4) | D3 / ADR-004 | `design_system/adaptive/` | Source-scan test: no `Color(0x`, `Colors.`, `Platform.is`, or `defaultTargetPlatform` outside `lib/design_system/` (passes vacuously today; the guard is the deliverable) | AC 4 unenforceable across 31 screens — return BLOCKED |
| Flag behavior (AC 3) | ADR-004a | `CupidFeatureFlags`, `CupidApp` | Widget test: flags default false, `CupidApp` pins dark + `vi`; light `ThemeData` and `en` still constructible directly | AC 3 unproven — return BLOCKED |

### Mobile Lane Handoff

- Responsibilities: everything in Affected Components, the five guard tests, font asset bundling, and `pubspec.yaml`/`l10n.yaml`/`analysis_options.yaml` wiring.
- Authoritative inputs: this solution and `ux/uiux-spec.md` §2–§7 for exact token names and values.
- Guardrails: do not rename any public symbol in §2; do not add a `CupertinoApp`; do not invent token values absent from UX §2–§4 (the only sanctioned carry-over is ADR-004c); do not build any screen; do not add dependencies beyond `flutter_localizations` + `intl`.

### DevOps Lane Handoff

- Responsibilities: create runtime registry id `mobile-app`; record the two `--dart-define` keys, the QA command for the non-default combinations, and the `--no-tree-shake-icons` fallback.
- Requirement configuration guide update: REQUIRED.
- Guardrails: release/store builds must not set either flag to `true`.

### Backend Lane Handoff

Not applicable — no backend surface in this story.

## 5. Non-Functional Impact

- Security / privacy: no secrets, no network. Bundled fonts avoid third-party font CDN calls (no client IP leakage, works offline).
- Performance: three theme extensions resolve via `Theme.of` — O(1); spacing is const. Bundled variable font adds ~1–2 MB to the bundle, accepted in exchange for the icon-variant tokens.
- Observability: none required.
- Rollout / rollback: flags default off, so enabling light/`en` later is a build-flag change plus a settings-UI story, with no token migration.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| One combinatorial 4-variant `ThemeExtension` | Fewer classes | Rejected | Source axes are orthogonal; combinatorial variants would duplicate every color 2x and drift |
| Platform + theme extensions composed | Matches source structure and D3 | **Adopted** | Adding a platform or a theme stays linear, not multiplicative |
| Spacing/typography as plain consts | Simplicity | Partially adopted | Spacing const (invariant); typography is an extension because `body` depends on the platform font |
| `google_fonts` runtime fetch | Less bundle weight | Rejected | Network dependency, startup jank, privacy leak; app is offline-capable |
| SF Symbols on iOS | Native feel | Rejected (ADR-004d) | Licence + no Flutter API + adds a fifth fork point |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Screen stories bypass tokens with raw literals (R7 recurrence) | High | AC 4 source-scan guard test + single barrel import surface |
| Light-accent contrast failure resurfaces on a screen | Medium | ADR-004b dartdoc + contrast tripwire test |
| ARB key drift between `vi` and `en` | Medium | Parity test + `untranslated-messages-file` gate |
| iOS-style typography unverifiable on Android (SF Pro not bundleable) | Low | Documented: iOS-style typography audited on iOS targets only |
| `mobile-app` runtime registry id missing | Low | DevOps task; does not block `flutter test`-based gates |

## 8. Handoff Notes

- Implementation guardrails: token values come verbatim from UX §2–§4; ADR-004a–e are binding and may not be re-decided by the implementation lane.
- OQ-driven constraint: OQ5 — build all four combinations and both locales; expose only dark + `vi`.
- Shared contract-first work: `tokens/` + `theme/` land before `adaptive/`, `icons/`, and `app/`.
- Shared coding plan required: YES (Complexity L; the file set exceeds one specialist lifecycle and must be split into sequential phases — tokens/theme, adaptive+icons, l10n+flags+app wiring, verification).
- Memory updates required: none now. When STORY-001 merges, append ADR-004a–e as refinements of ADR-004 during the next foundation pass.
- Open questions / blockers: none. UX §8 items 1 and 2 are resolved by ADR-004c and ADR-004d.
