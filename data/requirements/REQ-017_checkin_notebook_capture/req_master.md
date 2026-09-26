# Requirement Master: REQ-017 Ghi vào sổ tay từ màn check-in 23h
Status: PENDING
Ready-For-Delivery: NO

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|

## Story Seeds
| Seed | Source Idea | Serves Which User Outcome | Notes |
|------|-------------|---------------------------|-------|
| SEED-1 | IDEA-20260925-001_checkin-to-notebook-capture | "Vừa về sau buổi hẹn, tôi ghi lại điều mới biết về người ấy mà không phải mở màn khác", để sổ tay đầy lên từ trải nghiệm thật và gợi ý quà/mồi chuyện/kịch bản bớt chung chung | Phương án đã chốt O-1b (user, 2026-09-25): trên màn check-in 23h (REQ-016/STORY-012 AC-16, bản vá D-6) thêm một lời hỏi-tại-chỗ **tuỳ chọn** "Hôm nay biết thêm gì về người ấy?", ghi thành mục sổ tay có cấu trúc thuộc hai loại **sở thích** hoặc **sự kiện/dịp**. Câu nhật ký **không bao giờ** được sao chép sang sổ tay. Mục ghi mang xuất xứ "từ buổi hẹn <thẻ>" (O-2) và sửa/xoá được trong màn sổ tay STORY-004 sẵn có, không thêm màn mới (O-3) |

## Brainstorm Handoff Context
- Source idea: `data/brainstorms/IDEA-20260925-001_checkin-to-notebook-capture/idea.md` (development: `development.md` `## Current Snapshot`, `## Convergence Notes`).
- Origin: chip canvas "+ ghi vào sổ tay" trên màn `23h-vua-ve-j8` đã bị loại khỏi REQ-016/STORY-012 vì AC-16 chỉ lưu nhật ký (vá AC-16 ngày 2026-09-25, ghi chú "requirement riêng, chờ user xác nhận"). User chọn mở requirement riêng (lựa chọn C) ngày 2026-09-25.
- Rejected options: O-1a (chép nguyên câu nhật ký sang sổ tay) bị loại vì vi phạm REQ-016 R-1f và phá riêng tư nhật ký (STORY-003). O-1c (tự đề xuất mục sổ tay từ từ khoá trong câu nhật ký) hoãn vì nguy cơ trái R-7.
- Binding constraints inherited from REQ-016 (`data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md`): R-1f (sổ tay chỉ sở thích + sự kiện, không đánh giá con người, không xuất/chia sẻ), SC-3 (không luồng điền trước, chỉ hỏi-tại-chỗ), R-7 (tất định, không AI, không API ngoài), R-15 (nội dung là dữ liệu có id bền), STORY-012 BR-12 (thẻ STORY-001 chỉ đọc).
- Delivery dependencies: REQ-016 STORY-003 (nhật ký), STORY-004 (sổ tay + cơ chế hỏi-tại-chỗ), STORY-012 (màn check-in toàn màn hình). REQ-017 không thể bắt đầu trước khi ba story này DONE.
- Priority: MEDIUM, chạy sau REQ-016. Đây là giả định của brainstormer theo khuyến nghị, vì user chưa trả lời câu hỏi ưu tiên (2026-09-25); user có thể đổi.

## Handoff Blocker
- 2026-09-25 — BLOCKED: `GIT_BOUNDARY_MISSING` (guard-git-story-boundary.sh). Guard chặn 3 lần liên tiếp lần spawn `Andy-PO` `Mode: requirement-breakdown`, `Scope: REQ-017_checkin_notebook_capture`, lần cuối với `Target: Andy-PO`. Guard đòi block Story Git Boundary. Nhưng `.agent-contract/handoff-schema.md` miễn Git-Boundary cho PO/UX, và REQ-017 chưa có story nào để `git-story-boundary.sh start --story` trỏ vào (chính requirement-breakdown là bước tạo story). Brainstormer không chạy `start --inline` với story giả, vì lệnh đó tạo worktree/branch thuộc Git state của Scrum Master.
- Không có artifact PO/UX nào được tạo. `Status: PENDING`, `Ready-For-Delivery: NO` giữ nguyên.
- Để gỡ: cần một exemption trong guard cho spawn backlog-shaping của brainstormer (`Mode: requirement-breakdown` / `story-requirements` / `ux-requirement-batch`), giống cách `Mode: ac-patch` hiện đang đi qua được. Sau đó chạy lại brainstormer `handoff-to-backlog` cho REQ-017, bắt đầu từ bước 7.
