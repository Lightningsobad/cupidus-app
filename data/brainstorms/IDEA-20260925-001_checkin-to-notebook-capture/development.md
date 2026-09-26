# Idea Development: IDEA-20260925-001 Ghi vào sổ tay từ màn check-in 23h

## BMAD Session State

- Stance: Ideate For Me (user đã chọn hướng qua một lựa chọn A–D, không cần facilitation dài)
- Topic: bắt thông tin sổ tay ngay trên màn check-in sau buổi hẹn
- Goal: chốt đủ hướng kinh doanh để PO tách story mà không vi phạm R-1f/SC-3
- Constraints: R-1f (chỉ sở thích + sự kiện, không đánh giá, không xuất/chia sẻ); SC-3 (không có luồng điền trước, chỉ hỏi-tại-chỗ); nhật ký riêng tư mặc định (STORY-003); BR-12 STORY-012 (thẻ chỉ đọc); R-7 (không AI, không API ngoài); phụ thuộc STORY-003, STORY-004, STORY-012 đã giao
- Active technique batch: Reverse Assumptions, What-If constraint flip, PMI
- Approximate raw idea count: 6
- Domain shifts explored: dữ liệu / quyền riêng tư / thời điểm UX
- Convergence state: CONVERGED — user chọn O-1b (2026-09-25)
- Next technique or move: handed off to REQ-017

## Idea Inventory

- 2026-09-25: Idea tạo từ lựa chọn C của user (tách chip "+ ghi vào sổ tay" khỏi STORY-012).
- 2026-09-25 (Ideate For Me), các phương án:
  - O-1a: chip bật/tắt "cũng ghi vào sổ tay" → sao chép nguyên câu nhật ký sang sổ tay.
  - O-1b: một lời hỏi-tại-chỗ riêng, tuỳ chọn: "Hôm nay biết thêm gì về người ấy?" với hai loại có cấu trúc: **sở thích** và **sự kiện/dịp**. Câu nhật ký vẫn chỉ vào nhật ký.
  - O-1c: sau khi lưu check-in, app đề xuất 0–1 mục sổ tay dựa trên từ khoá trong câu nhật ký (luật tất định, không AI).
  - O-2: ghi mục sổ tay kèm nguồn "từ buổi hẹn <tên thẻ>" để các màn sau hiển thị xuất xứ.
  - O-3: sửa/xoá mục vừa ghi ngay trong màn sổ tay của STORY-004 (không thêm màn mới).
  - O-4: đếm số mục sổ tay được ghi từ check-in để đo giả thuyết giá trị.

## Current Snapshot

- Problem framing: khoảnh khắc sau buổi hẹn giàu thông tin nhất nhưng sổ tay không có cửa vào ở đó.
- Target actors: người dùng solo chặng 1, ngay sau buổi hẹn.
- JTBD or use moment: "Vừa về, tôi muốn nhớ lại điều mới biết về người ấy mà không phải mở một màn khác."
- Value proposition: sổ tay đầy lên từ trải nghiệm thật, nên gợi ý của cả chặng 1 cá nhân hoá hơn.
- Option space: O-1a / O-1b / O-1c (xem Inventory); O-2, O-3, O-4 là phần bổ sung.
- Differentiators: dùng lại đúng cơ chế hỏi-tại-chỗ của STORY-004 thay vì mở một luồng điền trước.
- Risks and constraints: O-1a đẩy câu nhật ký (riêng tư, có thể chứa đánh giá con người) vào sổ tay, nên vi phạm R-1f và phá tính riêng tư của nhật ký. O-1c cần phân tích văn bản, dễ trượt thành "AI" và trái R-7. Phụ thuộc ba story của REQ-016 đã giao.
- Assumptions: người dùng chịu gõ thêm một ý ngắn khi được hỏi đúng lúc; lời hỏi là tuỳ chọn và không làm màn check-in nặng thêm.
- Open questions: đã đóng. O-1 = O-1b (user). Ưu tiên: MEDIUM sau REQ-016 (giả định mặc định, user chưa trả lời).
- Recommended next move: chọn O-1b (+ O-2, O-3), ưu tiên MEDIUM, chạy sau REQ-016.

## Convergence Notes

- 2026-09-25 PMI:
  - O-1a: + nhanh nhất, khớp chữ canvas; − vi phạm R-1f, phá riêng tư nhật ký. **Loại**, trừ khi user ghi đè R-1f.
  - O-1b: + đúng SC-3 (hỏi-tại-chỗ), đúng R-1f vì dữ liệu có cấu trúc; − thêm một ô trên màn check-in. **Khuyên chọn.**
  - O-1c: + ít thao tác; − nguy cơ trái R-7, luật tất định khó đạt chất lượng. **Hoãn.**

## Research Notes

- None (chỉ dùng bằng chứng trong repo: REQ-016 req_master R-1f/SC-3, STORY-004 story_brief, STORY-012 AC-16 sau vá).

## Session Log

- 2026-09-25: Tạo idea và chạy một vòng Ideate For Me + PMI. Chờ user chốt O-1 và ưu tiên trước khi handoff.
- 2026-09-25: User chốt O-1b → EXPANDED → handoff sang REQ-017.
