# Story Master: STORY-047 Pairing Chain Undisclosed Deviation Triage

Status: RETRO_PENDING
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-010_onboarding_profile_design_fidelity, STORY-012_join_code_design_fidelity
Fixes (descoped 2026-08-18, see REQ-004): STORY-009_permissions_design_fidelity
Scope: Retro-hardening (RWB-20260816-024) — AC1/AC3/AC4/AC5 only; AC2
(`permissions`/STORY-009 copy token) descoped into REQ-004, see
`## Blocker (2026-08-18)`.
Screens: Onboarding Profile Setup (`profile`), Join/Enter Pairing Code
(`joincode`) — 2 screens closed here. Permissions (`permissions`) AC2 moved
to REQ-004 (ADR-002 copy conflict).

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — mobile lane, AC1/AC3/AC4/AC5 (AC2 descoped
  to REQ-004). Evidence:
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-047_pairing_chain_deviation_triage/visual-fidelity/visual-fidelity-report.md`
  (`VISUAL_FIDELITY: PASS`)
- [ ] Review (Reviewer)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-024 (source:
`STORY-046_shared_backdrop_occlusion_hardening`'s reviewer,
`review/review-report.md` cycle 2, finding DEF-3) — read directly, not
re-derived, before this story is scoped.

STORY-046's reviewer (Iris-QC) opened all 12 rendered PNGs added by that
story's evidence patch and confirmed 4 categories of deviation from the
design references, none moved by STORY-046's own diff (a backdrop-only
change) and none newly introduced by it:

1. No app-bar chrome on `otp`, `profile`, `permissions`, `joincode`, where
   the references draw a titled header. **Already resolved as an approved
   deviation** — governed by `ux/uiux-spec.md` Chrome Rules. Not part of
   this story's scope; do not reopen.
2. `profile`: filled person-glyph avatar vs. the design reference's dashed
   "Ảnh đại diện" ring; CTA reads "Tiếp tục → Love Contract" vs. the
   reference's "Tiếp tục → Ghép đôi". Owner: `STORY-010_onboarding_profile_design_fidelity`.
3. `permissions`: notification body copy "Nhắc nhớ đồng bộ và Emoji Storm"
   vs. the reference's "Synced Alarm và Emoji Storm" (localization delta).
   Owner: `STORY-009_permissions_design_fidelity`.
4. `joincode` (reviewer called this **"the largest"**): a single
   6-character free-text field vs. the reference's 8-character segmented
   `CPD-8…` cells, and no "Dán" / "Quét QR" / "Tôi mới là người tạo mã →"
   affordances. Owner: `STORY-012_join_code_design_fidelity`.

Reviewer's own framing (do not re-derive, quoted for scope discipline):
"a future reader who sees `VISUAL_FIDELITY: PASS` on STORY-046 must not
conclude that these 6 screens match the design source... the `PASS` means
'the backdrop fix landed and this story moved nothing else'."

Classification: pre-existing gaps in each screen's own origin story, not
introduced or worsened by STORY-046. Each is undisclosed by that origin
story's own `visual-fidelity-report.md` (none of them flagged it), so this
is new information, not a re-litigation of an already-reviewed deviation.

Exact remediation needed: Product Owner triages items 2, 3, and 4 above —
`joincode` (item 4) first, since it is structural rather than cosmetic and
may carry backend/validation implications (segmented-cell entry vs.
free-text). For each, decide and record: (a) genuine defect to harden
(route to `mobile` lane, and for `joincode` confirm whether the join-code
format itself is 6 vs. 8 characters at the backend/contract level before
prescribing a UI-only fix), or (b) accepted product/content difference to
record and close as-is (no code change, only a documentation correction in
each origin story's own artifacts). Do not assume UI-only scope for
`joincode` without checking whether the 6-vs-8-character mismatch is a
UI-only render gap or a real product/contract mismatch.

Carry-forward note: RWB-20260816-012's closure found that prior deviation
lists in this requirement were sometimes inflated by a stale, mis-scaled
STORY-002-era capture. This item's 3 deviations were instead found by a
reviewer opening real rendered PNGs from STORY-046 (fresh renders, not the
old capture set), so that specific risk does not apply here — but Product
Owner should still independently confirm each deviation against the current
`design-reference-*`/`implemented-*` pairs before scoping ACs, not just
trust the reviewer's prose description.

Exact remediation steps: see `rework-backlog.md` RWB-20260816-024 detail
section and STORY-046's own `review/review-report.md` finding DEF-3
(already read, do not re-derive).

## Product Owner Triage (2026-08-18)

Each of the 3 deviations was independently re-confirmed against the current
locked design source (`cupid-app-design-system/project/Cupid App.dc.html`,
which `<dc-import name="Cupid Screens">`s the actual per-screen markup in
`Cupid Screens.dc.html`) and the current shipped mobile/backend source, not
just the reviewer's prose or a single PNG pair — two of the three screens'
own PNG pairs on disk turned out to be stale/non-representative (see notes
below), so the source-level check was load-bearing, not a formality.

### Screen 1 — `profile` (owner: STORY-010_onboarding_profile_design_fidelity)

**1a. Avatar dashed-ring vs filled person-glyph — ACCEPTED DIFFERENCE, already
disclosed, no code change.** STORY-010's own
`visual-fidelity/visual-fidelity-report.md` §4.1 ("Empty-avatar placeholder is
the app's glyph, not the canvas' dashed slot") already reasoned this exact
point: the design source's `<image-slot placeholder="Ảnh đại diện">` dashed
ring is Claude Design's own authoring-tool "drop an image here" chrome, not
literal product UI, and `onboarding_profile_setup_screen.dart` deliberately
uses the app's standard empty-avatar person glyph instead (confirmed at
`onboarding_profile_setup_screen.dart:171-173`). RWB-20260816-024's framing of
this item as "undisclosed" does not hold for this specific sub-item — it was
disclosed and reasoned in STORY-010's own artifacts. Product Owner concurs
with STORY-010's reasoning. No AC, no doc correction needed (STORY-010's
report already states it correctly).

**1b. CTA text "Tiếp tục → Love Contract" vs design's "Tiếp tục → Ghép đôi" —
GENUINE DEFECT, in scope.** Confirmed at the source level, not just image
comparison: the locked design source (`Cupid Screens.dc.html:117`) reads
`Tiếp tục → Ghép đôi` / `Continue → Pair up` with `onClick="{{
goPairingChoice }}"`, and the app's own `OnboardingChain._forwardOrder` sends
`profileSetup → pairingChoice` — i.e. the button's real destination is the
pairing-choice screen, several chain nodes before `loveContract`. The shipped
app hardcodes `Tiếp tục → Love Contract` / `Continue → Love Contract`
(`onboarding_profile_setup_screen.dart:408-409`), which is both a design-source
mismatch and a label that misdescribes its own actual navigation target.
STORY-010's own report (line 135) recorded this as a "copy match" against the
design source — that transcription was wrong; the source does not say "Love
Contract" at that line. This is why the on-disk `design-reference-*-android.png`
in STORY-010's own folder is not representative (it shows "Love Contract"): it
does not reflect the current locked source text; the source HTML itself is the
tie-breaker here, per this story's own carry-forward note.

