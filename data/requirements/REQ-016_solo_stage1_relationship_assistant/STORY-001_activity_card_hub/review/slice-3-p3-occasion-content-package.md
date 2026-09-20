# Review Slice S3 — P3 Occasion Content Package

- Review type: `scoped-slice`
- Slice: S3 of the 8-pass plan in `review/scope-gate.md` → `## Prescribed Slice Plan`
- Subject: P3 occasion content package — R-7/BR-8, R-15a/R-15b
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Diff baseline: `git -C <Worktree> diff 9207f7296a64cd37ca60e432939469ca96860762 HEAD`
- slice_outcome: `PASS_WITH_FINDINGS`
- SLICE_COMPLETE: YES

This pass records findings only. It issues no story-level verdict; S8
`final-synthesis` owns the canonical `Outcome:` line.

## Files Reviewed (6 — matches the S3 inventory exactly)

| File | Δ | Read |
|---|---|---|
| `mobile/lib/core/content/content_package.dart` | +225 / −0 | whole (new) |
| `mobile/lib/features/activity_cards/domain/occasion_suggestion_service.dart` | +167 / −0 | whole (new) |
| `mobile/assets/data/req016/occasions.v1.json` | +197 / −0 | whole (new) |
| `mobile/pubspec.yaml` | +5 / −4 | diff hunk only |
| `mobile/test/core/content/content_package_test.dart` | +289 / −0 | whole (new) |
| `mobile/test/features/activity_cards/occasion_suggestion_service_test.dart` | +330 / −0 | whole (new) |

Cross-checked for one claim only, not reviewed (S2 owns it):
`mobile/lib/features/activity_cards/domain/activity_type.dart` — needed to
verify what `occasionFromJson` gets back for an unrecognized `activity_type`
(see F-4).

The 6 changed files match `phase-P3-occasion-content-package.md` §1B Write
Scope exactly. No write-scope leakage.

## Governing AC Set — Corrected

`scope-gate.md` → `## Query Keys` labels S3 as *"AC-1, AC-2, R-7, BR-8, R-15a,
R-15b"*, and its per-slice focus list says *"AC-1/AC-2 second invitation"*.
Verified against `requirements/requirements.md` (the gate's own stated
authority), that labelling is wrong — this is the AC-numbering drift S1 and S2
already flagged, and it lands on this slice too.

The ACs that actually govern P3:

| AC (authoritative `requirements/requirements.md`) | Text in scope | Applies to P3 |
|---|---|---|
| **AC-3** | *"app hiển thị 1–2 gợi ý tất định lấy từ gói dữ liệu ship sẵn (dịp Việt gần nhất theo lịch thiết bị), và chọn một gợi ý tạo ngay một thẻ Mới nghĩ ra"* | primary |
| **AC-5** | *"toàn bộ nội dung đến từ bảng tra / preset ship sẵn, không có lời gọi mô hình AI nào ở runtime và không có lời gọi API nội dung bên ngoài nào (R-7)"* | primary |
| **AC-9** | thẻ mang một **nguồn sinh** (*"gợi ý theo dịp"*) đọc được ở story sau, không hiển thị như chỉ số | partial (write side only) |
| **BR-8** | R-7 restated: bảng tra tay ship như gói dữ liệu, runtime tất định | primary |
| AC-1 | names the second invitation label *"để app gợi ý 1 việc theo dịp gần nhất"*; the empty-state rendering that must show exactly two invitations is P5 | boundary only → **S5** |
| AC-2 | the *paste-link* invitation — a different path entirely | **not P3** → S5 |

The implementation's own doc comments cite AC-3 and AC-5, i.e. the **code is
right and the scope gate is wrong**. `phase-P3-occasion-content-package.md`
§1B/§2 also names AC-3, AC-5, BR-8. No finding against the code here; S8 should
carry the correction forward and not re-derive S3 scope from the gate's AC list.

