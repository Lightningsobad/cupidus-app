# Cupid App - Danh Sách Toàn Bộ Actions & Ma Trận Notification / Realtime Socket / In-App Popup

Tài liệu này đặc tả toàn bộ các tương tác, hành động (actions) giữa cặp đôi trong **Cupid App**, phân loại chi tiết theo cơ chế thông báo (**Push Notification**), truyền tải thời gian thực (**WebSocket / Socket.IO**), và phản hồi giao diện (**In-App Popup / Modal / Toast / Fullscreen**), đảm bảo xử lý đồng bộ trong cả 2 trạng thái thiết bị của người nhận (App đang mở hoặc đang tắt/chạy ngầm).

---

## 1. Kiến Trúc Phân Phối Tín Hiệu (Multi-Channel Realtime Architecture)

```
                       [ ACTION TỪ PHÍA USER A ]
                                   │
                                   ▼
                          [ BACKEND SERVICE ]
                                   │
                 ┌─────────────────┴─────────────────┐
                 ▼                                   ▼
     [ NẾU USER B ĐANG MỞ APP ]          [ NẾU USER B TẮT APP / NGẦM ]
                 │                                   │
                 ▼                                   ▼
        [ WEBSOCKET (SOCKET.IO) ]               [ PUSH NOTIFICATION (FCM) ]
                 │                                   │
     ┌───────────┴───────────┐                       ▼
     ▼                       ▼             [ Bấm vào thông báo Push ]
[POPUP / MODAL]       [REALTIME SYNC]                │
(Duyệt/Từ chối)     (Cập nhật UI ngầm)               ▼
                                           [ Mở App -> Kích hoạt Modal tương ứng ]
```

### Xử lý 2 Trạng thái thiết bị của Người Nhận (Partner):
1. **Khi đối phương TẮT app / Chạy ngầm (Background / Terminated):**
   * Backend kích hoạt **Push Notification (Firebase Cloud Messaging - FCM / APNs)**.
   * Push notification chứa payload định danh (`actionType`, `targetId`, `deepLink`).
   * Khi người dùng nhấn vào thông báo -> App khởi chạy và tự động điều hướng / mở **Interactive Dialog / Modal** tương ứng để thao tác.
   * Với các hành động khẩn cấp (Báo thức reo, Bão Emoji Storm, v.v.), Push Notification được gửi dưới dạng **High Priority / Critical Alert**.
2. **Khi đối phương đang MỞ app (Foreground / Active):**
   * Backend phát sự kiện qua **WebSocket (Socket.IO)** tới room riêng của `partnerId`.
   * Client bắt sự kiện và hiển thị ngay trên UI theo các cấp độ tương tác:
     * **Cấp độ 1: Interactive Dialog / Modal Popup (Chặn & Yêu cầu duyệt ngay: Accept / Reject / Slide / Touch)**.
     * **Cấp độ 2: Fullscreen Takeover (Chiếm toàn màn hình khẩn cấp: Báo thức reo, Bão Emoji)**.
     * **Cấp độ 3: In-App Top Banner / Toast (Thông báo nổi, không chặn thao tác, bấm để xem)**.
     * **Cấp độ 4: Silent UI State Sync (Tự động cập nhật số liệu, đổi màu theme, thanh máu Pet ngầm)**.

---

## 2. Bảng Ma Trận Chi Tiết Từng Module & Action

---

### Module 1: Kho Theme & Tùy Biến Giao Diện (Themes)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **TH-01** | **Yêu cầu đổi/mua Theme mới**<br>`POST /themes/request` | 🔔 *"Bae muốn đổi sang giao diện [Tên Theme]! Hãy mở app để duyệt nhé."* | `theme:request`<br>`{ themeId, requesterId }` | 🔴 **Interactive Dialog Popup**:<br>Hiện modal preview theme mới + 2 nút **[Đồng ý]** / **[Từ chối]**. |
| **TH-02** | **Partner Duyệt đổi Theme**<br>`POST /themes/approve` | 🔔 *"Bae đã đồng ý đổi giao diện sang [Tên Theme]! 🎉"* | `theme:approved`<br>`{ activeThemeId }` | ⚡ **Silent Auto-Sync**:<br>Toàn bộ theme app của cả 2 tự chuyển sang màu/skin mới tức thì + Toast chúc mừng. |
| **TH-03** | **Partner Từ chối đổi Theme**<br>`POST /themes/reject` | 🔔 *"Bae chưa ưng theme này rồi, hãy thử chọn theme khác nhé!"* | `theme:rejected`<br>`{ themeId }` | 🟡 **In-App Toast**:<br>Báo *"Bae đã từ chối yêu cầu đổi theme"*. |
| **TH-04** | **Thêm theme vào Wishlist**<br>`POST /themes/wishlist` | 🔔 *"Bae vừa thả tim [Tên Theme] vào Wishlist chung!"* | `theme:wishlist_updated`<br>`{ wishlistThemeId, userId }` | 🟢 **In-App Toast** + Cập nhật icon tim trong Wishlist. |

