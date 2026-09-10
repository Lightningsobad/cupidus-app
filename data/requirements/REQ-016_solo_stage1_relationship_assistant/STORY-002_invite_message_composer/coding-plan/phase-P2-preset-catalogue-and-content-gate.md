# Phase P2 – Kho preset theo danh mục + cổng nhập luật bất biến

## 1. Objective

Giao ba thứ đi liền nhau: bộ giải danh mục → khoá asset theo quy ước, gói
preset danh mục `invite` đã soạn, và cổng nhập luật bất biến chạy được trong
bản dựng. Đây là phase làm cho "vi phạm luật thì hỏng bản dựng" thành sự thật.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-preset-catalogue-and-content-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/invite_composer/domain/preset_catalogue.dart`
  - `mobile/lib/features/invite_composer/domain/preset_content_gate.dart`
  - `mobile/assets/data/req016/presets.invite.v1.json`
  - `mobile/test/features/invite_composer/preset_catalogue_test.dart`
  - `mobile/test/features/invite_composer/preset_content_gate_test.dart`
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
  - quy ước khoá asset `assets/data/req016/presets.<categoryId>.v1.json`
  - `validatePresetPack` — cổng nhập luật bất biến, đặt trong `lib/`
  - gói nội dung danh mục `invite`
- Shared Interfaces Consumed:
  - `InvitePreset` parser (P1)
  - `core/content/ContentPackageLoader`
- Risk Surfaces:
  - Luật bất biến lọt qua nội dung
  - N là thuộc tính dữ liệu
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §1(A), §2, §5, §6
  - consumer contract: P5 (sheet), STORY-007 (danh mục thứ hai)
- Primary Inputs Summary:
  - requirements: AC-11, AC-22, AC-23..AC-29
  - architecture: `../architecture/solution.md` §1 Key Discovery 4, §4 Risk table
  - OQ constraints: R-15a, R-15b, R-15c (D-15, đóng OQ-3)
  - upstream phase outputs: P1 `InvitePreset`
  - UX constraints, if truly required: `../ux/uiux-spec.md` §3 — preset phải soạn
    thành nhiều câu ngắn rời, mỗi câu mang tối đa 1-2 biến, để việc bỏ một câu
    không làm gãy ngữ pháp câu còn lại. Đây là ràng buộc soạn nội dung của phase
    này, không phải gợi ý.
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — nội dung vào hệ thống qua đúng một cổng.
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (AC-11, AC-22..AC-29, BR-5, BR-6, BR-10, BR-14..BR-16)
- `../architecture/contract-summary.md` §1(A), §2, §3, §5, §6
- `../ux/uiux-spec.md` §3, §7
- P1 output: `mobile/lib/features/invite_composer/domain/invite_preset.dart`

## 3. Tasks

- `preset_catalogue.dart`: `categoryId` → khoá asset bằng **quy ước chuỗi**,
  không bảng tra cứng trong code, để STORY-007 chỉ cần thêm file. Load qua
  `ContentPackageLoader` với `expectedSchemaId: 'req016.presets.v1'` dùng chung
  cho mọi danh mục. Cache gói theo `categoryId` sau lần parse đầu.
- `preset_content_gate.dart` — `validatePresetPack(ContentPackage<InvitePreset>)`
  trả về danh sách vi phạm. Luật **cấu trúc**: đúng một clause `role:
  decline_door` mỗi preset và clause đó phải có `requires: []`; mọi `targets`
  hợp lệ; `editorial_review` có đủ hai lớp. Luật **từ vựng**: denylist token
  cho tâng bốc, ký hiệu `%`, streak/chuỗi ngày, điểm số/tỉ lệ, chỉ báo hành vi
  người nhận ("đã xem", "đã đọc", "seen"), và giọng thao túng ("chiêu", "cưa",
  "thả thính"). Denylist nằm trong Dart, **không** trong asset — nếu không, CMS
  ngoài repo tự nới luật của chính nó.
- `preset_content_gate_test.dart`: quét `mobile/assets/data/req016/` từ đĩa bằng
  `dart:io`, khớp mọi file `presets.*.json`, parse và chạy gate trên từng gói.
  Quét đĩa thay vì liệt kê tay là điều làm cho gói của STORY-007 tự động rơi
  vào cổng mà không cần thêm nhánh (AC-29).
- Soạn gói `presets.invite.v1.json`: danh mục `invite`, `locale: "vi"`, nhiều
  preset, mỗi preset là chuỗi câu ngắn rời theo ràng buộc UX §3, mỗi preset có
  đúng một câu cửa từ chối `requires: []`, mọi câu đùa `targets: "sender"`.
  Ghi vết kiểm duyệt hai lớp vào `editorial_review` theo id bền.
- **Chỉ ship danh mục `invite`** (AC-22). Không tạo file `presets.thanks.*`.

## 4. Acceptance Criteria

- Gói `invite` load được và `validatePresetPack` trả về **không** vi phạm nào.
- Thêm một preset cố ý vi phạm vào fixture (thiếu cửa từ chối / có `%` / có
  "đã xem") → test đỏ. Đây là bằng chứng cổng thật sự làm hỏng bản dựng, không
  phải cổng trang trí (AC-28/BR-16).
- Gói với `schema_id` khác `req016.presets.v1` bị từ chối lúc load.
- Khoá asset của một `categoryId` bất kỳ suy ra được bằng quy ước, không cần sửa
  code (AC-21/AC-29).
- Không file nào trong `mobile/lib/` chứa câu chữ lời mời (R-15a).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/invite_composer/domain/`,
  `mobile/assets/data/req016/presets.invite.v1.json`
- Contracts or schemas: gói `req016.presets.v1` danh mục `invite`
- Notes or evidence: `../coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, domain + asset
- Required levels:
  - unit: `validatePresetPack`, giải khoá asset theo danh mục
  - integration: load gói `invite` thật từ đĩa và chạy gate lên nó
  - mobile build/type-check/static-analysis: có
- Required checks:
  - gói đã ship qua cổng sạch
  - mỗi luật của cổng có ít nhất một fixture vi phạm làm test đỏ
  - `schema_id` sai → exception
  - mọi preset trong gói ship có đúng một clause `decline_door`
- Minimum gates by risk surface:
  - Luật bất biến lọt qua nội dung: test quét đĩa + fixture vi phạm
  - N là thuộc tính dữ liệu: test không được khẳng định số preset cụ thể của gói
    ship; chỉ khẳng định `length >= 1`
- Required regression or contract coverage: `flutter test test/core/content/`
  vẫn xanh — `core/content/content_package.dart` không được sửa.
- Evidence format: đầu ra `flutter test` dán vào `../coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn UI nào.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/invite_composer/ test/core/content/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: kết quả gate trên gói ship + kết quả từng
    fixture vi phạm

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-10
