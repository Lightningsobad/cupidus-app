# Bộ Mốc Định Nghĩa Sẵn + Danh Mục Tín Hiệu Phán Đoán

Phụ lục của `development.md` (IDEA-20260831-001). Business-level, không phải spec
kỹ thuật. Nguồn quyết định: `[CHỐT c3]` — chọn phương án (b), app được đọc tín hiệu
im lặng/hoạt động **và tín hiệu trong chat** để **hỏi riêng**.

## 0-bis. Từ vựng (chốt c4)

| Khái niệm | Là gì | Ví dụ |
|---|---|---|
| **Loại mốc** ("lá bài") | định nghĩa sẵn: tên + icon + giọng + độ nhạy | "Lần đầu ra mắt gia đình" |
| **Mốc thật** (instance) | một lần xảy ra của *cặp này*, có ngày + ảnh | "12/3/2026 — nhà Linh, Nam Định" |
| **Pattern** | tín hiệu phát hiện, ánh xạ nhiều-nhiều tới loại mốc | "chào bác" + ảnh nhiều mặt người |

**[CHỐT c4] Ba tập lồng nhau, chi phí khác nhau, KHÔNG cần bằng nhau:**

- **Tập tự khai** (rộng, rẻ — chỉ cần tên + icon + một câu): **~30-40 lá**. Đây là
  bộ bài của onboarding hồi tố.
- **Tập auto-detect** (hẹp, đắt nhất — mỗi lá cần pattern + cửa sổ hỏi + test
  dương tính giả + mang rủi ro hỏi sai): **8-10 lá**.
- **Tập có hiện vật khoe riêng** (giữa, đắt về design — khung/chữ/bố cục riêng):
  **~15 lá**; phần còn lại dùng khung mặc định.

**Đề xuất tập auto-detect bản đầu (9 lá)** — tiêu chí: hay xảy ra trong 90 ngày
đầu x tín hiệu rõ x sai thì ít đau:

1. Chuyến đi đầu tiên · 2. Ra mắt gia đình · 3. **Cãi nhau xong vẫn nắm tay** ·
4. Yêu xa (tháng đầu + lần gặp lại) · 5. Lần đầu nấu cho nhau · 6. Cùng xem hết
một phim · 7. Công khai chuyện tụi mình · 8. Ở bên nhau lúc ốm · 9. Cùng qua một
bước ngoặt.

Để lại cho **tự khai**: dọn về gần nhau, mua/nuôi chung, đã quay lại, gia đình
chưa thuận, mất mát — hiếm ở cặp mới yêu hoặc quá rủi ro để đoán.

## 0. Nguyên tắc kiến trúc: BỘ BÀI ĐÓNG

Phán đoán **không bao giờ tạo ra loại mốc mới**. Nó chỉ **nâng một lá bài có sẵn
trong bộ** lên đúng thời điểm. Nói cách khác, detection là một hàm **xếp hạng trên
một danh mục cố định**, không phải hàm sinh.

Hệ quả:
- Mọi thứ app có thể gợi ý đều đã được người thiết kế duyệt trước về giọng và độ nhạy.
- Không bao giờ có chuyện app tự nghĩ ra một "thành tựu" lạ giữa lúc nhạy cảm.
- Test được: chỉ cần kiểm tra ánh xạ tín hiệu → lá bài, không phải kiểm tra đầu ra tự do.

## 1. Kiến trúc tín hiệu 3 lớp

- **Lớp A — Nhịp (rhythm).** Không đọc chữ. Im lặng, bùng nổ trở lại, lệch giờ,
  một chiều (một người nhắn dài, người kia không hồi). Rẻ, riêng tư, nhưng mơ hồ
  về ý nghĩa.
- **Lớp B — Từ vựng (lexical).** Khớp mẫu tiếng Việt trong chat chung. Chính xác
  về *sự kiện* hơn hẳn lớp A.
- **Lớp C — Ngoài chat (cross-module).** `gallery` (ảnh mới, geotag, nhiều mặt
  người), `expenses` (loại chi tiêu), `vibes` (tụt/hồi), `timeline`, `dream-jar`,
  `love-contracts`, `anti_ghosting`/`ghost-config`, `pairing`.

**[LUẬT L10 — Luật hai lớp] Một tín hiệu đơn lẻ không bao giờ đủ để hỏi.**
Cần ≥2 lớp trùng khớp trong cùng cửa sổ thời gian. Đây là van chính để cắt giảm
"hỏi sai thời điểm" — cái giá đã biết trước của phương án (b).

## 2. Bộ bài mốc + pattern

### Nhóm 1 — Mốc tiến lên (vui, khoe được)

