# Bản đồ màn hình + User Journey — IDEA-20260828-002 (vòng 15)

**Ghi ranh giới (A-20, user quyết 2026-09-03):** tệp này liệt kê **màn hình, vai trò,
nội dung ở mức nghiệp vụ, lối vào/ra**. Nó **không** phải đặc tả UI — không layout,
không component, không token, không state machine. Đặc tả là việc `ui-ux-designer`
sau handoff. User đã yêu cầu rõ mức này; brainstormer ghi nhận là quyết định của user.

Nền chứng cứ: `wiring-map.md` (vòng 14) + quét mã vòng 15.
**App hôm nay có 39 màn hình thật** (không tính preview stub).

---

## Phần 0 — Đính chính vòng 14

- **D14-6 sửa:** `vow` **có** builder đăng ký (`service_locator.dart:511`), **có** route,
  và trạng thái **có** lưu qua cờ `profile.vowTaken`
  (`onboarding_progress_resolver.dart:46`). Đúng hơn: **không có module backend riêng,
  chỉ có một cờ boolean trên profile.** Kết luận D14-5 (dời) **không đổi**; chỉ chi phí
  dời là thấp hơn tôi ước.
- **D14-9 sửa một phần:** `love_contracts` **không** bị chôn — `MeScreen` có mục
  "Love contract" (`me_screen.dart:347`). Vẫn bị chôn thật: **`ExpenseHistoryScreen`**
  (chỉ `expenses_route.dart` trỏ tới, không ai gọi route đó) và **`GalleryScreen`**
  (không tệp nào ngoài thư mục gallery tham chiếu).

---

## Phần 1 — Ngân sách tab sau thay đổi

Cơ chế đã có sẵn: `_ShellDestination` + `ChatEntryGate` cho phép tab **xuất hiện/biến
mất theo điều kiện** mà index không vỡ (D14-4). Ta dùng lại đúng cơ chế đó, đổi tên
khái niệm thành `ModeGate`.

| Tab | Chặng 1 (một người) | Chặng 2 (cặp đôi) | Ghi chú |
|---|---|---|---|
| 1 | **Nhà** (hình thái solo) | **Nhà** (hình thái cặp — `HomeScreen` hôm nay) | S-02 / GIỮ |
| 2 | *(ẩn)* | Trò chuyện | `ChatEntryGate` đã làm sẵn |
| 3 | **Danh sách** | **Danh sách** | S-03 — chiếm ô "Ví chung" |
| 4 | *(ẩn)* | Pet | Pet vô nghĩa khi một mình |
| 5 | Tôi | Tôi | GIỮ |

