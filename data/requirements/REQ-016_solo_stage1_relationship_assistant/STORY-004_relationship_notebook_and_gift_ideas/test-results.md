# STORY-004 — Test Results

## Phase P1 — Kho ngữ cảnh: bảng Drift + repository

- Lane: Mobile
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Date: 2026-09-10
- Per-story visual fidelity: NOT_APPLICABLE (phase dựng không màn nào)

### schemaVersion

Đọc sống trên nhánh này và trên `codex/REQ-016_solo_stage1_relationship_assistant-integration`
(`git show <integration>:mobile/lib/core/database/cupid_database.dart`): cả hai
đều là **5**. P1 cộng đúng một → **6**. Nhánh migration chỉ `CREATE TABLE`
(`notebook_entries`, `skill_profile_entries`, `ask_prompt_state`) trong khối
`if (from < 6)`; không `ALTER`, không huỷ-tạo-lại bảng nào.

### Commands

| Lệnh | Kết quả |
|---|---|
| `flutter test test/features/context_notebook test/core/database --reporter failures-only` | `+99: All tests passed!` |
| `flutter test test/core/database/context_notebook_migration_test.dart --reporter expanded` | `+8: All tests passed!` (8 case liệt kê tên) |
| `flutter test test/features/context_notebook/context_notebook_repository_test.dart --reporter expanded` | `+17: All tests passed!` (17 case liệt kê tên) |
| `flutter test test/features/activity_cards test/features/journal test/features/invite_composer --reporter failures-only` | `+401 ~6: All other tests passed!` (6 skip có sẵn) |
| `flutter analyze lib test` | 0 error · 35 warning · 178 info (exit 1 do info/warning có sẵn) |

Mọi lệnh chạy với `PATH="$HOME/flutter/bin:$PATH"` trong `mobile/`.
Trước đó chạy một lần `flutter pub get`, `flutter gen-l10n` (worktree mới,
`lib/l10n/generated/` bị gitignore) và `dart run build_runner build`.

### Analyzer

0 error. Toàn bộ output quy được cho P1 là **4 info
`prefer_initializing_formals`** ở `context_notebook_repository.dart:27-30` —
đúng dạng đã có ở `ActivityCardRepositoryImpl` (tham số tên có giá trị mặc định
không dùng được initializing formal cho field private). 35 warning và 174 info
còn lại nằm ở file P1 không đụng tới; nền không đổi.

### Gate migration (AC bắt buộc của phase)

`context_notebook_migration_test.dart` dựng fixture bằng cách mở schema hiện
tại trên file, seed một hàng thật cho mỗi bảng client-owned đã có, `DROP` đúng
ba bảng mới rồi `PRAGMA user_version = 5`. Sau khi mở lại:

- `user_version` = 6, ba bảng mới có mặt và ghi được ngay.
- `activity_cards` / `journal_entries` / `invite_messages` giữ nguyên hàng và
  nội dung (`Đi ăn lẩu`, `Hôm nay trời đẹp`, `invite.rap_phim.v1`).
- `ask_prompt_state` có PK gộp đúng `(owner_key, question_id)`.

### Gate cột bị cấm (AC-12 / AC-25 / R-1b)

Ba test so **tập cột sinh ra** với allowlist chính xác của
`contract-summary.md` §4, cộng assert phủ định:

- `skill_profile_entries`: không có `level` / `star` / `stars` / `score` /
  `rank` / `rating` / `proficiency`.
- `notebook_entries`: không cột nào bắt đầu bằng `partner_` / `seen_` /
  `reply_` / `frequency_`.
- `ask_prompt_state`: không cột đếm.

Vì so bằng tập bằng nhau (không phải `containsAll`), mọi cột thêm về sau — kể
cả tên chưa nằm trong danh sách cấm — đều làm test đỏ.

### AC coverage

