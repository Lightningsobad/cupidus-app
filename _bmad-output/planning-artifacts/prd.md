---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
inputDocuments:
  - /Users/alantravala/workspace/snapsofts/cupid/_bmad-output/planning-artifacts/product-brief-cupid-2026-02-13.md
workflowType: 'prd'
documentCounts:
  briefCount: 1
  researchCount: 0
  brainstormingCount: 0
  projectDocsCount: 0
classification:
  projectType: Mobile App
  domain: Consumer Social / Fintech
  complexity: Medium
  projectContext: Greenfield
  financialTracking: Manual
---

# Product Requirements Document - cupid

**Author:** alan
**Date:** 2026-02-13

## Executive Summary

**Vision:** Cupid là ứng dụng di động dành cho các cặp đôi, kết hợp kết nối cảm xúc, gamification hài hước và quản lý tài chính chung — tất cả trong một sản phẩm duy nhất.

**Product Differentiator:** Tông giọng "toxic nhưng vui" — khác biệt hoàn toàn với các couple app "ngọt ngào" hiện tại. Killer feature **Typing Ghost** (hiển thị real-time keystroke bao gồm phần đã xóa) là tính năng chưa từng có trong ngành.

**Target Users:** Cặp đôi Gen Z Việt Nam (18-30 tuổi), cả yêu xa và cùng thành phố.

**MVP Approach:** iOS-first, Experience MVP. Team: 1 iOS Dev + 1 Backend Dev + 1 Designer + AI Coding Agent.

## Success Criteria

### User Success

- Cặp đôi cảm thấy **kết nối hơn mỗi ngày** thông qua các tương tác gamified (Synced Alarm, Love Pet, Vibe Check)
- Khoảnh khắc "aha!": Lần đầu tiên sử dụng **Typing Ghost** và cảm nhận được suy nghĩ thật của đối phương
- Giảm xung đột nhờ **Zodiac Red Flag / Argument Forecast** cảnh báo sớm
- Cặp đôi đạt mục tiêu tài chính chung đầu tiên qua **Dream Jar**
- Trải nghiệm onboarding **Love Contract** tạo ấn tượng mạnh, khiến người dùng muốn chia sẻ ngay

### Business Success

- **3 tháng đầu:** 10,000+ cặp đôi active (20,000 users)
- **DAU/MAU ratio** ≥ 40% (chứng tỏ thói quen sử dụng hàng ngày)
- **Tỷ lệ uninstall 7 ngày** < 30%
- **12 tháng:** 100,000+ cặp đôi, bắt đầu có doanh thu từ Premium
- **Mô hình:** Freemium — Core features miễn phí, Premium cho AI features (Ghostwriter, Argument Forecast) + Virtual Goods (Love Pet items, Stickers)

### Technical Success

- App hoạt động mượt trên iOS (MVP), Android từ Phase 1.5
- Tin nhắn real-time (Typing Ghost) latency < 200ms
- Dữ liệu cá nhân được mã hóa end-to-end (Private Gallery, chat)
- Uptime ≥ 99.5%

### Measurable Outcomes

- **Viral coefficient** ≥ 1.2 (mỗi cặp đôi giới thiệu thêm ít nhất 1 cặp đôi mới)
- **Session length** trung bình ≥ 8 phút/ngày
- **Feature adoption:** ≥ 60% users sử dụng ít nhất 3 core features trong tuần đầu

## User Journeys

### Journey 1: "Ngày đầu tiên" — Cặp đôi Onboarding & Pairing (Happy Path)

**Nhân vật:** Minh (25 tuổi, dev) & Linh (24 tuổi, designer) — yêu nhau 8 tháng, muốn thử app mới cho vui.

**Opening Scene:** Minh thấy bạn share screenshot Typing Ghost trên TikTok. Tò mò, anh tải Cupid. Màn hình đầu tiên không phải form đăng ký nhàm chán — mà là một bản **Love Contract** với những điều khoản hài hước: *"Hứa không giận quá 24h"*, *"Không được bơ tin nhắn quá 10 phút"*. Minh cười, tick đồng ý, tạo tài khoản.

