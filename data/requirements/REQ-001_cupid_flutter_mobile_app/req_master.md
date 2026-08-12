# Requirement Master: REQ-001 Cupid Flutter Mobile App (iOS + Android)
Status: IN_PROGRESS — reopened 2026-08-12 for RED-PATCH retro-audit hardening
(see `## Retro Audit` below). Prior state: all 16 original stories DONE and
merged into `codex/REQ-001_cupid_flutter_mobile_app-integration`; requirement
integration review `Outcome: CLEAN`; all 5 integration bugs
(BUG-20260801-001..005) DONE, Reviewer `Outcome: CLEAN` on each, independently
confirmed by Scrum Master; Integration Build & Runtime evidence gate CLEAN
(`flutter build apk --debug` exit 0, `flutter test` 880 passed / 2
pre-existing out-of-scope failures). See
`data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/review-report.md`
for full evidence. Will return to `DONE` once all hardening stories for this
retro-audit cycle are `DONE` with Reviewer approval, per
`shared-verdict-and-plan.md`.

## Retro Audit

- Date: 2026-08-12
- Verdict: **RED-PATCH — CONFIRMED** (user-confirmed 2026-08-12), full detail
  in `data/requirements/REQ-001_cupid_flutter_mobile_app/retro-audit/audit-report.md`.
- Basis: requirement-wide Design Fidelity FAIL (reused, not recaptured,
  evidence — 2/37 screens fully compared, both FAIL; 27/37 never captured),
  4 confirmed AC FAILs (STORY-006 AC2/AC3, STORY-008 AC2, STORY-016
  AC2/AC3), and 6 confirmed unapproved scope/traceability gaps (STORY-005 D2,
  STORY-006 OQ-006A, STORY-008 ADR-3, STORY-013 Open Item #1, STORY-014
  wish-list/savings-jar, STORY-016 AC2/AC3 rescope).
- Hardening plan (user-confirmed 2026-08-12): STORY-017 (Product-Owner OQ/
  scope triage, must complete first) then STORY-018 (Design Fidelity capture
  coverage, 37/37 screens). Code-fix hardening stories for STORY-006
  (partner visibility), STORY-008 (GhostStateRow mount), and STORY-016
  (privacy/notification capability) are deliberately **not yet created** —
  they are scoped once STORY-017's dispositions and STORY-018's complete
  MATCH/DEVIATION report are available, so scope is not guessed from the
  current partial (2/37 fully reviewed) evidence.

## Open Question Triage / Approved Scope Change

Retro-audit-driven Product Owner triage (STORY-017). Source for all six
entries below: `data/requirements/REQ-001_cupid_flutter_mobile_app/retro-audit/audit-report.md`
(Audit Date 2026-08-12, Overall Verdict RED-PATCH — CONFIRMED, user-confirmed
2026-08-12), "Overall Substantive Verdict" / "Audit Classification" sections.
Ruling date for every entry: 2026-08-12.

### 1. STORY-005 D2 — invite screen couple-type picker + "Continue → Fingerprint Vow" CTA
- Affected OQ: none was ever registered — the exclusion was a story-level
  self-approval (UX §7 / master-plan §1) that never reached the central OQ
  registry or this section. This entry retroactively opens and closes that OQ.
- Ruling: **approved scope cut** (not deferred to a code-fix story). The
  design source's couple-type picker and the invite→"Fingerprint Vow" CTA
  chain are excluded from the invite screen for v1. STORY-006 (love
  contracts) remains the sole entry point to the vow/contract ritual.
- No-further-scope-cut assertion: this is the only approved narrowing of
  STORY-005's invite flow. It does not pre-approve any other divergence from
  `cupid-app-design-system` found in future audits.
- Changed AC: AC text unchanged, cut ruled out of scope. STORY-005's AC1-AC4
  never promised the couple-type picker or the CTA chain, so no AC edit is
  required.
