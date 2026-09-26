# F-M1 — Giải pháp kỹ thuật: nối 3 tab solo chặng 1 tới các màn đã ship

Nguồn phát hiện: `../integration-review/mobile-visual-audit.md` → `## F-M1`
(đã commit tại `c1c538ea`).
Quyết định sản phẩm đầu vào (2026-09-26, người dùng): **nối tab, không hoãn
D-3**. Tài liệu này chỉ quyết định **CÁCH LÀM**, không mở lại D-3.
Đọc tại HEAD `c1c538ea` của worktree tích hợp.

## 0. Tóm tắt cho Scrum Master

- `next_mode_recommendation`: **`mobile-implementation-direct`**
- Phân loại thay đổi: **`standard`**, chạy **trực tiếp trên worktree/branch
  tích hợp này** — không cần worktree kiểu story riêng.
- Phạm vi file: **1 file nguồn + 1 file test** (cộng tối đa 1 file test mới).
  Không migration, không đổi DI, không khoá l10n mới, không sửa hợp đồng
  cross-story.
- **Sửa chữa một tiền đề của handoff**: không có tab nào tên `Hồ sơ kỹ năng`.
  Bốn nhãn tab bị D-3 khoá là `Muốn làm · Ý tưởng · Sổ tay · Nhật ký`
  (`req_master.md:155`, `STORY-001_activity_card_hub/ux/uiux-spec.md:15`).
  Ánh xạ 1:1 "3 tab ↔ 3 màn" trong handoff **không khớp**. Xem §2.
- Kết quả: **cả 3 màn đã ship đều tới được ở phiên solo** — tức khoảng trống
  thật của F-M1 được đóng hết — nhưng bằng **2 tab**, không phải 3.
  Tab `Ý tưởng` giữ nguyên placeholder; đó là **OQ-1** cho PO (§6), không
  chặn triển khai.

## 1. Ràng buộc quyết định hình dạng giải pháp (đọc trong code, không suy diễn)

Hai hợp đồng entry point đã ship **cấm tường minh** việc mount các màn này làm
thân tab:

- `mobile/lib/features/journal/journal_entry_point.dart:96-98` —
  "The list is **not a tab and not a sub-tab of anything**: it is one
  independent route, which is what keeps it separate from the notebook and
  skill surfaces sharing its menu block (AC-17, `ux/uiux-spec.md` §8)."
- `mobile/lib/features/context_notebook/context_notebook_entry_point.dart:59-61`
  — "Its own route, **not a tab or a sub-tab of the skill screen**: the two
  surfaces stay independent so neither can grow a switcher between them
  (AC-17, `ux/uiux-spec.md` Phần 0)."

Ba lý do kỹ thuật độc lập nữa dẫn tới cùng kết luận:

1. Cả ba màn tự mang `Scaffold` + app bar có nút back (audit seam C). Làm thân
   tab thì nút back đó sẽ pop chính `PairGateShell`.
2. Mount trực tiếp buộc phải gọi `getIt<...>` ngay trong `build`. Test host
   hiện có của solo shell (`activity_card_hub_view_test.dart:805-850`) **không
   đăng ký `getIt`**, nên mọi test đang pump `HomeScreen` sẽ nổ.
3. `_SoloStageOneShell` dùng `IndexedStack` (`home_screen.dart:323-332`) —
   giữ sống cả 4 thân tab. Mount 3 màn có repository ở đó nghĩa là mở 3 màn
   dữ liệu riêng tư ngay khi vào app, kể cả khi người dùng không chạm tab nào.

**Kết luận ràng buộc:** điều hướng phải **push qua đúng 3 entry point đang có**,
và thân tab là một **khối liệt kê điểm đến**, không phải chính màn đó.

## 2. Quyết định 1 — cách điều hướng cụ thể (đã chốt, không để mở)

**Mô hình: "thân tab = khối điểm đến, chạm hàng → push route qua entry point".**
Áp dụng đồng nhất cho mọi tab không phải `Muốn làm`.

