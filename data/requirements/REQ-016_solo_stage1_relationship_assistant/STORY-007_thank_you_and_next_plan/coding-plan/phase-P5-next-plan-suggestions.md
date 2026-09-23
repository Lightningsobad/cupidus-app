# Phase P5 – Phần 3: chốt việc kế tiếp

## 1. Objective

Đưa ra 2-3 gợi ý nhẹ lấy tất định từ kho mồi STORY-005 hoặc dịp lịch âm gần
nhất; chọn một chip thì tạo ngay một thẻ mới ở *Mới nghĩ ra* **qua đúng đường
tạo thẻ đã có**, kèm snackbar hoàn tác 5 giây. Bỏ qua phải không tốn thao tác.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-next-plan-suggestions.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO — ghi vào widget khối của P2, chạy sau P4
- Write Scope:
  - `mobile/lib/features/activity_cards/thank_you/domain/` (service gợi ý)
  - `mobile/lib/features/activity_cards/thank_you/presentation/`
    (section phần 3 cắm vào khe của P2)
  - `mobile/test/features/activity_cards/thank_you/`
- Impacted Runtime Service/App:
  - Name: mobile
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - service gợi ý việc kế tiếp (tất định)
- Shared Interfaces Consumed:
  - kho mồi + hàm tính dịp lịch âm trên thiết bị của STORY-005 (AC-18)
  - `ActivityCardRepository.createCard(NewActivityCard draft)`
    (`features/activity_cards/domain/activity_card_repository.dart`) — đã kiểm
    chứng là đường tạo thẻ duy nhất; **cấm** ghi thẳng xuống DAO/bảng
- Risk Surfaces:
  - Đúng một đường tạo thẻ
  - Không phạt im lặng
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` mục 4
  - consumer contract: kho thẻ chung của màn (1)
- Primary Inputs Summary:
  - requirements: AC-19..AC-24, AC-28, AC-35, BR-10, BR-11, BR-14, BR-17
  - architecture: `../architecture/contract-summary.md` mục 4
  - upstream phase outputs: khe cắm phần 3 của P2
  - UX constraints: `../ux/uiux-spec.md` mục 3 (phần 3), mục 7
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — gợi ý tất định + tạo thẻ + hoàn tác
  - Source/Test File Count: ~6 (service gợi ý, section widget, snackbar/undo,
    test tất định, test tạo thẻ, test N nhỏ/N lớn)
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm D, AC-35)
- `../architecture/contract-summary.md` mục 4
- `../ux/uiux-spec.md` mục 3 (phần 3), mục 7

## 3. Tasks

- Viết service gợi ý: chọn tất định từ kho mồi STORY-005 và/hoặc dịp lịch âm
  gần nhất **tính trên thiết bị**. Không gọi AI, không gọi API ngoài.
- Dải 2-3 chip là **tham số bố cục**, không phải ràng buộc lên số mục kho mồi.
  Kho có ít hơn số chip cần → render đúng phần có sẵn, không ô giữ chỗ, không
  báo lỗi, không màn rỗng. Kho rất lớn → hành vi chọn không đổi, không có bước
  tải/đợi mới.
- Dựng section phần 3: các chip ngang hàng, **cùng kích thước**, không chip nào
  nổi bật hơn; tầng hành động phụ.
- Bấm một chip → **tạo thẻ ngay**, không hộp thoại xác nhận chặn (chính cú bấm
  là bước xác nhận của AC-20). Thẻ vào *Mới nghĩ ra*, mang nguồn sinh
  `next_plan_after_date`, và mang sẵn ngày của dịp nếu gợi ý gắn với ngày cụ
  thể (AC-21).
- Snackbar đáy màn "Đã thêm vào kho hoạt động — Hoàn tác", hiện 5 giây; hoàn
  tác xoá thẻ qua cùng contract, không để bản ghi mồ côi.
- Không chọn chip nào và đóng khối → không thẻ nào được tạo, không nhắc lại,
  không dấu chưa-hoàn-thành ở bất kỳ đâu.

## 4. Acceptance Criteria

- Thẻ mới đi qua **đúng** lời gọi tạo thẻ của STORY-005 AC-11; không có đường
  tạo thẻ thứ hai và không có "danh sách việc kế tiếp" thứ hai (AC-20, BR-11).
- Thẻ mới mang nguồn sinh đọc được, và nguồn sinh không bao giờ hiển thị như
  chỉ số đánh giá (AC-24).
- Đóng khối mà không chọn gì: không thẻ, không nhắc, không dấu chưa-hoàn-thành
  (AC-22, AC-25).
- Không bị chặn, không bị hỏi lại khi bỏ qua phần này (AC-23, BR-10).
- Gợi ý tất định: cùng đầu vào → cùng tập gợi ý (AC-19).
- Ngày dịp lịch âm lấy từ hàm trên thiết bị của STORY-005, không tính lại
  (AC-21, STORY-005 AC-18).

## 5. Planned Outputs

- Code directories: `.../thank_you/domain/` (service gợi ý),
  `.../presentation/` (section phần 3)
- Notes or evidence: kết quả test tất định + test biên N

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, section phần 3 trong khối + màn (1)
- Required levels:
  - unit: service gợi ý (tất định, biên N nhỏ và N lớn)
  - integration: widget test — bấm chip tạo thẻ; hoàn tác xoá thẻ
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: có
- Required checks:
  - Tất định: gọi hai lần cùng đầu vào → cùng tập gợi ý, cùng thứ tự.
  - N = 1 trong kho mồi → render 1 chip, không ô giữ chỗ, không lỗi (AC-35).
  - N rất lớn → không thêm bước tải/đợi, hành vi chọn không đổi (AC-35).
  - Bấm chip → thẻ xuất hiện ở *Mới nghĩ ra* với nguồn sinh đúng; gợi ý gắn dịp
    → thẻ mang sẵn ngày và sửa được.
  - Hoàn tác trong 5 giây → thẻ biến mất, không bản ghi mồ côi.
  - Đóng khối không chọn gì → số thẻ không đổi, không bản ghi mới nào.
- Mobile discoverability / navigation integration: thẻ mới phải xuất hiện ở
  **kho chung của màn (1)**; test khẳng định nó tìm thấy được ở đó, không phải
  ở một danh sách riêng của khối.
- Minimum gates by risk surface: mỗi risk surface ở `## 1B` có assertion trực
  tiếp.
- Required regression or contract coverage: test hiện có của đường tạo thẻ
  STORY-005 phải xanh, hành vi không đổi.
- Evidence format: lệnh + kết quả test thật
- Per-story visual fidelity: REQUIRED
  - Design screen id: giải quyết sau khi render theo
    `contracts/design-fidelity-spec.md`; canvas REQ-016 dùng id slug, **không**
    truyền `--label`.
  - How the implemented screen is captured: `capture-mobile-screen.sh` trên
    khối đã đủ ba phần.
  - NOTE: gate riêng của story này; không hoãn sang audit cấp requirement.
    Không chạm được runtime → chặn với `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: test sub-feature + test hiện có của đường tạo thẻ.
  - Build/type-check: `flutter analyze lib test`; gate là không thêm error mới.
  - Required assertion evidence: trích dòng kết quả thật.
  - **Bẫy đã biết:** kiểm `git status` trước khi báo hoàn tất — chạy bộ test
    mobile có thể ghi đè PNG visual-fidelity của story khác.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-20
