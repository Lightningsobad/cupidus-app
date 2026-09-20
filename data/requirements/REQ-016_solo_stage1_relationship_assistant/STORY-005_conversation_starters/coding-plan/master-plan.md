# Master Coding Plan – STORY-005 Mồi chuyện

## 1. Planning Metadata

- Story ID: STORY-005_conversation_starters
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — không env var, không
  secret, không tích hợp bên thứ ba mới; toàn bộ nằm trong một bản dựng app.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (`mobile/`), một lane duy nhất.
- Contract-first phase required: NO — mọi consumer của hợp đồng nằm cùng lane,
  cùng owner, chạy tuần tự. P1 **không** phải phase cô lập hợp đồng: nó là
  phase cài đặt thật (hai gói dữ liệu + validator + bộ test cổng nhập), và gộp
  nó vào P3 sẽ vượt xa một vòng đời specialist.
- Parallel execution possible: NO — một lane mobile, một specialist.
- Critical path: P1 → P3 → P4, rồi vòng rework P5 → P6 → P7.
- Parallelism notes: P1 và P2 không phụ thuộc nhau và chạm tập file rời nhau,
  nên dispatch được theo thứ tự nào cũng đúng. Cả hai phải xong trước P3.
  P5/P6/P7 là một chuỗi tuần tự bắt buộc (xem §7).

## 2A. Vòng Rework Neo-Thiết-Kế (2026-09-20)

P1–P4 đã ship và story đã `Status: DONE`; `VISUAL_FIDELITY: PASS` ghi trước
ngày này **không đổi**. P5–P7 là **mở rộng phạm vi sau phán quyết**, không phải
sửa lỗi của bản dựng.

- Nguồn phán quyết: Design Ruling Log trong `../../req_master.md`, hàng
  `2026-09-20 | STORY-005 | §7 mục 2,3,4,5,6b,7` — người dùng chọn
  **"Neo thiết kế"**, canvas `6-moi-chuyen-a-a` thắng lời văn `uiux-spec.md`
  §2 ở cả sáu mục. Sáu mục này **đã đóng**, không mở lại.
- Bằng chứng gốc: `../visual-fidelity/visual-fidelity-report.md` §7.
- Mục 1, 6a, 8 **không** thuộc vòng này: chúng có AC chống lưng bản dựng và đã
  xử cho bản dựng.
- Phân chia phase theo đúng cột "Hệ quả" của ruling: mục 2 một phase, mục 7 một
  phase, mục 3/4/5/6b một phase gộp.

### Prerequisite ngoài lane (Scrum Master, trước khi dispatch P6)

`../ux/uiux-spec.md` §2 phải được vá cho khớp canvas trước khi mobile-dev thi
hành: §2 mục 2 (ba dòng ngang hàng → hero/phụ; nhãn nút và text button; thêm
dòng trấn an) và §2 mục 5 (nhãn khối sự kiện; **bỏ** gạch đầu dòng
`Leading: badge ngày (dd/mm, caption 13pt)`). Tech Lead **không** vá file này ở
vòng này — ngoài WriteScope. P6 mang sẵn blocker `UX_SPEC_PATCH_MISSING` nếu
bản vá chưa có.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| `req016.starters.v1` schema + luật R-1g ở cổng nhập | Mobile Developer | P1 | P3, P4 | `../architecture/contract-summary.md` section 3 |
| `req016.calendar_events.v1` schema + `calendar_event_state` | Mobile Developer | P1, P2 | P3, P4 | `../architecture/contract-summary.md` section 4 |
| `ActivityCardOrigin.conversationStarter` | Mobile Developer | P3 | STORY-007 | `../architecture/contract-summary.md` section 2 |
| `req016.calendar_events.v1` mở rộng `reason_template` + `reason_context_slot` | Mobile Developer | P7 | P7 | `phase-P7-event-reason-field.md` section 4 |
| `CupidIcons.refresh` | Mobile Developer | P6 | P6 | `phase-P6-labels-affordances-and-date-inline.md` section 3 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Cổng nhập nội dung R-15c (AC-29) | P1, P7 |
| Hành vi hết-vòng với mọi N (AC-27/AC-28) | P1, P3, P5 |
| Tất định (AC-17) | P1, P3, P7 |
| Không mạng / không AI (AC-15/AC-16) | P1, P3, P4, P6, P7 |
| Ghi thẻ đúng hợp đồng STORY-001 (AC-11/AC-12) | P2, P3 |
| Migration Drift 6→7 | P2 |
| Visual fidelity màn (6) | P4, P5, P6, P7 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (không phase nào đổi
    đường khởi động app), command/source runtime registry
    `data/devops/system/runtime-command-registry.json` → `mobile-app`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | None | NO | DONE |
