# Design Brief — Dấu Mốc Cặp Đôi (IDEA-20260831-001)

Vòng 8 · 2026-09-04 · chuyển từ **nghiên cứu thô** sang **hình hài sản phẩm**.

Đầu vào: `idea.md` (23 luật + framing đã chốt) · `milestone-deck.md` (147 lá / 12
nhóm) · `development.md` `## Convergence Notes` (12 lát → 4 đợt) ·
`signal-patterns.md` (chỉ cho Đợt 4).

Tài liệu này trả lời: **có những tính năng gì, mỗi tính năng là gì.**
Bản đồ màn hình + user journey nằm ở `screen-map.md`.

---

## 0. Một câu để nhớ

> Hệ này **không đo** quan hệ. Nó **đóng dấu** những gì đã có thật, rồi **in ra**
> một thứ cầm đi khoe được.

Ba động từ đó chính là ba lớp sản phẩm, và mọi tính năng bên dưới thuộc đúng một
lớp:

| Lớp | Động từ | Câu hỏi nó trả lời | Tính năng |
|---|---|---|---|
| **Nạp** | *đã xảy ra chưa* | "chuyện gì của tụi mình đáng được ghi?" | F-01…F-04, F-17 |
| **Giữ** | *đóng dấu, cất* | "tụi mình đã đi được tới đâu?" | F-05, F-08, F-15, F-16 |
| **Khoe** | *in ra, gửi đi* | "tôi đăng cái gì hôm nay?" | F-06, F-07, F-09…F-14, F-18 |

Sai lầm chết người cần tránh: làm xong lớp **Nạp** rồi tưởng đã xong sản phẩm.
Không có lớp **Khoe** thì đây chỉ là một cái timeline thứ hai — thứ app đã có
(`TimelineScreen`, 490 dòng) và không ai dùng.

---

## 1. Từ vựng chốt (dùng thống nhất trong mọi tài liệu sau)

| Từ | Nghĩa | Không phải là |
|---|---|---|
| **Lá bài** | một *loại* mốc trong bộ bài đóng 147 lá (A01, G04, K02…) | không phải mốc của một cặp cụ thể |
| **Con dấu** | một lá bài **đã đạt** bởi một cặp cụ thể (có ngày, có thể có ảnh) | không phải "badge tính điểm" |
| **Hộ chiếu** | bộ sưu tập con dấu của cặp, sắp theo thời gian | không phải bảng xếp hạng |
| **Hiện vật** | tấm ảnh/thiệp sinh ra từ một con dấu, để gửi ra ngoài | không phải ảnh chụp màn hình |
| **Nghi lễ** | màn ăn mừng toàn màn hình khi đạt mốc lớn (~15 lá) | không phải toast/snackbar |
| **Làm chứng** | người ngoài xác nhận trên trang công khai | không phải "like" |
| **Sẹo** | nhóm G — mốc vượt qua chuyện khó | không phải "sự cố được ghi lại" |

App luôn xưng **"tụi mình"** (chốt c5).

---

## 1b. Sáu quyết định đã chốt — 2026-09-04

| Mã | Quyết định | Chốt |
|---|---|---|
| **A-01** | Người kia thấy gì khi mình đóng con dấu | **(d)** ghi = một người · **khoe = hai người** → **L24** |
| **A-02** | Chỗ ở của Hộ chiếu | **(1)** chế độ xem thứ hai của `TimelineScreen`, **lối vào nâng lên hạng nhất** trên `HomeScreen`. **Không lấy tab nào** |
| **A-03** | Nội dung widget màn khoá | **(2) bản đầy đủ**: bộ đếm + mốc gần nhất + mốc sắp tới → kéo theo đồng bộ dữ liệu và **L26** |
| **A-04** | Vị trí buổi ôn lại | **(4)** `onboarding_chain` giữ **1 câu hỏi ngày gốc + 5 lá xác suất cao nhất**; 142 lá còn lại ra ngoài Nhà |
| **A-05** | Wrapped chen lịch | **(4) luật kích hoạt**: Đợt 1 xong **trước 15/10/2026** → Wrapped chen trước F-09/F-10; sau mốc đó → nhường, làm mùa 2027 |
| **A-06** | `expenses` làm nguồn | **(1)** có, **chỉ mức sự kiện, cấm số tiền** → **L25** |

Hai quyết định A-03 và A-06 đi ngược khuyến nghị của brainstormer. Cả hai đều được
nhận, và mỗi cái được cài một luật chặn đúng rủi ro đã nêu lúc tư vấn — xem §6.