| AC | Bằng chứng |
|---|---|
| AC-4 | `an answered question round-trips with its stable question id`; `a manually typed entry carries no question id` |
| AC-6 | Cột `detail` là ghi chú trong chính mục đó; enum `NotebookKind` đóng ở `interest`/`event`, không kind thứ ba |
| AC-9 | Nhóm `sửa và xoá có hiệu lực ngay (AC-9)` — 4 test, gồm xoá trả `1` và đọc lại `null` |
| AC-12 | `skill_profile_entries carries no proficiency dimension (AC-12)` |
| AC-25 | `notebook_entries measures nothing about the partner (AC-25)` |

### Deviations from the declared Write Scope

Hai nhóm file ngoài Write Scope buộc phải sửa vì chính việc tăng
`schemaVersion` mà phase yêu cầu:

1. `mobile/lib/core/database/cupid_database.g.dart` — output của
   `build_runner`, có commit trong repo; không tái sinh thì ba bảng mới không
   tồn tại. Không có file `.g.dart` nào khác đổi.
2. Sáu file test có sẵn hard-code hằng số phiên bản cũ (`5` → `6`). Đây là
   hằng số đã cũ, không phải hành vi đổi; nếu không sửa thì yêu cầu "test hiện
   có giữ nguyên xanh" của chính §6 không thể thoả cùng lúc với yêu cầu tăng
   `schemaVersion`:
   - `test/core/database/migration_v5_test.dart` (2 chỗ)
   - `test/core/database/activity_card_migration_test.dart` (2 chỗ)
   - `test/core/database/activity_card_dao_test.dart` (1 chỗ + tên test)
   - `test/core/database/timeline_dao_test.dart` (1 chỗ)
   - `test/core/database/journal_dao_test.dart` (1 chỗ)
   - `test/core/database/expense_dao_test.dart` (1 chỗ)
   - `test/features/activity_cards/activity_type_test.dart` (1 chỗ + comment)

Không sửa gì khác trong các file đó.

### Ghi chú thiết kế đáng lưu ý cho reviewer

`ContextNotebookDao` là lớp bọc thường, **không** phải `@DriftAccessor` đăng ký
trong danh sách `daos:` của annotation database. Đăng ký như vậy sẽ buộc
`core/database/cupid_database.dart` import `features/`, phạm ADR-010 — và test
có sẵn `lib declares exactly one @DriftDatabase (ADR-010)` quét văn bản file
`lib/**`, nên ngay cả chuỗi `@DriftDatabase` trong comment cũng làm nó đỏ.

## Phase P2 — Tầng luật bất biến dùng chung + gói/cổng nhập kho ngữ cảnh

- Lane: Mobile
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Date: 2026-09-10
- Per-story visual fidelity: NOT_APPLICABLE (phase không dựng màn nào)

### Commands

| Lệnh | Kết quả |
|---|---|
| `flutter test test/features/context_notebook test/features/invite_composer test/core/content --reporter failures-only` | `+181: All tests passed!` |
| `flutter test test/features/context_notebook --reporter failures-only` | `+45: All tests passed!` |
| `flutter test .../context_content_gate_test.dart --plain-name "the invariant rules have exactly one home" --reporter expanded` | `+2: All tests passed!` (2 case liệt kê tên) |
| `flutter analyze lib test` | 0 error · 213 issue (exit 1 do info/warning có sẵn) |
| `flutter analyze --no-fatal-infos --no-fatal-warnings lib/core/content lib/features/context_notebook lib/features/invite_composer test/features/context_notebook` | 13 issue, **0 error · 0 warning**, toàn bộ là `prefer_initializing_formals` có sẵn ở file không đụng tới |

Mọi lệnh chạy với `PATH="$HOME/flutter/bin:$PATH"` trong `mobile/`.

### Tầng luật bất biến chỉ có một chỗ sống (D-15/R-15c)

`_deniedTerms` + hàm so khớp nguyên-từ đã rời
`features/invite_composer/domain/preset_content_gate.dart` sang
`core/content/invariant_terms.dart`. `PresetGateRule`, `PresetViolation`, chữ ký
và hành vi quan sát được của `validatePresetPack` **không đổi**: hai enum ghép
với nhau bằng `wireValue`, và chuỗi `detail` giữ nguyên từng ký tự
(`text uses the denylisted term "…"`, `text shows a "%" figure`).

