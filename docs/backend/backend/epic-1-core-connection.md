# Epic 1: Core Connection Foundation - Backend Integration Guide

## Overview
Tài liệu cung cấp thông tin tích hợp Backend cho các tính năng thuộc Epic 1: Xác thực (Authentication), Thiết lập hồ sơ (Profile Setup), Hợp đồng tình yêu (Love Contract) và Ghép đôi (Partner Pairing). Android App cần tham khảo luồng gọi API và Socket (nếu có) tương tự như iOS App.

---

## 1. Authentication (Firebase JWT)
Hệ thống sử dụng Firebase Authentication. Mobile App cần lấy được `Firebase ID Token` sau khi đăng nhập qua Google, Apple, hoặc Email/Password.
Tất cả các API yêu cầu xác thực đều cần truyền token này qua header.

**Header Format:**
```http
Authorization: Bearer <firebase_id_token>
```

### 1.1. Login (Đăng nhập)
- **Endpoint URL:** `POST /auth/login`
- **Description:** Đăng nhập đối với user đã đăng ký trên hệ thống. Trả về `404 Not Found` nếu user chưa gọi API register trước đó.
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Trả về đối tượng `User` hiện tại từ DB.

### 1.2. Register (Đăng ký)
- **Endpoint URL:** `POST /auth/register`
- **Description:** Đăng ký user mới vào database sau khi đã xác thực Firebase thành công. Cần gọi API này khi Login trả về lỗi 404 (chưa đăng ký).
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Trả về đối tượng `User` mới được tạo.

---

## 2. User Profile Setup (Thiết lập hồ sơ)

### 2.1. Lấy thông tin cá nhân (Get My Profile)
- **Endpoint URL:** `GET /users/me`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Trả về đối tượng `User` kèm theo thông tin của Partner (nếu đã ghép đôi).

### 2.2. Cập nhật hồ sơ (Update Profile)
- **Endpoint URL:** `PATCH /users/me`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:** (Content-Type: application/json)
  ```json
  {
      "displayName": "string (optional)",
      "birthday": "ISO 8601 Date String (optional)",
      "relationshipStartDate": "ISO 8601 Date String (optional)",
      "zodiacSign": "string (optional)",
      "language": "string (optional)",
      "photoUrl": "string (optional)",
      "coupleType": "Enum: 'SAME_CITY' | 'LONG_DISTANCE' | 'LIVING_TOGETHER' | 'DATING' (optional)",
      "isGhostModeEnabled": boolean (optional)
  }
  ```
- **Response:** Trả về đối tượng `User` sau khi đã được cập nhật.

---

## 3. Love Contract Flow (Hợp đồng tình yêu)

### 3.1. Tạo mới hợp đồng (Create Contract)
- **Endpoint URL:** `POST /love-contracts`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "clauses": ["Điều khoản 1", "Điều khoản 2"] // Mảng string, tối đa 20 phần tử
  }
  ```
- **Response:** Trả về đối tượng `LoveContract` vừa được tạo.

### 3.2. Lấy hợp đồng đang chờ (Get Pending Contract)
- **Endpoint URL:** `GET /love-contracts/my-pending`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Trả về hợp đồng đang trong trạng thái chờ ký hoặc chờ phản hồi từ cả hai phía.

### 3.3. Ký hợp đồng (Sign Contract)
- **Endpoint URL:** `PATCH /love-contracts/sign`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Description:** Đánh dấu user hiện tại đã ký vào hợp đồng.
- **Response:** Trả về hợp đồng với trạng thái chữ ký (signature status) đã được cập nhật.

---

## 4. Partner Invitations & Pairing (Ghép đôi & Vow)

### 4.1. Tạo mã mời (Generate Invitation Code)
- **Endpoint URL:** `POST /invitations/generate`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:**
  ```json
  {
      "code": "123456" // Mã mời động sinh ra hệ thống
  }
  ```

### 4.2. Kiểm tra mã mời (Validate Invitation Code)
- **Endpoint URL:** `POST /invitations/validate`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "code": "123456" // Bắt buộc
  }
  ```
- **Description:** Kiểm tra mã mời có hợp lệ không trước khi quyết định chấp nhận ghép đôi.

### 4.3. Chấp nhận ghép đôi (Accept Invitation)
- **Endpoint URL:** `POST /invitations/accept`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "code": "123456" // Bắt buộc
  }
  ```
- **Description:** Hoàn tất quá trình ghép đôi. Sau bước này, user hiện tại sẽ được liên kết với người tạo mã qua `partnerId`/`coupleId` tuỳ cấu trúc DB.

### 4.4. Fingerprint Vow (Xác nhận lời thề sinh trắc học)
- **Endpoint URL:** `POST /users/vow`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Description:** Sau khi cả hai hoàn tất ghép đôi và quét vân tay/khuôn mặt ở thiết bị. Gọi API này để đánh dấu user đã "vow".
