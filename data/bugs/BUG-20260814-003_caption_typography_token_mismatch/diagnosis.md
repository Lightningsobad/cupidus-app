# Diagnosis: BUG-20260814-003 Caption Typography Token Mismatch

Bug id: BUG-20260814-003_caption_typography_token_mismatch
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Worktree: `.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`

## Pre-Fix Reproduction Gate

Result: REPRODUCED (4 assertions, all before any owner-source edit).

Command A — the 3 anchors named in the bug report:

```
flutter test test/features/auth/presentation/screens/login_screen_test.dart \
             test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart \
             test/features/pairing/presentation/screens/joincode_screen_design_test.dart \
  --reporter failures-only
```

`+24 -3: Some tests failed.` (exit 1). Each failure `Expected: <13> / Actual: <11.5>`:

| Anchor | Test | Line |
|---|---|---|
| login | `design-source subtext slot renders below the heading` | `login_screen_test.dart:91` |
| waiting | `applies the design source typography and muted subtitle` | `waiting_screen_design_fidelity_test.dart:188` |
| joincode | `heading and sub-copy use the design source display/caption roles` | `joincode_screen_design_test.dart:107` |

Anchor correction: the report and checkpoint cite
`waiting_screen_design_fidelity_test.dart:238`. The assertion is at `:188` on
this branch — BUG-20260815-002's merged patch shortened the file above it. Same
test, same assertion.

Command B — the second drift:

```
flutter test test/features/pet/presentation/pet_design_fidelity_test.dart --reporter failures-only
```

`+8 -1: Some tests failed.` (exit 1) —
`pet_design_fidelity_test.dart:150`, test
`renders the section title as an uppercase muted eyebrow`:
`Expected: a numeric value within <0.0001> of <0.65> / Actual: <0.5750000000000001>`.

## Report Corrections (evidence-backed)

Two claims in finding I-5 / the bug report do not survive query-first checking.
Neither changes the fix, but both change what "done" means:

1. **It is not an alpha.** `0.65 → 0.575` is `letterSpacing`, not a muted-alpha
   value. `pet_reactions_card.dart:41` computes
   `letterSpacing: 0.05 * type.caption.fontSize!`. There is no `0.575` literal
   anywhere in `mobile/lib`, and no `0.65` anywhere in `mobile/lib/design_system`
   — the value is derived, never declared.
2. **It was already covered.** I-5 states the second drift has "no assertion".
   `pet_design_fidelity_test.dart:150` asserts it and was RED (Command B). No new
   assertion was needed for this drift; the assertions added by this fix cover
   two *different* uncovered surfaces (see Coverage Added).

## Root Cause

**One root cause, shared — confirmed, not assumed.**

`CupidTypographyTokens.caption`
(`mobile/lib/design_system/tokens/cupid_typography_tokens.dart:46-50`) was
declared `fontSize: 11.5`. The Love Pet eyebrow derives its letter spacing from
that same field arithmetically, so a single token value produces both symptoms:

| Token `caption.fontSize` | Sub-copy renders | `0.05 × fontSize` eyebrow spacing |
|---|---|---|
| `13` (expected) | `13` | `0.65` |
| `11.5` (observed) | `11.5` | `0.575` |

`0.05 × 11.5 = 0.575` exactly reproduces the observed value. The two drifts are
**not** independent regressions.

### How the token drifted

`git log -L 44,52:cupid_typography_tokens.dart`:

| Commit | Story | Change |
|---|---|---|
| `eeaeeae` | REQ-001/STORY-001 | created `caption` at `fontSize: 13` |
| `bf01450` | REQ-002/STORY-033 | `fontSize: 13` → `11.5` ("Delta 2") |

This was a deliberate, reviewed, merged change — not an accidental regression.
STORY-033's `ux/ux-spec.md` "Delta 3 — caption Text Style Declared Size (AC3)"
argues the design source's canvas `profile` has no 13px small text, and set the
token to the 11.5px zodiac-helper value to fix that helper's 2-line wrap.

### Why both stories were half right

STORY-033's measurement is correct but partial. Read directly from the locked
design source `cupid-app-design-system/project/Cupid Screens.dc.html`, small
supporting text is drawn at **four distinct sizes**, and `caption` is the single
token serving all of them:

| Design-source role | Size | Source lines |
|---|---|---|
| Uppercase field labels (`letter-spacing:.06em`) | 11px | 104, 108, 113 |
| Inline helper (zodiac auto-derived) | **11.5px** | 110 |
| Card eyebrows (`font-weight:700; letter-spacing:.05em`) | 12px | 416, 473, 654, **680** |
| Avatar crop hint | 12.5px | 100 |
| Screen sub-copy / subtitle | **13px** | 1429, 1554, 1580 |

