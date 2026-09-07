# Story Brief: STORY-011 Vỏ hoàng đạo / trắc nghiệm

- Actor: người dùng chặng 1 muốn một cớ nhẹ nhàng để bắt chuyện.
- Capability: màn hoàng đạo / trắc nghiệm preset, kết quả **luôn** kết thúc
  bằng 3 thẻ hoạt động đẩy vào màn (1).
- Business value: cửa vào nhẹ nhất để bắt ý tưởng (J1), nhưng bị buộc phải dẫn
  ra hành động thay vì dừng ở một câu phán.
- Key business rules: **SC-2 — không bao giờ có biến thể chỉ hiện nhận định** ·
  **R-10 định vị: không phải app bói toán** · R-1g kết bằng câu để hỏi · R-1e
  cấm chấm điểm người kia · cấm tử vi hằng ngày / streak (không tối ưu DAU).
- Key edge/failure case: cám dỗ lớn nhất là ship một màn kết quả "đẹp" đứng một
  mình. Đó chính là "app bói toán có kèm to-do list" mà SB-174 cấm.
- Existing system entry/discoverability seed: đường vào riêng từ menu chính
  (nhóm CỬA VÀO). **Không** khoá vị trí, khác STORY-009/010.
- Direct AC/OQ anchors: AC1-6 trong `story_master.md`; R-15 áp cho kho nội
  dung.
- Complexity and why: standard — nội dung preset trên hạ tầng đã giao; giá trị
  nằm ở ràng buộc đầu ra, không ở kỹ thuật.
- Dependencies: STORY-001, STORY-004, STORY-005, STORY-008 (thứ tự SB-174 bắt
  buộc — đây là ràng buộc sản phẩm, không phải kỹ thuật).