---

## 2. Bảng tổng tính năng — 19 tính năng / 4 đợt

Cột **Lát** nối ngược về 12 lát công việc trong `development.md`.

| ID | Tính năng | Đợt | Lát | Lớp | Nguồn dữ liệu chính |
|---|---|---|---|---|---|
| **F-01** | Ngày gốc & bộ đếm | 1 | S1a | Nạp | `pairing.startDate` |
| **F-02** | Bộ bài mốc & kho tra cứu 147 lá | 1 | S3 | Nạp | nội dung tĩnh |
| **F-03** | Buổi ôn lại — nạp mốc hồi tố | 1 | S3 | Nạp | người dùng bấm |
| **F-04** | Tự khai & sửa mốc | 1 | S3 | Nạp | người dùng |
| **F-05** | Hộ chiếu | 1 | S4 | Giữ | con dấu |
| **F-06** | Xưởng hiện vật (bản cơ bản) | 1 | S2 | Khoe | `gallery` + con dấu |
| **F-07** | Widget màn hình khoá *(bản đầy đủ)* | 1* | S1b | Khoe | bộ đếm + con dấu |
| **F-08** | Mốc tự sinh từ sự kiện cứng | 1 | S1/S3 | Giữ | `gallery`, `timeline`, `dream-jar`, `love-contracts`, `themes`, `data-export` |
| **F-09** | Trang công khai của tụi mình | 2 | S5 | Khoe | hộ chiếu (đã lọc) |
| **F-10** | Người làm chứng | 2 | S5 | Khoe | người ngoài, **không cần cài app** |
| **F-11** | Danh hiệu & lời chúc bạn bè trao | 2 | S5 | Khoe | người ngoài |
| **F-12** | Cupid Wrapped cuối năm | 2† | S9 | Khoe | cả 5 tầng + `vibes` |
| **F-13** | Nhóm "sẹo" đầy đủ | 3 | S8 | Nạp | tự khai riêng tư |
| **F-14** | Hệ sinh hiện vật đầy đủ | 3 | S6 | Khoe | 12 khung × 6 bố cục × 147 con dấu |
| **F-15** | Nghi lễ 15 lá lớn | 3 | S6 | Giữ | — |
| **F-16** | Hearts faucet | 3 | S10 | Giữ | nối IDEA-20260828-001 |
| **F-17** | Tinh ý — auto-detect 9 lá | 4 | S7 | Nạp | `messages` on-device, `signal-patterns.md` |
| **F-18** | Bản in vật lý | 4 | S11 | Khoe | hiện vật |
| **F-19** | Mốc solo chặng 1 + Ngày trao kho | 4 | S12 | Nạp | nối IDEA-20260829-001 |

`*` F-07 nằm **cuối** Đợt 1, sau khi vòng `M-01 → M-03 → M-06` đã đóng — xem §5
Phát hiện 3 và §4b quy tắc trượt đợt.
`†` F-12 bị ràng buộc lịch: nếu sát Tết/cuối năm thì chen lên trước F-09/F-10.

---

## 3. Đợt 1 — tám tính năng, mô tả đầy đủ

Đợt 1 = **"ngày đầu cài app đã có hộ chiếu dày và một tấm thiệp đăng được."**
Không chạm luật rủi ro nào: không đọc chat, chưa công khai, không so sánh.

### F-01 · Ngày gốc & bộ đếm

Mọi mốc nhóm A đều là hàm của một con số duy nhất: **ngày tụi mình bắt đầu**.

- Người dùng khai ngày này (không phải ngày ghép đôi trên app — hai thứ khác nhau,
  và chính khoảng cách giữa chúng là thứ làm cho onboarding hồi tố có việc để làm).
- **Sửa lùi tự do, không khoá** (chốt c5, Q5). Chống lạm dụng bằng xã hội chứ không
  bằng kỹ thuật: **mỗi lần ngày bị đổi, người kia luôn được báo** — nêu ngày cũ,
  ngày mới, ai đổi.
- Bộ đếm sinh ra 16 lá nhóm A tự động, không cần ai nhập gì thêm.
- A12 (kỷ niệm hằng tháng) **mặc định TẮT** — mốc mềm, dễ thành nhiễu.
- A16 (ngày số đẹp) chỉ hiện khi trùng thật.

Ràng buộc: `pairing.startDate` hôm nay là dữ liệu của module ghép đôi. Cần xác nhận
nó ghi được, có lịch sử sửa, và bắn được thông báo cho phía kia.