---

### Module 2: Hũ Ước Mơ & Ống Heo Tiết Kiệm (Dream Jar)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **DJ-01** | **Tạo Hũ ước mơ mới**<br>`POST /dream-jar` | 🔔 *"Bae vừa tạo hũ ước mơ mới: [Tên hũ]. Cần bạn duyệt để bắt đầu nuôi heo!"* | `dream_jar:created`<br>`{ jarId, name, targetAmount }` | 🔴 **Interactive Dialog Popup**:<br>Modal chi tiết hũ (mục tiêu tiền, hạn chót) + 2 nút **[Duyệt hũ]** / **[Từ chối]**. |
| **DJ-02** | **Duyệt tạo Hũ ước mơ**<br>`PATCH /dream-jar/:id/approve` | 🔔 *"Bae đã duyệt hũ ước mơ [Tên hũ]! Bắt đầu tích lũy thôi 💕"* | `dream_jar:status_changed`<br>`{ jarId, status: 'ACTIVE' }` | 🟢 **In-App Toast** + Chuyển trạng thái hũ sang `ACTIVE` trên màn hình. |
| **DJ-03** | **Từ chối tạo Hũ ước mơ**<br>`PATCH /dream-jar/:id/reject` | 🔔 *"Bae đã từ chối tạo hũ ước mơ [Tên hũ]."* | `dream_jar:status_changed`<br>`{ jarId, status: 'REJECTED' }` | 🟡 **In-App Toast** + Đổi trạng thái hũ sang `REJECTED`. |
| **DJ-04** | **Nạp tiền / Bỏ ống vào Hũ**<br>`POST /dream-jar/:id/contributions` | 🔔 *"Bae vừa bỏ thêm [Số tiền] vào [Tên hũ]! 🐷"* | `dream_jar:contributed`<br>`{ jarId, amount, currentAmount, contributorId }` | ⚡ **Realtime Auto-Sync**:<br>Số tiền hiện tại nhảy số tăng lên + Hiệu ứng xu bay/Toast. |
| **DJ-05** | **Hũ đạt 100% mục tiêu**<br>*(Auto transition)* | 🔔 *"Chúc mừng 2 bạn! Hũ [Tên hũ] đã chính thức về đích! 🎉"* | `dream_jar:completed`<br>`{ jarId, name, totalAmount }` | 🎆 **Celebration Modal**:<br>Hiệu ứng pháo hoa toàn màn hình chúc mừng cả 2. |
| **DJ-06** | **Xóa / Sửa Hũ ước mơ**<br>`DELETE /dream-jar/:id` | 🔔 *"Bae đã xóa hũ ước mơ [Tên hũ]."* | `dream_jar:deleted`<br>`{ jarId }` | ⚡ **Realtime Auto-Sync**:<br>Xóa card hũ khỏi danh sách trên màn hình. |

---