R-15 scoping note, for S8: `requirements.md` → `## Open Question Impact`
states R-15 *"áp cho các story tiêu thụ nội dung preset, **không thêm phạm vi
cho STORY-001**"*. P3 adopted R-15a/R-15b voluntarily as phase risk surfaces.
So R-15 gates below are held to the phase file's bar, not to a requirement-level
obligation — which is what makes F-4 a defensible deferral rather than a
violation.

## Gate Results

| Gate | Rule source | Verdict | Evidence |
|---|---|---|---|
| No runtime AI / no external content API | AC-5, BR-8, R-7, scope-gate critical gate | **PASS** | see below |
| 1–2 deterministic suggestions for the nearest occasion | AC-3 | **PASS** | `nearestOccasion` + 6 tests |
| Choosing a suggestion creates an `idea` card, no extra field asked | AC-3 | **PASS** | `acceptSuggestion` + test |
| Origin `occasion_suggestion` recorded | AC-9, contract-summary §2 | **PASS** | asserted in 2 tests |
| Stable author-assigned ids, never an array index | R-15a | **PASS** | parse-time + shipped-asset tests |
| No occasion content string in any Dart file | R-15a, phase §4 | **PASS** | `lib/**/*.dart` scan test |
| N is a data property; correct at N=0/1/50 | R-15b | **PASS** | parametrised tests |
| Schema failure is loud at load, never swallowed | phase §3 | **PASS (with F-4)** | 9 rejection tests |
| Asset directory registered | phase §3 | **PASS** | `pubspec.yaml` hunk |
| Static analysis: no new errors | phase §6 | **PASS** | 0 errors, 2 new `info` |
| Shared-interface contract recorded for downstream stories | phase §1B, scope-gate | **FINDING F-3** | absent from contract-summary |

### AC-5 / BR-8 / R-7 — no network on the suggestion path

The strongest gate in this slice, and it is genuinely enforced rather than
asserted:

- Neither lib file imports `dart:io`, `package:http`, or any network client.
  `ContentPackageLoader` takes an `AssetBundle` and nothing else; there is no
  base URL, no client field, and no injection point for one.
- `occasion_suggestion_service_test.dart` runs load + suggest + create inside
  `HttpOverrides.runZoned` with a `createHttpClient` that throws `StateError`,
  so any network call turns the test red.
- It is followed by an explicit **control test** asserting that opening an
  `HttpClient` in that same zone *does* throw. Without the control, a passing
  gate could not be distinguished from an override that never took effect.
  Recording this because it is the difference between a real gate and a vacuous
  one, and S8 can rely on it.

### AC-3 — determinism

`OccasionSuggestionService.nearestOccasion` is `static` and pure over
`(deviceDate, package)`; it reads no clock, no locale, and no I/O. Ordering is
total: earliest date wins, ties broken by `occasion.id.compareTo`, so package
reordering cannot change the answer. Covered at N=0, N=1, N=50, at the
same-day boundary (an occasion on the device date counts as upcoming), and for
"no upcoming date at all" (returns `null`, does not throw).

The 1–2 cap is `maxOccasionSuggestions = 2`, documented as derived from AC-3's
wording rather than from package size — which is exactly what phase §3's ban on
count constants asks for. The lower bound of 1 is enforced structurally:
`occasionFromJson` rejects an occasion carrying zero suggestions.

`civilDate()` builds a zero-padded `YYYY-MM-DD` from the device-local
`DateTime` fields, deliberately not an instant or UTC shift. This matches
`contract-summary.md` §3's `scheduled_on` contract (*"ngày dân dụng YYYY-MM-DD
theo lịch thiết bị, không phải instant/UTC"*). Citation verified, not assumed.

### Contract-summary §2 conformance (verified value by value)

| §2 identifier | Shipped implementation | Match |
|---|---|---|
| Gói nội dung dịp `occasions` @ `mobile/assets/data/req016/occasions.v1.json` | `"id": "occasions"`, `occasionsAssetKey` | yes |
| Nguồn sinh `occasion_suggestion` | `ActivityCardOrigin.occasionSuggestion` | yes |
| `ActivityType`: `outing`, `home`, `visit`, `dining`, `handmade`, `walk`, `photo`, `gift` | all 8 used in the asset, none outside the set | yes |

