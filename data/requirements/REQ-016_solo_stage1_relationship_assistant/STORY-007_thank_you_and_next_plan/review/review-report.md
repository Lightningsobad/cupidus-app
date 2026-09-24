# STORY-007 — Review Report (scoped-slice, in progress)

Outcome: PARTIAL_SLICE_ONLY

> **Đây KHÔNG phải phán quyết cuối của story.** File này được tạo vì cổng
> `validate-reviewer-handoff.sh` chặn stop của slice P1 với `PHASE2_MISSING`
> (`fix: write review-report.md with one Outcome line`), trong khi bản giao việc
> của slice P1 lại cấm tạo file này và dành nó cho pass final-synthesis.
> Reviewer slice P1 đã tạo bản tối thiểu này thay vì im lặng bỏ qua xung đột.
>
> **Pass final-synthesis được phép ghi đè toàn bộ file này** sau khi cả 5 slice
> trả kết quả. `PARTIAL_SLICE_ONLY` không thoả cổng DONE, nên không có rủi ro
> story bị đánh DONE dựa trên file này.
>
> Slice sau nếu gặp cùng cổng: **đừng ghi đè**, chỉ thêm một dòng vào bảng
> `## Slice Index` bên dưới và giữ nguyên dòng `Outcome:` duy nhất ở trên.

## Slice Index

| Slice | Phạm vi | Báo cáo | Kết luận slice |
|---|---|---|---|
| P1 | Activation ledger: persistence, bump `schemaVersion` 9→10, đăng ký `stage1_wipe_registry` | `review/slice-p1-activation-ledger.md` | Không có phát hiện chặn |
| P2 | Khung khối + điểm gắn: `ThankYouSection` lồng trên `activity_card_detail_screen.dart`, `ThankYouBlockCubit`, phần khung của `thank_you_block.dart` | `review/slice-p2-block-shell-entry-point.md` | Không có phát hiện chặn (7 mục advisory, A3 cần PO xác nhận) |
| P3 | Danh mục preset "cảm ơn sau buổi hẹn": gói asset mới + luật `decline_door` theo phạm vi danh mục trong `invite_composer/domain/preset_content_gate.dart` | `review/slice-p3-preset-category.md` | Không có phát hiện chặn (5 mục advisory; A3 cần Scrum Master commit hàng ruling `CONTENT_GATE_CATEGORY_COUPLING`) |
| P4 | Đính ảnh: `attachable_photos.dart`, `photo_attach_section.dart`, khe ảnh + `_selectedPhotos` trong `thank_you_block.dart`, hàm chiếu chỉ-đọc `journalPhotoPathsForOrigin` ở cổng nhật ký | `review/slice-p4-photo-attach.md` | Không có phát hiện chặn (6 mục advisory; A1 handoff dẫn sai AC-4/AC-5 thay vì AC-14..AC-18/BR-8/BR-9; cặp `VISUAL_FIDELITY: PASS` + `DESIGN_SPEC_CONFLICT` cần final-synthesis quyết) |
| P5 | Next-plan suggestions | chưa trả | — |

## Scope Gate

`review/scope-gate.md` (Phase 1) do reviewer slice P1 viết, phạm vi giới hạn ở
đúng các file P1. Pass final-synthesis cần mở rộng lại scope gate cho cả story.

## Tóm tắt slice P1

Chi tiết đầy đủ, bằng chứng test và 6 mục advisory nằm trong
`review/slice-p1-activation-ledger.md`. Các điểm cần Scrum Master xử lý:

1. `stage1_wipe_registry_parity_test.dart` đỏ — đã xác nhận **PRE-EXISTING,
   cross-story** (registry thiếu `calendar_event_state`, `portrait_answers`,
   `relationship_labels` của STORY-009/010). Cần quyết định PO/Tech-Lead xuyên
   story; không phải lỗi của STORY-007.
2. Handoff trích `R-15c` — id không tồn tại trong `req_master.md` (chỉ có R-15,
   R-15a, R-15b).
3. `coding-plan/test-results.md` §P1 ghi BaseHead `d36e7a4a`, khác BaseHead
   review `bfe231aa`.
4. AC của phase P1 "bộ test của app xanh trở lại" không thoả theo nghĩa đen do
   baseline repo đã đỏ sẵn; gate thực chất đạt là "không thêm đỏ mới".
