# Master Coding Plan – STORY-004 Gợi ý quà, sổ tay và hồ sơ kỹ năng

## 1. Planning Metadata

- Story ID: STORY-004_relationship_notebook_and_gift_ideas (REQ-016)
- Complexity: complex (`Story-Class: shared-foundation`)
- OQ Constraints Source: `../../req_master.md` mục 15 (R-15, đóng OQ-3 bằng D-15)
- Requirement Configuration Guide impact: NOT_APPLICABLE — không biến môi trường,
  không secret, không tích hợp bên thứ ba, không endpoint mới.

## 2. Planning Goal

- Shared contract owner: Mobile Developer, `../architecture/contract-summary.md`
- Contract-first phase required: NO — mọi consumer trong story nằm cùng lane và
  cùng specialist, nên tầng luật bất biến dùng chung được gộp vào P2, phase tiêu
  thụ đầu tiên của nó, thay vì đứng riêng.
- Parallel execution possible: YES (trong cùng một lane mobile, nếu Scrum Master
  chạy nhiều lượt; thứ tự tuần tự dưới đây vẫn hợp lệ).
- Critical path: P1 → P3 → P4 và P2 → P5 → P6 → P7.
- Parallelism notes: P1 ∥ P2 (tách hẳn file: P1 chạm `core/database` + DI, P2
  chạm `core/content` + gate + asset). Sau đó P3 ∥ P5, rồi P4 ∥ P6. P7 đóng lại.

**Thứ tự pha bắt buộc SB-174/BR-11:** pha 1 (sổ tay + hồ sơ kỹ năng + hỏi-tại-chỗ)
= P1–P4 · pha 2 (gợi ý quà) = P5–P7 · pha 3 (handmade) nằm **trong** P5–P7 chứ
không thành phase riêng: `../architecture/contract-summary.md` §2 đã chốt nhánh
quà là **item dữ liệu** trong `gift_taxonomy`, nên thêm nhánh handmade là thêm dữ
liệu cộng một đầu vào kỹ năng, không phải một lane mã riêng. Tách nó ra sẽ buộc
hai phase cùng sửa `gift_selector.dart`.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Cơ chế hỏi-tại-chỗ + `ContextNotebookReader` (hợp đồng cho STORY-005/008/009/010) | Mobile Developer | P3 | P4, P7 (và story sau) | `../architecture/contract-summary.md` §3 |
| Ba bảng kho ngữ cảnh + migration cộng thêm | Mobile Developer | P1 | P3, P6 | `../architecture/contract-summary.md` §4 |
| Năm gói asset + `schema_id` + id bền | Mobile Developer | P2, P5 | P3, P6 | `../architecture/contract-summary.md` §2 |
| `createCard(NewActivityCard)` đẩy thẻ vào kho STORY-001 | STORY-001 (đã ship) | — | P7 | `../../STORY-001_activity_card_hub/architecture/contract-summary.md` §1 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Rẽ đôi tầng luật bất biến | P2 |
| Ranh giới sổ tay bị bẩn từ tầng ĐẦU VÀO | P2 |
| VNĐ/giá lọt vào bề mặt quà | P5, P7 |
| Hằng số N rò vào hành vi | P5, P6 |
| Migration Drift đụng độ với STORY-003 đang chạy | P1 |
| Hợp đồng shared-foundation bị định hình sai | P3 |
| Hồ sơ kỹ năng trượt về hình dạng CV | P2, P4 |
| Kho thẻ thứ hai / điểm dừng chân | P6, P7 |
| Đường đi không tất định / gọi mạng | P6 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source runtime
    registry `mobile-app.buildCommand` / `mobile-app.testCommand`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | YES (với P2) | NOT_STARTED |
| P2 | Mobile Developer | Mobile | None | YES (với P1) | NOT_STARTED |
| P3 | Mobile Developer | Mobile | P1, P2 | YES (với P5) | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P1, P3 | YES (với P6) | NOT_STARTED |
| P5 | Mobile Developer | Mobile | P2 | YES (với P3) | NOT_STARTED |
| P6 | Mobile Developer | Mobile | P1, P5 | YES (với P4) | NOT_STARTED |
| P7 | Mobile Developer | Mobile | P3, P6 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-context-notebook-persistence.md` |
| P2 | `phase-P2-shared-invariant-gate-and-context-packs.md` |
| P3 | `phase-P3-ask-on-the-spot-shared-surface.md` |
| P4 | `phase-P4-notebook-and-skill-screens-and-menu-entry.md` |
| P5 | `phase-P5-gift-content-packs-and-gate.md` |
| P6 | `phase-P6-gift-repository-and-deterministic-selector.md` |
| P7 | `phase-P7-gift-screen-quick-entry-and-push-to-hub.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`; không có file trùng id.
- Mọi phase mobile nằm trong một vòng đời specialist (khoảng sáu file
  source/test) hoặc đã được tách.
- Không phase nào bị tách chỉ vì hai phase sẽ ghi cùng một file, và không phase
  nào lặp lại khuôn của phase anh em cho một biến thể của cùng cụm hành vi.
- Không có phase hợp đồng đứng riêng: consumer của tầng luật dùng chung cùng
  lane, cùng specialist, chạy tuần tự.
- Không có phase verification/testing đuôi; mỗi phase tự chạy test của nó.
- Test scope của mọi phase loại trừ e2e backend, Playwright/browser e2e, mobile
  e2e, vòng đời emulator/simulator, trace, chạy lại kịch bản, script gate ở gốc
  repo, và runtime startup smoke.

## 6. Notes

- P1 **đọc `CupidDatabase.schemaVersion` thật trên nhánh tích hợp rồi cộng một**.
  STORY-003 còn đang chạy trên cùng nhánh tích hợp; chép một con số cố định từ
  tài liệu là cách hỏng duy nhất mà migration test không bắt được trước khi merge.
- P4 và P7 là hai phase lối vào (rule 13a): P4 gắn hai `_MenuRow` vào khối "Kho
  riêng của tôi", P7 nối `onSelected` của quick-entry strip. Mỗi phase mang dòng
  visual-fidelity riêng của story, không hoãn sang audit cấp requirement.
