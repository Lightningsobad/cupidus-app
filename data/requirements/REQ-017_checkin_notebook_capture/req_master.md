# Requirement Master: REQ-017 Ghi vào sổ tay từ màn check-in 23h
Status: DONE
Ready-For-Delivery: YES

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
| STORY-001 | Ghi điều mới biết về người ấy vào sổ tay ngay trên màn check-in 23h | standard | DONE | `STORY-001_checkin_notebook_capture/story_master.md` |

Breakdown: `requirements/requirements.md` (1 seed → 1 story; OQ-1 và OQ-2 đã giải quyết 2026-09-27, xem `## User Decisions`; không còn OQ chặn).

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
- Priority: MEDIUM, chạy sau REQ-016. User xác nhận ngày 2026-09-27 (xem `## User Decisions`).

## User Decisions
- 2026-09-27 — OQ-1: RESOLVED. User đồng ý diễn giải BR-8/AC-1: thông báo 23h và câu hỏi chính của màn check-in vẫn hướng vào người dùng. Lời hỏi O-1b "Hôm nay biết thêm gì về người ấy?" là khối phụ, tuỳ chọn, đứng sau phần ảnh và nhật ký, chỉ xin sở thích hoặc sự kiện/dịp. Hệ quả ngoài REQ-017: REQ-016 STORY-012 AC-19 cần một bản vá truy vết (`ac-patch`) ghi nhận diễn giải này. Việc đó thuộc Helen-SC, brainstormer không spawn `ac-patch`.
- 2026-09-27 — A-5: CONFIRMED. Check-in chỉ ghi một ý và loại của nó. Ngày và chi tiết của mục "sự kiện/dịp" để người dùng bổ sung ở màn Sổ tay.
- 2026-09-27 — OQ-2 (ưu tiên): RESOLVED. Giữ MEDIUM, chạy sau REQ-016.

## Handoff Blocker
- 2026-09-25 — BLOCKED: `GIT_BOUNDARY_MISSING` (guard-git-story-boundary.sh). Guard chặn 3 lần liên tiếp lần spawn `Andy-PO` `Mode: requirement-breakdown`, `Scope: REQ-017_checkin_notebook_capture`, lần cuối với `Target: Andy-PO`. Guard đòi block Story Git Boundary. Nhưng `.agent-contract/handoff-schema.md` miễn Git-Boundary cho PO/UX, và REQ-017 chưa có story nào để `git-story-boundary.sh start --story` trỏ vào (chính requirement-breakdown là bước tạo story). Brainstormer không chạy `start --inline` với story giả, vì lệnh đó tạo worktree/branch thuộc Git state của Scrum Master.
- Không có artifact PO/UX nào được tạo. `Status: PENDING`, `Ready-For-Delivery: NO` giữ nguyên.
- 2026-09-27 — chạy lại từ bước 7, vẫn BLOCKED `GIT_BOUNDARY_MISSING`, 2 lần spawn `Andy-PO` (`Mode: requirement-breakdown`, `Flow: story`, `Scope: REQ-017_checkin_notebook_capture`, `Checkpoint: NONE`). Lần 2 đã bỏ toàn bộ tên thư mục story REQ-016 khỏi thân handoff, guard vẫn chặn. Vậy nguyên nhân là tổ hợp `Flow: story` + Target PO, không phải chữ trong thân handoff. Guard hook và handoff contract không thay đổi từ 2026-09-24. Không có parallel run nào đang active.
- Mâu thuẫn contract: skeleton `requirement-breakdown` trong `.claude/skills/scrum-master/references/handoffs/product-owner.md` ghi `Flow: story`, còn `.agent-contract/handoff-schema.md` nói PO/UX "never receive a `Flow: story` handoff". Enum `Flow` lại không có giá trị nào cho backlog-shaping. Brainstormer không tự đặt ra giá trị `Flow` để lách guard.
- Để gỡ: cần một exemption trong guard cho spawn backlog-shaping của brainstormer (`Mode: requirement-breakdown` / `story-requirements` / `ux-requirement-batch`), giống cách `Mode: ac-patch` hiện đang đi qua được. Sau đó chạy lại brainstormer `handoff-to-backlog` cho REQ-017, bắt đầu từ bước 7.
- 2026-09-27 — RESOLVED: skeleton handoff PO/UX đã bỏ `Flow:`. Spawn `Andy-PO` (`requirement-breakdown`, rồi `story-requirements`) qua guard không bị chặn.
- 2026-09-27 — Handoff hoàn tất: PO `requirement-breakdown` + `story-requirements` (STORY-001) và UX `ux-requirement-batch` đều COMPLETE. `Ready-For-Delivery: YES`. `Status` trả về `PENDING` (PO đã đổi thành IN_PROGRESS), để Scrum Master tự chuyển trạng thái khi `continue`.

## Delivery Closure (2026-09-28)
- STORY-001 review: `DEFERRED_ONLY` (`STORY-001_checkin_notebook_capture/review/review-report.md`).
- Story branch merged vào integration branch: merge_sha
  `a15bde4fb6a5d4e8de67410a1f0fd4b2b00612b7`.
- Requirement integration review (`Iris-QC`, 2 lượt):
  - Lượt 1: `PATCH_REQUIRED` (F-I1 thiếu build+runtime evidence cấp
    integration, F-I2 thiếu mobile visual audit cấp integration).
  - Lượt 2 (sau khi F-I1/F-I2 được xử lý): `DEFERRED_ONLY`, không còn blocking
    finding. Các mục deferred: D-I3 (đã sửa), D-I1 (đã xử lý — xem dưới), D-I2
    (thông tin, không cần hành động), A-1 (xem mục theo dõi bên dưới).
    Report: `integration-review/review-report.md`.
- `sync-integration` (do `land-integration` báo `LAND_BASE_STALE`, main đã
  tiến thêm commit `70ddb8b8`): merge history-only, không đổi nội dung (diff
  rỗng, xác nhận độc lập bởi Scrum Master và `Frank-Devops`). Build+runtime
  evidence resync tại HEAD `e1012284` PASS, commit `04472512`.
- Landed vào `main`: merge_sha `5fd1f448e7b1d091b123b1358d1a4579e3c01eab`.
  Integration branch và story worktree đã dọn (`cleanup-requirement`,
  `land-integration` lần 2 xoá nhánh `codex/REQ-017_checkin_notebook_capture-integration`).
- **Theo dõi sau khi đóng requirement (chưa phải story riêng, không tự tạo
  artifact backlog — cần user xác nhận trước khi vào brainstormer/PO):**
  1. REQ-016 STORY-004: bổ sung "đổi loại" (kind-changing) cho UI sửa mục sổ
     tay, theo quyết định Option B trước đây của user — vẫn cần qua
     brainstormer/product-owner intake đúng quy trình.
  2. A-1 (advisory từ mobile visual audit REQ-017): trên khối "Hôm nay biết
     thêm gì về người ấy?" ở màn check-in 23h, các chip loại (sở thích /
     sự kiện) bị nút Lưu (pinned CTA) che một phần — vẫn thao tác được bằng
     cách cuộn nhẹ, không vi phạm AC nào, Iris-QC khuyến nghị ghi nhận như một
     quan sát UX deferred, không mở lại STORY-001.
