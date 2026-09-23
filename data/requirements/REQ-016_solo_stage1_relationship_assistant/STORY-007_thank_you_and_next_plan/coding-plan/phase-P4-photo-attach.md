# Phase P4 – Phần 2: đính ảnh, chỉ-đọc và giữ riêng tư nhật ký

## 1. Objective

Cho phép người dùng chọn ảnh **đã có sẵn** của buổi hẹn để đính vào vật phẩm
chia sẻ, với ràng buộc cứng: **chỉ ảnh đi ra, chữ và siêu dữ liệu ở lại**. Phần
này biến mất hoàn toàn khi chưa có ảnh nào.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-photo-attach.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO — ghi vào widget khối của P2, chạy sau P3
- Write Scope:
  - `mobile/lib/features/activity_cards/thank_you/data/` (query
    projection chỉ-đọc)
  - `mobile/lib/features/activity_cards/thank_you/presentation/`
    (section phần 2 cắm vào khe của P2)
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
  - kiểu projection ảnh chỉ mang tham chiếu file (không trường văn bản)
- Shared Interfaces Consumed:
  - bảng nhật ký + ảnh của STORY-003 (chỉ đọc)
  - trường ảnh/ký ức trên thẻ của STORY-001 AC-8 (chỉ đọc)
  - `share_plus` — `SharePlus.instance.share(ShareParams(text:, files:))`