| Tab | Thân tab sau thay đổi | Hàng → điểm đến |
|---|---|---|
| `Muốn làm` | KHÔNG ĐỔI (`ActivityCardHubView`) | — |
| `Ý tưởng` | KHÔNG ĐỔI (`_SoloTabPlaceholder`) | — (OQ-1) |
| `Sổ tay` | khối 2 hàng | `Sổ tay người yêu` → `openNotebookScreen(context)`; `Những gì bạn giỏi` → `openSkillProfileScreen(context)` |
| `Nhật ký` | khối 1 hàng | `Nhật ký riêng` → `openJournalScreen(context)` |

Vì sao `Hồ sơ kỹ năng` nằm trong tab `Sổ tay` chứ không phải một tab riêng:

- `req_master.md:131` gộp **`Sổ tay người yêu (màn 2) + Hồ sơ kỹ năng (màn 3)`
  thành MỘT seed**, cùng outcome, cùng mô tả "hạ tầng cho quà/mồi chuyện".
  Đặt hai hàng cạnh nhau là đúng ý định phạm vi, không phải chỗ nhồi cho đủ.
- Không vi phạm AC-17: lệnh cấm là hai **màn** không được mọc switcher giữa
  chúng. Một khối menu **bên ngoài** cả hai màn, mỗi hàng push route độc lập
  của mình, chính là `_PrivateStorageBlock` đã ship
  (`me_screen.dart:539-579`) và đã PASS seam C1 của audit. Cấm tuyệt đối:
  segmented control / tab phụ / nút chuyển giữa hai màn đó.
- Nhãn dùng lại **khoá l10n đã có**, không tạo khoá mới:
  `me_menu_context_notebook` ("Sổ tay người yêu"),
  `me_menu_skill_profile` ("Những gì bạn giỏi"),
  `me_menu_private_journal` ("Nhật ký riêng").

Hai phương án đã cân nhắc và **loại**:

- *Mount màn làm thân tab*: vi phạm nguyên văn hai hợp đồng ở §1, cộng 3 lý do
  kỹ thuật ở §1.
- *Tự động push khi chọn tab* (chạm tab là đẩy route luôn): tạo một tab có thân
  không bao giờ thấy; pop về là một tab đang chọn nhưng trống; phải thêm logic
  khôi phục tab trước đó; và làm hợp đồng "mục đang chọn tô `--pink`"
  (UX §1 dòng 20) mất nghĩa.

Ràng buộc trình bày (giữ ý định định vị của AC-22 trong D-3, cột Outcome):
khối điểm đến phải **nhẹ và tĩnh** — tiêu đề nhỏ + các hàng, cùng bán kính/đệm
với `_PrivateStorageBlock`. Không card lớn, không đếm, không preview nội dung,
không CTA nổi. Nó không được cạnh tranh thị giác với kho thẻ, và theo
AC-21/SC-1' không được liệt kê thẻ hoạt động dưới bất kỳ hình thức nào.

## 3. Quyết định 2 — state/DI có phải đổi gì không

**Không. Không có state hay DI nào mà ba màn này thừa hưởng từ `MeScreen`.**
Kiểm chứng:

- Ba màn nhận phụ thuộc qua **constructor tường minh, do chính entry point
  điền**: `context_notebook_entry_point.dart:62-68` và `:121-128`,
  `journal_entry_point.dart:99-109`. `MeScreen` không truyền gì, không bọc
  `BlocProvider`, không giữ repository nào cho chúng.
- `getIt` đăng ký **vô điều kiện lúc boot**, độc lập trạng thái ghép đôi:
  `ContextNotebookRepository` (`service_locator.dart:412`),
  `JournalMediaStore` (`:673`), `JournalRepository` (`:681`) — đều
  `registerLazySingleton`. Phiên solo resolve giống hệt phiên đã ghép.