| P3 | Mobile Developer | Mobile | P1, P2 | NO | DONE |
| P4 | Mobile Developer | Mobile | P3 | NO | DONE |
| P5 | Mobile Developer | Mobile | None | NO | DONE |
| P6 | Mobile Developer | Mobile | P5 | NO | NOT_STARTED |
| P7 | Mobile Developer | Mobile | P6 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-content-packs-and-gate.md` |
| P2 | `phase-P2-calendar-event-state-drift.md` |
| P3 | `phase-P3-selection-and-card-handoff.md` |
| P4 | `phase-P4-screen-and-entry-point.md` |
| P5 | `phase-P5-hero-and-secondary-hierarchy.md` |
| P6 | `phase-P6-labels-affordances-and-date-inline.md` |
| P7 | `phase-P7-event-reason-field.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Mobile implementation phases fit roughly six source/test files or are split.
  P2 and P7 are the two phases that touch more files than that, and
  deliberately: P2 is 4 substantive files plus 8 one-line `schemaVersion`
  constant edits in existing tests; P7 is 6 substantive files plus 3 test files
  that are the mechanical fallout of its own content-pack field. In both cases
  the extra files belong nowhere else.
- No trailing verification/testing phase; each phase owns its own targeted
  tests and build/type-check.

## 6. Notes

- **A-1 cần PO/Reviewer nhìn thấy, không chặn phase nào.**
  `../architecture/solution.md` §3 A-1 chốt rằng AC-18 ("ngày lịch âm tính tất
  định trên thiết bị") được thoả bằng ngày dân dụng chốt sẵn trong gói dữ liệu,
  theo đúng quy ước `occasions.v1.json` mà STORY-001 đã ship — không có phép
  quy đổi âm↔dương nào trong code, và P1 **không** được thêm dependency lịch
  âm. Nếu Reviewer đọc AC-18 theo nghĩa đen "phải có phép tính", đó là một
  Design Ruling ở tầng requirement, không phải lỗi cài đặt của P1.
- Thứ tự bắt buộc bên trong P2: `schemaVersion` lên `7` và migration cộng thêm
  phải vào **cùng một commit** với việc sửa 8 file test đang khẳng định `6`.
  Tách ra là để lại một cây đỏ giữa hai phase.

## 7. Ghi Chú Vòng Rework P5–P7

- **Thứ tự P5 → P6 → P7 là bắt buộc, không phải sở thích.** Cả ba phase cùng
  sửa `conversation_starters_screen.dart`, và hai chỗ chồng lấn thật:
  mục 3 (nút `Chép để nhắn` + nút tròn) chỉ gắn được vào thẻ hero mà P5 dựng;
  dòng lý do của mục 7 nằm ngay dưới dòng tên sự kiện mà mục 6b vừa viết lại.
  Đảo thứ tự nghĩa là một phase viết lại đúng widget phase trước vừa viết.
  Thứ tự này khác thứ tự liệt kê trong cột "Hệ quả" của ruling (mục 2, mục 7,
  rồi nhóm 3/4/5/6b) — nội dung ba phase vẫn đúng như ruling chia, chỉ lịch
  dispatch đổi.
- **Đính chính phạm vi mục 7 (đọc trước khi dispatch P7).** Bản giao việc vòng
  này mô tả mục 7 là "cột Drift mới + migration + nâng `schemaVersion`, cỡ như
  B-1". Nguyên văn ruling chỉ viết "thêm trường lý do vào **schema gói sự
  kiện** — cỡ như B-1", và rà mã trên nhánh này cho thấy sự kiện lịch sống
  trong gói asset `calendar_events.v1.json`, không trong Drift; bảng Drift duy
  nhất của story (`calendar_event_state`, P2) chỉ lưu `converted`/`dismissed`.
  `cỡ như B-1` là so sánh **kích cỡ và quyền sở hữu** (Tech Lead bóc phase,
  mobile-dev thi hành), không phải chỉ định hình thức kỹ thuật. P7 vì vậy
  **cấm** cột Drift, bảng mới, migration và nâng `schemaVersion` — chi tiết và
  đường thoát blocker ở `phase-P7-event-reason-field.md` §1C.
- **Đính chính "test nhãn ở P1/P4".** Cột "Hệ quả" nói việc đổi nhãn kéo theo
  cập nhật test ở P1/P4. Đã rà: mọi khẳng định nhãn của màn (6) nằm trong
  `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
  (test của P4). Test của P1 là cổng nhập nội dung, không chứa nhãn chrome nào,
  và `app_vi.arb` cũng không (chuỗi `Thêm vào kho của tôi` ở đó thuộc feature
  `compat`). P6 chỉ sửa file test của P4.
- **Hai chỗ canvas KHÔNG được suy rộng thành phạm vi.** Cả hai đều ngoài sáu
  mục đã phán quyết, nên giữ nguyên bản dựng và ghi lại ở đây để vòng sau không
  mở lại như "khoảng hụt fidelity":
  - Canvas không vẽ nút copy trên hai thẻ câu phụ. `ux/uiux-spec.md` §2 mục 2
    đang yêu cầu mỗi câu có nút copy ≥44pt và §7 chưa từng nêu chỗ này — P5 giữ
    nút copy trên câu phụ.
  - Canvas viết ngày sự kiện theo lối tương đối (`— thứ Bảy này`). Ruling chỉ
    đóng "bỏ badge, gộp ngày vào tên"; một nhánh tương đối theo `today` là hành
    vi mới chưa ai phán quyết — P6 dùng `thứ Bảy 16/08`.
- Cả ba phase đều chạm màn (6) nên đều bật `Per-story visual fidelity:
  REQUIRED`. Ảnh chụp cuối cùng dùng để đối chiếu canvas là ảnh của P7 — hai
  ảnh trước là bằng chứng của chính phase đó, không phải bản chốt của story.