**Rising Action:** Minh gửi link mời Linh. Linh mở link, cũng ký Love Contract. Hai người cùng đặt ngón tay lên màn hình — **Fingerprint Vow** — xác nhận ghép đôi. App hỏi: *"Tụi mình thuộc kiểu nào?"* — Linh chọn **"Ở cùng thành phố"** và **"Yêu được vài tháng"**. Dashboard hiện ra: Love Timeline bắt đầu từ Ngày 1, Vibe Check hỏi *"Hôm nay cảm thấy thế nào?"*.

**Climax:** Tối hôm đó, Minh bật Typing Ghost. Anh thấy Linh đang gõ: *"Anh ơi em nhớ..."* rồi xóa, gõ lại *"Anh ăn cơm chưa?"*. Minh cười — lần đầu tiên anh nhìn thấy suy nghĩ thật chưa qua chỉnh sửa. Anh screenshot gửi lại: *"Anh thấy em xóa rồi viết lại nè 😏"*. Họ cười cả buổi tối.

**Resolution:** Tuần đầu tiên, họ set Synced Alarm 7h sáng. Love Pet — một chú mèo ảo tên "Bún" — xuất hiện. Minh tạo Dream Jar đầu tiên: "Du lịch Đà Lạt" — 5 triệu đồng. Cupid trở thành app đầu tiên cả hai mở mỗi sáng.

---

### Journey 2: "Yêu xa vẫn gần" — Cặp đôi Long Distance

**Nhân vật:** Hùng (27 tuổi, kỹ sư ở Hà Nội) & Mai (26 tuổi, giáo viên ở Đà Nẵng) — yêu xa 2 năm, hay cãi nhau vì thiếu giao tiếp.

**Opening Scene:** Mai tải Cupid vì muốn có công cụ kết nối hơn là chỉ Zalo. Khi ghép đôi, họ chọn **"Yêu xa"**. App hiểu rằng đây là cặp cần các tính năng "cảm giác hiện diện" nhiều hơn.

**Rising Action:** Sáng thứ Hai, Synced Alarm reo 6h30. Hùng ngủ nướng — Mai đã dậy nhưng alarm vẫn kêu bên Hùng cho đến khi anh xác nhận. *"Dậy đi anh, em dậy rồi nè!"* — tin nhắn tự động kèm Vibe Check của Mai: "Tươi tỉnh ☀️". Hùng miễn cưỡng dậy, nhưng mỉm cười.

**Climax:** Chiều thứ Tư, Zodiac Red Flag cảnh báo: *"⚠️ Hôm nay Song Ngư (Mai) đang ở pha nhạy cảm. Chỉ số xung đột: 7/10. Gợi ý: Gọi video trước 9h tối."* Hùng thường sẽ quên gọi vì bận quá. Nhưng lần này, anh gọi đúng 8h45. Mai bất ngờ — *"Sao hôm nay siêng vậy?"*. Không cãi nhau. Cuối tuần, Love Pet "Bông" lên level vì tuần này tương tác đều đặn.

**Resolution:** Dream Jar "Gặp nhau tháng sau" đạt 80%. Cả hai đều thấy mối quan hệ yêu xa bớt mệt mỏi hơn nhờ các tương tác nhỏ nhưng đều đặn mỗi ngày.

---

### Journey 3: "Ly hôn số" — Digital Divorce Flow

**Nhân vật:** Khoa (28 tuổi) & Trang (27 tuổi) — chia tay sau 1 năm sử dụng Cupid.

**Opening Scene:** Khoa mở Settings, bấm **"Digital Divorce"**. Thay vì xóa ngay, app hiện thông báo: *"Quy trình hòa giải 7 ngày bắt đầu. Bạn có muốn tiếp tục?"*.