### F-02 · Bộ bài mốc & kho tra cứu 147 lá

Bộ bài **đóng** — app không sinh mốc mới ngoài danh mục (L21). Đây là điều kiện để
mọi thứ khác an toàn: detection chỉ **xếp hạng** lá có sẵn, không **phát minh** lá.

- 147 lá / 12 nhóm A–L, mỗi lá có: tên theo giọng "tụi mình", nhóm, tầng nguồn
  (1–5), khán giả mặc định (CK/BT/R), con dấu riêng.
- **Kho tra cứu luôn mở** — không giấu lá nào. Người dùng vào xem được toàn bộ 147
  lá bất cứ lúc nào, kể cả lá chưa đạt.
- Nhóm G (sẹo) trong kho **nằm sau vách ngăn** với lời dẫn rõ ràng.
- Đây là **nội dung**, không phải kỹ thuật: khối lượng thật nằm ở viết 147 tên +
  vẽ con dấu. Đợt 1 chỉ cần **12 con dấu chung theo nhóm** (PMI), con dấu riêng
  từng lá đẩy sang F-14.

### F-03 · Buổi ôn lại — nạp mốc hồi tố

**Tính năng quan trọng nhất Đợt 1**, và theo PMI có thể là màn hình hay nhất cả app.

Giải bài toán chí mạng: người dùng cài app khi đã yêu 2 năm, mở ra thấy trống trơn
nên bỏ đi. Buổi ôn lại lấp đầy hộ chiếu **trong 5 phút đầu**.

Cách chạy:
- Lướt **toàn bộ** 147 lá (chốt Q15) dưới dạng bài lật: *"Tụi mình đã cùng đi
  du lịch chưa?"* → **Rồi / Chưa / Để sau**.
- **Xếp theo xác suất đã xảy ra**, suy từ độ dài quan hệ vừa khai ở F-01. Cặp 3
  tháng và cặp 5 năm thấy hai thứ tự hoàn toàn khác nhau.
- Chia đợt, có điểm dừng tự nhiên: *"còn 90 lá nữa, xem tiếp không?"*
- **Dừng bất cứ lúc nào, quay lại bất cứ lúc nào.** Không có màn bắt buộc hoàn thành.
- Bấm "Rồi" là đủ để đóng dấu; **hỏi ngày là tuỳ chọn**, và mặc định là "khoảng
  thời gian" chứ không phải ngày chính xác (luật hai loại số: được mơ hồ ở phán
  xét, không được sai ở sự kiện — "khoảng hè 2024" là thành thật, "12/7/2024" bịa
  ra thì không).
- **Nhóm G nằm cuối, sau vách ngăn**: *"Phần tiếp theo nói về những lúc khó. Xem
  sau cũng được."*
- Làm một mình được. Không cần đợi người kia (L4).

**Vị trí — chốt A-04 = lối 4.** Chia làm hai nửa, không phải một khối:

| Nửa | Ở đâu | Nội dung | Vì sao |
|---|---|---|---|
| **Hạt giống** | **trong `onboarding_chain`** | **1 câu hỏi ngày gốc + 5 lá xác suất cao nhất** | Ra khỏi đăng ký đã có ~20 con dấu. Không ai bước vào app và thấy hộ chiếu rỗng |
| **Buổi ôn lại đầy đủ** | **ngoài chain**, lời mời trên `HomeScreen` | 142 lá còn lại, chia đợt, hoãn được | Không gánh rủi ro kéo dài luồng đăng ký |

Nửa trong chain phải **cứng dưới 60 giây**. 5 lá đó không được chọn tuỳ hứng — phải
là 5 lá xác suất cao nhất theo độ dài quan hệ vừa khai, và **không lá nào thuộc
nhóm G**.

Rủi ro phải đo, không được đoán: **thời lượng thật**. Nếu lướt 147 lá mất 20 phút
thì tính năng này tự giết chính nó.

### F-04 · Tự khai & sửa mốc

Ngoài buổi ôn lại, người dùng phải ghi được một mốc **ngay lúc nó vừa xảy ra**.

- Vào từ kho bài (chọn lá → đánh dấu đã đạt) hoặc từ ảnh trong `gallery`
  (chọn ảnh → "đây là mốc gì?").
- Sửa/gỡ con dấu tự do, **cả hai người đều có quyền như nhau** — đối xứng, vì
  con dấu là vật thể của **cặp**, không phải của người bấm.
