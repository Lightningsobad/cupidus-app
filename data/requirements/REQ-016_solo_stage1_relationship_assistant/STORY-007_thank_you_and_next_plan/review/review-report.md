# STORY-007 "Cảm ơn + chốt việc kế tiếp" — Review Report (final synthesis)

Outcome: DEFERRED_ONLY

- Reviewer: Iris-QC
- Review type: `final-synthesis` (tổng hợp 5 slice `scoped-slice`)
- Ngày: 2026-09-24
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`
- BaseHead: `bfe231aa` · Worktree HEAD: `32f20f0a`
- Diff: 52 file dưới `mobile/`, +5955 / −138
- Scope gate: `review/scope-gate.md` (đã mở rộng cho cả story ở pass này)

> **Đây là phán quyết cấp story, thay thế toàn bộ file placeholder trước đó.**
> 5 báo cáo slice `review/slice-p1..p5-*.md` được **giữ nguyên** và là nơi chứa
> bằng chứng chi tiết; báo cáo này tham chiếu chứ không chép lại chúng.

## 1. Vì sao `DEFERRED_ONLY` chứ không phải `CLEAN`

Cả 5 slice đều trả **0 phát hiện chặn**, không slice nào yêu cầu quay lại lane
hiện thực. Không có `PATCH_REQUIRED`, không có `BLOCKED`.

Không dùng `CLEAN` vì story đóng lại vẫn còn ba nhóm việc chuyển tiếp có thật,
không cái nào chặn ship: (a) một câu hỏi sản phẩm cần PO trả lời (mục 4),
(b) các advisory đã được các slice gắn nhãn DEFERRED tường minh (mục 6), và
(c) hai test đỏ có sẵn xuyên story cần quyết định ở tầng requirement (mục 5).
`DEFERRED_ONLY` là giá trị enum mô tả đúng tình trạng đó và vẫn thoả cổng DONE.

| Slice | Phạm vi | Phát hiện chặn | Báo cáo |
|---|---|---|---|
| P1 | Sổ kích hoạt, bump `schemaVersion` 9→10, `stage1_wipe_registry` | 0 | `review/slice-p1-activation-ledger.md` |
| P2 | Khung khối `ThankYouSection` + điểm gắn trên `activity_card_detail_screen.dart` | 0 | `review/slice-p2-block-shell-entry-point.md` |
| P3 | Danh mục preset `thank_you_after_date` + `decline_door` theo phạm vi danh mục | 0 | `review/slice-p3-preset-category.md` |
| P4 | Đính ảnh: `attachable_photos.dart`, `photo_attach_section.dart`, `journalPhotoPathsForOrigin` | 0 | `review/slice-p4-photo-attach.md` |
| P5 | Gợi ý "chốt việc kế tiếp": `next_plan_suggestion_service.dart`, `next_plan_cubit.dart`, `next_plan_section.dart` | 0 | `review/slice-p5-next-plan-suggestions.md` |

Tất cả 52 file trong diff đã được gán cho đúng một slice; **không còn file mồ
côi**. Hai file từng không thuộc slice nào
(`relationship_label_repository_test.dart`, `portrait_answer_repository_test.dart`)
đã được pass này đọc diff và gán về P1 — xem `review/scope-gate.md`
mục `### Hai file từng mồ côi`.

## 2. Phán quyết: cặp `VISUAL_FIDELITY: PASS` + `DESIGN_SPEC_CONFLICT`

**Phán quyết cấp story: giữ nguyên `VISUAL_FIDELITY: PASS`. Sáu mục
`DESIGN_SPEC_CONFLICT` được ghi nhận là *xung đột tài liệu thiết kế*, không phải
khoảng hụt fidelity, nên chúng không hạ `PASS` xuống `BLOCKED`.**

Căn cứ, áp dụng tiền lệ chứ không mở lại nó:

1. Tiền lệ chi phối đã đứng sẵn trong chính REQ-016 — `req_master.md`
   `## Design Ruling Log` hàng 2026-09-17 / STORY-010 ghi nguyên tắc:
   *"một phần tử canvas tự vi phạm một AC đã chốt không thắng được AC đó chỉ
   bằng thẩm quyền 'design thắng'"*. Cùng nguyên tắc đã đóng D-1 và mục 4 của
   STORY-010, và đã được áp lại ở STORY-006 P2 (`sb-211`) rồi ở slice P2 của
   story này (`sb-212`). Handoff yêu cầu **áp dụng, không tái tranh luận** — báo
   cáo này áp dụng đúng như vậy.
