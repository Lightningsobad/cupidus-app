# Bản đồ màn hình + User Journey — IDEA-20260831-001 (vòng 8)

Đọc `design-brief.md` trước (danh sách 19 tính năng F-01…F-19).
Tài liệu này trả lời: **những tính năng đó sống ở màn hình nào**, và
**người dùng đi qua chúng theo trình tự nào**.

Đối chiếu trên mã nguồn thật: `mobile/lib/features/**` (39 màn hình app) +
`mobile/lib/core/navigation/app_shell.dart` + `web/src/pages/` (Astro).

**Sáu quyết định A-01…A-06 đã chốt ngày 2026-09-04** — xem Phần 6. Tài liệu này đã
được cập nhật theo bản chốt; không còn câu hỏi chặn khâu vẽ màn hình.

---

## Phần 1 — Ngân sách tab: **không xin ô nào**

Tab hôm nay (`app_shell.dart`, `_ShellDestination` × 5, Chat gated bởi
`ChatEntryGate`):

| Tab | Hôm nay | Sau idea này |
|---|---|---|
| 1 | Nhà (`HomeScreen`, 1099 dòng) | **Nhà** — thêm thẻ mốc *(SỬA)* |
| 2 | Trò chuyện *(gated)* | Trò chuyện — **không chạm tới Đợt 4** |
| 3 | Pet | Pet — **cấm tham gia** |
| 4 | Ví chung | Ví chung — không đổi |
| 5 | Tôi | **Tôi** — thêm lối vào trang công khai *(SỬA)* |

⇒ **Ngân sách tab không đổi. Idea này không lấy tab nào.**

Lý do (design-brief §5 Phát hiện 1): idea sinh đôi **IDEA-20260828-002 đã xin ô
"Ví chung"**. Nếu Dấu Mốc cũng xin một tab thì hai idea đụng nhau ở đúng một ô và
idea nào vào backlog trước sẽ khoá idea sau. Tránh được xung đột đó **mà không mất
gì**, nhờ Phát hiện 2.

**Hộ chiếu vào bằng hai cửa, không bằng tab:**
1. **Thẻ mốc trên `HomeScreen`** — cửa chính, hằng ngày.
2. **`TimelineScreen` có hai chế độ xem** — `Dòng thời gian | Hộ chiếu`.
   Timeline hôm nay là nhật ký thủ công (`TimelineEvent`: coupleId, type, title,
   description, photoUrl, icon, createdAt); Hộ chiếu là **cùng loại dữ liệu đó
   nhưng có lá bài và đóng dấu được**. Không phải hai màn hình rời — là một màn
   hình, hai cách sắp.

`TimelineScreen` hiện được push từ `home_screen.dart:1087`, tức là lối vào đã tồn
tại. Cần **nâng nó lên thành lối vào hạng nhất**, không phải chôn dưới đáy Nhà.

---

## Phần 2 — Bảng tổng màn hình

Loại: **MỚI** · **SỬA** (đổi nội dung/hình thái) · **NỐI** (đã có, chỉ thiếu dây
sinh mốc) · **GIỮ** · **CHỜ** (chỉ chạm ở đợt sau) · **CẤM** (cố ý không tham gia)

### 2.1 Màn hình MỚI

