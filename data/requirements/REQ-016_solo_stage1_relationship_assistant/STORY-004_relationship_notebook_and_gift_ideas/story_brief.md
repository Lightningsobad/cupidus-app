# Story Brief: STORY-004 Gợi ý quà, và sổ tay / hồ sơ kỹ năng thu thập tại chỗ

- Actor: người dùng chặng 1 muốn tặng quà có ý nghĩa mà không cần giàu.
- Capability: màn Gợi ý quà (dịp Việt × giai đoạn × sổ tay, nhánh không-tốn-tiền
  và handmade theo kỹ năng, lọc theo **số giờ**), cộng kho ngữ cảnh sổ tay + hồ
  sơ kỹ năng được đổ đầy bằng **hỏi tại chỗ**, cộng hai màn xem/sửa của chúng.
- Business value: đây là chỗ chặng 1 hết "gợi ý chung chung". Sổ tay + kỹ năng
  là hạ tầng mà STORY-005/008/009/010 đều đọc lại.
- Vì sao sổ tay không phải story riêng: brainstorm định nghĩa nó là "kho ngữ
  cảnh, không phải tính năng" và cấm luồng điền-trước (SC-3). Giao một mình thì
  sau khi merge **không có gì quan sát được** → trượt cổng standalone-value.
  SB-174 được giữ dưới dạng **thứ tự pha** bên trong story này.
- Key business rules: R-1f sổ tay chỉ ghi sở thích + sự kiện, không đánh giá
  con người, không xuất/chia sẻ · R-11 thang CÔNG SỨC (giờ), cấm VNĐ và cấm
  thương mại/affiliate · SC-2 mỗi gợi ý phải đẩy ra một thẻ vào màn (1) · SC-3
  không có luồng điền trước.
- Key edge/failure case: **rủi ro #2** — hỏi kỹ năng kiểu CV thì ~80% trả lời
  "không có" và cả nhánh handmade sập. "Nhớ dai", "biết chỗ ăn ngon" phải tính
  là kỹ năng.
- Existing system entry/discoverability seed: Gợi ý quà vào từ menu chính (nhóm
  CỬA VÀO); Sổ tay/Hồ sơ kỹ năng vào từ menu nhưng chỉ để xem/sửa.
- Direct AC/OQ anchors: AC1-8 trong `story_master.md`; R-15 (cổng nhập chạy
  được) áp cho kho quà.
- Complexity and why: complex — ba pha (kho ngữ cảnh → quà → handmade), một cơ
  chế hỏi-tại-chỗ tái dùng được cho mọi cửa vào sau, và một chỉ mục nội dung
  nhiều chiều.
- Dependencies: STORY-001.