**Rising Action:**
- **Ngày 1-3:** App nhẹ nhàng hiển thị kỷ niệm — ảnh trong Private Gallery, mốc trên Love Timeline: *"Ngày 100 bên nhau"*, *"Dream Jar 'Mua PS5' đã đạt mục tiêu"*. Không ép ở lại, chỉ nhắc.
- **Ngày 4-5:** App hỏi: *"Bạn muốn giữ lại kỷ niệm dưới dạng file xuất (export) không?"*. Khoa chọn export ảnh.
- **Ngày 6:** Thông báo cuối: *"Ngày mai quy trình sẽ hoàn tất."*

**Climax:** **Ngày 7:** Khoa xác nhận lần cuối. App yêu cầu cả hai bên đồng ý. Trang cũng bấm xác nhận. Love Pet "Bún" hiện lời chào từ biệt. Mọi dữ liệu chung bị xóa vĩnh viễn.

**Resolution:** Cả hai trở về trạng thái "single" trên app. Tài khoản cá nhân vẫn tồn tại — họ có thể ghép đôi với người mới trong tương lai. Quy trình tôn trọng, không toxic, không giữ chân cưỡng ép.

---

### Journey 4: Admin/Ops — Quản trị Hệ thống

**Nhân vật:** Duy (30 tuổi, Backend Engineer kiêm Admin) — vận hành hệ thống Cupid.

**Opening Scene:** Dashboard admin hiển thị metrics hàng ngày: số cặp đôi mới, DAU, lỗi hệ thống.

**Rising Action:** Duy nhận cảnh báo: *Một user báo cáo đối phương "lạm dụng" Anti-Ghosting Lock — bật nhạc liên tục dù đang họp.* Duy vào panel moderation, xem lịch sử tương tác, nhận thấy tần suất bất thường.

**Climax:** Duy tạm vô hiệu hóa tính năng cho cặp đôi đó, gửi thông báo: *"Tính năng đã bị giới hạn do vi phạm quy tắc sử dụng."*. Đồng thời đánh dấu pattern này để team product review lại giới hạn của tính năng.

**Resolution:** Hệ thống hoạt động ổn định. Duy review báo cáo cuối ngày: uptime 99.9%, latency Typing Ghost trung bình 150ms, không có sự cố nghiêm trọng.

---

### Journey Requirements Summary

| Journey | Capabilities Required |
|---|---|
| Onboarding & Pairing | Love Contract UI, Fingerprint Vow, Couple Type Selection, Account creation, Invite/Link system |
| Long Distance | Synced Alarm sync engine, Zodiac Red Flag AI, Love Pet progression, Dream Jar tracking, Push notifications |
| Digital Divorce | 7-day cooldown flow, Data export, Mutual confirmation, Data deletion, Account state management |
| Admin/Ops | Admin dashboard, Moderation panel, Usage analytics, Feature toggle per user, Alert system |

## Domain-Specific Requirements

### Data Classification & Storage Architecture

Hệ thống phân loại dữ liệu theo 3 cấp độ lưu trữ, được quản trị viên cấu hình cho từng loại dữ liệu:

| Cấp độ | Mô tả | Vị trí lưu trữ | Ví dụ dữ liệu mặc định |
|---|---|---|---|
| **Level 1: Device-Only** | Dữ liệu nhạy cảm cao, chỉ tồn tại trên thiết bị người dùng | Local storage (encrypted) | Typing Ghost keystrokes, Private Gallery ảnh, Chat messages, Nội dung Pandora Box |
| **Level 2: Backend Encrypted** | Dữ liệu cần đồng bộ nhưng phải mã hóa E2E | Server (encrypted at rest + in transit, E2E) | Dream Jar số tiền, Expense records, Love Timeline milestones, Vibe Check history |
| **Level 3: Backend Raw** | Dữ liệu vận hành, không nhạy cảm | Server (standard encryption in transit) | Account profiles, Couple Type, Love Pet stats, Synced Alarm settings, App configs |

**Admin Configuration:**
- Quản trị viên chọn cấp độ lưu trữ cho từng loại dữ liệu từ danh sách
- Có thể nâng cấp độ bảo mật (Level 3 → 2 → 1) nhưng không hạ cấp
- Thay đổi cấp độ sẽ trigger migration dữ liệu hiện có

