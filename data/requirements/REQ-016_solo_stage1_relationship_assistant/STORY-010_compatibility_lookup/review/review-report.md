# Review Report — REQ-016 / STORY-010 Bảng tra ăn khớp

Outcome: DEFERRED_ONLY

- Review type: `completion/resume` trên `compact-story-review` — **lượt 3**
- Lane: mobile · Story-Class standard · HEAD `1651702f`
- Lượt 1 (`b58afbe0`): PATCH_REQUIRED, F-1…F-6 · Lượt 2 (`aaa2021a`): BLOCKED, F-1…F-5 đóng, F-6 còn mở
- Lượt 3 (`1651702f`): **F-6 đóng** · Blocking findings: 0 · Deferred: 8

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Phạm vi vòng này đúng bằng phần handoff nêu: diff `aaa2021a → 1651702f` cộng hai
file bằng chứng đang sửa trong working tree. Không mở lại các bề mặt đã PASS ở
lượt 1/2 và không đọc lại `uiux-spec.md` toàn phần, `master-plan.md`,
`architecture/*`, `requirements.md` (chỉ tra nguyên văn AC-33 và R-7 theo dòng để
kiểm một luật bị chạm — xem F-6 dưới).

**Source/Test Files In Scope**
- `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_facet_block.dart`
- `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_activity_block.dart`
- `mobile/test/features/compatibility_lookup/compat_result_widgets_test.dart` (2 test mới)

**Evidence Files In Scope**
- `visual-fidelity/visual-fidelity-report.md` (bản đã dựng lại, **chưa commit**)
- `visual-fidelity/implemented-10-bang-tra-an-khop-md.png` (chụp lại, **chưa commit**)
- `coding-plan/test-results.md` §"Vá F-6 mục 5 và mục 6"
- `coding-plan/master-plan.md` bảng Phases Overview
- `ux/uiux-spec.md` §3.2/§3.3/§3.4 (chỉ phần diff)
- `../req_master.md` `## Design Ruling Log` — **đọc ở control checkout**, xem ghi chú D-8

**Query Keys**
`F-6`, `mục 5`, `mục 6`, `caption`, `toUpperCase`, `Semantics`, `44`,
`Design Ruling Log`, `R-7`, `AC-33`, `VISUAL_FIDELITY`

## F-6 — ĐÓNG

Bốn phán quyết cho STORY-010 tồn tại thật, ngày 2026-09-17, trong
`data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md`
`## Design Ruling Log` dòng 213-216 (control checkout):

| Mục | Phán quyết | Bản dựng có khớp không |
|---|---|---|
| 1 — khối DẢI gradient | Đóng bởi Scrum Master: canvas tự vi phạm AC-16/AC-17 nên **không** thắng bằng thẩm quyền "design thắng"; bản dựng đúng, đây là **design-source defect**, **không chặn STORY-010** | Có — không sửa mã, đúng như phán quyết yêu cầu |
| 4 — tiêu đề màn | Đóng bởi Scrum Master: AC-11 cho phép hai hệ nhãn cùng ra kết quả nên "tên cặp" không tổng quát được; bản dựng đúng | Có — không sửa mã |
| 5 — kiểu tiêu đề khối | **User chốt qua AskUserQuestion: Theo DESIGN (IN HOA)**; mobile-dev được uỷ quyền vá `uiux-spec.md` §3.2/§3.3 phạm vi hẹp | Có — xem dưới |
| 6 — hành động "1 hoạt động nên thử" | **User chốt qua AskUserQuestion: Theo DESIGN (nút tròn icon-only)**, kèm điều kiện "target chạm đủ lớn" | Có — xem dưới |

Đây chính là đầu vào mà lượt 2 trả `BLOCKED` để chờ. Nó đã có, và có thẩm quyền
đúng loại (user cho hai mục thuần kiểu dáng, Scrum Master cho hai mục do AC chi
phối). Không còn mục nào do chính báo cáo tự phân xử.

**Đã tự kiểm mã, không tin tiêu đề mục:**

- Mục 5 — `compat_facet_block.dart:60` đổi `titleStyle` từ `type.body` +
  `w600` sang token `type.caption`, và `:88-95` bọc
  `Semantics(label: _title(l10n), excludeSemantics: true)` quanh
  `Text(_title(l10n).toUpperCase())`. IN HOA nằm đúng ở tầng glyph; chuỗi l10n
  nguồn không đổi nên trình đọc màn hình không đánh vần từng chữ cái.
