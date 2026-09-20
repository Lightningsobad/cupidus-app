# Review Slice S2 — P2 domain/repository + P7 ActivityType

- Story: STORY-001 (REQ-016), slice 2 of 8 (scope-gate.md § Prescribed Slice Plan)
- Reviewer: Iris-QC
- Date: 2026-09-08
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Diff baseline: `9207f7296a64cd37ca60e432939469ca96860762`
- AC source of truth: `requirements/requirements.md` (per scope-gate ruling)
- Owns: FLAG-1 first half — contract surface for field writes

All 9 in-scope source/test files are net-new since BaseHead (`git diff --stat`
shows insertions only, no modified pre-existing lines).

## 1. AC-numbering verification

S1 warned that the scope gate's Query Keys carry `story_master.md` numbering.
Checked all three labels this slice was handed against `requirements.md`:

| Scope-gate label | `requirements.md` reality | Verdict |
|---|---|---|
| AC-4 | `requirements.md:87-89` — AC-4 is the Phút-1 "1–2 thẻ trong vòng 60 giây" timing criterion, a P4/P5 empty-state concern. The P2 create-contract criterion is **AC-6** (`requirements.md:97-99`, "một trường bắt buộc duy nhất là tiêu đề"). | **DRIFT — use AC-6** |
| AC-7 | `requirements.md:101-104` — link kept verbatim, card still creates without preview. | correct as labeled |
| AC-15 | `requirements.md:149-151` — rollback must not silently drop ngày hẹn/ghi chú/ảnh. | correct as labeled |

The drift is independently corroborated inside the story's own artifacts:
`phase-P2-card-domain-repository.md:89` and the test file itself
(`activity_card_repository_test.dart:27`, group `createCard tối thiểu (AC-6)`)
both use AC-6. So the implementation followed `requirements.md`; only the scope
gate's key list drifted. S8 should re-key the S2 row to AC-6/AC-7/AC-15 and
treat AC-8, AC-9, AC-12, AC-14, AC-17 as additionally in P2's contract blast
radius (`phase-P2...md:49` names AC-6/7/9/11/12/14/15 + BR-2/BR-13).

## 2. Critical gates

| # | Gate (source) | Result | Evidence |
|---|---|---|---|
| G1 | Shared contract §2 identifiers stable/ASCII/append-only for 11 downstream stories | **PASS** | 4 status + 3 origin + 2 reply + 2 indoor/outdoor + 8 ActivityType wire values match `contract-summary.md:32-38` literally; pinned by literal-string assertions in `activity_card_status_test.dart:5-51` and `activity_type_test.dart:90-101`, so a rename breaks the build (R-15a). |
| G2 | Shared contract §1 single write door (`createCard`) | **PASS** | `activity_card_repository.dart:10`; `NewActivityCard` requires only `title`+`origin` (`activity_card.dart:142-171`), matching `contract-summary.md:20-23`. |
| G3 | Shared contract §3 field set complete for 11 downstream stories | **FAIL** | `activity_cards` columns are all present, but the photo half of §3 (`contract-summary.md:78-80`) is unreachable from the contract. See F2-1. |
| G4 | P7 must not touch `schemaVersion` (master-plan §6, `contract-summary.md:100-101`) | **PASS** | `activity_type_test.dart:172-179` asserts `schemaVersion == 3` and that `activity_type` stays `DriftSqlType.string` + nullable; `test-results.md:636-639` shows the codegen diff is 35+/35− confined to the converter, no DDL, no migration step. `activity_cards_table.dart:64-65` maps the converter onto the existing `text().nullable()` column. |
| G5 | P7 lenient read — pre-vocabulary free-text rows survive | **PASS** | `activity_type.dart:34-44` returns `null` instead of throwing; `ActivityTypeConverter.fromSql` delegates to it (`activity_cards_table.dart:21`); `activity_type_test.dart:155-170` writes `'chiều'` by raw SQL and proves the row still reads with other fields intact. |
| G6 | AC-15 — no silent data loss on status rollback (**P2 half**; master-plan §3A binds AC-15 to P2+P6) | **PASS** | `updateStatus` writes a companion carrying only `status` (`activity_card_repository_impl.dart:110-118`); `clearScheduledDate` is a separate explicit mutation writing only `scheduled_on` (`:120-128`). The 4×4 matrix test walks all 16 ordered pairs and asserts `scheduledOn`, `note`, `priceVnd`, `distanceKm`, `needsBooking`, `indoorOutdoor`, `invited`, `replyState` all survive every transition including regressions (`activity_card_repository_test.dart:98-155`). P6 half (asking the user) belongs to S6. |
| G7 | SC-4 / AC-11 — exactly one primary action per status | **PASS** | `primaryActionFor` is a total switch over `ActivityCardStatus` (`activity_card.dart:77-88`); tested total, SC-4-exact, and injective (`activity_card_status_test.dart:53-84`). |
| G8 | AC-7 — link kept verbatim, graceful title degradation, no network | **PASS** | `_resolveTitle` derives the host only when title is blank and never calls out (`activity_card_repository_impl.dart:149-162`); `activity_card_repository_test.dart:68-96`. |
| G9 | AC-22 — card store is not a `SessionScopedStore` | **PASS** | `service_locator.dart:305-319` registers plainly, with the reasoning in-comment; P1 already pins the behaviour (`test-results.md:46-47`). |
| G10 | P7 icon coverage for D-5 | **PASS** | `activityTypeIcon` is a total switch (`activity_type.dart:53-75`); all 9 tokens exist with cmap-confirmed codepoints in `cupid_icons.dart` (`:98,:165,:302,:310,:315,:320,:328,:337,:343`); per-member glyph assertions in `activity_type_test.dart:182-198`. |
| G11 | P2 test evidence recorded per `phase-P2...md` §5/§6 | **FAIL** | No `Phase P2` section exists in `test-results.md`. See F2-6. |