### Privacy & Security

- **Mô hình Zalo-like:** Dữ liệu Level 1 không bao giờ rời thiết bị, server chỉ relay metadata
- **End-to-End Encryption:** Tất cả Level 2 data được mã hóa trước khi gửi lên server
- **Data Deletion:** Khi Digital Divorce hoàn tất, dữ liệu Level 2 & 3 bị xóa vĩnh viễn trên server. Level 1 bị xóa trên thiết bị.
- **Data Export:** User có quyền xuất dữ liệu cá nhân trước khi xóa (PDPA compliance)

### Localization & Market

- **Thị trường mục tiêu:** Việt Nam (ưu tiên)
- **Ngôn ngữ:** Tiếng Việt (mặc định) + Tiếng Anh
- **Tiền tệ:** VND (mặc định cho Dream Jar, Expense Manager)
- **Múi giờ:** UTC+7 (mặc định), hỗ trợ khác múi giờ cho cặp đôi yêu xa

### App Store Compliance

- **Age Rating:** 17+ (do nội dung Pandora Box, Digital Divorce)
- **Permissions yêu cầu:** Notifications, Camera (Private Gallery), Biometrics (Fingerprint Vow)
- **Không yêu cầu:** Truy cập danh bạ, Vị trí (optional cho Date Planner trong Growth)

### Anti-Ghosting Lock (Redesigned)

Thay thế cơ chế "phát nhạc max volume" bằng combo nhẹ nhàng:
- **Đếm ngược công khai:** Hiển thị *"Đã seen X phút mà chưa trả lời"* trên dashboard cả hai bên
- **Emoji Storm:** Sau ngưỡng thời gian (có thể cấu hình), người gửi được quyền "bắn" loạt emoji/sticker tràn ngập màn hình khóa đối phương
- Cặp đôi tự cấu hình ngưỡng thời gian (5/10/15 phút) và bật/tắt từng cơ chế

## Innovation & Novel Patterns

### Detected Innovation Areas

1. **Typing Ghost (Radical Transparency Communication)**
   - Không có app cặp đôi nào hiển thị real-time keystroke bao gồm phần đã xóa
   - Yêu cầu đồng thuận của cả 2 (mutual consent toggle, mặc định BẬT)
   - Tiềm năng viral cực cao — tạo nội dung screenshot/video tự nhiên trên TikTok
   - Đây là tính năng "chưa từng có" trong category couple apps

2. **Relationship Lifecycle Management (Love Contract → Digital Divorce)**
   - Thiết kế toàn bộ vòng đời mối quan hệ như một sản phẩm
   - "Chia tay văn minh" với cooling-off 7 ngày là concept chưa app nào thực hiện
   - Tạo brand identity mạnh: "Yêu nghiêm túc, chia tay đàng hoàng"

3. **"Toxic nhưng vui" Brand Voice**
   - Tông giọng "kiểm soát hài hước" (Emoji Storm, Love Credit, Curfew Mode)
   - Khác biệt hoàn toàn với các app cặp đôi hiện tại (Between, Locket) vốn mang tông "ngọt ngào"
   - Đánh đúng tâm lý Gen Z Việt Nam: châm biếm, tự giễu, gần gũi

4. **3-Tier Data Classification Architecture**
   - Kiến trúc Device-Only / Encrypted Backend / Raw Backend
   - Admin có thể cấu hình cấp độ cho từng loại dữ liệu
   - Hiếm có trong consumer app, tạo lợi thế cạnh tranh về niềm tin

### Market Context & Competitive Landscape

| App | Loại | Điểm mạnh | Cupid khác gì |
|---|---|---|---|
| **Locket** | Photo sharing (bạn bè + cặp đôi) | Rất phổ biến tại VN, Gen Z | Cupid chuyên biệt cho cặp đôi, có gamification + tài chính |
| **Between** | Couple app (Hàn Quốc) | Timeline, chat, nhật ký | Cupid có tông "toxic vui", Typing Ghost, Dream Jar |
| **Honeydue** | Couple finance | Kết nối ngân hàng, quản lý bill | Cupid là ghi chép thủ công, gắn vào trải nghiệm cặp đôi rộng hơn |
| **Tinder/Bumble** | Dating (tìm người mới) | Thống trị thị trường hẹn hò | Cupid phục vụ SAU khi đã có cặp, không phải tìm kiếm |