| Lá bài | Lớp B (từ khoá/cụm) | Lớp A / C | Cửa sổ hỏi |
|---|---|---|---|
| Lần đầu ra mắt gia đình | "về nhà anh/em", "gặp bố mẹ", "ra mắt", "chào bác", "mẹ anh hỏi", "ba em bảo", "về quê" | ảnh nhiều mặt người + cuối tuần/lễ; expense "quà" | 1–2 ngày sau |
| Chuyến đi đầu tiên | "đặt vé", "book phòng", "khách sạn", "xách vali", tên địa danh | expense travel; ảnh geotag khác tỉnh | ngay khi về |
| Cùng nuôi / mua chung | "mua chung", "góp tiền", "của tụi mình", "nuôi con mèo" | expense chia đôi lặp lại | 1 ngày |
| Công khai chuyện tụi mình | "đăng ảnh", "để status", "thay avatar", "công khai" | ảnh đôi mới trong gallery | 1 ngày |
| Gặp hội bạn của nhau | "hội bạn anh", "nhóm em", "đi với tụi nó" | ảnh đông người | 1 ngày |
| Dọn về gần nhau | "chuyển nhà", "thuê phòng", "dọn về", "cùng khu" | expense "nhà" | 3 ngày |
| Cùng nhau qua một bước ngoặt | "đậu rồi", "trúng tuyển", "tốt nghiệp", "nhận việc", "nghỉ việc" | vibe tăng vọt | 1 ngày |
| Kỷ niệm tự phát | "kỷ niệm", "tròn X tháng", "hôm nay là ngày" | trùng mốc T1 | tức thì |

### Nhóm 2 — "Sẹo" (chỉ hỏi riêng, chỉ khoe dạng tổng hợp theo L9)

| Lá bài | Pha đứt gãy | Pha lành (**chỉ hỏi ở pha này**) | Cửa sổ hỏi |
|---|---|---|---|
| Cãi nhau xong vẫn nắm tay | im lặng vượt baseline riêng của cặp; "thôi", "tuỳ anh", "không có gì", "muốn nói gì thì nói", câu cụt, tin dài một chiều không hồi đáp | "xin lỗi", "anh sai rồi", "mình nói chuyện đi", "thương", emoji ôm; nhịp phục hồi | ≥24h **sau khi** nhịp đã hồi |
| Tháng đầu yêu xa / lần gặp lại thứ N | "bay", "sân bay", "ga", "xa nhau", "mấy tháng nữa"; giờ nhắn lệch hẳn, video call tăng | gặp lại: ảnh chung sau chuỗi ngày không có ảnh chung | ngày gặp lại |
| Đã ở bên nhau lúc ốm đau | "ốm", "sốt", "bệnh viện", "truyền nước", "mổ" | nhịp trở lại bình thường | **≥3–7 ngày**, giọng rất nhẹ |
| Đã đi qua mất mát | "mất", "đám tang", "viếng" | — | **≥7–14 ngày**, không bao giờ gợi ý khoe |
| Đã quay lại | "chia tay", "nghỉ đi", "dừng lại" rồi nối lại sau ≥1 ngày | nhịp hồi + giọng dịu | ≥48h sau khi hồi |
| Hiểu lầm đã gỡ | tín hiệu `anti_ghosting`/`ghost-config` | nhịp hồi | ≥24h |
| Gia đình chưa thuận mà vẫn đi tiếp | "ba mẹ không đồng ý", "cấm", "phản đối" | — | **không auto-hỏi**; chỉ để trong bộ bài tự khai |

### Nhóm 3 — Mốc nhịp sống (nhẹ, dày ở 30 ngày đầu)

Lần đầu nấu cho nhau ("nấu", "làm món") · lần đầu xem hết một phim cùng nhau
("tập cuối", "xem xong") · lần đầu gọi video quá nửa đêm (lớp A thuần) · lần đầu
đi khám/đi làm cùng · lần đầu ngủ quên khi đang gọi.

### Danh sách KHÔNG BAO GIỜ auto-detect

- **Lần đầu nói yêu** — quá thiêng, đoán sai là hỏng vĩnh viễn. Chỉ tự khai.
- Bất cứ thứ gì liên quan **thân mật thể xác**.
- **Có thai / kết hôn / chia tay thật** — hệ quả đời thật quá lớn, chỉ tự khai.
- Mọi thứ suy về **tính cách hoặc lỗi của MỘT người** (giữ luật R-1 của
  IDEA-20260828-002).

## 3. Luật thời điểm hỏi (van an toàn cho phương án b)

- **[L22 — chốt c4, giọng ẤM] Ấm ở sự QUAN TÂM, không ấm ở sự SUY DIỄN.**
  ✅ *"Mấy hôm nay yên ắng nhỉ. Có gì muốn giữ lại không?"* (dịu dàng, không khẳng
  định gì). ❌ *"Hình như hai bạn vừa giận nhau..."* (ấm nhưng đã đoán — vi phạm
  L7). Câu hỏi được phép dịu dàng; không được phép khẳng định điều app chưa biết.
  Giọng ấm làm câu hỏi sai trở nên xâm phạm hơn nhiều, nên L22 là điều kiện đi
  kèm bắt buộc của lựa chọn "ấm".