- **AC1 (profile, mobile lane):** Given the `profile` screen's continue CTA,
  when rendered, then its label reads `Tiếp tục → Ghép đôi` (vi) /
  `Continue → Pair up` (en), matching `Cupid Screens.dc.html:117`, and its
  `onPressed` continues to navigate to `pairingChoice` (behavior unchanged —
  copy-only fix). Update the corresponding assertion in
  `onboarding_profile_setup_screen_test.dart` (`_ctaLabel`).

### Screen 2 — `permissions` (owner: STORY-009_permissions_design_fidelity)

**2a. Notification body copy "Nhắc nhở đồng bộ và Emoji Storm" vs design's
"Synced Alarm và Emoji Storm" — GENUINE DEFECT, in scope, genuinely
undisclosed.** Confirmed at the source level: `permissions_screen.dart:80-81`
ships `Nhắc nhở đồng bộ và Emoji Storm cần cái này...` / `Synced Reminder and
Emoji Storm need this...`; the locked design source
(`Cupid Screens.dc.html:2452`) specifies `Synced Alarm và Emoji Storm cần cái
này...` / `Synced Alarm and Emoji Storm need this...` — `Synced Alarm` is used
as a fixed feature/brand name throughout the design source in both languages
(lines 1773, 1887, 2411), not translated, so the app's invented
"Nhắc nhở đồng bộ"/"Synced Reminder" phrasing is a real content deviation, not
a legitimate localization choice. Unlike the `profile` avatar item, this one
really is undisclosed: grepped STORY-009's own
`visual-fidelity/visual-fidelity-report.md` for this string and found no
mention. (Note: the PNG pair in STORY-009's own `visual-fidelity/` folder
already shows the corrected "Synced Alarm" text and is therefore also
non-representative of the current shipped code — the PNGs in STORY-046's own
evidence-patch folder, which is what the reviewer actually opened, show the
real "Nhắc nhở đồng bộ" text and match the current source.)

