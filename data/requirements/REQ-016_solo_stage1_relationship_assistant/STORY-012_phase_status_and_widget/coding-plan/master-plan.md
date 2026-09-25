# Master Coding Plan – STORY-012 Trạng thái theo pha, widget, và bộ đếm

## 1. Planning Metadata

- Story ID: STORY-012_phase_status_and_widget
- Complexity: complex
- Requirement Configuration Guide impact: REQUIRED — App Group iOS, target
  extension WidgetKit mới, và quyền `POST_NOTIFICATIONS` Android 13+ là cấu
  hình bản dựng chưa từng tồn tại. `../../deployment/configuration-guide.md`
  **chưa có**; P5 tạo nó.

## 2. Planning Goal

- Shared contract owner: P4 (Dart `buildWidgetPayload` + tập khoá native)
- Contract-first phase required: NO — tập khoá ở `../architecture/contract-summary.md`
  §2 do P4 dựng và P4/P5 tiêu thụ ngay, nhưng người tiêu thụ là **mã Swift/Kotlin
  ở lane khác toolchain**, nên hợp đồng đã có nhà riêng trong artifact kiến trúc;
  không cần thêm một phase chỉ để phát vài hằng chuỗi.
- Parallel execution possible: YES — sau P1, ba nhánh (P2/P3 logic thuần, P4/P5
  native, P6 thông báo) độc lập nhau.
- Critical path: P1 → P2 → P7 → P8
- Parallelism notes: P4 chỉ cần P2+P3 (nguồn payload); P6 chỉ cần P1+P2. P7 và
  P8 **cùng sửa** `activity_card_hub_view.dart` nên chạy tuần tự — chúng tách
  nhau vì kích thước (12 file gộp lại), **không** vì file trùng.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Payload widget Dart → native | Mobile Developer | P4 | P4 (Android), P5 (iOS) | `../architecture/contract-summary.md` §2, §3 |
| Lược đồ ba gói nội dung | Mobile Developer | P1 | P2, P3, P4, P6 | `../architecture/contract-summary.md` §4 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| `CONTENT-GATE` | P1 |
| `COUNTER-STREAK` | P3 |
| `DRIP-CADENCE` | P3 |
| `WIDGET-LEAK` | P4 |
| `HARDCODED-COPY` | P4 (Android), mở rộng sang iOS ở P5 |
| `IOS-WIDGET-TARGET` | P5 |
| `WIDGET-STALE` | P4 + P7 |
| `REMIND-REPEAT` | P6 |
| `VISUAL-FIDELITY` | P7, P8, P12 (ô 7 — ảnh widget thật) |
| `HARDCODED-COPY` (glyph là tài nguyên native, không phải nội dung) | P11 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app.buildCommand` / `testCommand`

## 5. Phases Overview

Ba phase còn lại (2026-09-25) chạy **tuần tự trong cùng lane Mobile**, theo
đúng thứ tự P10 → P11 → P12, vì lane chỉ có một code-writer
(`MAX_CODE_WRITERS_PER_STORY: 1`) và P12 phải chụp sau khi P11 đã đổi hình chỉ
báo pha:

- P10: cờ `journalAvailable` cho nhánh suy biến AC-18
  (`../architecture/contract-summary.md` §7 — bản P10 cũ gate bằng
  `openJournal` đã bị thay thế).
- P11: chỉ báo pha `date_day` đổi từ chấm sang glyph tia chớp (D-13, §3a).
- P12: build native + chụp `implemented-widget-*.png` thật để đóng ô 7 của
  bảng đối chiếu hình ảnh (R-5).

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | YES | DONE |
| P3 | Mobile Developer | Mobile | P1 | YES | DONE |
| P4 | Mobile Developer | Mobile | P2, P3 | YES | DONE |
| P5 | Mobile Developer | Mobile | P4 | NO | DONE |
| P6 | Mobile Developer | Mobile | P1, P2 | YES | DONE |
| P7 | Mobile Developer | Mobile | P2 | NO | DONE |
| P8 | Mobile Developer | Mobile | P3, P7 | NO | DONE |
| P9 | Mobile Developer | Mobile | P4, P5 | YES | DONE |
| P10 | Mobile Developer | Mobile | P6, P8 | NO | PENDING |
| P11 | Mobile Developer | Mobile | P4, P5, P9 | NO | PENDING |
| P12 | Mobile Developer | Mobile | P11 | NO | PENDING |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-content-packages-and-gate.md` |
| P2 | `phase-P2-phase-resolver.md` |
| P3 | `phase-P3-counter-milestone-drip.md` |
| P4 | `phase-P4-widget-bridge-android.md` |
| P5 | `phase-P5-widget-ios-extension.md` |
| P6 | `phase-P6-evening-check-in.md` |
| P7 | `phase-P7-phase-line-and-countdown.md` |
| P8 | `phase-P8-counter-and-quiet-surfaces.md` |
| P9 | `phase-P9-widget-phase-label-and-dot.md` |
| P10 | `phase-P10-checkin-degrade-parity.md` |
| P11 | `phase-P11-widget-date-day-bolt-glyph.md` |
| P12 | `phase-P12-widget-native-capture.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`; không có file trùng id.
- Mọi phase nằm trong một vòng đời chuyên gia (khoảng sáu file source/test) hoặc
  đã được tách; lý do tách ghi ở `## 1B Phase Sizing` của từng phase.