- **[L23 — chốt c4] Bỏ lỡ là chấp nhận được.** Không detect được thì thôi, chờ mốc
  khác. **Không có cơ chế đuổi bắt mốc đã lỡ**, không nhắc lại, không "hình như
  tháng trước có chuyện gì". Hệ quả: **auto-detect là phần thưởng thêm, không phải
  xương sống** — lưới an toàn luôn là onboarding hồi tố + tự khai. Điều này hạ hẳn
  áp lực độ chính xác và biện minh cho việc giữ tập auto-detect nhỏ.

- **[L11] Không bao giờ hỏi trong pha căng.** Chỉ hỏi ở "cửa sổ lành", sau khi
  nhịp đã phục hồi ≥24h. Hỏi giữa lúc đang cãi nhau là cách nhanh nhất để bị gỡ app.
- **[L12] Hạn ngạch**: tối đa **1 gợi ý/tuần**, và **≤1 gợi ý loại "sẹo"/tháng**.
  Hỏi nhiều = app thành kẻ dò xét.
- **[L13] Tắt dần**: bỏ qua 2 lần cùng một loại → ngưng loại đó 90 ngày.
- **[L14] Không bao giờ trích lại lời của họ.** App tuyệt đối không nói *"mình
  thấy bạn nhắn 'anh xin lỗi'"*. Chỉ nói chung chung. Đây là ranh giới giữa "app
  tinh ý" và "app theo dõi".
- **[L15] Không bao giờ hỏi người này về người kia.** Hỏi *"có chuyện gì đáng ghi
  lại không?"*, không hỏi *"bạn ấy có ổn không?"*.
- **[L16] Một chiều thì nằm chờ.** Nếu chỉ một người xác nhận mốc sẹo → nằm ở kho
  riêng của người đó, không tự lên hộ chiếu chung, không thông báo cho người kia.

## 4. Ranh giới xử lý dữ liệu (thay cho luật "cấm đọc chat" đã bị bãi bỏ)

- **[L17] Khớp mẫu chạy trên máy.** Chỉ gửi lên server **mã tín hiệu**
  (ví dụ `SIGNAL_RECONCILE`) + dấu thời gian. **Không bao giờ gửi nội dung.**
- **[L18] Không lưu chữ đã khớp, không log, không dùng cho quảng cáo hay huấn luyện.**
- **[L19] Có công tắc tắt hẳn "gợi ý mốc từ chat", tắt là tắt thật**, và nói rõ
  một lần lúc onboarding: *"app tìm vài dấu hiệu để gợi ý ghi lại kỷ niệm — không
  đọc hộ ai, không kể lại cho người kia."*
- **[L20] Cấm biến tín hiệu thành chỉ số hiển thị** ("tuần này căng thẳng 3 lần").
  Vi phạm L6 và biến app thành hồ sơ bằng chứng dùng để cãi nhau.

## 5. Chống dương tính giả (bài toán trung tâm của phương án b)

- **Baseline theo từng cặp, không dùng ngưỡng chung.** Cặp nhắn 300 tin/ngày thì
  im 6 tiếng là bất thường; cặp nhắn 5 tin/ngày thì im 3 ngày là bình thường.
- **Loại trừ ngữ cảnh trước khi kết luận im lặng là xấu**: mùa thi, đi công tác,
  đang du lịch (gallery/expenses cho thấy đang đi chơi → im lặng là vui), giờ ngủ,
  lệch múi giờ, mất mạng.
- **Phủ định và đùa hạ điểm tín hiệu**: "không giận đâu", "đùa thôi", emoji cười.
- **Tiếng Việt không dấu + teencode là bắt buộc**, nếu không thì miss gần hết:
  "ko/k/hok", "xl", "iu", "j", "z", "dc", "bit", "ns". Cộng chuyển mã Việt–Anh:
  "sorry", "mad", "ily", "miss u".
- **Không đoán bừa để tỏ ra thông minh.** Không đủ tín hiệu thì im, chi phí của
  việc im lặng gần bằng 0; chi phí của một câu hỏi sai lúc đang đau thì rất lớn.

## 6. Vòng đời một gợi ý

tín hiệu (≥2 lớp) → chờ cửa sổ lành → kiểm hạn ngạch + tắt dần → **hỏi riêng từng
người, giọng nhẹ, một câu, bỏ qua được** → user chọn một lá bài trong bộ (hoặc
"không có gì") → mốc vào **kho riêng** → nếu là "sẹo" thì cần **đồng thuận hai
chiều** mới lên hộ chiếu chung → công khai thì cần **cả hai đồng ý lần nữa**, và
chỉ ở dạng tổng hợp đã vượt qua (L9).
