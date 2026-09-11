# Master Coding Plan – STORY-002 Xuất lời mời (khung nhại + mad-libs)

## 1. Planning Metadata

- Story ID: STORY-002_invite_message_composer
- Complexity: complex (Story-Class: shared-foundation)
- OQ Constraints Source: OQ-3 ĐÃ ĐÓNG 2026-09-06 bằng D-15 → R-15a/b/c. Không
  còn OQ mở nào chặn story này; ràng buộc kỹ thuật kế thừa nằm ở AC-25..AC-29.
- Requirement Configuration Guide impact: NOT_APPLICABLE — mobile-only, không
  biến môi trường, không secret, không tích hợp bên thứ ba mới (share_plus đã
  có sẵn trong `pubspec.yaml` từ trước).

## 2. Planning Goal

- Shared contract owner: P2 (gói preset + cổng nhập luật) và P4 (payload
  SB-125). Hợp đồng bản thân nó ở `../architecture/contract-summary.md`.
- Contract-first phase required: NO — một lane duy nhất (Mobile Developer),
  các consumer trong story chạy tuần tự sau producer. Hợp đồng được gấp vào
  chính phase producer đầu tiên của nó, không tách phase riêng.
- Parallel execution possible: YES — P1 và P3 là hai gốc độc lập (engine thuần
  Dart vs schema sqlite); chúng không chạm file chung.
- Critical path: P1 → P2 → P5 → P6.
- Parallelism notes: P3 → P4 chạy song song được với P1 → P2. P5 là điểm hợp
  lưu: nó cần cả gói preset (P2) lẫn repository payload (P4). Nếu chỉ có một
  lane worker, thứ tự rẻ nhất là P1, P3, P2, P4, P5, P6.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| Lược đồ gói preset + quy ước khoá asset theo danh mục | Mobile Developer | P2 | P5 (trong story); STORY-007 (ngoài story) | `../architecture/contract-summary.md` §1(A), §3 |
| Cổng nhập luật bất biến | Mobile Developer | P2 | STORY-007 (ngoài story) | `../architecture/contract-summary.md` §5, §6 |
| Payload SB-125 `invite_messages` | Mobile Developer | P4 | P5 (trong story); STORY-008 và chặng 1.5 (ngoài story) | `../architecture/contract-summary.md` §4 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Luật bất biến lọt qua nội dung | P1, P2 |
| Hình dạng payload SB-125 | P3, P4 |
| Migration phá dữ liệu chỉ tồn tại trên máy | P3 |
| Cửa vào và SC-4 | P5, P6 |
| Tất định và không AI runtime | P1 |
| N là thuộc tính dữ liệu | P2, P5 |
| Trung thực thị giác của hai sheet | P5, P6 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app` (`testCommand: flutter test`,
    `buildCommand: flutter build apk --debug`). Story này không thêm, không đổi,
    và không xoá entry nào của registry.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | YES (với P3) | NOT_STARTED |
| P2 | Mobile Developer | Mobile | P1 | NO | NOT_STARTED |
| P3 | Mobile Developer | Mobile | None | YES (với P1) | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P3 | NO | NOT_STARTED |
| P5 | Mobile Developer | Mobile | P2, P4 | NO | NOT_STARTED |
| P6 | Mobile Developer | Mobile | P3, P5 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-mad-libs-render-engine.md` |
| P2 | `phase-P2-preset-catalogue-and-content-gate.md` |
| P3 | `phase-P3-schema-v5-location-and-invite-store.md` |
| P4 | `phase-P4-sb125-payload-repository.md` |
| P5 | `phase-P5-invite-composer-sheet.md` |
| P6 | `phase-P6-prepare-entry-surface-and-location-field.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`; không có file trùng id.
- Phase Mobile phải vừa một vòng đời specialist (khoảng sáu file source/test)
  hoặc bị tách.
- Không có phase nào bị tách chỉ vì hai phase sẽ ghi cùng một file.
- Không có phase contract độc lập: cùng một specialist cài đặt hợp đồng và mọi
  consumer trong story theo thứ tự, trong một lane.
- Không có phase kiểm thử/nghiệm thu đuôi; mỗi phase tự chạy test và
  build/type-check của chính nó.
- Test scope của phase không chứa e2e, browser e2e, vòng đời thiết bị ảo,
  ký/nộp store, trace, hay runtime startup smoke.

## 6. Notes

- `cupid_database.dart` chỉ được sửa **một lần**, ở P3. Cột `location` và bảng
  `invite_messages` cùng nằm trong bước nhảy schema v5, nên tách chúng thành hai
  phase sẽ tạo hai phase ghi cùng một file và hai lần chạy `build_runner` cho
  cùng một version — P3 làm cả hai và là phase duy nhất chạm `core/database/`.
- P6 là phase cửa vào bắt buộc: nó thay snackbar stub "Phần chuẩn bị nằm ở bước
  sau" bằng bề mặt thật. Không có P6 thì P5 là tính năng mồ côi, không đường tới.
