# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
This story has no unresolved OQ; OQ2 is RESOLVED and its outcome is already
encoded in AC4 and in the P1 guardrails — do not reopen it.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane (both phases here are Mobile).
3. Update phase `## 7. Status` immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand phase scope into scanning, expiry, or the couple-type picker.
6. Stop and escalate if the assigned work requires a decision the phase does
   not already resolve.

## 4. Story-Specific Traps

These have already cost time to discover; do not rediscover them.

- `mobile/test/design_system/no_fork_guard_test.dart` substring-scans
  `lib/features`, `lib/app`, `lib/core` for `Color(0x` and `Colors.`. A single
  `Colors.black` passed to the QR widget's module color turns that test red.
  All QR colors come from `lib/design_system/tokens/qr_palette.dart`.
- The token access must be bound to a local (`final CupidColorTokens colors =
  context.cupidColors;`) rather than chained off `context` at each use — the
  existing card does this deliberately for the same guard.
- The Continue CTA currently does **not** navigate. Wiring it is P1 work, not a
  no-op check. The push it needs already exists verbatim in `_copyAndAdvance`.
- Never import anything from `features/vow/` into `invite_screen.dart`;
  `post_code_navigation_guard_test.dart` fails the build on the substring.
- The design source shows an 8-character code, an in-card waiting pill, and a
  "Simulate: partner joined" link. None of the three exist in the app. Do not
  add them, and do not change the "Mã 6 ký tự" caption.
- The QR payload is the bare code string, never
  `https://cupid.app/pair?code=...`. See `../architecture/contract-summary.md`.
- `flutter` is not on PATH on this machine. Prefix commands with
  `PATH="$HOME/flutter/bin:$PATH"` or use `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Record test commands and assertion names in `coding-plan/test-results.md`.
- Do not redesign the plan during implementation; escalate if it is materially
  wrong.