- Risk Surfaces:
  - Riêng tư nhật ký khi đính ảnh
  - Khoá nối nhật ký ↔ thẻ
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` mục 1 Key Discovery
    (b)(c), mục 4
  - consumer contract: vật phẩm chia sẻ của phần 1 (P3)
- Primary Inputs Summary:
  - requirements: AC-12, AC-14..AC-18, AC-30, BR-8, BR-9
  - architecture: `../architecture/solution.md`
  - upstream phase outputs: khe cắm phần 2 của P2, vật phẩm chia sẻ của P3
  - UX constraints: `../ux/uiux-spec.md` mục 3 (phần 2)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — nguồn ảnh chỉ-đọc + chọn + đính vào vật phẩm
  - Source/Test File Count: ~5 (projection/query, kiểu ảnh, section widget,
    test riêng tư, test trạng thái rỗng)
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm C)
- `../architecture/solution.md` mục 1 Key Discovery (b) và (c)
- `../ux/uiux-spec.md` mục 3 (phần 2)

## 3. Tasks

- **Bước 1 — CHẶN, cần quyết định trước khi viết code.** Lược đồ đã ship được
  kiểm chứng: `JournalEntries` (`mobile/lib/core/database/tables/journal_entries.dart`)
  **không có** khoá ngoại tới thẻ, và `journal_entry_point.dart` — toàn bộ bề
  mặt tiếp xúc của nhật ký với phần còn lại của app — là hợp đồng **một chiều**
  có chủ đích: "a caller can hand content in and can never read anything back
  out (AC-7)", không có hàm liệt kê/đếm/xem trước, và không file nào ngoài
  `features/journal/**` được import nội bộ nhật ký. Nguồn ảnh nhật ký của AC-14
  vì vậy **không truy cập được** bằng code hiện có. Hai lối thoát, cần Scrum
  Master/PO chốt, **cấm** tự chọn:
  - (A) mở rộng `journal_entry_point.dart` thêm đúng một hàm chiếu chỉ-đọc trả
    về **danh sách đường dẫn ảnh** theo `originRef` — không văn bản, không mốc
    thời gian; giữ nguyên tinh thần AC-7 vì chỉ ảnh rời khỏi nhật ký. Kèm điều
    kiện bên ghi: hiện **không caller nào** điền `originRef`, nên còn phải có
    story ghi `originRef = id thẻ` lúc tạo mục nhật ký từ thẻ, nếu không truy
    vấn luôn rỗng.
  - (B) thu hẹp AC-14 còn nguồn ảnh của thẻ (`ActivityCardPhotos`), bỏ nguồn
    nhật ký khỏi phạm vi STORY-007.
  Trước khi có quyết định, dừng với `JOURNAL_SOURCE_CONTRACT_CLOSED`. **Cấm**
  thêm cột/migration lên bảng của STORY-003, cấm import nội bộ nhật ký vòng qua
  entry point, và cấm suy ra liên kết bằng cách so ngày.
- Định nghĩa kiểu projection ảnh chỉ mang **tham chiếu file ảnh**. Kiểu này
  **không được có** trường văn bản, thời gian ghi, hay nhãn mục nhật ký — đây
  là cách AC-17 được cưỡng chế bằng trình biên dịch thay vì bằng kỷ luật ở
  widget.
- Nguồn ảnh của thẻ là bảng `ActivityCardPhotos`
  (`mobile/lib/core/database/tables/activity_cards_table.dart`, cột `cardId`
  tham chiếu `ActivityCards`), không phải một trường ảnh trên chính bản ghi
  thẻ. Query chỉ đọc; nguồn nhật ký chỉ được hợp nhất vào nếu lối (A) được
  chọn.
- Dựng section phần 2: hàng thumbnail cuộn ngang, **chỉ ảnh** — không chữ,
  không ngày giờ, không nhãn đè lên. Mặc định **chưa chọn**; bấm để chọn/bỏ
  chọn, hiện tick nhỏ góc trên-phải khi đã chọn.
- Không có lối "thêm ảnh mới" ở đây: phần này không mở camera/thư viện.
- Khi không có ảnh nào: section **không tồn tại** trong cây widget — không hàng
  xám, không placeholder, không CTA thúc chụp ảnh.
- Nối ảnh đã chọn vào vật phẩm chia sẻ: truyền tham chiếu file **gốc**. Không
  tạo bản sao ảnh nằm trong dữ liệu của app — quyền xoá của STORY-003 phải vẫn
  xoá được sạch (AC-18).

## 4. Acceptance Criteria

- Kiểu projection không phơi bất kỳ trường văn bản/siêu dữ liệu nào (AC-17).
- Không ảnh nào được chọn sẵn khi khối vừa hiện (AC-16).
- Không có ảnh → section vắng mặt hoàn toàn, hai phần còn lại dùng bình thường
  (AC-15, BR-9).
- Xoá mục nhật ký sau đó vẫn xoá toàn bộ ảnh của nó; không còn bản sao mồ côi
  (AC-18).
- App không đổi trạng thái riêng tư của mục nhật ký và không đánh dấu "đã chia
  sẻ" (AC-18).
- Tích hợp ngoài duy nhất là OS Share Sheet (AC-12, AC-30).

## 5. Planned Outputs

- Code directories: `.../thank_you/data/` (projection), `.../presentation/`
  (section phần 2)
- Notes or evidence: kết luận bước 1 (khoá nối có/không) ghi vào
  `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, section phần 2 trong khối
- Required levels:
  - unit: query projection hợp nhất hai nguồn; trạng thái rỗng
  - integration: widget test chọn/bỏ chọn thumbnail
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: có
- Required checks:
  - Khẳng định kiểu projection **không có** trường văn bản/thời gian (kiểm ở
    mức kiểu dữ liệu, không phải ở mức widget).
  - Có ảnh ở nhật ký và ở trường thẻ → cả hai nguồn cùng xuất hiện, không trùng.
  - Không ảnh → không widget section nào tồn tại trong cây (`findsNothing`),
    không hàng xám.
  - Mặc định chưa chọn; chỉ sau thao tác người dùng mới có ảnh trong vật phẩm.
  - Xoá mục nhật ký → không còn file ảnh nào của mục đó do app quản lý.
- Minimum gates by risk surface: mỗi risk surface ở `## 1B` có assertion trực
  tiếp; `JOURNAL_SOURCE_CONTRACT_CLOSED` phải được chốt (A) hay (B) trước khi viết
  query.
- Evidence format: lệnh + kết quả test thật
- Per-story visual fidelity: REQUIRED
  - Design screen id: giải quyết sau khi render theo
    `contracts/design-fidelity-spec.md`; canvas REQ-016 dùng id slug, **không**
    truyền `--label`.
  - How the implemented screen is captured: `capture-mobile-screen.sh`, chụp
    **hai** trạng thái — có ảnh và không có ảnh.
  - NOTE: gate riêng của story này; không hoãn sang audit cấp requirement.
    Không chạm được runtime → chặn với `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: test sub-feature + test hiện có của nhật ký STORY-003
    (khẳng định hành vi xoá không đổi).
  - Build/type-check: `flutter analyze lib test`; gate là không thêm error mới.
  - Required assertion evidence: trích dòng kết quả thật.
  - **Bẫy đã biết:** một lời gọi MethodChannel được `await` trên đường đi mà
    `testWidgets` chạm tới sẽ **không bao giờ trả về**, và widget biến mất khỏi
    cây mà không ném lỗi nào. Mọi test chạm Share Sheet hoặc image picker phải
    mock channel handler trước.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-20