- Phụ thuộc môi trường mà `_SoloStageOneShell` đã có sẵn: `Navigator` (nó nằm
  dưới `PairGateShell` trong cây route của app), `Localizations` (đã dùng ở
  `_label`, `home_screen.dart:305-317`), theme tokens (đã dùng
  `context.cupidColors` ở `_SoloTabPlaceholder`).

**Một thay đổi bổ sung duy nhất, và nó là seam test chứ không phải DI:**
`_SoloStageOneShell` nhận thêm 3 callback mở màn tuỳ chọn
(`Future<void> Function(BuildContext)`), mặc định là chính ba entry point thật;
`HomeScreen` forward xuống ba tham số tuỳ chọn tương ứng. Đây đúng khuôn mẫu
seam đã ship trong cùng file (`resolvePairingStatus`, `createTimelineCubit`,
`home_screen.dart:199-209`). Không có seam này thì test host không đăng ký
`getIt` sẽ nổ khi chạm hàng.

**Biên import:** `home_screen.dart` thêm **đúng hai** import —
`features/journal/journal_entry_point.dart` và
`features/context_notebook/context_notebook_entry_point.dart`. Đó là hai bề mặt
công khai được phép; **không** import bất kỳ nội thất nào
(`presentation/screens/...`, repository, dao, cubit), nên AC biên import của
journal (P5 §4) vẫn giữ. Đây là ràng buộc cứng khi triển khai, không phải gợi ý.

## 4. Quyết định 3 — `standard` trên worktree tích hợp, không cần worktree riêng

**`standard`, thực thi trực tiếp trên
`codex/REQ-016_solo_stage1_relationship_assistant-integration`.**

Lý do, nói thẳng:

- Diff chạm **một file nguồn** (`mobile/lib/features/home/presentation/home_screen.dart`)
  và **một file test** đang có, cộng tối đa một file test mới. Không schema,
  không migration, không `schemaVersion`, không package mới, không sửa hợp đồng
  cross-story, không sinh lại l10n.
- Đây là **sửa chữa mức yêu cầu do audit mức yêu cầu tìm ra**, nên nó phải hạ
  cánh đúng nơi audit đã chạy. Cùng tuyến đã dùng cho F-I1/F-I2/F-I3 ở Round
  40-41 — có tiền lệ trong chính requirement này.
- Một worktree kiểu story sẽ nhánh ra từ đúng head này rồi merge thẳng về, không
  có lợi ích song song nào, mà lại đòi một STORY id mới + artifact PO/UX cho một
  thay đổi nhỏ hơn phần lớn phase đơn lẻ.
- Rủi ro bị chặn sẵn: nhánh đã ghép đôi không bị chạm (`_buildCoupleHome` không
  sửa), tab `Muốn làm` và chuỗi push cross-story seam B không bị chạm.

## 5. Quyết định 4 — một lượt mobile-dev, không cần coding-plan

**Khuyến nghị: `mobile-implementation-direct`.** Một `coding-plan` với bảng
phase sẽ tốn thêm một lượt dispatch và một lượt verification cho thay đổi 2 file
— nhỏ hơn hẳn một vòng đời specialist (chuẩn ~6 file nguồn/test). Dưới đây là
phạm vi test giao trực tiếp cho mobile-dev, thay cho coding-plan.

### 5.1 Việc phải làm trong code

1. `home_screen.dart`: thêm widget khối điểm đến dùng chung (icon + nhãn +
   divider, hình dạng theo `_PrivateStorageBlock`), key ổn định cho khối và cho
   từng hàng (ví dụ `solo_tab_destinations_soTay`,
   `solo_destination_row_notebook`).
2. `home_screen.dart`: `_SoloStageOneShell` build thân tab `soTay`/`nhatKy` từ
   khối đó; **giữ lại** `_SoloTabPlaceholder` cho `yTuong` (không xoá widget).
3. `home_screen.dart`: thêm 3 seam opener tuỳ chọn + forward từ `HomeScreen`.
4. Thêm đúng 2 import ở §3. Không thêm gì khác.

### 5.2 Test bắt buộc