**`test/features/invite_composer/preset_content_gate_test.dart` giữ nguyên
XANH, KHÔNG sửa một dòng nào** — `git status --porcelain` trong worktree không
liệt kê file test đó; file duy nhất bị sửa ở lane invite_composer là
`preset_content_gate.dart`.

Test khẳng định kiểu grep (`only invariant_terms.dart declares denylisted
terms`) quét mọi `lib/**/*.dart` tìm 7 chuỗi mẫu — `thả thính`, `điểm số`,
`xếp hạng`, `chuỗi ngày`, `hoạt động lần cuối`, `tần suất`, `xứng đáng` — và
đòi file duy nhất chứa chúng là `lib/core/content/invariant_terms.dart`. Một
bản sao thứ hai của danh sách, ở bất kỳ đâu trong `lib/`, làm test đỏ.

`notebookBoundaryTerms` (R-1f tầng đầu vào) sống **cùng file** với
`invariantDeniedTerms` và rời rạc với nó: không chuỗi nào lặp giữa hai bản đồ,
nên mỗi chuỗi cấm vẫn chỉ tra được ở đúng một danh sách. Bản đồ này không nằm
trong đường đi của preset gate, nên preset gate không phát sinh luật mới.

### Cổng nhập quét-từ-đĩa (AC-35/AC-36/BR-18) — đã chứng minh đỏ được

Nhóm `shipped packs pass the gate from disk` đọc
`assets/data/req016/ask_questions.v1.json` và `skill_seeds.v1.json` bằng
`File(...).readAsStringSync()` — không phải fixture trong bộ nhớ.

Bằng chứng đỏ được: tạm đổi prompt của `ask.interest.food.v1` thành
"Người ấy nhắn cho bạn bao lâu một lần?" rồi chạy lại đúng test đó:

```
Expected: empty
  Actual: [ 'req016.ask_questions/ask.interest.food.v1 [frequency_probe]:
            question asks past the notebook boundary via "bao lâu một lần"' ]
```

Đã hoàn nguyên ngay sau đó; lần chạy cuối cùng của cả test scope là
`+181: All tests passed!`.

### AC coverage

| AC | Bằng chứng |
|---|---|
| AC-10 | Parser từ chối câu hỏi không có chip (`a question with no seed chips is rejected`); `every shipped question offers tap-to-pick seeds` |
| AC-11 | `the four required soft skills are on disk`; `a seed pack missing one required id is a violation` (đỏ, nêu đúng id thiếu); `an empty seed pack reports all four missing ids`. `SkillSeed` không có trường nhóm/hạng/mức độ nên không thể vẽ "nhóm phụ" |
| AC-32 / BR-16 | Hai gói là asset JSON có `schema_id` + id bền; `no pack wording is written into any Dart or l10n file` quét `lib/**/*.dart` và `lib/**/*.arb` |
| AC-35 | 8 test luật hiển thị: tâng bốc, `%`, streak, điểm/hạng (cả trên nhãn kỹ năng), hành vi người kia, giọng thao túng, chip cũng bị quét, và `địa điểm` **không** bị coi là điểm số |
| AC-36 / BR-4 | 4 test ranh giới đầu vào: tần suất, hành vi, đánh giá con người, và một câu đánh giá giấu trong chip |
| BR-18 | Cổng chạy trong bản dựng; mục vi phạm → test đỏ → bản dựng hỏng (xem mục trên) |

### Ghi chú cho reviewer

1. `AskTarget` là enum đóng ba giá trị; giá trị lạ ném
   `ContentPackageFormatException` ở parser, **không** rơi về mặc định
   (`an unknown target is a parse error, not a default`).
2. `allow_free_text` bắt buộc là boolean thật; `"yes"` bị từ chối. `ContentPackage`
   không có `requireContentBool` và `content_package.dart` nằm ngoài Write Scope
   của phase, nên helper đọc bool là hàm riêng trong `context_content.dart`.
