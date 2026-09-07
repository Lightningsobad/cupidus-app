# UX Survey: REQ-016 Solo Stage-1 Relationship Assistant

Khảo sát chéo bắt buộc trước khi viết uiux-spec cho từng story (batch RUN 1-4).
Các RUN sau đọc file này thay vì khảo sát lại. Không refresh
`data/ux/system/ui_ux_system_memory.md` ở đây — mục cuối gom đề xuất, chờ RUN
cuối áp dụng.

## 0. Phát hiện nền tảng — shell hiện có không có bề mặt "chặng 1"

`mobile/lib/core/navigation/app_shell.dart`: shell 5 tab hiện tại là
**Nhà · Trò chuyện (ẩn khi chưa ghép, `ChatEntryGate.isUnlocked`) · Pet · Ví
chung · Tôi**. Đây là shell của REQ-001 (chế độ đã ghép cặp). `home_screen.dart`
đã có sẵn nhánh `isPaired` (dòng ~382/562/573) và một cổng
`PairingStatus.paired` ẩn `TimelineEntryPointCard` khi chưa ghép (dòng
~1050-1099) — nhưng **không có nội dung thay thế** cho nhánh solo: đây chính
là điểm "mờ nhạt" mà `req_master.md` mô tả.

**Quyết định kiến trúc điều hướng cho toàn REQ-016** (áp dụng cho mọi story,
không đàm phán lại ở story sau):

- **Không thêm tab, không đổi shell 5 tab.** Tab "Trò chuyện" tiếp tục ẩn khi
  chưa ghép (hành vi có sẵn, không đổi).
- **Tab "Nhà" phân nhánh theo `isPaired`**: nhánh solo = toàn bộ nội dung
  STORY-001 (kho chung). Đây là "màn về nhà" mà mọi story khác tham chiếu.