⇒ Chặng 1 thấy **3 tab**, chặng 2 thấy **5 tab**. Không tăng ngân sách tab. Dream Jar
rời tab, thành **bộ lọc "tầm xa"** bên trong S-03 (design-brief §5: *"một danh sách,
nhiều tầm xa, không phải hai màn hình rời"*).

---

## Phần 2 — Bảng tổng màn hình

Loại: **MỚI** · **SỬA** (đổi nội dung/hình thái) · **DỜI** (đúng thứ, sai chỗ) ·
**NỐI** (đã có, chỉ thiếu lối vào) · **GIỮ** · **CHỜ** (phụ thuộc quyết định)

| ID | Màn hình | Loại | Màn hình hiện có | Chặng | Journey | Tính năng idea |
|---|---|---|---|---|---|---|
| **S-01** | Chọn chế độ | **MỚI** | — (chèn sau `profileSetup`) | cả hai | J1 | C0 · D14-1 |
| **S-02** | Nhà — hình thái một người | **MỚI** (hình thái) | `HomeScreen` | 1 | J1,J2 | §5.0 · CS7 · CS8 |
| **S-03** | Danh sách hoạt động | **MỚI** (tab) | thay ô `DreamJarListScreen` | cả hai | J2,J3,J5 | **C1** xương sống · gộp `dream_jar` |
| **S-04** | Một hoạt động | **MỚI** | — | cả hai | J2,J5 | C1 · C3 · AC7 |
| **S-05** | Khu riêng của tôi | **MỚI** | — | cả hai | J2 | **C6** nhật ký riêng (ii-b) |
| **S-06** | Máy quyết định | **MỚI** | — | cả hai | J2,J5 | C2 · §5.1 |
| **S-07** | Khoảnh khắc mời | **SỬA** | `WaitingScreen` | 1→2 | **J3** | **C0 · G-b** |
| **S-08** | Người thứ hai nhận lời | **SỬA** | `JoinCodeScreen` | 2 | **J4** | CS5 · CS6 · D13-7 |
| **S-09** | Vừa thành đôi | **SỬA** | `PairedScreen` | 2 | J4,J5 | CS11 · D12-2 |
| **S-10** | Nghi thức đổi chế độ | **DỜI** | `LoveContractScreen` + `VowScreen` | 1→2 | **J5** | PRIM-1 · §4.3 |
| **S-11** | Ghép đôi — chọn cách | **SỬA** | `PairingChoiceScreen` | cả hai | J1,J3 | hết bắt buộc, thành tuỳ chọn |
| **S-12** | Nhà — hình thái cặp đôi | **GIỮ** | `HomeScreen` (1099 dòng) | 2 | J5 | dùng nguyên vẹn |
| **S-13** | Dòng thời gian | **NỐI** | `TimelineScreen` | 2 | J5 | **C7** cột mốc · **C16** ký ức tự viết |
| **S-14** | Chi tiêu | **NỐI** *(đang bị chôn)* | `ExpenseHistoryScreen` | 2 | J5 | **AC7** chia tiền chuyến đi |
| **S-15** | Album | **NỐI** *(đang bị chôn)* | `GalleryScreen` | 2 | J5 | album buổi hẹn · C16 |
| **S-16** | Kỳ vọng liên lạc | **SỬA** | `AntiGhostScreen` | 2 | J5 | **RS1** hai chìa khoá |
| **S-17** | Nhắc nhau | **SỬA** | `ReminderScheduleScreen` | 2 | J5 | **C14** ô giữa (90% quỹ thời gian) |
| **S-18** | Hồ sơ của tôi | **SỬA** | `ProfileEditScreen` | cả hai | J1,J4 | **D13-6** tự khai · thêm `gender` cho BD1/GA3. **KHÔNG hỏi vai** — A-16=1, vai đọc từ phễu (L19) |
| **S-19** | Tôi | **SỬA** | `MeScreen` | cả hai | mọi J | đổi chế độ · **L14** đẩy ra ngoài |
| **S-20** | Chiêm tinh — hạt câu hỏi | **SỬA** *(A-19=3 chốt)* | `ZodiacRedFlagScreen` **đổi tên** | cả hai | J2,J5 | **C8 hồi sinh** · RS2 · vòi đổ vào PRIM-2 |
| **S-21** | Pet | **SỬA** *(A-21=1 chốt)* | `PetScreen` + `pet_stats_row` | 2 | J5 | phản ánh **nhịp**, bỏ `level`/`points`/`percent`/`streak`; giữ `mood` định tính |
| — | welcome/login/register/otp/permissions/profileSetup/invite/scanCode/chat/theme store/emoji store/privacy/notifications/ngôn ngữ/… | **GIỮ** | 18 màn hình | | | không thuộc phạm vi idea |

**Đếm (chốt c18): 6 MỚI · 11 SỬA · 1 DỜI · 3 NỐI · 0 CHỜ · 18 GIỮ. Không màn hình nào bị xoá.**

⭐ Sáu màn hình mới, và **không màn hình nào bị xoá**. So với giả định ngầm của 13 vòng
đầu ("mở rộng sang chặng 1 = một sản phẩm thứ hai"), đây là con số nhỏ hơn nhiều.

**MẪU dùng lại, không phải màn hình** (design-brief §7): hai chìa khoá · **lật bài
(PRIM-2)** · quà bất ngờ · trạng thái rỗng-có-nội-dung. Chúng xuất hiện *bên trong*
S-03/S-04/S-06/S-10/S-16, không đứng riêng.

---

## Phần 3 — Sáu màn hình mới (mức nghiệp vụ)

### S-01 · Chọn chế độ — **cạnh thứ hai duy nhất phải thêm vào `onboarding_chain`**

- **Vì sao tồn tại:** D14-1 — hôm nay `profileSetup` có **đúng một** cạnh ra:
  `→ pairingChoice`. Không có nhánh "tôi đang một mình" ⇒ chặng 1 bất khả đạt.
- **Vào từ:** `profileSetup`. **Ra:** S-02 (một mình) hoặc S-11 (đã có người kia).
- **Nội dung:** đúng hai lối. Chữ phải nói về **việc**, không về **tình trạng quan hệ**
  — hỏi "bạn độc thân à?" là hỏi sai câu và chạm R-3.
- **Ràng buộc:** lối "một mình" **không được** trình bày như bản dùng thử hay bản thiếu
  (L1). Đảo chế độ về sau phải luôn mở, không phải cửa một chiều.
- **Trạng thái rỗng:** không có — đây là màn hình quyết định.

### S-02 · Nhà, hình thái một người — **bề mặt gánh D12-1**

- **Vì sao tồn tại:** D14-3 — `_CoupleHero` cần hai avatar, `_DaysCounter` cần ngày bắt
  đầu của cặp, `_PresenceRow` in `Minh & Linh`. **Không gì trong hero hiện tại có nghĩa
  với một người.**
- **Vào từ:** S-01, hoặc tab 1 mọi lúc. **Ra:** S-03, S-05, S-06, S-19.
- **Nội dung:**
  - **Đếm ngược dịp Việt** thay đúng chỗ `_DaysCounter` — cùng vai trò thị giác, cùng
    vai trò tâm lý, khác nguồn dữ liệu. Đây là thứ **duy nhất** có giá trị ở giây thứ 5
    với **không dữ liệu nào** (§5.0/CS8): *"còn 12 ngày nữa tới 20/10"*.
  - Ba–bốn gợi ý hoạt động **đã biên tập sẵn theo thành phố**, vuốt bỏ được (CS7).
  - Lối vào nhanh S-05, S-06.
- ⚠️ **Ràng buộc nặng nhất toàn sản phẩm:** màn hình này **không được rỗng ở ngày 1**
  (D12-1 — 5/8 ô hiện là hộp rỗng; chặng 1 pass L1 ở ngày 30 chứ không phải ngày 1).
  Người dùng phải **cắt bớt**, không phải **nghĩ ra**.
- **Cấm:** mọi thứ hình dạng "người kia" — không đếm ngược tới người, không nhắc "đã 3
  ngày chưa nhắn" (R-1, L13, L17).

### S-03 · Danh sách hoạt động — **vật thể trung tâm của cả sản phẩm**

- **Vì sao tồn tại:** C1 là "đối tượng xương sống, mọi cụm khác cắm vào" — và hôm nay
  **không có tab** (D14-2). Nó lấy ô "Ví chung", ô này trống ra vì `dream_jar` gộp vào.
- **Vào từ:** tab 3. **Ra:** S-04, S-06, S-07.
- **Nội dung:**
  - Một danh sách **có hướng đi**, không phẳng: chuỗi hoạt động **mỗi cái thân mật hơn
    cái trước một nấc**. Đây là điều chỉnh từ JTBD đã sửa — nỗi đau số một là *"mắc kẹt,
    không biết cách đẩy quan hệ tiến lên"*, **không phải** thiếu ý tưởng đi chơi.
  - Bộ lọc **tầm xa**: tuần này → tháng này → "một ngày nào đó" ← chỗ `dream_jar` sống.
  - Bộ lọc mặc định theo §L1 vòng trước: ngân sách + trong/ngoài trời.
  - Nút **"rủ người này đi"** → J3.
- **Vòng đời xuyên chế độ (phải vẽ cả ba):** *danh sách của tôi* → *danh sách của chúng
  ta* → *kế hoạch được vận hành*. **Đây chính là chỗ M2 lộ ra ở tầng UI.**
- **Trạng thái rỗng: không được phép tồn tại** — màn hình đầu tiên là danh sách **đã có
  sẵn đồ để vuốt bỏ**, không phải nút "+" trên nền trắng (§5.0 đã sửa §7.4 cũ).

### S-04 · Một hoạt động

- **Vì sao tồn tại:** đối tượng xương sống cần một chỗ để có chiều sâu; C3 (chuyến đi đầu
  tiên — "khác biệt nhất, chưa app nào làm") và AC7 (chia tiền) đều cắm vào đây.
- **Vào từ:** S-03. **Ra:** S-14 (chi tiêu), S-15 (album), S-13 (cột mốc).
- **Nội dung:** cái gì · ở đâu · bao giờ · ghi chú riêng · trạng thái (định làm / đã làm
  / bỏ) · sau khi làm thì mở ra ảnh + chi tiêu + "đây có phải lần đầu tiên?".
- **Ở chặng 2 thêm:** hai chìa khoá để chốt, và chỗ neo S-14/S-15 — **ba màn hình đang
  bị chôn có nhà ở đây** (D14-9).

### S-05 · Khu riêng của tôi — **C6, và là ca thiết kế đạo đức khó nhất**

- **Vì sao tồn tại:** C6 chạy suốt cả ba chặng; ghi chú chặng 1 giữ **vĩnh viễn** (chốt c7).
- **Vào từ:** S-02 / S-12. **Ra:** —
- **Nội dung:** ghi chú tự do về **chính mình** và về **hoạt động**; ở chặng 2 vẫn là của
  riêng một người.
- ⚠️ **Ràng buộc G-2 bản (ii-b) — "không giấu cánh cửa, bỏ ổ khoá":** khu riêng **công
  khai và đối xứng** (cả hai đều thấy *có* một khu riêng), nhưng **nội dung** và cả
  **việc có-hay-không nội dung** đều bất khả truy cập với tài khoản kia. Câu trả lời cho
  người bạn đời cưỡng ép phải là *"app không có chức năng đó"* — **sản phẩm chịu trách
  nhiệm thay người dùng**, không đẩy cho họ.
- **Cấm:** L17 — mọi thứ về người kia chỉ đến từ chính người đó hoặc từ tay người dùng
  gõ. App **không bao giờ** là nguồn.
- **Mở, chưa giải:** OQ-13A — cho cô ấy đọc lại chính chữ mình đã viết về anh ấy là *tự
  soi* hay *hồ sơ buộc tội*?

### S-06 · Máy quyết định

- **Vì sao tồn tại:** C2 — nỗi đau nền "không biết chọn gì, sợ chọn nhạt".
- **Vào từ:** S-02, S-03. **Ra:** S-04.
- **Nội dung:** "hôm nay ăn gì / đi đâu"; thẻ thử thách hẹn hò.
- ⭐ **Ở chặng 2 nó thành nơi PRIM-2 sống rõ nhất:** cả hai chọn mù, **trùng thì tự
  chốt**. Đây là hợp nhất hai mẫu lõi (hai chìa khoá × lật bài) trong một tương tác.
- **Ghi cho designer:** có thể đây là một **chế độ của S-03** chứ không phải màn hình
  riêng. Tôi để mở, không quyết thay.

---

## Phần 4 — Năm user journey

Ký hiệu: `[MỚI]` `[SỬA]` `[DỜI]` `[GIỮ]`

### J1 — Ngày đầu của người chặng 1

> **Hôm nay: đường cụt.** `profileSetup` → `pairingChoice` là cạnh duy nhất; không ghép
> đôi thì không tới được tab nào.

```
welcome [GIỮ] → register → otp → permissions → profileSetup [GIỮ]
  → S-01 Chọn chế độ [MỚI]
      ├─ "đang một mình" → S-02 Nhà solo [MỚI]
      └─ "đã có người kia" → S-11 Ghép đôi [SỬA: hết bắt buộc]
```

**Trong 60 giây đầu ở S-02, người dùng phải thấy giá trị mà chưa nhập gì:** đếm ngược
20/10 + vài gợi ý hoạt động theo thành phố. Nếu họ phải nhập trước khi nhận, **J1 hỏng
và D12-1 thắng**.

**Kiểm thử L1 neo ở đây:** journey này phải trọn vẹn kể cả người kia **không bao giờ**
tham gia.

### J2 — Ngày 2 → 30: tích luỹ

```
S-02 [MỚI] → S-03 Danh sách [MỚI] → S-04 Một hoạt động [MỚI]
   ↘ S-05 Khu riêng [MỚI]      ↘ S-06 Máy quyết định [MỚI]
```

Ba cái vòi đổ dữ liệu vào S-05 là **KY2 · GI7 · GI3 bản một người** (D10-4 — chúng
không phải đồ thừa rẻ tiền; **thiếu chúng thì J3 không có gì để trưng**).

**Đầu ra của J2 là đạn cho J3:** một kho *"12 chỗ tôi đã ghi lại"*.

### J3 — Khoảnh khắc mời ⭐ **bề mặt quan trọng nhất toàn sản phẩm**

```
S-03 [MỚI] → "rủ người này đi" → invite [GIỮ] → S-07 [SỬA: WaitingScreen]
```

Hôm nay `WaitingScreen` là **màn hình chờ kỹ thuật thuần tuý**. Khoảnh khắc đắt nhất của
cả sản phẩm — thứ giải **đồng thời** rào cản gia nhập X1, chiến lược tốt nghiệp (a), và
vòng lan truyền (b) — đang là một cái spinner.

Nó phải trở thành nơi **G-b** xảy ra: *"đây là 12 chỗ anh đã ghi lại để đưa em đi"* —
**một món quà cụ thể, không phải một lời nhờ vả.**

**Không sinh node mới. Đổ nội dung vào node đã có** (D14-7).
**Vận chuyển:** link/Zalo — người kia phải mở được **trước khi** có tài khoản.
**Mở:** OQ-12B — CS2 (mời vào *hoạt động* thay vì vào *mối quan hệ*) có làm loãng khoảnh
khắc này không? Tôi chưa giải được.

### J4 — 60 giây đầu của người thứ hai ⭐ **lỗ to nhất và nó vô hình (D12-7)**

```
link → S-08 [SỬA: JoinCodeScreen] → S-09 [SỬA: PairedScreen] → S-18 [SỬA: ProfileEdit]
```

- **S-08 = hành động trước, tài khoản sau (CS6).** Người thứ hai **nhìn thấy 12 chỗ kia
  trước khi bị hỏi bất cứ điều gì**. Hôm nay `JoinCodeScreen` hỏi mã trước, nội dung sau
  — ngược.
- **S-09 phải mang D13-7: cấu trúc giá trị hai chiều** — cô ấy hưởng lợi từ tính năng
  **anh ấy** đã dùng.
- ⚠️ **Đây là chỗ D12-2 sống hoặc chết.** Nếu J4 vẫn phục vụ người khởi xướng, thì người
  thứ hai thành **người vận hành app không công** — *mankeeping số hoá*. Gánh nặng phải
  **đổi vai** đúng lúc app đổi chế độ: chặng 1 gánh *khởi xướng*, chặng 2 gánh *duy trì*.
  Vá bằng **CS11**, và CS11 sống ở S-09.

### J5 — Nghi thức đổi chế độ, và chặng 2

```
S-09 [SỬA] → S-10 Nghi thức [DỜI: LoveContract + Vow] → S-12 Nhà cặp đôi [GIỮ]
   → S-03 "danh sách của tôi" ⇒ "danh sách của chúng ta"   ← M2 lộ ra ở đây
   → S-13 cột mốc [NỐI] · S-14 chi tiêu [NỐI] · S-15 album [NỐI]
   → S-16 kỳ vọng liên lạc [SỬA] · S-17 nhắc nhau [SỬA]
```

**Hôm nay `loveContract` và `vow` đứng TRƯỚC toàn bộ chuyện này** — ngay giây sau khi
quét mã ghép đôi. App bắt hai người ký hợp đồng tình yêu và thề nguyện **trước khi họ có
gì để hứa** (D14-5). Dời xuống đây thì lời thề có nội dung để thề, và `HomeScreen` 1099
dòng hiện tại **được dùng nguyên vẹn** làm S-12.

⭐ **Cả năm journey chỉ cần 6 màn hình mới.** Mọi thứ còn lại là **đổ nội dung vào node
đã có**, **dời**, hoặc **mở lối vào cho thứ đã build**.

---

## Phần 5 — A-19 ✅ **CHỐT: lối 3** (user, 2026-09-03)

**Quyết định:** zodiac đổi vai từ *chấm điểm cặp đôi* → *mồi chuyện*.

### 5.1 Cơ chế của lối 3: **không phải ngoại lệ — là dịch chuyển tầng**

Đây là phần quan trọng nhất, và nó làm lối 3 mạnh hơn lý do tôi đưa ra lúc đề xuất.

Luật ba tầng `R-1e` phân loại theo **ai là người khẳng định**, không theo chủ đề:

| Tầng | Ai khẳng định | Phán quyết |
|---|---|---|
| 1 — GHI | người dùng ghi điều họ tự quan sát | ✅ |
| 2 — ĐOÁN | người dùng đoán, **app không xác nhận** | ✅ **hợp lệ, và là trò chơi** |
| 3 — SUY/CHẤM | **app** khẳng định về người kia | ❌ cấm |

`conflictIndex` là app khẳng định ⇒ tầng 3. Nhưng **chủ đề không phải thứ bị cấm** —
*chủ thể khẳng định* mới là. Đổi **thức** của cùng một nội dung từ **kết luận** sang
**câu hỏi** thì chủ thể khẳng định chuyển từ app sang người dùng, và nó **rơi xuống
tầng 2** — nơi luật đã tuyên *"hợp lệ, và là trò chơi"*.

⭐⭐ ⇒ **Lối 3 không mở ngoại lệ nào cho R-1. Luật đứng yên; zodiac di chuyển bên trong
luật.** Đó là lý do cấu trúc khiến nó hơn lối 1, không phải lý do cảm tính.

### 5.2 ⭐ L18 — luật mới rút ra được từ A-19

> **L18. Chủ thể khẳng định quyết định tính hợp lệ, không phải chủ đề.**
> App được phép **NÊU** một chủ đề về hai người; app **không được KẾT LUẬN** về họ.
> Cưỡng chế ở tầng API cùng nước đi với **AI-1**: schema đầu ra của mọi nội dung sinh
> ra mô tả con người hoặc cặp đôi **không được có trường điểm số** — cấm `score`,
> `index`, `percent`, `compatibility`, `level`, và mọi biến thể.

L18 là thứ khiến A-19 kiểm tra được bằng máy thay vì bằng thiện chí. Nó cũng là bản
tổng quát của cả `R-1e` lẫn `AI-1`.

### 5.3 Hệ quả cụ thể cho S-20

| Hôm nay | Sau A-19=3 | Vì sao |
|---|---|---|
| `ZodiacConflictIndex` — `score`/`scoreMax`/`fillFraction`, 2 partner, glyph `bolt` | **bỏ hẳn** | Trường điểm số, L18 cấm thẳng |
| `dailyTips` — 3 **lời khuyên** trong ngày | → **hạt câu hỏi** trong ngày | Lời khuyên = app khuyên cách cư xử với người kia = tầng 3 mềm, và đúng bề mặt nịnh hót **H-R1** (*Science*: 73% xác nhận lập luận sai, làm người ta ít xin lỗi trong xung đột quan hệ) |
| `GET /zodiac/red-flag/today` · `ZodiacRedFlagScreen` | **đổi tên** | Tên gọi **chính là khái niệm bị cấm**. Giữ tên thì sau 6 tháng luật sẽ bị đọc lại sai. Đây không phải mỹ phẩm |
| ô trên quick grid của Nhà | **giữ ô, đổi nội dung** | Lối vào đã có |
| đứng một mình | **nối vào PRIM-2 và S-06** | Câu hỏi trong ngày → cả hai trả lời kín → cùng lật |

### 5.4 ⭐⭐ Cái được mà tôi chưa thấy lúc đề xuất: A-19=3 **hồi sinh C8**

Hai chuyện đã chốt từ trước, chưa ai nối lại với nhau:

- **A-9 (c7):** *"C8 giữ, nhưng dạng **thi thoảng chèn câu hỏi**, không phải bảng câu hỏi."*
- **Nghiên cứu c6:** C8 bị **hạ ưu tiên** vì *"kho câu hỏi soạn sẵn cạn trong 2-4 tuần —
  mô hình chết phổ biến thứ hai của thể loại. **Chỉ giữ nếu đổi sang RS2** (nội dung sinh
  từ dữ liệu của chính cặp đôi)."*

Zodiac sau khi đổi vai **sinh câu hỏi mỗi ngày từ ngày sinh của chính hai người**. Đó
**chính xác là RS2**, và **chính xác là hình dạng A-9 đã chốt**.

⇒ App đã có sẵn một **máy sinh câu hỏi hằng ngày đang chạy trong production**, chỉ đang
xuất ra **sai thức**. A-19=3 không phải một khoản sửa nợ — nó **trả lại C8 đúng điều
kiện mà c6 đã đặt ra**, với chi phí gần bằng không so với xây mới.

### 5.5 S-20 chạy được ở **cả hai chặng**

- **Chặng 2:** hai ngày sinh → câu hỏi cho cặp → lật bài.
- **Chặng 1:** chỉ ngày sinh **của chính người dùng** → chiêm tinh **về bản thân** =
  người dùng tự khai về mình = **tầng 1, sạch tuyệt đối**, không chạm R-1 lẫn L17.

⭐ ⇒ **Đây là cái vòi thứ tư đổ vào S-05**, đứng cạnh KY2/GI7/GI3 (D10-4) — và là cái
vòi **duy nhất có nội dung từ ngày 1 mà không cần người dùng nhập gì**. Nó vá thẳng
D12-1 (chặng 1 pass L1 ở ngày 30 chứ không phải ngày 1), cùng vai trò với đếm ngược
dịp Việt trên S-02.

---

## Phần 5b — A-21 (mới): `pets` **trượt L18**, và nó lớn hơn zodiac

Tôi đã đo thay vì đoán. `pets` ship: **`happiness` · `level` · `streak` · `mood` ·
`points` · `percent`**, kèm một widget tên `pet_stats_row.dart`. Đó là một **bảng điểm**,
và design-brief §6.12 đã tự phán quyết từ trước: *"chỉ được phản ánh **nhịp** — có đang
cùng nhau làm gì không — **tuyệt đối không phản ánh điểm số**."*

**Phân biệt trung thực — pets KHÔNG cùng một ca với zodiac:**

- Chủ thể của `conflictIndex` là **con người / cặp đôi** ⇒ đúng tầng 3 của `R-1e`.
- Chủ thể của `happiness`/`level` là **hoạt động chung**, không phải một con người ⇒
  **không** vi phạm `R-1e`. Nó vi phạm **L18** (trường điểm số mô tả cặp đôi) và vi phạm
  **§6.12** — luật của chính idea này, đã chốt từ trước.
- `streak` là ca riêng và nặng nhất: bảng điểm chuỗi ngày đụng luật *"chúng ta, không
  phải tôi vs anh"*, và biến việc yêu nhau thành nghĩa vụ giữ chuỗi.

**Vì sao lớn hơn zodiac:** pets chiếm **một tab trong năm**, có **entity backend**, và
sáu trường số nằm rải trong 4 tệp. Zodiac là một endpoint và một màn hình.

**Khuyến nghị:** cùng lối 3 — pet phản ánh **nhịp** (*"hai người có đang cùng làm gì
không"*) thay vì **điểm**. Bỏ `level`/`points`/`percent`/`streak`; giữ `mood` như một
**trạng thái định tính** phái sinh từ hoạt động, không phải một thang đo tích luỹ.

**Không chặn handoff** — L18 đã cho sẵn phép thử, tech-lead áp được. Nhưng nếu bạn muốn
pets đi lối khác thì nói, vì đó là ngoại lệ đầu tiên của L18.

---

## Phần 6 — Còn chờ bạn (không chặn, trừ A-19)

| Mã | Câu hỏi | Chặn gì |
|---|---|---|
| ~~A-19~~ | ✅ **CHỐT lối 3** (user 2026-09-03) — kèm **L18** mới. Handoff hết chặn | — |
| **A-21** | `pets` trượt **L18** (`happiness`/`level`/`streak`/`points`). Cùng lối 3? | không chặn |
| **A-16** | Customize rẽ theo **vai** (đề xuất) hay theo **giới**? Nếu vai: tự khai một câu hay suy từ hành vi? | S-18, phần customize đợt 1 |
| **A-17** | Chốt **L14** (app phải đẩy người dùng ra ngoài, không chỉ hút vào) thành luật? | S-19 |
| **A-18** | Mở lại "đồng bộ chu kỳ và sức khoẻ" đã loại ở §9? *(GA1 **không** phải là mở lại nó)* | — |
| **OQ-13A** | Cho cô ấy đọc lại chính chữ mình đã viết về anh ấy — tự soi hay hồ sơ buộc tội? **Chưa giải được** | S-05 |
| **OQ-12B** | CS2 có làm loãng khoảnh khắc G-b không? **Chưa giải được** | S-07 |
