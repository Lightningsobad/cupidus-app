# Story Brief: STORY-009 Chân dung "theo cách BẠN nhìn"

- Actor: người dùng chặng 1 muốn hiểu "mối" của mình rõ hơn.
- Capability: bảng câu hỏi người dùng trả lời **thay** người kia, cho ra một
  chân dung **tưởng tượng** ghi rõ xuất xứ, mỗi phần kết bằng một câu để hỏi
  người thật.
- Business value: biến quan sát rời rạc của chính người dùng thành hiểu biết
  dùng được, và đổ dữ liệu ngược vào sổ tay cho các cửa vào khác.
- Key business rules: **R-1e ba tầng** — user GHI ✅, user ĐOÁN app không xác
  nhận ✅, app SUY LUẬN/CHẤM ĐIỂM về người kia ❌ · R-1a chỉ suy luận trên dữ
  liệu user tự nhập · **R-1g bài kiểm tra: đọc xong muốn hỏi người kia nhiều
  hơn** · **SC-6/R-13 khoá vị trí**, không menu, không tab bar, không route
  trực tiếp.
- Key edge/failure case: bỏ dở giữa chừng → giữ phần đã trả lời, không thúc ép.
  Rủi ro chính là ngôn ngữ trượt từ "bạn đoán" sang "sự thật về người kia".
- Existing system entry/discoverability seed: liên kết trong luồng (5) gợi ý
  quà đang chạy. Direct URL only acceptable: **NO**.
- Direct AC/OQ anchors: AC1-6 trong `story_master.md`; R-15 — story rủi ro
  "sượng" cao nhất, bắt buộc qua cổng nhập (R-15c).
- Complexity and why: standard — bảng câu hỏi + hiển thị kết quả trên hạ tầng
  sổ tay đã có; độ khó nằm ở ràng buộc ngôn ngữ và điều hướng, không ở kỹ thuật.
- Dependencies: STORY-004.