3. `editorial_review` được **parse** vào model nhưng **không** thêm luật cổng
   riêng: §3 của phase liệt kê đúng hai luật riêng (câu hỏi vượt ranh giới, thiếu
   id mồi bắt buộc), và §4 không nêu editorial. Đây là chủ ý, không phải bỏ sót.
4. Câu chữ gói phải né trùng chuỗi với Dart có sẵn: `Cà phê`, `Trà sữa`,
   `Xem phim`, `Sinh nhật`, `Chụp ảnh` đã xuất hiện trong `main_preview.dart`,
   `chat_composer.dart`, `vibe_strings.dart`, `activity_card_tile.dart` ở các
   feature không liên quan. Đã đổi chip thành cụm dài hơn
   (`Cà phê sáng`, `Trà sữa ít đường`, `Xem phim ở nhà`, `Sinh nhật sắp tới`,
   `Chụp ảnh kỷ niệm`) thay vì nới test — luật BR-16 giữ nguyên độ chặt.

## Phase P3 — Hỏi-tại-chỗ: mặt tiền dùng chung

- Lane: Mobile
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Date: 2026-09-10
- Per-story visual fidelity: NOT_APPLICABLE (phase không gắn lối vào nào, chưa
  có màn hình chạy được để chụp)

### Commands

| Lệnh | Kết quả |
|---|---|
| `flutter test test/features/context_notebook` | `00:06 +68: All tests passed!` |
| `flutter analyze lib test` | 0 error · 35 warning · 182 info (exit 1 do nền info/warning có sẵn) |
| `flutter analyze lib/features/context_notebook test/features/context_notebook` | 0 error · 0 warning · 8 info |

Mọi lệnh chạy với `PATH="$HOME/flutter/bin:$PATH"` trong `mobile/`, không lọc
output.

68 test = 17 của P1 (`context_notebook_repository_test.dart`) + 28 của P2
(`context_content_gate_test.dart`) + 11 mới (`ask_cadence_policy_test.dart`) +
12 mới (`ask_on_the_spot_slot_test.dart`). P1 và P2 vẫn xanh nguyên.

### Analyzer

0 error, 0 warning trong phạm vi feature. 8 info còn lại: 4 cái ở
`context_notebook_repository.dart:27-30` là nền P1 để nguyên, 4 cái mới ở
`ask_on_the_spot_cubit.dart:66-69` cùng dạng `prefer_initializing_formals` —
tham số tên public không nhận `this._field`, nên toàn repo (kể cả
`content_package.dart`, `cupid_session.dart`) mang y hệt info này. Một info
thật sự của phase (`unnecessary_import` `dart:typed_data` trong test) đã sửa,
không phải bỏ qua.

### Hai test cổng của phase

| Test | Ý nghĩa |
|---|---|
| `đúng một câu một lần (AC-2/BR-2) two slots on one route render one card, not two` | Hai `AskOnTheSpotSlot` trên cùng route → đúng một `ask-on-the-spot-card`. Thiếu test này là `SHARED_CONTRACT_UNSTABLE` |
| `biên giới import của feature no file outside features/context_notebook imports an internal` | Quét đệ quy `lib/`, regex bắt `features/context_notebook/(data\|domain\|presentation)/` |

Test biên giới miễn trừ đúng một đường dẫn: `lib/core/di/service_locator.dart`.
Composition root buộc phải gọi tên lớp cụ thể để đăng ký nó (P1 đã đăng ký, y
như cách nó đối xử với journal). Ngoài file đó, danh sách miễn trừ rỗng.

**Bản đầu của test này xanh giả, và việc thử-đỏ đã bắt được.** Cách bắt ban đầu
là một regex đòi chuỗi `features/context_notebook/(data|domain|presentation)/`
xuất hiện nguyên văn trong câu lệnh import. Thêm tạm
`import '../context_notebook/data/context_notebook_dao.dart';` vào
`lib/features/journal/journal_entry_point.dart` — một vi phạm thật — test vẫn
báo `+1: All tests passed!`. Lý do: repo này viết import trong `lib/` theo dạng
tương đối, không có chữ `features/` trong URI, nên regex không thể khớp cái
dạng vi phạm phổ biến nhất.

