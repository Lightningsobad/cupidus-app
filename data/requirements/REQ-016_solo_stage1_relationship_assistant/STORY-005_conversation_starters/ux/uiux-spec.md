# UX Spec: STORY-005 Mồi chuyện — kho câu thường xanh và sự kiện có lịch

Requirement: REQ-016 · Story-Class: standard · Depends On: STORY-001, STORY-004
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md`. `DESIGN_SOURCE_NOT_DETECTED` bình thường ở
giai đoạn này — spec dùng luật đo được, không tham chiếu ảnh render.

## 1. Vị trí và cách mở

Màn (6), nhóm CỬA VÀO. Mở từ ô thứ 2 trong dải lối-vào-nhanh 3 ô trên đầu tab
Nhà (khung do STORY-001 sở hữu). Là một destination riêng (push full-screen,
có nút quay lại về tab Nhà), **không phải** bottom sheet.

## 2. Bố cục màn, từ trên xuống

1. Header: nút quay lại + tiêu đề "Mồi chuyện" (`card title 22pt/600`).
2. **Khối Bản A — câu gợi chuyện** (luôn hiện, luôn có nội dung, AC-1), chia
   hai tầng hero/phụ theo canvas `6-moi-chuyen-a-a` (Design Ruling Log
   2026-09-20, mục 2/3/4 — "Neo thiết kế"):
   - Hiển thị đúng **3 câu** mỗi lượt (con số cố định — không phải danh sách
     cuộn dài): 1 câu hero + 2 câu phụ.
   - **Thẻ hero — tiêu đề "CÂU HÔM NAY"**: văn bản câu `body 17pt` (nổi bật hơn
     hai câu phụ) + nút đặc nền `--pink` nhãn "Chép để nhắn" (thay cho icon
     copy trần) — bấm → sao chép câu vào clipboard, hiện toast thoáng qua "Đã
     copy" (2 giây, tự biến mất, không phải hộp thoại chặn) — **không** tạo
     thẻ, đúng AC-2. Ngay cạnh nút đặc: một icon-button tròn dùng icon
     `refresh` (Material Symbols, biến thể line, vùng chạm ≥44pt/48dp) đảm
     nhiệm hành vi "Xem câu khác" trước đây (xem gạch dưới). Dưới thẻ hero:
     một dòng caption trấn an "Câu này nhắn liền, không cần lưu…" (`caption
     13pt`).
   - **Khối phụ — tiêu đề "CÙNG CHỦ ĐỀ"**: danh sách 2 câu còn lại, mỗi câu vẫn
     là một dòng độc lập: văn bản `body 17pt` bên trái + nút icon "copy"
     (Material Symbols `content_copy`, biến thể line) bên phải, vùng chạm
     ≥44pt/48dp, hành vi copy giống hệt thẻ hero, đúng AC-2 (canvas không vẽ
     nút copy ở đây nhưng giữ lại theo quyết định P5 — không phải khoảng hụt
     fidelity).
   - Bấm icon `refresh` ở thẻ hero → thay cả bộ 3 câu (hero + phụ) bằng 3 câu
     kế tiếp trong kho, theo **thứ tự cố định** (không ngẫu nhiên) được tính
     tất định từ (ngày hiện tại, sổ tay, vị trí đã xem trong phiên) — đúng
     AC-17 tất định. **Hết vòng kho** (đã xem hết mọi bộ) → bộ tiếp theo là
     **quay lại bộ đầu tiên**, không hiện thông báo "đã hết", không có màn
     hình ngõ cụt (AC-4/SC-5).
   - Màn này **không** giữ danh sách "câu đã copy"/"đã lưu"/"yêu thích" ở bất
     kỳ đâu (AC-3, SC-1').
   - **Gói hiện tại có ít hơn 3 câu (N < 3, gói dữ liệu, không phải hằng số
     "3 câu mỗi lượt" ở trên — AC-28):** khối Bản A chỉ render đúng số câu có
     sẵn — câu đầu tiên luôn là thẻ hero "CÂU HÔM NAY"; nếu N=2 chỉ có 1 câu
     phụ dưới "CÙNG CHỦ ĐỀ"; nếu N=1 khối "CÙNG CHỦ ĐỀ" không hiện. **Không**
     chèn ô trống/khung giữ chỗ cho đủ 3, không báo lỗi, không đổi chiều cao
     khối theo cách gây giật hình. Icon `refresh` vẫn hoạt động bình thường,
     chuyển tất định sang gói kế tiếp theo đúng thứ tự.
3. **Ô hỏi tại chỗ** (chỉ hiện khi sổ tay còn thiếu dữ liệu liên quan, AC-6):
   nằm ngay dưới khối Bản A, dùng **nguyên cơ chế hỏi-tại-chỗ của STORY-004**
   — một chip câu hỏi + ô trả lời ngắn, có nút "Bỏ qua" cùng hàng. Bỏ qua
   không chặn nội dung phía trên hay phía dưới (AC-7). Trả lời → lưu thẳng
   vào kho sổ tay/kỹ năng của STORY-004 (AC-8) — màn này không có kho ngữ
   cảnh riêng, không có luồng điền-trước/onboarding (AC-9).
4. **Divider mảnh** (`--r-sm` spacing, không phải đường kẻ nặng).
5. **Khối Bản A+ — "CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC"**: tiêu đề phụ "CÓ LỊCH SẴN · RỦ
   ĐI ĐƯỢC" (`body 17pt/600`, đổi tên theo Design Ruling Log 2026-09-20 mục
   5 — "Neo thiết kế") + danh sách dọc các mục sự kiện, mỗi mục là một hàng:
   - Giữa: tên sự kiện gộp sẵn ngày theo lối "thứ Bảy 16/08" (`body 17pt`), ví
     dụ "Phim X ra rạp — thứ Bảy 16/08". **Không** badge ngày riêng ở leading
     (bỏ theo Design Ruling Log 2026-09-20 mục 6b — canvas viết ngày lẫn trong
     tên sự kiện, không tách badge dd/mm).
   - Trailing: nút pill nhỏ (chiều cao 44pt, không full-width) nền `--pink`,
     nhãn "Thêm vào Muốn làm" — bấm → tạo thẻ mới ở màn (1) trạng thái *Mới
     nghĩ ra*, mang sẵn ngày sự kiện (AC-11 story-master).
   - Ngay cạnh trailing action, một icon-button "bỏ qua" (Material Symbols
     `close`, biến thể line, ≥44pt) — bấm xoá khỏi danh sách ngay, **không**
     hộp thoại xác nhận, không hỏi lý do (AC-14).
   - Sự kiện **đã qua ngày** không xuất hiện trong danh sách nữa (âm thầm rời
     khỏi kho hiển thị, không xám, không nhắc "đã lỡ") — AC-13.
6. Sau khi một sự kiện được "Thêm vào Muốn làm": mục đó **biến mất khỏi danh
   sách này** ngay (không giữ bản sao ở đây — SC-1'/AC-12); nơi duy nhất còn
   chứa nó là kho chung màn (1).

## 3. Trạng thái rỗng

- Khối "Sự kiện có lịch" hết mục (đã thêm hết/bỏ qua hết/không còn sự kiện sắp
  tới) → một dòng trung tính "Chưa có sự kiện nào sắp tới" thay cho danh
  sách, **không** mời gọi hành động, không lặp mẫu Phút-1 (đúng mục 3 survey
  — chỉ màn (1) tuyệt-đối-rỗng được dùng giọng mời gọi).
- Khối Bản A **không bao giờ** rỗng (luôn có 3 câu mặc định kể cả sổ tay
  trống, BR-5).

## 4. Ngoại tuyến và tất định

Toàn bộ nội dung màn này (câu mồi, danh sách sự kiện, phép tính lịch âm) là
gói dữ liệu tĩnh ship kèm app — không có trạng thái loading/skeleton chờ
mạng, không banner "không có mạng" (AC-15). Không phần tử nào trên màn ngụ ý
đang gọi dịch vụ ngoài hay đang tạo bằng AI (không spinner sinh nội dung,
không nhãn "AI gợi ý"/"đang tạo…") — R-7.

## 5. Ranh giới đạo đức thể hiện trong UI

- Không nơi nào trên màn hiển thị chỉ báo hành vi người kia — không "đã trả
  lời", không tần suất, không mốc "lần cuối nhắn" (AC-21, R-1b).
- Không streak, không đếm số câu đã dùng, không huy hiệu (AC-23).
- Nội dung mồi kết thúc bằng câu hỏi (R-1g) là trách nhiệm nội dung (R-15),
  không phải cấu trúc UI; UI không cắt/rút gọn câu theo cách làm mất câu hỏi
  kết ở cuối.

## 6. Trách nhiệm bàn giao

- Nút "Thêm vào kho" ở đây dùng đúng hợp đồng thẻ của STORY-001 (trạng thái
  *Mới nghĩ ra*, nguồn sinh); không tạo đường tạo thẻ thứ hai.
- Cơ chế hỏi-tại-chỗ tái dùng nguyên STORY-004, không vẽ biến thể mới.

## Completion

Điều kiện ship nội dung (câu mồi, tên sự kiện thật) vào bản build người dùng
thật nay là R-15: qua cổng nhập nội dung chạy được (R-15c) và có truy vết
duyệt qua id bền; không chặn cấu trúc màn ở trên (đối chiếu
`requirements.md` → `## Open Question Impact`). Spec trên đủ để build và
verify bằng nội dung placeholder nội bộ.
