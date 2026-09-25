-- =====================================================================
-- Database Security & Scalability Benchmark: MySQL Query Benchmarks
-- =====================================================================

USE db_security_test;

-- 1. Verify Record Count
SELECT COUNT(*) AS total_records FROM employee_records;

-- 2. Inspect Initial Physical Storage Footprint
SELECT 
    table_name AS `Table`,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS `Total Size (MB)`,
    ROUND((data_length / 1024 / 1024), 2) AS `Data Size (MB)`,
    ROUND((index_length / 1024 / 1024), 2) AS `Index Size (MB)`
FROM information_schema.TABLES
WHERE table_schema = 'db_security_test' AND table_name = 'employee_records';

-- ---------------------------------------------------------------------
-- Test A: Baseline & TDE Query (Plaintext or Disk-Level Encryption)
-- Note: Flush buffer pool between runs for cold-cache benchmarking:
-- SET GLOBAL innodb_buffer_pool_dump_now = OFF;
-- ---------------------------------------------------------------------
SELECT * 
FROM employee_records 
WHERE salary > 6000;

-- ---------------------------------------------------------------------
-- Test B: Application-Layer (Field-Level) Surgical Encryption
-- Technical Caveat: Wrapping column in decryption causes a non-sargable query,
-- invalidating B-Tree indexes and forcing an O(N) full-table scan on CPU.
-- ---------------------------------------------------------------------
SELECT * 
FROM employee_records
WHERE CAST(
    AES_DECRYPT(
        AES_ENCRYPT(salary, 'my_secret_key'), 
        'my_secret_key'
    ) AS DECIMAL(10,2)
) > 6000;

-- 3. Post-Test Storage Inspection (Verifying Cryptographic Expansion)
SELECT 
    table_name AS `Table`,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS `Post-Test Size (MB)`
FROM information_schema.TABLES
WHERE table_schema = 'db_security_test' AND table_name = 'employee_records';