| ID | Màn hình | Đợt | Nơi ở | Journey | Tính năng |
|---|---|---|---|---|---|
| **M-01** | Ngày gốc của tụi mình | 1 | **trong `onboarding_chain`** + sheet từ `HomeScreen` | J1 | F-01 |
| **M-02a** | Hạt giống — **5 lá trong chain** | 1 | **trong `onboarding_chain`**, sau M-01 | **J1** | **F-03** |
| **M-02b** | ⭐ Buổi ôn lại đầy đủ — 142 lá | 1 | toàn màn hình, vào từ Nhà, hoãn được | **J1** | **F-03** |
| **M-03** | Hộ chiếu | 1 | **chế độ xem 2 của `TimelineScreen`** | J1,J2,J4 | F-05 |
| **M-04** | Một con dấu | 1 | push từ M-03 | J2,J3,J4 | F-04·F-05·F-06 |
| **M-05** | Kho bài 147 lá | 1 | push từ M-03 | J1,J3 | F-02 |
| **M-06** | ⭐ Xưởng hiện vật | 1 | push từ M-04 / M-07 | **J2**,J3 | **F-06** |
| **M-07** | Nghi lễ mốc mới | 1 | toàn màn hình, chèn ngang | J2 | F-15 *(bản rút gọn)* |
| **M-08** | Bật / thu hồi trang công khai | 2 | push từ `PrivacyScreen` | J5 | F-09 |
| **M-09** | ⭐ Trang công khai của tụi mình | 2 | **`web/` — Astro, ngoài app** | J5,**J6** | **F-09** |
| **M-10** | ⭐ Làm chứng | 2 | **`web/` — người lạ, không cài app** | **J6** | **F-10** |
| **M-11** | Người làm chứng & lời chúc | 2 | push từ M-03 | J5,J6 | F-10·F-11 |
| **M-12** | Cupid Wrapped | 2† | toàn màn hình theo mùa | — | F-12 |
| **M-13** | Khu sẹo — sau vách ngăn | 3 | trong M-02 và M-05 | J7 | F-13 |
| **M-14** | Hộp thư hỏi riêng | 3 | push từ `MeScreen` | J7 | F-13·F-17 |
| **M-15** | Cài đặt tinh ý | 4 | push từ `NotificationSettingsScreen` | — | F-17 |
| **M-16** | Đặt in | 4 | push từ M-06 | — | F-18 |

**14 màn hình app mới + 2 trang web mới.** M-09/M-10 không phải màn hình Flutter —
đó là điều kiện tiên quyết của F-10 (người làm chứng **không cần cài app**, chốt c5).

### 2.2 Màn hình có sẵn bị chạm

| Màn hình hiện có | Loại | Đợt | Việc phải làm |
|---|---|---|---|
| `HomeScreen` *(1099 dòng)* | **SỬA** | 1 | Thẻ "mốc vừa đạt / mốc sắp tới" + lời mời **M-02** hoãn được + lối vào Hộ chiếu hạng nhất |
| `TimelineScreen` *(490 dòng)* | **SỬA lớn** | 1 | Thêm chế độ xem thứ hai = **M-03**. `TimelineEvent` sinh I04 |
| `PairedScreen` | **SỬA** | 1 | Sinh I01; chèn lời mời khai **ngày bắt đầu thật** (≠ ngày ghép đôi) → M-01 |
| `GalleryViewerScreen` | **SỬA** | 1 | Từ một ảnh: *"đây là mốc gì của tụi mình?"* → M-04 |
| `ProfileEditScreen` | **SỬA** | 1 | Ngày sinh → điều kiện của A14/A15 |
| `MeScreen` *(749 dòng)* | **SỬA** | 2 | Lối vào trang công khai · quyền riêng tư mốc · lối vào **M-14** |
| `PrivacyScreen` | **SỬA** | 2 | Đồng thuận hai chiều · thu hồi URL → **M-08** |
| `NotificationSettingsScreen` | **SỬA** | 2/4 | Bật/tắt thông báo mốc · **thông báo khi ngày gốc bị đổi** · hạn ngạch hỏi riêng |
| `GalleryScreen` | **NỐI** | 1 | Đếm ảnh → I02 · album đầu → I03 · nguồn ảnh cho **M-06** |
| `DreamJarDetailScreen` | **NỐI** | 1 | Ước thành thật → I05 |
| `LoveContractScreen` | **NỐI** | 1 | Giao ước xong → mốc *(đã sẵn consent hai phía)* |
| `VowScreen` | **NỐI** | 1 | Lời thề → mốc |
| `ThemeStoreScreen` | **NỐI** | 1 | Theme đầu mở khoá cùng nhau → I06 |
| `ExpenseHistoryScreen` | **NỐI** | 1 | ⚠️ **A-06=1 + L25**: đọc được **sự tồn tại · ngày · nhãn loại**. **Số tiền không có trong kiểu dữ liệu của module mốc** |
| `VibeScreen` | **NỐI** | 2 | Tầng 5 — đường màu cả năm cho Wrapped |
| `ChatScreen` | **CHỜ** | **4** | ⚠️ **Đợt 1–3 tuyệt đối không chạm.** Đợt 4: khớp mẫu **trên máy**, chỉ gửi mã tín hiệu |
| `AntiGhostScreen` | **CHỜ** | 4 | Tín hiệu hiểu lầm cho F-17 |
| `PetScreen` | **CẤM** | — | ⚠️ **Cố ý không tham gia.** `level`/`happiness` cày được → vi phạm L1 |
| *(21 màn hình còn lại)* | **GIỮ** | — | auth ×6 · pairing ×5 · dream jar ×3 · onboarding ×2 · theme detail · emoji store · ghost settings · reminders · zodiac |

