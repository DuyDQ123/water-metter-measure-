# IoT Monitoring System

## Cài đặt Database

1. Mở phpMyAdmin: http://localhost/phpmyadmin
2. Tạo database 'test' nếu chưa có
3. Import file create_tables.sql để tạo cấu trúc database và dữ liệu mẫu

## Tài khoản mẫu

- Người dùng:
  - User 1: 123456
  - User 2: 234567
- Quản trị: admin123

## API Endpoints

- POST `/iotdigi-main/post.php`:
  - validate_code: Xác thực mã truy cập
  - get_bills: Lấy danh sách hóa đơn
  - update_bill_status: Cập nhật trạng thái hóa đơn
  - capture_photo: Chụp ảnh
  - update_sensor: Cập nhật dữ liệu cảm biến

- GET `/iotdigi-main/get.php`:
  - Lấy dữ liệu cảm biến mới nhất
  - Lấy thông tin sử dụng nước và hóa đơn
