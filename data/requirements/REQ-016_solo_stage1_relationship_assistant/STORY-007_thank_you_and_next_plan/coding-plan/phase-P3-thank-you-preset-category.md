# Phase P3 – Phần 1: danh mục preset "lời cảm ơn sau hẹn"

## 1. Objective

Thêm danh mục preset `thank_you_after_date` vào **gói dữ liệu** của STORY-002
và nối chip "Soạn lời cảm ơn" trong khối sang **đúng bottom sheet renderer đã
có**, chỉ khác tham số danh mục. Engine render không được sửa một dòng nào.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-thank-you-preset-category.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO — ghi vào widget khối của P2, chạy trước P4/P5
- Write Scope:
  - gói dữ liệu preset của STORY-002: **chỉ thêm** danh mục mới
  - `mobile/lib/features/activity_cards/thank_you/presentation/`
    (section phần 1 cắm vào khe của P2)
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
  - danh mục preset `thank_you_after_date` (dữ liệu)
- Shared Interfaces Consumed:
  - engine render + bottom sheet + cổng nhập nội dung của STORY-002
- Risk Surfaces:
  - Engine STORY-002 không bị sửa
  - Cổng nhập nội dung dùng chung
  - Hết-vòng đúng với mọi N
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` mục 2, 3
  - consumer contract: payload lưu theo STORY-002 AC-17
- Primary Inputs Summary:
  - requirements: AC-8..AC-13, AC-27, AC-33, AC-34, AC-36, BR-5..BR-7,
    BR-14..BR-18
  - architecture: `../architecture/contract-summary.md`, `solution.md` mục 4
  - upstream phase outputs: khe cắm phần 1 của P2
  - UX constraints: `../ux/uiux-spec.md` mục 3 (phần 1), mục 4
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — nội dung-là-dữ-liệu cho danh mục lời cảm ơn
  - Source/Test File Count: ~5 (file dữ liệu preset, đăng ký danh mục, section
    phần 1, test cổng nhập, test render/xoay vòng)
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm B, Nhóm G)
- `../architecture/contract-summary.md`
- `../ux/uiux-spec.md` mục 3, 4

## 3. Tasks

- Thêm danh mục bằng **một file asset mới**, không sửa code tra cứu:
  `presetAssetKey()` trong
  `mobile/lib/features/invite_composer/domain/preset_catalogue.dart` ánh xạ id
  danh mục sang `assets/data/req016/presets.<categoryId>.v1.json` bằng quy ước
  chuỗi, nên file cần tạo là
  `mobile/assets/data/req016/presets.thank_you_after_date.v1.json` (đăng ký
  asset trong `pubspec.yaml` nếu thư mục chưa được khai báo theo thư mục).
- Dùng **nguyên** `presetsSchemaId = 'req016.presets.v1'`. Comment tại
  `preset_catalogue.dart:5` gọi đích danh story này: **cấm** đúc schema id
  riêng kiểu `req016.presets.thanks.v1`, vì nó tách cổng nội dung thành nhánh
  thứ hai và phá AC-29.
- Khai hằng `thankYouAfterDateCategoryId` trong file của STORY-007, **không**
  thêm vào `preset_catalogue.dart` — để diff của phase không chạm file
  STORY-002 nào ngoài asset.
- **CHẶN, cần quyết định:** cổng nội dung
  (`domain/preset_content_gate.dart`) bắt buộc **đúng một** clause
  `decline_door` cho **mọi** preset, không phân nhánh theo danh mục
  (`PresetGateRule.declineDoorMissing`). Một lời cảm ơn không có "cửa từ chối"
  tự nhiên, nên gói mới sẽ chết ở cổng. AC-21/AC-29 nói thêm danh mục là thêm
  dữ liệu, nhưng luật này gắn cứng ngữ nghĩa lời mời vào mọi danh mục. Hai lối,
  **cấm** tự chọn: (A) đưa luật `decline_door` về phạm vi danh mục trong cổng —
  sửa file STORY-002, mâu thuẫn "thêm danh mục là thêm file"; (B) PO chốt rằng
  preset cảm ơn vẫn mang một clause tương đương cửa từ chối. Chưa chốt thì dừng
  với `CONTENT_GATE_CATEGORY_COUPLING`.
- Mỗi mục có id bền `thank_you_after_date.<slug>`.
- Soạn bộ preset bản đầu với nội dung placeholder nội bộ đạt luật bất biến. Số
  lượng là **dữ liệu**; không viết bất kỳ logic nào dựa trên một N cụ thể.
- Nội dung phải đạt: đùa chỉ nhắm người gửi (AC-27); câu nói về người kia kết
  bằng câu hỏi (BR-14); không %, không streak, không tâng bốc, không đo hành vi
  người kia (BR-18). Preset nào có lời rủ nhúng bên trong thì **tính là lời
  mời** và phải mang cửa từ chối một chạm (BR-6).
- Dựng section phần 1: một chip/text-button "Soạn lời cảm ơn" ở tầng hành động
  phụ, bấm → mở **sheet có sẵn** của STORY-002
  (`presentation/widgets/invite_composer_sheet.dart`, tham số vị trí thứ hai là
  `categoryId`) với giá trị `thank_you_after_date`. **Không vẽ UI mới** cho
  bước này, và **không** thêm bộ chọn danh mục — `categoryId` là tham số ẩn do
  caller cấp, sheet không có picker.
- Lặp lại thế phòng vệ của `prepare_actions_sheet.dart`: kiểm tra danh mục
  giải được ra gói có ít nhất một preset **trước khi** hiện lối vào, để một gói
  thiếu/hỏng không mở ra sheet rỗng.
- Sau khi đóng sheet, quay lại khối này; phần 1 **vẫn hiện**, không tự ẩn.
- Lưu kết quả bằng `InvitePayload` có sẵn (`domain/invite_payload.dart`:
  `cardId`, `categoryId`, `presetId`, `packVersion`, `filledValues`,
  `userEditedText`) — đây chính là payload SB-125 của AC-17; **không** tạo kiểu
  payload song song cho lời cảm ơn.

## 4. Acceptance Criteria

- Diff của phase **không chạm** file engine render (AC-9, BR-5).
- Không có nhánh `if category == 'thank_you_after_date'` ở bất kỳ đâu trong
  engine hay cổng nhập (AC-36).
- Cùng thẻ + cùng khung nhại → hai lần sinh ra kết quả **giống hệt** (AC-10).
- Thẻ thiếu trường mad-libs → câu vẫn trôi, không ô trống, không placeholder lộ
  ra (AC-11).
- Hành vi hết-vòng giống hệt danh mục `lời mời`: quay lại từ đầu, không thông
  báo "đã hết", không chỉ báo tiến độ (AC-34).
- Bản lưu là payload có cấu trúc, không phải chuỗi text đã bẹp (AC-13).

## 5. Planned Outputs

- Code directories: gói dữ liệu preset (thêm danh mục), section phần 1
- Contracts or schemas: danh mục `thank_you_after_date` theo
  `../architecture/contract-summary.md` mục 2, 3
- Notes or evidence: danh sách id preset đã ship ghi vào
  `coding-plan/test-results.md` (khoá truy vết duyệt)

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, khối trong chi tiết thẻ + bottom sheet
- Required levels:
  - unit: nạp danh mục theo id; tất định; xoay vòng
  - integration: widget test — bấm chip mở đúng sheet với đúng tham số danh mục
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: có
- Required checks:
  - **Cổng nhập:** nạp một fixture vi phạm (ví dụ mục chứa `%` hoặc câu đo hành
    vi người kia) và khẳng định cổng **từ chối và làm hỏng bản dựng**. Không có
    test này thì AC-36 chỉ là lời hứa.
  - Xoay vòng với N=1 và với N của bộ seed: cả hai quay vòng, không thông báo
    "đã hết", không chỉ báo tiến độ.
  - Tất định: gọi hai lần cùng đầu vào → cùng chuỗi ra.
  - Thẻ thiếu trường: không lộ placeholder.
- Minimum gates by risk surface: mỗi risk surface ở `## 1B` có assertion trực
  tiếp; riêng "Engine không bị sửa" kiểm bằng danh sách file trong diff.