No Vietnamese string is used as a stored key anywhere in the package; display
text lives only in `name` / `title`.

## Findings

### F-2 — MEDIUM — the shipped occasion package expires on 2027-12-24

`occasions.v1.json` carries exactly two dated instances per occasion, all in
2026 and 2027. The latest date in the whole package is `2027-12-24`
(`giang_sinh`). There is no recurrence rule, no wrap-around, and no refresh
path.

Consequence: for any device date from **2027-12-25** onward,
`nearestOccasion` returns `null` permanently, so AC-3 (*"app hiển thị 1–2 gợi
ý"*) can no longer be satisfied, and AC-1's second one-tap invitation
(*"để app gợi ý 1 việc theo dịp gần nhất"*) has nothing behind it.

Mitigating: the null path is deliberate, graceful, and tested — the service
returns `null` rather than throwing, and `an empty package yields no prompt`
plus `... yields no prompt rather than throwing` both cover it. So this is a
content shelf-life issue, not a crash. Nothing in the phase file,
`requirements.md`, or `test-results.md` records the horizon or an owner for
refreshing it.

- Owner: product-owner (content horizon decision) + mobile-dev (refresh path)
- **Crosses into S5:** whether this degrades acceptably depends on what
  `minute_one_empty_state.dart` renders when the prompt is `null`. If the
  invitation is still shown and dead-ends, that compounds into an AC-1 defect
  owned by S5. S3 cannot see that widget and does not judge it.
- Not resolvable inside this slice. S8 should route it, not absorb it.

### F-3 — LOW/MEDIUM — `ContentPackage<T>` is a declared shared interface that no cross-lane contract records

`phase-P3-occasion-content-package.md` §1B lists under **Shared Interfaces
Produced**: *"`ContentPackage<T>` (`id`, `version`, `schemaId`, `items[]`) —
hình dạng mà kho preset của STORY-002+ dùng lại"*, and names the consumer
contract as *"P5, và kho preset của STORY-002/004/005/011"*. Both source files
reinforce this in their doc comments, each citing
`architecture/contract-summary.md` §2 as the shape's home:

`content_package.dart:30-32`
```dart
/// A versioned, schema-checked bundle of preset content
/// (`architecture/contract-summary.md` §2). The shape STORY-002+ preset stores
/// reuse.
```

`contract-summary.md` contains **no occurrence of `ContentPackage`,
`schema_id`, or the package envelope shape**. Its §2 is *"Identifiers — copy
exactly"* — a table of stored identifier values, which P3 does conform to (see
above), but which says nothing about the generic package structure.

This matters because the scope gate names contract-summary §1–§3 as the
*"Shared contract stability for 11 downstream stories"* gate, and STORY-001 is
`Story-Class: shared-foundation`. A STORY-002 author reading the cross-lane
contract — the artifact they are told to read — would not learn that a reusable
preset-package shape already exists, and would be free to invent a second one.

Documentation gap in a governing artifact; no code defect. Owner: tech-lead.
Deferrable if S8 records it against the requirement rather than dropping it.

### F-4 — LOW — package field validation is looser than the file's own stated policy

`content_package.dart:5-8` states the policy:

```dart
/// A shipped content package failed its schema check. Loading never degrades
/// to a partial or empty package: a malformed asset is a loud error at load
/// time (R-15a), because the content source moves to an out-of-repo CMS whose
/// exports never pass through this repository's review.
```

Two field types do not meet that bar:

1. **Dates are not format-checked.** `requireContentStringList(json, 'dates',
   source)` only rejects non-strings and empty strings. `nearestOccasion` then
   orders dates with `String.compareTo` against `civilDate`'s zero-padded
   output. A CMS export shipping `2026-2-17` (unpadded) or `17/02/2026` parses
   cleanly and then sorts *wrongly* — silently selecting the wrong "nearest"
   occasion instead of failing loudly. The `^\d{4}-\d{2}-\d{2}$` assertion does
   exist, but only in `occasion_suggestion_service_test.dart` against the
   in-repo asset — i.e. against the one file that *does* pass review, and not
   against the CMS export the comment names as the threat.
