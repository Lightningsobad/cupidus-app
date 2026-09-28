# Requirement Integration Review: REQ-017_checkin_notebook_capture

Review type: `requirement-integration-review`
Outcome: PATCH_REQUIRED

Scope gate: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-017_checkin_notebook_capture/data/requirements/REQ-017_checkin_notebook_capture/integration-review/scope-gate.md`
Branch: `codex/REQ-017_checkin_notebook_capture-integration` @ `a15bde4fb6a5d4e8de67410a1f0fd4b2b00612b7`
BaseHead: `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1`
Reviewed: 2026-09-28

## Outcome và lý do

Phần **code** của requirement sạch ở tầng integration: merge nhập trọn vẹn, schema cộng thêm đúng
tuần tự, asset mới phân giải được lúc chạy, và luồng end-to-end check-in → mục sổ tay → nhãn xuất xứ
còn nguyên sau merge. Không có finding code nào chặn.

Nhưng requirement **chưa đủ hai gate cấp đóng-requirement**, và cả hai đều thiếu hoàn toàn (không
phải cũ hay mâu thuẫn — không tồn tại):

1. `## Integration Build & Runtime` với cả `- Build: PASS — …` và `- Runtime/Smoke: PASS — …` trong
   cùng một file dưới `integration-review/` (rule 12g3). `req_master.md` không có dòng
   `Integration-Verify: WAIVED`.
2. `integration-review/mobile-visual-audit.md` cấp requirement (rule 12g2).

Cả hai là bằng chứng phải do lane thực thi sinh ra trên nhánh đã merge, nên `PATCH_REQUIRED` (rule
12c: lane vẫn cấp được bằng chứng), không phải `BLOCKED`. Không có gì trong hai gate này bị chặn bởi
môi trường, credential, hay quyết định thượng nguồn — REQ-016 đã làm đúng hai gate này bằng
`integration-review/build-runtime-evidence.md` (build `assembleLocalDebug` thật + `am start -W` thật
trên `emulator-5554`) và `integration-review/mobile-visual-audit.md`.

Reviewer **không tự viết** hai dòng `Build: PASS` / `Runtime/Smoke: PASS`. Cây merge trùng khít cây
story branch (chứng minh dưới đây), nên có thể lập luận rằng bằng chứng build/smoke cấp story áp cho
đúng những byte này — nhưng dùng lập luận đó để tự điền gate mình đang canh là tự sản xuất bằng
chứng, và nó lệch khỏi hình dạng bằng chứng mà rule 12g3 cùng tiền lệ REQ-016 đòi (một lần build +
một lần khởi chạy thật **trên nhánh merge**). Việc chụp trên thiết bị/emulator cho gate 2 cũng thuộc
mobile-dev, không thuộc Reviewer (rule 12e3).

## Merged stories và story review

| Story | Complexity | Story review | Merge |
|---|---|---|---|
| STORY-001_checkin_notebook_capture | standard | `Outcome: DEFERRED_ONLY` — `STORY-001_checkin_notebook_capture/review/review-report.md:3` | `a15bde4f` (parents `908d22d8` ⊕ `dd46d89d`) |

Requirement có đúng một story, nên không có bề mặt cross-story nào để đối chiếu. Không AC nào đã
PASS ở story review được mở lại (rule 16a).

## Integration gates