- Reason: the excluded picker/CTA duplicates functionality STORY-006 already
  owns; chaining invite acceptance directly into the vow ritual was an
  onboarding-flow enhancement beyond STORY-005's pairing-only scope, not a
  backend-contract gap.
- Source/date: `retro-audit/audit-report.md`, Audit Date 2026-08-12; ruling
  recorded 2026-08-12.
- Blocked/unblocked scope: no code-fix hardening story is created for this
  item. STORY-005 is confirmed as final v1 scope as shipped.

### 2. STORY-006 OQ-006A — dual-signature contract ritual reduced to creator-only capability
- Affected OQ: OQ-006A (dual-signature contract ritual), previously only
  tracked at story level, never centrally triaged.
- Ruling: **not an approved scope cut** — confirmed build defect against an
  AC that was already correct. STORY-006 AC2 ("The partner can view and
  acknowledge/accept it per the backend's supported flow") already required
  partner view + acknowledge/accept; the shipped creator-only capability
  fails AC2 outright (the audit found the partner cannot even view the
  contract). No scope is being cut here; the audit's AC2 FAIL finding is
  upheld.
- No-further-scope-cut assertion: no further narrowing of AC2/AC3 is
  approved. The dual-signature ritual (both partners can view AND
  acknowledge/accept) remains the approved contract-level scope.
- Changed AC: AC text unchanged, cut ruled out of scope — AC2 stands exactly
  as written.
- Reason: the shipped creator-only capability is a build defect against an
  already-correct AC, not a scope decision requiring an AC correction.
- Source/date: `retro-audit/audit-report.md`, Audit Date 2026-08-12; ruling
  recorded 2026-08-12.
- Blocked/unblocked scope: this ruling unblocks the STORY-006 partner-
  visibility code-fix hardening story referenced in `## Retro Audit`. That
  story must implement AC2/AC3 exactly as written (partner view +
  acknowledge/accept) — no further PO decision is required before it starts.

### 3. STORY-013 Open Item #1 — shared/backend gallery model vs. design source "Private Gallery" concept
- Affected OQ: none was ever registered — the story's own UX spec cited the
  sibling DND/Critical-Alerts conflict as the precedent this one should have
  followed (escalate to PO/req_master) and didn't.
- Ruling: **approved scope cut**. The shared/backend `gallery` model (upload
  + both-partner view, contract-frozen per A1) is confirmed as final v1
  scope. The design source's "Private Gallery" (device-encrypted,
  single-partner) concept is cut from v1.
- No-further-scope-cut assertion: only the Private Gallery concept is cut; no
  other gallery scope narrowing is pre-approved by this ruling.
- Changed AC: AC text unchanged, cut ruled out of scope — STORY-013's AC1-3
  already describe the shared model as shipped.
- Reason: A1 freezes the backend contract; the shared `gallery`/`uploads`
  endpoints have no device-encrypted single-partner mode, and building one
  would require a backend change that is out of scope for this client-only
  requirement.
- Source/date: `retro-audit/audit-report.md`, Audit Date 2026-08-12; ruling
  recorded 2026-08-12.
- Blocked/unblocked scope: no code-fix hardening story is created for this
  item. A device-encrypted "Private Gallery" concept, if ever pursued,
  requires a new backend-contract change and is out of scope for REQ-001; it
  may be captured as a future brainstorm idea, not a REQ-001 story.

### 4. STORY-014 wish-list-vs-savings-jar reinterpretation
- Affected OQ: the open Product Owner item STORY-014's own
  `story_master.md` § "Open Items For Downstream Roles" raised (AC wording
  vs. shipped feature, plus the epic-4/epic-5 tag question), never centrally
  triaged.
- Ruling: **contract/wording correction**, not a scope cut. The shipped
  feature (a shared monetary VND savings-jar contribution, matching the
  frozen `dream-jar` backend contract and the design source) is confirmed as
  the correct v1 feature. STORY-014's User Story and AC1 wording ("dream/wish
  entry") is corrected to match.