2. **Unknown `activity_type` degrades silently.**
   `occasionFromJson` reads it through `activityTypeFromWireValue`, which is
   documented as a deliberately lenient reader for *stored DB rows written
   before the vocabulary existed* — `activity_type.dart:28-33`. That leniency
   is correct for its own purpose, but reusing it on the *content package* path
   means a typo'd type in a CMS export yields a typeless suggestion (card loses
   its icon) rather than a load error. Note `activity_type.dart:6-8` asserts
   *"the shipped `occasions.v1.json` package is the only producer"* — which is
   precisely the path that does not validate.

Severity is LOW **today**: the shipped asset is correct, and its shape is
test-guarded. This becomes the stated threat model's actual failure mode only
when the out-of-repo CMS is real. `requirements.md` explicitly scopes R-15's
ingest gate out of STORY-001, so deferring to STORY-002 (where the preset store
lands) is defensible. Owner: tech-lead / mobile-dev.

### F-1 — INFO — scope-gate AC labelling for S3 is wrong (no code impact)

Recorded above under `## Governing AC Set — Corrected`. Repeated here so S8 can
count findings from one list. Correction only; no patch to any file.

### F-5 — INFO — `tet_trung_thu` carries `name` "Rằm tháng Tám"

Id/label divergence in the asset. Ids are stable and opaque by contract
(`contract-summary.md` §2: ASCII, stable, append-only), and renaming the id
later would be the actual breaking change. Cosmetic. No action.

## Test Evidence Assessment

`coding-plan/test-results.md` → `## Phase P3` (lines 100–229) records
`flutter test test/core/content/ test/features/activity_cards/` → **48/48
pass** (33 new P3 tests), and maps every phase §4/§6 gate to a named test. Each
of the three §6 *Required checks* has a named passing test:

- exploding-HTTP-client run → present, plus its control
- N=1 and N=50 run of the same suite → present, parametrised
- item id is a stable string, not an array index → present at parse level and
  against the shipped asset

Static analysis: `flutter analyze lib test` → 193 issues, **0 errors**, 35
warnings identical to the P1 baseline, 158 info. Exactly 2 info attach to P3
files, both `prefer_initializing_formals` at
`content_package.dart:208` and `occasion_suggestion_service.dart:107`, both
unfixable as the lint suggests (a private field behind a public named
parameter, and Dart forbids a named parameter starting with `_`). Same shape as
P2's 3 pre-existing info of that kind. Accepted.

Credibility note for S8: the test-results P3 section records that the
"no content string in Dart" gate **caught a real violation before the phase
closed** — a doc comment in `occasion_suggestion_service.dart` quoting an
occasion name — which was fixed. It also records that reviewing the rendered
design references forced a contract change mid-phase (`Occasion` gained a
required `name`, `OccasionPrompt` began carrying the whole `Occasion`) to stop
P5 from having to hard-code Vietnamese occasion names. Both are evidence of
gates that bite rather than gates that decorate.

Per-story visual fidelity: `NOT_APPLICABLE` for P3 — the phase builds no
screen. Design references were rendered and read as *input* to the data shape,
which is recorded in test-results; the fidelity verdict itself belongs to S7.

## Residual Risk Carried To S8

- **F-2** is the only finding with user-visible consequence, and its severity
  depends on S5's null-prompt rendering. S8 must pair this slice's F-2 with
  S5's empty-state result before classifying it.
- **F-3** is a shared-foundation contract-documentation gap; it affects
  STORY-002/004/005/011 authors, not this story's behaviour.
- **F-4** is a forward-looking robustness gap, explicitly out of STORY-001's
  requirement scope.
- No finding in this slice blocks P3's own ACs. AC-3, AC-5, AC-9 (write side),
  BR-8, R-15a and R-15b are all verified PASS against code and named tests.
- Nothing in this slice bears on FLAG-1 or FLAG-2.

## Unverified Items

None. Every gate assigned to S3 was evaluated against code plus a named test;
no item was accepted on trust.
