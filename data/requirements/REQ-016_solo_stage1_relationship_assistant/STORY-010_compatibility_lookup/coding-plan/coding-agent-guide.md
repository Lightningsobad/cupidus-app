# Coding Agent Guide – STORY-010 Bảng tra ăn khớp

Đọc file này trước khi mở bất kỳ file phase nào. Nó chứa các ràng buộc áp dụng
cho **mọi** phase của story. File phase chỉ nói phần riêng của phase đó.

## 1. Ranh giới story

- Lane duy nhất: **Mobile**. Không có lane backend, không có lane devops.
  Phần "cổng nhập nội dung" là một validator Dart chạy trong `mobile/test/`,
  không phải service. Lý do đầy đủ: `../architecture/solution.md` section 1,
  Key Discovery 1.
- Story **không được** thêm: HTTP client, endpoint, env var, secret, SDK bên
  thứ ba, job nền, hay bất kỳ lời gọi mạng nào. AC-28/AC-29 cấm trực tiếp; đây
  là ràng buộc thiết kế, không phải hiện trạng tạm.
- Story **không được** ghi vào `notebook_entries`, `skill_profile_entries`, hay
  `ask_prompt_state`. Sổ tay thuộc STORY-004; BR-10 cấm đổi contract của nó.

## 2. Nguồn sự thật theo thứ tự

1. `../architecture/contract-summary.md` — hình dạng dữ liệu, tên cột, chữ ký
   hàm. Đây là văn bản có thẩm quyền. Nếu file phase và contract-summary lệch
   nhau, **contract-summary thắng** và hãy báo lệch đó về Scrum Master.
2. `../architecture/solution.md` — vì sao lại quyết như vậy, và bảy mặt rủi ro.
3. `../requirements/requirements.md` — AC gốc. Trích đúng id AC, đừng trích trí
   nhớ: id AC trong handoff đã từng sai ở requirement này.
4. `../ux/uiux-spec.md` — hình dạng thị giác.

## 3. Lệnh chạy

SDK Flutter **không nằm trên PATH** của máy này. Mọi lệnh phải giải SDK trước:

```bash
export PATH="${FLUTTER_SDK_PATH:-$HOME/flutter}/bin:$PATH"
```

- Test: `flutter test <đường dẫn file test cụ thể>` (nguồn: runtime registry
  `mobile-app.testCommand`), chạy với `cwd` là `<worktree>/mobile`.
- Build gate: `flutter build apk --debug` (nguồn: runtime registry
  `mobile-app.buildCommand`).
- Sinh l10n khi chạm ARB: `flutter gen-l10n`. Trong worktree mới, chạy lệnh này
  **trước** mọi lệnh test, nếu không import `AppLocalizations` sẽ đỏ giả.
- Drift codegen khi chạm bảng: `dart run build_runner build --delete-conflicting-outputs`.

Ba luật về lệnh, vi phạm là hỏng cả phiên làm việc:

- **Không bao giờ nối ống (`|`, `| tee`, `| tail`) vào lệnh build.** Output bị
  cắt sẽ khoá vĩnh viễn cổng kết thúc và bạn sẽ không còn cách nào xác định
  nguyên nhân.
- **`flutter analyze` không bao giờ là bằng chứng cổng.** Baseline của repo là
  222 cảnh báo có sẵn, 0 lỗi; lệnh này không thể trả về 0. Dùng nó để tự đọc thì
  được, đừng dán kết quả làm bằng chứng pass.
- **Chạy từng file test trước, hợp lại sau.** Một lần chạy gộp đỏ sẽ khoá cổng
  bằng chứng build của cả phiên.

## 4. Bốn luật bất biến của story

Bốn điều này xuất hiện lại trong gần như mọi phase. Chúng là lý do story tồn
tại, không phải chi tiết trang trí.

### 4.1 DẢI là nhãn, không phải thang đo (R-8/BR-7/AC-32)

Không phần trăm, không sao, không điểm, không thanh tiến độ, không xếp hạng,
không so sánh cặp này "hơn" cặp kia. Cổng nhập ở P1 chặn **mọi số JSON** trong
cả ba gói — đó là hàng rào cứng khiến lỗi này không thể trượt qua review.

