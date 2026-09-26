# STORY-013 Lối ra (J11) và lối quay lại (J13) — solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-09-11

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC-6/AC-10 (phân loại tất định ở tầng dữ liệu, mơ hồ →
  giữ), AC-1 (đóng trong **một** thao tác), AC-11/AC-12 (mọi bề mặt khác ngừng
  hiện vật liệu đã đóng), AC-17 (mở lại được), AC-19/AC-20 (một hằng số, một
  phép so sánh boolean, không lộ số đo), AC-26/AC-27 (xoá thật, không dư lượng),
  BR-3 (không đổi ngữ nghĩa hợp đồng STORY-001/STORY-004).
- Architectural invariants / non-goals: **không backend, không mạng, không
  thông báo** (BR-8); không cột nào chứa lý do/nhãn/nhận định về người kia
  (AC-5/BR-9); không route mới cho kho đã đóng (BR-4); không thêm lối vào màn 8
  /màn 10 (BR-13); không API nào trả về số ngày vắng (AC-20); không xoá dữ liệu
  trong luồng đóng ngăn (BR-1).
- Proposed technical direction: một feature module mobile mới
  `mobile/lib/features/chapter_closure/` sở hữu (a) **sổ ghi thành viên** hai
  bảng Drift mới (`chapter_closures`, `chapter_closure_items`) chụp ảnh tập vật
  liệu gắn người tại thời điểm đóng, (b) một **cổng đọc** duy nhất mà
  `ActivityCardDao` và `ContextNotebookRepository` anti-join vào, (c) một
  `Stage1WipeRegistry` liệt kê tường minh mọi kho REQ-016 cho luồng xoá sạch,
  (d) một `ReturnGateResolver` chỉ trả về `bool`. Màn quay lại J13 chèn giữa
  `SplashScreen` và `PairGateShell`.
- Why this fits: mọi dữ liệu REQ-016 đã là Drift device-authoritative không có
  bản sao máy chủ (`mobile/lib/core/database/tables/activity_cards_table.dart`
  §47-64, `context_notebook_tables.dart` §3-15, `invite_messages_table.dart`
  §10-18). Story này thêm một tầng trạng thái của riêng nó lên trên, đúng BR-3.

### Key Discovery

1. **Phân loại AC-6 phải là ảnh chụp, không phải vị từ chạy lúc đọc.** Nếu
   "gắn người" được tính lại mỗi lần đọc (`invited = 1 OR status IN
   ('done','memory') OR có invite_message`), thì một thẻ **sống sót** mà người
   dùng dùng lại cho mối quan hệ mới sẽ tự chui vào kho đã đóng ngay khi họ xuất
   lời mời — phá thẳng AC-9. Vì vậy tập đóng phải được **materialize** tại thời
   điểm xác nhận và không bao giờ tính lại. Đây là lý do tồn tại của
   `chapter_closure_items`; không có nó, AC-7 và AC-9 mâu thuẫn nhau.
2. **Dải segmented control đã có 5 ô, không phải 4.**
   `presentation/activity_card_list_cubit.dart` §15-25 và
   `presentation/widgets/activity_status_filter.dart` §39-41 ship
   `ActivityCardPane { all, idea, scheduled, done, memory }` — ô "Tất cả" dẫn
   đầu rồi bốn trạng thái. `ux/uiux-spec.md` §3 mô tả "đoạn thứ 5"; thực tế là
   **ô thứ 6**, vẫn là ô cuối trên **cùng một** control, cùng một danh sách,
   không route mới. Ý đồ UX không đổi; chỉ số thứ tự trong spec đã cũ. Không
   phải blocker, không cần PO patch.
3. **Lọc "đã đóng" phải nằm trong SQL, không phải sau khi đọc.**
   `cardsByStatus(limit:, offset:)` là truy vấn phân trang và
   `ActivityCardListCubit._fetchPage` suy ra `hasMore` từ `page.length ==
   _pageSize`. Lọc trong Dart sau khi đọc sẽ làm sai cả kích thước trang lẫn
   `hasMore`. Anti-join `NOT EXISTS` là bắt buộc, không phải tối ưu.
4. **Lời mời không cần là một loại thành viên riêng.**
   `invite_messages.card_id` đã có `ON DELETE CASCADE` về `activity_cards`
   (`invite_messages_table.dart` §24-28), nên lời mời gắn người **khi và chỉ
   khi** thẻ của nó gắn người. Sổ ghi chỉ liệt kê ba loại; danh mục AC-7 vẫn
   đúng nguyên vẹn qua quan hệ khoá ngoại.
5. **Xoá sạch không phải là `clearOnSignOut()`.** Người dùng vẫn đăng nhập sau
   AC-29. Các kho REQ-016 cố ý **không** là `SessionScopedStore`
   (`daos/activity_card_dao.dart` §11-14); tái dùng hook đăng xuất sẽ vừa thiếu
   (không chạm filesystem) vừa thừa (xoá cache của domain khác).

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (cổng đóng ngăn +
  sổ đăng ký xoá sạch mà STORY-005/007/008/009/010/011/012 phải tuân thủ).