2. Cả 6 mục đều thuộc đúng hình dạng đó: phần tử canvas mâu thuẫn với một AC
   hoặc một luật đã chốt, chứ không phải bản dựng lệch khỏi một canvas hợp lệ.
   `visual-fidelity-report.md` §`## Authority note` đã tự nêu đúng lập luận này
   và tự gắn cờ thay vì tự phân xử — đó là hành vi đúng của tầng bằng chứng.
3. Cổng 12e2 mặc định muốn `BLOCKED: DESIGN_SPEC_CONFLICT` cho một xung đột
   chưa phân xử. Xung đột ở đây **đã được phân xử** (bởi tiền lệ trên, ở tầng
   requirement), nên `PASS` kèm 6 mục ghi nhận là cách ghi đúng, không phải một
   mâu thuẫn nội tại của báo cáo. Ghi nhận rõ ở đây để lần đọc sau không hiểu
   nhầm cặp này là lỗi sổ sách.
4. Riêng delta "3 hàng thay vì 2" của phần 3: slice P5 §7 đã chỉ ra đây **không
   phải** một sai lệch thiết kế độc lập mà là **hệ quả trực tiếp của AC-35** —
   dải "2-3" là tham số bố cục, không phải số lượng cố định; ngày chụp gói dịp
   có 3 mục nên 3 hàng render. Pass này đồng ý: nó không được tính là mục
   `DESIGN_SPEC_CONFLICT` thứ 7, và cũng không phải delta cần ruling.

Hai delta còn lại của phần 3 (`+` đặc thay vì `⊕` viền; mọi hàng đều có dòng
ngày) và ba delta của phần 2 đều đã có nguồn ràng buộc ghi kèm trong
`visual-fidelity-report.md` (`CupidIcons.add` là token sẵn có của design system;
AC-21 buộc ngày đi cùng thẻ; `ux/uiux-spec.md` mục 3 dòng 53-54 cố định hình
dạng "hàng thumbnail cuộn ngang"). Không mục nào cần sửa mã.

## 3. Sáu mục `DESIGN_SPEC_CONFLICT` — ghi nhận cho hồ sơ story

Cả 6 đều đã được **kiểm chứng độc lập trên chính PNG canvas**, không phải tin
theo ghi chú của implementer (P2 kiểm 4 mục, P4 mở cả 3 PNG kiểm 2 mục).

| # | Canvas vẽ gì | Ràng buộc thắng | Xử lý |
|---|---|---|---|
| 1 | Màn riêng có chrome: back chevron, H1 riêng, device chrome | AC-7 + `architecture/solution.md` §3 + `ux/uiux-spec.md` mục 6 — khối **lồng** trong `ActivityCardDetailScreen` | Theo AC. Dựng là sub-block, không thêm route. Trùng đúng xung đột STORY-006 P2 ghi với `sb-211` |
| 2 | Nút full-width `Thôi, để hôm khác` | AC-6 giữ **đúng một** hành động chính cấp thẻ; phase P2 §3 chỉ định icon `close` ≥44pt | Theo AC. Dựng `thank_you_close`, `CupidIcons.close`, `colorTextMuted`, nhãn ngữ nghĩa `Đóng` |
| 3 | H1 `Sáng nay có hai việc nhỏ xíu.` + phụ đề cấp màn | Chrome cấp màn mà khối lồng không có chỗ; "hai việc" mâu thuẫn ba phần P3/P4/P5 | Theo spec. Khối mang tên `ux/uiux-spec.md` mục 1 đặt cho nó |
| 4 | Chip `ĐÃ ĐI RỒI · TỐI QUA` | Màn chi tiết đã có chip trạng thái riêng (STORY-001); sổ lượt chỉ lưu `armed_on` dạng ngày dân sự (BR-3 + allowlist cột P1) nên `· TỐI QUA` không có dữ liệu | Theo AC. Không chip nào ship từ story này |
| 5 | Hàng phần 2: `Kèm một ảnh tối qua` + phụ đề `lấy từ tối qua bạn lưu lúc 23h` | **AC-17/BR-8** — chỉ **tham chiếu file ảnh** được rời nhật ký; `ux/uiux-spec.md` mục 3: "chữ và siêu dữ liệu không bao giờ rời thiết bị qua đường này" | Theo AC — mục sắc nhất trong 6. Cưỡng chế ở tầng kiểu: projection chỉ mang `filePath`, widget **không có** mốc thời gian nào trong tầm với để vẽ. Thay bằng header caption-caps không mang nội dung nhật ký |
| 6 | Chevron cuối hàng phần 2 | AC-7 (nhật ký là bề mặt một chiều) + **AC-16** (tương tác nằm trên chính thumbnail) | Theo AC. Chevron ngụ ý đích điều hướng thứ hai — không ship |

