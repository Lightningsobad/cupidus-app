# Idea Master: IDEA-20260925-001 Ghi vào sổ tay từ màn check-in 23h
Lifecycle: ACTIVE
Development Status: EXPANDED
Source: user (lựa chọn C, 2026-09-25 — tách từ chip canvas "+ ghi vào sổ tay" của REQ-016/STORY-012, ruling D-6)
Created: 2026-09-25
Last Updated: 2026-09-27
Linked Requirement: REQ-017

## Seed

Original idea: Canvas `23h-vua-ve-j8` (REQ-016/STORY-012, màn check-in "Về tới nhà chưa?") có chip "+ ghi vào sổ tay". AC-16 của STORY-012 chỉ cho lưu câu viết vào **nhật ký** (STORY-003), nên chip đó bị loại khỏi STORY-012 (vá 2026-09-25). User chọn mở một requirement riêng cho hành động "ghi vào sổ tay" thật từ màn check-in, ghi sang sổ tay người yêu của STORY-004.

## Current Business Framing

- Problem: Ngay sau buổi hẹn là lúc người dùng vừa biết thêm điều mới về người kia (món thích, chuyện kể, dịp sắp tới), nhưng sổ tay (STORY-004) chỉ được đổ đầy bằng hỏi-tại-chỗ (SC-3) ở các cửa vào khác. Không có chỗ nào bắt đúng khoảnh khắc "vừa về".
- Target actor: người dùng chặng 1 (solo) vừa đi hẹn về, mở màn check-in từ nhắc 23h.
- Value hypothesis: một lời hỏi-tại-chỗ tuỳ chọn trên màn check-in làm sổ tay đầy lên từ trải nghiệm thật, nên gợi ý quà, mồi chuyện và kịch bản (STORY-004/005/008/009/010) bớt chung chung.
- Why this might matter now: STORY-012 vừa đổi màn check-in thành màn đầy đủ (D-6). Canvas đã vẽ sẵn chỗ cho hành động này.
- Notes: Hướng đã chốt O-1b (2026-09-25): hỏi-tại-chỗ tuỳ chọn, mục sổ tay có cấu trúc (sở thích / sự kiện-dịp), không chép câu nhật ký. Bị R-1f ràng buộc chặt: sổ tay chỉ ghi sở thích và sự kiện, không đánh giá con người, không xuất hay chia sẻ. Câu nhật ký mặc định riêng tư (STORY-003).

## Artifacts

- Development: `development.md`
- Checkpoint: `brainstormer-checkpoint.md`

## Routing Notes

- Current owner: brainstormer
- Next action: none (handed off)
- Delivery handoff: handed off to REQ-017 on 2026-09-25 (user chốt O-1b; ưu tiên MEDIUM là giả định mặc định)
- Delivery handoff completed 2026-09-27: REQ-017 Ready-For-Delivery YES (1 story, PO + UX done; user resolved OQ-1, A-5, priority MEDIUM)
