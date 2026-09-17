# Review Report — REQ-016 / STORY-010 Bảng tra ăn khớp

Outcome: BLOCKED

- Review type: `compact-story-review` — **lượt 2 (patch re-review)**
- Lane: mobile (không có làn backend/frontend — `architecture/solution.md` §1 Key Discovery 1)
- Baseline lượt này: `git -C <worktree> diff 47233dac aaa2021a` (12 file, worktree sạch, HEAD `aaa2021a`)
- Baseline story gốc: `b58afbe0` (đã review đầy đủ ở lượt 1)
- F-1…F-5: **ĐÃ ĐÓNG cả năm** · F-6 còn mở · Deferred: 4

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

**Review type:** compact-story-review, patch re-review (parallel-story, Story-Class standard)

**Source/Test Files In Scope (chỉ phần patch chạm)**
- `mobile/test/core/database/relationship_labels_migration_test.dart` (mới)
- `mobile/test/features/compatibility_lookup/compatibility_lookup_screen_test.dart` (hunk tên ảnh)

Patch **không chạm file `lib/` nào** (`git diff --stat 47233dac aaa2021a`), nên mọi
kết luận PASS về mã sản phẩm ở lượt 1 còn nguyên hiệu lực và không được kiểm lại.

**Evidence Files In Scope**
- `coding-plan/test-results.md` — `## Phase Status`; `## Lượt vá F-1..F-5 — Commands Run`;
  `## Entry Point Reachability`; `## Story Runtime Startup Smoke`;
  `## Phủ test đường nâng cấp v6 → v7`; `## Đổi tên ảnh visual-fidelity theo quy ước cổng`
- `visual-fidelity/visual-fidelity-report.md`
- 5 ảnh PNG trong `visual-fidelity/` (đã mở mắt thường từng ảnh)
- `../req_master.md` — `## Design Ruling Log` (kiểm có/không dòng phán quyết STORY-010)

**Query Keys**
`F-1`…`F-6`, `Entry Point Reachability`, `Story Runtime Startup Smoke`, `from < 7`,
`relationship_labels`, `implemented-*.png`, `Phase Status`, `Design Ruling Log`

## Kết quả F-1 … F-5

| # | Nội dung | Kết quả | Bằng chứng đã tự kiểm |
|---|---|---|---|
| F-1 | Thiếu mục `## Entry Point Reachability` | **ĐÓNG** | Mục có thật, `Reachable: YES`, bảng 5 bước có cả trích mã lẫn hành vi lúc chạy. Đường đi khớp đúng mã mà lượt 1 đã tự đọc (`gift_ideas_screen.dart` `_GuessRow.onTap` → `openCompatibilityLookup`), và patch không chạm `lib/` nên kết luận đó còn nguyên. Ảnh `runtime-entry-…-emulator-5554.png`: màn (10) thật, AppBar "Bảng tra ăn khớp", đủ dấu tiếng Việt, không chip nào chọn sẵn |
| F-2 | Không có runtime startup smoke, không có miễn trừ | **ĐÓNG** | `## Story Runtime Startup Smoke` = `PASS`, có registry `mobile-app`, `emulator-5554`, `am start -W` → `Status: ok`, `LaunchState: COLD`, `TotalTime 3627ms`, 0 dòng logcat gắn tag lỗi, pid `16495` không đổi trước/sau. Ảnh `runtime-smoke-main-first-screen-…png`: màn (1) home dựng đủ, không red screen. Bốn dòng `NOT_APPLICABLE` cũ đã được thay bằng con trỏ tới mục này |
| F-3 | Migration v6→v7 không test nào phủ | **ĐÓNG** | `relationship_labels_migration_test.dart` mới, group `v6 -> v7`, 5 test. Fixture đúng chỗ khó: `DROP TABLE relationship_labels` + `PRAGMA user_version = 6`, và hai khẳng định "fixture đúng là v6" chạy **trên chính connection đang seed trước khi đóng** (`:90-91`) — đúng cách tránh bẫy `CREATE TABLE IF NOT EXISTS` của drift. Phủ: lên v7 + có bảng, đủ 8 cột, 4 họ dòng client-owned còn nguyên, ghi được ngay sau nâng cấp, khoá duy nhất `(owner_key, subject, system)` còn hiệu lực. Có chứng minh mutation (`if (from < 7 && false)` → 4/5 đỏ) và đã hoàn nguyên |
| F-4 | Ảnh visual-fidelity sai quy ước tên | **ĐÓNG** | Thư mục nay chỉ còn `implemented-10-bang-tra-an-khop-md.png` và `implemented-10-bang-tra-an-khop-md-chua-co-nhan.png`; hai tên cũ đã biến mất khỏi cây. Hằng số trong `compatibility_lookup_screen_test.dart:376,411` sửa theo, hai dòng bảng trong `visual-fidelity-report.md` cập nhật kèm giải thích hậu tố `-md`. Đã mở cả hai ảnh mới: đúng màn của story, không tofu, không khung lỗi, không spinner |
| F-5 | `## Phase Status` mâu thuẫn thân file | **ĐÓNG** | P5/P6 nay ghi `COMPLETE / PASS / PASS`, khớp §P5/§P6 và `master-plan.md` |