Cả 6: **đã giải quyết theo AC/spec-over-canvas, không mục nào chặn, không mục
nào cần sửa mã.** Nếu người dùng/PO sau này muốn neo về canvas cho bất kỳ mục
nào, đó là phạm vi mới ở vòng sau, không phải lỗi của story này.

## 4. CẦN PO QUYẾT — lượt trọn đời bị tiêu lúc dựng màn, không phải lúc nhìn thấy

**Mục này KHÔNG được reviewer tự giải quyết. Scrum Master phải đưa lên
user/PO trước hoặc ngay sau khi story ship.** Đây là mục duy nhất của cả story
có hiệu ứng **một chiều, không hoàn tác được** đối với dữ liệu người dùng.

- Nguồn: slice P2 advisory A3 (`review/slice-p2-block-shell-entry-point.md` §4).
- Sự việc: `ThankYouBlockCubit.resolve()` gọi `ledger.consume(cardId)` **trước**
  khi `emit(isVisible: true)`, và `resolve()` chạy từ `initState` của màn chi
  tiết. Khối nằm cuối một `Column` cuộn được, **dưới** `_primaryAction` và
  `BeforeYouGoSection`.
- Hệ quả: trên một thẻ có ghi chú dài hoặc có ảnh, khối có thể nằm dưới nếp gấp.
  Người dùng mở chi tiết thẻ rồi thoát ra mà **chưa từng nhìn thấy khối** vẫn
  tiêu mất lượt trình bày trọn đời duy nhất của thẻ đó. Không có đường hồi lượt:
  `consumed` là trạng thái hấp thụ ở tầng SQL (P1 §1.2), và `dismiss()` không có
  API nào đưa `isVisible` về `true` lần nữa.
- Vì sao không chặn: AC-3 diễn đạt theo hành vi *"dù người dùng đã dùng đủ ba
  phần, dùng một phần, hay không dùng phần nào"*, và AC-1 neo vào hành vi "mở
  chi tiết thẻ" chứ không vào "khối lọt vào tầm mắt". Cách đọc của bản dựng vì
  vậy **bảo vệ được** trước văn bản AC hiện tại, và đã được ghi chú ngay trong
  cubit. Đây là một khoảng trống trong **cách viết AC**, không phải sai lệch so
  với AC.
- Câu hỏi gửi PO: AC-3 có ý là "tiêu lượt khi màn được dựng" hay "tiêu lượt khi
  khối thật sự hiển thị cho người dùng"? Nếu là vế sau thì cần một cơ chế
  visibility-aware (ví dụ tiêu lượt khi khối lọt viewport) và AC-3 cần vá câu
  chữ — phạm vi nhỏ, nhưng đổi hành vi dữ liệu.

## 5. Đỏ có sẵn, xuyên story — xác nhận không do STORY-007 gây ra

Cả hai đều đã được slice tương ứng kiểm chứng **tại BaseHead**, không phải tin
theo lời implementer. Không cái nào chặn cổng DONE của story này.

