# Slice S6b — Quiet surfaces + hub/card integration (phase-P8)

Review type: scoped-slice
Slice: S6b
Story: STORY-012_phase_status_and_widget
Requirement: REQ-016_solo_stage1_relationship_assistant
Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget
BaseHead: b58afbe073eff4e1ebb9151735221532a9cf5a82
Reviewed at: 2026-09-17

REVIEW_SLICE_COMPLETE: YES

## Files Reviewed

Đúng 8 tệp mà `review/scope-gate.md` (dòng 107-115) liệt kê cho S6b. Diff đo bằng
`git -C <Worktree> diff b58afbe0 HEAD -- <8 tệp>`: 1290 thêm / 9 xoá.

| # | Tệp | Trạng thái |
| --- | --- | --- |
| 1 | `mobile/lib/features/phase_status/presentation/wealth_counter_line.dart` | mới, 83 dòng |
| 2 | `mobile/lib/features/phase_status/presentation/gift_progress_block.dart` | mới, 112 dòng |
| 3 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart` | +155 / -9 |
| 4 | `mobile/lib/features/activity_cards/presentation/widgets/activity_card_tile.dart` | +51 |
| 5 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | +26 |
| 6 | `mobile/test/features/phase_status/wealth_counter_line_test.dart` | mới, 335 dòng |
| 7 | `mobile/test/features/phase_status/gift_progress_block_test.dart` | mới, 258 dòng |
| 8 | `mobile/test/features/phase_status/quiet_surfaces_capture_test.dart` | mới, 270 dòng |

Văn bản điều chỉnh đã đối chiếu nguyên văn trong slice này: AC-14, AC-15, AC-20,
AC-21, AC-22, AC-24..AC-29, AC-38, BR-7, BR-9, BR-12, BR-15/R-15a.

## Verdicts

| Bề mặt rủi ro | Cổng | Kết quả |
| --- | --- | --- |
| Counter là lực lượng của một tập bền vững, không phải dự đoán về người kia | AC-20, AC-24..AC-27 | PASS |
| Không có mục tiêu số, thanh tiến độ, hạn chót, so sánh | AC-25..AC-27 | PASS |
| Màn hình yên tĩnh không có bề mặt quà và không mời tạo dữ liệu | AC-21 | PASS |
| Giảm số không sinh kịch tính | AC-29 | PASS |
| Cột mốc chỉ hiển thị, không mời mời-người-kia / không mở luồng hai chiều | AC-28 | PASS (xem N-2) |
| Drip thưa, không bao giờ hằng ngày; không hỏi policy ngoài pha quiet | AC-22, BR-9 | PASS |
| Trống là im lặng, không phải thông báo lỗi | AC-38 | PASS có điều kiện (xem F-1) |
| Không chữ hiển thị trong `.dart`; mọi câu lấy từ content pack | BR-15/R-15a | PASS (đóng N-1 của S6a) |
| Không đụng `activity_card_repository.dart` | BR-12 | Bất biến PASS; test canh gác vô hiệu (F-2) |
| Đếm ngược thẻ dùng mạch đồng hồ `today`, không `DateTime.now()` ẩn | AC-14, AC-15 | PASS |
| Làm mới khi resume / sau khi đóng màn chi tiết | AC-20 | PASS |
| Thứ tự dựng: counter nằm trên dải quick-entry, không dính header ghim | UX | PASS |

Các mục S6a bàn giao cho S6b:

- **N-1 của S6a (đóng)** — cả `WealthCounterLine` và `GiftProgressBlock`/
  `DripCaptionLine` chỉ nhận `String?` đã được chọn và đã thế số từ tầng cubit;
  không có một câu hiển thị nào nằm trong mã. Test khẳng định ngược lại bằng nội
  dung đọc thẳng từ `nudges.v1.json`/`drip.v1.json` trên đĩa, nên nếu ai đó cứng
  hoá chuỗi thì test vẫn đỏ.
- **F-1 của S6a (consume-on-resolve), phần call site** — các widget vẽ đúng thứ
  mà `PhaseStatusState` mang sang trong cùng một lần build, không tự gọi resolver,
  không resolve suy đoán. Có đúng một ngoại lệ, ghi thành F-1 dưới đây.

## Test Evidence

`coding-plan/test-results.md` dòng 1114-1213 (phase P8), đã đọc lại nguyên vùng:

| Lệnh | Kết quả |
| --- | --- |
| `flutter analyze lib test` | 227 issues, 0 error (nền 225 / 0 error) |
| `flutter test .../wealth_counter_line_test.dart` | +12 |
| `flutter test .../gift_progress_block_test.dart` | +7 |
| `flutter test .../quiet_surfaces_capture_test.dart` | +1 ~1, và +2 khi bật `--dart-define=CAPTURE_VISUALS=true` |
| `flutter test .../phase_status/ .../activity_cards/` | +439 ~8 |

Bằng chứng ảnh: đã mở và nhìn trực tiếp `visual-fidelity/implemented-quiet-surfaces.png`
và `visual-fidelity/design-reference-j12-nhan-ra-cot-moc-ios.png` (tên file đã được
đổi lại đúng id canvas gốc trong lượt patch2, nội dung ảnh không đổi — Scrum Master
cập nhật đường dẫn này ngày 2026-09-19 theo `followup_out_of_writescope` của run
patch2).

Finding 4 trong test-results.md tự khai rằng lượt chạy suite đã ghi đè PNG
visual-fidelity của STORY-002 và đã khôi phục bằng `git checkout --`. Tôi xác nhận
`git status` hiện sạch ở vùng đó, nên hệ quả đã được dọn.

## Findings

### F-1 — `WealthCounterLine` nuốt cột mốc đã bị tiêu thụ khi nhãn counter vắng mặt

Mức: MEDIUM. Không chặn với bộ content đang ship, nhưng là mất dữ liệu một chiều
khi bộ content đổi.

`wealth_counter_line.dart:34-36` thoát sớm dựa **chỉ** vào nhãn counter:

```dart
final String? line = label;
if (line == null || line.isEmpty) {
  return const SizedBox.shrink();
}
```

`milestone` được đọc mãi sau đó (dòng 40) nên nằm hoàn toàn trong nhánh bị bỏ.
`activity_card_hub_view.dart:168-171` là nơi duy nhất truyền `milestone`, nên không
có bề mặt nào khác vẽ bù.

Điều làm nó thành mất mát vĩnh viễn chứ không phải một khung hình lỡ: `milestone_resolver.dart:72`
ghi `setMilestoneLastShownValue(crossed)` **trước** khi trả kết quả, đúng như ghi chú
của cubit ở `phase_status_cubit.dart:224-229 ("Both resolve and nextItem consume their
slot as a side effect")`. Ngưỡng bị đốt xong mà câu công nhận không bao giờ tới màn hình,
và lần refresh sau sẽ không vượt lại ngưỡng đó nữa.

Đường tới được: `counterLabel` đến từ `_nudgeBody(catalogue.nudges, NudgeSlot.counter, ...)`
(`phase_status_cubit.dart:209-213, 280-295`), trả `null` khi pack không có mục slot
`counter`. Pack `nudges.v1.json` đang ship có mục đó, nên **hôm nay không tái hiện được**.
Nhưng toàn bộ thiết kế content-as-data (BR-15/R-15a) tồn tại để sửa pack mà không đụng
mã; một lượt biên tập bỏ hoặc đổi tên slot `counter` sẽ lặng lẽ giết cột mốc của mọi
người dùng đang vượt ngưỡng, và AC-38 chỉ cho phép im lặng khi *không có gì để nói*,
chứ không phải khi đã có một cột mốc được giải quyết.

Ghi chú thêm: `resolve()` chạy ngoài nhánh `if (quiet)` (`phase_status_cubit.dart:240-247`),
nên cột mốc cũng bị tiêu thụ trong pha đếm ngược; ở pha đó hub vẫn dựng
`WealthCounterLine` nên câu vẫn hiện — đây không phải lỗi, chỉ là dữ kiện cần cho S7
khi cân nhắc cách sửa.

Hướng sửa gợi ý (không bắt buộc, thuộc quyền S7/PO): cho widget tự dựng phần cột mốc
khi `milestone` khác null dù `label` vắng, hoặc để cubit không phát cột mốc mà nó biết
sẽ không vẽ được.

### F-2 — Test canh gác BR-12 vô hiệu (false assurance)

Mức: LOW cho sản phẩm, MEDIUM cho độ tin của bộ test.

`wealth_counter_line_test.dart:314-334` chạy `git diff --name-only HEAD` rồi khẳng định
`activity_card_repository.dart` không nằm trong danh sách. Trong một worktree đã commit,
lệnh đó trả về rỗng, nên phép khẳng định không bao giờ có thể đỏ — kể cả khi ai đó thực
sự sửa repository rồi commit. Nó cũng phụ thuộc `Directory.current.parent.path`, tức
đứt nếu vị trí chạy test đổi.

Bất biến thì thật sự giữ: `git diff --name-only b58afbe0 HEAD -- mobile/lib/features/activity_cards/domain/activity_card_repository.dart`
trả rỗng. Vậy đây là lỗi của cái khoá, không phải của cánh cửa. Muốn có giá trị, phép
so sánh phải dùng một base thật (ví dụ merge-base với nhánh integration) thay cho `HEAD`.

## Notes

- **N-1 — `BaseHead` khai trong handoff không dùng được.** Handoff khai
  `BaseHead: 27c0a7e8`, đúng bằng HEAD hiện tại của worktree (xác nhận trong
  `BoundaryState`: `base_head == commit_sha == 27c0a7e8e27e...`). Mọi diff theo nó
  đều rỗng, và schema yêu cầu BaseHead của review phải là tổ tiên của HEAD, không
  phải chính HEAD. Slice này dùng
  `git merge-base HEAD codex/REQ-016_solo_stage1_relationship_assistant-integration`
  = `b58afbe073eff4e1ebb9151735221532a9cf5a82` (HEAD đi trước 14 commit), trùng với
  base mà slice-S6a đã dùng. S7 nên dùng cùng base này.
- **N-2 — Lệch J12 giữa canvas và bản dựng, thuộc quyền S7/PO.**
  `visual-fidelity/visual-fidelity-report.md` đang ghi `VISUAL_FIDELITY: FAIL` (dòng 3)
  và đã mô tả lệch này ở dòng 174-178: canvas J12 là một khung cột mốc toàn màn hình
  có "Giữ lại bộ này" / "Xem lại 5 kỷ niệm", bản dựng là một dòng công nhận nội tuyến
  không nút. Đáng lưu ý cho người ra quyết định: AC-28 chỉ cấm *mời người kia* và *mở
  luồng hai chiều*; nó không cấm mọi nút. Ghi chú trong `wealth_counter_line.dart:24`
  khái quát thành "no button, no ..." — đó là một lựa chọn chặt hơn AC, không phải
  điều AC bắt buộc. Việc này đã nằm trong D-10 như ứng viên `DESIGN_SPEC_CONFLICT`
  chờ Scrum Master/PO phán; slice này không tự quyết.
- **N-3 — Ảnh chụp còn dải DEBUG.** `implemented-quiet-surfaces.png` hiện băng DEBUG
  góc phải. Không ảnh hưởng phán quyết nội dung, nhưng làm bằng chứng đối chiếu bẩn;
  harness nên đặt `debugShowCheckedModeBanner: false`.
- **N-4 — Kiểm kê trong scope-gate đã cũ.** `review/scope-gate.md` dòng 125-127 nói
  thư mục visual-fidelity có "6 `implemented-*.png`, không có `design-reference-*.png`,
  không có `visual-fidelity-report.md`". Thực tế hiện có 7 ảnh design-reference, 6 ảnh
  implemented, `runtime-smoke-ios-first-screen.png` và `visual-fidelity-report.md`
  (17.8K). Không phải khuyết tật, chỉ là ghi chú để S7 đừng tin số liệu cũ.

## Slice Recommendation

Phần lát cắt S6b đạt trên mọi cổng AC/BR đã nêu, trừ một khuyết tật thật nhưng chưa
tái hiện được với bộ content đang ship (F-1) và một test canh gác vô hiệu (F-2). Cả
hai đều sửa gọn trong chính các tệp của lát cắt này. Chuyển F-1, F-2 và N-2 cho S7
tổng hợp; N-1 là hiệu chỉnh quy trình mà S7 cần áp dụng ngay khi tự chạy diff.