## 3. FLAG-1 — contract surface for field writes (ground truth for S6)

**Classification deliberately withheld.** Per the handoff and rule 14, the
PATCH_REQUIRED/deferred verdict belongs to S6, which reviews P6's actual usage.
This section establishes only what the contract exposes.

### 3.1 Complete public surface

`ActivityCardRepository` (`activity_card_repository.dart:7-45`) declares exactly
8 members. `ActivityCardRepositoryImpl` (`activity_card_repository_impl.dart:16-134`)
declares exactly the same 8 as `@override` and adds no public member of its own
(`_requireOwnerKey`, `_resolveTitle`, `_toDomain` are private; `_newUuidV4` is a
private library function).

Reads (4):

| Method | Line |
|---|---|
| `cardsByStatus({status, limit, offset})` | `:13-17` |
| `watchCardsByStatus({status, limit, offset})` | `:20-24` |
| `cardById(String id)` | `:26` |
| `countsByStatus()` | `:30` |

Writes (4) — this is the entire mutation surface:

| Method | Line | Columns it can write |
|---|---|---|
| `createCard(NewActivityCard draft)` | `:10` | INSERT only. Sets every field once at creation, incl. `scheduled_on`. Forces `status=idea`, `invited=false`, `reply_state=not_answered` (`impl:40,49,50`). |
| `updateStatus(String cardId, ActivityCardStatus status)` | `:36` | `status` **only** (`impl:113-117`) |
| `clearScheduledDate(String cardId)` | `:40` | `scheduled_on := NULL` **only** (`impl:123-127`) — it can clear, it cannot set |
| `deleteCard(String id)` | `:44` | row delete |

### 3.2 Direct answer to the handoff's question

**A scheduled-date edit made in the P6 detail screen has no path to reach this
repository.** There is no `setScheduledDate`, no `updateCard`, no
`updateFields`, and no overload of any existing method that accepts a
`scheduled_on` value. `clearScheduledDate` writes a hard `Value(null)`
(`impl:126`) and takes no date argument. The only method that can ever put a
non-null value into `scheduled_on` is `createCard`, at insert time. Therefore a
date chosen on an existing card can only live in detail-cubit memory.

The same holds for **every other mutable field**: `title`, `note`, `priceVnd`,
`distanceKm`, `needsBooking`, `indoorOutdoor`, `activityType`, `sourceLink`,
`invited`, and `replyState` have no post-creation write path at all.

