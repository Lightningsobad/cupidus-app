# Phase P2 – Mô hình thẻ, repository, và cửa ghi dùng chung

## 1. Objective

Dựng hợp đồng Dart mà 11 story sau lập trình dựa vào: model thẻ, 4 định danh
trạng thái, `primaryActionFor`, và `createCard` với `title` là trường bắt buộc
duy nhất.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-card-domain-repository.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/activity_cards/domain/activity_card.dart`
  - `mobile/lib/features/activity_cards/domain/activity_card_repository.dart`
  - `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/activity_cards/activity_card_repository_test.dart`
  - `mobile/test/features/activity_cards/activity_card_status_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `createCard`, `ActivityCardStatus`, `ActivityCardOrigin`, `primaryActionFor`
    (`../architecture/contract-summary.md` §1, §2)
- Shared Interfaces Consumed:
  - `ActivityCardDao` từ P1
- Risk Surfaces:
  - AC-15 mất dữ liệu âm thầm khi lùi trạng thái
  - SC-4/SC-5 — đúng một hành động chính, không ngõ cụt
  - Vỡ hợp đồng cho 11 story sau
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §1, §2
  - consumer contract: P4, P5, P6 và STORY-002/004/005/006/007/008/011/012/013
- Primary Inputs Summary:
  - requirements: AC-6, AC-7, AC-9, AC-11, AC-12, AC-14, AC-15, BR-2, BR-13
  - architecture: `../architecture/solution.md` §4 Contracts And Integrations
  - upstream phase outputs: P1 DAO
  - UX constraints: `../ux/uiux-spec.md` §2 bảng SC-4 (bốn nhãn hành động chính)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — hợp đồng domain + repository.
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../architecture/contract-summary.md`
- `../architecture/solution.md` §4
- `../requirements/requirements.md` Nhóm B, Nhóm C
- `../ux/uiux-spec.md` §2

## 3. Tasks

- `ActivityCardStatus` với 4 định danh lưu trữ `idea`/`scheduled`/`done`/`memory`;
  nhãn tiếng Việt lấy từ l10n, **không** hard-code trong enum.
- `primaryActionFor(status)` là hàm thuần, nguồn duy nhất ánh xạ trạng thái →
  hành động chính theo bảng SC-4. Không API nào trả về hai hành động chính.
- `ActivityCardOrigin` với các định danh hiện có, khai báo append-only.
- `createCard(NewActivityCard)`: `title` + `origin` bắt buộc, mọi trường khác
  tuỳ chọn; sinh UUID v4; mặc định `status = idea`, `reply_state = not_answered`,
  `invited = false`.
- Dán link: nhận URL thô, giữ nguyên vào `source_link`; nếu người dùng chưa nhập
  tiêu đề thì lấy host của URL làm `title` mặc định. **Không** gọi mạng để lấy
  metadata ở bất kỳ đâu.
- `updateStatus(cardId, status)` chỉ ghi cột `status`; cung cấp mutation riêng
  `clearScheduledDate(cardId)` để UI gọi khi người dùng chọn rõ ràng.
- Không thêm ràng buộc `status == scheduled ⇒ scheduled_on != null` (phá AC-14).
- Đăng ký repository trong `service_locator.dart`; **không** đăng ký làm
  `SessionScopedStore`.

## 4. Acceptance Criteria

- `createCard` với chỉ `title` tạo được thẻ ở trạng thái `idea` (AC-6).
- Dán URL tạo được thẻ kể cả khi không có tiêu đề/ảnh, `source_link` nguyên vẹn (AC-7).
- Chuyển `scheduled → idea` giữ nguyên `scheduled_on`, ghi chú, và ảnh (AC-15).
- Chuyển được tới cả 4 trạng thái theo hai chiều, không cạnh nào bị khoá (AC-14).
- `primaryActionFor` trả đúng một hành động cho mỗi trạng thái, khớp bảng SC-4.

## 5. Planned Outputs

- Code: model + repository interface + implementation + đăng ký DI.
- Contracts: hiện thực hoá `contract-summary.md` §1, §2.
- Notes: bằng chứng test ghi vào `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng domain/data
- Required levels:
  - unit: `createCard` tối thiểu, dán link suy giảm êm, ma trận chuyển trạng thái
    4×4 hai chiều, tính thuần của `updateStatus`, `primaryActionFor`
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks:
  - Test ma trận 16 cặp chuyển trạng thái: không cặp nào bị từ chối và không cặp
    nào làm mất dữ liệu cột khác.
  - Test khẳng định `primaryActionFor` là toàn phần trên 4 trạng thái và trả về
    đúng một hành động.
- Required regression or contract coverage: định danh trạng thái/origin được
  khẳng định bằng chuỗi literal để đổi tên là gãy test (R-15a).
- Minimum gates by risk surface: ba risk surface ở §1B đều có gate ở trên.
- Evidence format: output `flutter test` dán vào `coding-plan/test-results.md`.
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn hình.
- Verification strategy:
  - Targeted tests: `flutter test test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + kết quả pass cho từng gate trên.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-07