1. **`mobile/test/features/chapter_closure/stage1_wipe_registry_parity_test.dart`**
   (P1 §1.5). Fail vì registry thiếu `calendar_event_state`, `portrait_answers`,
   `relationship_labels` — cả ba là bảng của STORY-009/STORY-010.
   `thank_you_activations` **có mặt** trong tập Actual, tức diff này đã đăng ký
   đúng bảng của chính nó. Chứng minh đỏ-từ-trước: diff lên
   `stage1_wipe_registry.dart` là `+9 −0` (chỉ thêm một `Stage1WipeTable`), trong
   khi lược đồ tại `bfe231aa` đã ở v9 và đã chứa cả ba bảng thiếu kia ⇒ test
   không thể xanh tại BaseHead. **Cần quyết định PO/Tech-Lead xuyên story**
   (đăng ký ba bảng kia, hoặc loại trừ có chủ ý trong `nonReq016Tables()`).
2. **`mobile/test/features/calendar_events/calendar_event_service_test.dart:390`**
   (P5 §5). Ghim `ActivityCardOrigin.values` đúng 5 phần tử;
   `git show bfe231aa:.../activity_card.dart` cho thấy đã có **6** phần tử tại
   BaseHead ⇒ đỏ trước P5. P5 đưa lên 7 nhưng **kiểu hỏng không đổi** và bất
   biến mà test bảo vệ ("giá trị mới nằm cuối") vẫn giữ. Đã có
   `BUG-20260923-002_conversation_starters_enum_pinned_assertion_lag` trỏ đúng
   dòng đó. **Không mở bug mới.** DEFERRED theo luật triage.

Ngoài ra `BUG-20260924-001` (đỏ repo-wide có sẵn ở `test/design_system/`) là lý
do AC của phase P1 *"bộ test của app xanh trở lại"* không thoả theo nghĩa đen.
Gate thực chất đã đạt là **"không thêm đỏ mới so với BaseHead"** (37 → 18, mọi
đỏ còn lại là tập con thật). Đề nghị Scrum Master/Tech Lead vá câu chữ AC đó.

## 6. Residual risk — advisory DEFERRED, không cái nào chặn

Một chủ đề lặp lại ở 3 slice, đáng gộp thành một việc dọn nhỏ ở vòng sau:
**đường nạp bất đồng bộ của khối không có biên lỗi nhất quán.**

| # | Nội dung | Nguồn | Mức |
|---|---|---|---|
| R1 | `unawaited(_resolve())` từ `initState` cộng `await` trần ở `_cubit.resolve()`, `thankYouPresetsAvailable(...)`, `next.load()` — hỏng ở DB/DI thành uncaught async error, khối im lặng vắng mặt. **Không nhất quán** với `try/catch` có chủ ý ngay bên dưới cho nguồn ảnh | P2 A1, P5 A1/A2 | Low — nên đối xứng hoá |
| R2 | `ThankYouActivationStatus.fromWireValue` dùng `firstWhere` không `orElse` ⇒ `StateError` thay vì degrade nếu gặp giá trị lạ | P1 A1 | Low |
| R3 | `ThankYouActivationAwareCardRepository.updateStatus` `await` listener **sau** khi ghi thẻ ⇒ caller nhận exception dù trạng thái thẻ đã đổi thật (điểm không-nguyên-tử) | P1 A2 | Low |
| R4 | `Image.file` không có `errorBuilder`; file biến mất giữa lúc nạp và lúc vẽ thì Flutter dựng widget lỗi trong hàng ảnh | P4 A3 | DEFERRED |
| R5 | `existsSync()` đồng bộ trên mỗi đường dẫn khi gộp ảnh — không đáng kể ở khối lượng hiện tại | P4 A4 | DEFERRED |
| R6 | `_declineDoorCategories` là **allowlist** ⇒ một danh mục mang ngữ nghĩa lời mời trong tương lai mặc định **không** bị buộc cửa từ chối (fail-open). Hiện chỉ 2 danh mục nên không có rủi ro thực; test ghim tên file danh mục (AC-22) buộc người thêm phải sửa test | P3 A1 | Low — ghi chú cho requirement sau |
| R7 | `_categoryOf()` cắt cứng hậu tố `.v1.json` trong khi regex tên file nhận mọi phiên bản ⇒ gói `.v2.json` sau này sinh category id méo | P3 A4 | Low |
| R8 | BR-14 không có test ở P5; theo cấu trúc không áp dụng được (chữ trên chip là tên dịp đọc khỏi gói STORY-005), bảo đảm nằm ở cổng nhập của STORY-005 | P5 A4 | Info |

