# UX Spec: STORY-001 Ghi điều mới biết về người ấy vào sổ tay ngay trên màn check-in 23h

Requirement: REQ-017 · Story-Class: standard · Implementation Lane: mobile-only
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../requirements/requirements.md` (breakdown cấp requirement),
REQ-016 STORY-012 `ux/uiux-spec.md` mục 4 (màn check-in 23h),
REQ-016 STORY-004 `ux/uiux-spec.md` Phần A + Phần B (cơ chế hỏi-tại-chỗ, màn Sổ
tay). `DESIGN_SOURCE_NOT_DETECTED` bình thường ở đây — không có canvas riêng
cho khối hỏi mới; spec dùng luật đo được, neo vào hai màn đã có canvas
(`23h-vua-ve-j8`, `2-so-tay-nguoi-yeu`).

Không màn mới, không route mới (BR-9/O-3). Mọi mục dưới đây là phần thêm vào
hai màn sẵn có, không phải một đặc tả màn độc lập.

## 0. Hai bề mặt, một workflow

- Bề mặt 1 — khối hỏi phụ trên màn check-in 23h (canvas `23h-vua-ve-j8`, đã mô
  tả ở REQ-016 STORY-012 `ux/uiux-spec.md` mục 4). REQ-017 chèn thêm đúng một
  khối mới vào cuối luồng nhập của màn đó; không đổi tiêu đề lớn hai dòng, khối
  ngữ cảnh, lưới ba ô ảnh, ô nhập nhật ký, hai chip mô tả, hay dòng trấn an ở
  chân màn.
- Bề mặt 2 — mục mới trong màn Sổ tay người yêu (canvas `2-so-tay-nguoi-yeu`,
  đã mô tả ở REQ-016 STORY-004 `ux/uiux-spec.md` Phần B). REQ-017 chỉ thêm một
  nhãn xuất xứ trên hàng mục; không đổi header, hai nhóm cố định "Sở thích"/
  "Sự kiện", nút "+ tự thêm", hay trạng thái rỗng.
- Ghi chú vá canvas: chữ "+ ghi vào sổ tay" trên canvas `23h-vua-ve-j8` từng bị
  loại khỏi STORY-012 (AC-16 cũ chỉ lưu nhật ký) vì hành động thật cần xác nhận
  người dùng trước — nay đã xác nhận (`req_master.md` OQ-1, 2026-09-27). Từ
  đây, khối hỏi phụ ở mục 1 dưới là cách hiện thực hoá ý đó; nó **không** thay
  đổi phần thông báo 23h hay câu hỏi chính của màn ("về tới nhà chưa?"), cả hai
  vẫn hướng vào người dùng theo STORY-012 AC-19 (AC-1, BR-8).

## Phần A — Khối hỏi phụ trên màn check-in 23h

### 1. Vị trí và ranh giới thị giác (AC-1, AC-7, BR-8)

- Khối mới nằm **sau** lưới ba ô ảnh và ô nhập nhật ký, **trước** CTA chính cỡ
  lớn và dòng trấn an ở chân màn. Nó không bao giờ là thứ đầu tiên người dùng
  thấy khi mở màn.
- Một **đường phân cách mảnh** (divider, không phải card riêng che nền) ngăn
  khối này với phần nhật ký phía trên, đủ để mắt nhận ra đây là một khối khác,
  không phải phần tiếp theo của ô nhập nhật ký.
- Nhãn nhỏ "Tuỳ chọn" (`caption 13pt`, màu `--ghost`) đặt cạnh tiêu đề câu hỏi
  của khối — cùng vai trò với hai chip mô tả không chạm được ở STORY-012 mục 4,
  nhưng đây là chữ, không phải chip, để không bị hiểu nhầm là lựa chọn chạm được.
- Tiêu đề câu hỏi của khối dùng `body 17pt`, tối đa 1 câu, cùng cỡ chữ với ô
  nhập nhật ký phía trên — không dùng cỡ lớn hơn để khối phụ không lấn khối
  chính (AC-7).
- Hai chip mô tả sẵn có của STORY-012 AC-16 ("sẽ vào nhật ký", "chỉ người dùng
  đọc được") giữ nguyên vị trí ngay dưới ô nhập nhật ký và giữ nguyên nghĩa —
  chúng chỉ nói về câu nhật ký, không nói về khối mới (AC-7).

### 2. Nhập ý + chọn loại (AC-3, AC-16, AC-17, BR-1, BR-4)

- Một **ô nhập một dòng** (không phải nhiều dòng như ô nhật ký) — vì AC-17 chỉ
  xin một ý ngắn, không phải một đoạn văn. Giới hạn độ dài và luật hợp lệ nội
  dung giống hàng nhập "+ tự thêm" ở màn Sổ tay (STORY-004 Phần B).
- Ngay dưới ô nhập: một **segmented control 2 lựa chọn** "Sở thích" / "Sự
  kiện" — cùng component với segmented nhỏ trong hàng "+ tự thêm" của STORY-004
  Phần B, không phải dropdown, không phải radio list riêng.
  - Trạng thái khởi tạo: **không lựa chọn nào được tô sẵn** (AC-3) — component
    segmented phải hỗ trợ trạng thái "chưa chọn", khác trạng thái mặc định của
    STORY-004 nơi segmented luôn có một lựa chọn tô sẵn. Đây là điểm khác biệt
    duy nhất so với hàng "+ tự thêm" gốc.
  - Không có lựa chọn thứ ba, không có trường đánh giá/nhận xét/chấm điểm ở
    bất kỳ đâu trong khối này (AC-3, BR-1).
  - App không tự tô một lựa chọn dựa trên chữ đã gõ ở bất kỳ thời điểm nào,
    kể cả sau khi người dùng gõ xong (BR-4).
- Ô nhập chỉ chứa khoảng trắng được coi là để trống, cùng luật với AC-2
  (AC-17).
- Không có trường ngày, trường chi tiết, hay ô nhập thứ hai nào trong khối này
  (AC-17) — nếu người dùng cần thêm ngày/chi tiết cho mục "Sự kiện", họ làm ở
  màn Sổ tay bằng thao tác sửa sẵn có (BR-9).

### 3. Để trống khối (AC-2, AC-6, BR-2, BR-3)

- Ô nhập của khối này **luôn bắt đầu trống**, không bao giờ được điền sẵn từ
  câu nhật ký hay từ bất kỳ nguồn nào khác (AC-6, BR-3) — kể cả khi người dùng
  quay lại màn sau khi rời tạm thời trong cùng phiên (không có khái niệm nháp
  chia sẻ giữa hai ô).
- Nếu người dùng để trống khối này (ô nhập trống hoặc chỉ khoảng trắng) và lưu
  hoặc đóng check-in: không mục sổ tay nào được tạo, không thông báo lỗi,
  không câu nhắc kiểu "bạn quên điền", và lần check-in sau không hỏi lại về
  buổi hẹn này (AC-2, BR-2). Việc bỏ qua khối này hoàn toàn im lặng — không
  toast, không banner.

### 4. Gõ ý nhưng chưa chọn loại — hành vi lưu (AC-16, BR-10)

- Khi người dùng chạm CTA chính để lưu và ô nhập khối này có chữ (khác
  khoảng trắng) nhưng chưa chọn "Sở thích" hay "Sự kiện": app **không** tạo
  mục sổ tay, và **không** tự tô một lựa chọn để "cứu" ý đó (AC-16).
- Ảnh và câu nhật ký lưu ngay lập tức như bình thường; CTA vẫn hoàn tất phần
  đó, không bị treo chờ khối phụ (BR-10, tách lưu).
- Đồng thời, ngay dưới segmented control, hiện một dòng nhắc ngắn
  (`caption 13pt`, màu `--red`) kiểu "Chọn một loại để lưu, hoặc xoá ý này" —
  xuất hiện đúng lúc CTA bị chạm lần đó, không xuất hiện chủ động trước đó.
  Đây là cách "app cho họ chọn loại hoặc bỏ ý đó" (AC-16) mà không mở dialog
  chặn màn: người dùng có thể chọn một loại ngay tại chỗ (mục sổ tay được tạo
  ngay khi đó, không cần chạm CTA lần hai) hoặc xoá chữ đã gõ (dòng nhắc biến
  mất, màn coi như mục 3 ở trên).
- Nếu người dùng rời màn mà không giải quyết dòng nhắc này (đóng check-in),
  màn không mở lại được (ngoài phạm vi) nên ý gõ dở mất — chấp nhận được vì
  ảnh/nhật ký không mất và người dùng đã được báo rõ ràng, không âm thầm.

## Phần B — Lưu, lỗi, trùng lặp (AC-8, AC-12, BR-10, BR-12)

- CTA chính chuyển sang trạng thái đang xử lý ngắn (label mờ đi hoặc spinner
  nhỏ trong nút, cùng vật liệu pill sẵn có của STORY-012 mục 4) ngay khi chạm
  lần đầu, và vô hiệu hoá chạm tiếp cho tới khi xử lý xong — chạm lặp lại hay
  chạm hai lần không được tạo mục sổ tay thứ hai (AC-8).
- Nếu riêng phần ghi sổ tay lỗi (ảnh/nhật ký vẫn lưu được bình thường): khối
  hỏi phụ chuyển sang một trạng thái lỗi cục bộ, chỉ ảnh hưởng chính nó —
  dòng chữ nhỏ (`caption 13pt`, màu `--red`) "Chưa ghi được vào sổ tay" cùng
  một liên kết văn bản nhỏ "Thử lại" ngay dưới, giữ nguyên nội dung ý đã gõ và
  loại đã chọn để người dùng không phải gõ lại (AC-12).
- "Thử lại" chỉ thử lại phần ghi sổ tay, không đụng lại ảnh/nhật ký đã lưu,
  và không tạo mục thứ hai nếu một phần của lần ghi trước đã thành công một
  phần (idempotent theo lần check-in, không theo nội dung — BR-12: hai lần
  check-in khác nhau ghi cùng một sở thích vẫn là hai mục hợp lệ, nhưng cùng
  một lần check-in không bao giờ tạo quá một mục).

## Phần C — Mục trên màn Sổ tay: nhãn xuất xứ (AC-4, AC-5, AC-9, AC-10, AC-11, AC-15, BR-6, BR-11)

- Mục mới ghi từ check-in xuất hiện trong đúng nhóm cố định "Sở thích" hoặc
  "Sự kiện" (STORY-004 Phần B) — loại "sự kiện/dịp" ánh xạ vào nhóm "Sự kiện"
  có sẵn, không tạo nhóm thứ ba (AC-4).
- Ngay dưới dòng nội dung của mục, thêm một **dòng nhãn xuất xứ**:
  `caption 13pt`, màu `--ghost` (cùng vai trò với timestamp/metadata theo bảng
  type-scale) — không phải chip/pill, không viền, không nền màu riêng. Nhãn
  không chạm được, không dẫn tới đâu (không mở lại thẻ buổi hẹn) — vì Out of
  Scope đã loại lọc/sắp xếp theo xuất xứ.
  - Có tên buổi hẹn đọc được: "từ buổi hẹn <tên thẻ>".
  - Không đọc được (thẻ bị xoá, bị đóng ngăn, hoặc lỗi đọc — BR-6): suy biến
    thành "từ một buổi hẹn", mục vẫn hiện đầy đủ, vẫn sửa/xoá được (AC-9).
  - Nhãn không bao giờ là icon riêng, huy hiệu, hay có màu nổi bật hơn nội
    dung chính của mục — nó không phải tín hiệu chất lượng (BR-11).
- Nút "..." (Sửa/Xoá) trên hàng mục hoạt động y hệt mọi mục khác trong màn Sổ
  tay (STORY-004 AC-9) — không thêm lựa chọn thứ ba, không có "Xem xuất xứ" hay
  "Xem buổi hẹn gốc" trong menu này (giữ đúng phạm vi O-3/BR-9).
  - Sửa nội dung hoặc đổi loại: có hiệu lực ngay, dòng nhãn xuất xứ **giữ
    nguyên chữ** như lúc tạo, không đổi theo lần sửa (AC-5).
  - Xoá: mục biến mất ngay, không dialog xác nhận kịch tính hoá thêm so với
    xoá mục thường (STORY-004 AC-9 áp nguyên).
- Menu "..." của mục này **không** có mục xuất/chia sẻ, giống mọi mục khác
  trong màn (AC-15, STORY-004 AC-7) — không ngoại lệ vì có xuất xứ.
- Các bên đọc sổ tay (gợi ý quà, mồi chuyện, kịch bản buổi hẹn) dùng mục này y
  hệt mục tự thêm — ví dụ dòng "Dựa trên sổ tay" ở màn Gợi ý quà (STORY-004
  Phần D) hiện tên mục, **không bao giờ** kèm nhãn xuất xứ hay tên buổi hẹn ở
  bề mặt đó (AC-10) — nhãn xuất xứ chỉ hiện trên chính hàng mục ở màn Sổ tay.
- Widget và thông báo của STORY-012 không bao giờ hiện tên mục hay nhãn xuất
  xứ này, dù mục vừa ghi ngay sau một lần check-in (AC-13, BR-7) — không có
  UI mới nào ở widget/thông báo cho story này.
- Xoá một mục nhật ký hoặc xoá toàn bộ nhật ký không ảnh hưởng hiển thị của
  mục sổ tay này, và ngược lại (AC-11, BR-3) — hai màn, hai nguồn dữ liệu độc
  lập về mặt UI.

## Phần D — Nội dung là dữ liệu (AC-14, BR-5)

- Câu hỏi "Hôm nay biết thêm gì về người ấy?", nhãn "Tuỳ chọn", dòng nhắc chọn
  loại, hai dạng nhãn xuất xứ ("từ buổi hẹn <tên thẻ>" và suy biến "từ một
  buổi hẹn"), và các câu lỗi/thử lại — tất cả là mục dữ liệu có id bền trong
  gói nội dung hỏi-tại-chỗ, đi qua cổng nhập STORY-004 AC-36; không chuỗi cứng
  trong code (R-15a/c).
- Placeholder `<tên thẻ>` là một tham số nội dung, không phải chuỗi ghép tay
  ở tầng UI — cổng nhập từ chối bất kỳ mục nội dung nào chứa hàm ý đánh giá
  hay chấm điểm người kia (vi phạm R-1f ở tầng đầu vào làm hỏng cả bản dựng).

## Phần E — Điều không đổi (nhắc lại ranh giới, không phải phạm vi mới)

- Không thêm điểm vào mới, không route mới, không URL trực tiếp cho màn
  check-in — vẫn chỉ tới được từ thông báo 23h (STORY-012 mục 4).
- Không gắn ảnh check-in vào mục sổ tay ở bất kỳ đâu trong UI (AC-11).
- Không mở lại màn check-in sau khi đóng; không sửa mục ngay trên màn
  check-in sau khi đã lưu — mọi sửa/xoá chỉ ở màn Sổ tay (Out of Scope, BR-9).
- Không có badge/toast "đã lưu vào sổ tay" ở bất kỳ đâu ngoài phản hồi cục bộ
  của khối tại Phần A/B — nhất quán với STORY-004 Phần A "không toast đã lưu
  vào hồ sơ".

## Completion

- Output: `data/requirements/REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture/ux/uiux-spec.md` (tệp này).
- Design-Screen xác nhận trong `story_master.md`: `23h-vua-ve-j8` (khối hỏi
  phụ, Phần A/B/D) và `2-so-tay-nguoi-yeu` (nhãn xuất xứ, Phần C) — cả hai
  canvas đã có sẵn từ REQ-016, không có canvas riêng cho REQ-017.
- Không OQ nào bị chặn bởi spec này; OQ-1/OQ-2/A-5 đã RESOLVED trước khi viết
  (xem `req_master.md` `## User Decisions`).
- Đã refresh `data/ux/system/ui_ux_system_memory.md` — thêm mục 14 "Per-Item
  Provenance/Origin Tag" (mẫu hình dùng lại được ngoài REQ-017).
