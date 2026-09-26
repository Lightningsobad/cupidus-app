# STORY-007 — Review slice P2 (khung khối + điểm gắn)

Outcome: PARTIAL_SLICE_ONLY

Slice 2/5 của một Tier 3 scoped-slice review. **Kết luận slice: ĐẠT — không có
phát hiện chặn (blocking finding).** Giá trị `PARTIAL_SLICE_ONLY` ở trên là giá
trị enum hợp lệ duy nhất diễn đạt "một slice đã xong, chưa phải phán quyết cả
story", giống hệt cách slice P1 đã ghi.

- Reviewer: Iris-QC
- Ngày: 2026-09-24
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`
- Worktree HEAD lúc review: `4c99d0f3`
- Diff baseline (BaseHead của handoff): `bfe231aa`
- Phạm vi: chỉ P2 — khung khối, cubit khung, và điểm gắn duy nhất trên màn chi
  tiết thẻ. P1, P3, P4, P5 **không** được xem xét ở đây; phần photo-attach bên
  trong `thank_you_block.dart` thuộc slice P4 và đã được bỏ qua có chủ ý.

## 1. File trong phạm vi slice

`git -C <Worktree> diff --name-only bfe231aa -- <6 file>` trả đúng 6 file:

- `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` (+16)
- `mobile/lib/features/activity_cards/thank_you/presentation/thank_you_block_cubit.dart` (+79, file mới)
- `mobile/lib/features/activity_cards/thank_you/presentation/widgets/thank_you_block.dart` (+395, file mới)
- `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` (+20)
- `mobile/test/features/activity_cards/card_lifecycle_ui_test.dart` (+19)
- `mobile/test/features/activity_cards/activity_type_test.dart` (+4/-4)

## 2. Các kiểm tra bắt buộc

### 2.1 Điểm gắn duy nhất, không thêm destination — ĐẠT

- Toàn bộ `mobile/lib` chỉ có **một** lời gọi `ThankYouSection`:
  `activity_card_detail_screen.dart:475`. Không có route, không có
  `Navigator.push`, không có entry point thứ hai nào được thêm.
- Vị trí: bên trong `CustomScrollView` → `SliverList` → `Column` của
  `_content`, ngay sau `_primaryAction` và sau `BeforeYouGoSection`, trước
  `SizedBox(height: CupidSpacing.xl)` cuối cùng. Đã cuộn được nên không có rủi
  ro overflow; nằm **dưới** hành động chính cấp thẻ nên trật tự thị giác của
  AC-6/AC-7 đọc được ngay trên cây widget.
- `story_master.md` "System Integration And Discoverability — Không thêm
  destination mới" và AC-7 (đã đối chiếu nguyên văn
  `requirements/requirements.md:120-123`: "khối nằm **bên trong luồng 'ghi
  lại'** ... Người dùng không phải rời luồng 'ghi lại' để dùng khối") đều thoả.
  Bản dựng đúng là khối lồng, **không** phải màn riêng.

### 2.2 Cổng trạng thái và cổng ngày — ĐẠT

- `ThankYouBlockCubit.isRecording = card.status == ActivityCardStatus.done`
  (`thank_you_block.dart:154`) là bộ lọc thô; luật ngày thật nằm ở
  `ThankYouActivationService.isEligible` (P1): "chỉ đúng vào ngày dân sự **sau**
  ngày arm". Ghép lại đúng AC-1 (`requirements.md:93-95`, "vào một ngày lịch sau
  ngày chuyển") và AC-2 (`requirements.md:97-99`, cùng ngày thì không hiện).
- Thẻ ở mọi trạng thái khác `done` **không chạm vào sổ lượt**: `resolve()` thoát
  trước khi gọi `service()`, nên service (và `getIt<CupidDatabase>()`) không hề
  được dựng. Đây cũng là lý do phần lớn test cũ không phải sửa.
- Thẻ không đủ điều kiện chỉ tốn một `SizedBox.shrink`; `NextPlanCubit` và gói
  dịp cũng không được nạp trên nhánh này.

### 2.3 Đúng một lượt trình bày trọn đời — ĐẠT

- `resolve()` gọi `ledger.consume(cardId)` **trước** khi `emit(isVisible: true)`
  (`thank_you_block_cubit.dart:70-74`), nên một lần mở màn rồi bỏ đi vẫn tiêu
  lượt — đúng cách đọc AC-3 (`requirements.md:101-103`: "dù người dùng đã dùng
  đủ ba phần, dùng một phần, hay không dùng phần nào").
- Cờ `_settled` chặn `resolve()` lần hai từ rebuild, nên một khối đã đóng không
  bị dựng lại.
- `dismiss()` chỉ `emit(ThankYouBlockState())`, không có đường mở lại — không có
  API nào trong cubit đưa `isVisible` về `true` lần nữa.
- Bằng chứng test tương ứng có thật (xem mục 3).

### 2.4 Khối là widget có biên, không kéo sập màn chi tiết — ĐẠT có điều kiện

- Về cây widget thì có biên rõ: khối chỉ là một phần tử `Column`, mọi lỗi dữ
  liệu đều quy về "không vẽ gì" chứ không ném trong `build`. Khe rỗng để lại
  `SizedBox.shrink`, không có placeholder (AC-15/BR-9 — do P4 nghiệm thu).
- Nguồn ảnh được bọc `try/catch` tường minh (`thank_you_block.dart:179-185`) với
  lý do ghi ngay tại chỗ.
- **Nhưng** đường đọc sổ lượt thì không được bọc: `initState` gọi
  `unawaited(_resolve())` (`:157`), còn `_cubit.resolve()`,
  `thankYouPresetsAvailable(...)` và `next.load()` đều `await` trần. Nếu
  database/DI ném, lỗi trở thành **uncaught async error** của zone: màn chi tiết
  vẫn vẽ (không phải lỗi trong `build`), khối im lặng biến mất — nhưng trong
  widget test thì lỗi đó làm đỏ cả test với thông điệp không liên quan. Đúng
  kiểu hỏng đó là cách 3 test cũ đỏ ra (mục 2.6). Xem advisory A1.
- Hình dạng state của cubit đúng phạm vi P2 (`isVisible` và chỉ thế), **không**
  có state chọn ảnh của P4 — như yêu cầu của handoff, không tính là thiếu.

### 2.5 Không thêm hành động chính cấp thẻ thứ hai — ĐẠT

- Khối không dựng nút gradient/pill nào. Affordance duy nhất ở tầng khung là
  `thank_you_close`: ô `platform.tapTarget` (≥44pt), `CupidIcons.close`,
  `colorTextMuted`, bọc `Semantics(button: true)` và có `semanticLabel`
  `Đóng`/`Close`. Thoả AC-6 (`requirements.md:115-118`) và BR-1; cũng đúng
  phase P2 §3 (icon close ở header, không hộp thoại xác nhận).

### 2.6 "3 test card-detail không liên quan" — ĐẠT, đúng là sửa đăng ký

- `activity_card_detail_screen_test.dart` và `card_lifecycle_ui_test.dart`: chỉ
  thêm `setUp`/`tearDown` đăng ký `CupidDatabase(NativeDatabase.memory())` rỗng
  vào `getIt` và dọn sau. **Không** đổi một assertion nào, không đổi kỳ vọng
  hành vi của tính năng khác. Sổ lượt rỗng ⇒ không thẻ nào `armed` ⇒ khối không
  vẽ ⇒ bố cục các test đó khẳng định giữ nguyên.
- `activity_type_test.dart`: chỉ là gợn sóng bump `schemaVersion` 9 → 10 của P1
  (assertion + chú thích lịch sử phiên bản). Thuộc về P1 về mặt ngữ nghĩa, đã
  được slice P1 nghiệm thu; ở đây xác nhận không có thay đổi hành vi kèm theo.
- File thứ ba trong nhóm này — `test/features/before_you_go/before_you_go_block_test.dart`
  — **không** nằm trong danh sách file của slice này (xem advisory A4).

### 2.7 Bằng chứng test — ĐẠT

`coding-plan/test-results.md` §`## P2 — Khung khối + điểm gắn` (dòng 169-255)
ghi: `flutter test test/features/activity_cards test/features/before_you_go` →
`+358 ~6`, và `thank_you_block_test.dart` → `+16`, `0 error` khi analyze. Mục
"Phạm vi test mới" liệt kê đúng các nhóm mà slice này cần: cubit (AC-1/AC-3/AC-7),
màn chi tiết (mở hai lần, close rồi mở lại, thẻ *Đã đi rồi* hôm nay, không thêm
hành động chính thứ hai), và khung khối (khe rỗng, thứ tự ba khe).

