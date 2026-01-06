USE db_security_test;

-- Baseline test
SELECT COUNT(*) AS total_records FROM employee_records;

-- Simple range query (salary > 6000)
SELECT * FROM employee_records WHERE salary > 6000 LIMIT 10;

-- Check storage size
SELECT ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_MB
FROM information_schema.TABLES
WHERE table_name = "employee_records";

-- Transparent Data Encryption (TDE) simulation query
SELECT * FROM employee_records WHERE salary > 6000 LIMIT 10;

-- Field-level AES Encryption Test
SELECT *
FROM employee_records
WHERE CAST(
    AES_DECRYPT(AES_ENCRYPT(salary, 'my_secret_key'), 'my_secret_key') AS DECIMAL(10,2)
) > 6000
LIMIT 10;

-- Storage size after encryption
SELECT ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_MB
FROM information_schema.TABLES
WHERE table_name = "employee_records";
