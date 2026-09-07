# UX Spec: STORY-008 Kịch bản buổi hẹn 3 phần — màn (9), KHOÁ VỊ TRÍ

Requirement: REQ-016 · Story-Class: standard
Depends On: STORY-001, STORY-002, STORY-003, STORY-004
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md` mục 0/2 (khoá vị trí) và mục 4 (action-tier),
`STORY-001/ux/uiux-spec.md` mục 3 (segmented control — style tái dùng) và
mục 5, `STORY-002/ux/uiux-spec.md` (renderer, mục 6 điểm quay về theo ngữ
cảnh), `STORY-006/ux/uiux-spec.md` mục 1 (thứ tự khu vực Chuẩn bị).
`DESIGN_SOURCE_NOT_DETECTED` bình thường ở giai đoạn này — spec dùng luật đo
được.

## 1. Cửa vào duy nhất — mục 2 trong khu vực Chuẩn bị

Theo thứ tự đã khoá ở `STORY-006/ux/uiux-spec.md` mục 1, "Kịch bản buổi hẹn"
là **mục thứ 2** trong khu vực Chuẩn bị của thẻ *Đã hẹn ngày* (sau "Xuất lời
mời", trước "Trước giờ đi"), trình bày như một hàng chip/text-button gọn.
Bấm hàng này **push** một destination full-screen mới — màn (9) — chồng lên
trên chi tiết thẻ (có nút quay lại về khu vực Chuẩn bị).

**Không có lối vào nào khác.** Màn (9) không có mục ở tab bar, không có mục
ở bất kỳ menu nào (tab "Tôi", tab "Nhà"), và **không nhận route/deep-link
trực tiếp** — mở màn (9) khi thiếu ngữ cảnh thẻ nguồn phải quay ngay về màn
(1), không hiển thị nội dung rỗng chờ ngữ cảnh (AC-4/AC-5 story requirements,
BR-1/BR-1a). Trên chính màn (9): **không có** nút share/copy-link/"gửi màn
này cho ai đó" ở bất kỳ đâu — mọi affordance kiểu đó tạo ra một cửa ngách
tương đương deep-link, vi phạm SC-6 dù kỹ thuật route vẫn khoá đúng.

## 2. Bố cục màn, từ trên xuống

1. Header: nút quay lại (về khu vực Chuẩn bị của thẻ) + tiêu đề "Kịch bản
   buổi hẹn" (`card title 22pt/600`).
2. **Segmented control 3 phần** — tái dùng đúng **style thị giác** của
   segmented filter 4 ngăn do STORY-001 định nghĩa (mục 3 spec STORY-001:
   pill group, chọn-một), nhưng ở đây chỉ có **3 đoạn cố định**: "Trước" /
   "Trong" / "Sau". Đây **không phải** một biến thể component thứ hai — cùng
   token màu/bo góc/kiểu chip, khác duy nhất là số đoạn.
3. **Vùng nội dung** bên dưới, đổi theo đoạn đang chọn:
   - Đoạn "Trước": đoạn văn preset 2-4 câu (`body 17pt`), mad-libs điền từ
     loại hoạt động/địa điểm/thời lượng của thẻ + sổ tay.
   - Đoạn "Trong": **có một dòng caption cố định ở đầu nội dung**, trước cả
     đoạn văn: "Đọc trước khi đi — không phải nhắc trong lúc hẹn" (`caption
     13pt`, màu `colorTextMuted`, icon `menu_book` line đứng trước). Dòng
     này là **bắt buộc, không được lược bỏ** — nó là hàng rào thị giác chống
     lấn J7 (BR-3). Bên dưới là đoạn văn preset cùng kiểu đoạn "Trước".
   - Đoạn "Sau": đoạn văn preset cùng kiểu, không cần caption đặc biệt (đây
     là chữ đọc sau khi về, không có rủi ro bị hiểu nhầm là đồng hành realtime).
   - Không đoạn nào có nút hẹn giờ, đồng hồ đếm ngược, hay bất kỳ điều khiển
     thời gian nào (đối chiếu AC-14/AC-15 — J7 để trống là chủ ý).
4. **Ô hỏi tại chỗ** (chỉ hiện khi kịch bản cần một trường sổ tay chưa có,
   AC-24): nằm ngay dưới vùng nội dung của đoạn đang xem, dùng nguyên cơ chế
   hỏi-tại-chỗ của STORY-004 (một câu, có nút "Bỏ qua" cùng hàng, bỏ qua
   không chặn nội dung — AC-25).
5. **Sticky footer — ba cửa ra bắt buộc** (SC-2), cố định ở đáy màn, luôn
   hiện bất kể đang cuộn ở đoạn nào hay cuộn tới đâu trong nội dung:
   - Ba nút chiều rộng bằng nhau, xếp hàng ngang (xếp dọc nếu màn quá hẹp),
     kiểu **pill viền/outline** (không nền `--grad` đặc — dành riêng cho hành
     động chính cấp thẻ, để không tạo cảm giác đây là "hành động chính của
     thẻ" thứ hai): "Xuất lời mời" · "Tạo thẻ mới" · "Ghi vào nhật ký".

## 3. Hành vi ba cửa ra

- **Xuất lời mời**: mở đúng bottom sheet renderer STORY-002 (danh mục "lời
  mời"), chồng lên trên màn (9). Đóng sheet → quay lại **màn (9)** (không
  phải chi tiết thẻ) — ngữ cảnh mở sheet là từ màn (9) nên đó là điểm quay
  về, theo đúng nguyên tắc mục 6 của spec STORY-002. Sau khi hoàn tất chia
  sẻ, màn (9) **tự đóng**, trả người dùng về khu vực Chuẩn bị của thẻ (BR-6 —
  màn (9) không phải điểm dừng chân).
- **Tạo thẻ mới**: bấm → một form ngắn xuất hiện tại chỗ (không phải màn mới)
  để xác nhận tiêu đề/ngày gợi ý (điền sẵn nếu có), nút "Tạo" xác nhận → thẻ
  mới vào màn (1) trạng thái *Mới nghĩ ra* + snackbar "Đã tạo thẻ mới trong
  kho hoạt động — Xem". Sau xác nhận, màn (9) **tự đóng**, trả về khu vực
  Chuẩn bị.
- **Ghi vào nhật ký**: mở màn/composer tạo mục nhật ký của STORY-003, đã gắn
  sẵn ngữ cảnh thẻ nguồn (AC-4 story-master). Sau khi lưu, màn (9) **tự
  đóng**, trả về khu vực Chuẩn bị.
- **Không chọn cửa ra nào**: người dùng dùng nút quay lại/gesture back để rời
  màn (9) bất kỳ lúc nào — không hộp thoại "bạn có chắc muốn rời đi", không
  bị ép chọn một trong ba cửa trước khi thoát (AC-21 story requirements).

## 4. Ngoại tuyến, tất định, ranh giới đạo đức

- Toàn bộ nội dung ba phần hoạt động không mạng (AC-11) — không skeleton chờ
  mạng.
- Không phần tử nào ngụ ý AI đang soạn hay đang "cá nhân hoá" theo thời gian
  thực (không spinner, không nhãn "AI gợi ý") — R-7, AC-12.
- Không nơi nào trên màn có cơ chế A/B, không có nhãn "kịch bản hiệu quả
  hơn", không chấm điểm buổi hẹn hay phản ứng người kia (AC-28).
- Nội dung nói về người kia kết thúc bằng câu hỏi (R-1g) là trách nhiệm nội
  dung (R-15); UI không cắt câu theo cách làm mất câu hỏi kết ở cuối đoạn.
- Không streak, không đếm số lần mở màn (9), không phần nào sau paywall
  (AC-22 story requirements liên quan R-1/R-14).

## 5. Trách nhiệm bàn giao

- Ba cửa ra dùng đúng hạ tầng STORY-001/002/003 đã giao; spec này không vẽ
  bản sao rút gọn của bất kỳ luồng nào trong số đó.
- STORY-009 (Chân dung) và STORY-010 (Bảng tra ăn khớp) sẽ **thêm** liên kết
  khoá-vị-trí đi ra từ màn (9) sau này (ví dụ một chip nữa trong vùng nội
  dung hoặc footer) — spec này không xây hai đích đó, chỉ để chỗ: vùng nội
  dung mỗi đoạn cho phép chèn thêm một dòng liên kết phụ ở cuối đoạn văn khi
  hai story đó tới lượt giao, không đổi cấu trúc segmented control hay
  sticky footer ba cửa ra.

## Completion

Điều kiện ship nội dung kho kịch bản ba phần vào bản build người dùng thật
nay là R-15: qua cổng nhập nội dung chạy được (R-15c) và có truy vết duyệt
qua id bền; không chặn màn, điều hướng khoá vị trí, ba cửa ra, hay cơ chế
hỏi-tại-chỗ ở trên (đối chiếu `requirements.md` → `## Open Question Impact`).
Spec trên đủ để build và verify bằng nội dung placeholder nội bộ.