- Changed User Story (verbatim):
  - Before: "As a paired couple, we want a shared 'dream jar' where we can
    each drop in wishes/dreams for our relationship, so we build a
    collection of shared aspirations over time."
  - After: "As a paired couple, we want a shared savings jar where we can
    each contribute money toward a shared relationship goal, so we build
    shared savings over time."
- Changed AC1 (verbatim):
  - Before: "A paired user can add a dream/wish entry to the shared jar."
  - After: "A paired user can contribute a monetary (VND) amount to the
    shared savings jar."
  - AC2 and AC3 are unchanged in substance (both partners can view the jar's
    contents; unpaired users cannot access this feature).
- Epic-4/epic-5 tag: **reconciled as epic-4 (intimacy/memories)**, unchanged.
  Reason: although contributions are monetary, the feature's purpose is a
  couple's shared aspirational goal, materially different from STORY-015's
  general shared-expense tracking (epic-5); the `dream-jar` backend module
  name and its design-source framing support keeping it grouped with
  intimacy/memories.
- No-further-scope-cut assertion: this is a wording correction only; no
  functional scope is added or removed.
- Reason: the story's own Tech Lead and UX flagged this mismatch during
  implementation (`coding-plan/master-plan.md` §2); it was never corrected in
  the canonical AC text.
- Source/date: `retro-audit/audit-report.md`, Audit Date 2026-08-12; ruling
  recorded 2026-08-12.
- Blocked/unblocked scope: no code-fix hardening story required — this ruling
  is a documentation correction matching text to already-shipped,
  already-reviewed (Reviewer `Outcome: DEFERRED_ONLY`) behavior.