### 4.2 Đối xứng thị giác "hợp"/"va" (AC-33)

Khối "chỗ hợp" và khối "chỗ dễ va" phải **cùng một widget** dựng hai lần với
tham số khác nhau, không phải hai widget song sinh. Hai widget song sinh sẽ
lệch nhau ở lần sửa thứ ba và không ai phát hiện.

### 4.3 Khoá vị trí (R-13/SC-6/AC-30)

Màn tra ăn khớp **không có** named route, **không có** mục trong `routes:` của
`cupid_app.dart`, **không có** mục menu/tab. Vào được chỉ qua một hàm cửa vào
trong tiến trình, nhận token nguồn bắt buộc. Đây là cùng mẫu mà
`context_notebook_entry_point.dart` đang dùng — đọc nó, đừng phát minh lại.

### 4.4 Không rò nhãn từ hồ sơ (AC-29)

**Không prefill** nhãn hoàng đạo từ `CupidProfile.zodiacSign`. Trường đó do
backend trả về qua mạng và được suy từ ngày sinh; dùng nó là kéo mạng vào một
tính năng mà AC-29 tuyên bố là ngoại tuyến. Người dùng tự chọn nhãn, mỗi lần.

## 5. Quy ước dùng chung

- Gói nội dung parse qua `ContentPackage.parse<T>` với `expectedSchemaId` ghim
  cứng. Sai schema id thì ném `ContentPackageFormatException` — **đừng** bắt rồi
  trả về danh sách rỗng. Hỏng to, hỏng sớm là hành vi đúng ở đây.
- Denylist từ ngữ đã tồn tại ở `mobile/lib/core/content/invariant_terms.dart`.
  **Tuyệt đối không** chép bản thứ hai; bản chép là lỗi theo R-15c.
  Khi cần kiểm ranh giới sổ tay, đọc đúng **một** khoá
  `notebookBoundaryTerms[NotebookBoundaryRule.frequencyProbe]`. Nối cả ba khoá
  sẽ làm cổng không bao giờ qua được, vì `judgementProbe` chứa `tính cách`,
  `điểm mạnh`, `điểm yếu` — chính là chủ đề hợp lệ của một ô ăn khớp.
- Chuỗi hiển thị đi qua ARB (`app_vi.arb` + `app_en.arb`), trừ nội dung ô: nội
  dung ô sống trong asset JSON, không trong ARB.
- Không viết `12`, `16`, `144`, `256` vào bất kỳ file nào dưới `mobile/lib/`.
  Chúng chỉ được phép xuất hiện trong `mobile/test/`. Lý do: AC-36 bắt trục suy
  từ dữ liệu; AC-38 bắt số lượng bộ seed là cố định. Ranh giới `lib/` ↔ `test/`
  là cách duy nhất thoả cả hai.

## 6. Bằng chứng và chụp ảnh

- Màn này bị khoá vị trí nên **không** có route để script chụp màn hình lái tới.
  Bằng chứng thị giác cho story dùng đường vòng `RepaintBoundary` ngay trong
  widget test của story. Bố cục chụp cần bọc `CupidAppBackground` và nạp font
  `MaterialIcons` của framework, nếu không ảnh sẽ ra nền trắng và ô vuông tofu.
- Ảnh chụp xanh **không** đồng nghĩa đúng. Mở ảnh ra nhìn. Ký tự tiếng Việt có
  dấu sẽ thành ô vuông nếu font chữ nhúng thiếu điểm mã — chuyện này đã xảy ra
  ở requirement này.

## 7. Khi nào dừng lại thay vì đoán

Dừng và báo blocker (đừng tự chế giải pháp) khi:

- `DATA_GATE_BLOCKED` — cổng nhập không thể vừa chặn lời khen suông vừa cho qua
  nội dung hợp lệ.
- `NAV_LOCK_UNVERIFIABLE` — không viết được test chứng minh màn không có đường
  vào nào khác.
- `VISUAL_FIDELITY_BLOCKED` — không dựng được bằng chứng thị giác.
- `SCHEMA_BUMP_BLOCKED` — bump `schemaVersion` làm đỏ test của story khác.