### Module 3: Hợp Đồng Tình Yêu & Quy Tắc Cặp Đôi (Love Contracts)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **LC-01** | **Tạo bản hợp đồng / quy tắc mới**<br>`POST /love-contracts` | 🔔 *"Bae vừa soạn Hợp đồng tình yêu mới. Hãy vào ký tên nhé! 📜"* | `contract:created`<br>`{ contractId, title, rules }` | 🔴 **Interactive Dialog Popup / Bottom Sheet**:<br>Xem nội dung điều khoản + Nút **[Đặt bút ký tên]** / **[Từ chối]**. |
| **LC-02** | **Ký tên / Chấp thuận hợp đồng**<br>`PATCH /love-contracts/sign` | 🔔 *"Bae đã ký tên vào hợp đồng! Hợp đồng chính thức có hiệu lực 💕"* | `contract:signed`<br>`{ contractId, status: 'ACTIVE', signedAt }` | 📜 **Celebration Modal**:<br>Hiển thị con dấu / chữ ký của cả 2 + Đổi trạng thái sang `ACTIVE`. |
| **LC-03** | **Báo cáo vi phạm điều khoản / Phạt** | 🔔 *"Bae vừa bấm còi phạt bạn vi phạm điều khoản hợp đồng! 🚨"* | `contract:violated`<br>`{ contractId, ruleIndex, penalty }` | 🔴 **Interactive Popup**:<br>Báo vi phạm + Yêu cầu thực hiện hình phạt. |

---

### Module 4: Báo Thức Đôi Đồng Bộ (Synced Alarms)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **AL-01** | **Đặt giờ báo thức đôi mới**<br>`POST /alarms` hoặc socket `setAlarm` | 🔔 *"Bae muốn đặt báo thức đôi lúc [HH:mm]. Bạn có đồng ý không?"* | `alarm:newAlarmRequest`<br>`{ alarmId, time, requesterId }` | 🔴 **Interactive Dialog Popup**:<br>Hiện giờ báo thức + Nút **[Chấp nhận]** / **[Đổi giờ khác]**. |
| **AL-02** | **Xác nhận giờ báo thức**<br>`PATCH /alarms/:id/confirm` hoặc socket `confirmAlarm` | 🔔 *"Bae đã xác nhận giờ báo thức lúc [HH:mm]!"* | `alarm:alarmScheduled`<br>`{ alarmId, status: 'CONFIRMED' }` | 🟢 **In-App Toast** + Cập nhật icon chuông kích hoạt trên màn hình Home. |
| **AL-03** | **Báo thức reo**<br>`triggerAlarm` | 🚨 **Critical Alert / Push Call**:<br>Đổ chuông báo thức toàn màn hình (kể cả khi tắt app). | `alarm:triggerAlarm`<br>`{ alarmId, time }` | ⏰ **Fullscreen Alarm Ringing Screen**:<br>Màn hình chuông reo toàn bộ máy + Nút trượt để tắt chuông. |
| **AL-04** | **Một bên tắt báo thức trước**<br>`PATCH /alarms/:id/stop` hoặc socket `stopAlarm` | 🔔 *"Bae đã dậy và tắt báo thức rồi! Đến lượt bạn đấy nhé ☀️"* | `alarm:alarmStoppedByPartner`<br>`{ stopperId }` | 🟡 **In-App Live Banner**:<br>Màn hình chuông cập nhật *"Bae đã dậy, đang đợi bạn tắt chuông!"*. |
| **AL-05** | **Cả 2 cùng tắt xong báo thức**<br>`alarmFullyStopped` | 🔔 *"Cả hai đã cùng thức dậy thành công! Chúc một ngày ngọt ngào."* | `alarm:alarmFullyStopped`<br>`{ alarmId }` | 🟢 Tắt hoàn toàn màn hình chuông trên cả 2 máy. |

---

