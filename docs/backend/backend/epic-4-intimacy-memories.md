# Epic 4: Digital Intimacy & Memories - Backend Integration Guide

## Overview
Tài liệu cung cấp thông tin tích hợp Backend cho phần Intimacy & Memories bao gồm: Thú cưng tình yêu (Love Pet), Dòng thời gian tình yêu (Love Timeline) và Thư viện ảnh chung (Shared/Private Gallery).

---

## 1. Love Pet (Thú cưng ảo)

### 1.1. Xem thông tin Thú cưng (Get Pet)
- **Endpoint URL:** `GET /pets`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:**
  ```json
  {
      "id": "uuid",
      "coupleId": "uuid",
      "species": "cat | dog | bunny",
      "name": "string",
      "happiness": 50,
      "level": 1,
      "totalInteractions": 0,
      "lastInteraction": "ISO date"
  }
  ```

### 1.2. Xem trạng thái Thú cưng (Get Pet Status)
- **Endpoint URL:** `GET /pets/status`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Trả về trạng thái được tính toán dựa trên mức độ tương tác (ví dụ: happy, sad, sick) và logic nội bộ.

### 1.3. Nhận nuôi Thú cưng (Adopt Pet)
- **Endpoint URL:** `POST /pets/adopt`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "species": "cat", // "cat" | "dog" | "bunny"
      "name": "Mimi"
  }
  ```
- **Response:** Đối phượng `Pet` vừa được tạo. (Lưu ý: Mỗi cặp đôi chỉ có 1 thú cưng active).

### 1.4. Tương tác với Thú cưng (Interact)
- **Endpoint URL:** `PATCH /pets/interact`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Description:** Gọi API này khi người dùng chạm/vuốt ve/cho ăn trên UI để tăng điểm `happiness` và `totalInteractions`.
- **Response:** Đối phượng `Pet` đã cập nhật chỉ số.

---

## 2. Love Timeline (Dòng thời gian tình yêu)

### 2.1. Lấy danh sách sự kiện (Get Timeline)
- **Endpoint URL:** `GET /timeline`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Query Parameters:**
  - `limit` (number, optional, default: 50)
  - `offset` (number, optional, default: 0)
- **Response:** Mảng các `TimelineEvent` (sắp xếp giảm dần theo thời gian).
  ```json
  [
    {
      "id": "uuid",
      "coupleId": "uuid",
      "type": "milestone | memory | system",
      "title": "string",
      "description": "string",
      "photoUrl": "string",
      "icon": "string",
      "createdAt": "ISO date",
      "date": "ISO date" // ngày user tự set
    }
  ]
  ```

### 2.2. Thêm sự kiện thủ công (Add Event)
- **Endpoint URL:** `POST /timeline`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "title": "First Date",
      "description": "Ngắm hoàng hôn ở Hồ Tây",
      "photoUrl": "url_anh (optional)",
      "icon": "icon_name (optional)",
      "type": "memory", // "milestone" | "memory" | "system"
      "date": "2024-05-14T10:00:00.000Z (optional)"
  }
  ```
- **Response:** Đối phượng `TimelineEvent` vừa tạo.

### 2.3. Xoá sự kiện (Delete Event)
- **Endpoint URL:** `DELETE /timeline/:id`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** `200 OK`

---

## 3. Private Gallery (Thư viện ảnh kỉ niệm)

### 3.1. Lấy danh sách Ảnh (Get Gallery)
- **Endpoint URL:** `GET /gallery`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Query Parameters:**
  - `limit` (number, optional, default: 50)
  - `offset` (number, optional, default: 0)
- **Response:** Mảng các Item trong Gallery.
  ```json
  [
    {
      "id": "uuid",
      "userId": "uuid",
      "filename": "enc_image_file.jpg",
      "mimeType": "image/jpeg",
      "url": "https://storage...",
      "createdAt": "ISO date"
    }
  ]
  ```

### 3.2. Lưu trữ Ảnh mới (Add to Gallery)
*Lưu ý: Quá trình mã hoá AES ảnh nên được thực hiện phía Client trước khi upload. Backend chỉ lưu đường dẫn hoặc thông tin file đã upload.*
- **Endpoint URL:** `POST /gallery`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "filename": "encrypted_2024.jpg",
      "mimeType": "application/octet-stream" // có thể tuỳ chỉnh
  }
  ```
- **Response:** Đối phượng GalleryItem tạo thành công.

### 3.3. Xoá Ảnh (Delete from Gallery)
- **Endpoint URL:** `DELETE /gallery/:id`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** `200 OK`
