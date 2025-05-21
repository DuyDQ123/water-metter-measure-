USE test;

-- Bảng người dùng
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    access_code VARCHAR(50) NOT NULL,
    user_type ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Thêm dữ liệu mẫu cho người dùng
INSERT INTO users (name, access_code, user_type) VALUES 
('User 1', '123456', 'user'),
('User 2', '234567', 'user'),
('Admin', 'admin123', 'admin');