### 5. STORY-016 AC2/AC3 rescope — privacy view-only, notifications device-local-only
- Affected OQ: none was ever registered for this reduction.
- Ruling: **not an approved scope cut** — confirmed build defect /
  traceability gap, same pattern as STORY-006. AC2 as written promises "view
  and change privacy settings exposed by the backend contract" — shipped as
  view-only (no editable control beyond STORY-008's ghost-mode field). AC3 as
  written promises "view and change notification settings exposed by the
  backend contract" — shipped as device-local-only with no backend contract
  at all.
- No-further-scope-cut assertion: no further narrowing of AC2/AC3 is
  approved; both remain as literally written.
- Changed AC: AC text unchanged, cut ruled out of scope.
- Reason: the shipped view-only privacy control and device-local-only
  notifications are build defects against already-correct ACs, not scope
  decisions requiring AC correction.
- Source/date: `retro-audit/audit-report.md`, Audit Date 2026-08-12; ruling
  recorded 2026-08-12.
- Blocked/unblocked scope: this ruling unblocks the STORY-016 privacy/
  notification capability code-fix hardening story referenced in
  `## Retro Audit`. That story must implement AC2 (editable privacy) and AC3
  (backend-contract-backed notifications) exactly as written — no further PO
  decision is required before it starts.

### 6. REQ-001 AC-coverage gap — no AC in any of the 16 original stories asserts design-source conformance
- Affected OQ: requirement-wide traceability gap between this file's
  `## Problem / Value` design-source commitment and the 16 original stories'
  60 ACs, none of which assert conformance to `cupid-mobile-design/`.
- Ruling: **design-conformance acceptance criteria are added at the
  requirement level** — this is not a narrowing of the Problem/Value
  design-source commitment. Retroactively adding a per-screen design-
  conformance AC to each of the 16 already-DONE stories' `story_master.md`
  would invent new implementation scope without a corresponding fix path, so
  the gap is closed once, at the requirement level, below.
- New requirement-level AC (see `## Design Conformance Acceptance Criterion`
  added below): every mobile screen shipped under REQ-001 must be captured
  and compared against its corresponding `cupid-mobile-design/` screen, and
  any DEVIATION must be fixed or explicitly ruled an approved scope cut
  through this same OQ Triage / Approved Scope Change mechanism — not
  silently shipped.
- No-further-scope-cut assertion: does not apply — this entry adds coverage,
  it does not cut scope.
- Changed AC: new AC added (`## Design Conformance Acceptance Criterion`,
  below); no existing story AC is edited by this ruling.
- Reason: STORY-018 (Hardening — Design Fidelity Capture Coverage, already
  created, `RETRO_PENDING`) is the vehicle that produces the 37/37-screen
  MATCH/DEVIATION evidence this new AC requires; no new story is invented by
  this ruling.
- Source/date: `retro-audit/audit-report.md`, Audit Date 2026-08-12; ruling
  recorded 2026-08-12.
- Blocked/unblocked scope: this ruling does not block or unblock STORY-018 —
  STORY-018 was already created and scoped independently. Any DEVIATION
  STORY-018's report finds becomes a new confirmed gap requiring its own
  future entry in this same section, not an automatic code-fix.

### 7. STORY-018 OQ-1 — ten design-canvas screens with no mobile implementation at all

- Affected OQ: OQ-1, `STORY-018_design_fidelity_capture/coding-plan/master-plan.md`
  §7 — raised during STORY-018 planning, ruled here per that section's request
  for a Product Owner ruling before P11.
- Ruling: **approved scope cut** for all ten screens: `otp`, `permissions`,
  `vow`, `zodiac`, `themes`, `themedetail`, `sharepick`, `shareedit`,
  `shareapprove`, `shareok`. Full ruling and per-screen evidence:
  `STORY-018_design_fidelity_capture/requirements/requirements.md`.
- No-further-scope-cut assertion: this ruling covers exactly these ten screen
  ids. It does not pre-approve any other divergence from
  `cupid-app-design-system` found by STORY-018's capture pass or by any future
  audit — any other DEVIATION STORY-018 reports still requires its own future
  entry in this section, per entry 6 below.
- Changed AC: AC text unchanged in all 16 original stories and in STORY-018.
  STORY-018 AC1/AC2 already require a real `implemented-*.png` and a recorded
  verdict for all 37 screens including these ten (satisfied via placeholder
  capture + `DEVIATION — screen not implemented`, per master-plan.md §3);
  this ruling only fixes how those ten rows are labeled in the P11 report.
- Reason: none of the 16 original stories' shipped User Story, In/Out of
  Scope, or Acceptance Criteria text ever promised any of these ten screens.
  `otp`/`permissions` were explicitly placed downstream of STORY-003 by its
  own UX spec and Tech Lead ADR-011e ("AC1-AC4 do not mention OTP"); `vow` was
  explicitly excluded from STORY-006 as "a separate backend concern"
  (`POST /users/vow`) never assigned elsewhere; `zodiac` is not named in any
  story's scope at all (STORY-016 ships only an unrelated, already-implemented
  read-only zodiac chip); `themes`/`themedetail` (theme store) and
  `sharepick`/`shareedit`/`shareapprove`/`shareok` (share-to-partner-approval
  flow) sit outside the six backend-driven epics this file scopes for v1
  (`epic-1 → epic-6`, see § below) and have no backend module at all, matching
  the STORY-013 Private Gallery precedent (entry 3, above).
- Source/date: STORY-018 OQ-1 ruling, 2026-08-12.
- Blocked/unblocked scope: no code-fix hardening story is created for any of
  these ten ids. STORY-006, STORY-008, and STORY-016's already-deferred
  code-fix hardening stories are unaffected — nothing is added to their scope
  by this ruling. If a typed OTP flow, an app-permissions request screen, a
  Fingerprint Vow ritual screen, a theme store, or a share-to-partner flow is
  ever pursued, each must be raised as a new backlog item through Scrum
  Master/Product Owner intake, not folded into REQ-001.

## Design Conformance Acceptance Criterion
Added 2026-08-12 by STORY-017 (Open Question Triage / Approved Scope Change
entry 6, above), to close the requirement-wide AC-coverage gap the retro-audit
found.
- Every mobile screen shipped under REQ-001 must be captured and compared
  against its corresponding `cupid-mobile-design/` screen (Design Fidelity
  evidence).
