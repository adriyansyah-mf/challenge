-- SecureCorp Database Initialization
-- This script sets up the vulnerable database for the challenge

CREATE DATABASE IF NOT EXISTS securecorp;
USE securecorp;

-- Users table with weak security
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,  -- Plain text passwords (vulnerability)
    email VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Insert vulnerable test users
INSERT INTO users (username, password, email, role) VALUES 
('admin', 'admin123', 'admin@securecorp.com', 'admin'),
('john.doe', 'password123', 'john.doe@securecorp.com', 'user'),
('jane.smith', 'qwerty', 'jane.smith@securecorp.com', 'user'),
('test', 'test', 'test@securecorp.com', 'user'),
('guest', '', 'guest@securecorp.com', 'guest'),  -- Empty password
('sa', 'sa', 'sa@securecorp.com', 'admin'),     -- Weak admin account
('backup_user', 'backup123', 'backup@securecorp.com', 'service');

-- Employee information table
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    position VARCHAR(50),
    salary DECIMAL(10,2),           -- Sensitive information
    ssn VARCHAR(11),                -- Highly sensitive data
    phone VARCHAR(20),
    address TEXT,
    emergency_contact VARCHAR(100),
    hire_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert employee data with sensitive information
INSERT INTO employees (user_id, first_name, last_name, department, position, salary, ssn, phone, address, emergency_contact, hire_date) VALUES
(1, 'Admin', 'User', 'IT', 'System Administrator', 85000.00, '123-45-6789', '555-0101', '123 Admin St, Tech City', 'Emergency Admin', '2020-01-15'),
(2, 'John', 'Doe', 'Engineering', 'Software Developer', 75000.00, '987-65-4321', '555-0102', '456 Dev Ave, Code Town', 'Jane Doe', '2021-03-10'),
(3, 'Jane', 'Smith', 'Marketing', 'Marketing Manager', 68000.00, '456-78-9123', '555-0103', '789 Market Blvd, Brand City', 'John Smith', '2021-06-01'),
(4, 'Test', 'User', 'QA', 'QA Tester', 55000.00, '321-54-9876', '555-0104', '321 Test Rd, Bug Valley', 'Test Contact', '2022-01-01');

-- System configuration table (contains sensitive settings)
CREATE TABLE system_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT NOT NULL,
    description TEXT,
    is_sensitive BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert system configuration with secrets
INSERT INTO system_config (config_key, config_value, description, is_sensitive) VALUES
('database_password', 'r00tp@ss123', 'Root database password', TRUE),
('api_secret_key', 'sk-1234567890abcdef', 'API secret key for external services', TRUE),
('encryption_key', 'MyVerySecretEncryptionKey2024!', 'Application encryption key', TRUE),
('aws_access_key', 'AKIAIOSFODNN7EXAMPLE', 'AWS access key', TRUE),
('aws_secret_key', 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY', 'AWS secret key', TRUE),
('smtp_password', 'smtp_secret_2024', 'SMTP server password', TRUE),
('backup_location', '/tmp/backups', 'System backup directory', FALSE),
('debug_mode', 'enabled', 'Debug mode status', FALSE),
('max_upload_size', '10485760', 'Maximum file upload size in bytes', FALSE),
('session_timeout', '3600', 'Session timeout in seconds', FALSE);

-- Audit log table for tracking actions
CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100),
    table_name VARCHAR(50),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- File uploads table
CREATE TABLE file_uploads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    original_filename VARCHAR(255),
    stored_filename VARCHAR(255),
    file_path VARCHAR(500),
    file_size INT,
    mime_type VARCHAR(100),
    upload_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Network monitoring table (for the challenge scenario)
CREATE TABLE network_monitoring (
    id INT AUTO_INCREMENT PRIMARY KEY,
    source_ip VARCHAR(45),
    destination_ip VARCHAR(45),
    port INT,
    protocol VARCHAR(10),
    status VARCHAR(20),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_agent TEXT,
    request_data TEXT
);

-- Insert some sample monitoring data
INSERT INTO network_monitoring (source_ip, destination_ip, port, protocol, status, user_agent, request_data) VALUES
('192.168.1.100', '192.168.1.10', 80, 'HTTP', 'success', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'GET /dashboard.php'),
('192.168.1.101', '192.168.1.10', 22, 'SSH', 'failed', '', 'SSH-2.0-OpenSSH_8.0'),
('10.0.0.1', '192.168.1.10', 443, 'HTTPS', 'success', 'curl/7.68.0', 'GET /api/status'),
('172.16.0.1', '192.168.1.10', 3306, 'MySQL', 'blocked', '', 'mysql_native_password');

-- Create a view for sensitive data (another attack vector)
CREATE VIEW sensitive_employee_data AS
SELECT 
    u.username,
    e.first_name,
    e.last_name,
    e.salary,
    e.ssn,
    e.department
FROM users u
JOIN employees e ON u.id = e.user_id
WHERE u.is_active = TRUE;

-- Grant permissions (overly permissive)
GRANT ALL PRIVILEGES ON securecorp.* TO 'webapp'@'%';
GRANT FILE ON *.* TO 'webapp'@'%';  -- Allows file operations (vulnerability)

-- Create additional database user with elevated privileges (vulnerability)
CREATE USER 'backup_user'@'%' IDENTIFIED BY 'backup123';
GRANT ALL PRIVILEGES ON *.* TO 'backup_user'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;

-- Insert some system logs for the logs viewer
INSERT INTO audit_log (user_id, action, table_name, record_id, ip_address, user_agent) VALUES
(1, 'LOGIN', 'users', 1, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'),
(2, 'FILE_UPLOAD', 'file_uploads', 1, '192.168.1.101', 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36'),
(1, 'CONFIG_VIEW', 'system_config', NULL, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'),
(3, 'LOGIN_FAILED', 'users', 3, '192.168.1.102', 'curl/7.68.0');

-- Comment with additional information for attackers to find
-- TODO: Remove debug user before production deployment
-- Default MySQL root password: r00tp@ss123
-- SSH keys location: /root/.ssh/
-- Backup encryption key: BackupKey2024!
-- Internal API endpoint: http://internal-api:8080/admin
