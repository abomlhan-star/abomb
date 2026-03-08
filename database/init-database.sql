-- 成研运营项目管理系统数据库初始化脚本
-- 使用方法: mysql -u root -p < init-database.sql

-- 创建数据库
CREATE DATABASE IF NOT EXISTS chengyan_operation 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 创建用户（可选，建议创建专用数据库用户）
-- CREATE USER 'chengyan'@'localhost' IDENTIFIED BY 'your_password';
-- GRANT ALL PRIVILEGES ON chengyan_operation.* TO 'chengyan'@'localhost';
-- FLUSH PRIVILEGES;

USE chengyan_operation;

-- 提示信息
SELECT 'Database created successfully!' AS message;
SELECT 'Please run migrations using: cd server && npm run migrate' AS next_step;