- Đính kèm: ngày (hoặc khoảng), ảnh (tuỳ chọn), một dòng ghi chú, vòng khán giả.
- **Không bắt gõ chữ để mở khoá mốc.** Gõ chữ là tuỳ chọn làm đẹp, không phải cửa.

**Ranh giới ghi/khoe — chốt A-01 = lối (d), thành L24.** Ba mệnh đề, không có hàng
chờ duyệt nào:

1. **Ghi là việc của một người.** Con dấu vào hộ chiếu ngay lập tức. Người kia nhận
   một thông báo nhẹ. Không có trạng thái "chờ duyệt" — hàng chờ sẽ vi phạm L3
   (nhắc duyệt = phạt khi im lặng) và L4 cùng lúc.
2. **Khoe ra ngoài app chỉ với con dấu mình đã tận mắt xem.** Con dấu mình tự đóng
   thì hiển nhiên đã xem → khoe được ngay. Con dấu người kia đóng thì mở ra xem là
   xong — **chính hành động xem là xác nhận**, không cần nút "duyệt".
3. **Gỡ là quyền phủ quyết tức thời của cả hai.** Ai gỡ thì con dấu biến khỏi mọi
   bề mặt khoe ngay, kể cả trang công khai (F-09). Ảnh đã gửi đi thì không thu hồi
   được — đó là giới hạn thật, phải nói thẳng với người dùng, không giả vờ.

Rủi ro còn lại đã biết và chấp nhận: An khoe được một con dấu Bình chưa kịp xem.
Bù lại Bình luôn nhận thông báo và luôn gỡ được. Với nhóm nhạy nhất (G — sẹo) thì
Đợt 3 đã đặt luật chặt hơn: **đồng thuận hai chiều ngay từ khâu GHI**.

### F-05 · Hộ chiếu

Chỗ ở của mọi con dấu. Ẩn dụ trung tâm của lớp **Giữ**.

- Sắp theo thời gian, nhóm theo năm/mùa.
- Ô trống của lá chưa đạt **hiện mờ, không hiện dạng nhiệm vụ**. Đây là ranh giới
  đạo đức: hộ chiếu là *đã đi tới đâu*, không phải *còn thiếu bao nhiêu*. Không
  thanh tiến độ, không phần trăm, không "còn 118 mốc nữa".
- Đếm được: "24 con dấu · 3 năm · 4 người làm chứng". Đếm **sự kiện**, không đếm
  điểm.
- Từ một con dấu → mở chi tiết → nút **"Làm thiệp"** dẫn sang F-06.
- I08 (*hộ chiếu đủ N con dấu*) là mốc meta của chính hệ này.

### F-06 · Xưởng hiện vật (bản cơ bản)

Thứ duy nhất **rời khỏi app** ở Đợt 1. Nếu tính năng này dở, cả đợt không có kênh
lan truyền nào.

- Đầu vào: một con dấu. Đầu ra: một ảnh dọc (tỉ lệ story) tải về / chia sẻ được
  (`share_plus` đã có sẵn trong `pubspec.yaml`).
- Đợt 1 làm **3 bố cục**, không phải 6: **số lớn** (mốc ngày) · **tem hộ chiếu**
  (mặc định) · **ảnh tràn** (khi có ảnh).
- ⚠️ **"Ảnh tràn" không được là đường đi chính.** Ngày 1 người dùng chưa có ảnh
  trong `gallery`, mà PMI đã cảnh báo chất lượng hiện vật phụ thuộc chất lượng ảnh
  họ có. Vậy hai bố cục **không cần ảnh** phải đẹp đứng một mình.
- **Không có watermark bắt buộc dạng quảng cáo.** Dấu Cupid nhỏ, sang, ở mép — thứ
  người ta không muốn cắt đi.
- 12 khung theo nhóm (Đợt 1 dùng bản rút gọn); khung đầy đủ ở F-14.

### F-07 · Widget màn hình khoá — **bản đầy đủ (chốt A-03 = lối 2)**

Theo PMI, **có thể là kênh khoe mạnh hơn cả trang công khai**: bộ đếm nằm trên màn
khoá của chính người dùng, ai nhìn điện thoại họ cũng thấy.

Nội dung: **bộ đếm ngày + mốc gần nhất + mốc sắp tới**.

Ba phần đó có ba chi phí rất khác nhau, và đó là chìa khoá để làm nó không đắt:

| Phần | Cần gì | Chi phí |
|---|---|---|
| Bộ đếm ngày | chỉ `startDate` | **Thấp** — hàm thuần, widget tự tính tại chỗ |
| **Mốc sắp tới** | chỉ `startDate` | **Thấp** — mốc nhóm A đều là hàm của ngày gốc, tính offline được, **không cần đồng bộ** |
| **Mốc gần nhất đã đạt** | một bản ghi | **Trung bình** — phải đẩy sang widget mỗi khi có con dấu mới |

⇒ Chỉ **một** trong ba phần cần đồng bộ. Không phải "đồng bộ hộ chiếu vào widget",
mà là **ghi đúng một bản ghi mới nhất** vào App Group (iOS) / DataStore (Android)
rồi gọi reload. Đó là lý do bản đầy đủ vẫn nằm được trong Đợt 1.

- iOS WidgetKit + App Group; Android AppWidget/Glance.
- Không refresh định kỳ, không gọi mạng từ widget. Widget chỉ đọc thứ app đã ghi.

⚠️ **L26 — luật riêng của widget.** Màn khoá là bề mặt công khai nhất trong đời
sống hằng ngày: ai cầm điện thoại lên cũng đọc được, kể cả người không được mời.
Vậy widget **chỉ hiện lá có khán giả `CK`**. **Nhóm G (sẹo) bị cấm vĩnh viễn khỏi
widget**, cùng mọi lá đặt khán giả `R`. Một dòng như *"đã cùng đi qua một mất mát"*
nằm trên màn khoá là hỏng theo cách không sửa được.

### F-08 · Mốc tự sinh từ sự kiện cứng

Thu hoạch chéo toàn bộ module đã có, **không xây feature mới** — đây là lý do idea
này rẻ bất thường so với giá trị.

| Lá | Nguồn trong repo | Điều kiện |
|---|---|---|
| I01 ngày ghép đôi | `pairing` | có sẵn |
| I02 ảnh thứ 100/500/1000 | `gallery` | đếm ảnh |
| I03 album đầu tiên | `gallery` | — |
| I04 kỷ niệm đầu vào dòng thời gian | `timeline` | — |
| I05 điều ước đầu vào hũ | `dream-jar` | — |
| I06 theme đầu mở khoá cùng nhau | `themes` | — |
| I07 lần đầu xuất kho | `data-export` | — |
| A01–A16 | `pairing.startDate` | thuần hàm ngày |
| — | `love-contracts` | giao ước xong = mốc (đã có sẵn consent hai phía) |

**Cấm tuyệt đối làm nguồn**: `pets` (level/happiness cày được) · tần suất nhắn tin
làm thước đo.

**`expenses` — chốt A-06 = lối 1 (có, chỉ mức sự kiện), thành L25.** Brainstormer
đã khuyến nghị cắt hẳn vì đóng góp biên gần bằng không; quyết định giữ lại được
nhận, kèm một hàng rào ở tầng hợp đồng chứ không phải ở tầng nhắc nhở:

- Module `milestones` được đọc từ `expenses` **đúng ba thứ**: **bản ghi có tồn tại
  không · ngày · nhãn loại**. Hết.
- **Trường số tiền không bao giờ đi vào module mốc**, không đi qua API mốc, không
  nằm trong payload widget, không lên hiện vật, không lên trang công khai.
- Ràng buộc này phải nằm trong **hợp đồng dữ liệu** (DTO/schema không có field số
  tiền), không phải trong một dòng lưu ý cho lập trình viên. Nếu con số không tồn
  tại trong kiểu dữ liệu thì đường trượt sang *"tụi mình đã cùng chi 12 triệu"* bị
  bịt vĩnh viễn ở tầng compiler, đúng loại số thứ ba mà **L6** cấm.

---

## 4. Đợt 2–4 — mô tả gọn

### F-09 · Trang công khai của tụi mình *(Đợt 2)*
Một URL của cặp, ngoài app, `web/` đã là Astro nên có sẵn chỗ đứng. Hiện: hộ chiếu
đã lọc theo khán giả `CK`, bộ đếm, lời chúc. **Đồng thuận hai chiều bắt buộc** để
bật; **một người tắt là tắt**; URL **thu hồi được** và khi thu hồi thì chết thật.
Không bao giờ hiện lá nhóm G ở dạng sự kiện đơn lẻ (L9).

### F-10 · Người làm chứng *(Đợt 2)*
Người ngoài **không cần cài app** (chốt c5, Q6). Trên trang công khai họ nhập tên +
quan hệ ("bạn cấp 3", "chị gái") rồi xác nhận. Đổi lại phải chịu: giới hạn phiên,
chống spam, và **cặp đôi gỡ được** bất kỳ ai. Lời mời cài app chỉ hiện **sau khi**
đã làm chứng. Đây là tầng nguồn mạnh nhất (T4) và là vòng lan truyền thật duy nhất.
Sinh K01, K02, K03, K04, K06, K07.

