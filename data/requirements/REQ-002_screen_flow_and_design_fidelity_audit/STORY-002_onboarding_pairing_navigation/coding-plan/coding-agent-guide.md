# Coding Agent Guide: STORY-002

Read this before starting any phase. It carries the conventions that are not
obvious from the phase files.

## Operating Root

All work happens in the STORY-002 worktree. Every path in the phase files is
repo-relative to that worktree root.

## Phase Order

P1 → (P2 ∥ P3) → P4 → P5. One canonical file per phase id:
`phase-P1-*.md` … `phase-P5-*.md`. Do not create additional phase files.

## Hard Precondition Before P3

Rebase onto the requirement integration branch and confirm the `otp`,
`permissions`, and `vow` screens exist. At `BaseHead` they are listed in
`mobile/lib/main_preview.dart` `_notImplementedCanvasIds`. If any is still
missing, **stop and report the exact missing dependency** — STORY-007 /
STORY-009 / STORY-016 own building them, and the Product Owner Ruling
(2026-08-14) forbids this story absorbing that work. P1 and P2 do not need
them and can proceed regardless.

## Codebase Conventions (observed, follow them)

- **Design tokens**: never a literal colour. Bind
  `final CupidColorTokens colors = context.cupidColors;` to a **local**
  first — a directly-chained `context.cupidColors.x` access trips the no-fork
  guard test's forbidden-literal substring scan. This is why existing screens
  all have that odd-looking local plus its comment.
- **Localization**: chain screens resolve vi/en through a local
  `viEn(vi, en)` extension on `BuildContext` keyed off
  `Localizations.localeOf(context).languageCode == 'vi'`. Follow the file's
  existing pattern rather than introducing a shared helper across features.
- **Cubit injection seams**: every screen takes an optional
  `SomeCubit Function()? createSomeCubit` that defaults to a `getIt`-backed
  factory. Tests supply fakes through it. Preserve these seams — they are the
  only reason widget tests run without live Firebase/Dio.
- **`AuthRepository` is not in `getIt`.** Callers construct it. Keep it that way.
- **`AccountRepository` is** in `getIt` (`service_locator.dart:96`).

## Navigation Rule

After P1, chain navigation goes through `OnboardingRouter`. Do not add new
inline `Navigator.push(MaterialPageRoute(builder: (_) => SomeScreen()))` calls
inside a chain screen — removing that scattered pattern is the point of the
story. Non-chain navigation (gallery viewer, jar detail, chat) is untouched.

## Do Not Touch

- Body, layout, or visual fidelity of `otp`, `permissions`, `vow`, or any
  other Scope B screen. Register them in the router; nothing more.
- Backend, schema, API client, or `data/devops/**`. This story is mobile-only.
- The cold-launch splash routing decision — that is STORY-001.
- `love_contract_screen.dart` beyond its chrome/entry-mode seam. STORY-019
  owns that screen's fidelity.

## Testing

`flutter analyze` clean, `flutter test` green. No e2e, Playwright, or emulator
gate inside an implementation phase. Prefer unit tests over widget tests for
ordering logic — `OnboardingChain` and `OnboardingProgressResolver` are plain
Dart specifically so AC1/AC2/AC3 can be proven without pumping widgets.

## Reporting

Report per phase: files changed, tests added, analyze/test result, and any
verification-contract blocker from `master-plan.md` §6 you could not clear.