| # | Gate | Kết quả | Bằng chứng |
|---|---|---|---|
| 1 | merge nhập trọn vẹn, không mất nội dung | **PASS** | `git diff dd46d89d..HEAD` **rỗng** → cây merge trùng khít cây story tip. `git diff 70ddb8b8..HEAD --name-status` chỉ ra các file REQ-017 (thêm/sửa), không có file nào của `main` bị mất hay lùi. Working tree sạch, không còn `MERGE_HEAD`. |
| 2 | không divergence trên file cả hai nhánh cùng chạm | **PASS** | `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` — giao điểm với BUG-20260927-001 (BR-16) — `git diff 70ddb8b8 HEAD -- <file>` **rỗng**: nội dung bản vá của `main` có mặt nguyên văn trong cây integration. Bản vá không bị merge ghi đè, và cổng nội dung của story chạy cùng lúc với nó. |
| 3 | schema/migration cộng thêm, tuần tự, không xung đột | **PASS** | `cupid_database.dart:86` `schemaVersion => 11`; bản `main` cùng dòng là `10` → bump đúng một bậc, không nhánh nào khác đang tranh `11` (requirement chỉ có một story). Bước nâng cấp ở `:153` (`else if (from < 11)`). |
| 4 | asset/pack mới phân giải được lúc chạy | **PASS** | `pubspec.yaml` diff so với `main` là **một dòng duy nhất**: `- assets/data/req017/`. `checkin_capture_content.dart:9` khai path `assets/data/req017/checkin_capture.v1.json`, khớp thư mục đã đăng ký, và file có thật trong cây (`A mobile/assets/data/req017/checkin_capture.v1.json`). |
| 5 | luồng end-to-end cấp requirement còn nguyên sau merge | **PASS** | Đọc trực tiếp trong cây integration, không suy từ prose: `evening_check_in_sheet.dart:369-380` mount `CheckinCaptureBlock` (có `eveningCheckInCaptureKey`, `onRetry`, `kindMissing`); `:753` `loadCheckInCaptureCopy()`; `context_notebook_entry_point.dart:85-90` `openNotebookScreen` đẩy `NotebookScreen` trên route riêng. Hai đầu của luồng (ghi ở check-in, đọc + nhãn ở Sổ tay) đều còn mắc. |
| 6 | configuration guide (rule 12a) | **NOT_REQUIRED — đúng** | Thay đổi cấu hình duy nhất của toàn requirement là dòng asset dir ở gate 4. Không env var, không secret, không dependency mới, không third-party, không bước thiết lập thủ công. `req_master.md` `## Configuration Documentation` `Status: NOT_REQUIRED` khớp với phạm vi đã đổi. |
| 7 | `## Integration Build & Runtime` (rule 12g3) | **MISSING — F-I1** | Không có file nào dưới `integration-review/` chứa hai dòng đó. `req_master.md` không có `Integration-Verify: WAIVED`. |
| 8 | `mobile-visual-audit.md` cấp requirement (rule 12g2) | **MISSING — F-I2** | `integration-review/` không có file này. Mọi requirement mobile trước đó (REQ-001, 002, 007, 009, 010, 011, 012, 016) đều có. |
| 9 | visual fidelity per story (12e2/12e3) | **PASS — không mở lại** | `visual-fidelity/visual-fidelity-report.md:3` `VISUAL_FIDELITY: PASS`; story review đã mở ảnh ra nhìn và tự chạy lại gate kèm negative control. Gate 8 là kiểm cross-screen riêng, **không** thay gate này theo chiều nào (rule 12g2). |
| 10 | bằng chứng runtime/entry-point cấp story còn đúng cho cây merge | **PASS** | `coding-plan/test-results.md:788-856` `## Entry Point Reachability` (`Reachable: YES` cả hai bề mặt), `:858-914` `## Story Runtime Startup Smoke`, `:916-931` `## AC-5 — Deviation đã khai báo`. Vì cây merge trùng khít cây story tip (gate 1), bằng chứng này không bị cũ đi bởi merge. Nó là **đầu vào** cho F-I1, không phải sự thay thế. |

## Blocking findings

### F-I1 — thiếu `## Integration Build & Runtime` trên nhánh merge (rule 12g3)

- **Bề mặt rủi ro**: app lifecycle + persistence/schema/migration. Đây là requirement nâng drift
  `schemaVersion` 10 → 11, tức rủi ro thật là máy đã có dữ liệu ở v10 mở app lần đầu sau cập nhật.
- **Đang có gì**: bằng chứng cấp story ở `test-results.md:858-914` (build → `uninstall -k` + cài đè
  giữ data → khởi chạy nguội hai lượt → ảnh màn mở → quét 972 dòng logcat), đã được story review đối
  chiếu và chốt ĐÓNG.
- **Còn thiếu gì**: chính hai dòng verdict trên **nhánh merge**, trong một file dưới
  `integration-review/`. `Runtime: NOT_APPLICABLE` không phải pass.
