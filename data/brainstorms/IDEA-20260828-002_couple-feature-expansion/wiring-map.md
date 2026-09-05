# Bản đồ móc nối — IDEA-20260828-002 (vòng 14)

Vòng này trả lời đúng ba câu user hỏi: **móc nối vào cái đang có ở đâu**, **bề mặt
nào phải sinh ra**, **user journey chạy thế nào**.

Khác mọi vòng trước: 13 vòng đầu chạy trên *ý tưởng*. Vòng này chạy trên **mã nguồn
thật**. Mọi khẳng định dưới đây có đường dẫn tệp kèm theo — cái nào tôi không đọc thì
tôi ghi là chưa đọc.

- Kỹ thuật: T20 Forced Fit lên đồ thị điều hướng thật · T21 Quét thanh lý module ·
  T22 Journey Walk · T23 Dò va chạm
- Công cụ: **không WebSearch/WebFetch vòng này** (đây là vòng chứng cứ nội bộ).
  Đọc mã: `mobile/lib/core/navigation/*`, `features/home/presentation/home_screen.dart`,
  `features/zodiac/**`, `backend/src/modules/`.

---

## Phần 1 — Hiện trạng thật của bề mặt (cái mà 13 vòng trước chưa ai nhìn)

### 1.1 Đồ thị onboarding — `core/navigation/onboarding_chain.dart`

```
welcome → login/register → otp → permissions → profileSetup
        → pairingChoice → (invite → waiting | joinCode) → paired
        → loveContract → vow → home
```

`home` là **bề mặt 5-tab đầu tiên trong toàn bộ luồng**; mọi thứ trước nó đều
chromeless (`OnboardingChain.isChromeless`). `AppShell` chỉ được mount bởi
`PairGateShell` **sau trạng thái `paired`**.

### 1.2 Năm tab — `core/navigation/app_shell.dart`

| # | Tab | Body thật sự được mount |
|---|---|---|
| 1 | Nhà | `HomeScreen` |
| 2 | Trò chuyện | `ChatScreen` — **rơi hẳn khỏi danh sách** khi `ChatEntryGate` khoá |
| 3 | Pet | `PetScreen` |
| 4 | **Ví chung** | **`DreamJarListScreen`** |
| 5 | Tôi | `MeScreen` |

### 1.3 Tab Nhà hôm nay — `features/home/presentation/home_screen.dart` (1099 dòng)

- `_CoupleHero`: **hai avatar**, `_DaysCounter` (số ngày bên nhau), `_MilestonePill`,
  `_PresenceRow` (`Minh & Linh`), nút "Chia sẻ số ngày bên nhau".
- Quick grid **5 ô**: Reminders · Zodiac · Dream Jar · Anti-Ghosting · (+1).
- Đi được từ Nhà: `VibeScreen`, `NotificationSettingsScreen`, `ReminderScheduleScreen`,
  `ZodiacRedFlagScreen`, `DreamJarListScreen`, `AntiGhostScreen`, `TimelineScreen`.

### 1.4 Tính năng đã build nhưng **không có lối vào từ 5 tab**

`expenses` (có cả backend lẫn `expenses_route.dart`) · `gallery` · `emojis` ·
`love_contracts` (chỉ gặp một lần trong onboarding) · `vow` (chỉ gặp một lần trong
onboarding, **không có backend**).

---

## Phần 2 — Mười phát hiện (D14-1..D14-10)

### ⭐⭐⭐ D14-1 — Chặng 1 không thiếu màn hình. Chặng 1 **không có cửa**.

`OnboardingChain._forwardOrder` có **đúng một cạnh** ra khỏi `profileSetup`:
`→ pairingChoice`. Không có nhánh "tôi đang một mình". Và `AppShell` chỉ tồn tại sau
`paired`.

Nghĩa là: một người dùng chặng 1 hôm nay **không thể đến được bất kỳ tab nào**. Không
phải "trải nghiệm nghèo nàn" — là **bất khả đạt**.

**Điều này làm M2 lớn hơn cái ta đã ghi.** 13 vòng ghi M2 = "mô hình dữ liệu 1 chủ → 2
chủ". Nhưng **đồ thị điều hướng cũng chỉ có một chế độ**, và nó là tệp 60 dòng
`onboarding_chain.dart` có unit test chứng minh thứ tự. Tin tốt: nó được viết tách khỏi
widget có chủ đích ("deliberately widget-free"), nên **thêm nhánh chế độ ở đây rẻ hơn
nhiều so với M2 tầng dữ liệu**.