Chạy lại độc lập trong worktree, đúng phạm vi slice:

```
$ flutter test test/features/activity_cards --reporter failures-only
+337 ~5: 5 skipped tests.
+337 ~5: All other tests passed!
```

`git status --porcelain` sau lần chạy: **sạch** — không PNG visual-fidelity của
story khác bị ghi đè.

### 2.8 Visual fidelity — ĐẠT

`visual-fidelity/visual-fidelity-report.md` mở đầu bằng `VISUAL_FIDELITY: PASS`,
`Design-Screen: sb-212-cam-on-chot-viec-ke-tiep` (surface `cupid-ch-ng-1`, ios,
415x900), dựng bằng `RepaintBoundary.toImage` trong chính widget test của story
— đúng fallback đã có tiền lệ cho bề mặt không tới được bằng điều hướng
(STORY-006 P2, STORY-003 P3). Các sai lệch harness (capture qua
`CupidPlatform.material`, không có device chrome, nền đóng băng) được ghi rõ là
artefact của harness chứ không phải lỗi sản phẩm. Phần khung khối trong báo cáo
khẳng định đúng bốn điểm slice này quan tâm: container `colorSurfaceAlt` +
`colorLine` + `radiusSmall` thụt một `md`, tiêu đề `body` semibold, affordance
đóng ở cùng hàng, và bậc hành động hai tầng còn nguyên.

