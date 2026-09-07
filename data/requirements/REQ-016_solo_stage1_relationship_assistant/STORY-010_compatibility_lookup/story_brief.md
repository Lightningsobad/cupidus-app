# Story Brief: STORY-010 Bảng tra ăn khớp

- Actor: người dùng chặng 1 muốn chuẩn bị cho mối quan hệ cụ thể này.
- Capability: bảng tra tay (144 ô hoàng đạo + 256 ô MBTI) ship như gói dữ liệu,
  runtime tất định, cho ra **bộ bốn bắt buộc**: chỗ dễ hợp · chỗ dễ va · 1 hoạt
  động nên thử · 1 câu để hỏi.
- Business value: biến "ăn khớp" từ trò bói thành công cụ chuẩn bị; mục "hoạt
  động nên thử" đẩy thẳng thành thẻ vào kho chung.
- Key business rules: **R-7 không AI runtime, bảng tra tay, mỗi ô bắt buộc có
  ít nhất một điểm cọ xát** · **R-8 hiển thị DẢI, không %** · R-1a đầu vào phải
  do người dùng tự nhập, cấm app suy ra dấu của người kia · **SC-6/R-13 khoá vị
  trí** · R-10 không được trượt sang định vị "app bói toán".
- Key edge/failure case: chưa có dữ liệu người kia → hỏi tại chỗ, tuyệt đối
  không tự suy. Không mạng → nội dung vẫn đầy đủ.
- Existing system entry/discoverability seed: liên kết trong luồng (5) hoặc (9)
  đang chạy. Direct URL only acceptable: **NO**.
- Direct AC/OQ anchors: AC1-7 trong `story_master.md`; **OQ-3 ĐÃ ĐÓNG
  2026-09-06 (user) — D-15 → R-15.** Điều kiện ship nội dung nay là **cổng nhập
  chạy được (R-15c)** + truy vết duyệt qua **id bền**, không còn là quyết định
  nhân sự — 400 ô vẫn là khối lượng biên tập lớn nhất của cả requirement.
- Complexity and why: complex — gói dữ liệu 144 + 256 ô với ràng buộc nội dung
  cứng trên từng ô, cộng một quy tắc hiển thị (DẢI, không %) dễ bị vi phạm.
- Dependencies: STORY-004. Chạy sau STORY-004/005/008 theo SB-174.