**Đếm: 14 MỚI (app) + 2 MỚI (web) · 8 SỬA · 7 NỐI · 2 CHỜ · 1 CẤM · 21 GIỮ.
Không màn hình nào bị xoá. Không tab nào bị chiếm.**

**Riêng Đợt 1: 7 MỚI · 5 SỬA · 6 NỐI.** Đây là con số nhỏ đáng ngạc nhiên cho một
idea 147 lá bài — vì phần lớn khối lượng là **nội dung** (147 tên lá + 12 con dấu),
không phải màn hình.

**MẪU dùng lại, không phải màn hình**: lật bài (M-02, M-05) · vách ngăn (M-13) ·
nghi lễ chèn ngang (M-07) · thẻ chia sẻ (M-06). Chúng xuất hiện *bên trong* màn
hình khác, không đứng riêng.

---

## Phần 3 — Bảy màn hình mới của Đợt 1 (mức nghiệp vụ)

### M-01 · Ngày gốc của tụi mình — **bước duy nhất được chèn vào `onboarding_chain`**
Một sheet, không phải màn hình đầy. Hỏi đúng một câu: *"Tụi mình bắt đầu từ ngày
nào?"* — và nói rõ **đây không phải ngày cài app**.

- Sửa lùi tự do, vĩnh viễn, không khoá (Q5).
- **Mỗi lần đổi, phía kia luôn được báo**: ngày cũ → ngày mới, ai đổi. Đây là toàn
  bộ cơ chế chống lạm dụng — xã hội, không phải kỹ thuật.
- Sau khi khai xong, dẫn thẳng sang M-02 *(nhưng hoãn được)*.

### M-02 · ⭐ Buổi ôn lại — **màn hình quan trọng nhất Đợt 1**
Lướt 147 lá dạng bài lật: **Rồi / Chưa / Để sau**.

- Xếp theo **xác suất đã xảy ra**, suy từ độ dài quan hệ ở M-01. Cặp 3 tháng và cặp
  5 năm thấy hai thứ tự khác hẳn nhau.
- Chia đợt, có điểm dừng tự nhiên: *"còn 90 lá nữa, xem tiếp không?"*
- Bấm "Rồi" là đóng dấu xong. **Hỏi ngày là tuỳ chọn**, mặc định nhận khoảng thời
  gian ("khoảng hè 2024") — đúng L6, thà mơ hồ thành thật còn hơn chính xác bịa.
- **Nhóm G sau vách ngăn** (**M-13**), cuối cùng: *"Phần tiếp theo nói về những lúc
  khó. Xem sau cũng được."*
- Làm một mình được, không đợi người kia (L4).

**Chốt A-04 = lối 4 — tách làm hai nửa:**

- **M-02a hạt giống, TRONG `onboarding_chain`**: đúng **5 lá xác suất cao nhất**,
  ngay sau M-01. **Cứng dưới 60 giây.** Không lá nào thuộc nhóm G. Cộng với 16 mốc
  nhóm A do M-01 sinh ra, người dùng **bước ra khỏi đăng ký với ~20 con dấu**.
- **M-02b buổi ôn lại đầy đủ, NGOÀI chain**: 142 lá còn lại, lời mời trên
  `HomeScreen`, hoãn được, quay lại được, không có màn bắt buộc hoàn thành.

Vì sao tách: đặt cả 147 lá trong chain thì giết tỉ lệ hoàn thành đăng ký (PMI đã
cảnh báo "nguy cơ dài"); đặt cả 147 lá ngoài chain thì người dùng bước vào app lần
đầu và thấy **hộ chiếu rỗng** — đúng thứ bệnh mà tính năng này sinh ra để chữa.