- Không có phase kiểm thử đuôi; mỗi phase mang `## 6. Test Scope` riêng.
- Không phase nào chỉ tồn tại để cô lập hợp đồng.
- Test scope các phase không chứa e2e backend, Playwright/browser e2e, mobile
  e2e, vòng đời emulator/simulator, ký bản dựng, upload store, hay startup smoke.

## 6. Notes

- **Điểm vào (rule 13a) nằm ở P4 + P5**: widget xuất hiện trong bộ chọn widget
  của hệ điều hành nhờ `res/xml/*_info.xml` + receiver trong AndroidManifest
  (P4) và `Info.plist` của extension (P5). Đó là bề mặt khám phá được mà người
  dùng tự thêm — không có route in-app nào cần gắn. Các bề mặt còn lại tự mount
  vào `ActivityCardHubView` ở P7/P8.
- `flutter analyze` ở repo này **không bao giờ** exit 0 (có warning tồn dư từ
  trước, 0 error). Phase nào dùng static analysis phải so theo *errors*, không
  theo exit code, và chạy `flutter gen-l10n` trước trong worktree mới.
- Bảng Phase Overview theo đúng 6 cột của `assets/master_plan_template.md`, vốn
  cấm thêm cột `Write Scope`/`Primary Inputs`/`Planned Outputs`/`Test Scope`.
  Chỗ này lệch với SKILL rule 14 (liệt kê 10 cột); template thắng vì nó là thứ
  phase file tham chiếu.
- **P9/P10 (2026-09-25, coding-plan round 2) — lệch đã sửa so với handoff:**
  handoff nói "9-column Phase Overview schema"; giữ nguyên 6 cột như trên,
  đúng precedent đã ghi sẵn ở dòng trên — không có phiên bản 9 cột nào của
  template hay SKILL tồn tại để đối chiếu.
- **P9/P10 — khoảng trống thật đã xác minh trực tiếp trên mã, khác mô tả
  trong checkpoint/handoff:** checkpoint trước round này mô tả một "D-3
  data-contract gap: ActivityCard chỉ có `scheduledOn` không giờ, cần cho
  khối ngữ cảnh check-in" làm lý do mở WriteScope sang
  `activity_card_tile.dart`/`activity_card_hub_view.dart`. Không tìm được
  ruling D-3 nào khớp mô tả đó ở `requirements.md`/`ux/uiux-spec.md`/
  `req_master.md`. D-3 thật (đọc từ `coding-plan/test-results.md` lượt vá
  2026-09-19 và `review/review-report.md` mục "Cổng quyết định
  PATCH_REQUIRED") là **ngày ISO thô hiện ra thay vì định dạng vi** trên thẻ
  — đã DONE, test PASS, không liên quan giờ hẹn hay `ActivityCard`. Khoảng
  trống D-6/C-1 thật duy nhất còn lại, xác minh bằng cách đọc trực tiếp
  `evening_check_in_sheet.dart` (dòng 121-280): khối "viết một câu" + hai chip
  render vô điều kiện, chưa có nhánh ẩn khi thiếu STORY-003 mà AC-18 (vá hôm
  nay, commit `84bdd6b2`) đòi. P10 đóng đúng khoảng trống này; WriteScope là
  `evening_check_in_sheet.dart` + test của nó, không phải
  `activity_card_tile.dart`/`activity_card_hub_view.dart`/`l10n/arb/` như
  handoff giả định — hai file thẻ đó không sở hữu màn check-in.