Corroboration from the implementer's own P6 record (`test-results.md:881-891`),
which reached the identical conclusion independently: *"Hợp đồng repository của
P2 chỉ có `updateStatus`, `clearScheduledDate`, `deleteCard`, `createCard` —
không có `setScheduledDate` và không có hàm ghi trường tổng quát... cubit giữ
bản làm việc trong bộ nhớ cho mọi sửa trường (kể cả ngày đã chọn ở AC-12)...
ngày hẹn và các sửa trường không sống qua lần mở lại màn."* It also names an
existing precedent for the same hole one column over:
`ActivityCardListState.replyOverrides` for `reply_state`.

### 3.3 Attribution — the gap originates in the plan, not the code

`phase-P2-card-domain-repository.md:81-82` prescribes exactly
`updateStatus(cardId, status)` "chỉ ghi cột `status`" plus a separate
`clearScheduledDate(cardId)`, and prescribes no field-write method anywhere in
§3 or §4. `contract-summary.md:13-18` likewise declares `createCard` the *"cửa
ghi duy nhất cho story sau"*. The implementation matches its plan and its
contract line for line. Whatever S6 decides, the corrective work lands on the
contract/plan, not on a coding defect in these three files.

### 3.4 Downstream AC exposure S6/S8 should weigh

Stated as fact, not as a verdict:

- **AC-12** (`requirements.md:135-137`) requires a *Mới nghĩ ra* card whose
  primary action is used to "đặt một ngày hẹn" to move to *Đã hẹn ngày*. Only
  the status half is persistable through this contract.
- **AC-17** (`requirements.md:159-161`) requires the đã/chưa trả lời flag to
  change on the user's own tap. No method writes `reply_state` or `invited`.
- **AC-8** (`requirements.md:106-109`) requires the detail screen to support all
  structured fields; none are editable post-creation through this contract.
- **BR-13** (`requirements.md:232-234`) requires the model to carry the AC-8
  fields in this story because 12 later stories read *and write* on it. The read
  half holds; the write half does not.

## 4. Other findings