- **AC2 (permissions, mobile lane) — DESCOPED 2026-08-18, folded into
  REQ-004.** Given the `permissions` screen's notifications-permission row
  body copy, when rendered, then it reads `Synced Alarm và Emoji Storm cần
  cái này. Tối đa 15 cái/ngày.` (vi) / `Synced Alarm and Emoji Storm need
  this. Max 15 a day.` (en), matching `Cupid Screens.dc.html:2452`. Blocked
  by STORY-021's approved ADR-002 copy guard
  (`reminder_copy_guard_test.dart:18-22`, bans literal `synced alarm`) —
  same guard/ADR conflict class already tracked, PENDING, in
  `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/req_master.md`
  for a different token ("Do Not Disturb"). User decision 2026-08-18: fold
  this token into REQ-004 rather than litigate it separately; STORY-047
  closes without AC2. The shipped ADR-002-canonical copy
  (`permissions_screen.dart:80-81`) is unchanged and stays authoritative
  until REQ-004's PO/UX ruling lands.

### Screen 3 — `joincode` (owner: STORY-012_join_code_design_fidelity)

STORY-012's own `story_master.md` "Follow-Up Scope (Deferred)" section had
already identified and deferred all 4 of this screen's gaps, explicitly
flagged 2 of them "Product Owner decision" — this triage makes those
decisions. See that file's Follow-Up Scope section (items 1-4) for the
decision detail; summarized here:

**3a. Code length 6 vs 8 — ACCEPTED DIFFERENCE, closed, no code change.**
Confirmed the shipped 6-character code is a real, working, fully-implemented
end-to-end contract: `InvitationsService.generateCode`
(`backend/src/modules/invitations/invitations.service.ts:36`,
`randomBytes(3).toString('hex').toUpperCase()`, 6 hex chars), `JoincodeScreen`
(`maxLength: 6`), `InviteScreen` display, and the repository test suite. The
design source's "8 ký tự" copy (`Cupid Screens.dc.html:1562`) does not even
match its own static mockup, which draws only 5 character-box divs plus a
dash separator (lines 1564-1569), not 8. This answers this story's own
carry-forward question: the 6-vs-8 gap is a design-source content
inconsistency, not a UI-only rendering gap and not a real backend/contract
mismatch requiring a Tech Lead/backend decision — the backend and every mobile
surface already agree with each other at 6; only the design mockup's copy
text disagrees with itself and with the shipped product. No AC.

**3b. Code-entry segmented-box row vs single free-text field — GENUINE
DEFECT, in scope.** The design source renders the code entry as individual
bordered boxes (`background:var(--surf)`, `border:1.5px solid var(--line)`,
`border-radius:16px`, active slot `border:var(--pink)` +
`box-shadow:var(--glow)`, `Roboto Mono` 21px/500) rather than the shipped
single `TextField`. Since 3a keeps the code at 6 characters, this becomes a
6-slot segmented box row (not the design mockup's partially-drawn 5), styled
per the design's box treatment, UI-only — the underlying value stays a
6-character string.

- **AC3 (joincode, mobile lane):** Given the `joincode` entry field, when
  rendered, then the 6 characters are entered via 6 individually bordered
  slot boxes styled per `Cupid Screens.dc.html` D3/D4 tokens (`colorSurface`
  fill, `colorLine` border, `radiusSmall` corners, `colorAccentPink` +
  `glowShadow` on the active/focused slot, `colorRed` on error, Roboto Mono
  21px/500) instead of the current single full-width `TextField`, preserving
  existing behavior: paste-fills-multiple-slots, backspace-across-slots,
  the existing `errorText` rejection message tied to the control by
  description (uiux-spec §9), and the existing `submit`/`isBusy` flow in
  `JoincodeCubit` unchanged. Empty, partial, active, and error states must
  each visually match the design source's per-state slot styling (D3/D4).

**3c. `Dán` (paste) affordance — GENUINE DEFECT, in scope, small.** Missing
entirely from the shipped screen. Low complexity: `Clipboard.getData` (already
available via `package:flutter/services.dart`, already imported by a sibling
pairing screen) needs no new dependency or platform permission.

- **AC4 (joincode, mobile lane):** Given the `joincode` screen, when the user
  taps the `Dán` / `Paste` button, then the clipboard's text content (trimmed,
  uppercased, truncated to 6 characters) populates the code-entry control from
  AC3, matching the design source's paste-pill placement and styling
  (`Cupid Screens.dc.html:1572`).

**3d. `Quét QR` (scan QR) affordance — OUT OF SCOPE for this story, stays
deferred.** STORY-012 already correctly flagged this as "genuine feature
work, not a style/token fix" — it needs a new camera/QR-scanning package
dependency, `pubspec.yaml` changes, and platform camera-permission manifest
entries, none of which exist in this app today (confirmed: no QR/camera
scanning package in `pubspec.yaml`). This is materially bigger than a
hardening fix and does not belong in a trivial single-mobile-lane triage
story. No AC. Recommend Scrum Master register it as its own future story
(needs Tech Lead solutioning for package/permission choices) if/when the
product wants QR-based pairing.