**Khoảng trống thị trường:** Không có app nào ở VN kết hợp **kết nối cặp đôi + gamification + quản lý tài chính chung** trong một sản phẩm.

### Validation Approach

- **Typing Ghost:** A/B test với 100 cặp đôi beta — đo tỷ lệ bật/tắt, thời gian sử dụng, viral sharing
- **Love Contract / Digital Divorce:** Khảo sát cảm xúc sau onboarding — tỷ lệ screenshot/share là KPI chính
- **Dream Jar:** Theo dõi % cặp đôi tạo mục tiêu trong 7 ngày đầu

### Risk Mitigation

| Rủi ro | Giải pháp |
|---|---|
| Typing Ghost bị copy bởi Zalo/Facebook | First-mover advantage + tính năng chỉ hoạt động trong hệ sinh thái Cupid |
| Typing Ghost gây xung đột cặp đôi | Mutual consent toggle + hướng dẫn sử dụng tích hợp + tips từ AI |
| Brand "toxic" bị hiểu sai | Tông giọng rõ ràng là hài hước, có disclaimer, community guidelines |
| Dữ liệu tài chính nhạy cảm | 3-tier architecture + PDPA compliance + data export |

## Mobile App Specific Requirements

### Platform Requirements

- **Phát triển:** Native — **Swift** (iOS first), **Kotlin** (Android Phase 1.5+)
- **Target OS:** iOS 15.0+ (MVP), Android 8.0+ (API 26) post-MVP
- **Offline mode:** Không yêu cầu ở MVP. Dữ liệu Level 1 (Device-Only) khả dụng cục bộ, các tính năng khác yêu cầu kết nối mạng
- **Ngôn ngữ:** Tiếng Việt (mặc định) + Tiếng Anh, localizable strings

### Device Permissions

Hệ thống quyền truy cập thiết bị **có thể cấu hình bởi quản trị viên**:

| Quyền | Tính năng sử dụng | Mặc định |
|---|---|---|
| Camera | Private Gallery chụp ảnh | Yêu cầu khi dùng |
| Photo Library | Private Gallery chọn ảnh | Yêu cầu khi dùng |
| Biometrics (Face ID / Fingerprint) | Fingerprint Vow pairing | Yêu cầu khi onboarding |
| Notifications | Synced Alarm, Emoji Storm, Vibe Check, Dream Jar | Yêu cầu khi onboarding |
| Alarm/Clock (Android) | Synced Alarm | Yêu cầu khi bật tính năng |

Admin có thể bật/tắt từng quyền cho toàn hệ thống hoặc theo nhóm tính năng.

### Push Notification Strategy

- **Service:** Firebase Cloud Messaging (FCM)
- **Các loại push:**

| Loại | Ưu tiên | Ví dụ |
|---|---|---|
| **Critical** | High | Synced Alarm, Emoji Storm trigger |
| **Engagement** | Normal | Vibe Check reminder, Love Pet status |
| **Informational** | Low | Dream Jar milestone, Love Timeline update |

- **Rate limiting:** Admin cấu hình giới hạn push/ngày/user (mặc định: 15 push/ngày)
- **Quiet hours:** Tôn trọng Do Not Disturb của OS, trừ Synced Alarm (cần đặc quyền alarm)

### Store Compliance

- **Mô hình:** Free download + In-App Purchase
- **Premium subscription:** Monthly/Yearly plan mở khóa AI features (Ghostwriter, Argument Forecast)
- **Virtual goods:** One-time purchase cho Love Pet items, Stickers
- **Age rating:** 17+ (Apple) / Mature 17+ (Google Play)
- **Review guidelines:**
  - Không thu thập dữ liệu không cần thiết
  - Rõ ràng về data usage trong App Privacy (Apple) / Data Safety (Google)
  - Fingerprint Vow sử dụng local biometric API, không gửi dữ liệu sinh trắc ra ngoài

