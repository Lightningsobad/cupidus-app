# Phase P4 – Payload SB-125: mô hình, codec, repository

## 1. Objective

Giao lớp lưu trữ vật phẩm lời mời: payload có cấu trúc render lại được, codec
JSON cho `filled_values`, và repository ghi/đọc `invite_messages`. Đây là hợp
đồng mà chặng 1.5 và STORY-008 sẽ đọc lại, nên hình dạng của nó là sản phẩm
chính của phase.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-sb125-payload-repository.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/invite_composer/domain/invite_payload.dart`
  - `mobile/lib/features/invite_composer/domain/invite_payload_repository.dart`
  - `mobile/lib/features/invite_composer/data/invite_payload_repository_impl.dart`
  - `mobile/lib/core/database/daos/invite_message_dao.dart`
  - `mobile/test/features/invite_composer/invite_payload_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `InvitePayload` + codec `filled_values`
  - `InvitePayloadRepository` (cố ý **không** có API đếm theo thẻ)
- Shared Interfaces Consumed:
  - bảng `invite_messages` (P3)
  - `renderInvite` (P1) cho đường render lại
- Risk Surfaces:
  - Hình dạng payload SB-125
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §4
  - consumer contract: P5 (sheet ghi payload lúc chia sẻ); STORY-008 và chặng
    1.5 ngoài story
- Primary Inputs Summary:
  - requirements: AC-13, AC-14, AC-17, AC-18, AC-19
  - architecture: `../architecture/solution.md` §1 Key Discovery 3, §4 Contracts
    And Integrations
  - upstream phase outputs: P3 schema v5, P1 `renderInvite`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — vật phẩm đã xuất được lưu và dựng lại y nguyên.
  - Source/Test File Count: 5 (chưa kể `.g.dart`)
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (AC-13, AC-14, AC-17..AC-19)
- `../architecture/contract-summary.md` §2, §4, §6
- `../architecture/solution.md` §1 Key Discovery 3
- P3 output: `mobile/lib/core/database/tables/invite_messages_table.dart`

## 3. Tasks

- `InvitePayload`: `id`, `cardId`, `categoryId`, `presetId`, `packVersion`,
  `filledValues` (Map<String, String>), `userEditedText` (nullable), `createdAt`.
  Codec JSON chỉ cho `filledValues`; các trường còn lại là cột riêng, không gộp
  vào một blob.
- `savePayload(...)` ghi một hàng mỗi lần người dùng bấm chia sẻ. Không
  idempotency key: hai lần bấm là hai vật phẩm, và vì không bề mặt nào đếm
  chúng thì trùng lặp không quan sát được.
- `renderStored(InvitePayload)` = `userEditedText ?? renderInvite(preset[presetId],
  filledValues)`. `userEditedText` là **bản ghi đè thủ công (AC-7)**, không phải
  dạng lưu chính — ghi chuỗi đã render vào `filledValues` hoặc các cột id là vi
  phạm hợp đồng AC-17.
- Repository chỉ phơi ra `latestForCard(cardId)` và `payloadById(id)`. **Không**
  thêm `countForCard`, `allPayloads`, hay bất kỳ API tổng hợp/xếp hạng nào —
  R-1e/AC-14 cấm, và một API đếm là thứ khiến bề mặt đếm xuất hiện sau này.
- Không thêm trường thời điểm gửi/mở/xem, không lưu `ShareResult`.

## 4. Acceptance Criteria

- Lưu → đóng và mở lại database → `renderStored` ra **đúng** chuỗi lúc xuất, ở
  cả hai nhánh: người dùng không sửa, và người dùng có sửa tay (AC-18).
- Preset đổi `packVersion` sau khi payload đã lưu: payload cũ vẫn dựng lại được
  vì nó giữ `presetId` bền + `filledValues` của chính nó.
- Không có API nào của repository trả về số lượng payload theo thẻ (AC-14).
- Bảng không có, và test khẳng định không có, cột nào mang dữ liệu người nhận
  hay hành vi người nhận (AC-19/R-1b).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/invite_composer/domain|data/`,
  `mobile/lib/core/database/daos/`
- Contracts or schemas: `InvitePayload` theo `contract-summary.md` §4
- Notes or evidence: `../coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, domain + tầng dữ liệu
- Required levels:
  - unit: codec `filledValues`, `renderStored` hai nhánh
  - integration: round-trip qua database thật (mở lại kết nối giữa ghi và đọc)
  - mobile build/type-check/static-analysis: có
- Required checks:
  - round-trip ra đúng chuỗi, cả nhánh có và không có `userEditedText`
  - payload lưu trước khi `packVersion` đổi vẫn dựng lại được
  - bề mặt public của repository không chứa API đếm/tổng hợp
- Minimum gates by risk surface:
  - Hình dạng payload SB-125: test round-trip có mở lại database
- Required regression or contract coverage: `flutter test test/core/database/`
  vẫn xanh sau khi thêm DAO.
- Evidence format: đầu ra `flutter test` dán vào `../coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn UI nào.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/invite_composer/ test/core/database/`
  - Build/type-check/lint command when required:
    `dart run build_runner build --delete-conflicting-outputs` rồi
    `flutter analyze lib test`
  - Required assertion evidence: chuỗi trước khi lưu và chuỗi sau khi dựng lại,
    dán cạnh nhau trong evidence

## 7. Status

- Status: DONE
- Last updated: 2026-09-10

### Lệch write scope

`mobile/lib/core/database/cupid_database.dart` (+ `cupid_database.g.dart` sinh
lại) nằm ngoài Write Scope khai báo ở §5 nhưng bắt buộc phải sửa: Drift chỉ
sinh `_$InviteMessageDaoMixin` khi DAO có tên trong `daos:` của
`@DriftDatabase`, và ADR-010 chỉ cho phép đúng một `@DriftDatabase` trong `lib/`
(có test khẳng định). Thay đổi thuần cộng thêm: một import và một phần tử
trong `daos:`. Bằng chứng ở `../coding-plan/test-results.md` mục "Phase P4".