### Module 5: Anti-Ghosting & Ghost Mode (Chống Ghost & Bão Emoji)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **AG-01** | **Đề xuất đổi quy tắc Anti-Ghosting**<br>`POST /ghost-config` | 🔔 *"Bae muốn đổi giới hạn thời gian phản hồi tin nhắn thành [X] phút!"* | `ghost_config:requested`<br>`{ configId, timeoutMinutes, penalty }` | 🔴 **Interactive Dialog Popup**:<br>Chi tiết quy tắc mới + Nút **[Đồng ý luật]** / **[Từ chối]**. |
| **AG-02** | **Duyệt / Từ chối cấu hình Ghosting**<br>`PATCH /ghost-config/:id/approve` | 🔔 *"Bae đã [chấp thuận / từ chối] luật Anti-Ghosting mới."* | `ghost_config:updated`<br>`{ configId, status }` | 🟢 **In-App Toast** + Áp dụng timeout mới. |
| **AG-03** | **Cảnh báo sắp hết giờ (Ghost Warning)** | 🔔 *"Còn 5 phút nữa là hết hạn phản hồi! Hãy nhắn tin cho Bae ngay kẻo bị phạt ⚠️"* | `ghost:countdown_warning`<br>`{ remainingSeconds }` | 🟡 **Top Banner cảnh báo**:<br>Đếm ngược thời gian trong app. |
| **AG-04** | **Bị dội bão Emoji (Emoji Storm)**<br>Socket `emojiStorm` | 🔔 *"Bae vừa dội Bão Emoji vì bạn dám ghost quá lâu! 💣🔥"* | `chat:emojiStormReceived`<br>`{ senderId, penalty }` | 💥 **Fullscreen Takeover Animation**:<br>Màn hình rung giật, hàng trăm emoji nổ tung tràn ngập toàn bộ app. |
| **AG-05** | **Ghost Typing (Xem gõ realtime)**<br>Socket `typing` / `stopTyping` | *(Không cần Push)* | `chat:ghostTyping`<br>`{ content, senderId }` | ⚡ **Realtime UI Sync**:<br>Hiện chính xác từng ký tự đối phương đang gõ trong khung chat. |

---

### Module 6: Trò Chuyện & Tương Tác Tức Thì (Chat & Nudge)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **CH-01** | **Gửi tin nhắn mới (Text/Ảnh/Voice)**<br>`POST /messages` hoặc socket `sendMessage` | 🔔 *"[Tên Bae]: [Nội dung tin nhắn / Đã gửi một ảnh]"* | `chat:newMessage`<br>`{ message }` | ⚡ Thêm tin nhắn vào box chat; nếu đang ở màn hình khác thì hiện **Top Notification Banner**. |
| **CH-02** | **Đã nhận / Đã xem tin nhắn**<br>Socket `markDelivered` / `markSeen` | *(Không cần Push)* | `chat:messageDelivered`<br>`chat:messageSeen` | ⚡ Cập nhật icon trạng thái tin nhắn (1 tích -> 2 tích -> Avatar đã đọc). |
| **CH-03** | **Thả cảm xúc / Reaction tin nhắn** | 🔔 *"Bae đã thả ❤️ vào tin nhắn của bạn"* | `chat:messageReaction`<br>`{ messageId, reaction }` | ⚡ Hiển thị icon reaction ngay trên bong bóng tin nhắn. |
| **CH-04** | **Gửi Nudge / Chạm yêu thương / Rung tim** | 🔔 *"Bae vừa chạm nhẹ vào tim bạn 💓"* | `chat:nudge`<br>`{ senderId, type: 'heartbeat' }` | 💓 **Haptic & Visual Effect**:<br>Màn hình nhấp nháy hiệu ứng trái tim đập + máy rung theo nhịp tim. |

---

### Module 7: Thú Cưng Ảo Đôi (Love Pet)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **PT-01** | **Nhận nuôi Pet mới**<br>`POST /pets/adopt` | 🔔 *"Bae vừa nhận nuôi bé Pet [Tên Pet]! Hãy vào chào đón thành viên mới 🐾"* | `pet:adopted`<br>`{ petId, name, type }` | 🔴 **Interactive Welcome Modal**:<br>Hiện hoạt ảnh trứng nở / Pet ra mắt + Nút **[Vào cưng nựng]**. |
| **PT-02** | **Cho Pet ăn / Tắm / Chơi đùa**<br>`PATCH /pets/interact` | 🔔 *"Bae vừa cho [Tên Pet] ăn no căng bụng rồi! 🍖"* | `pet:interacted`<br>`{ petId, hunger, happiness, action }` | ⚡ **Realtime Animation & Progress Sync**:<br>Pet chạy hoạt ảnh ăn/nhảy múa + Thanh hạnh phúc tăng lên. |
| **PT-03** | **Cảnh báo Pet bị đói / ốm**<br>*(System Alert)* | 🔔 *"[Tên Pet] đang đói lả kìa! Mau vào cho bé ăn thôi 😿"* | `pet:status_warning`<br>`{ status: 'HUNGRY' }` | 🟡 **In-App Alert Banner**:<br>Cảnh báo trạng thái Pet cần chăm sóc. |

---

