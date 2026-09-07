# UX Spec: STORY-006 "Trước giờ đi" — checklist tất định (SB-211)

Requirement: REQ-016 · Story-Class: standard · Depends On: STORY-001
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md` mục 4 (bảng action-tier hai tầng — BẮT BUỘC),
`STORY-001/ux/uiux-spec.md` mục 5 (chi tiết thẻ), `STORY-002/ux/uiux-spec.md`
mục 1 (đặt tên "luồng Chuẩn bị"). `DESIGN_SOURCE_NOT_DETECTED` bình thường ở
giai đoạn này — spec dùng luật đo được.

## 1. Vị trí — khu vực "Chuẩn bị" trong chi tiết thẻ

STORY-002 đã đặt tên: bấm hành động chính cấp thẻ "Chuẩn bị" (thẻ *Đã hẹn
ngày*) mở ra **khu vực Chuẩn bị** — một danh sách lựa chọn sống **bên trong**
chi tiết thẻ full-screen (STORY-001 mục 5), không phải bottom sheet, không
phải route riêng. Khu vực Chuẩn bị là nơi STORY-002 ("Xuất lời mời"),
STORY-008 ("Kịch bản buổi hẹn") và story này ("Trước giờ đi") cùng sống, tất
cả ở tầng thị giác **hành động phụ** theo bảng action-tier ở mục 4 survey
(không nền `--grad`/pill đặc, không cùng cấp thị giác với "Chuẩn bị").

**Thứ tự cố định trong khu vực Chuẩn bị** (trên xuống dưới, theo trình tự thời
gian dùng trong đời thực của một buổi hẹn):

| # | Mục | Story | Hiện khi nào |
|---|---|---|---|
| 1 | Xuất lời mời | STORY-002 | Luôn hiện |
| 2 | Kịch bản buổi hẹn | STORY-008 | Luôn hiện |
| 3 | Trước giờ đi | Story này | **Chỉ** khi ngày hẹn = hôm nay (AC-1/AC-2) |

Mục 1 và 2 là hàng chip/text-button gọn (một dòng, chạm để mở). Mục 3 khác
biệt: khi điều kiện đúng, nó **mở sẵn tự động** ở dạng khối nội dung đầy đủ
(không phải một hàng chờ bấm) — đây là điểm khác duy nhất giữa nó và hai mục
kia, đúng AC-1. Khi điều kiện sai, mục 3 **không tồn tại** trong danh sách —
không hàng xám, không hàng khoá (AC-2/AC-3), và nó cũng không xuất hiện ở bất
kỳ menu/tab nào khác (AC-6).

## 2. Bố cục khối "Trước giờ đi" khi mở

Khối là một **khối con lồng** đúng bảng action-tier: bo góc `--r-sm` (16px),
nền tách lớp/desaturated so với nền chi tiết thẻ, thụt trái `md` (16px) so
với mép khu vực Chuẩn bị.

1. Tiêu đề khối: "Trước giờ đi" (`body 17pt/600` — đậm hơn dòng bên trong để
   phân biệt tiêu đề khối với nội dung, nhưng vẫn nhỏ hơn/nhẹ hơn tiêu đề thẻ
   `22pt/600`).
2. Danh sách dòng gợi ý — **chỉ hiện dòng có trường thật khớp** (AC-9):

   | Dòng | Icon (Material Symbols, biến thể line) |
   |---|---|
   | "Mang đủ tiền mặt" | `payments` |
   | "Đổ xăng / sạc xe trước khi đi" | `ev_station` |
   | "Mang áo mưa/ô, có phương án B trong nhà" | `umbrella` |
   | "Xác nhận lại chỗ đã đặt" | `event_available` |
   | "Chia sẻ vị trí" | `share_location` |

   Mỗi dòng: icon leading + nhãn `body 17pt/400`, chiều cao dòng tối thiểu
   40px. Các dòng **không có checkbox, không đánh dấu đã-làm** — đây là danh
   sách đọc để nhớ, không phải to-do có trạng thái tích lũy (tránh mọi hình
   thức đếm hoàn thành, AC-27). Riêng dòng "Chia sẻ vị trí" có thêm một text
   button trailing nhãn "Chia sẻ" (`caption 13pt`, không nền) — bấm mở OS
   Share Sheet một lần (AC-18); các dòng còn lại không tương tác.
3. Nếu thẻ thưa trường, khối chỉ còn dòng "Chia sẻ vị trí" hoặc rỗng hoàn
   toàn — **đây là kết quả hợp lệ** (AC-12): không hiện thông điệp "thẻ của
   bạn còn thiếu thông tin", không CTA đi điền thêm trường (AC-13). Nếu khối
   rỗng hoàn toàn, toàn bộ khối con (kể cả tiêu đề) **ẩn hẳn**, không để lại
   khung/viền rỗng gây hiểu nhầm là lỗi tải (AC-14).
4. Hành động chính **của khối** (không phải của thẻ): pill nhỏ, viền/outline
   (không nền `--grad` đặc — đúng tầng "hành động phụ"), nhãn "Xong hết rồi,
   đi thôi", nằm cuối khối, thụt lề như các dòng khác. Bấm → khối đóng lại
   ngay, không hộp thoại xác nhận, không câu chúc mừng, không hỏi lại
   (AC-17).

## 3. Sau khi đóng khối

Sau khi bấm "Xong hết rồi, đi thôi", mục "Trước giờ đi" trong khu vực Chuẩn
bị co lại thành **một hàng gọn một dòng**: nhãn mờ hơn "Trước giờ đi ✓" +
text button trailing "Mở lại" (`caption 13pt`) — bấm mở lại toàn bộ nội dung
mục 2 cho **cùng ngày đó** (AC-16, SC-5 không ngõ cụt). Hàng gọn này **không**
dùng dấu tick màu `--mint`/`--green` kiểu "đã hoàn thành nhiệm vụ" để tránh
gợi liên tưởng gamification — dùng icon line `check` màu trung tính.

## 4. Đồng cư với STORY-002 trong khu vực Chuẩn bị

Khối "Trước giờ đi" (mở sẵn, chiếm nhiều không gian nhất khi có nội dung) đặt
**dưới cùng** trong khu vực Chuẩn bị, sau hai mục gọn "Xuất lời mời"/"Kịch
bản buổi hẹn" — lý do: hai mục kia dùng ở giai đoạn "trước khi chốt/trước khi
đi", còn checklist dùng đúng ngày đi, nên đọc từ trên xuống đúng trình tự thời
gian thực tế. Việc mở khối "Trước giờ đi" **không** thay đổi vị trí hay ẩn hai
mục kia — cả ba luôn cùng hiện trong khu vực Chuẩn bị khi điều kiện của chúng
đúng.

## 5. Ngoại tuyến, tất định, ranh giới đạo đức

- Toàn bộ nội dung khối sinh tất định từ trường thẻ + bảng tra tĩnh — không
  skeleton chờ mạng, không banner lỗi mạng (AC-22).
- Không phần tử nào ngụ ý đang gọi AI hay dịch vụ ngoài (không spinner sinh
  nội dung, không nhãn "gợi ý bởi AI") — R-7, AC-23.
- Hành động "Chia sẻ vị trí" không để lại lịch sử hiển thị (không có mục "đã
  chia sẻ lúc mấy giờ" ở bất kỳ đâu trong UI) — AC-19/AC-20, ranh giới R-1b:
  đây là an toàn của chính người dùng, không phải giám sát người kia.
- Bỏ qua dòng "Chia sẻ vị trí" không sinh hệ quả thị giác nào (không icon
  cảnh báo, không nhắc lại) — AC-21.

## 6. Trách nhiệm bàn giao

- Trạng thái pha "trước giờ đi" (mở/đã đóng cho thẻ) là dữ liệu STORY-012 đọc
  để vẽ widget; spec này **không** vẽ bất kỳ bề mặt widget OS nào (BR-11).
- Không đổi 4 nhãn hành động chính cấp thẻ hay mô hình thẻ của STORY-001; khu
  vực Chuẩn bị chỉ thêm bên trong luồng đã khoá.

## Completion

Không có OQ nào chặn phạm vi UX của story này — bảng tra là nhãn chức năng,
không phải nội dung có giọng điệu, nên không thuộc phạm vi nội dung của R-15
(đối chiếu `requirements.md` → `## Open Question Impact`: NONE bị chặn). Spec
trên là đầy đủ.