- Mục 6 — `compat_activity_block.dart:75-105`: `Semantics(button: true,
  label: compat_add_to_my_store_action, excludeSemantics: true)` bọc
  `GestureDetector` (`HitTestBehavior.opaque`) → `SizedBox(44, 44)` →
  `DecoratedBox(shape: BoxShape.circle)` + `CupidIcon(add, size 20)`. Điều kiện
  trợ năng mà phán quyết kèm theo được thoả bằng cả vùng chạm lẫn tên đọc được.

**Luật R-7 không bị phá.** Đã tra nguyên văn: R-7 ở `req_master.md`
`## Invariant Design Rules` mục 7 là luật **nội dung** ("không AI ở runtime",
"mỗi ô bắt buộc có ít nhất một điểm cọ xát"), không nói gì về kiểu chữ; AC-33
(`requirements.md:277`) nói về chỉ số gắn kết. Cấm "thu nhỏ cỡ chữ xuống
`caption`" chỉ tồn tại trong văn xuôi `uiux-spec.md` §3.3 — đúng tầng mà tiền lệ
neo-thiết-kế của REQ-016 cho phép vá, và phán quyết mục 5 uỷ quyền vá tường
minh. Bản vá spec giữ nguyên bất biến thật (đối xứng "hợp"/"va"), chỉ viết lại
cho đúng: "điều bị cấm là lệch nhau, không phải bản thân cỡ `caption`". Vì cả hai
mặt dùng chung một widget, đối xứng không thể lệch qua đường này.

**Ảnh bằng chứng đã mở mắt thường** (`implemented-10-bang-tra-an-khop-md.png`
bản chụp lại): "CHỖ DỄ HỢP"/"CHỖ DỄ VA" hiện IN HOA, cùng cỡ cùng độ đậm cùng
màu, đủ dấu (Ỗ/Ễ không rơi), không ô tofu; nút hoạt động là vòng tròn viền tím
có dấu `+`, không còn chữ. Ảnh khớp với mã ở `1651702f` và không mâu thuẫn
`VISUAL_FIDELITY: PASS`.

**Test khoá đúng hai luật vừa dựng** (`compat_result_widgets_test.dart`, 2 test
mới): khẳng định glyph `.toUpperCase()`, cỡ/độ đậm đọc từ `type.caption` của
theme chứ không hard-code, `find.bySemanticsLabel(<chuỗi sentence case>)` tìm
thấy cho cả hai khối, `find.text(nhãn)` là `findsNothing` trong khi
`find.bySemanticsLabel(nhãn)` là `findsOneWidget`, `BoxDecoration.shape ==
BoxShape.circle`, và `tester.getSize(button) >= 44x44`. Đây là test chống trôi
ngược thật, không phải test hình thức.

Lệnh: `flutter test test/features/compatibility_lookup/` → `+88 ~3` (3 `~` là
test chụp ảnh `skip` khi không bật cờ), và bản chạy có
`--dart-define=CAPTURE_VISUALS=true` → `+7`. `master-plan.md` Phases Overview
đổi cả sáu phase `COMPLETE` → `DONE`.

## Bề mặt rủi ro — trạng thái cuối

| Bề mặt rủi ro | Cổng tới hạn | Kết quả |
|---|---|---|
| design fidelity (làn mobile, 12e3) | hai ảnh thật + `VISUAL_FIDELITY: PASS` có đối chiếu, mọi chênh lệch đã đóng | **PASS** |
| persistence/schema/migration (v6→v7) | test đường nâng cấp | PASS (F-3, lượt 2) |
| app lifecycle / khởi động | runtime startup smoke trên `emulator-5554` | PASS (F-2, lượt 2) |
| mobile navigation/discoverability | `Entry Point Reachability` + tự đọc mã cửa vào | PASS (F-1, lượt 2) |
| mobile interaction | test widget/hành vi + 2 test mới cho affordance đã đổi | PASS |
| typed/generated contract · local storage/offline · nội dung dạng dữ liệu · build/type-check | — | PASS (lượt 1, vòng này không chạm) |

## Deferred (không mục nào chặn story)

**D-1 · Frame canvas `10-bang-tra-an-khop` vẫn vẽ một UI vi phạm AC-16/AC-17.**
ĐÃ ĐÓNG về mặt phán quyết (dòng 213): design-source defect, bản dựng đúng, không
sửa mã, **không chặn STORY-010**. Việc còn lại là UI/UX sửa frame ở một lượt UX
riêng — ngoài write scope làn Mobile.