### ⭐⭐ D14-2 — Đối tượng xương sống của cả idea không có tab. Nhưng ô để nó vào đã có sẵn.

C1 (danh sách hoạt động xuyên chặng) là "vật thể trung tâm của cả sản phẩm"
(design-brief §5). Nó **không có tab**. Năm tab đã đầy.

Nhưng tab 4 "Ví chung" hiện mount `DreamJarListScreen` — và design-brief §5 đã chốt
**gộp hũ ước mơ vào C1** ("một danh sách, nhiều tầm xa, không phải hai màn hình rời").

⇒ **Việc gộp đó tự nó giải phóng đúng cái tab mà C1 cần, ở đúng vị trí.** Đây là móc
nối rẻ nhất trong toàn bộ idea, và 13 vòng trước không thấy vì không ai mở
`app_shell.dart`.

### ⭐⭐ D14-3 — Tab Nhà bất khả render ở chế độ một người.

`_CoupleHero` cần hai avatar, `_DaysCounter` cần ngày bắt đầu của cặp, `_PresenceRow`
in `Minh & Linh`, nút chính là "Chia sẻ số ngày bên nhau". **Không có gì trong hero
này có nghĩa với một người.**

Nên đây không phải "thêm một màn hình cho chặng 1". Đây là: **Nhà phải có hai hình
thái**, và hình thái chặng 1 là bề mặt duy nhất bắt buộc phải sinh mới.

