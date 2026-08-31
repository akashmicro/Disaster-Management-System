USE disaster_management_db;

ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(150) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified TINYINT(1) NOT NULL DEFAULT 1;

CREATE TABLE IF NOT EXISTS otp_verifications (
    otp_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    otp_code VARCHAR(255) NOT NULL,
    purpose ENUM('ACCOUNT_VERIFICATION','PASSWORD_RESET') NOT NULL,
    expires_at DATETIME NOT NULL,
    is_used TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_otp_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_otp_lookup (user_id, purpose, is_used)
);