## 7. Việc cho Scrum Master (không chặn cổng DONE)

1. **`story_master.md` thiếu dòng `Design-Screen:`.**
   `visual-fidelity-report.md` dòng 36-38 ghi rõ id là
   `sb-212-cam-on-chot-viec-ke-tiep` và nói Scrum Master phải chép sang, vì
   `story_master.md` nằm ngoài write scope của phase — giống cách xử lý STORY-006 P2.
2. **Một PNG của story khác lọt vào diff nhánh này.**
   `git diff --name-status bfe231aa` cho thấy
   `A data/requirements/REQ-016_.../STORY-013_graceful_exit_and_return/visual-fidelity/implemented-j13-man-quay-lai-ios.png`
   — artifact của **STORY-013**, ngoài phạm vi story này (mẫu quen thuộc: bộ test
   mobile ghi đè PNG visual-fidelity của story khác). Cần quyết định giữ hay gỡ
   trước khi merge vào nhánh tích hợp. Không phải lỗi mã, không chặn.
3. **Lệch BaseHead trong `coding-plan/test-results.md`** — lặp ở cả 4 phase:
   §P1 ghi `d36e7a4a`, §P2 `4a241d2f`, §P3 `5fa0e972`, §P4 `3a824d4a`, §P5
   `d684c7e5`, trong khi BaseHead review là `bfe231aa`. Mọi slice đều đã chạy lại
   test độc lập trên HEAD hiện tại nên kết luận không dựa vào con số cũ. Thuần
   sổ sách.
4. **Handoff trích `R-15c` — id không tồn tại.** `req_master.md` chỉ có `R-15`,
   `R-15a`, `R-15b`. Luật chống bộ đếm/tiến độ áp cho story này là `R-15b`, cùng
   `R-1b` và AC-25/AC-26. Đã review theo các id thật. Lưu ý là
   `story_master.md` mục `## Open Question Impact` cũng đang trích `R-15c` — nên
   vá cùng lúc.
5. **Đã tự giải quyết ở pass này, không cần hành động:** advisory A3 của slice P3
   (*"căn cứ ruling chưa được commit"*) **nay đã hết hiệu lực**. Kiểm chứng:
   `git log --oneline -S'CONTENT_GATE_CATEGORY_COUPLING' main -- .../req_master.md`
   → `dc05d105 chore(REQ-016): commit overdue Design Ruling Log + bug queue
   entries...`. Cả hai hàng ruling 2026-09-23
   (`CONTENT_GATE_CATEGORY_COUPLING` dòng 221, `JOURNAL_SOURCE_CONTRACT_CLOSED`
   dòng 222) đã có trên `main`. Mã đã ship không còn trỏ tới hàng ruling không
   tồn tại. Bản `req_master.md` trong worktree story chưa có hai hàng đó chỉ vì
   nhánh được cắt trước `dc05d105` và `req_master.md` không thuộc write scope của
   story — sẽ hoà khi merge.

## 8. Sai lệch WriteScope của lane hiện thực — chấp nhận, không phải khiếm khuyết

1. **P5 sửa `mobile/lib/features/activity_cards/domain/activity_card.dart`
   (+3/−1) ngoài WriteScope khai báo của phase.** Xác nhận theo yêu cầu handoff
   mục 6: **đây là sai lệch chính đáng, không chặn, không tạo `PATCH_REQUIRED`.**
   Căn cứ: thêm đúng một giá trị enum `nextPlanAfterDate('next_plan_after_date')`
   ở **cuối** danh sách — hiện thực trực tiếp của AC-24, không có đường vòng nào
   khác (`NewActivityCard.origin` nhận kiểu `ActivityCardOrigin`, không nhận
   chuỗi). Đúng luật append-only mà chính enum tự ghi; không cần migration vì cột
   `origin` là `text()` thuần, không CHECK constraint (P5 §3(2b) đã đối chiếu).
   Lane đã tự khai trong `test-results.md` thay vì để trôi.
2. **P1 ghi ngoài WriteScope: `cupid_database.g.dart` (codegen) và
   `stage1_wipe_registry.dart`.** Cần thiết: bỏ codegen thì bảng không tồn tại;
   bỏ registry thì dữ liệu sổ kích hoạt sống sót qua "rời giai đoạn 1" và
   tripwire parity đỏ thêm một bảng nữa.
