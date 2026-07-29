# Epic 5: Finance (Shared Future) - Backend Integration Guide

## Overview
Tài liệu cung cấp thông tin tích hợp Backend cho phần Tài chính chung bao gồm: Hũ ước mơ (Dream Jar) và Quản lý chi tiêu (Expense Manager).

---

## 1. Dream Jar (Hũ ước mơ)

### 1.1. Lấy danh sách Hũ ước mơ (Get Dream Jars)
- **Endpoint URL:** `GET /dream-jar`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Query Parameters:**
  - `limit` (number, optional, default: 50)
  - `offset` (number, optional, default: 0)
- **Response:** Mảng các đối tượng `DreamJar`. Backend tự động tính toán thuộc tính `progress` (0-100%).
  ```json
  [
    {
      "id": "uuid",
      "coupleId": "uuid",
      "name": "Du lịch Đà Lạt",
      "targetAmount": "15000000.00",
      "currentAmount": "5000000.00",
      "deadline": "ISO date",
      "currency": "VND",
      "status": "active | completed | archived",
      "progress": 33
    }
  ]
  ```

### 1.2. Tạo Hũ ước mơ mới (Create Dream Jar)
- **Endpoint URL:** `POST /dream-jar`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "name": "Tên quỹ",
      "targetAmount": 15000000,
      "deadline": "2024-12-31T00:00:00.000Z (optional)",
      "currency": "VND (optional, default VND)"
  }
  ```
- **Response:** Đối phượng `DreamJar` vừa được tạo.

### 1.3. Cập nhật Hũ ước mơ (Update)
- **Endpoint URL:** `PATCH /dream-jar/:id`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:** Gửi các trường cần update (`name`, `targetAmount`, `deadline`, `status`).

### 1.4. Xoá quỹ (Delete)
- **Endpoint URL:** `DELETE /dream-jar/:id`

---

## 2. Dream Jar Contributions (Đóng góp quỹ)

### 2.1. Đóng góp vào quỹ (Add Contribution)
- **Endpoint URL:** `POST /dream-jar/:id/contributions`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "amount": 500000,
      "note": "Tiền thưởng tháng 5"
  }
  ```
- **Response:** Cập nhật `currentAmount` của Dream Jar và trả về record đóng góp.

### 2.2. Lịch sử đóng góp (Get Contributions)
- **Endpoint URL:** `GET /dream-jar/:id/contributions`
- **Query Parameters:** `limit`, `offset`
- **Response:** Mảng các lịch sử nạp tiền vào quỹ này.

---

## 3. Expense Manager (Quản lý chi tiêu chung)

### 3.1. Thêm khoản chi tiêu (Create Expense)
- **Endpoint URL:** `POST /expenses`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "category": "food", // "food" | "date" | "travel" | "shopping" | "other"
      "amount": 200000,
      "description": "Ăn Haidilao",
      "date": "2024-05-14T00:00:00.000Z" // Không được là ngày tương lai
  }
  ```
- **Response:** Đối phượng `Expense` vừa tạo.

### 3.2. Lịch sử chi tiêu (Get Expenses)
- **Endpoint URL:** `GET /expenses`
- **Query Parameters:** `limit`, `offset`
- **Response:** Danh sách các khoản chi tiêu.

### 3.3. Xoá khoản chi tiêu (Delete Expense)
- **Endpoint URL:** `DELETE /expenses/:id`

### 3.4. Báo cáo chi tiêu (Expense Report)
- **Endpoint URL:** `GET /expenses/report`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Query Parameters:** `period` ("week" hoặc "month", mặc định là "month")
- **Response:** Object thống kê tổng số tiền và phân rã theo category.
  ```json
  {
      "total": 5000000,
      "byCategory": {
          "food": 2000000,
          "date": 1500000,
          "travel": 0,
          "shopping": 1000000,
          "other": 500000
      }
  }
  ```