**Chỉ số duy nhất đáng đo ở Đợt 1: thời lượng thật của M-02.** Nếu nó mất 20 phút,
tính năng tự giết chính nó.

### M-03 · Hộ chiếu — *chế độ xem thứ hai của `TimelineScreen`* **(chốt A-02 = lối 1)**

⚠️ **Điều kiện bắt buộc đi kèm quyết định này**: `TimelineScreen` hôm nay bị chôn
(push từ `home_screen.dart:1087`). **Lối vào phải được nâng lên hạng nhất** trên
`HomeScreen`. Nếu giữ nguyên chỗ chôn thì trái tim sản phẩm nằm dưới đáy và cả Đợt 1
mất tác dụng — đây là rủi ro số một của lối 1.

Con dấu sắp theo thời gian, nhóm theo năm/mùa.

- Lá chưa đạt hiện **mờ, không hiện dạng nhiệm vụ**. **Không thanh tiến độ, không
  phần trăm, không "còn 118 mốc nữa"** — hộ chiếu là *đã đi tới đâu*, không phải
  *còn thiếu bao nhiêu*.
- Đếm được: "24 con dấu · 3 năm · 4 người làm chứng" — đếm **sự kiện**, không điểm.
- Chuyển qua lại `Dòng thời gian ⇄ Hộ chiếu` không mất chỗ đang xem.
- I08 (*hộ chiếu đủ N con dấu*) là mốc meta của chính hệ này.

### M-04 · Một con dấu — **(chốt A-01 = lối d → L24)**
Ngày (hoặc khoảng) · ảnh tuỳ chọn · một dòng ghi chú · vòng khán giả (CK/BT/R) ·
**ai đã đóng dấu này**. Hai nút: **"Làm thiệp"** → M-06, và **sửa/gỡ** — mở cho
**cả hai người như nhau**.

Ba trạng thái phải vẽ, và **không có trạng thái "chờ duyệt"**:

| Trạng thái | Ai thấy gì | Khoe được chưa |
|---|---|---|
| Mình vừa đóng | hiện ngay trong hộ chiếu; người kia nhận thông báo nhẹ | **Được ngay** |
| Người kia đóng, **mình chưa mở xem** | có trong hộ chiếu, gắn chấm "mới" | **Chưa** — nút "Làm thiệp" chưa mở |
| Người kia đóng, **mình đã mở xem** | như mọi con dấu khác | **Được** — mở xem *là* xác nhận |

**Gỡ = phủ quyết tức thời.** Ai gỡ thì con dấu biến khỏi mọi bề mặt khoe ngay, kể
cả trang công khai. Ảnh đã gửi đi thì không thu hồi được — phải nói thẳng câu đó
với người dùng ở màn xác nhận gỡ, không giả vờ làm được.

### M-05 · Kho bài 147 lá
Toàn bộ bộ bài, **luôn mở, không giấu lá nào**. Xem được cả lá chưa đạt. Đây là nơi
tự khai chủ động: chọn lá → đánh dấu đã đạt. Nhóm G sau vách ngăn.

### M-06 · ⭐ Xưởng hiện vật — **thứ duy nhất rời khỏi app ở Đợt 1**
Đầu vào một con dấu, đầu ra một ảnh dọc tỉ lệ story, chia sẻ bằng `share_plus`
*(đã có trong `pubspec.yaml`)*.

- **Ba bố cục Đợt 1**: **số lớn** · **tem hộ chiếu** · **ảnh tràn**.
- ⚠️ **Hai bố cục không cần ảnh phải là hai bố cục đẹp nhất** (design-brief §5 Phát
  hiện 6): người vừa cài app có 0 ảnh trong `gallery`, mà tấm thiệp đầu tiên lại là
  tấm quyết định có lan truyền hay không.
- Ảnh lấy từ `GalleryScreen` hoặc máy ảnh.
- Dấu Cupid nhỏ, sang, ở mép — **không phải watermark quảng cáo**. Thứ người ta
  không muốn cắt đi.