### Module 8: Nhật Ký Tâm Trạng (Daily Vibe Check)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **VB-01** | **Đăng tâm trạng hôm nay**<br>`POST /vibes` | 🔔 *"Bae vừa cập nhật tâm trạng: [Mood Emoji/Tên tâm trạng] - [Ghi chú]"* | `vibe:posted`<br>`{ userId, mood, note, createdAt }` | 🟢 **In-App Toast** + Widget tâm trạng trên Home Screen tự động cập nhật avatar/icon của Bae. |
| **VB-02** | **Gửi phản hồi / Ôm an ủi khi Bae buồn** | 🔔 *"Bae vừa gửi cho bạn một cái ôm ấm áp: [Lời nhắn] 🤗"* | `vibe:hug_sent`<br>`{ senderId, message }` | 💖 **In-App Floating Modal**:<br>Hiệu ứng vòng tay ôm / trái tim ấm áp + Lời nhắn an ủi. |

---

### Module 9: Sổ Chi Tiêu & Quỹ Chung (Shared Expenses)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **EX-01** | **Thêm khoản chi tiêu mới**<br>`POST /expenses` | 🔔 *"Bae vừa ghi chép khoản chi: [Tên khoản chi] - [Số tiền] (Chia 50/50)"* | `expense:created`<br>`{ expense }` | 🟢 **In-App Toast** + Danh sách chi tiêu & số dư quỹ tự cập nhật lại. |
| **EX-02** | **Yêu cầu quyết toán / Settle Up** | 🔔 *"Bae gửi yêu cầu quyết toán chi tiêu tháng này: [Số tiền cần thanh toán]"* | `expense:settle_request`<br>`{ amount, period }` | 🔴 **Interactive Dialog Popup**:<br>Xem bảng kê chi tiêu + Nút **[Xác nhận đã thanh toán]**. |
| **EX-03** | **Xóa / Sửa khoản chi**<br>`DELETE /expenses/:id` | *(Không bắt buộc Push hoặc Push nhẹ)* | `expense:updated`<br>`{ expenseId }` | ⚡ **Realtime Auto-Sync**:<br>Cập nhật lại số liệu trên màn hình sổ chi tiêu. |

---

### Module 10: Kho Ảnh & Dòng Thời Gian Kỷ Niệm (Gallery & Timeline)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **GL-01** | **Đăng ảnh mới vào Album chung**<br>`POST /gallery` | 🔔 *"Bae vừa thêm [N] ảnh mới vào album kỷ niệm! 📸"* | `gallery:item_added`<br>`{ item }` | 🟢 **In-App Toast** + Thêm ảnh mới vào Grid Gallery mà không cần F5. |
| **TL-01** | **Thêm cột mốc kỷ niệm mới**<br>`POST /timeline` | 🔔 *"Bae vừa ghi lại một kỷ niệm đẹp: [Tên kỷ niệm] 💕"* | `timeline:event_added`<br>`{ event }` | 🟢 **In-App Toast** + Dòng thời gian Timeline tự chèn thêm event mới. |
| **TL-02** | **Nhắc nhở ngày kỷ niệm yêu nhau**<br>*(Cron / System)* | 🔔 *"Hôm nay là kỷ niệm [N] ngày yêu nhau của 2 bạn! Hãy dành lời ngọt ngào cho nhau nhé 🌹"* | `timeline:anniversary_alert`<br>`{ daysCount, milestoneName }` | 🎆 **Celebration Fullscreen Card**:<br>Mở ra thiệp chúc mừng kỷ niệm ngày yêu. |

---

### Module 11: Ghép Đôi & Lời Thề Tình Yêu (Pairing & Biometric Vow)