- Any DEVIATION found must be either fixed or explicitly ruled an approved
  scope cut through the `## Open Question Triage / Approved Scope Change`
  mechanism above — it must never be silently shipped.
- Coverage baseline: STORY-018's 37/37-screen MATCH/DEVIATION report.

## Deployment Status
- Development Environment: **DEPLOYED** (2026-08-01). Final DevOps redeploy
  ran end-to-end against `main` HEAD `6e79d90`, which contains the
  integration->main merge (merge commit
  `239b2116b4d4b793e2a635fb79fa3e579448ad81`) plus the two readiness-gate
  bugfixes `BUG-20260801-006` (`c71875f`) and `BUG-20260801-007` (`6e79d90`):
  - `scripts/setup.sh` PASS (Postgres/Redis on `127.0.0.1:15432` /
    `127.0.0.1:16379`, project `cupid-apps`).
  - `scripts/build.sh` PASS — real 223.4 MB `app-debug.apk` built from the
    full merged 16-story source, plus `backend/dist`.
  - `scripts/start-dev.sh` PASS — backend ready (`GET /api-docs-json` 200 at
    `http://127.0.0.1:3005`) and mobile `flutter test` **890 passed / 0
    failed**, so the readiness gate cleared and the script reached
    `Local dev environment is up`. The previously blocking
    `MOBILE_READINESS_GATE_FAILS_ON_KNOWN_TESTS` is resolved; the gate was
    fixed, never relaxed or bypassed.
  - No persistent endpoint — dev-local only; the backend was live-verified
    during the bounded run and then stopped. Launching the app itself still
    needs an interactive `flutter run` with a connected device/emulator, by
    design of the registry's `mobile-app` runtime.
  See `deployment/deployment-log.md` § Latest Attempt / § History.
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Source
- Brainstorm idea: `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/idea.md`
  - `## Handoff Package → scrum-master`
  - `## Quyết Định Đã Chốt (2026-07-29)` (D0-D5)
  - `## Bối Cảnh Đã Có (Đặc Tả Nguồn)`
- Brainstorm development log: `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/development.md`
  - `## Convergence Notes` (bảng Impact/Effort rủi ro)
  - `## Open Questions` (OQ4, OQ5 còn mở)
- Design source (read-only, không sửa): `cupid-mobile-design/`
- Backend source (đã hoàn thiện, contract đóng băng — A1): `backend/src/modules/`, Swagger `/api-docs` (`backend/src/main.ts`)
- Kiến trúc client cũ (SUPERSEDED): `_bmad-output/planning-artifacts/architecture.md`

## Problem / Value
Xây ứng dụng mobile Cupid (couple-only, 1:1 pairing) bằng **Flutter** cho cả
iOS và Android, tiêu thụ backend NestJS đã hoàn thiện (~59 REST endpoint, 2
Socket.IO gateway, Firebase Auth), hiện thực đúng bộ design đã chốt tại
`cupid-mobile-design/` (~31 màn, 2 bản iOS/Material, dark + light, VI + EN).
Thay thế quyết định client cũ (iOS Native Swift/SwiftUI) đang khoá sản phẩm
vào 1 platform và không khớp bộ design đã vẽ sẵn cả 2 platform.

## Trong phạm vi
- ~31 màn theo prototype `cupid-mobile-design/` (`Cupid Screens.dc.html`),
  nhóm theo 6 epic backend hiện có: epic-1 (core connection), epic-2
  (communication), epic-3 (daily engagement), epic-4 (intimacy/memories),
  epic-5 (finance), epic-6 (admin/privacy — chỉ phần có màn mobile).
- Nền tảng client: design system + token (platform × theme), i18n (mặc định
  `vi`, có `en`), API client sinh từ OpenAPI (`/api-docs`), auth Firebase +
  refresh token, tầng realtime Socket.IO.
