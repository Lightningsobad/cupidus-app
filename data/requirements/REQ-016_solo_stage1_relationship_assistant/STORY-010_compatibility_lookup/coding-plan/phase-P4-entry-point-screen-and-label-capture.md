# Phase P4 – Cửa vào, màn tra, nhập nhãn, đẩy thẻ

## 1. Phase Metadata

- Phase Id: P4
- Owner: Mobile Developer
- Lane: Mobile
- Depends On: P1, P2, P3
- Parallelizable: YES (chạy song song P5, P6)
- Status: NOT_STARTED
- Runtime Registry Id: `mobile-app`
- Build Command Source: runtime registry `mobile-app.buildCommand`
- Startup Smoke: NOT_APPLICABLE

## 2. Goal

Ghép thành tính năng chạy được: hàm cửa vào bị khoá vị trí, màn tra, cubit đọc
nhãn từ P2 và tra ô từ P1, thẻ nhập nhãn, và đường đẩy hoạt động sang kho thẻ.
Đây là phase duy nhất chạm file ngoài thư mục feature.

## 3. Primary Inputs

- `../architecture/contract-summary.md` section 1 (`openCompatibilityLookup`,
  `CompatibilityEntry`) và section 5 (`ActivityCardOrigin` mới)
- `../requirements/requirements.md` — AC-29, AC-30, AC-31, AC-34
- `../ux/uiux-spec.md`
- P1 domain, P2 repository, P3 widgets
- `mobile/lib/features/context_notebook/context_notebook_entry_point.dart` —
  **mẫu cửa vào bị khoá vị trí phải chép**
- `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
  quanh `class _GuessRow` (`Key('gift-ideas-guess-row')`) — cửa vào đã đặt sẵn
  cho story này, hiện đang hiện `SnackBar` "sắp có"
- `mobile/lib/features/activity_cards/domain/activity_card.dart` —
  `enum ActivityCardOrigin`, **chỉ được nối thêm**
- `mobile/lib/app/cupid_app.dart` — đọc để **xác nhận không sửa**
- `../coding-plan/coding-agent-guide.md`

## 4. Write Scope

- `mobile/lib/features/compatibility_lookup/compatibility_lookup_entry_point.dart`
- `mobile/lib/features/compatibility_lookup/presentation/screens/compatibility_lookup_screen.dart`
- `mobile/lib/features/compatibility_lookup/presentation/cubit/compatibility_lookup_cubit.dart`
  (kèm state trong cùng file)
- `mobile/lib/features/compatibility_lookup/presentation/widgets/label_capture_card.dart`
- `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
  (sửa: nối `_GuessRow` vào cửa vào thật)
- `mobile/lib/features/activity_cards/domain/activity_card.dart` (sửa: nối thêm
  một giá trị enum)
- `mobile/lib/core/di/service_locator.dart` (sửa: đăng ký cubit + loader)
- `mobile/lib/l10n/app_vi.arb`, `mobile/lib/l10n/app_en.arb` (sửa)
- `mobile/test/features/compatibility_lookup/compatibility_lookup_screen_test.dart`
- `mobile/test/features/compatibility_lookup/compatibility_lookup_position_lock_test.dart`

Việc nối thêm `ActivityCardOrigin` gộp vào phase này thay vì tách riêng: nó là
một dòng enum chỉ có ý nghĩa khi có nơi phát ra nó, và tách ra sẽ tạo một phase
một-dòng không đáng một vòng đời chuyên gia.

## 5. Planned Outputs

- `enum CompatibilityEntry { giftIdeas('gift_ideas'), dateScript('date_script') }`
- `Future<void> openCompatibilityLookup(BuildContext context, {required CompatibilityEntry from})`
- Màn tra + cubit + thẻ nhập nhãn.
- `ActivityCardOrigin.compatibilityLookup('compatibility_lookup')`.
- Test khoá vị trí.

## 6. Implementation Steps

1. Viết cửa vào đúng chữ ký trong contract-summary section 1. Nó đẩy một
   `MaterialPageRoute` **vô danh** — không `settings.name`, không hằng
   `routeName`, không mục trong `routes:` của `cupid_app.dart`, không mục
   menu/tab. Tham số `from` là token nguồn **bắt buộc**; không có giá trị mặc
   định, nên gọi được thì phải khai báo mình đến từ đâu.
2. `cupid_app.dart` **không được sửa trong phase này**. Nếu bạn thấy mình đang
   mở nó để thêm gì đó, khoá vị trí đã vỡ — dừng lại và đọc lại AC-30.