### F-11 · Danh hiệu & lời chúc bạn bè trao *(Đợt 2)*
K05: bộ danh hiệu vui do bạn bè bình chọn — "cặp ồn ào nhất", "cặp đi nhiều nhất".
**Định tính, không phần trăm** (Q2). Đây là thứ **thay cho mọi chỉ số chất lượng
quan hệ** mà hệ này đã cấm mình làm.

### F-12 · Cupid Wrapped cuối năm *(Đợt 2, ràng buộc lịch)*
Tổng kết năm dùng cả 5 tầng nguồn + đường màu `vibes`. Impact rất cao nhưng **lỡ
mùa là mất một năm** — nếu lịch giao hàng chạm Tết/cuối năm thì chen lên trước F-09.

### F-13 · Nhóm "sẹo" đầy đủ *(Đợt 3)*
Khác biệt thương hiệu lớn nhất. Chỉ **hỏi riêng từng người** (L8), không bao giờ hỏi
trong không gian chung. Cần đồng thuận hai chiều để ghi. **Chỉ khoe được ở dạng đã
vượt qua và đã tổng hợp** (L9): *"đã cùng nhau đi qua 8 tháng yêu xa"* thì được;
*"3/4: lần đầu cãi nhau"* thì không bao giờ.

### F-14 · Hệ sinh hiện vật đầy đủ *(Đợt 3)*
12 khung × 6 bố cục + 147 con dấu riêng = mỗi lá có hiện vật thật sự riêng, mà khối
lượng design chỉ là 12 + 6 + 147 icon. Gợi ý mạnh từ PMI: dùng **thang vật liệu kỷ
niệm cưới (giấy → gỗ → bạc → vàng)** làm bộ khung thị giác gốc cho cả 12 nhóm.

### F-15 · Nghi lễ 15 lá lớn *(Đợt 3)*
Chống rủi ro "đẹp đều = không gì nổi bật" bằng **phân cấp nghi lễ chứ không phải
phân cấp thiết kế**: 15 lá (A04, A07, A09, B01, B14, C02, C15, D01, D08, E01, G04,
H03, H06, J05, L05) được toàn màn hình + hoạt hình + âm thanh + gợi ý in; 132 lá còn
lại là thiệp tĩnh đẹp nhưng lặng lẽ.

### F-16 · Hearts faucet *(Đợt 3)*
**Hearts không mua được con dấu; con dấu đúc ra hearts** (L5). Một chiều, không đảo
ngược. Nối sang IDEA-20260828-001.

### F-17 · Tinh ý — auto-detect 9 lá *(Đợt 4)*
9 lá: C11, C13, C17, D01, E01, G01, G07, H02, H03. Ba lớp tín hiệu (nhịp / từ vựng /
ngoài chat), khớp mẫu **trên máy**, chỉ gửi mã tín hiệu, không lưu chữ, không trích
lại lời người dùng, tắt được, cấm hiển thị thành chỉ số (L17–L20). App **chỉ suy ra
để HỎI, không bao giờ để KẾT LUẬN** (L7). Danh mục: `signal-patterns.md`.

### F-18 · Bản in vật lý *(Đợt 4)* · F-19 · Mốc solo chặng 1 *(Đợt 4)*
F-18 là đường doanh thu. F-19 phụ thuộc IDEA-20260829-001; J05 *"Ngày trao kho kỷ
niệm cho người ấy"* được đánh giá là **mốc cảm xúc mạnh nhất toàn sản phẩm**.

---

## 5. Sáu phát hiện của vòng 8 (mới, không có trong 7 vòng trước)

Đây là phần đáng đọc nhất tài liệu này — bảy vòng trước làm ở mức khái niệm nên
chưa chạm vào bốn thứ sau.

**Trạng thái sau 2026-09-04:** phát hiện 1 đã giải bằng A-02 · phát hiện 3 đã giải
bằng A-03 *(giữ bản đầy đủ, nhưng tách chi phí ba phần — xem F-07)* · phát hiện 4
đã giải bằng A-04 · phát hiện 5 đã giải bằng A-01 → **L24** · phát hiện 2 và 6 là
kết luận thiết kế, không cần quyết định.