- **Vì sao không hạ xuống DEFERRED**: rule 12c cấm ghi `DEFERRED_ONLY` cho gate là bằng chứng chính
  của hành vi đã đổi, và DONE gate cưỡng chế 12g3 độc lập — trả `DEFERRED_ONLY` ở đây chỉ dồn tắc
  sang bước đóng requirement.

### F-I2 — thiếu `integration-review/mobile-visual-audit.md` cấp requirement (rule 12g2)

- **Bề mặt rủi ro**: mobile navigation/discoverability + cross-screen consistency. Requirement sửa
  hai màn REQ-016 đang chạy (`23h-vua-ve-j8` và `2-so-tay-nguoi-yeu`) chứ không thêm màn mới, nên
  đúng loại rủi ro mà ảnh chụp một màn của story không bắt được: khối hỏi mới đẩy layout màn check-in,
  và nhãn xuất xứ mới thêm dòng vào mỗi mục Sổ tay.
- **Phạm vi đủ**: hẹp — hai màn đó cộng shell/nav quanh chúng. Không cần quét lại toàn app.
- **Ranh giới vai**: chụp thiết bị/emulator thuộc mobile-dev (rule 12e3). Reviewer không chụp lại và
  không tự viết verdict.
- **Nếu Scrum Master phán quyết `NOT_APPLICABLE`**: đó là quyền của Scrum Master và phải ghi vào
  `req_master.md` để đọc lại được. Báo cáo này không tự suy ra miễn trừ đó — rule 12g2 không có ngoại
  lệ cho requirement một story, và tám requirement mobile trước đều có artifact này.

## Deferred findings

Toàn bộ carry-forward của story review được mang sang **nguyên trạng**, không mở lại, không đổi
phân loại: R-1 (AC-8(i) sub-frame dedup latch, tuỳ chọn), F-2 (migration `else if` maintainability —
đã đối chiếu: đúng `cupid_database.dart:153`, đúng ở v11, chỉ là nợ cho lần thêm cột sau), F-5 (gate
asymmetry required-id — khớp doc-comment `context_content_gate.dart:47`), P3-U1, P3-U2, O-4, O-5, và
ghi chú prose cũ ở `coding-plan/phase-P4-notebook-origin-label.md` §4:86. Deviation AC-5 "đổi loại"
đã là deviation user chấp thuận (Option B, `test-results.md:916-931`) — **không** mở lại.

Thêm hai ghi chú cấp requirement phát sinh từ pass này:

- **D-I1 — dòng registry lệch trạng thái.** `req_master.md` `## User Stories` ghi STORY-001
  `Status: TODO`, trong khi `story_master.md:3` là `IN_PROGRESS` và story đã review-pass + merge.
  Dòng cũ này là thứ khiến một story đã giao bị điều phối lại. Scrum Master sở hữu cập nhật (rule 17).
- **D-I2 — topology merge-về-main.** `main` tip `70ddb8b8` **không** là ancestor của integration HEAD
  (nhánh cắt từ `908d22d8`), nhưng nội dung bản vá `70ddb8b8` có mặt nguyên văn trong cây (gate 2).
  Nên merge về `main` sẽ là merge thật chứ không fast-forward, và theo nội dung thì không có xung đột
  nào phải giải. Ghi lại để lần merge đó không bị đọc nhầm là divergence.

## Traceability

- **Merged stories / merge refs**: bảng `## Merged stories và story review`. Merge commit
  `a15bde4f`, parents `908d22d8` (main-side) ⊕ `dd46d89d` (story tip).
- **Story review reports**: `STORY-001_checkin_notebook_capture/review/review-report.md`
  (`Outcome: DEFERRED_ONLY`) cùng bốn slice `slice-p1-schema.md`, `slice-p2-content-pack.md`,
  `slice-p3-capture-ui.md`, `slice-p4-origin-label.md`. AC-1..AC-17 đã có verdict ở
  `## Traceability — AC → slice chốt → verdict` của báo cáo đó; pass này không chấm lại.
- **Integration evidence**: git diff/ancestry đã nêu trong bảng gate; `test-results.md` ba mục
  :788-856, :858-914, :916-931; `visual-fidelity/visual-fidelity-report.md:3`.