3. Cubit: nạp ba gói qua `ContentPackageLoader`, đọc nhãn hiện có từ repository
   P2, và khi đủ cặp `(self, partner)` cho một hệ thì gọi `lookupCell` của P1.
   Chọn hệ nào để tra là quyết định của cubit dựa trên nhãn đang có, không phải
   của widget.
4. Thẻ nhập nhãn dựng theo **hình dạng thị giác** của `AskOnTheSpotSlot` nhưng
   **không dùng** lớp đó và **không ghi** gì vào sổ tay. Lý do:
   `AskTarget` là enum đóng ba giá trị với câu trả lời tự do, còn nhãn ở đây là
   từ vựng đóng 12/16 giá trị kèm cờ `known | guess`; ép vào sẽ đổi contract của
   STORY-004, điều BR-10 cấm. Lập luận đầy đủ ở
   `../architecture/solution.md` section 1 Key Discovery 5 — đọc trước khi phản
   đối, vì §6 của contract-summary STORY-004 thoạt nhìn nói ngược lại.
5. **Không prefill** nhãn hoàng đạo từ `CupidProfile.zodiacSign`. Trường đó do
   backend trả về và suy từ ngày sinh; chạm vào nó là kéo mạng vào một tính năng
   AC-29 tuyên bố ngoại tuyến. Người dùng tự chọn, mỗi lần, cho cả mình lẫn đối
   phương, kèm `known | guess`.
6. Nối thêm **một** giá trị vào cuối `ActivityCardOrigin`. Enum này chỉ-nối-thêm
   theo contract STORY-001: không chèn vào giữa, không đổi wire value cũ, không
   xoá. Nút "thêm vào kho" của P3 tạo thẻ qua `createCard` với `origin` mới và
   `title` lấy từ `cell.activity`.
7. Nối `_GuessRow` trong `gift_ideas_screen.dart`: thay `SnackBar` "sắp có"
   bằng `openCompatibilityLookup(context, from: CompatibilityEntry.giftIdeas)`.
   Giữ nguyên `Key('gift-ideas-guess-row')` — test của story khác dựa vào nó.
   Gỡ chuỗi ARB "sắp có" nếu không còn nơi dùng.
8. Đăng ký cubit và loader trong `service_locator.dart`.

## 7. Test Scope

- `mobile/test/features/compatibility_lookup/compatibility_lookup_screen_test.dart`:
  chọn nhãn self + partner → hiện ô đúng; đổi thứ tự cặp ra ô **khác** (BR-2);
  nhấn "thêm vào kho" tạo đúng một thẻ với `origin` mới; màn **không** ghi gì
  vào sổ tay.
- `mobile/test/features/compatibility_lookup/compatibility_lookup_position_lock_test.dart`:
  - khẳng định `cupid_app.dart` không chứa tên màn này trong `routes:`;
  - khẳng định không file nào dưới `mobile/lib/` (ngoài chính file cửa vào) gọi
    `Navigator.pushNamed` tới màn này;
  - khẳng định điểm gọi `openCompatibilityLookup` **duy nhất** trong `lib/` là
    `gift_ideas_screen.dart` (STORY-008 sẽ thêm điểm thứ hai ở story của nó).
- Test ranh giới import: khi quét vi phạm, hãy **phân giải URI import** thành
  đường dẫn thật. `lib/` dùng import tương đối, nên so khớp chuỗi con kiểu
  `features/context_notebook/` sẽ luôn xanh trong khi vi phạm thật vẫn nằm đó.

Ngoài phạm vi: e2e, chạy trên thiết bị, script gate ở gốc repo, runtime startup
smoke.

## 8. Build Gate

`flutter build apk --debug` (nguồn: runtime registry `mobile-app.buildCommand`).
Không nối ống.

## 9. Runtime Startup Gate

NOT_APPLICABLE.

## 10. Completion Criteria

- `openCompatibilityLookup` là đường vào duy nhất; `cupid_app.dart` không đổi.
- Cả hai file test xanh.
- `ActivityCardOrigin` chỉ được nối thêm, không sắp xếp lại.
- Không có ghi nào vào bảng sổ tay.
- Build gate xanh.

## 11. Stop Rule

Dừng với `NAV_LOCK_UNVERIFIABLE` nếu không viết được test chứng minh màn không
có đường vào nào khác. Đừng thay bằng lời hứa trong mô tả PR: khoá vị trí là một
yêu cầu kiểm chứng được, và nếu không kiểm chứng được thì Scrum Master cần biết
ngay chứ không phải ở lần review sau.