- **3 màn nhóm CỬA VÀO (Gợi ý quà, Mồi chuyện, Vỏ hoàng đạo)** có lối vào từ
  **một dải lối-vào-nhanh cố định 3 ô, nằm trên đầu tab Nhà**, phía trên khối
  4-ngăn-lọc. Dải này KHÔNG phải kho thứ hai (không vi phạm SC-1'): đúng 3 ô
  cố định, không cuộn vô hạn, không trạng thái theo item, chỉ là điều hướng.
- **3 màn nhóm KHO chỉ-xem/sửa (Sổ tay, Hồ sơ kỹ năng) + Nhật ký** có lối vào
  từ tab **"Tôi"**, dưới dạng một khối menu mới tái dùng nguyên mẫu `_MenuRow`
  + card nhóm đã có trong `me_screen.dart` (dòng ~560, icon-badge + label +
  chevron, đã dùng cho Privacy/Notifications). Không cần component menu mới.
- **3 màn nhóm KHOÁ VỊ TRÍ (Chân dung, Kịch bản, Bảng tra)** — không route
  trực tiếp, không mục menu ở bất cứ đâu. Chỉ tới được bằng liên kết trong
  luồng (5) hoặc (9) đang chạy, đúng SC-6/R-13.
- **Hành động (11) Xuất lời mời** — bottom sheet, không phải destination.

Bản đồ 11 màn hình ↔ story sở hữu ↔ lối vào:

| # | Màn | Nhóm | Story chủ | Lối vào |
|---|---|---|---|---|
| 1 | Kho chung (danh sách việc-cần-làm) | KHO | STORY-001 | Tab "Nhà" (nhánh solo) |
| 2 | Sổ tay người yêu | KHO | STORY-004 | Tab "Tôi" → menu |
| 3 | Hồ sơ kỹ năng | KHO | STORY-004 | Tab "Tôi" → menu |
| 4 | Nhật ký riêng | KHO | STORY-003 | Tab "Tôi" → menu |
| 5 | Gợi ý quà | CỬA VÀO | STORY-004 | Dải lối-vào-nhanh trên tab Nhà |
| 6 | Mồi chuyện | CỬA VÀO | STORY-005 | Dải lối-vào-nhanh trên tab Nhà |
| 7 | Vỏ hoàng đạo / trắc nghiệm | CỬA VÀO | STORY-011 | Dải lối-vào-nhanh trên tab Nhà |
| 8 | Chân dung "theo cách BẠN nhìn" | KHOÁ VỊ TRÍ | STORY-009 | Chỉ từ luồng (5)/(9) |
| 9 | Kịch bản buổi hẹn 3 phần | KHOÁ VỊ TRÍ | STORY-008 | Chỉ từ hành động "chuẩn bị" của thẻ *Đã hẹn ngày* |
| 10 | Bảng tra ăn khớp | KHOÁ VỊ TRÍ | STORY-010 | Chỉ từ luồng (5)/(9) |
| 11 | Xuất lời mời (bottom sheet) | HÀNH ĐỘNG | STORY-002 (+ STORY-007 thêm danh mục) | Trong luồng "chuẩn bị" của thẻ *Đã hẹn ngày*; STORY-007 gọi lại từ khối "Cảm ơn" |

Mở rộng không phải màn thứ 12: khối "Trước giờ đi" (STORY-006) và "Cảm ơn +
chốt việc kế tiếp" (STORY-007) là khối trong chi tiết thẻ ở màn (1). Widget +
pha + bộ đếm (STORY-012) và lối ra/quay lại (STORY-013) là trạng thái đặc biệt
của màn (1) + bề mặt widget OS.

## 1. Component dùng chung — owner vs consumer

| Component / hợp đồng | Owner (thiết kế chuẩn) | Consumer (chỉ tiêu thụ, không tự vẽ lại) |
|---|---|---|
| Mô hình thẻ hoạt động (card) + 4 ngăn trạng thái + action-tier | STORY-001 | 002,004,005,006,007,008,009,010,011,012,013 |
| Dải lối-vào-nhanh 3 ô (Home) | STORY-001 (khung layout) | STORY-004/005/011 (nội dung ô) |
| Bottom sheet renderer khung nhại + mad-libs (đa danh mục) | STORY-002 | STORY-007 (chỉ thêm danh mục preset, không sửa renderer) |
| Điểm nhận nội dung nhật ký (tạo mục từ nguồn ngoài) | STORY-003 | STORY-007, STORY-008 |
| Kho ngữ cảnh (Sổ tay + Hồ sơ kỹ năng) + cơ chế hỏi-tại-chỗ (1 câu/lần) | STORY-004 | STORY-005, STORY-008, STORY-009, STORY-010 |
| Menu nhóm `_MenuRow` trên tab "Tôi" | có sẵn (`me_screen.dart`) | STORY-003, STORY-004 (thêm 3 hàng) |
| Nhãn xuất xứ "dựa trên những gì BẠN nhập" | STORY-009 | STORY-010 nên dùng cùng vị trí/kiểu nhãn khi hiển thị dữ liệu tự nhập |

## 2. Quy ước điều hướng
Xem mục 0. Ghi thêm: không màn nào trong 3 màn khoá-vị-trí được gán route đặt
tên có thể gõ tay/deep-link trực tiếp tới UI thường trực (SC-6/R-13) — chi
tiết kỹ thuật route để Tech Lead quyết, nhưng ràng buộc UX là "không có ô nhấn
nào trong menu/tab dẫn thẳng tới nó".

## 3. Quy ước trạng thái rỗng
- **Kho chung (màn 1), lần đầu tuyệt đối rỗng** — mẫu "Phút 1": KHÔNG form,
  đúng 2 lời mời một chạm ("dán 1 link" / "để app gợi ý theo dịp"), chọn 1 ra
  thẻ trong ≤60 giây. Đây là mẫu **duy nhất** được phép có ngôn ngữ mời gọi chủ
  động kiểu này.
- **Kho chung, một ngăn cụ thể rỗng** (ví dụ ngăn "Đã đi rồi" rỗng dù kho có
  thẻ ở ngăn khác) — trung tính, không lặp lại mẫu Phút-1, chỉ một dòng mô tả
  + lối quay về ngăn "Mới nghĩ ra".
- **Sổ tay / Hồ sơ kỹ năng, lần đầu** — trung tính tuyệt đối: danh sách rỗng +
  nút "+ tự thêm", KHÔNG mời gọi, KHÔNG wizard (SC-3). Rỗng là hành vi đúng,
  không phải lỗi.
- **Nhật ký, lần đầu** — trung tính, có đúng 1 CTA "Viết đầu tiên", KHÔNG mục
  tiêu viết hằng ngày, KHÔNG streak.
- Quy tắc chung: chỉ màn (1) lúc tuyệt-đối-rỗng được dùng giọng "mời gọi hành
  động ngay"; mọi trạng thái rỗng khác đều trung tính, không thúc giục.

## 4. Quy ước phân tầng hành động (SC-4 hai tầng — luật đo được)

Tiền lệ PO đã chốt: hành động chính ở CẤP THẺ giữ nguyên; hành động của khối
mở rộng (STORY-006/007) nằm lồng bên trong, tầng thị giác thấp hơn rõ rệt.
Luật đo được, áp dụng cho MỌI hành động phụ/khối lồng trong toàn REQ-016:

| Thuộc tính | Hành động chính (SC-4) | Hành động phụ / khối lồng |
|---|---|---|
| Kiểu nút | Pill đặc, nền `--pink`/`--grad`, bán kính `--r-btn` | Text button hoặc outline chip, không nền đặc |
| Trọng lượng chữ | 600 (semibold), cỡ body 17pt | 400 (regular), cỡ caption 13pt hoặc body 17pt không in đậm |
| Vị trí | Footer thẻ / vị trí hành động chính đã khoá | Lồng **bên trong** một khối con (bo góc `--r-sm` 16px, nền tách lớp/desaturated), luôn nằm **dưới** hành động chính |
| Thụt lề | Không thụt, full-width hoặc trailing | Thụt trái tối thiểu `md` (16px) so với mép khối con |
| Vùng chạm | ≥44pt (iOS) / ≥48dp (Android), giữ nguyên | Vẫn ≥44/48pt (không giảm khả năng bấm), nhưng diện tích thị giác nhỏ hơn |

Áp dụng cụ thể: khối "Trước giờ đi" (STORY-006) và khối "Cảm ơn + chốt việc kế
tiếp" (STORY-007) đều là khối con lồng trong chi tiết thẻ *Đã hẹn ngày*/*Đã đi
rồi*; nút "Xong hết rồi, đi thôi" và các gợi ý "chốt việc kế tiếp" dùng cột
"hành động phụ" ở bảng trên — không được vẽ giống hệt nút hành động chính của
thẻ.

## 5. Token / pattern lấy từ System UX Memory
- Bán kính: `--r-card` 26/24px (thẻ hoạt động), `--r-sheet` 28px (bottom sheet
  STORY-002), `--r-sm` 16px (khối con lồng, chip).
- Nút: `--r-btn` 999px (pill) cho mọi hành động chính.
- Màu: `--pink`/`--grad` cho hành động chính và CTA Phút-1; `--mint`/`--green`
  cho trạng thái tích cực/đã xác nhận (ví dụ "đã trả lời"); `--red` chỉ cho
  hành động phá huỷ (xoá thẻ, xoá nhật ký) ở bước xác nhận, KHÔNG dùng để gợi ý
  kịch tính hoá từ chối (R-1c cấm tông màu báo động cho luồng từ chối).
- Type scale: Card title 22pt/600; Body 17pt; Caption 13pt cho mốc thời gian,
  nhãn xuất xứ, mọi hành động phụ.
- Spacing: lưới 8pt (`xs 4 / sm 8 / md 16 / lg 24 / xl 32`).
- Icon: Material Symbols Rounded, biến thể "line"/"soft" cho hành động phụ và
  trạng thái rỗng (không dùng biến thể "filled" đậm cho hành động phụ, để giữ
  đúng "tầng thị giác thấp hơn rõ rệt" ở mục 4).
- **Khoảng trống trong system memory (đề xuất bổ sung ở mục 7):** chưa có
  component "segmented filter 4 ngăn" và chưa có "adaptive bottom sheet"
  built-sẵn trong `mobile/lib/design_system/` dù bảng thích ứng nền tảng đã
  gợi ý "adaptive bottom-sheet/dialog chrome" là một trong 4 widget thích ứng
  khả dĩ — REQ-016 là requirement đầu tiên hiện thực hoá nó.

## 6. Mâu thuẫn phát hiện giữa artifact
Không phát hiện mâu thuẫn prose-vs-artifact nào trong batch RUN 1 (khác với
tiền lệ STORY-006/012 mà scrum-master đã tự sửa trước khi giao). Toàn bộ 4
story_master.md + story_brief tương ứng khớp với `requirements/requirements.md`
tương ứng của từng story.

## 7. Đề xuất cập nhật System UX Memory (chờ RUN cuối)
1. Thêm mục "Solo stage-1 shell branching": tab Nhà phân nhánh `isPaired`,
   nhánh solo neo vào STORY-001; ghi lại dải lối-vào-nhanh 3 ô làm pattern điều
   hướng chuẩn cho "cửa vào có giới hạn cố định, không phải kho".
2. Thêm component mới vào catalog: "4-segment filter control" (dùng cho ngăn
   lọc màn 1) và "adaptive bottom sheet chrome" (dùng cho STORY-002) — cả hai
   chưa tồn tại trong `mobile/lib/design_system/` tính tới thời điểm khảo sát.
3. Thêm quy ước "action-tier hai tầng" ở mục 4 vào catalog pattern dùng chung
   (không chỉ riêng REQ-016) vì đây là giải pháp tái dùng cho mọi thẻ có hành
   động chính + khối mở rộng trong tương lai.
4. Ghi nhận "nhãn xuất xứ dữ liệu tự nhập" (STORY-009) như một pattern content
   trust label tái dùng được cho mọi màn suy luận trên dữ liệu người dùng tự
   nhập.
5. **[RUN 2]** Thêm pattern "khu vực lựa chọn lồng trong chi tiết" — khi một
   hành động chính cấp thẻ (SC-4) cần dẫn tới nhiều lựa chọn phụ (STORY-002 +
   STORY-006 + STORY-008 cùng sống trong "khu vực Chuẩn bị" của thẻ *Đã hẹn
   ngày*; STORY-007 sống trong "chế độ ghi ký ức" của thẻ *Đã đi rồi*), giải
   pháp chuẩn là một danh sách hàng gọn (chip/text-button) lồng **bên trong**
   chi tiết thẻ full-screen, không phải bottom sheet thứ hai hay route mới —
   tránh nhân bản destination cho mỗi hành động phụ. Xem
   `STORY-006/ux/uiux-spec.md` mục 1-2 và `STORY-007/ux/uiux-spec.md` mục 1
   để lấy định nghĩa đầy đủ (container `--r-sm`, thụt `md`, thứ tự cố định).
6. **[RUN 2]** Ghi nhận segmented control (do STORY-001 định nghĩa cho 4 ngăn
   lọc) là một **style tái dùng theo số đoạn tuỳ ngữ cảnh**, không khoá cứng
   ở 4 đoạn — STORY-008 dùng lại đúng token với 3 đoạn ("Trước/Trong/Sau").
   Khi hệ thống hoá vào catalog, đặt tên component là "segmented control"
   chung, tham số hoá theo số đoạn, thay vì "segmented filter 4 ngăn" cố định.
7. **[RUN 2]** Ghi nhận pattern "xác nhận nhẹ không chặn": khi một hành động
   tạo dữ liệu mới (tạo thẻ từ gợi ý) không cần rủi ro cao, dùng **tạo ngay +
   snackbar hoàn tác 5 giây** thay cho hộp thoại xác nhận chặn — áp dụng ở
   STORY-007 phần "chốt việc kế tiếp" và có thể tái dùng cho mọi luồng tạo
   thẻ nhanh khác trong REQ-016.
8. **[RUN 3]** Ghi nhận pattern "DẢI = chip nhãn văn bản tĩnh, không phải một
   điểm trên thang": khi hệ thống cần biểu diễn một chỉ số định tính từ một
   tập nhãn đóng mà KHÔNG được ngụ ý một vị trí đo được trên một trục liên
   tục (D-14 và mọi luật "hiển thị dải, không %" tương lai), component chuẩn
   là một pill/chip tĩnh chứa đúng một nhãn văn bản — cấm progress bar,
   vòng tròn %, dải màu gradient theo mức, số sao. Xem
   `STORY-010/ux/uiux-spec.md` mục 3.1 để lấy định nghĩa đầy đủ.
9. **[RUN 3]** Ghi nhận pattern "khối đối xứng thị giác thuận lợi/cọ xát":
   khi một kết quả bắt buộc có cả mặt tích cực và mặt cần lưu ý (ví dụ luật
   "mỗi ô tra phải có điểm cọ xát"), hai khối phải dùng ĐÚNG HỆT container,
   cỡ chữ, độ đậm tiêu đề — chỉ khác icon — để không khối nào bị đọc là "phụ"
   qua thứ tự thị giác. Luật nghiệm thu: che tiêu đề, người xem không đoán
   được khối nào là "điểm mạnh" khối nào là "điểm cọ xát" chỉ qua kiểu chữ.
   Xem `STORY-010/ux/uiux-spec.md` mục 3.2-3.3.
10. **[RUN 3]** Ghi nhận pattern "nhãn xuất xứ sticky": khi một màn hiển thị
    nội dung suy luận trên dữ liệu người dùng tự nhập (không phải sự thật đã
    xác nhận), nhãn xuất xứ ("dựa trên những gì bạn đã nhập") phải ghim lại
    khi cuộn (sticky header phụ dưới app bar), không cuộn mất theo nội dung.
    Owner: STORY-009 (`ux/uiux-spec.md` mục 3.1-3.2); STORY-010 tái dùng.