- Kênh realtime: chat (typing-ghost 2 chiều), anti-ghosting, nhắc nhở đồng bộ
  (xem đổi từ ngữ epic-3 ở mục Ghi chú bắt buộc).

## Ngoài phạm vi
- Module `admin` và `data-export` (không có màn design cho mobile — web
  admin / API-only).
- Báo thức cấp hệ thống / Critical Alerts entitlement (D1 hoãn khỏi v1).
- Thay đổi contract backend (A1: backend đóng băng, không đổi vì client).

## Ràng buộc kiến trúc đã chốt (D0-D5) — cho tech-lead viết ADR, không khám phá lại option space

| # | Quyết định | Nội dung | Hệ quả chính |
|---|-----------|----------|--------------|
| D0 | Client | Flutter, thay iOS Native (SwiftUI) | `_bmad-output/planning-artifacts/architecture.md` phần client = SUPERSEDED |
| D1 | Báo thức | v1 chỉ cần thông báo nhắc đủ mạnh, không cần báo thức thật | Không xin Critical Alerts, không viết module alarm native. Epic-3 đổi từ ngữ "báo thức" → "nhắc nhở đồng bộ" |
| D2 | State management | Bloc (Cubit cho màn CRUD, Bloc đầy đủ cho nghi thức + realtime) | Kèm `freezed` + `get_it`/`injectable`; `bloc_test`, cân nhắc `hydrated_bloc` |
| D3 | Adaptive UI | Bám design, giữ 2 bản iOS/Material | 1 cây widget + `ThemeExtension` (platform × theme) + 4 widget adaptive có tên, không fork màn hình |
| D4 | Archetype | Pragmatic Feature-First, 1 package (hội tụ qua PMI) | Hoãn melos monorepo và Pigeon tới khi thực sự cần |
| D5 | API client | Sinh từ OpenAPI (Swagger đã bật ở `backend/src/main.ts`, `/api-docs`) | Xoá phần lớn data layer viết tay; khoá contract client–server |

Chi tiết đầy đủ và lý do hội tụ: `idea.md` → `## Quyết Định Đã Chốt (2026-07-29)`
và `development.md` → mục 41-54 (`PMI`).

## Ghi chú bắt buộc cho breakdown / tech-lead (không được bỏ sót)

1. **`design_system` phải là story shared-foundation đầu tiên** — token
   (platform × theme, 4 tổ hợp) + i18n ARB (VI/EN). Làm sau sẽ phải sửa lại
   cả 31 màn (rủi ro R7: impact cao, effort thấp).
2. **Spike `RealtimeCoordinator` sớm** — hợp nhất Socket.IO + FCM (đường đôi
   foreground/background) là rủi ro số 1 sau khi chốt kiến trúc (R2, impact
   cao), không phải báo thức.
3. **Product Owner đổi từ ngữ epic-3**: "báo thức đồng bộ" → "**nhắc nhở
   đồng bộ**" trong mọi story/AC của epic-3 — hệ quả trực tiếp của D1, để
   không hứa quá với người dùng.

## Rủi ro bàn giao (bảng Impact/Effort đầy đủ ở `development.md` → `## Convergence Notes`)

| Rủi ro | Impact | Effort giảm thiểu | Hành động đề xuất |
|--------|--------|-------------------|-----------|
| R2 socket/FCM | Cao | Trung | Spike `RealtimeCoordinator` trước tiên |
| R7 design_system làm sau | Cao | Thấp | Story nền tảng đầu tiên, trước mọi feature |
| R6 kỷ luật Bloc/Cubit | Trung | Thấp | Chốt quy ước + lint trong ADR |
| R3 libsodium FFI | Trung | Trung | Spike build 2 platform sớm, trước epic-4 |
| R4 perf Android low-end | Trung | Thấp | Đo trên 1 máy Android low-end mốc |
| R1 alarm (đã hạ) | Thấp | Thấp | Chỉ cần PO chỉnh từ ngữ epic-3 |
| R5 trôi UI | Thấp | Thấp | Golden test atoms + ~6 màn tiêu biểu |