### M-07 · Nghi lễ mốc mới
Chèn ngang, toàn màn hình, khi một mốc vừa đạt. Đợt 1 dùng **bản rút gọn**: một
hoạt hình chung + con dấu nhóm. Nghi lễ đầy đủ 15 lá lớn nằm ở F-15 (Đợt 3).
Kết thúc luôn dẫn sang M-06 — **nghi lễ không có nút thoát cụt**.

---

## Phần 4 — Bảy user journey

### J1 — 10 phút đầu của cặp đã yêu 2 năm ⭐ *(Đợt 1 · F-01,F-02,F-03,F-05,F-06)*
Journey quyết định sống chết của Đợt 1.

`PairedScreen` *(vừa ghép đôi)* → **M-01** *"Tụi mình bắt đầu từ ngày nào?"* → khai
`12/2024` → app nói *"Vậy tụi mình đã đi cùng nhau 634 ngày rồi"* + **16 mốc nhóm A
tự đóng dấu ngay lập tức** → `HomeScreen` với thẻ *"Tụi mình có 16 con dấu. Xem lại
những gì đã đi qua?"* → **M-02** buổi ôn lại → lướt ~40 lá xác suất cao → bấm "Rồi"
15 lần → **M-03 Hộ chiếu có 31 con dấu** → chọn A09 "1000 ngày" → **M-06** → tấm
thiệp bố cục **số lớn** *(chưa có ảnh nào — và vẫn đẹp)* → chia sẻ.

**Điểm chết cần canh**: nếu M-02 dài quá, người dùng bỏ ở lá thứ 12 và không bao giờ
tới M-06. Vì vậy M-02 phải chia đợt và **thoát ra lúc nào cũng vẫn có hộ chiếu**.

### J2 — Sáng có mốc mới *(Đợt 1 · F-07,F-08,F-15,F-06)*
Widget màn khoá đếm `633 → 634`, ngay dưới là *"sắp tới: 700 ngày — còn 66"* →
đúng ngày, thông báo *"Hôm nay tụi mình tròn 700 ngày"* → mở app → **M-07 nghi lễ**
→ **M-06** → đăng story.

Chốt **A-03 = lối 2 (widget đầy đủ)**: widget mang **bộ đếm + mốc gần nhất + mốc
sắp tới**. Hai trong ba phần đó là hàm thuần của `startDate` nên tính offline được;
chỉ "mốc gần nhất đã đạt" cần app ghi một bản ghi sang App Group/DataStore rồi
reload. **L26**: widget chỉ mang lá khán giả `CK` — nhóm G và lá `R` bị cấm vĩnh
viễn khỏi màn khoá.

Đây là vòng lặp giữ chân **hằng ngày**, khác J1 là vòng **một lần**. Nếu tới cuối
Đợt 1 mà widget chưa xong thì **nó trượt sang Đợt 2, không kéo dài Đợt 1** — J2 tạm
chạy bằng thông báo thường, yếu hơn nhưng vẫn chạy.

### J3 — Ghi một mốc vừa xảy ra, từ một tấm ảnh *(Đợt 1 · F-04,F-06)*
Vừa đi Đà Lạt về → `GalleryScreen` → mở ảnh → `GalleryViewerScreen` *"đây là mốc gì
của tụi mình?"* → **M-05** gợi ý D-nhóm *"Chuyến đi đầu tiên"* → **M-04** đặt ngày +
gắn ảnh → **M-06** bố cục **ảnh tràn**.

Đây là đường mà **`gallery` trở thành nguồn**, không chỉ là kho.

### J4 — ⭐ Người kia thấy gì *(Đợt 1 · lỗ hổng A-01)*
An bấm "Rồi" cho C15 lúc 11 giờ đêm. **Bình mở app sáng hôm sau và thấy gì?**

**Chốt A-01 = lối (d) → L24.** Bình nhận **một thông báo nhẹ** *"An vừa đóng dấu:
Lần đầu về ra mắt nhà An"* → con dấu đã nằm sẵn trong hộ chiếu, gắn chấm "mới" →
Bình mở **M-04** → thấy đủ ngày/ảnh/ai đóng → **sửa hoặc gỡ được y hệt An**, và từ
lúc mở xem thì Bình cũng **khoe được**. Không có bước duyệt, không có hàng chờ.

