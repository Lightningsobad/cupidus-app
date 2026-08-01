# Requirement Master: REQ-001 Cupid Flutter Mobile App (iOS + Android)
Status: DONE — all 16 stories DONE and merged into
`codex/REQ-001_cupid_flutter_mobile_app-integration`; requirement integration
review `Outcome: CLEAN`; all 5 integration bugs (BUG-20260801-001..005)
DONE, Reviewer `Outcome: CLEAN` on each, independently confirmed by Scrum
Master; Integration Build & Runtime evidence gate CLEAN (`flutter build apk
--debug` exit 0, `flutter test` 880 passed / 2 pre-existing out-of-scope
failures). See
`data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/review-report.md`
for full evidence.

## Deployment Status
- Development Environment: BLOCKED — `main` does not contain the merge of
  `codex/REQ-001_cupid_flutter_mobile_app-integration` (13/16 stories and all
  5 integration bugfixes exist only on the integration branch, HEAD
  `2efa1489ef7b3ec176508801abe10fb071929026`; `main` still ends at STORY-003).
  DevOps `scripts/setup.sh`/`build.sh`/`start-dev.sh` all passed against
  `main`, but that result is not representative of the DONE requirement.
  Merging the integration branch into `main` is Scrum Master Git
  control-plane scope; re-dispatch DevOps once merged. See
  `deployment/deployment-log.md` § Latest Attempt.
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Source
- Brainstorm idea: `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/idea.md`
  - `## Handoff Package → scrum-master`
  - `## Quyết Định Đã Chốt (2026-07-29)` (D0-D5)
  - `## Bối Cảnh Đã Có (Đặc Tả Nguồn)`
- Brainstorm development log: `data/brainstorms/IDEA-20260729-001_cupid-flutter-mobile-architecture/development.md`
  - `## Convergence Notes` (bảng Impact/Effort rủi ro)
  - `## Open Questions` (OQ4, OQ5 còn mở)
- Design source (read-only, không sửa): `cupid-mobile-design/`
- Backend source (đã hoàn thiện, contract đóng băng — A1): `backend/src/modules/`, Swagger `/api-docs` (`backend/src/main.ts`)
- Kiến trúc client cũ (SUPERSEDED): `_bmad-output/planning-artifacts/architecture.md`

## Problem / Value
Xây ứng dụng mobile Cupid (couple-only, 1:1 pairing) bằng **Flutter** cho cả
iOS và Android, tiêu thụ backend NestJS đã hoàn thiện (~59 REST endpoint, 2
Socket.IO gateway, Firebase Auth), hiện thực đúng bộ design đã chốt tại
`cupid-mobile-design/` (~31 màn, 2 bản iOS/Material, dark + light, VI + EN).
Thay thế quyết định client cũ (iOS Native Swift/SwiftUI) đang khoá sản phẩm
vào 1 platform và không khớp bộ design đã vẽ sẵn cả 2 platform.

## Trong phạm vi
- ~31 màn theo prototype `cupid-mobile-design/` (`Cupid Screens.dc.html`),
  nhóm theo 6 epic backend hiện có: epic-1 (core connection), epic-2
  (communication), epic-3 (daily engagement), epic-4 (intimacy/memories),
  epic-5 (finance), epic-6 (admin/privacy — chỉ phần có màn mobile).
- Nền tảng client: design system + token (platform × theme), i18n (mặc định
  `vi`, có `en`), API client sinh từ OpenAPI (`/api-docs`), auth Firebase +
  refresh token, tầng realtime Socket.IO.
- Kênh realtime: chat (typing-ghost 2 chiều), anti-ghosting, nhắc nhở đồng bộ
  (xem đổi từ ngữ epic-3 ở mục Ghi chú bắt buộc).

## Ngoài phạm vi
- Module `admin` và `data-export` (không có màn design cho mobile — web
  admin / API-only).
- Báo thức cấp hệ thống / Critical Alerts entitlement (D1 hoãn khỏi v1).
- Thay đổi contract backend (A1: backend đóng băng, không đổi vì client).

## Ràng buộc kiến trúc đã chốt (D0-D5) — cho tech-lead viết ADR, không khám phá lại option space

| # | Quyết định | Nội dung | Hệ quả chính |
|---|-----------|----------|--------------|
| D0 | Client | Flutter, thay iOS Native (SwiftUI) | `_bmad-output/planning-artifacts/architecture.md` phần client = SUPERSEDED |
| D1 | Báo thức | v1 chỉ cần thông báo nhắc đủ mạnh, không cần báo thức thật | Không xin Critical Alerts, không viết module alarm native. Epic-3 đổi từ ngữ "báo thức" → "nhắc nhở đồng bộ" |
| D2 | State management | Bloc (Cubit cho màn CRUD, Bloc đầy đủ cho nghi thức + realtime) | Kèm `freezed` + `get_it`/`injectable`; `bloc_test`, cân nhắc `hydrated_bloc` |
| D3 | Adaptive UI | Bám design, giữ 2 bản iOS/Material | 1 cây widget + `ThemeExtension` (platform × theme) + 4 widget adaptive có tên, không fork màn hình |
| D4 | Archetype | Pragmatic Feature-First, 1 package (hội tụ qua PMI) | Hoãn melos monorepo và Pigeon tới khi thực sự cần |
| D5 | API client | Sinh từ OpenAPI (Swagger đã bật ở `backend/src/main.ts`, `/api-docs`) | Xoá phần lớn data layer viết tay; khoá contract client–server |

