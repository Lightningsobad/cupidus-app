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
  - `mobile/lib/features/journal/journal_entry_point.dart` (thêm **đúng một**
    hàm chiếu chỉ-đọc theo lối (A))
  - `mobile/lib/features/journal/data/` (truy vấn nền cho hàm chiếu đó)
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
  - Source/Test File Count: ~6 (hàm chiếu ở entry point + truy vấn nền,
    projection/query hợp nhất, kiểu ảnh, section widget, test riêng tư, test
    trạng thái rỗng)
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm C)
- `../architecture/solution.md` mục 1 Key Discovery (b) và (c)
- `../ux/uiux-spec.md` mục 3 (phần 2)
- `mobile/lib/features/journal/journal_entry_point.dart` (toàn file, 91 dòng —
  hợp đồng phải giữ nguyên khi thêm hàm chiếu)

## 3. Tasks

- **Bước 1 — quyết định đã chốt: lối (A). Không mở lại.** `req_master.md`
  mục `## Design Ruling Log`, hàng 2026-09-23 `JOURNAL_SOURCE_CONTRACT_CLOSED`:
  mở rộng `journal_entry_point.dart` thêm **đúng một** hàm chiếu chỉ-đọc trả về
  danh sách đường dẫn ảnh theo `originRef` — không văn bản, không mốc thời gian
  — vì chỉ ảnh rời khỏi nhật ký nên tinh thần một chiều của AC-7 vẫn giữ.
  Việc phải làm:
  - Thêm **đúng một** hàm vào
    `mobile/lib/features/journal/journal_entry_point.dart` (hiện có đúng ba
    khai báo: `JournalComposerSeed` :31, `openJournalComposer` :57,
    `openJournalScreen` :80). Hàm nhận `originRef` và trả về tham chiếu file
    ảnh. **Cấm** thêm bất kỳ hàm liệt kê/đếm/tìm/xem trước nội dung mục nhật ký.
  - Truy vấn nền đặt cạnh `JournalRepository`
    (`mobile/lib/features/journal/data/journal_repository.dart`); widget của
    STORY-007 chỉ được thấy hàm entry point.
  - **Cấm** thêm cột/migration lên bảng của STORY-003, cấm import nội bộ nhật ký
    vòng qua entry point, cấm suy ra liên kết bằng cách so ngày.
- **Bước 1b — đường ghi `originRef`: toàn bộ ống dẫn đã có, thứ duy nhất thiếu
  là caller.** Đã kiểm chứng trên worktree này (base `1960fb8d`), chuỗi ghi
  hoàn chỉnh từ entry point xuống tận cột DB:
  `JournalComposerSeed.originRef` (`journal_entry_point.dart:35,49`) →
  `openJournalComposer` truyền xuống (`journal_entry_point.dart:68`) →
  `JournalComposerScreen.originRef` (`presentation/screens/journal_composer_screen.dart:34,49,72`) →
  `JournalComposerCubit.seeded(... originRef:)`
  (`presentation/journal_composer_cubit.dart:148,157`, ghi kèm
  `origin: JournalEntryOrigin.external` :156, giữ ở `_originRef` :176, lưu ở :252) →
  `JournalRepository.saveEntry(... originRef:)`
  (`data/journal_repository.dart:65-72`, ghi vào hàng ở :114) →
  cột `JournalEntries.originRef` (`core/database/tables/journal_entries.dart:34`).
  Vì vậy **không cần thêm API ghi nào**: bất kỳ màn hình nào có ngữ cảnh thẻ chỉ
  cần gọi
  `openJournalComposer(context, seed: JournalComposerSeed(originRef: <id thẻ>))`
  là mục nhật ký sinh ra đã mang khoá nối.