Vì sao không cho duyệt: L4 nói một người mở khoá được mốc thường, và L3 nói im lặng
không bị phạt. Nếu bắt duyệt thì mốc chết mỗi khi một người ít mở app — mà cặp yêu
xa (nhóm H, ngách cảm xúc cao nhất) chính là nhóm hay im lặng nhất.

Vì sao vẫn siết ở khâu khoe: L4 nói về *mở khoá mốc*, nó chưa bao giờ nói về *khoe*.
Mà Q1 (công khai internet) vốn đã đòi đồng thuận hai chiều — nên L24 không phải luật
mới, chỉ là kéo ranh giới đã có về đúng chỗ.

Rủi ro còn lại, đã biết và chấp nhận: An khoe được một con dấu Bình chưa kịp xem.
Bù lại Bình luôn được báo và luôn gỡ được. Nhóm G (sẹo) không dính rủi ro này vì
Đợt 3 đòi **đồng thuận hai chiều ngay từ khâu ghi**.

### J5 — Bật trang công khai *(Đợt 2 · F-09)*
`MeScreen` → `PrivacyScreen` → **M-08** → An bật → **Bình nhận yêu cầu đồng thuận**
→ Bình đồng ý → URL sinh ra → hộ chiếu lọc còn lá `CK` → chia sẻ link.

Ba luật cứng của màn này: **đồng thuận hai chiều mới bật** · **một người tắt là
tắt** · **thu hồi là chết thật, không phải ẩn**. Và **không bao giờ có lá nhóm G ở
dạng sự kiện đơn lẻ** (L9).

### J6 — ⭐ 60 giây của người lạ *(Đợt 2 · F-10,F-11)*
Journey nuôi tăng trưởng. Người xem **chưa có app và có thể sẽ không bao giờ cài**.

Thấy link trên story → mở **M-09** *(web)* → thấy hộ chiếu + bộ đếm → nút
*"Mình xác nhận chuyện này"* → **M-10**: nhập tên + quan hệ *("bạn cấp 3")* → xong →
**K01/K02 đóng dấu** → **chỉ lúc này** mới hiện lời mời cài app.

Ba ràng buộc: **không bắt đăng nhập** · chống spam bằng giới hạn phiên · **cặp đôi
gỡ được bất kỳ ai** *(M-11)*. `web/src/components/share/` đã tồn tại — có chỗ đứng
sẵn, không phải dựng hạ tầng web mới.

### J7 — Một cái sẹo được ghi *(Đợt 3–4 · F-13,F-17)*
Chỉ **hỏi riêng** (L8). `MeScreen` → **M-14 hộp thư hỏi riêng** → *"Mấy hôm nay yên
ắng hơn thường lệ. Có chuyện gì tụi mình đã đi qua không?"* → **M-13 sau vách ngăn**
→ chọn G04 → ghi.

Con dấu này **không lên trang công khai ở dạng sự kiện**. Nhiều tháng sau nó chỉ hiện
ra dưới dạng tổng hợp: *"đã cùng nhau đi qua 8 tháng yêu xa"* (L9).

Giọng: **ấm ở sự QUAN TÂM, không ấm ở sự SUY DIỄN** (L22). App được phép dịu dàng,
không được phép khẳng định điều nó chưa biết.

---

## Phần 5 — Thứ tự dựng của Đợt 1

Dây phụ thuộc thật, rút từ bảng trên:

```
M-01 ngày gốc ──► 16 mốc nhóm A ──► M-03 hộ chiếu ──► M-06 xưởng ──► CHIA SẺ
       │                              ▲     ▲                          (kênh duy nhất)
       └──► M-02 buổi ôn lại ─────────┘     │
                    │                       │
                    └──► M-05 kho bài ──► M-04 một con dấu
                                              ▲
       F-08 nguồn có sẵn (gallery/timeline/dream-jar/…) ┘
```

Bốn chặng, mỗi chặng tự đứng được nếu phải dừng:

1. **M-01 + nhóm A + M-03** — hôm nay cài, hôm nay có hộ chiếu. *Vẫn có giá trị nếu
   dừng ở đây.*
2. **M-06** — có thứ đăng được. **Không được dừng trước chặng này**: dừng ở chặng 1
   là làm ra một cái timeline thứ hai.