- Required regression or contract coverage: test hiện có của danh mục `lời mời`
  (STORY-002) phải xanh, hành vi không đổi (AC-9).
- Evidence format: lệnh + kết quả test thật
- Per-story visual fidelity: REQUIRED
  - Design screen id: giải quyết sau khi render, theo
    `contracts/design-fidelity-spec.md`; canvas REQ-016 dùng id slug, **không**
    truyền `--label`.
  - How the implemented screen is captured: `capture-mobile-screen.sh` trên
    khối đã có section phần 1.
  - NOTE: gate riêng của story này; không hoãn sang audit cấp requirement.
    Không chạm được runtime → chặn với `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: test sub-feature + test danh mục `lời mời` hiện có.
  - Build/type-check: `flutter analyze lib test`; gate là không thêm error mới.
  - Required assertion evidence: trích dòng kết quả thật.
  - **Bẫy đã biết:** ảnh chụp xanh vẫn có thể chứa ký tự tofu. Đối chiếu
    codepoint của `Text` tiếng Việt với cmap của font chữ đang bundle thay vì
    chỉ tin vào việc test chạy xong.

## 7. Status

- Status: DONE
- Last updated: 2026-09-24
- Evidence: `coding-plan/test-results.md` mục "P3 — Danh mục preset "cảm ơn sau
  buổi hẹn""
- Blocker `CONTENT_GATE_CATEGORY_COUPLING`: RESOLVED theo lối A
  (`req_master.md` `## Design Ruling Log`, 2026-09-23). Cổng nhập nay nhận
  `categoryId` từ người gọi; danh mục lời mời giữ nguyên độ chặt, cả hai chiều
  đều có test.