Đã đổi cách bắt: quét cả `import` lẫn `export`, phân giải URI (dạng tương đối
`../` và dạng `package:cupid_mobile/`) về đường dẫn `lib/...` rồi mới so với
ba thư mục nội bộ. Chạy lại với đúng vi phạm tạm đó:

```
Expected: empty
  Actual: ['lib/features/journal/journal_entry_point.dart -> ../context_notebook/data/context_notebook_dao.dart']
```

Đã `git checkout` hoàn nguyên `journal_entry_point.dart` ngay sau đó; `git
status` trước khi bàn giao chỉ còn đúng 6 file Write Scope + file này.

### AC coverage

| AC | Bằng chứng |
|---|---|
| AC-1 | `the answer disappears with no toast, dialog or save button` (không `SnackBar`, không `Dialog`, không nút lưu); `the answer is written straight through and the flow re-runs` (`onContextChanged` gọi đúng 1 lần sau khi repository đã ghi) |
| AC-2 / BR-2 | Hai test nhóm `đúng một câu một lần`: slot thứ hai câm, và vẫn câm sau khi slot đầu được trả lời |
| AC-3 / BR-3 | `skipping hides the card without blocking or scolding` (khẳng định không có chuỗi trách móc); `the skipped question is not asked again this session` |
| AC-4 | `ContextNotebookReader sees what the card just wrote` — đọc lại qua mặt tiền, không qua repository |
| AC-5 / BR-1 | `nothing left to ask renders nothing, not an empty prompt` → `SizedBox.shrink()` |
| AC-10 | `a free-text answer is opt-in, never the default box` — không có `TextField` nào trước khi chạm chip "Khác..."; `every required soft-skill seed is on screen before any typing` |
| AC-11 | Danh sách chip khẳng định theo `requiredSkillSeedIds` (không hard-code lại), thứ tự giữ nguyên như gói khai báo — không nhóm phụ, không làm mờ |

### Ghi chú cho reviewer

1. **`openNotebookScreen`/`openSkillProfileScreen` hiện ném
   `UnimplementedError` có chú thích trỏ về P4.** Chữ ký bị chốt ở P3 vì
   STORY-005/008/009/010 viết dựa vào nó, nhưng §6 phase ghi rõ "phase này
   không gắn lối vào; P4 và P7 làm việc đó". Đây là mối nối cố ý và có ghi
   chú, không phải việc làm dở — P4 thay thân hàm bằng lệnh push thật.
2. Bất biến "đúng một câu" nằm trong widget, không nằm ở kỷ luật của caller:
   một `Map<Object, State>` cấp module khoá theo `ModalRoute.of(context)`, nhận
   trong `didChangeDependencies` và trả trong `dispose`. `AskOnTheSpotSlot` vẫn
   là `StatelessWidget` đúng như §3 hợp đồng khai báo; phần có state nằm trong
   `_AskOnTheSpotHost` private.
3. Chip kỹ năng lấy từ gói `skill_seeds`, không lấy từ `chips` của chính câu
   hỏi: chỉ seed mới có id bền để ghi vào `skill_profile_entries.seed_id`, và
   AC-11 đòi bốn kỹ năng thường ngày phải có mặt.
4. `skip()` phát `hidden` **trước** rồi mới `await recordPromptState` — "không
   bị chặn" của AC-3 nói về người dùng, không nói về database.
5. Cubit nuốt mọi lỗi nạp về trạng thái `hidden`: thẻ hỏi là phần làm giàu
   tuỳ chọn của luồng người khác, và BR-1/AC-3 nói luồng đó không bao giờ bị
   chặn. Owner key chưa resolve, hay bundle thiếu gói, đều làm thẻ vắng mặt —
   không thành lỗi màn hình chủ phải vẽ.
6. Ba tham số `@visibleForTesting` (`repository`, `contentLoader`,
   `sessionSkips`) là tuỳ chọn; ba tham số bắt buộc của hợp đồng §3 giữ
   nguyên, production vẫn đi qua `getIt` + `const ContentPackageLoader()` +
   `AskSessionSkips.shared`.