### Implementation Considerations

- **Architecture:** MVVM cho consistency
- **Networking:** REST API + WebSocket (cho Typing Ghost real-time)
- **Local Storage:** CoreData (iOS) cho Level 1 data, Room (Android Phase 1.5+)
- **Encryption:** AES-256 cho dữ liệu cục bộ, TLS 1.3 cho truyền tải
- **CI/CD:** Fastlane cho automated builds, TestFlight (iOS)

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Experience MVP — iOS-first
**Team:** 1 iOS Dev (Swift) + 1 Backend Dev + 1 Designer + AI Coding Agent
**Rủi ro chính:** Thị trường (liệu cặp đôi VN có muốn app riêng cho mối quan hệ?)

### MVP Feature Set (Phase 1) — iOS Only

**Core Journeys Supported:**
- ✅ Journey 1: Onboarding & Pairing (Happy Path)
- ✅ Journey 2: Long Distance (cơ bản)
- ⏳ Journey 3: Digital Divorce → Phase 1.5
- ⏳ Journey 4: Admin/Ops → Phase 1.5

**Must-Have (MVP):**

| # | Tính năng | Lý do phải có |
|---|---|---|
| 1 | **Account & Auth** | Đăng ký/đăng nhập (email + social), profile cơ bản |
| 2 | **Love Contract Onboarding** | Điểm khác biệt, viral moment đầu tiên |
| 3 | **Fingerprint Vow Pairing** | Ghép đôi, brand signature |
| 4 | **Couple Type Selection** | Personalize trải nghiệm (yêu xa, cùng thành phố, mới yêu...) |
| 5 | **Typing Ghost** | Killer feature #1, viral driver |
| 6 | **Priority Channel Chat** | Kênh liên lạc chính giữa cặp đôi |
| 7 | **Vibe Check** | Daily engagement, dữ liệu cảm xúc |
| 8 | **Synced Alarm** | Daily habit formation, cảm giác kết nối |
| 9 | **Love Pet (basic)** | Engagement hook, trạng thái mối quan hệ |
| 10 | **Dream Jar** | Mục tiêu tài chính chung, retention driver |
| 11 | **Expense Manager (basic)** | Ghi chép chi tiêu thủ công |
| 12 | **Love Timeline** | Kỷ niệm, milestone tracking |
| 13 | **Private Gallery** | Ảnh riêng tư, encrypted cục bộ |
| 14 | **Zodiac Red Flag** | Engagement hook, giảm xung đột |
| 15 | **Anti-Ghosting Lock (Emoji Storm + Đếm ngược)** | Engagement, tông "toxic vui" |
| 16 | **Push Notifications (FCM)** | Hạ tầng cho tất cả features trên |

### Post-MVP Features

**Phase 1.5 (Sau MVP 1-2 tháng):**
- Digital Divorce flow (7-day cooldown, data export)
- Admin Dashboard cơ bản (metrics, moderation)
- Love Tasks (daily quests)
- Android version bắt đầu phát triển

**Phase 2 — Growth:**
- Love Credit & Love Ransom (gamification system)
- Ghostwriter AI (Premium)
- Argument Forecast AI (Premium)
- Date & Travel Planner
- Curfew Mode
- Fair Share Game
- Virtual Goods store cho Love Pet
- Android release

**Phase 3 — Expansion:**
- Crisis Simulation (AI stress-test)
- Council of Elders (social voting)
- Smart Contribution (auto-remind + ví liên kết)
- Solidarity Mode
- Mở rộng thị trường quốc tế

### Risk Mitigation Strategy

**Market Risk (Chính):**