### Phát hiện 1 · ⚠️ Xung đột ngân sách tab với IDEA-20260828-002
App có 5 tab (`Nhà / Trò chuyện / Pet / Ví chung / Tôi`, chat gated bởi
`ChatEntryGate`). Idea sinh đôi **IDEA-20260828-002 đã xin ô "Ví chung"** cho
"Danh sách hoạt động". Nếu Hộ chiếu cũng xin một tab thì hai idea đụng nhau ở đúng
một ô, và ai vào backlog trước sẽ khoá người sau.
**→ Giải: Hộ chiếu KHÔNG lấy tab.** Xem `screen-map.md` §2.

### Phát hiện 2 · `TimelineScreen` là chủ nhà tự nhiên của Hộ chiếu
`idea.md` đã ghi *"`timeline` là nguyên thuỷ gần nhất với dấu mốc"* nhưng chưa rút
ra hệ quả: **Hộ chiếu không phải màn hình mới, nó là hình thái thứ hai của
`TimelineScreen`**. Timeline = nhật ký thủ công, Hộ chiếu = cùng dữ liệu đó nhưng
sắp theo lá bài và đóng dấu được. Một màn hình, hai chế độ xem. Tiết kiệm một tab
và giải luôn Phát hiện 1.

### Phát hiện 3 · ⚠️ S1 bị đánh giá thấp effort — phải tách đôi
Lưới Impact/Effort xếp **S1 = "Cao / Thấp" → làm ngay**. Nhưng S1 gộp hai thứ rất
khác nhau, và `pubspec.yaml` **không có `home_widget`** hay bất kỳ package widget
nào:
- **S1a bộ đếm** — thật sự effort thấp, thuần Dart.
- **S1b widget màn hình khoá** — native hai nền tảng: iOS WidgetKit + App Group để
  chia sẻ dữ liệu qua process boundary, Android AppWidget/Glance. Đây là
  **trung bình–cao**, không phải thấp.
**→ Đề nghị: giữ S1a mở màn Đợt 1; đẩy S1b (F-07) xuống cuối Đợt 1 hoặc đầu Đợt 2.**
Không huỷ — PMI đúng khi nói widget có thể là kênh khoe mạnh nhất — nhưng đừng để
nó chặn đường đi của F-03/F-06.