- **Runtime/configuration**: `req_master.md` `## Configuration Documentation` `NOT_REQUIRED` — xác
  nhận đúng (gate 6). `## Deployment Status` vẫn `NOT_DEPLOYED`/`NOT_REQUESTED`, phù hợp: không có
  triển khai nào được yêu cầu trong requirement này.
- **Cross-story contracts**: không có (một story). Hợp đồng **cross-requirement** đã kiểm: BR kế thừa
  REQ-016 R-1f (không xuất/chia sẻ), SC-3 (không điền sẵn), R-15 (nội dung có id bền qua cổng nhập),
  BR-12 (không ghi vào thẻ) — đều đã do story review chốt PASS ở AC-6/AC-9/AC-14/AC-15; tầng
  integration chỉ xác nhận không có gì trong merge phá chúng (gate 2 và gate 4).
- **OQ discipline**: `req_master.md` `## User Decisions` — OQ-1, OQ-2, A-5 đều RESOLVED 2026-09-27;
  `story_master.md` `## Open Question Impact` không ghi phạm vi nào bị chặn. Không lỗi OQ (rule 12).

## Action items

1. **[mobile-dev hoặc devops — integration-verification pass]** F-I1: trên nhánh
   `codex/REQ-017_checkin_notebook_capture-integration` (không phải nhánh story), chạy một lần build
   thật và một lần khởi chạy thật, rồi ghi vào **một file** dưới
   `data/requirements/REQ-017_checkin_notebook_capture/integration-review/` (tiền lệ REQ-016 đặt tên
   `build-runtime-evidence.md`) một mục `## Integration Build & Runtime` chứa cả hai dòng, verdict là
   từ đầu tiên sau dấu hai chấm:
   - `- Build: PASS — <lệnh + kết quả>`
   - `- Runtime/Smoke: PASS — <lệnh khởi chạy + kết quả>`
   Smoke cần đúng rủi ro của requirement này: cài **đè** lên bản đã có dữ liệu v10 (giữ data) rồi
   khởi chạy, để chứng minh nâng `schemaVersion` 10 → 11 không crash — cài sạch che mất chính rủi ro
   đó. `Runtime: NOT_APPLICABLE` không được tính là pass.
2. **[mobile-dev — mobile visual audit]** F-I2: tạo
   `data/requirements/REQ-017_checkin_notebook_capture/integration-review/mobile-visual-audit.md`,
   phạm vi hẹp ở hai màn đã đổi (`23h-vua-ve-j8` với khối hỏi mới, `2-so-tay-nguoi-yeu` với nhãn xuất
   xứ) cộng shell/nav quanh chúng. Đây là kiểm cross-screen, không phải chụp lại per-story (ảnh
   per-story đã PASS và không được chụp lại).
3. **[Scrum Master]** D-I1: sửa dòng STORY-001 trong `req_master.md` `## User Stories` cho khớp
   trạng thái thật sau story review + merge. Nếu phán quyết F-I2 là `NOT_APPLICABLE`, ghi phán quyết
   đó vào `req_master.md` để đọc lại được, thay vì để artifact vắng mặt không lý do.
4. **[không bắt buộc]** dọn nợ prose đã ghi nhận: `phase-P4-notebook-origin-label.md` §4:86 và O-4.

## Khuyến nghị trạng thái

- `Review (Reviewer)` cấp requirement: để **chưa tick**.
- Requirement status: `IN_PROGRESS` (không phải `DONE`). Requirement chỉ đóng được sau khi F-I1 và
  F-I2 có artifact, và Scrum Master sở hữu việc chuyển trạng thái (rule 17).
- Nhánh story: đã merge sạch, **không** cần rework code và **không** cần trả story về lane nào. Hai
  action item là bằng chứng cấp requirement trên nhánh integration, không phải defect trong
  `mobile/lib/**`.
- Sau khi F-I1/F-I2 xong, một pass `completion/resume` hẹp trên đúng báo cáo này là đủ — không cần
  review lại từ đầu, và không đọc lại `mobile/lib/**` hay bốn slice story.