| Giải pháp | Chi tiết |
|---|---|
| Closed Beta trước launch | 50-100 cặp đôi thử nghiệm, thu thập feedback trước khi release công khai |
| Viral-first features | Typing Ghost + Love Contract tạo nội dung tự nhiên trên social media |
| TikTok/Reels marketing | Khuyến khích cặp đôi beta share screenshots/videos |
| Quick pivot signals | Nếu DAU/MAU < 20% sau 1 tháng → review lại feature set |

**Technical Risk (Thấp — có AI Agent hỗ trợ):**
- Typing Ghost WebSocket: Prototyping sớm để validate latency < 200ms
- 3-tier data: Thiết kế architecture trước, implement từng cấp

**Resource Risk (Thấp):**
- Team nhỏ nhưng tập trung: iOS-first, không chia sẻ tài nguyên
- AI Coding Agent tăng tốc development đáng kể

## Functional Requirements

### Account & Identity

- **FR1:** User can tạo tài khoản mới bằng email hoặc social login (Google/Apple)
- **FR2:** User can đăng nhập vào tài khoản hiện có
- **FR3:** User can thiết lập hồ sơ cá nhân (tên, ảnh đại diện, ngày sinh, cung hoàng đạo)
- **FR4:** User can đặt ngôn ngữ ưa thích (Tiếng Việt / Tiếng Anh)
- **FR5:** User can khôi phục mật khẩu qua email

### Couple Pairing

- **FR6:** User can tạo và ký Love Contract với các điều khoản hài hước có sẵn
- **FR7:** User can tùy chỉnh thêm điều khoản vào Love Contract
- **FR8:** User can mời đối phương ghép đôi thông qua link chia sẻ
- **FR9:** User can xác nhận ghép đôi bằng Fingerprint Vow (biometric xác nhận đồng thời)
- **FR10:** Cặp đôi can chọn kiểu quan hệ (yêu xa, cùng thành phố, mới yêu, yêu lâu...)

### Communication

- **FR11:** User can gửi và nhận tin nhắn text trong Priority Channel
- **FR12:** User can gửi ảnh và emoji trong chat
- **FR13:** User can bật/tắt Typing Ghost (yêu cầu đồng thuận cả 2 bên)
- **FR14:** User can xem real-time keystroke của đối phương khi Typing Ghost bật (bao gồm phần đã xóa)
- **FR15:** Hệ thống can hiển thị bộ đếm "Đã seen X phút" khi tin nhắn chưa được trả lời
- **FR16:** User can kích hoạt Emoji Storm trên màn hình đối phương khi vượt ngưỡng thời gian chưa trả lời

### Daily Engagement

- **FR17:** Cặp đôi can đặt Synced Alarm với thời gian chung, cả hai phải xác nhận để tắt
- **FR18:** User can hoàn thành Vibe Check hàng ngày (chọn trạng thái cảm xúc)
- **FR19:** User can xem Vibe Check history của cặp đôi
- **FR20:** Cặp đôi can nuôi Love Pet ảo chung, Love Pet phản ánh mức độ tương tác
- **FR21:** Love Pet can thay đổi trạng thái (vui/buồn/ốm) dựa trên tần suất tương tác
- **FR22:** User can xem cảnh báo Zodiac Red Flag dựa trên cung hoàng đạo của cặp đôi

### Financial Management

- **FR23:** Cặp đôi can tạo Dream Jar với tên, mục tiêu số tiền (VND) và deadline
- **FR24:** User can ghi chép đóng góp vào Dream Jar (thủ công)
- **FR25:** User can theo dõi tiến độ Dream Jar (% hoàn thành)
- **FR26:** User can ghi chép chi tiêu chung trong Expense Manager
- **FR27:** User can xem báo cáo chi tiêu theo tuần/tháng

### Memory & Media

- **FR28:** User can chụp/chọn ảnh và lưu vào Private Gallery (mã hóa cục bộ, Level 1)
- **FR29:** User can xem Private Gallery chỉ trên thiết bị của mình
- **FR30:** Hệ thống can tự động ghi lại các mốc quan trọng trên Love Timeline
- **FR31:** User can thêm mốc thủ công vào Love Timeline