**D-2 · Kiểm duyệt lớp 2 (AC-35 / D-15) chưa được cấp.** 400 ô seed sẵn sàng
nhưng chưa được user duyệt để vào bản dựng người dùng thật. P5/P6 ghi vết đúng,
không tự phê duyệt. Scrum Master đưa bộ seed cho user duyệt **trước khi phát
hành**, không phải trước khi merge.

**D-3 · Ba test đỏ có sẵn ở `test/features/love_contracts`.** Đã chứng minh có
trước (`git stash` asset P6 → vẫn `+80 -3` đúng ba test đó). Ngoài phạm vi story.

**D-4 · Findings 1/2/5/7/9 của `test-results.md`** (lệch AC id trong file phase
P1; AC-32 chưa có chủ ở tầng dữ liệu; `frequencyProbe` áp cả bốn trường; gỡ khoá
`gift_ideas_guess_coming_soon` cần đối soát STORY-009; quy ước giọng của
`question`) — đã ghi vết rõ, không mục nào phá AC đã duyệt của story này.

**D-5 · Va chạm `schemaVersion` 6→7 giữa các nhánh song song.** STORY-010 và
STORY-009 cùng nâng lên v7 với bảng khác nhau; trên máy đã chạy nhánh kia,
`from == to == 7` nên `onUpgrade` bỏ qua `createTable(relationshipLabels)` và
màn (10) dựng trống. Bắt được lúc chạy thật, ghi vết đầy đủ trong
`test-results.md` §"Va chạm `schemaVersion`…". **Chuyển thẳng cho
`requirement-integration-review`**: hoặc mỗi story một số riêng, hoặc bước v7 gộp
đủ `createTable`.

**D-6 · (mới) Tiêu đề "1 hoạt động nên thử" vẫn sentence-case.** Canvas vẽ IN
HOA. Phán quyết mục 5 chỉ nêu đích danh hai khối "hợp"/"va", nên mobile-dev
không tự mở rộng — đúng kỷ luật. Hệ quả: trong cùng một chồng kết quả đang có hai
kiểu tiêu đề khối. Cần một dòng phán quyết bổ sung nếu Scrum Master muốn đồng bộ.
Thuần thẩm mỹ, không chạm AC nào.

**D-7 · (mới) Vị trí nút `(+)`.** Canvas đặt nút cùng hàng bên phải đoạn văn hoạt
động; bản dựng đặt ở hàng riêng, canh trái. Phán quyết mục 6 chỉ nói về **hình
dạng** nút, không nói vị trí, nên bố cục giữ nguyên. Thuần thẩm mỹ, chưa được
phán quyết.

**D-8 · (mới, dọn dẹp — Scrum Master) Ba việc trước khi merge.**
1. `visual-fidelity/visual-fidelity-report.md` và
   `visual-fidelity/implemented-10-bang-tra-an-khop-md.png` đang **chưa commit**
   trong worktree. Cổng DONE và merge đọc trạng thái đã commit, nên phải commit
   hai file này.
2. Bản `req_master.md` **trong worktree story đang cũ**: không có dòng 213-216.
   Bốn phán quyết chỉ có ở control checkout. Bất kỳ ai review chỉ từ worktree sẽ
   thấy `visual-fidelity-report.md` trích một phán quyết "không tồn tại" — đúng
   cái bẫy mà lượt 2 suýt kết luận sai. Merge nhánh integration sẽ tự mang vào,
   nhưng nên biết trước.
3. `test-results.md` §"Còn mở sau lượt vá" mục 1 nay đã cũ: nó nói
   `visual-fidelity/` chưa cập nhật vì ngoài WriteScope, trong khi một lượt sau
   đã cập nhật xong. Sửa một dòng hoặc bỏ qua.

## Khuyến nghị trạng thái

- Giữ `Implementation (Development)` đã tích; **tích `Review (Reviewer)`**.
- Story status: **DONE** (Scrum Master sở hữu thao tác này).
- **Merge-eligible: CÓ**, sau khi commit hai file bằng chứng ở D-8 mục 1.
- Chuyển D-5 cho `requirement-integration-review`; D-2 cho user trước phát hành;
  D-1/D-6/D-7 cho một lượt UX/phán quyết riêng, không chặn.

## Ghi chú cấu hình

Không phát hiện tác động setup/configuration: story không chạm Docker, Compose,
registry runtime, biến môi trường, hay script môi trường cục bộ. Không yêu cầu
`deployment/configuration-guide.md`.
