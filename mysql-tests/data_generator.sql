-- =====================================================================
-- Database Security & Scalability Benchmark: MySQL Data Generator
-- Target Table: employee_records (Scales: 100K, 1M, 5M rows)
-- =====================================================================

USE db_security_test;

DROP PROCEDURE IF EXISTS GenerateEmployeeData;
DROP PROCEDURE IF EXISTS GenerateEmployeeDataBatch;

DELIMITER //

-- Standard Stored Procedure (Row-by-Row insertion)
CREATE PROCEDURE GenerateEmployeeData(IN total_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    
    WHILE i < total_rows DO
        INSERT INTO employee_records (id_number, full_name, salary, dept_code)
        VALUES (
            CONCAT('ID-', LPAD(FLOOR(RAND() * 1000000), 6, '0')),
            CONCAT('Employee_', i),
            ROUND(2500 + (RAND() * 5000), 2),
            CONCAT('DEPT', FLOOR(1 + (RAND() * 10)))
        );
        SET i = i + 1;
    END WHILE;
END //

-- High-Speed Transactional Batch Generator (Recommended for 1M & 5M tiers)
CREATE PROCEDURE GenerateEmployeeDataBatch(IN total_rows INT, IN batch_size INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE b INT DEFAULT 0;
    
    SET autocommit = 0;
    
    WHILE i < total_rows DO
        START TRANSACTION;
        SET b = 0;
        
        WHILE b < batch_size AND i < total_rows DO
            INSERT INTO employee_records (id_number, full_name, salary, dept_code)
            VALUES (
                CONCAT('ID-', LPAD(FLOOR(RAND() * 1000000), 6, '0')),
                CONCAT('Employee_', i),
                ROUND(2500 + (RAND() * 5000), 2),
                CONCAT('DEPT', FLOOR(1 + (RAND() * 10)))
            );
            SET i = i + 1;
            SET b = b + 1;
        END WHILE;
        
        COMMIT;
    END WHILE;
    
    SET autocommit = 1;
END //

DELIMITER ;