### Anti-Ghosting & Engagement Mechanics

- **FR32:** Cặp đôi can cấu hình ngưỡng thời gian Anti-Ghosting (5/10/15 phút)
- **FR33:** Cặp đôi can bật/tắt từng cơ chế Anti-Ghosting (đếm ngược, Emoji Storm)
- **FR34:** User can chọn emoji/sticker để sử dụng trong Emoji Storm

### Data & Privacy

- **FR35:** Hệ thống can phân loại và lưu trữ dữ liệu theo 3 cấp độ (Device-Only / Backend Encrypted / Backend Raw)
- **FR36:** User can xuất dữ liệu cá nhân (data export)
- **FR37:** Hệ thống can mã hóa end-to-end tất cả dữ liệu Level 2
- **FR38:** Hệ thống can gửi push notifications theo 3 mức ưu tiên (Critical / Engagement / Informational)
- **FR39:** User can quản lý cài đặt thông báo (bật/tắt từng loại)

### Admin Configuration

- **FR40:** Admin can cấu hình cấp độ lưu trữ cho từng loại dữ liệu
- **FR41:** Admin can cấu hình giới hạn push notifications/ngày/user
- **FR42:** Admin can bật/tắt quyền truy cập thiết bị theo nhóm tính năng
- **FR43:** Admin can xem metrics cơ bản (số cặp đôi, DAU)

## Non-Functional Requirements

### Performance

- **NFR1:** Typing Ghost keystroke hiển thị trên thiết bị đối phương trong < 200ms
- **NFR2:** Tin nhắn chat gửi/nhận trong < 500ms (điều kiện mạng bình thường)
- **NFR3:** App khởi động cold start < 3 giây trên iPhone 11 trở lên
- **NFR4:** Emoji Storm animation render tại 60fps, không gây lag hệ thống
- **NFR5:** Private Gallery mở ảnh đã mã hóa trong < 1 giây
- **NFR6:** API response time trung bình < 300ms cho các thao tác CRUD

### Security

- **NFR7:** Dữ liệu Level 1 mã hóa AES-256 trên thiết bị, không bao giờ rời device
- **NFR8:** Dữ liệu Level 2 mã hóa end-to-end, server không thể đọc nội dung
- **NFR9:** Dữ liệu Level 3 truyền tải qua TLS 1.3
- **NFR10:** Token authentication (JWT) hết hạn sau 24 giờ, refresh token 30 ngày
- **NFR11:** Biometric data (Fingerprint Vow) xử lý hoàn toàn cục bộ qua OS API, không gửi ra ngoài
- **NFR12:** Tuân thủ PDPA (Luật Bảo vệ Dữ liệu Cá nhân Việt Nam)
- **NFR13:** Data export hoàn thành trong < 5 phút cho tài khoản dưới 1GB dữ liệu

### Scalability

- **NFR14:** Backend hỗ trợ 20,000 concurrent WebSocket connections (10,000 cặp đôi online đồng thời)
- **NFR15:** Hệ thống scale được lên 100,000 cặp đôi mà không cần thay đổi kiến trúc
- **NFR16:** FCM push xử lý burst tối thiểu 50,000 notifications/phút (Synced Alarm đồng loạt)
- **NFR17:** Database query time < 100ms cho p95 dưới 100K users

### Reliability

- **NFR18:** Uptime ≥ 99.5% (downtime tối đa ~3.6 giờ/tháng)
- **NFR19:** Synced Alarm không bao giờ miss khi cả hai online (critical path)
- **NFR20:** Zero data loss cho Level 2 data khi server restart
- **NFR21:** Graceful degradation khi backend lỗi — chat cục bộ vẫn hoạt động với dữ liệu cached

### Integration

- **NFR22:** Firebase Cloud Messaging tích hợp đúng chuẩn APNs cho iOS
- **NFR23:** Social login (Google Sign-In, Sign in with Apple) tuân thủ Apple App Review Guidelines
- **NFR24:** iOS Biometric API (Face ID / Touch ID) sử dụng LAContext framework chuẩn
