# Epic 6: Administration & Privacy - Backend Integration Guide

## Overview
Tài liệu cung cấp thông tin tích hợp Backend cho phần Quản trị và Quyền riêng tư bao gồm: Xuất dữ liệu cá nhân (Data Export) và Cấu hình Admin. Mặc dù Admin thường dành cho web dashboard, nhưng App hoàn toàn có thể gọi các API này nếu user có quyền (`AdminGuard`).

---

## 1. Data Export (Xuất dữ liệu cá nhân)
Chức năng này cho phép người dùng yêu cầu hệ thống đóng gói toàn bộ dữ liệu của họ (tuân thủ luật User Data Privacy).

### 1.1. Yêu cầu xuất dữ liệu (Request Export)
- **Endpoint URL:** `POST /data-export`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Description:** Gửi yêu cầu async cho backend để bắt đầu gom và nén dữ liệu thành file ZIP.
- **Response:**
  ```json
  {
      "id": "uuid",
      "userId": "uuid",
      "status": "pending", // "pending" | "processing" | "completed" | "failed"
      "createdAt": "ISO date"
  }
  ```

### 1.2. Danh sách các lần xuất dữ liệu (Get Exports)
- **Endpoint URL:** `GET /data-export`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Mảng các yêu cầu xuất dữ liệu và trạng thái hiện tại. (Client có thể polling API này để biết khi nào file `completed` và sẵn sàng tải về).

### 1.3. Tải file dữ liệu (Download Export)
- **Endpoint URL:** `GET /data-export/:id/download`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Description:** Chỉ gọi được khi export request (id) đó đang ở trạng thái `completed`.
- **Response:** Trả về HTTP Stream file `.zip` nén dữ liệu (`Content-Type: application/zip`).

---

## 2. Admin Configurations

Các API dưới đây yêu cầu user truyền token phải thuộc role Admin (`AdminGuard`). Dành cho việc xây dựng Admin Portal (hoặc tích hợp vào 1 phần màn hình ẩn trong App cho Dev/Admin).

### 2.1. Lấy tất cả cấu hình (Get All Configs)
- **Endpoint URL:** `GET /admin/config`
- **Headers:** `Authorization: Bearer <firebase_id_token>` (User must be Admin)
- **Response:** Mảng các records cấu hình (VD: giới hạn spam, cho phép sử dụng Emoji Storm global).

### 2.2. Lấy cấu hình theo key (Get Config)
- **Endpoint URL:** `GET /admin/config/:key`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Value hiện tại của cấu hình.

### 2.3. Cập nhật cấu hình (Update Config)
- **Endpoint URL:** `PATCH /admin/config/:key`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Body Request:**
  ```json
  {
      "value": "new_value", // Tuỳ thuộc kiểu dữ liệu của config key đó
      "description": "optional update reason"
  }
  ```

### 2.4. Metric tổng quan (Get Metrics)
- **Endpoint URL:** `GET /admin/metrics`
- **Headers:** `Authorization: Bearer <firebase_id_token>`
- **Response:** Các chỉ số tổng quan của hệ thống (Số lượng users, active couples, v.v.).