1. **`mobile/test/features/activity_cards/activity_card_hub_view_test.dart:852-907`
   PHẢI viết lại** — test này đang ghim cả ba tab là placeholder, nó sẽ đỏ và
   đó là đỏ đúng. Khi viết lại: `yTuong` vẫn assert
   `solo_tab_placeholder_yTuong`; `soTay`/`nhatKy` assert các hàng điểm đến;
   **giữ nguyên nguyên văn** assertion AC-21/SC-1'
   (`find.text('Đi biển')` → `findsNothing`) cho **cả ba** tab.
2. Assertion mới: chạm mỗi hàng gọi **đúng một lần** opener được inject, đúng
   điểm đến. Thêm một test dùng opener thật với `getIt` đã đăng ký để khẳng định
   route được push và `solo_stage_one_tab_bar` **vắng mặt** trên route đã push
   (hợp đồng seam B của audit).
3. Kiểm tra `mobile/test/core/navigation/app_shell_test.dart:351` vẫn xanh
   (nhánh đã ghép đôi không đổi — kỳ vọng không phải sửa gì).
4. Chạy `test/features/journal/` và `test/features/context_notebook/` để chắc
   biên import và hai entry point không bị lệch.

### 5.3 Ràng buộc chạy gate (đã biết trước, đừng thử lại)

- **KHÔNG chạy `flutter test` trần.** Baseline của REQ-016 đang đỏ ở 3 suite
  `test/design_system/`, và một lượt full-suite sẽ kẹt build gate cả phiên.
  Chỉ chạy đúng các file/thư mục ở §5.2.
- **Không pipe output của lệnh build/test.** Kẹt gate là không cứu được.
- `flutter analyze lib test` có baseline khác 0 (khoảng 222 warning tồn đọng,
  0 error). So **số error**, không dùng exit code làm bằng chứng.
- `git status` trước khi phát completion marker: lượt chạy test mobile hay ghi
  đè PNG visual-fidelity của story khác.

### 5.4 Ảnh chụp cho lần audit lại

Hai thân tab mới là bề mặt render mới trên màn đã bị audit, nên nên chụp
`Sổ tay` và `Nhật ký` bằng `RepaintBoundary` trong chính widget test (harness
cần `CupidAppBackground`, một lớp nền đục, và nạp font `MaterialIcons` của
framework). **Đây là ảnh để đóng lại seam A, KHÔNG phải artifact fidelity
gate**: hai khối này không có id canvas thiết kế, nên **không** đặt tên
`implemented-*.png` và không cố ghép cặp fidelity.

## 6. OQ-1 (cho PO, không chặn triển khai) — tab `Ý tưởng`

Sự thật đã kiểm chứng: `Ý tưởng` không ứng với màn nào đã ship. Các màn "sinh ý
tưởng" (`Gợi ý quà` màn 5, `Mồi chuyện` màn 6, `trắc nghiệm` màn 7) đã ship và
**đã tới được ở phiên solo** qua dải lối-vào-nhanh của tab `Muốn làm` (audit
seam B PASS). Không có story nào được giao sở hữu nội dung tab `Ý tưởng`.

Vì vậy `Ý tưởng` giữ `sắp có` là **đúng đặc tả**, không phải khuyết điểm F-M1:
UX §1 dòng 17-18 mô tả ba tab đó là "vỏ giữ chỗ… nội dung do story khác điền",
và §6 chỉ định đúng câu trả lời trung tính `sắp có` cho lối vào mà story chủ
chưa ship. Khuyết điểm F-M1 là **màn đã ship mà không tới được** — và sau thay
đổi này không còn màn nào như vậy.

Cần PO quyết (ngoài phạm vi tài liệu này): có giao nội dung tab `Ý tưởng` cho
một story chặng 1 hay ghi nhận hoãn tường minh. Gộp các màn 5/6/7 vào tab đó là
phạm vi mới, cần PO + UX, và sẽ tạo lối vào trùng với dải lối-vào-nhanh.