## 3. Bốn mục `DESIGN_SPEC_CONFLICT` — ghi nhận advisory, không tái tranh luận

Ghi lại nguyên trạng cho pass final-synthesis. Tiền lệ "theo AC/spec, không theo
canvas" (STORY-006 P2 với `sb-211`) đã đứng, slice này **không** mở lại:

1. Canvas vẽ **màn riêng có chrome** (back chevron, chip `ĐÃ ĐI RỒI · TỐI QUA`,
   H1 riêng) vs AC-7 + `architecture/solution.md` §3 + `ux/uiux-spec.md` mục 6
   đòi khối lồng trong `ActivityCardDetailScreen`. Bản dựng theo AC — đã kiểm
   chứng ở mục 2.1.
2. Nút full-width `Thôi, để hôm khác` vs icon `close` ở header (AC-6 giữ đúng
   một hành động chính cấp thẻ).
3. H1 + phụ đề cấp màn (`Sáng nay có hai việc nhỏ xíu.`) — chrome mà khối lồng
   không có chỗ, và "hai việc" mâu thuẫn với ba phần P3/P4/P5.
4. Chip `ĐÃ ĐI RỒI · TỐI QUA` — màn chi tiết đã có chip trạng thái riêng, và sổ
   lượt chỉ lưu `armed_on` dạng ngày dân sự nên nửa `· TỐI QUA` không có dữ liệu
   để dựng (BR-3 + allowlist cột của P1).

Cả bốn đều là **xung đột tài liệu, không phải lỗi hiện thực**, và không được
"sửa về phía canvas" nếu không có phán quyết của người dùng.

## 4. Advisory (không chặn) — dành cho final-synthesis

**A1 — Đường đọc sổ lượt không có biên lỗi tường minh.**
`unawaited(_resolve())` (`thank_you_block.dart:157`) cộng với `await` trần ở
`_cubit.resolve()`, `thankYouPresetsAvailable(...)` và `next.load()`. Hỏng ở
database/DI ⇒ uncaught async error + khối im lặng vắng mặt. Mức nghiêm trọng
thấp (màn chi tiết không sập), nhưng **không nhất quán** với `try/catch` có chủ
ý ngay bên dưới cho nguồn ảnh, và không có test nào phủ nhánh "sổ lượt ném".
Đề xuất: bọc `try/catch` cùng kiểu, hoặc ghi một dòng lý do rằng im lặng là chủ
ý theo AC-25.