Chi tiết đầy đủ và lý do hội tụ: `idea.md` → `## Quyết Định Đã Chốt (2026-07-29)`
và `development.md` → mục 41-54 (`PMI`).

## Ghi chú bắt buộc cho breakdown / tech-lead (không được bỏ sót)

1. **`design_system` phải là story shared-foundation đầu tiên** — token
   (platform × theme, 4 tổ hợp) + i18n ARB (VI/EN). Làm sau sẽ phải sửa lại
   cả 31 màn (rủi ro R7: impact cao, effort thấp).
2. **Spike `RealtimeCoordinator` sớm** — hợp nhất Socket.IO + FCM (đường đôi
   foreground/background) là rủi ro số 1 sau khi chốt kiến trúc (R2, impact
   cao), không phải báo thức.
3. **Product Owner đổi từ ngữ epic-3**: "báo thức đồng bộ" → "**nhắc nhở
   đồng bộ**" trong mọi story/AC của epic-3 — hệ quả trực tiếp của D1, để
   không hứa quá với người dùng.

## Rủi ro bàn giao (bảng Impact/Effort đầy đủ ở `development.md` → `## Convergence Notes`)

| Rủi ro | Impact | Effort giảm thiểu | Hành động đề xuất |
|--------|--------|-------------------|-----------|
| R2 socket/FCM | Cao | Trung | Spike `RealtimeCoordinator` trước tiên |
| R7 design_system làm sau | Cao | Thấp | Story nền tảng đầu tiên, trước mọi feature |
| R6 kỷ luật Bloc/Cubit | Trung | Thấp | Chốt quy ước + lint trong ADR |
| R3 libsodium FFI | Trung | Trung | Spike build 2 platform sớm, trước epic-4 |
| R4 perf Android low-end | Trung | Thấp | Đo trên 1 máy Android low-end mốc |
| R1 alarm (đã hạ) | Thấp | Thấp | Chỉ cần PO chỉnh từ ngữ epic-3 |
| R5 trôi UI | Thấp | Thấp | Golden test atoms + ~6 màn tiêu biểu |

## Open Questions chưa giải quyết

- **OQ4 — Offline**: dùng Drift (SQLite, query thật) cho
  chat/timeline/expenses, hay chỉ dựa `hydrated_bloc` cho v1? Giả định tạm:
  Drift cho 3 miền có lịch sử dài, `hydrated_bloc` cho state phù du. Cần
  tech-lead xác nhận trong ADR.
- **OQ5 — Light theme & i18n EN có nằm trong v1 không?** Design đã vẽ cả 2.
  Giả định tạm: hạ tầng token + ARB làm ngay từ đầu, nhưng chỉ **bật**
  dark + vi ở v1. Product Owner cần quyết khi breakdown story (đặc biệt story
  `design_system`).

Nguồn đầy đủ: `development.md` → `## Open Questions`.

## Thứ tự nền tảng đề xuất (mức khám phá, không ràng buộc — tech-lead xác nhận lại trong coding-plan)

1. `design_system` + token (platform × theme) + i18n ARB — shared-foundation,
   trước mọi feature (R7).
2. `api_client` sinh từ OpenAPI `/api-docs` (D5).
3. Auth Firebase + interceptor refresh token.
4. Spike `RealtimeCoordinator` (hợp nhất Socket.IO + FCM) — R2, rủi ro cao
   nhất.
5. Feature theo epic-1 → epic-6 (trừ admin/data-export).

## Khoảng trống đã nhận diện (từ brainstorm, cần soi lại ở tech-lead/PO)

- Không có màn design cho `admin` và `data-export` → 2 module này ngoài phạm
  vi mobile.
- Design có `me`, `privacy`, `notifs` nhưng cần soi lại endpoint tương ứng
  khi vào tech-lead.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Design system: platform x theme tokens + i18n ARB infra | L | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/story_master.md |
| STORY-002 | API client generated from OpenAPI (`/api-docs`) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/story_master.md |
| STORY-003 | Auth: Firebase sign-in + refresh-token interceptor | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/story_master.md |
| STORY-004 | Spike: RealtimeCoordinator (Socket.IO + FCM dual path) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-004_realtime_coordinator_spike/story_master.md |
| STORY-005 | Epic-1: Pairing / 1:1 connection (invitations) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-005_pairing/story_master.md |
| STORY-006 | Epic-1: Love contracts / nghi thức cam kết | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-006_love_contracts/story_master.md |
| STORY-007 | Epic-2: Chat (2-way typing-ghost, realtime) | L | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-007_chat/story_master.md |
| STORY-008 | Epic-2: Anti-ghosting configuration | S | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-008_anti_ghosting/story_master.md |
| STORY-009 | Epic-3: Nhắc nhở đồng bộ | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-009_nhac_nho_dong_bo/story_master.md |
| STORY-010 | Epic-3: Vibes / cảm xúc hằng ngày | S | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-010_vibes/story_master.md |
| STORY-011 | Epic-3: Bun Pet đồng hành | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-011_bun_pet/story_master.md |
| STORY-012 | Epic-4: Timeline kỷ niệm | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-012_timeline/story_master.md |
| STORY-013 | Epic-4: Gallery ảnh chung | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/story_master.md |
| STORY-014 | Epic-4: Dream Jar / hũ ước mơ chung | S | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-014_dream_jar/story_master.md |
| STORY-015 | Epic-5: Chi tiêu chung (expenses) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/story_master.md |
| STORY-016 | Epic-6: Hồ sơ / quyền riêng tư / thông báo (mobile-only) | M | DONE | data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-016_profile_privacy_notifs/story_master.md |
