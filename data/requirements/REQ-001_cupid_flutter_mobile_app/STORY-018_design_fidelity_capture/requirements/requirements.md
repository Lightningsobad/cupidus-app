# Story Requirements: STORY-018 Hardening — Design Fidelity Capture Coverage

Scope: REQ-001 / STORY-018_design_fidelity_capture
Status: PRODUCT_OWNER_COMPLETE

## Confirmed Scope

37/37-screen design-fidelity capture coverage, unchanged from
`story_master.md`. This artifact records the ruling on the story's one open
question (OQ-1, `coding-plan/master-plan.md` §7) — it does not correct or
re-litigate any other part of the story's scope.

## OQ-1 Ruling — The Ten No-Implementation Screens

**Ruling: approved scope cut**, for all ten screens: `otp`, `permissions`,
`vow`, `zodiac`, `themes`, `themedetail`, `sharepick`, `shareedit`,
`shareapprove`, `shareok`.

This does not change any capture work. P8/P10/P11 still render a real
placeholder `implemented-*.png` and record `DEVIATION — screen not
implemented` for all ten, exactly as the plan's default already does — AC1,
AC2, and AC5 are satisfied at 37/37 either way. This ruling only fixes the
*label*: these ten rows are logged as approved scope cuts through this
artifact and the `## Open Question Triage / Approved Scope Change` entry
added to `req_master.md`, not as defects feeding the three deferred code-fix
hardening stories (STORY-006, STORY-008, STORY-016 stay exactly as already
deferred and scoped; nothing is added to them by this ruling).

### Reason

None of the 16 original stories' shipped User Story, In/Out of Scope, or
Acceptance Criteria text ever promised any of these ten screens. This is the
same test STORY-017's triage already applied (entries 1 and 3: approved scope
cut when no AC ever promised the excluded element; entries 2 and 5: confirmed
defect only when an AC's literal wording promised the functionality and it
wasn't delivered). Evidence per screen:

- **`otp`, `permissions`** — STORY-003's own UX spec and Tech Lead ADR-011e
  explicitly placed both downstream of the story ("AC1-AC4 do not mention
  OTP", "UX §2 places the screen downstream of this story";
  `permissions` UX row: "out of this story's scope beyond being the
  `goPermissions` target"). Tech Lead's solution.md explicitly forbids
  `implement local_auth/OTP screen logic` in this story's write scope and
  flags OTP disposition as "a scope confirmation, not a blocker" for Product
  Owner — a flag that never reached the central OQ registry until now, the
  same pattern as STORY-005 D2.
- **`vow`** — STORY-006's UX spec explicitly excludes it: "Out of scope for
  this spec: the `vow` (Fingerprint Vow) screen. Its backend target is
  `POST /users/vow` / `User.vowTaken`... not the `love-contracts` module this
  story owns." Self-flagged as "a separate backend concern" but never
  assigned to any other story's scope.
- **`zodiac`** — not named in any of the 16 stories' User Story, In/Out of
  Scope, or AC text (confirmed by search across every `story_master.md`
  under `data/requirements/REQ-001_cupid_flutter_mobile_app/`). STORY-016
  ships a different, already-implemented element — a read-only, DOB-derived
  zodiac chip on the profile screen — not the standalone "Zodiac Red Flag"
  screen the design canvas depicts under its epic-3 group. No story ever
  committed to that screen.
- **`themes`/`themedetail`** (design canvas: "Kho Theme" / "Chi tiết theme",
  theme-store feature) and **`sharepick`/`shareedit`/`shareapprove`/`shareok`**
  (design canvas: "Chọn mẫu ảnh" / "Xem trước & che" / "Xin phép đăng" /
  "Đã chia sẻ", a share-to-partner-approval flow) — both are visually
  highlighted as distinct groups in the design canvas, separate from the six
  epics `req_master.md` scopes for v1 ("nhóm theo 6 epic backend hiện có...
  epic-1 (core connection) → epic-6 (admin/privacy)"; "Feature theo epic-1 →
  epic-6 (trừ admin/data-export)"). No backend module exists for either
  feature (`backend/src/modules/**` has no theme or share module). Building
  either would require new backend work outside this client-only
  requirement — the same reasoning STORY-013's Open Item #1 (Private Gallery)
  already established as grounds for an approved scope cut.

### No-Further-Scope-Cut Assertion

This ruling covers exactly these ten screen ids and nothing else. It does
not pre-approve any other divergence from `cupid-app-design-system` found by
this story's P10/P11 capture pass or by any future audit.

### Consequence For Downstream Roles

No code-fix hardening story is created for any of these ten ids. If a typed
OTP flow, an app-permissions request screen, a Fingerprint Vow ritual screen,
a theme store, or a share-to-partner flow is ever pursued, each must be
raised as a new backlog item through Scrum Master/Product Owner intake — none
is folded into REQ-001 or implemented as part of STORY-018 or the three
already-deferred STORY-006/STORY-008/STORY-016 hardening stories.

## Open Question Impact

### Scope Items BLOCKED in this story

- Any implementation of `otp`, `permissions`, `vow`, `zodiac`, `themes`,
  `themedetail`, `sharepick`, `shareedit`, `shareapprove`, or `shareok` (all
  ten are ruled approved scope cuts, not defects — see above).
- Any change to `mobile/lib` application/feature code outside the preview
  harness (unchanged from `story_master.md` Out of Scope).
- Fixing any deviation this story's capture pass finds for the other 27
  screens (unchanged from `story_master.md` Out of Scope — deviations feed
  future code-fix hardening stories, not this one).

### Scope Items NOT BLOCKED in this story

- All 37 screens' placeholder/real capture and MATCH/DEVIATION verdict
  recording (`story_master.md` AC1-AC6), including placeholder captures and
  `DEVIATION — screen not implemented` rows for the ten screens ruled above.
- P11's report labeling those ten rows as approved scope cuts (citing this
  artifact and the corresponding `req_master.md` OQ Triage entry), rather
  than as defects.

## Implementation Lane

Shared (unchanged from `story_master.md`). This ruling adds no new
implementation scope to STORY-018 or to any other story.