Lệnh của lượt vá đã ghi vết, không nối ống: `flutter test test/core/database
test/features/compatibility_lookup test/features/gift_ideas` → `+275 ~4`, 0 đỏ;
harness chụp ảnh 7 passed; `flutter build apk --debug --flavor local
--split-per-abi` PASS.

## Blocking finding còn mở

**F-6 · `VISUAL_FIDELITY: PASS` vẫn chưa có căn cứ: ba chênh lệch canvas-vs-spec do chính báo cáo tự phân xử.**

Patch không chạm phần `## Chênh lệch so với design reference` của
`visual-fidelity-report.md` (diff lượt này chỉ đổi hai dòng bảng tên ảnh + thêm
đoạn giải thích hậu tố `-md`). Ba mục 4/5/6 của mục đó vẫn là tranh chấp
**canvas vs `uiux-spec.md`** thuần tuý, và vẫn đang được kết luận ngay trong báo
cáo bằng lý lẽ của chính làn Mobile:

- mục 5 — tiêu đề khối: canvas dùng caption IN HOA ("CHỖ DỄ HỢP"); bản dựng dùng
  tiêu đề phụ sentence-case theo spec §3.2/§3.3
- mục 6 — hành động "1 hoạt động nên thử": canvas là nút tròn `(+)` icon-only;
  bản dựng là outline chip có chữ theo spec §3.4
- mục 4 — tiêu đề màn: canvas dùng tên cặp; bản dựng dùng tiêu đề tĩnh + dòng
  xuất xứ (mục này **có** viện dẫn AC-11, khác hai mục trên)

