# Epic 3: Daily Engagement & Habits - Backend Integration Guide

## Overview
Tài liệu cung cấp thông tin tích hợp Backend cho phần Daily Engagement bao gồm Báo thức đôi (Synced Alarm), Trạng thái cảm xúc (Vibe Check) và Anti-Ghosting.

---

## 1. Synced Alarm (Báo thức đôi)

### 1.1. Xem chuông báo thức hiện tại (Get Alarm)
- **Endpoint URL:** `GET /alarms`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:**
  ```json
  {
      "id": "uuid",
      "coupleId": "uuid",
      "time": "ISO date",
      "status": "pending | active | ringing | stopped",
      "confirmedBy": ["user_id_1"] // mảng user đã xác nhận
  }
  ```

### 1.2. Tạo hoặc Cập nhật Báo thức (Create/Update Alarm)
- **Endpoint URL:** `POST /alarms`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "time": "2026-02-14T07:00:00.000Z" // Chuẩn ISO 8601
  }
  ```
- **Response:** Trả về đối tượng `Alarm`. Trạng thái sẽ là `pending` chờ đối phương xác nhận.

### 1.3. Xác nhận giờ báo thức (Confirm Alarm)
- **Endpoint URL:** `PATCH /alarms/:id/confirm`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Khi cả hai cùng xác nhận, trạng thái sẽ chuyển sang `active`.

### 1.4. Tắt báo thức khi đang chuông (Stop Alarm)
- **Endpoint URL:** `PATCH /alarms/:id/stop`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Description:** Được gọi khi thiết bị đang đổ chuông và user thao tác tắt. Báo thức chỉ thực sự dừng đổ chuông ở máy đối phương khi cả hai bên đã gọi API này (hoặc emit socket nếu có tích hợp).
- **Response:** Trạng thái có thể chuyển sang `stopped` nếu thoả mãn điều kiện cả hai đều tắt.

---

## 2. Daily Vibe Check (Trạng thái cảm xúc)

### 2.1. Đăng cảm xúc hôm nay (Create Vibe)
- **Endpoint URL:** `POST /vibes`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "mood": "happy", // "happy" | "sad" | "angry" | "horny" | "tired"
      "note": "string (optional)"
  }
  ```
- **Response:** Trả về đối tượng `Vibe` vừa tạo.

### 2.2. Xem cảm xúc hôm nay của mình (Get Today Vibe)
- **Endpoint URL:** `GET /vibes/today`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Đối tượng `Vibe` mới nhất trong ngày của user.

### 2.3. Lịch sử cảm xúc của mình (Get My History)
- **Endpoint URL:** `GET /vibes/history`
- **Query Parameters:** `days` (optional, default: 30) - Số ngày muốn xem lịch sử.
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Mảng các đối tượng `Vibe`.

### 2.4. Lịch sử cảm xúc của đối phương (Get Partner History)
- **Endpoint URL:** `GET /vibes/partner`
- **Query Parameters:** `days` (optional, default: 30)
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Mảng các đối tượng `Vibe` của đối phương.

---

## 3. Anti-Ghosting
Cơ chế Anti-Ghosting bao gồm việc cấu hình ngưỡng thời gian, hình phạt và trigger Emoji Storm.
Các API này phần lớn được quản lý chung trong module `GhostConfig`.

- **Chi tiết xem tại tài liệu:** [Epic 2 - Communication](./epic-2-communication.md#3-ghost-typing-configuration-rest-api)
- **Check list API cần dùng cho Anti-Ghosting:**
  - `POST /ghost-config` -> Thiết lập timeout/penalty.
  - `GET /ghost-config/storm-status/:partnerId` -> Kiểm tra xem lúc này có được phép bão emoji (trigger storm) hay không.
  - Tích hợp WebSocket Socket.io event `emojiStorm` để trigger mưa màn hình.