## Open Questions chưa giải quyết

- **OQ4 — Offline**: dùng Drift (SQLite, query thật) cho
  chat/timeline/expenses, hay chỉ dựa `hydrated_bloc` cho v1? Giả định tạm:
  Drift cho 3 miền có lịch sử dài, `hydrated_bloc` cho state phù du. Cần
  tech-lead xác nhận trong ADR.
- **OQ5 — Light theme & i18n EN có nằm trong v1 không?** Design đã vẽ cả 2.
  Giả định tạm: hạ tầng token + ARB làm ngay từ đầu, nhưng chỉ **bật**
  dark + vi ở v1. Product Owner cần quyết khi breakdown story (đặc biệt story
  `design_system`).

Nguồn đầy đủ: `development.md` → `## Open Questions`.

## Thứ tự nền tảng đề xuất (mức khám phá, không ràng buộc — tech-lead xác nhận lại trong coding-plan)

1. `design_system` + token (platform × theme) + i18n ARB — shared-foundation,
   trước mọi feature (R7).
2. `api_client` sinh từ OpenAPI `/api-docs` (D5).
3. Auth Firebase + interceptor refresh token.
4. Spike `RealtimeCoordinator` (hợp nhất Socket.IO + FCM) — R2, rủi ro cao
   nhất.
5. Feature theo epic-1 → epic-6 (trừ admin/data-export).

## Khoảng trống đã nhận diện (từ brainstorm, cần soi lại ở tech-lead/PO)

- Không có màn design cho `admin` và `data-export` → 2 module này ngoài phạm
  vi mobile.
- Design có `me`, `privacy`, `notifs` nhưng cần soi lại endpoint tương ứng
  khi vào tech-lead.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Design system: platform x theme tokens + i18n ARB infra | L | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/story_master.md |
| STORY-002 | API client generated from OpenAPI (`/api-docs`) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/story_master.md |
| STORY-003 | Auth: Firebase sign-in + refresh-token interceptor | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/story_master.md |
| STORY-004 | Spike: RealtimeCoordinator (Socket.IO + FCM dual path) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-004_realtime_coordinator_spike/story_master.md |
| STORY-005 | Epic-1: Pairing / 1:1 connection (invitations) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-005_pairing/story_master.md |
| STORY-006 | Epic-1: Love contracts / nghi thức cam kết | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-006_love_contracts/story_master.md |
| STORY-007 | Epic-2: Chat (2-way typing-ghost, realtime) | L | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-007_chat/story_master.md |
| STORY-008 | Epic-2: Anti-ghosting configuration | S | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-008_anti_ghosting/story_master.md |
| STORY-009 | Epic-3: Nhắc nhở đồng bộ | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-009_nhac_nho_dong_bo/story_master.md |
| STORY-010 | Epic-3: Vibes / cảm xúc hằng ngày | S | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-010_vibes/story_master.md |
| STORY-011 | Epic-3: Bun Pet đồng hành | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-011_bun_pet/story_master.md |
| STORY-012 | Epic-4: Timeline kỷ niệm | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-012_timeline/story_master.md |
| STORY-013 | Epic-4: Gallery ảnh chung | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/story_master.md |
| STORY-014 | Epic-4: Dream Jar / hũ ước mơ chung | S | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-014_dream_jar/story_master.md |
| STORY-015 | Epic-5: Chi tiêu chung (expenses) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/story_master.md |
| STORY-016 | Epic-6: Hồ sơ / quyền riêng tư / thông báo (mobile-only) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-016_profile_privacy_notifs/story_master.md |
| STORY-017 | Hardening - OQ/Scope Triage (retro-audit RED-PATCH) | standard | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-017_oq_scope_triage/story_master.md |
| STORY-018 | Hardening - Design Fidelity Capture Coverage (retro-audit RED-PATCH) | standard | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/story_master.md |