Và ta đã biết phải đặt gì vào đó: design-brief §5.0 nói tính năng **duy nhất** có giá
trị ở giây thứ 5 với không dữ liệu nào là **đếm ngược dịp Việt** (*"còn 12 ngày nữa tới
20/10"*). Nó thay đúng chỗ `_DaysCounter` đang đứng — cùng vai trò thị giác, cùng vai
trò tâm lý, khác nguồn dữ liệu.

### ⭐ D14-4 — Cơ chế "một app đổi chế độ" đã tồn tại trong repo, chỉ chưa ai gọi tên.

`ChatEntryGate` khiến tab Trò chuyện **rơi hẳn khỏi `destinations`** khi khoá, và
`_ShellDestination` được viết có chủ đích để "index math safe when Chat's conditional
slot appears or disappears".

⇒ Tab có điều kiện là **mẫu đã có, đã chạy, đã có lý do được viết vào comment**.
"Một app hai chế độ" (design-brief §2 — "điều quan trọng nhất phải hiểu") ở tầng điều
hướng **không phải xây mới**, mà là tổng quát hoá `ChatEntryGate` → `ModeGate`.

Đây là bằng chứng thứ hai cho D10-2 (lối B nuốt nửa rẻ của lối C).

### ⭐⭐ D14-5 — Nghi thức đổi chế độ đã có chỗ. Chỗ đó đang bị dùng sai.

`loveContract` và `vow` là **node bắt buộc**, nằm giữa `paired` và `home`.

Đó chính là nguyên thuỷ **PRIM-1 (hai chìa khoá)** — thứ idea gọi là "đã có trong 6
module nhưng chưa đặt tên" — nằm sẵn trong phễu, **ở sai thời điểm**: app bắt hai người
ký hợp đồng tình yêu và thề nguyện **trước khi họ có gì để hứa**, ngay giây sau khi
quét mã ghép đôi.

design-brief §4.3 ("nghi thức đổi chế độ") đang đi tìm một chỗ đứng. **Chỗ đó đã tồn
tại.** Việc phải làm không phải *thêm màn hình* mà là **dời**: `loveContract`/`vow` ra
khỏi onboarding, vào đúng khoảnh khắc chuyển chặng 1 → chặng 2, lúc đã có 12 chỗ trong
danh sách để mà hứa.

### ⭐ D14-6 — `vow` là node bắt buộc mà không có backend.

Đã xác nhận: `backend/src/modules/` không có `vow`. Nghĩa là **hôm nay mọi người dùng
đều bị ép đi qua một màn hình không lưu được gì lên server**. §6.12 mới ghi "ứng viên
hoàn hảo cho mẫu hai chìa khoá" — giờ có thêm: nó vừa là nợ đang chảy máu, vừa là đúng
màn hình cần dời ở D14-5. Một việc sửa hai chỗ.

### ⭐⭐ D14-7 — Đường nối giữa hai chặng có chủ sở hữu kỹ thuật rồi. Nó chỉ đang rỗng nội dung.

D12-7 kết luận "không có tính năng nào phục vụ người thứ hai trong 60 giây đầu; đường
nối giữa hai chặng không ai sở hữu". **Sai một nửa.** Đường nối đã tồn tại:
backend `invitations` + bốn node `invite → waiting` / `joinCode` → `paired`.

⇒ CS5/CS6 (màn hình người thứ hai) **không phải xây từ số 0**. Là **đổ nội dung vào
`joinCode` và `paired`** — hai node hôm nay là thủ tục kỹ thuật thuần tuý. Và G-b
(*"đây là 12 chỗ anh đã ghi lại để đưa em đi"*) chính là thứ đổ vào `waiting`/`paired`.

Khoảnh khắc đắt nhất của cả sản phẩm đang là một màn hình chờ.

### ⭐⭐⭐ D14-8 — Luật R-1 mâu thuẫn với một tính năng **đang chạy trong app**.

`zodiac` ship `GET /zodiac/red-flag/today`, trả về:

- `ZodiacConflictIndex` — **một điểm số `score` / `scoreMax` kèm thanh `fillFraction`**,
  render qua `ZodiacConflictIndexCard`, với **hai partner** và một glyph `bolt` ở giữa;
- `dailyTips` — ba lời khuyên trong ngày;
- màn hình tên `ZodiacRedFlagScreen`, có ô riêng trên quick grid của Nhà.

Đối chiếu với luật ba tầng (`R-1e`, c12) và §9 "đã loại — đừng thiết kế lại":

> **Tầng 3 — SUY / CHẤM: App khẳng định về người kia.** Ví dụ đã ghi nguyên văn trong
> tài liệu: *"độ ăn khớp 78%"*. Phán quyết: **❌ Cấm. Đã loại 2 lần.**

Và ở c13, tôi đã chặn ví dụ **"đèn đỏ"** của user bằng bốn lập luận. Trong khi đó app
**đã ship một màn hình tên là red-flag, có chỉ số xung khắc chấm điểm cặp đôi**.

**Mười bảy luật của idea này chưa bao giờ được đối chiếu với tập tính năng đang chạy.**
Đó là lỗ hổng phương pháp, không phải lỗ hổng ý tưởng — và nó là thứ nghiêm trọng nhất
vòng 14 tìm ra.

Có một phân biệt **thật** để cứu zodiac, và tôi không tự quyết nó:

| Cứu được | Không cứu được |
|---|---|
| Nguồn dữ liệu là **ngày sinh hai người tự khai**, cả hai đều có tài khoản ⇒ **sạch L17**, khác hẳn ca "đèn đỏ chặng 1" (chủ thể không có tài khoản, không có đường xin đồng ý) | `conflictIndex` là **app khẳng định về cặp đôi bằng một con số** ⇒ đúng tầng 3 |
| Chiêm tinh được đóng khung văn hoá là **giải trí**, không phải phán quyết tâm lý | `dailyTips` là app **khuyên về cách cư xử với người kia** ⇒ đúng bề mặt nịnh hót H-R1 |
| Đã ship, có người dùng, gỡ đi là mất tính năng | Nếu R-1 có ngoại lệ "vì đã ship" thì R-1 không còn là luật |

→ **A-19 / OQ-14A: câu này phải do bạn quyết.** Xem Phần 5.

### D14-9 — App có tính năng bị chôn không lối vào.

`expenses` có backend, có `expenses_route.dart`, **không có trong 5 tab và không có
trong quick grid**. `gallery`, `emojis` cũng không tìm được lối vào từ shell.

⇒ **AC7** (chia tiền chuyến đi — rủi ro còn mở trong `idea.md`) móc vào `expenses` đã
có, không phải xây mới. Và nó bổ sung một dữ kiện khó chịu cho D12-1: vấn đề "hộp rỗng"
của app **không chỉ ở chặng 1** — chặng 2 cũng đang có tính năng dựng xong rồi bỏ đó.

### D14-10 — Ghi trung thực về giới hạn của chính vòng này.

- Tôi đọc **đồ thị điều hướng và bề mặt**. Kết luận về **cấu trúc** là chắc.
- Tôi **không** đọc mô hình dữ liệu, entity, migration. Nên vòng này **không nói gì
  về chi phí của M2**. M2 vẫn nguyên vẹn là việc của tech-lead (G-3).
- "Pet chiếm 1/5 ngân sách điều hướng" là quan sát về **chi phí cơ hội của tab**, không
  phải đề nghị bỏ Pet. §6.12 đã có phán quyết riêng cho Pet (chỉ được phản ánh *nhịp*,
  tuyệt đối không phản ánh *điểm số* — lưu ý luật đó cũng va vào D14-8).

---

## Phần 3 — Quét thanh lý: mỗi module đang có thì đi về đâu

Bốn phán quyết: **NỐI** (móc idea vào, giữ nguyên vai) · **ĐỔI VAI** (giữ code, đổi
nghĩa) · **DỜI** (đúng thứ, sai chỗ) · **CHỜ** (chưa có phán quyết).

| Module đang có | Phán quyết | Móc vào đâu trong idea |
|---|---|---|
| `dream-jar` / `dream_jar` | **ĐỔI VAI** | Gộp vào **C1** như "hoạt động ở thì tương lai xa" (§5). Giải phóng tab 4 cho C1 → **D14-2** |
| `timeline` | **NỐI** | **C7 cột mốc / lần đầu tiên** + **C16 ký ức tự viết**. Nguyên thuỷ gần nhất đã có |
| `love_contracts` | **DỜI** | Là **PRIM-1 hai chìa khoá**. Dời khỏi onboarding → nghi thức đổi chế độ §4.3 → **D14-5** |
| `vow` (không backend) | **DỜI + NỐI** | Cùng nước đi với `love_contracts`; đồng thời là mẫu tham chiếu cho hai chìa khoá (§6.12) → **D14-6** |
| `invitations` + 4 node ghép đôi | **NỐI** | **C0 + G-b + CS5/CS6**. Khoảnh khắc mời đắt nhất sản phẩm đang là màn hình chờ → **D14-7** |
| `expenses` | **NỐI** | **AC7** chia tiền chuyến đi (C3). Đang bị chôn không lối vào → **D14-9** |
| `anti_ghosting` / `ghost-config` | **NỐI** | **RS1** thoả thuận kỳ vọng liên lạc bằng hai chìa khoá. §6.12: "đã độc đáo sẵn, chưa khai thác" |
| `alarms` + `reminders` | **NỐI** | **C14 ô giữa** (90% quỹ thời gian, hiện trống) + hẹn giờ nguội của love-contract |
| `messages` / `chat` | **NỐI, có khoá** | Chỉ từ chặng 2, chỉ trích xuất **hoạt động** (luật **AI-1**). `ChatEntryGate` đã là mẫu khoá theo chế độ → **D14-4** |
| `gallery` | **NỐI** | **C16 ký ức tự viết** + album buổi hẹn. Hiện không lối vào |
| `themes` + `emojis` + `vibes` + `pets` | **CHỜ** | Trục biểu đạt/trang trí. Không phản đối, nhưng chúng chiếm ngân sách điều hướng mà idea không cấp việc cho. Pet: chỉ *nhịp*, không *điểm* |
| **`zodiac`** | ⚠️ **CHỜ QUYẾT ĐỊNH** | **Va thẳng R-1 tầng 3.** Không phán quyết được trong brainstorm → **D14-8 / A-19** |
| `users` `auth` `uploads` `mail` `notifications` `admin` `data-export` | — | Hạ tầng, không thuộc phạm vi idea |

**Đếm:** 6 NỐI · 1 ĐỔI VAI · 2 DỜI · 5 CHỜ · 1 xung đột luật. Không module nào phải
xoá. Điều đó chống lưng cho D10-2: hướng đi này **cộng vào** app hiện có, không thay
thế nó.

---

## Phần 4 — Năm user journey (mức nghiệp vụ, không phải đặc tả màn hình)

Ký hiệu: `[có]` = node/bề mặt đã tồn tại · `[sửa]` = có nhưng phải đổi hình thái ·
`[mới]` = bề mặt chưa từng có.

### J1 — Ngày 1 của người chặng 1 (hôm nay: **bất khả**)

```
welcome [có] → register → otp → permissions → profileSetup [có]
  → ⛔ pairingChoice ép ghép đôi ⇒ ĐƯỜNG CỤT
```

Đề xuất:

```
profileSetup [có]
  → chọn chế độ [mới]            ← cạnh thứ hai duy nhất cần thêm vào onboarding_chain
  → Nhà (hình thái một người) [sửa]
        · đếm ngược dịp Việt thay chỗ _DaysCounter  (giá trị ở giây thứ 5, 0 dữ liệu)
        · danh sách hoạt động ĐÃ CÓ SẴN ĐỒ để vuốt bỏ  (CS7 — không phải nút "+" trên nền trắng)
```

**Kiểm thử L1 gắn vào đây:** journey này phải trọn vẹn kể cả người kia không bao giờ vào.

### J2 — Ngày 2 → 30, chặng 1 tích luỹ

```
Nhà [sửa] → tab C1 danh sách hoạt động [mới, dùng ô tab của Dream Jar]
   ← ba cái vòi đổ vào (D10-4): KY2 · GI7 · GI3 bản một người
   → nhật ký riêng C6 [mới, khu riêng ii-b]
   → timeline [có] ghi lần đầu tiên
```

Cuối J2, kho của người dùng có **12 chỗ đã ghi**. Đó là đạn cho J3.

### J3 — Khoảnh khắc mời (bề mặt quan trọng nhất sản phẩm)

```
C1 [mới] → "rủ người này đi" → invite [có] → waiting [có, đang RỖNG NỘI DUNG]
```

Hôm nay `waiting` là màn hình chờ kỹ thuật. Nó phải trở thành nơi G-b xảy ra:
*"đây là 12 chỗ anh đã ghi lại để đưa em đi"*. **Không sinh node mới — nhét nội dung
vào node đã có.**

### J4 — 60 giây đầu của người thứ hai (D12-7, lỗ to nhất)

```
link/mã → joinCode [có, đang RỖNG] → paired [có, đang RỖNG]
```

CS5/CS6 = **hành động trước, tài khoản sau**. Người thứ hai phải **nhìn thấy 12 chỗ
kia trước khi bị hỏi bất cứ điều gì**. Hai node đã có, đang trống — không cần xây mới.

⚠️ Đây cũng là chỗ **D13-7** phải sống: người thứ hai hưởng lợi từ tính năng người thứ
nhất đã dùng. Nếu J4 vẫn phục vụ người khởi xướng thì **D12-2 thành hiện thực**
(mankeeping số hoá).

### J5 — Nghi thức đổi chế độ, và ngày đầu chặng 2

```
paired [có] → loveContract [có, DỜI TỚI ĐÂY] → vow [có, DỜI TỚI ĐÂY]
            → Nhà (hình thái cặp đôi) [có, chính là HomeScreen hôm nay]
            → C1 chuyển "danh sách của tôi" → "danh sách của chúng ta"   ← đây là M2
```

Hôm nay `loveContract`/`vow` đứng **trước** J5, ngay sau khi quét mã. Dời chúng xuống
đây thì lời thề có nội dung để thề — và `HomeScreen` 1099 dòng hiện tại **được dùng
nguyên vẹn** làm hình thái chặng 2.

**Cả năm journey cộng lại chỉ cần đúng ba bề mặt mới:** chọn chế độ · Nhà hình thái một
người · tab C1. Mọi thứ còn lại là **nhét nội dung vào node đã có** hoặc **dời**.

---

## Phần 5 — Cái phải quyết, và cái tôi không giải được

- ⚠️ **A-19 / OQ-14A (mới, chặn):** `zodiac` `conflictIndex` + `dailyTips` va thẳng
  R-1 tầng 3 và §9. Ba lối:
  1. **Miễn trừ có tên** — zodiac là chiêm tinh giải trí, viết ngoại lệ vào R-1 bằng
     chữ, phạm vi hẹp, không được nới. *Giá: R-1 có ngoại lệ đầu tiên.*
  2. **R-1 hồi tố** — bỏ `conflictIndex`, giữ nội dung chiêm tinh không chấm điểm.
     *Giá: mất một tính năng đã ship.*
  3. **Đổi vai** — zodiac chuyển từ *chấm điểm cặp đôi* sang *mồi chuyện* (đúng tinh
     thần GA2: app **làm cho** anh ấy tâm lý hơn thay vì **chấm điểm** anh ấy).
  → **Tôi nghiêng về (3)**, vì nó là lối duy nhất không phải trả giá bằng luật hay bằng
  tính năng. Nhưng đây là quyết định của bạn.
- **Vẫn chờ từ trước:** A-16 (vai vs giới) · A-17 (L14) · A-18 (đồng bộ chu kỳ) ·
  OQ-13A · OQ-12B.
- **Không giải trong brainstorm:** chi phí M2 tầng dữ liệu (G-3, tech-lead). Vòng 14
  chỉ hạ được **một nửa** rủi ro đó — nửa điều hướng, rẻ hơn ta tưởng (D14-4). Nửa dữ
  liệu chưa ai chạm.
