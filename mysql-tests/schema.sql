-- Create Database
CREATE DATABASE IF NOT EXISTS db_security_test;
USE db_security_test;

-- Create Table
CREATE TABLE IF NOT EXISTS employee_records (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    id_number VARCHAR(20),
    full_name VARCHAR(100),
    salary DECIMAL(10,2),
    dept_code VARCHAR(10)
);