The three RED sub-copy assertions are faithful transcriptions of the 13px rows:

| Test | Design-source line | Declared |
|---|---|---|
| `login_screen_test.dart:91` (`Bae đang đợi ở trong đấy`) | 1429 | `font-size:13px` |
| `joincode_screen_design_test.dart:107` (`Bảo Bae đọc mã…`) | 1554 | `font-size:13px; line-height:1.6` |
| `waiting_screen_design_fidelity_test.dart:188` (`Gửi mã rồi mà chưa thấy ai vào…`) | 1580 | `font-size:13px; line-height:1.6` |

`13` is also what `ux/uiux-spec.md` section 4 documents — the spec the token's
own dartdoc cites: `| Caption (timestamps, metadata) | 13pt |` (line 96).

So STORY-033 re-pointed a shared token at one consumer's smaller role, which
mechanically resized every 13px consumer with it. STORY-033 anticipated exactly
this hazard and declared it out of its own scope
(`ux/ux-spec.md:161-171`): *"Both roles route through the same `type.caption`
base today… If Tech Lead/dev determine the two roles must diverge into separate
tokens, that is a new token and is out of this story's declared scope — raise it
as a follow-up rather than doing it inside this story."* This bug is that
follow-up.

## Fix Strategy

Restore the token to its documented `13` sub-copy/metadata role, and give the
11.5px inline-helper role its own stated size at its two consumers so
STORY-033's merged AC3 is preserved rather than silently undone.

A plain revert to `13` was rejected: no test pins the zodiac helper's size or its
single-line wrap (verified — no `zodiac` size assertion exists in `mobile/test`),
so reverting alone would have re-broken AC3 with nothing to catch it.

Introducing a new `ThemeExtension` field for the smaller role was also rejected
as disproportionate: only two call sites need it, and a stated local size is the
established repo idiom for a design-source-specific override
(`login_screen.dart:46 _dividerLabelFontSize`, `splash_screen.dart:380`,
`onboarding_profile_setup_screen.dart:41 _cardLabelLetterSpacing`).

## Coverage Added

Two surfaces that were silently unprotected now have assertions:

| Surface | New assertion | Why it was needed |
|---|---|---|
| The shared token itself | `theme_matrix_test.dart` — `caption keeps the section 4 declared size on both platforms` | Nothing pinned the token; re-pointing it was a 1-line change with cross-screen blast radius and no direct failure. |
| STORY-033 AC3 zodiac helper | `onboarding_profile_setup_screen_test.dart` — `zodiac helper keeps the canvas 11.5px inline-helper size` | AC3's fix rode entirely on the shared token with no assertion of its own. |

The Love Pet eyebrow drift needed no new assertion —
`pet_design_fidelity_test.dart:150` already covers it and is now GREEN.

## Changed Files

| File | Change |
|---|---|
| `mobile/lib/design_system/tokens/cupid_typography_tokens.dart` | `fontSize: 11.5` → `13`; comment recording the four roles so the token is not re-pointed again |
| `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart` | `_zodiacHelperFontSize = 11.5` stated on the helper |
| `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart` | same, for the same role on the edit screen |
| `mobile/test/design_system/theme_matrix_test.dart` | token-size regression assertion |
| `mobile/test/features/onboarding/presentation/screens/onboarding_profile_setup_screen_test.dart` | AC3 helper-size regression assertion |

## Not In Scope (findings for Scrum Master to triage)

These are real design-source deltas found during diagnosis. All are
pre-existing, none is asserted RED, none is named by this bug, and each would
widen the change well past the reported failures:

- **F-1 — Love Pet eyebrow is 12px in the design source, not 13px.** Line 680
  (`{{ petReactTitle }}`) declares `font-size:12px; font-weight:700;
  letter-spacing:.05em` → true spacing `0.6`, not `0.65`. The `0.65` this bug
  restores is derived from `caption`, so `pet_design_fidelity_test.dart:150` is
  self-consistent but transcribes the token rather than the canvas. Same applies
  to the three sibling eyebrows at lines 416, 473, 654.
- **F-2 — uppercase field labels are 11px in the design source.** They inherit
  `caption` (now 13px) at `profile_edit_screen.dart:271-277` and
  `onboarding_profile_setup_screen.dart` `_FieldCard`. This is STORY-033's own
  flagged residual micro-delta, now 2px rather than 0.5px.
- **F-3 — avatar crop hint is 12.5px** (design-source line 100); inherits
  `caption` on both profile screens.

F-1/F-2/F-3 are the role-split follow-up STORY-033 asked for. Recommend one new
bug covering the small-text scale as a whole rather than folding them in here.
