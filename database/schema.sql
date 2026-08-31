CREATE DATABASE IF NOT EXISTS disaster_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE disaster_management;

CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  username VARCHAR(80) NOT NULL UNIQUE,
  email VARCHAR(160) NOT NULL UNIQUE,
  phone VARCHAR(30) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','user') NOT NULL DEFAULT 'user',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS password_otps (
  otp_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  otp_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_password_otp (user_id, used_at, expires_at)
);
CREATE TABLE IF NOT EXISTS disasters (
  disaster_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  disaster_type VARCHAR(80) NOT NULL,
  district VARCHAR(80) NOT NULL,
  status ENUM('Reported','Under Assessment','Active Response','Resolved') NOT NULL DEFAULT 'Reported',
  severity ENUM('Low','Medium','High','Critical') NOT NULL DEFAULT 'Medium',
  description TEXT NOT NULL,
  reported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS victims (
  victim_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  age INT NOT NULL,
  gender VARCHAR(20) NOT NULL,
  condition_status VARCHAR(40) NOT NULL,
  rescue_status VARCHAR(40) NOT NULL DEFAULT 'Not Rescued',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS rescue_teams (
  team_id INT AUTO_INCREMENT PRIMARY KEY,
  team_name VARCHAR(120) NOT NULL,
  team_type VARCHAR(80) NOT NULL,
  leader_name VARCHAR(120) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  district VARCHAR(80) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Available'
);
CREATE TABLE IF NOT EXISTS missing_persons (
  missing_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  age INT NOT NULL,
  last_seen_location VARCHAR(160) NOT NULL,
  district VARCHAR(80) NOT NULL,
  missing_date DATE NOT NULL,
  contact_phone VARCHAR(30) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Missing'
);
CREATE TABLE IF NOT EXISTS shelters (
  shelter_id INT AUTO_INCREMENT PRIMARY KEY,
  shelter_name VARCHAR(160) NOT NULL,
  district VARCHAR(80) NOT NULL,
  location VARCHAR(160) NOT NULL,
  total_capacity INT NOT NULL,
  occupied_capacity INT NOT NULL DEFAULT 0,
  contact_phone VARCHAR(30) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Open'
);
CREATE TABLE IF NOT EXISTS blood_donors (
  donor_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  blood_group VARCHAR(5) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  district VARCHAR(80) NOT NULL,
  is_available TINYINT(1) NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS relief_inventory (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  item_name VARCHAR(120) NOT NULL,
  category VARCHAR(80) NOT NULL,
  quantity DECIMAL(12,2) NOT NULL,
  unit VARCHAR(30) NOT NULL,
  district VARCHAR(80) NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS vehicles (
  vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
  vehicle_number VARCHAR(50) NOT NULL,
  vehicle_type VARCHAR(60) NOT NULL,
  organization VARCHAR(120) NOT NULL,
  district VARCHAR(80) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Available'
);
CREATE TABLE IF NOT EXISTS missions (
  mission_id INT AUTO_INCREMENT PRIMARY KEY,
  mission_name VARCHAR(160) NOT NULL,
  disaster_id INT NULL,
  team_id INT NULL,
  vehicle_id INT NULL,
  district VARCHAR(80) NOT NULL,
  start_date DATE NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Planned',
  FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE SET NULL,
  FOREIGN KEY (team_id) REFERENCES rescue_teams(team_id) ON DELETE SET NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS emergency_contacts (
  contact_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(30) NOT NULL UNIQUE,
  category VARCHAR(60) NOT NULL,
  district VARCHAR(80) NOT NULL,
  description VARCHAR(255) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Active'
);
CREATE TABLE IF NOT EXISTS ambulances (
  ambulance_id INT AUTO_INCREMENT PRIMARY KEY,
  ambulance_number VARCHAR(50) NOT NULL UNIQUE,
  organization VARCHAR(120) NOT NULL,
  driver_name VARCHAR(120) NOT NULL,
  driver_phone VARCHAR(30) NOT NULL,
  district VARCHAR(80) NOT NULL,
  location VARCHAR(160) NOT NULL,
  emergency_phone VARCHAR(30) NOT NULL,
  status ENUM('Available','On Mission','Busy','Maintenance','Offline') NOT NULL DEFAULT 'Available'
);
CREATE TABLE IF NOT EXISTS hospitals (
  hospital_id INT AUTO_INCREMENT PRIMARY KEY,
  hospital_name VARCHAR(160) NOT NULL,
  hospital_type VARCHAR(80) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  emergency_phone VARCHAR(30) NOT NULL,
  district VARCHAR(80) NOT NULL,
  location VARCHAR(160) NOT NULL,
  address VARCHAR(255) NOT NULL,
  available_beds INT NOT NULL DEFAULT 0,
  emergency_available TINYINT(1) NOT NULL DEFAULT 1,
  status VARCHAR(30) NOT NULL DEFAULT 'Open'
);
CREATE TABLE IF NOT EXISTS donations (
  donation_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  donor_name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  donation_type ENUM('Money','Material') NOT NULL,
  amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  purpose VARCHAR(160) NOT NULL,
  item_name VARCHAR(160) NOT NULL DEFAULT '',
  category VARCHAR(80) NOT NULL DEFAULT '',
  quantity DECIMAL(12,2) NOT NULL DEFAULT 0,
  unit VARCHAR(30) NOT NULL DEFAULT '',
  disaster VARCHAR(160) NOT NULL,
  donation_date DATE NOT NULL,
  payment_method VARCHAR(50) NOT NULL DEFAULT '',
  transaction_reference VARCHAR(120) NOT NULL DEFAULT '',
  remarks TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS health_ai_chats (
  chat_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);
