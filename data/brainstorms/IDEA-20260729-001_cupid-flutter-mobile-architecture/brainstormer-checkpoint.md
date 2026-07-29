# Brainstormer Checkpoint

Scope:

- Idea ID: IDEA-20260729-001_cupid-flutter-mobile-architecture
- Workflow: develop-idea
- Lifecycle: ACTIVE
- Development Status: EXPANDED

Current State:

- Last Session: 2026-07-29 (cycle 2)
- Latest Focus: hội tụ archetype bằng PMI sau khi user chốt D1/D2/D3; xác minh
  bằng chứng từ design-source và Swagger backend
- Facilitation Stance: Creative Partner
- Active / Next Technique: đã chạy Assumption Reversal → Constraint-First →
  Forced Archetypes → Contrarian → Design-source probe → **PMI (hội tụ)** →
  Impact/Effort. Không còn kỹ thuật bắt buộc tiếp theo.
- Approximate Raw Idea Count: ~46
- Convergence State: **CONVERGED (sơ bộ)** — D0–D5 đã chốt
- Research Needed: KHÔNG. A4 đã xác minh cục bộ (Swagger bật).

Files Updated:

- idea.md
- development.md

Decisions Locked (D0–D5):

- D0 Flutter thay iOS Native
- D1 thông báo nhắc, KHÔNG cần báo thức thật ở v1
- D2 Bloc (Cubit cho CRUD, Bloc đầy đủ cho nghi thức + realtime)
- D3 bám design 2 bản, nhưng = 1 cây widget + token (platform × theme) + 4 điểm
  rẽ nhánh, KHÔNG fork màn hình
- D4 archetype "Pragmatic Feature-First, 1 package"; hoãn melos + Pigeon
- D5 sinh API client Dart từ OpenAPI (`/api-docs` đã bật)

Next Valid Step:

- Action: **HANDOFF_RECOMMENDED — user đã duyệt handoff 2026-07-29.**
  Brainstormer đã đóng gói bàn giao và DỪNG. Không tạo `data/requirements/`.
  Bước kế tiếp thuộc về user: chạy `scrum-master` (hoặc `PM`) với seed trong
  `idea.md` → `## Handoff Package → scrum-master`.
- Inputs cho scrum-master:
  - `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/idea.md`
    → `## Handoff Package → scrum-master`, `## Quyết Định Đã Chốt (2026-07-29)`,
    `## Bối Cảnh Đã Có (Đặc Tả Nguồn)`
  - `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/development.md`
    → `## Convergence Notes` (bảng Impact/Effort), `## Open Questions` (OQ4, OQ5)
- Backlog state tại thời điểm bàn giao: `data/requirements/` CHƯA TỒN TẠI, chưa
  có `data/runtime/scrum-master-active-scope.json` → đây là requirement đầu tiên.
- Output Paths: do scrum-master tạo (`data/requirements/...`), KHÔNG phải
  brainstormer.
- Quay lại brainstormer chỉ khi: cần cycle 3 cho OQ4/OQ5 hoặc mô hình hoá
  `RealtimeCoordinator` ở mức khám phá.

Do Not Re-read:

- broad prior chat narrative
- `_bmad-output/planning-artifacts/architecture.md` (đã trích, SUPERSEDED)
- `cupid-mobile-design/*.dc.html` (đã trích đủ: 31 màn, token, 4 điểm rẽ nhánh,
  i18n, light theme)
- `backend/src/` (đã trích: 16 module, ~59 endpoint, 2 gateway, Firebase, Swagger)

Large File Query Keys:

- idea.md: `## Quyết Định Đã Chốt (2026-07-29)`
- idea.md: `## Bối Cảnh Đã Có (Đặc Tả Nguồn)`
- development.md: `## Convergence Notes`
- development.md: `## Current Snapshot`
- development.md: `## Open Questions`
- development.md: `## Idea Inventory`

Open Threads:

- OQ4: Drift vs hydrated_bloc cho offline (không chặn; giả định tạm = Drift cho
  chat/timeline/expenses, hydrated_bloc cho state phù du)
- OQ5: light theme + tiếng Anh có bật ở v1 không (giả định tạm = làm hạ tầng
  token/ARB ngay, chỉ bật dark + vi ở v1)
- Hệ quả sản phẩm của D1: epic-3 cần đổi từ ngữ "báo thức đồng bộ" → "nhắc nhở
  đồng bộ" — thuộc `product-owner`, không phải brainstormer
- Rủi ro số 1 cần spike sớm: R2 Socket.IO lifecycle + hợp nhất socket/FCM
- Ranh giới: ADR ràng buộc do `tech-lead` viết qua `scrum-master`