**A2 — `ThankYouBlockState` không mô hình hoá loading/error.** Chỉ có
hiện/không hiện. Về sản phẩm thì hợp lý, thậm chí đúng hướng AC-25 (không bề
mặt trừng phạt, không báo cho người dùng biết họ lỡ gì), nhưng hệ quả là lỗi ở
A1 hoàn toàn không quan sát được từ UI. Ghi lại như một ghi chú thiết kế, không
phải khiếm khuyết.

**A3 — Lượt bị tiêu lúc dựng màn, không phải lúc khối thật sự lọt vào tầm
mắt.** Khối nằm cuối `Column` cuộn được; trên thẻ có ghi chú dài hoặc có ảnh,
khối có thể nằm dưới nếp gấp, nên người dùng có thể tiêu mất lượt trọn đời duy
nhất của thẻ mà chưa từng nhìn thấy khối. AC-1 diễn đạt theo hành vi "mở chi
tiết thẻ", nên cách đọc này bảo vệ được và đã được ghi chú ngay trong cubit —
nhưng hiệu ứng dữ liệu là **một chiều, không hoàn tác được**. Đề nghị PO xác
nhận ở pass final-synthesis.

**A4 — Lỗ hổng phân bổ file giữa các slice.** Hai file có trong diff story
nhưng không thuộc danh sách của slice P1 (`review/scope-gate.md`) lẫn slice này:
- `mobile/test/features/activity_cards/thank_you/thank_you_block_test.dart` —
  16 test, **chính là bằng chứng gốc của P2**;
- `mobile/test/features/before_you_go/before_you_go_block_test.dart` — file thứ
  ba trong nhóm sửa đăng ký của P2.
Final-synthesis phải gán chúng cho một slice hoặc tự phủ.

**A5 — `review/scope-gate.md` vẫn là scope của P1.** Slice này **không** sửa
file đó vì nó nằm ngoài `WriteScope` được khai báo cho run này (chỉ gồm báo cáo
slice P2 và `review-report.md`). Cổng scope-gate không kích hoạt lại trong run
này. Final-synthesis cần mở rộng scope gate cho cả story.

**A6 — BaseHead trong bằng chứng lệch với BaseHead review.**
`test-results.md` §P2 ghi BaseHead `4a241d2f`, còn handoff review dùng
`bfe231aa`. Cùng loại mục slice P1 đã ghi; không phải khiếm khuyết, chỉ cần nhất
quán khi tổng hợp.

**A7 — Nhánh `arm` từng thiếu, đã được đóng sau đó.** Chính báo cáo P2 ghi rằng
lúc đó không nơi nào trong `mobile/lib` gọi `onCardStatusChanged`, nghĩa là bản
build thật không bao giờ `arm` được thẻ nào và khối sẽ không bao giờ nổi lên.
Mục `## P1 — lượt hoàn tất đấu nối` đóng việc này bằng lớp bọc
`ThankYouActivationAwareCardRepository` + đăng ký ở `service_locator.dart`, có
test riêng (`thank_you_activation_card_status_repository_test.dart`, 4 test
xanh). Hai file đó thuộc danh sách của slice P1; ghi ở đây chỉ để xác nhận
**điểm gắn của P2 đã sống end-to-end**.

## 5. Kết luận slice

Không có phát hiện chặn trong phạm vi P2. Khung khối và điểm gắn đúng hợp đồng
AC-1/AC-2/AC-3/AC-6/AC-7, đúng một điểm gắn, đúng một lượt trọn đời, không thêm
destination và không thêm hành động chính cấp thẻ thứ hai. Bảy mục advisory ở
trên chuyển cho pass final-synthesis; A3 là mục duy nhất có thể cần phán quyết
của PO.

REVIEW_SLICE_COMPLETE: YES