## 3. Scope And Assumptions

- In Scope: module `features/chapter_closure/`, hai bảng Drift mới + migration
  v6→v7, anti-join trong `ActivityCardDao` và `ContextNotebookRepository`, ô
  pane thứ sáu trên hub, màn J13 và luồng xoá sạch.
- Out Of Scope: backend, mạng, thông báo, widget OS, mọi thay đổi chữ ký công
  khai của `ActivityCardRepository` và `ContextNotebookReader`.
- Assumptions affecting design: chặng 1 có **đúng một** "mối" tại một thời
  điểm (`ux/uiux-spec.md` §1), nên đóng ngăn là sự kiện toàn cục theo
  `ownerKey`, không cần thực thể "người" nào. `invited` do
  `invite_composer_cubit.dart` §301 ghi. STORY-005/007..012 chưa merge; BR-12
  cho phép sổ ghi chỉ bao ba loại đang tồn tại.

### UI Delivery Anchor

- Design Scope Description: (a) app bar tab "Nhà" của `ActivityCardHubView` —
  thêm overflow `more_vert` một mục; (b) cùng `ActivityStatusFilter` — thêm ô
  cuối "Đã đóng", chỉ hiện khi đã có ít nhất một closure; (c) một màn takeover
  toàn màn hình mới cho J13; (d) hai hộp thoại xác nhận theo bảng luật đo được
  `ux/uiux-spec.md` §2, dựng lại kiểu của
  `activity_cards/presentation/widgets/delete_card_dialog.dart`.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/chapter_closure/` — sở hữu duy nhất hai
  bảng mới, `ChapterClosureService`, `ChapterClosureGate`, `ReturnGateResolver`,
  `Stage1WipeRegistry` và `Stage1WipeService`.
- New or changed boundaries: `ActivityCardDao` và `ContextNotebookRepository`
  nhận cổng đọc qua constructor và anti-join trong SQL. Chữ ký và ngữ nghĩa
  công khai của `ActivityCardRepository` / `ContextNotebookReader` **không
  đổi** — điều đổi là một thẻ đã đóng không còn thuộc pane nào, đúng AC-11
  (BR-3 giữ nguyên). Hệ quả: AC-12 đạt được **không cần sửa consumer nào** —
  `entries()` trả list rỗng, đúng hành vi "sổ tay còn trống".
- Shared patterns reused: `BackendUserIdStore` cho `ownerKey`;
  `SharedPreferences` sau một store tiêm được, theo tiền lệ
  `before_you_go/data/before_you_go_dismissal_store.dart`; migration cộng thêm
  theo ADR-010 và ghi chú "no destructive recreate" ở `cupid_database.dart`
  §73-87; `JournalMediaStore.deleteRoot()` cho file ảnh.

### Affected Modules

- Mobile: `features/chapter_closure/` (mới), `features/activity_cards/`,
  `features/context_notebook/`, `core/database/`, `core/di/service_locator.dart`,
  `features/auth/presentation/screens/splash_screen.dart`.

### Contracts And Integrations

- Đóng ngăn chạy trong **một** transaction Drift: chọn id → ghi closure → ghi
  items. Sự cố giữa chừng không để lại trạng thái đóng một nửa (AC-1).
- Mở lại (AC-17) là **xoá hàng closure**, items cascade theo. Không cột
  `reopened_at`, không lịch sử đóng/mở — thứ không tồn tại thì không thể bị
  hiển thị thành chuỗi (BR-7).
- Ngưỡng vắng: `ReturnGateResolver.shouldShow()` trả về **`bool`**, không trả
  `Duration`, không trả ngày. Đó là cách thi hành AC-20 ở tầng kiểu: UI không
  có đường nào lấy được số ngày để vẽ.
- Kho rỗng là trạng thái bình thường ở mọi đường đọc (AC-12/AC-29), không phải
  lỗi, không có thông điệp lỗi.
- Compatibility: `schemaVersion` 6 → 7, chỉ `createTable` hai bảng mới trong
  một nhánh `if (from < 7)`; không sửa bảng cũ, không migrate dữ liệu.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Phân loại gắn người sai → mất tài sản | AC-6/AC-7/AC-8/AC-10 | Vị từ SQL chỉ gồm tín hiệu dương tính; mọi thứ khác sống sót | Test: thẻ "Mới nghĩ ra" chưa mời sống sót; hồ sơ kỹ năng sống sót; thẻ sống sót mời người mới **không** bị hút vào kho đã đóng | BLOCKER — AC-8/AC-9 không chứng minh được |
| Rò rỉ vật liệu đã đóng ra luồng thường ngày | AC-11/AC-12 | Anti-join trong DAO/repository, không lọc ở tầng UI | Test: `cardsByStatus`, `countsByStatus`, `entries()` sau khi đóng | BLOCKER |
| Phân trang sai do lọc sau khi đọc | Key Discovery 3 | Lọc bằng `NOT EXISTS` trong SQL | Test: pane 25 thẻ, 10 đã đóng, hai trang liên tiếp không trùng/không sót | BLOCKER |
| Dư lượng sau xoá sạch | AC-26/AC-27 | `Stage1WipeRegistry` là danh sách tường minh một chỗ | Test: sau wipe, mọi bảng trong sổ đăng ký rỗng, media root không tồn tại; test đối chiếu sổ đăng ký với danh sách bảng REQ-016 | BLOCKER |
| Cột cấm lọt vào schema | AC-5/BR-9 | Allowlist cột đóng | Test migration kiểu `context_notebook_migration_test.dart` cấm `reason`/`label`/`note`/`person*`/`sentiment`/`*count*` | BLOCKER |
| Màn J13 trở thành cổng chặn | AC-24/AC-30 | Mọi lối ra (kể cả X) đều `pushReplacement` vào đích dùng được | Widget test bốn lối + lối X | BLOCKER |
| Migration phá dữ liệu người dùng | `cupid_database.dart` §73-87, ADR-010 | Chỉ `createTable` trong nhánh `from < 7` | Test migration v6→v7 giữ nguyên hàng cũ | BLOCKER |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story. **Không có lane backend** — không AC nào cần
  máy chủ, và một bản sao máy chủ sẽ trực tiếp vi phạm AC-27.
- Authoritative inputs: `requirements/requirements.md`, `ux/uiux-spec.md`,
  `architecture/contract-summary.md`.
- Guardrails: không đổi chữ ký `ActivityCardRepository`; không thêm giá trị thứ
  năm vào `ActivityCardStatus`; không thêm cột vào bảng của STORY-001/004;
  không để bất kỳ hàm public nào trả về số đo khoảng vắng; không xoá hàng nào
  trong luồng đóng ngăn; không gọi `clearOnSignOut()` từ luồng xoá sạch; không
  thêm `@DriftDatabase` thứ hai (ADR-010).

## 5. Non-Functional Impact

- Anti-join chạy trên mọi lần đọc thẻ. `chapter_closure_items` cần index
  `(item_kind, item_id)`; kho thẻ cá nhân nhỏ nên chi phí không đáng kể, nhưng
  thiếu index sẽ biến mỗi trang thành quét bảng.
- `PRAGMA foreign_keys = ON` đã bật sẵn ở `beforeOpen` — cascade của
  `chapter_closure_items` phụ thuộc vào nó và không được tắt.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Sổ ghi thành viên riêng (`chapter_closure_items`) | Giữ trạng thái đóng ở tầng của chính story (BR-3), ảnh chụp tại thời điểm đóng, mở lại là xoá một hàng | ACCEPTED | Một chỗ duy nhất biết "cái gì đã đóng"; story tương lai chỉ đăng ký thêm `item_kind` |
| Cột `closed_at` trên từng bảng gắn người | Lọc rẻ hơn, không cần join | Rejected | Mỗi story tương lai phải tự thêm cột + tự nhớ lọc; sai sót là **im lặng**, và nó sửa hình dạng dữ liệu của STORY-001/004 đúng thứ BR-3 cấm |

## 7. Addendum 2026-09-26 — `calendar_event_state` thuộc phạm vi xoá sạch (F-I1)

**Decision: REGISTER.** `calendar_event_state` là bảng chặng 1 và phải có mặt
trong `Stage1WipeRegistry.tables`; không được loại trừ qua `nonReq016Tables()`.

Rationale: bảng chỉ lưu *lựa chọn của chính người dùng* với gợi ý mồi chuyện
(`state` = `converted` | `dismissed`, khoá `(ownerKey, eventId)`), tức dữ liệu
chặng 1 do người dùng tạo theo câu mở đầu AC-26 — danh sách liệt kê sau đó
("trạng thái bộ đếm" …) là minh hoạ cho nguyên tắc đó, không phải danh sách
đóng. Để lại các hàng này thì sau khi xoá sạch một gợi ý từng bị `dismissed`
vẫn còn dấu vết hành vi trước đó, đúng thứ AC-27 cấm. Đường (b) cũng không dùng
được: `nonReq016Tables()` chỉ nhận bảng đệm đọc-xuyên do máy chủ làm chủ, thuộc
yêu cầu trước, lấy lại được và bị xoá khi đăng xuất — bảng này không thoả tiêu
chí nào.

Việc mobile-dev phải làm (chỉ 1 file code):
`mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart` — thêm một
`Stage1WipeTable` cho `_db.calendarEventState` với `ownerWhere` dựng từ
metadata Drift sinh ra (`ownerKey`), không viết tay tên cột. Kèm theo đó,
`mobile/test/features/chapter_closure/stage1_wipe_registry_parity_test.dart`
phải cập nhật `expect(expected, hasLength(...))` cho đúng tổng số bảng REQ-016
sau khi cả ba bảng còn thiếu được đăng ký. Không sửa `nonReq016Tables()`.