**3e. `Tôi mới là người tạo mã →` cross-link — GENUINE DEFECT, in scope,
small.** Confirmed this is not a duplicate of the existing in-chain back
button: `pairingChoice` is a branching node with no entry in
`OnboardingChain._forwardOrder`, so a user who reaches `joincode` (always via
`pairingChoice`) and taps back lands on `pairingChoice`, not `invite`. The
design's link (`onClick="{{ goInvite }}"`, `Cupid Screens.dc.html:1576`) is a
direct shortcut to `invite` for a user who is actually the code creator and
landed on the wrong branch. `OnboardingRouter.push(context,
OnboardingNode.invite)` already exists and covers this without a new chain
edge.

- **AC5 (joincode, mobile lane):** Given the `joincode` screen, when the user
  taps `Tôi mới là người tạo mã →` / `I am the one with the code →`, then the
  app navigates (push, not reset) to the `invite` screen, matching
  `Cupid Screens.dc.html:1576`.

## Complexity / Lane

Every in-scope AC (AC1-AC5) is a single-lane `mobile` change: 2 copy-only
fixes (AC1, AC2), one UI-only input-widget rebuild that keeps the existing
6-character business logic (AC3), and 2 small additive affordances using
already-available APIs with no new dependency (AC4, AC5). No backend, Tech
Lead, or cross-lane work is required — the one item that could have forced a
cross-lane escalation (joincode's 6-vs-8 character question, 3a) resolved to
"keep the shipped contract as-is, no code change." Per the Lane Consistency
Rule and this requirement's established precedent, `Complexity: trivial`,
`Implementation Lane: mobile`.

## Blocker (2026-08-18) — AC2 conflicts with approved ADR-002

Mobile implementation (`Alex-Mobile-Dev-13`) delivered and verified AC1, AC3,
AC4, AC5 (`flutter test` → `+1284 ~2: All other tests passed!`, 0 failures;
`flutter analyze lib test` → 80 pre-existing `info`-level issues only, none
from new code). AC2 was implemented, found to fail a durable compliance gate,
and reverted so `main` stays green.

Independently verified by Scrum Master against disk (not trusted from the
report alone): `permissions_screen.dart` has zero uncommitted diff (AC2 truly
reverted). `mobile/test/features/reminders/reminder_copy_guard_test.dart:18-22`
bans the literal token `synced alarm` (case-insensitive substring match) in
every `mobile/lib` `.dart` string literal, with an explicit code comment
"do not delete this test to unblock a copy change" (STORY-021's approved
ADR-002 gate). AC2 requires the design source's literal `Synced Alarm`
(`Cupid Screens.dc.html:2452`), which trips this guard.

This is not a new conflict class: `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/req_master.md`
(`Status: PENDING`) already owns the same guard/ADR conflict for a different
token ("Do Not Disturb"), raised as REQ-002 Round 2 review finding E-2 and
routed to the user via `AskUserQuestion` on 2026-08-16, who selected "Route to
PO/UX for a copy ruling." Landing AC2 requires either a PO/UX-approved
alternate copy or a deliberate, documented ADR-002 amendment — both outside
mobile-dev's authority and outside a `trivial` single-lane story's scope.

`mobile/test/features/onboarding/permissions_screen_test.dart` gained two
assertions pinning the current ADR-002-canonical copy (both locales) — an
addition only, verified via diff; whoever executes the eventual AC2/REQ-004
ruling must update these two assertions together with the screen.

Visual-fidelity evidence and the Implementation checkbox are intentionally
not yet produced: the `permissions` screen capture would be invalidated by
the pending AC2 ruling.

**Resolved (2026-08-18):** user selected "Fold AC2 into REQ-004." AC2 is
descoped from STORY-047 (see updated AC2 bullet and header fields above);
`data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/req_master.md`
updated to own both the `Do Not Disturb` and `Synced Alarm` tokens against
the same ADR-002 guard as one PO/UX ruling. STORY-047 now closes on
AC1/AC3/AC4/AC5 only. Remaining before DONE: rendered
`implemented-*`/`design-reference-*` visual-fidelity evidence for `profile`
and `joincode` only (NOT `permissions` — out of scope now), a
`visual-fidelity-report.md` with a `VISUAL_FIDELITY:` marker, and the
Implementation checkbox. Do not re-implement AC2 or delete/weaken the guard
test without an explicit documented ADR-002 decision from REQ-004.