Đã kiểm trực tiếp: `req_master.md` `## Design Ruling Log` (dòng 146-213) **không
có dòng phán quyết nào cho STORY-010** — mọi hàng đều thuộc STORY-001. Tham
chiếu STORY-010 duy nhất trong file là hàng Story Seeds `:250`. Tiền lệ của
chính requirement này (hàng `:207`: mục chưa từng ruling thì "áp cùng tiền lệ
anchor on design — Design canvas thắng") nói rằng mục 5 và 6 nhiều khả năng sẽ
phải rework theo canvas, nhưng **phán quyết đó chưa tồn tại**, và quy tắc
reviewer 12e2 cấm chấp nhận một phân xử do chính báo cáo tự đưa ra.

Vì sao `BLOCKED` chứ không phải `PATCH_REQUIRED`: sau lượt vá này **làn Mobile
không còn việc nào có thể làm**. Mục 4 và mục 1 (xem D-1) là xung đột có trích
dẫn AC đối chiếu với phần tử thiết kế — đúng dạng `DESIGN_SPEC_CONFLICT` mà quy
tắc 12e2 yêu cầu trả `BLOCKED` để Scrum Master hỏi user bên nào là mốc neo, chứ
không phải ra lệnh vá; mục 5 và 6 cần một dòng `D-xx` trước khi bất kỳ ai chạm
mã. Định tuyến `PATCH_REQUIRED` sẽ trả story về một làn có danh sách việc rỗng.

**Đầu vào còn thiếu để gỡ chặn (Scrum Master/user sở hữu):**
1. Một dòng trong `req_master.md` `## Design Ruling Log` cho STORY-010 phán
   quyết mục 4/5/6 (mẫu sẵn có: các hàng D-18/D-19/D-28/G-3).
2. Quyết định cho mục 1 (khối DẢI) — xem D-1 dưới đây; đây là mục canvas vẽ một
   UI vi phạm AC-16/AC-17 của chính story, nên không thể đóng bằng "canvas thắng"
   theo lối thông thường.

Sau khi có hai dòng đó: nếu phán quyết giữ nguyên bản dựng thì
`visual-fidelity-report.md` chỉ cần trích dòng `D-xx` thay cho lý lẽ tự phân xử
và story đóng được; nếu phán quyết chọn canvas thì mở một lượt vá Mobile hẹp.

## Deferred (giữ nguyên từ lượt 1, ngoài phạm vi vòng này)

**D-1 · Frame canvas `10-bang-tra-an-khop` đang vẽ một UI vi phạm AC của chính story.**
Canvas vẽ "HAI ĐỨA HỢP TỚI ĐÂU" là thanh gradient 3 mốc + nhãn "khá hợp"; AC-16/AC-17,
`uiux-spec.md` §3.1 và R-8 cấm tuyệt đối mọi thành phần trả lời được "đầy bao nhiêu
phần". Bản dựng làm đúng (chip chữ tĩnh "Khác nhịp, bù nhau") — mục do AC chi phối,
không rework. Cần UI/UX sửa frame; ngoài write scope của làn Mobile. Ghi chú lượt 2:
mục này có trích dẫn AC đối chiếu phần tử canvas, nên nó là một nửa căn cứ của
`BLOCKED: DESIGN_SPEC_CONFLICT` ở F-6, không còn thuần "không chặn story".

**D-2 · Kiểm duyệt lớp 2 (AC-35 / D-15) chưa được cấp.** 400 ô seed sẵn sàng nhưng
chưa được user duyệt để vào bản dựng người dùng thật. P5/P6 ghi vết đúng, không tự
phê duyệt. Scrum Master đưa bộ seed cho user duyệt trước khi phát hành.

**D-3 · Ba test đỏ có sẵn ở `test/features/love_contracts`.** Đã chứng minh có trước
bằng `git stash` asset P6 + chạy lại (`+80 -3`, đúng ba test đó). Ngoài phạm vi story.

**D-4 · Findings 1/2/5/7/9 của `test-results.md`** (lệch AC id trong file phase P1;
AC-32 chưa có chủ ở tầng dữ liệu; `frequencyProbe` áp cả bốn trường; gỡ khoá
`gift_ideas_guess_coming_soon` cần đối soát STORY-009; quy ước giọng của `question`)
— đều ghi vết rõ, không mục nào phá AC đã duyệt của story này.

**D-5 (mới, không chặn) · Va chạm `schemaVersion` 6→7 giữa các nhánh song song.**
Lượt vá phát hiện lúc chạy thật: máy đã có DB v7 của một nhánh khác
(`portrait_answers`), nên `from == to == 7` và bước `if (from < 7) createTable
(relationshipLabels)` không bao giờ chạy — màn (10) dựng trống,
`SqliteException: no such table: relationship_labels`. Đã ghi vết đầy đủ trong
`test-results.md` §"Va chạm `schemaVersion`…". Không phải lỗi của STORY-010 và
không sửa được trong làn này; đúng như handoff nêu, đây là việc của
`requirement-integration-review` (đánh số riêng cho mỗi story, hoặc gộp đủ
`createTable` vào bước v7). Ghi ở đây để bước integration không phải tìm lại.

## Bề mặt rủi ro — trạng thái sau lượt vá

| Bề mặt rủi ro (12b) | Cổng tới hạn | Kết quả |
|---|---|---|
| persistence/schema/migration (v6→v7) | test đường nâng cấp | **PASS** (F-3 đóng) |
| app lifecycle / khởi động | runtime startup smoke | **PASS** (F-2 đóng) |
| mobile navigation/discoverability | `Entry Point Reachability` + tự đọc mã | **PASS** (F-1 đóng) |
| design fidelity (làn mobile, 12e3) | hai ảnh thật + `VISUAL_FIDELITY` có đối chiếu | **CHẶN** — ảnh đạt, phán quyết chênh lệch chưa có (F-6) |
| typed/generated contract · local storage/offline · mobile interaction · nội dung dạng dữ liệu · build/type-check | — | PASS từ lượt 1, patch không chạm `lib/`, không kiểm lại |

## Khuyến nghị trạng thái

- Để trống `Review (Reviewer)`; đặt story về `BLOCKED`.
- Không trả về làn Mobile: F-1…F-5 đã đóng, làn này không còn việc.
- Scrum Master/user xử: F-6 (dòng `D-xx` trong Design Ruling Log), D-1 (định tuyến
  UI/UX sửa frame), D-2 (duyệt lớp 2). Gỡ xong F-6 thì story đóng được ngay hoặc
  cần đúng một lượt vá Mobile hẹp, tuỳ phán quyết.
- D-5 chuyển thẳng cho `requirement-integration-review`.

## Ghi chú cấu hình

Không phát hiện tác động setup/configuration: story không chạm Docker, Compose,
registry runtime, biến môi trường, hay script môi trường cục bộ. Không yêu cầu
`deployment/configuration-guide.md`.
