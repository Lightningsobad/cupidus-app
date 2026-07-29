# Epic 2: Communication - Backend Integration Guide

## Overview
Tài liệu cung cấp thông tin tích hợp Backend cho phần Communication bao gồm Chat qua cả REST API và WebSocket, cùng với cơ chế Typing Ghost độc quyền.

---

## 1. REST API: Quản lý tin nhắn

### 1.1. Lấy danh sách tin nhắn (Get Messages)
- **Endpoint URL:** `GET /messages`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Query Parameters:**
  - `partnerId` (string, required): ID của đối phương (receiver/sender kia).
  - `page` (number, optional, default: 1)
  - `limit` (number, optional, default: 20)
- **Response:** Mảng các đối tượng `Message`.
  ```json
  [
    {
      "id": "uuid",
      "content": "string",
      "type": "text | image | video | ghost",
      "senderId": "uuid",
      "receiverId": "uuid",
      "status": "sent | delivered | seen",
      "readAt": "ISO date",
      "createdAt": "ISO date"
    }
  ]
  ```

### 1.2. Gửi tin nhắn qua REST (Fallback/Create Message)
Thông thường tin nhắn nên được gửi qua WebSocket (xem phần dưới) để đảm bảo realtime. Tuy nhiên tuỳ vào thiết kế, app có thể gọi API này sau đó server sẽ tự động stream xuống Socket.
- **Endpoint URL:** `POST /messages`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "content": "Hello",
      "receiverId": "uuid_of_partner",
      "type": "text" // hoặc "image", "video"
  }
  ```
- **Response:** Đối tượng `Message` vừa được tạo.

---

## 2. WebSocket: Real-time Chat & Ghost Typing

Kết nối WebSocket sử dụng **Socket.io**.
URL: `ws://<domain>` hoặc tuỳ thuộc cài đặt gateway.

### 2.1. Kết nối và Authentication
App cần join room của chính user đó. Việc này cho phép server gửi tin nhắn đích danh. Theo cơ chế hiện tại:

- **Client Emit:** `joinRoom`
  - **Payload:** `userId` (chuỗi ID của user hiện tại, lấy từ profile)
- **Server Broadcast/Emit:** `joinedRoom` (Payload: `userId`)

### 2.2. Gửi & Nhận tin nhắn (Send/Receive Flow)
- **Client Emit:** `sendMessage`
  - **Payload:** (giống body Create Message)
    ```json
    { "content": "text", "receiverId": "uuid", "type": "text" }
    ```
- **Server Emit về đối phương (Receiver):** `newMessage`
  - **Payload:** Đối tượng `Message` hoàn chỉnh.

### 2.3. Trạng thái tin nhắn (Delivered & Seen)
- **Đánh dấu Đã gửi (Delivered):**
  - **Client Emit:** `markDelivered`
    - Payload: `{ "senderId": "uuid_nguoi_gui", "receiverId": "uuid_nguoi_nhan_la_minh" }`
  - **Server Emit về Sender:** `messageDelivered`
    - Payload: `{ "deliveredTo": "uuid", "deliveredAt": "date" }`

- **Đánh dấu Đã xem (Seen):**
  - **Client Emit:** `markSeen`
    - Payload: `{ "senderId": "uuid_nguoi_gui", "receiverId": "uuid_nguoi_nhan_la_minh" }`
  - **Server Emit về Sender:** `messageSeen`
    - Payload: `{ "seenBy": "uuid", "readAt": "date" }`

### 2.4. Typing & Ghost Typing
Ghost Typing hiển thị từng ký tự trước khi gửi.

- **Báo đang Gõ (Bao gồm nội dung cho Ghost Mode):**
  - **Client Emit:** `typing`
    - Payload: `{ "content": "nội dung đang gõ", "senderId": "uuid_cua_minh", "receiverId": "uuid_doi_phuong" }`
  - **Server kiểm tra Ghost Config:** Nếu sender bật Ghost Mode, server sẽ emit event xuống partner.
  - **Server Emit về Receiver:** `ghostTyping`
    - Payload: `{ "content": "nội dung", "senderId": "uuid" }`

- **Dừng Gõ:**
  - **Client Emit:** `stopTyping`
    - Payload: `{ "senderId": "uuid_cua_minh", "receiverId": "uuid_doi_phuong" }`
  - **Server Emit về Receiver:** `ghostStopTyping`
    - Payload: `{ "senderId": "uuid" }`

### 2.5. Emoji Storm penalty (Anti-Ghosting Penalty)
- **Kích hoạt Emoji storm (Client Emit):** `emojiStorm`
  - Payload: `{ "senderId": "uuid_cua_minh", "receiverId": "uuid_bi_storm" }`
  - *Lưu ý: Chỉ gửi được nếu người gửi đã cấu hình penalty là Emoji Storm và timeout thoả mãn (server check ngầm).*
- **Nhận Emoji storm (Server Emit về Receiver):** `emojiStormReceived`
  - Payload: `{ "senderId": "uuid", "penalty": "emoji_storm" }`

---

## 3. Ghost Typing Configuration (REST API)
Cấu hình Ghost Mode và các hình phạt (Penalty).

### 3.1. Tạo yêu cầu bật Ghost Mode (Create Config)
Bất kỳ cấu hình nào thay đổi đều cần phải approve từ partner.
- **Endpoint URL:** `POST /ghost-config`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "isEnabled": true,
      "timeoutMinutes": 15,
      "penalty": "emoji_storm" // hoặc "noise", "none"
  }
  ```
- **Response:** Đối tượng `GhostConfig`, trạng thái `pending`. (PartnerId tự động trích xuất dựa trên user cặp đôi hiện tại).

### 3.2. Lấy cấu hình đang Active
- **Endpoint URL:** `GET /ghost-config`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Trả về cấu hình hiệu lực hiện tại (status = active).

### 3.3. Lấy cấu hình đang Chờ duyệt (Pending)
- **Endpoint URL:** `GET /ghost-config/pending`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Trả về các cấu hình đang chờ duyệt (nếu có).

### 3.4. Approve & Reject Config
- **Approve:** `PATCH /ghost-config/:id/approve`
- **Reject:** `PATCH /ghost-config/:id/reject`
- Tham số `:id` là UUID của `GhostConfig`. Trả về Config sau khi duyệt/từ chối.

### 3.5. Kiểm tra trạng thái Storm (Get Storm Status)
(Xem có thoả mãn điều kiện Anti-Ghosting không để hiện nút Storm):
- **Endpoint URL:** `GET /ghost-config/storm-status/:partnerId`
- **Response:** Kiểm tra trạng thái seen/messages cuối cùng và trả về liệu user có đực phép trigger storm hay không.