### Phát hiện 4 · ⚠️ Buổi ôn lại KHÔNG được chèn vào `onboarding_chain`
Repo có `core/navigation/onboarding_chain.dart` — chuỗi onboarding đã tồn tại và đã
có tỉ lệ rơi của nó. PMI vừa nói *"onboarding hồi tố có thể là màn hình hay nhất cả
app"* vừa cảnh báo *"có nguy cơ dài"*. Hai điều đó chỉ cùng đúng khi nó **không nằm
trong chuỗi đăng ký bắt buộc**.
**→ Buổi ôn lại không phải onboarding của app; nó là nghi thức đầu tiên TRONG app.**
Đặt sau khi đã vào Nhà, dạng lời mời hoãn được, quay lại bất cứ lúc nào. L23 ("bỏ
lỡ là chấp nhận được") đã cho phép điều này.

### Phát hiện 5 · Lỗ hổng chưa ai chạm: **người kia thấy gì?**
L4 chốt *"không cần đối phương hợp tác để mở khoá mốc thường"*. Nhưng con dấu là
vật thể của **cặp**, còn hành động lại của **một người**. Bảy vòng brainstorm chưa
thiết kế bề mặt cho người thứ hai. Ba lối:
- **(a) Hiện ngay, báo nhẹ, cả hai sửa/gỡ được như nhau** ← đề xuất. Đối xứng, và
  đúng L3 "không phạt khi im lặng": người kia im lặng không chặn gì cả.
- (b) Chờ người kia duyệt → vi phạm L4, và giết mốc khi một người ít mở app.
- (c) Hai hộ chiếu riêng rồi hợp nhất → phức tạp gấp đôi, phản ẩn dụ "của tụi mình".
Đây là **A-01**, câu hỏi cần bạn quyết. Xem `screen-map.md` §6.

### Phát hiện 6 · Hiện vật ngày-1 phải đẹp khi **không có ảnh**
PMI đã ghi minus *"chất lượng hiện vật phụ thuộc ảnh user đã có"* nhưng chưa rút hệ
quả thiết kế: người vừa cài app có 0 ảnh trong `gallery`. Nếu bố cục chủ lực cần
ảnh thì tấm thiệp đầu tiên — **tấm quan trọng nhất, vì nó quyết định có lan truyền
hay không** — sẽ là tấm xấu nhất. Vậy **"số lớn" và "tem hộ chiếu" phải là hai bố
cục được đầu tư nhất ở Đợt 1**, còn "ảnh tràn" là phần thưởng thêm.

---

## 6. Luật bất di bất dịch (rút gọn — bản đầy đủ ở `idea.md`)

Nhắc lại 9 luật mà **mọi màn hình đều phải tuân**, để không phải mở `idea.md`:

1. **L1 Không farm được** — mốc mua bằng thời gian và sự thật, không bằng số thao tác.
2. **L2 Không bao giờ so cá nhân** trong cặp. Không so chéo cặp (Q2).
3. **L3 Không phạt khi im lặng** — yêu xa, cãi nhau, quan hệ nguội: không mất gì.
   **Không streak. Không đứt chuỗi.**
4. **L4 Một người mở khoá được** mốc thường.
5. **L5 Hearts không mua được con dấu; con dấu đúc ra hearts.**
6. **L6 Luật hai loại số** — được mơ hồ ở *phán xét*, không được sai ở *sự kiện*.
   **Cấm vĩnh viễn loại thứ ba**: con số suy đoán giả vờ chính xác ("hợp nhau 92%").
7. **L7 App chỉ suy ra để HỎI, không bao giờ để KẾT LUẬN.**
8. **L9 Sẹo chỉ khoe ở dạng đã vượt qua và đã tổng hợp.**
9. **L23 Bỏ lỡ là chấp nhận được** — không có cơ chế đuổi bắt mốc đã lỡ.

Ba luật mới sinh ra từ các quyết định ngày 2026-09-04:

10. **L24 Ranh giới ghi/khoe** — ghi là việc của một người và hiện ngay; khoe ra
    ngoài app chỉ với con dấu mình đã tận mắt xem; **gỡ là quyền phủ quyết tức thời
    của cả hai**. Không có hàng chờ duyệt.
11. **L25 `expenses` chỉ ở mức sự kiện** — đọc được sự tồn tại, ngày, nhãn loại.
    **Số tiền không tồn tại trong kiểu dữ liệu của module mốc.**
12. **L26 Widget chỉ mang lá `CK`** — nhóm G và mọi lá khán giả `R` bị cấm vĩnh
    viễn khỏi màn hình khoá.

---

## 7. Đã loại — đừng thiết kế lại

- Bất kỳ **phần trăm, điểm số, thanh tiến độ tương thích** nào. Vi phạm L6.
- **Streak / chuỗi ngày** dưới mọi hình thức. Vi phạm L3.
- So sánh với cặp khác, bảng xếp hạng, "top 5% cặp đôi". Vi phạm Q2.
- **`pets` làm nguồn mốc khoe** (cày được) · **số tiền `expenses`** · **tần suất
  nhắn tin làm thước đo**.
- **Auto-detect vĩnh viễn cấm**: C07 lần đầu nói yêu · G10/G11/G14 mất mát ·
  L02 bàn chuyện cưới · mọi thứ thân mật thể xác · mọi suy luận về lỗi của một người.
- Lá đã bỏ ở vòng 6: **G03, I10, I11**.

---

## 8. Cần giao (khi idea này vào backlog)

- **Đợt 1** = `F-01 + F-02 + F-03 + F-04 + F-05 + F-06 + F-08`, **rồi F-07 cuối đợt**.
- **Quy tắc trượt đợt cho F-07**: nếu tới cuối Đợt 1 mà widget chưa xong thì nó
  **trượt sang Đợt 2**, không kéo dài Đợt 1. Vòng giá trị `M-01 → M-03 → M-06` là
  thứ định nghĩa Đợt 1 xong hay chưa, không phải widget.
- **Mốc lịch A-05**: Đợt 1 xong **trước 15/10/2026** → F-12 Wrapped chen trước
  F-09/F-10 ở Đợt 2. Sau mốc đó → giữ thứ tự cũ, Wrapped làm mùa 2027.
- Backend cần **một module mới `milestones`**: bộ bài (tĩnh), con dấu (theo cặp),
  lịch sử sửa `startDate`. Các nguồn khác chỉ **đọc** từ module có sẵn.
- Nội dung cần viết trước khi code: **147 tên lá theo giọng "tụi mình"** + **12 con
  dấu theo nhóm** (không phải 147 — PMI).
- Đầu vào cho Product Owner: tài liệu này + `screen-map.md` + `milestone-deck.md`.
- `signal-patterns.md` **KHÔNG thuộc phạm vi Đợt 1** — để dành Đợt 4.