- **Bước 1c — không có caller nào thuộc phạm vi STORY-007 để cắm lệnh ghi đó.**
  Sự thật đo được, không phải suy đoán:
  - Toàn bộ `mobile/lib` chỉ có hai nơi gọi entry point:
    `features/account/presentation/screens/me_screen.dart:560` →
    `openJournalScreen(context)` (chỉ điều hướng, không seed), và
    `journal_entry_point.dart:86` → `openJournalComposer(routeContext)` trong
    `onCompose` của chính màn nhật ký (không seed). Không nơi nào truyền
    `JournalComposerSeed`.
  - Không một file nào dưới `mobile/lib/features/activity_cards/**` nhắc tới
    nhật ký dưới bất kỳ dạng nào (grep `[Jj]ournal` → 0 kết quả). Luồng "tạo
    mục nhật ký từ thẻ" **chưa tồn tại** trong code; nó không nằm ở STORY-001
    hay STORY-005.
  - `ux/uiux-spec.md` mục 3 dòng 63 cấm khối này mở camera/thư viện để "giữ
    boundary chỉ-đọc với nhật ký", nên STORY-007 **không được** tự dựng một lối
    ghi nhật ký từ thẻ; làm vậy là phát minh UX ngoài AC-14..AC-18.
  Hệ quả cho P4, và đây là cách phải làm: hiện thực hàm chiếu như Bước 1, rồi
  **hợp nhất hai nguồn ảnh** như bình thường. Nhánh nhật ký sẽ trả rỗng trên
  app thật cho tới khi story sở hữu màn tạo-mục-từ-thẻ truyền `originRef`
  (`journal_entry_point.dart` dòng 4-5 đã ghi STORY-008 là caller dự kiến;
  STORY-008 đang `TODO` ở `req_master.md:256`). Nhánh thẻ
  (`ActivityCardPhotos`) vẫn có dữ liệu ngay, nên AC-14/AC-15 không bị treo.
  **Cấm** dùng chỗ này làm cớ bỏ nhánh nhật ký: hàm chiếu vẫn phải viết và vẫn
  phải được kiểm bằng hàng nhật ký gieo sẵn `originRef = <id thẻ>` qua
  `JournalRepository.saveEntry` trong test.
- Định nghĩa kiểu projection ảnh chỉ mang **tham chiếu file ảnh**. Kiểu này
  **không được có** trường văn bản, thời gian ghi, hay nhãn mục nhật ký — đây
  là cách AC-17 được cưỡng chế bằng trình biên dịch thay vì bằng kỷ luật ở
  widget.
- Nguồn ảnh của thẻ là bảng `ActivityCardPhotos`
  (`mobile/lib/core/database/tables/activity_cards_table.dart`, cột `cardId`
  tham chiếu `ActivityCards`), không phải một trường ảnh trên chính bản ghi
  thẻ. Query chỉ đọc; nguồn nhật ký hợp nhất vào qua hàm chiếu của Bước 1, khử
  trùng theo đường dẫn file.
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
  (section phần 2), `features/journal/journal_entry_point.dart` +
  `features/journal/data/` (hàm chiếu chỉ-đọc)
- Notes or evidence: ghi vào `coding-plan/test-results.md` — chữ ký hàm chiếu
  mới, và xác nhận nhánh nhật ký được kiểm bằng hàng gieo sẵn `originRef` chứ
  không qua UI (chưa có caller nào truyền `originRef`, xem Bước 1c)

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
    Hàng nhật ký gieo bằng
    `JournalRepository.saveEntry(... originRef: <id thẻ>)`
    (`data/journal_repository.dart:65-72`), không qua UI.
  - Không ảnh → không widget section nào tồn tại trong cây (`findsNothing`),
    không hàng xám.
  - Mặc định chưa chọn; chỉ sau thao tác người dùng mới có ảnh trong vật phẩm.
  - Xoá mục nhật ký → không còn file ảnh nào của mục đó do app quản lý.
- Minimum gates by risk surface: mỗi risk surface ở `## 1B` có assertion trực
  tiếp. `JOURNAL_SOURCE_CONTRACT_CLOSED` đã chốt lối (A) ngày 2026-09-23, không
  còn là cổng chặn; thay vào đó gate là: entry point chỉ tăng đúng một hàm
  chỉ-đọc, và hàm đó không trả về văn bản hay mốc thời gian.
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

- Status: DONE
- Last updated: 2026-09-24
- Evidence: `coding-plan/test-results.md` mục `## P4 — Phần 2, đính ảnh`;
  `visual-fidelity/visual-fidelity-report.md` mục `## Phần 2 (P4)`.
- Ghi chú về §6 "How the implemented screen is captured": `capture-mobile-screen.sh`
  và `contracts/design-fidelity-spec.md` **không tồn tại** trong repo lẫn
  worktree. Không phải `MOBILE_RUNTIME_UNAVAILABLE`: dùng đúng lối dự phòng mà
  P2/P3/P5 của chính story này đã dùng — chụp `RepaintBoundary.toImage` trong
  widget test của story, ở viewport iOS tham chiếu, với `ActivityCardDetailScreen`
  thật. Hai trạng thái đều đã chụp như §6 yêu cầu.
