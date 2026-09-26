# Master Coding Plan – Cảm ơn + chốt việc kế tiếp (STORY-007)

## 1. Planning Metadata

- Story ID: STORY-007_thank_you_and_next_plan
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — không thêm env var,
  secret, hay tích hợp bên thứ ba nào cần cấu hình (`share_plus` và
  `image_picker` đã có sẵn trong `mobile/pubspec.yaml`).

> Deviation: base của worktree thiếu toàn bộ code STORY-001/002/003/005 (xem
> `../architecture/solution.md` mục 1 Key Discovery (a)). Tên module/file vật lý
> trong các phase là **mức module**, phải bind ở bước đầu P1.

## 2. Planning Goal

- Shared contract owner: STORY-007 (mobile) cho bảng lượt-kích-hoạt; STORY-002
  giữ quyền sở hữu lược đồ preset và cổng nhập.
- Contract-first phase required: NO — cùng một specialist (Mobile Developer)
  viết hợp đồng và toàn bộ consumer của nó trong cùng một lane, tuần tự.
- Parallel execution possible: NO — một lane duy nhất; P3/P4/P5 đều ghi vào
  widget khối nên phải tuần tự.
- Critical path: P1 → P2 → P3 → P4 → P5.
- Parallelism notes: P3, P4, P5 độc lập về **hành vi** nhưng cùng ghi file khối;
  chúng được tách vì mỗi phase đã đầy một vòng đời specialist, không phải vì
  đụng file. Nếu cần rút ngắn, gộp **không** hợp lệ: mọi cặp đều vượt ~6 file.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Danh mục preset `thank_you_after_date` | STORY-002 (lược đồ) / P3 (dữ liệu) | P3 | P3 | `../architecture/contract-summary.md` mục 2, 3 |
| Lời gọi tạo thẻ + nguồn sinh | STORY-001/STORY-005 | — (đã ship) | P5 | `../architecture/contract-summary.md` mục 4 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Lượt kích hoạt một lần trọn đời | P1 |
| Biên ngày lịch địa phương | P1 |
| Bump `schemaVersion` của drift | P1 |
| Không phạt im lặng | P1, P2 |
| Engine STORY-002 không bị sửa | P3 |
| Cổng nhập nội dung dùng chung | P3 |
| Hết-vòng đúng với mọi N | P3 |
| Riêng tư nhật ký khi đính ảnh | P4 |
| Khoá nối nhật ký ↔ thẻ | P4 |
| Đúng một đường tạo thẻ | P5 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` cho phase
    implementation, command/source runtime registry `mobile-app`
    (`buildCommand: flutter build apk --debug`, `testCommand: flutter test`).

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | DONE |
| P3 | Mobile Developer | Mobile | P2 | NO | DONE |
| P4 | Mobile Developer | Mobile | P2 | NO | DONE |
| P5 | Mobile Developer | Mobile | P2 | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-activation-ledger.md` |
| P2 | `phase-P2-block-shell-and-entry-point.md` |
| P3 | `phase-P3-thank-you-preset-category.md` |
| P4 | `phase-P4-photo-attach.md` |
| P5 | `phase-P5-next-plan-suggestions.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`; không có file trùng.
- Phase implementation mobile vừa một vòng đời specialist (khoảng sáu file
  source/test) hoặc phải tách.
- Không phase nào bị tách chỉ vì trùng file ghi; không phase nào lặp lại mẫu
  của phase anh em cho một biến thể của cùng cụm hành vi.
- Không có phase contract đứng riêng; không có phase verification/testing đuôi.
- Test scope của phase implementation không chứa e2e, Playwright/browser,
  trace, scenario rerun, hay runtime startup smoke.

## 6. Notes

- Rebase đã xong: base là `bfe231aa` và đã có code STORY-001/002/003/005. Tên
  module vật lý đã kiểm chứng, không còn chỗ nào phải bind khi chạy.
- `schemaVersion` trên base là **9**; P1 bump lên **10**. Nếu lúc bắt đầu P1 số
  đã khác 9 thì một nhánh song song đã bump trước — dừng, đừng bump chồng.
- **P4 — `JOURNAL_SOURCE_CONTRACT_CLOSED` đã đóng, P4 dispatch được.** Ngày
  2026-09-23 người dùng chốt lối (A) (`req_master.md` mục `## Design Ruling
  Log`): `journal_entry_point.dart` được thêm **đúng một** hàm chiếu chỉ-đọc trả
  về đường dẫn ảnh theo `originRef`, không văn bản, không mốc thời gian. Chi
  tiết thi hành ở `phase-P4-photo-attach.md` §3 Bước 1.
- **Phụ thuộc còn lại của P4, không phải blocker.** Ống dẫn ghi `originRef` đã
  hoàn chỉnh sẵn từ `JournalComposerSeed.originRef` xuống tận cột
  `JournalEntries.origin_ref`; thứ duy nhất thiếu là một caller truyền
  `JournalComposerSeed(originRef: <id thẻ>)`. Trên base này **không có** luồng
  tạo mục nhật ký từ thẻ ở bất kỳ đâu (không file nào dưới
  `features/activity_cards/**` nhắc tới nhật ký), và `ux/uiux-spec.md` mục 3
  cấm khối của STORY-007 tự mở lối ghi nhật ký — nên lệnh ghi đó **không thuộc
  phạm vi STORY-007**. Nhánh nhật ký của AC-14 sẽ rỗng trên app thật cho tới khi
  story sở hữu màn tạo-mục-từ-thẻ (`journal_entry_point.dart` dòng 4-5 ghi
  STORY-008, hiện `TODO`) truyền `originRef`; nhánh ảnh thẻ có dữ liệu ngay nên
  AC-14/AC-15 vẫn chạy. Trong P4, nhánh nhật ký được kiểm bằng hàng gieo sẵn
  qua `JournalRepository.saveEntry(... originRef:)`.
- **P3 — `CONTENT_GATE_CATEGORY_COUPLING` (lịch sử).** Cổng nội dung bắt mọi
  preset phải có clause `decline_door`. P3 đã `DONE`, nên quyết định này đã được
  xử lý trong lúc thi hành P3; giữ lại ở đây làm dấu vết, không phải việc đang
  chờ.