| Mã Action | Tên Action / API | 1. Push Notification (Khi app TẮT/Ngầm) | 2. Socket Event (Khi app MỞ) | 3. In-App UI / Popup (Khi app MỞ) |
| :--- | :--- | :--- | :--- | :--- |
| **PR-01** | **Chấp nhận mã ghép đôi**<br>`POST /invitations/accept` | 🔔 *"Chúc mừng! Bạn và [Tên partner] đã kết đôi thành công 💕"* | `pairing:success`<br>`{ partner }` | 🔴 **Interactive Modal**:<br>Màn hình ghép đôi thành công, chuyển hướng vào App chính / Tuyên thệ. |
| **PR-02** | **Cùng tuyên thệ vân tay (Biometric Vow)**<br>`POST /users/vow` | 🔔 *"Bae đang chờ bạn cùng đặt ngón tay để tuyên thệ lời thề tình yêu! 🤝"* | `vow:partner_ready`<br>`{ userId }` | 🔴 **Interactive Sync Touch Screen**:<br>Hiển thị 2 dấu vân tay trên màn hình; khi cả 2 cùng chạm giữ -> Kích hoạt hiệu ứng hoàn thành lời thề. |
| **PR-03** | **Hủy kết đôi (Unlink / Chia tay)** | 🔔 *"Mối quan hệ đã bị hủy kết đôi bởi đối phương."* | `pairing:unlinked` | 🔴 **Blocking Alert Modal**:<br>Thông báo hủy kết đôi và đưa app trở về trạng thái chưa ghép đôi. |

---

## 3. Phân Loại Theo Mức Độ Ưu Tiên Xử Lý (Priority Categorization)

### 🔴 NHÓM 1: CẦN POPUP TƯƠNG TÁC NGAY (Interactive Dialogs / Modals)
> *Bắt buộc phải hiện Dialog/Modal đè lên màn hình hiện tại kèm nút Accept / Reject khi app mở, hoặc mở ngay khi user nhấn vào Push Notification:*
1. **Yêu cầu đổi / mua Theme** (`theme:request`)
2. **Duyệt tạo Hũ ước mơ mới** (`dream_jar:created`)
3. **Ký duyệt Hợp đồng tình yêu** (`contract:created`)
4. **Xác nhận giờ Báo thức đôi** (`alarm:newAlarmRequest`)
5. **Duyệt thay đổi luật Anti-Ghosting** (`ghost_config:requested`)
6. **Yêu cầu quyết toán sổ chi tiêu** (`expense:settle_request`)
7. **Tuyên thệ đồng bộ vân tay** (`vow:partner_ready`)
8. **Chấp nhận lời mời kết đôi** (`pairing:success`)

---

### 💥 NHÓM 2: CẦN CHIẾM TOÀN MÀN HÌNH KHẨN CẤP (Fullscreen Takeover)
> *Các sự kiện đặc biệt chiếm toàn bộ màn hình, phát âm thanh / rung mạnh:*
1. **Báo thức đôi đang reo** (`alarm:triggerAlarm` - Fullscreen Ringing Screen có nút trượt tắt).
2. **Bị dội bom Emoji Storm do Ghosting** (`chat:emojiStormReceived` - Màn hình rung giật, hàng trăm emoji nổ tung tràn ngập app).

---

### 🟢 NHÓM 3: THÔNG BÁO NỔI TRONG APP (In-App Toast / Floating Banner)
> *Hiện thanh thông báo nhẹ ở cạnh trên màn hình (Top Toast Banner), không gián đoạn thao tác của người dùng, bấm vào để mở chi tiết:*
1. Nạp tiền vào hũ ước mơ (`dream_jar:contributed`)
2. Cho thú cưng ăn / chơi đùa (`pet:interacted`)
3. Đăng cảm xúc hôm nay (`vibe:posted`)
4. Thêm khoản chi tiêu mới (`expense:created`)
5. Thêm ảnh vào album (`gallery:item_added`)
6. Thêm kỷ niệm dòng thời gian (`timeline:event_added`)
7. Nhận cái ôm an ủi / Chạm tim (`vibe:hug_sent`, `chat:nudge`)

---

### ⚡ NHÓM 4: ĐỒNG BỘ DỮ LIỆU NGẦM TỨC THÌ (Silent Realtime State Sync)
> *Tự động cập nhật State và Render lại UI trực tiếp qua Socket mà không cần F5/Reload:*
1. **Ghost Typing**: Xem trực tiếp chữ đối phương đang gõ.
2. **Message Seen / Delivered**: Cập nhật trạng thái tin nhắn (1 vạch, 2 vạch, đã xem).
3. **Active Theme Switch**: Giao diện cả 2 tự đổi màu khi theme được duyệt.
4. **Dream Jar Progress**: Cập nhật thanh tiến độ tiền hũ ước mơ.
5. **Pet Status**: Cập nhật thanh đói/hạnh phúc của Pet.
6. **Shared Expenses List**: Tự thêm dòng chi tiêu mới vào danh sách.