| ID | Severity | Location | Finding |
|---|---|---|---|
| F2-1 | HIGH | `activity_card.dart:93-136`, `activity_card_repository.dart:7-45` | **Photos are absent from the contract.** AC-8 (`requirements.md:106-109`) lists "ảnh/ký ức" among the fields the card must support, AC-15 names "ảnh" as data that must not vanish on rollback, and `contract-summary.md:25,78-80` makes `activity_card_photos` part of the store with a defined column set. But `ActivityCard` has no photos member and the repository has no photo method (no read, no add, no remove). The rows are reachable only through `ActivityCardDao.photosForCard`/`upsertPhoto`, which is not the declared consumer surface. STORY-007 ("ghi lại kỷ niệm") has no contract path to them. BR-13 requires this in *this* story. |
| F2-2 | MEDIUM | `activity_card_repository_impl.dart:110-128` vs `activity_card_repository.dart:12`, `activity_card_dao.dart:108-110` | **Status writes do not bump `updated_at`, but panes are ordered by it.** `updateStatus`/`clearScheduledDate` pass a companion containing only their one column, and the DAO's `updateCard` writes the companion verbatim (`activity_card_dao.dart:78-86`) — no automatic timestamp. This is deliberate and locked in by `activity_card_repository_test.dart:147-152`. Yet `cardsByStatus` is documented "newest-updated first" (`activity_card_repository.dart:12`) and the DAO's `_recentFirst` orders by `updatedAt DESC` (`activity_card_dao.dart:108-110`). A card just moved into a pane is therefore ranked by its creation time and can land below older cards; P4's "Tất cả" pane, built by merging four per-status queries sorted by `updatedAt` desc (`test-results.md:416-419`), inherits the same skew. `contract-summary.md:76` defines `updated_at` as "thời điểm **người dùng** thao tác trên dữ liệu của chính họ" — a manual status change is such an operation. Route to S4/S8 for the list-ordering impact. |
| F2-3 | MEDIUM | `activity_card_repository_impl.dart:111-128` | **Ownership-mismatched writes fail silently.** `updateStatus` and `clearScheduledDate` return `Future<void>` and discard the row count `_dao.updateCard` returns, even though `activity_card_dao.dart:76-77` documents that count as existing precisely "so a caller can tell 'not mine' from 'updated'", and `deleteCard` does propagate it (`impl:131-134`, interface `:42-44`). A status write against a card the session does not own resolves successfully having written nothing. The interface's own contract claim about owner isolation (`activity_card_repository.dart:3-6`) is thus unobservable to callers on 2 of its 4 write methods. |
| F2-4 | MEDIUM | `service_locator.dart:310-312` | **DI publishes the DAO next to the repository.** `ActivityCardDao` is registered as a public lazy singleton. Every DAO method takes `ownerKey` as a caller-supplied parameter, so any consumer can resolve it from GetIt and read or write with an arbitrary owner key — bypassing both the "cửa ghi duy nhất" rule (`contract-summary.md:13-18`) and the repository docstring's claim that "no method accepts it as a parameter, so a consumer cannot accidentally read or write another owner's cards" (`activity_card_repository.dart:3-6`). `phase-P2...md:84` asked only for the repository to be registered. Hardening, not a live defect — no in-story consumer does this today. |
| F2-5 | LOW | `activity_card_repository_impl.dart:149-162` | **Blank title persists.** When the draft's title is blank and there is no usable link host, `_resolveTitle` returns the empty string, so `createCard` writes `title = ''`. `contract-summary.md:63` calls `title` the "trường bắt buộc **duy nhất** (AC-6)"; the column is NOT NULL but not non-empty, so nothing enforces it. `activity_card_repository_test.dart:68-82` covers blank-title-**with**-link only; the blank-title-no-link path is untested. |
| F2-6 | MEDIUM | `coding-plan/test-results.md` | **P2 has no evidence section.** The file's phase sections are P1 (`:3`), P3 (`:100`), P4 (`:244`), P4 vòng 2 (`:398`), P4 vòng 3 (`:505`), P7 (`:593`), P5 (`:693`), P6 (`:798`). `phase-P2...md:99` ("bằng chứng test ghi vào `coding-plan/test-results.md`") and `:117` ("Evidence format: output `flutter test` dán vào `coding-plan/test-results.md`") are unmet. P2's numbers survive only second-hand inside P3's section (`test-results.md:118` "phần còn lại là test P1/P2 chạy lại nguyên vẹn"; `:199` "188 (baseline P1) + 3 (P2) + 2 (P3) = 193"). The tests themselves demonstrably exist and pass in later runs (`:111-113` 48/48, `:850-853` 112 pass / 2 skipped), so this is an evidence-trail gap, not a red suite. |
| F2-7 | LOW | `phase-P2-card-domain-repository.md:124-127` | **Stale phase status.** Still reads `Status: NOT_STARTED`, `Last updated: 2026-09-07`, while `master-plan.md:58` marks P2 `DONE` and P7's file correctly records `Status: DONE` with verification lines (`phase-P7...md:166-171`). |
| F2-8 | LOW | `activity_card_repository_test.dart` (whole file) | **Untested repository surface.** No test resolves a second `BackendUserIdStore` user id to prove `cardById`/`cardsByStatus`/`updateStatus`/`deleteCard` are actually scoped by `_requireOwnerKey`, and none covers the `StateError` thrown when no user id has resolved (`impl:136-144`). DAO-level owner isolation *is* covered by P1 (`test-results.md:43-44`), so the residual risk is confined to the repository's resolve-and-pass wiring. Also uncovered at P2 level: `countsByStatus`, `cardsByStatus` paging/ordering, `watchCardsByStatus`, and `deleteCard`'s row count. `phase-P2...md:106-107` did not name these, so this is a scope observation rather than a missed prescribed gate. |

## 5. Notes for S8

- Re-key the S2 row of scope-gate § Query Keys: AC-4 → AC-6 (§1 above). S1's
  drift warning is confirmed for a second slice.
- G3/F2-1 (photos) and FLAG-1 (§3) are both *contract-completeness* gaps in the
  same artifact pair (`contract-summary.md` §1/§3 + `phase-P2...md` §3). If S6
  routes FLAG-1 to a follow-up phase that opens the repository files for write,
  F2-1 and F2-3 belong in the same phase.
- F2-2 crosses into S4's list-ordering territory; S8 should reconcile.
- Nothing in this slice touches `schemaVersion`, migrations, or visual fidelity.
