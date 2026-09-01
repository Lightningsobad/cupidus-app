# Idea Master: IDEA-20260828-001 Hearts Currency Economy
Lifecycle: ACTIVE
Development Status: IN_PROGRESS
Source: user
Created: 2026-08-28
Last Updated: 2026-08-28
Linked Requirement: N/A

## Seed

Original idea:

Hệ thống tiền tệ `hearts` hiện đã tồn tại nhưng mới chỉ ở mức **cấp phát ban đầu**
(initial allocation). Hearts hiện chỉ dùng để mở khoá theme. Người dùng muốn phát
triển idea cho hệ thống hearts này thành một hệ kinh tế thực sự.

Hiện trạng quan sát được trong repo (business-level, không phải plan kỹ thuật):

- Hearts là **ví chung của cặp đôi** (shared couple wallet), khoá theo `coupleId`,
  không phải ví cá nhân từng người.
- Số dư khởi tạo là một hằng số cứng `1240` — không có mô hình kinh tế đứng sau.
- **Không có faucet**: không có bất kỳ cách nào để kiếm thêm hearts.
- **Chỉ có một sink**: mua theme, qua luồng mutual-consent request/approve/reject
  đã có sẵn, kèm một `wishlist` slot đã tồn tại nhưng chưa khai thác.
- Emoji pack đã có trường `price` trong catalog (ví dụ 250) nhưng luồng unlock
  **chưa hề trừ hearts** — đây là một sink đã dựng dở, chưa nối dây.
- Love Pet đã có `happiness` / `level` / `totalInteractions` — một hệ tiến trình
  song song hoàn toàn chưa kết nối với hearts.

## Current Business Framing

- **[CHỐT 2026-08-28] Định hướng: hearts là *tấm gương phản chiếu quan hệ*,
  không phải tiền tệ trò chơi.** Hearts không bao giờ mua được bằng tiền thật.
- Problem: Hearts đang là một **nền kinh tế chết** — có kho tiền, không có faucet,
  gần như không có sink. Sau khi chốt định hướng, bài toán đổi hình: không còn là
  *"thêm gì để mua"* mà là **"gương đo cái gì, và một tấm gương thì tiêu kiểu nào"**.
- Target actor: Cặp đôi như một đơn vị kinh tế duy nhất. Bốn ca biên bắt buộc phải
  chịu được: yêu xa, đang xung đột, mới ghép một tuần, và gắn bó lâu nhưng ít
  dùng app.
- Value hypothesis: Hearts được **đúc ra từ hành vi quan hệ có thật của cả hai
  người** thay vì được phát không, nên số dư biến từ điểm số trò chơi thành
  **bằng chứng đầu tư vào mối quan hệ**. Cái mua được không quan trọng bằng việc
  số dư đó chứng minh hai người đã thực sự có mặt vì nhau.
- Why this might matter now: Đây là thời điểm rẻ nhất để định hình — chưa có
  faucet nào nên chưa có kỳ vọng người dùng nào cần phá vỡ. Nhiều feature đã sẵn
  sàng làm faucet/sink (pet, emoji, dream jar, expenses, timeline, love contracts,
  data-export) mà chưa cái nào được nối.
- Luật thiết kế đã rút ra (không mở lại trừ khi user đổi ý):
  1. Hearts chỉ đo **"chúng ta"**, không bao giờ đo "anh so với em".
  2. **Một tấm gương không có hệ số nhân** — không trả tiền để tăng tốc, không
     bonus may mắn, không sự kiện nhân đôi.
  3. Không thưởng cho chính lời bày tỏ tình cảm; chỉ thưởng hiện diện và nghi thức.
  4. Số dư không bao giờ bị tịch thu; số **đọc** thì được phép rơi trung thực.
  5. Chia sẻ ra ngoài là chia sẻ **câu chuyện**, không bao giờ là con số.
  6. Giải thể mối quan hệ là một **nghi thức kết xuất**, không phải lệnh xoá.
- Câu hỏi chặn hiện tại: **một tấm gương thì không tiêu được.** Nếu số dư là bằng
  chứng đầu tư, mua một cái theme sẽ làm giảm chính bằng chứng đó. Chưa chọn lời
  giải trong năm hướng đã liệt kê ở `development.md` (G2-G6).
- Rủi ro hiệu lực lớn nhất: gương có nguy cơ đang **đo mức độ dùng app chứ không
  đo mối quan hệ** (H5), và có nguy cơ **thiên vị chống lại cặp yêu xa** (H1).
- Notes: Vẫn là idea khám phá. Chưa converge, chưa ranking, chưa scope, chưa handoff.

## Artifacts

- Development: `development.md`
- Checkpoint: `brainstormer-checkpoint.md`

## Routing Notes

- Current owner: brainstormer
- Next action: develop-idea (tiếp tục divergence hoặc converge khi user yêu cầu)
- Delivery handoff: explicit user switch to `scrum-master` only