3. **M-02 + M-05 + M-04** — hộ chiếu dày lên từ 16 lên ~40 con dấu.
4. **M-07 + F-07 widget** — vòng lặp hằng ngày.

---

## Phần 6 — Sáu quyết định **ĐÃ CHỐT** (2026-09-04)

| Mã | Chốt | Hệ quả trong tài liệu này |
|---|---|---|
| **A-01** | **(d)** ghi = một người · khoe = hai người → **L24** | M-04 có 3 trạng thái, **không có hàng chờ duyệt**; J4 viết lại |
| **A-02** | **(1)** Hộ chiếu = chế độ xem 2 của `TimelineScreen` | **0 tab mới.** Kèm điều kiện bắt buộc: nâng lối vào lên hạng nhất trên `HomeScreen` |
| **A-03** | **(2)** widget **bản đầy đủ** → **L26** | J2 viết lại; 2/3 phần tính offline, chỉ "mốc gần nhất" cần đồng bộ; widget chỉ mang lá `CK` |
| **A-04** | **(4)** chain giữ 1 câu + 5 lá | M-02 tách thành **M-02a** (trong chain) + **M-02b** (ngoài chain) |
| **A-05** | **(4)** luật kích hoạt | Đợt 1 xong **trước 15/10/2026** → Wrapped chen trước F-09/F-10; sau đó → mùa 2027 |
| **A-06** | **(1)** `expenses` chỉ mức sự kiện → **L25** | Hàng rào đặt ở **hợp đồng dữ liệu**, không phải ở lưu ý cho lập trình viên |

**Hai override cần người thực thi biết rõ:**

- **A-03** đi ngược khuyến nghị "chỉ bộ đếm". Đã nhận, và chi phí thật hoá ra thấp
  hơn lo ngại ban đầu vì **mốc sắp tới cũng là hàm thuần của `startDate`** — chỉ
  một trong ba phần cần đồng bộ. Đổi lại sinh **L26**, vì widget là bề mặt công
  khai nhất trong đời sống hằng ngày.
- **A-06** đi ngược khuyến nghị "cắt hẳn". Đã nhận, kèm **L25** đặt ràng buộc ở tầng
  kiểu dữ liệu: nếu trường số tiền không tồn tại trong DTO của module mốc thì đường
  trượt bị bịt ở tầng compiler chứ không phải ở tầng kỷ luật.

**Không còn câu hỏi chặn.** Khâu vẽ màn hình mở.

---

## Phần 7 — Cần cho Product Owner khi idea này vào backlog

- **Phạm vi requirement đầu tiên = Đợt 1**, bảy màn hình mới M-01…M-07 + 5 SỬA +
  6 NỐI. Không tab mới, không màn hình bị xoá.
- **Một module backend mới `milestones`**: bộ bài (tĩnh), con dấu (theo cặp), lịch
  sử sửa `startDate`. Mọi nguồn khác chỉ **đọc** từ module đã có.
- **Nội dung phải viết xong trước khi code**: 147 tên lá theo giọng "tụi mình" +
  **12 con dấu theo nhóm** (không phải 147 — PMI đã cắt).
- **`ChatScreen` và `PetScreen` nằm ngoài phạm vi Đợt 1–3** một cách cố ý. Đây là
  ràng buộc, không phải thiếu sót.
- Xung đột phải giải trước khi cả hai idea vào backlog: **ô tab "Ví chung"** đang bị
  IDEA-20260828-002 xin. Idea này đã tự tránh (A-02=1), nhưng người xếp lịch cần biết.
- **Ba luật mới sinh ngày 2026-09-04**, phải mang theo vào requirement:
  **L24** ranh giới ghi/khoe · **L25** `expenses` chỉ mức sự kiện, số tiền không tồn
  tại trong kiểu dữ liệu · **L26** widget chỉ mang lá `CK`, cấm nhóm G.
- **Hai quy tắc lịch**: F-07 chưa xong cuối Đợt 1 thì **trượt sang Đợt 2**, không kéo
  dài Đợt 1 · Đợt 1 xong trước **15/10/2026** thì Wrapped chen lên ở Đợt 2.