3. **P3 sửa `invite_composer/domain/preset_content_gate.dart` (file của
   STORY-002).** Đây chính là lối (A) mà **user đã chốt** ngày 2026-09-23 qua
   AskUserQuestion, và hàng ruling `CONTENT_GATE_CATEGORY_COUPLING` tự nêu điều
   kiện đánh đổi này. Không phải vượt rào.
4. **P4 mở rộng `journal_entry_point.dart` thêm đúng một hàm chiếu chỉ-đọc.**
   Lối (A) của ruling `JOURNAL_SOURCE_CONTRACT_CLOSED`, cũng do user chốt
   2026-09-23. Test cưỡng chế bề mặt không nới ra (`entry point vẫn chỉ có bốn
   khai báo...`, `không có hàm liệt kê, đếm, tìm hay xem trước`).
5. **Khoảng trống đã biết và được chấp nhận theo ruling:** chưa caller nào ghi
   `originRef` từ thẻ (STORY-008 mới là caller), nên nhánh nguồn ảnh nhật ký trả
   rỗng trên bản build hiện tại. Đường code đã được kiểm bằng hàng gieo thẳng qua
   `saveEntry(..., originRef:)`. AC-14 vì vậy đạt đủ với nguồn ảnh của thẻ ngay
   bây giờ, và đạt đủ hai nguồn khi STORY-008 xuất hiện. Điều kiện này được nêu
   tường minh trong chính hàng ruling — **không tính là khiếm khuyết**.

## 9. Đối chiếu AC — tập AC đúng cho từng phần

Ghi rõ ở đây theo yêu cầu handoff mục 5, để đính chính vĩnh viễn việc handoff
gốc của P4 trích sai:

| Phần | Tập AC/BR chi phối | Ghi chú |
|---|---|---|
| Kích hoạt một-lần-trọn-đời (P1) | AC-1..AC-5, AC-25, AC-26; BR-2, BR-3; R-1b, R-15b | |
| Khung khối + điểm gắn (P2) | AC-1, AC-2, AC-3, AC-6, AC-7; BR-1 | |
| Phần 1 — soạn lời cảm ơn (P3) | AC-8, AC-33..AC-36; BR-6, BR-16, BR-18; R-15/R-15a/R-15b | |
| **Phần 2 — đính ảnh (P4)** | **AC-14, AC-15, AC-16, AC-17, AC-18 + BR-8, BR-9** (`requirements.md:154-178`, `:308-316`) | **ĐÍNH CHÍNH:** handoff gốc của P4 trích "AC-4/AC-5". Sai — AC-4 (`:105`) và AC-5 (`:110`) nói về lượt kích hoạt khi thẻ đổi trạng thái, thuộc **P1**. Slice P4 đã chấm theo tập AC thật, đúng như mã tự trích dẫn; báo cáo này ghi tập đúng làm bản chính thức |
| Phần 3 — chốt việc kế tiếp (P5) | AC-19..AC-24, AC-28, AC-29, AC-30, AC-35, AC-36; BR-11, BR-14, BR-17, BR-18 | |

## 10. Trạng thái `story_master.md`

Checklist `## Artifacts` hiện có Requirements, UX Design, Architecture và
Implementation **đã tick**; chỉ còn `- [ ] Review (Reviewer)` chưa tick. Báo cáo
này là thứ mở khoá ô đó. **Reviewer không tự tick** — Scrum Master tick sau khi
báo cáo này hạ cánh, cùng lúc chuyển `Status: IN_PROGRESS` → `DONE` theo cổng
DONE của story.

## 11. Quyết định

- Phát hiện chặn: **0**.
- Phán quyết: **`DEFERRED_ONLY`** — thoả cổng DONE của story.
- Không có việc nào phải quay lại lane hiện thực vì review này.
- Việc chuyển tiếp: mục 4 (PO quyết, một chiều không hoàn tác), mục 5 (hai đỏ
  xuyên story cần quyết định ở tầng requirement), mục 6 (8 residual risk mức
  Low/DEFERRED), mục 7 (5 việc sổ sách cho Scrum Master, mục 7.5 đã tự đóng).

REVIEW_COMPLETE: YES
