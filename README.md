<div align="center">

# Group 69 Database Encryption Techniques and Performance Impact in DBMS
### MySQL vs. MongoDB Across 5 Million Records

[![MySQL](https://img.shields.io/badge/MySQL-8.0-00758F?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0%2B-47A248?style=flat-square&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Encryption](https://img.shields.io/badge/Cipher-AES--256-critical?style=flat-square)](https://csrc.nist.gov/publications/detail/fips/197/final)
[![Hardware](https://img.shields.io/badge/Acceleration-AES--NI-blue?style=flat-square)](https://en.wikipedia.org/wiki/AES_instruction_set)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-lightgrey?style=flat-square)](#)

A benchmark measuring query latency, execution time, and disk usage when encrypting data in MySQL 8.0 and MongoDB. Tests compare transparent data encryption (TDE) against field-level AES-256 on datasets up to 5,000,000 records.

[Overview](#overview) • [Key findings](#key-findings) • [Benchmark results](#benchmark-results) • [Architecture](#architecture) • [Getting started](#getting-started) • [Performance analysis](#performance-analysis) • [Recommendations](#recommendations)

</div>

## Overview

Regulations like GDPR, HIPAA, and PDPA require protecting sensitive database records at rest. Encrypting data prevents cleartext leaks from stolen drives or backups, but it changes how databases process queries and store pages.

This repository tests how encryption affects performance in MySQL 8.0 (InnoDB) and MongoDB (WiredTiger) across three dataset sizes: 100,000 rows, 1,000,000 rows, and 5,000,000 rows.

The tests evaluate four specific areas:
- Storage-engine encryption (TDE) with hardware AES-NI instructions.
- Application-layer (field-level) encryption and its effect on query sargability.
- Server-side document evaluation using MongoDB's JavaScript engine.
- Disk usage changes when high-entropy ciphertext bypasses page compression.

## Key findings

- Hardware offloading keeps TDE latency close to baseline. At 5,000,000 rows, MySQL TDE ran in 1,687 ms compared to 1,609 ms for unencrypted tables, an increase of 4.8%. The AMD Ryzen processor handles AES rounds directly in hardware registers as data moves between disk and memory.
- Decrypting columns inside query filters forces a full table scan. Calling `AES_DECRYPT` inside a MySQL `WHERE` clause increased 5M row latency to 10,047 ms. Because the column value is wrapped in a function, MySQL cannot use the B-tree index and must decrypt every row one by one.
- MongoDB document evaluation through JavaScript adds significant delay. Filtering encrypted fields in MongoDB with the `$where` operator took 57,716 ms at 5M records. Passing documents into the JavaScript runtime creates repeated context switches that slow down query execution.
- Encrypted data increases disk usage by about 15%. Because AES ciphertext is pseudo-random, page-level compression in InnoDB cannot find repeating byte patterns.

## Benchmark results

All benchmarks evaluate an analytical range query (`salary > 6000`) executed across five consecutive runs with cold caches (buffer pools cleared between runs) to measure raw I/O and cryptographic throughput.

### 1. Query latency matrix

| Scale Tier | Row Count | Dataset Vol. | MySQL Baseline | MySQL TDE (Disk-Level) | MySQL App-Layer (Field AES) | MongoDB Baseline | MongoDB App-Layer (`$where`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Small** | 100,000 | ~55 MB | 31 ms | 35 ms | 250 ms | 54 ms | 1,246 ms |
| **Mid** | 1,000,000 | ~500 MB | 250 ms | 281 ms | 2,000 ms | 650 ms | 12,600 ms |
| **Enterprise** | 5,000,000 | ~2.1 GB | **1,609 ms** | **1,687 ms** | **10,047 ms** | **3,858 ms** | **57,716 ms** |

> [!NOTE]
> Native storage-engine encryption for MongoDB requires MongoDB Enterprise Advanced. Community Edition MongoDB was evaluated under Baseline and simulated Field-Level workloads.

### 2. Storage footprint comparison

| Database Engine | Scale Tier | Record Count | Baseline Footprint | Encrypted Footprint | Storage Overhead |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **MySQL (InnoDB)** | Small | 100K | 6.52 MB | 6.52 MB (TDE) / 7.50 MB (App) | +15.0% |
| **MySQL (InnoDB)** | Mid | 1M | 62.59 MB | 62.59 MB (TDE) / 71.98 MB (App) | +15.0% |
| **MySQL (InnoDB)** | Enterprise | 5M | 315.81 MB | 315.81 MB (TDE) / 363.18 MB (App) | +15.0% |
| **MongoDB (WiredTiger)** | Enterprise | 5M | 106.39 MB | 106.39 MB (Compressed BSON) | -- |

```text
Query Latency Scaling Behavior (5M Records)
═════════════════════════════════════════════════════════════════════════════
MySQL Baseline           [1.6s]  █▎
MySQL TDE (AES-NI)       [1.7s]  █▎
MongoDB Baseline         [3.9s]  ███▍
MySQL App-Layer (AES)    [10.0s] █████████
MongoDB App-Layer ($where) [57.7s] ██████████████████████████████████████████
═════════════════════════════════════════════════════════════════════════════
```

## Architecture

The benchmark simulates an enterprise human resource and payroll system containing sensitive employee attributes (`id_number`, `full_name`, `salary`, `dept_code`).

```text
                                  ┌────────────────────────────────┐
                                  │      Client Query Request      │
                                  └───────────────┬────────────────┘
                                                  │
                 ┌────────────────────────────────┴────────────────────────────────┐
                 ▼                                                                 ▼
   ┌───────────────────────────┐                                     ┌───────────────────────────┐
   │    Relational (MySQL)     │                                     │      NoSQL (MongoDB)      │
   └─────────────┬─────────────┘                                     └─────────────┬─────────────┘
                 │                                                                 │
        ┌────────┴────────┐                                               ┌────────┴────────┐
        ▼                 ▼                                               ▼                 ▼
 ┌─────────────┐   ┌─────────────┐                                 ┌─────────────┐   ┌─────────────┐
 │ Baseline /  │   │  App-Layer  │                                 │ Baseline    │   │  App-Layer  │
 │ TDE (AES-NI)│   │ (AES_DECRYPT│                                 │ (Indexed)   │   │  ($where JS │
 └──────┬──────┘   └──────┬──────┘                                 └──────┬──────┘   │  Engine)    │
        │                 │                                               │          └──────┬──────┘
        ▼                 ▼                                               ▼                 ▼
 ┌─────────────┐   ┌─────────────┐                                 ┌─────────────┐   ┌─────────────┐
 │ Storage I/O │   │ O(N) Table  │                                 │ WiredTiger  │   │ 5M Context  │
 │  Page Read  │   │ Scan on CPU │                                 │ BSON Cache  │   │   Switches  │
 └─────────────┘   └─────────────┘                                 └─────────────┘   └─────────────┘
```

### Hardware & environment specifications

- **Processor:** AMD Ryzen 7 7735HS (8 Cores, 16 Threads, up to 4.75 GHz)
- **Instruction Extensions:** Hardware AES-NI & AMD-V virtualization
- **Memory:** 16 GB DDR5 4800 MHz
- **Storage:** PCIe 4.0 NVMe M.2 Solid State Drive
- **Operating Environment:** Windows 11 Enterprise (Clean configuration, background tasks silenced)
- **Database Versions:** MySQL Community Server 8.0.35, MongoDB Community Server 7.0 / 8.0

## Repository structure

```text
.
├── mysql-tests/
│   ├── schema.sql              # Database creation and table definitions
│   ├── data_generator.sql      # Stored procedures for single and high-speed batch generation
│   └── benchmark.sql           # Query execution scripts for Baseline, TDE, and App-Layer tests
├── nosql-tests/
│   ├── data_generation.js      # MongoDB bulk-write generation script for 100K-5M documents
│   ├── benchmark.js            # Mongo shell explain("executionStats") performance runners
│   └── *.png                   # CLI benchmark execution artifacts and terminal outputs
├── docs/
│   ├── query-latency.png       # Consolidated query latency comparative matrix
│   └── storage-comparison.png  # Physical storage footprint analysis
└── README.md
```

## Getting started

### Prerequisites

Ensure the following runtimes and tools are installed locally:

- [MySQL Server 8.0+](https://dev.mysql.com/downloads/mysql/) with MySQL CLI or MySQL Workbench
- [MongoDB Community Server 7.0+](https://www.mongodb.com/try/download/community)
- [mongosh (MongoDB Shell)](https://www.mongodb.com/try/download/shell)

### Step 1: MySQL benchmark execution

#### 1. Initialize database schema
```bash
mysql -u root -p < mysql-tests/schema.sql
```

#### 2. Load data generator & populate records
```bash
mysql -u root -p db_security_test < mysql-tests/data_generator.sql
```

Connect to your MySQL client and trigger the generation tier:
```sql
USE db_security_test;

-- Tier 1: Small (100,000 rows)
CALL GenerateEmployeeDataBatch(100000, 5000);

-- Tier 2: Mid (1,000,000 rows)
CALL GenerateEmployeeDataBatch(1000000, 10000);

-- Tier 3: Enterprise (5,000,000 rows)
CALL GenerateEmployeeDataBatch(5000000, 20000);
```

#### 3. Run benchmark queries
```bash
mysql -u root -p db_security_test < mysql-tests/benchmark.sql
```

> [!TIP]
> To reproduce cold-cache reads and prevent InnoDB buffer pool caching from skewing query latency, flush buffers between runs:
> ```sql
> SET GLOBAL innodb_buffer_pool_dump_now = OFF;
> ```

### Step 2: MongoDB benchmark execution

#### 1. Generate document batches
Launch `mongosh` and execute the data generator:
```javascript
mongosh "mongodb://localhost:27017"

// Executes insertion loops (configured for 100K, 1M, or 5M in script)
load("nosql-tests/data_generation.js");
```

#### 2. Run query execution analysis
```javascript
// Analyzes baseline vs. simulated field-level evaluation
load("nosql-tests/benchmark.js");
```

The script outputs `executionStats` detailing total index keys examined, total documents examined, and overall `executionTimeMillis`.

## Performance analysis

### 1. Hardware acceleration with AES-NI
When MySQL runs with InnoDB tablespace encryption (TDE), cryptographic work happens underneath the query layer. Data pages are decrypted in silicon as they move from the NVMe drive to the buffer pool. Because the processor executes AES rounds in dedicated registers, query times grow at nearly the same rate as plaintext tables (+78 ms at 5M rows).

### 2. The non-sargable query problem
In the application-layer test, the salary column is encrypted before storage. Filtering records with `WHERE salary > 6000` requires decrypting values during query execution:

```sql
WHERE CAST(AES_DECRYPT(AES_ENCRYPT(salary, 'key'), 'key') AS DECIMAL(10,2)) > 6000
```

> [!WARNING]
> Wrapping a column in a scalar function makes the query non-sargable. MySQL cannot look up values in the B-tree index, so it scans all 5,000,000 rows and decrypts each record in memory.

### 3. JavaScript context switching in MongoDB
MongoDB stores records as BSON documents. When queries use regular indexed fields (`{ salary: { $gt: 6000 } }`), the WiredTiger engine searches B-tree indexes directly in C++.

Evaluating unindexed field-level logic requires `$where`:

```javascript
$where: function() {
    return (parseFloat(this.salary) > 6000);
}
```

For every document in the collection, MongoDB passes data from the storage engine into the JavaScript runtime. Across 5,000,000 documents, these context switches and type conversions accumulate to a 57.7-second response time.

### 4. Storage entropy and compression
Ciphertext has high Shannon entropy, meaning bytes are distributed without predictable patterns. Compression algorithms like LZ4 and zlib in InnoDB and WiredTiger rely on repeating sequences. Because encryption removes those patterns, database files expand by about 15%, increasing physical disk requirements and backup sizes.

## Recommendations

1. Use storage-level TDE for high-traffic workloads. If your threat model focuses on physical disk theft, lost media, or exposed backups, hardware-accelerated TDE protects data with less than 5% overhead.
2. Avoid decrypting columns inside filter conditions. If you need field-level encryption to hide values from database administrators, store a deterministic HMAC hash in a separate indexed column. That lets you run exact-match queries without decrypting every row.
3. Plan for a 15% increase in storage capacity. Encrypted databases lose most dictionary compression benefits, which increases disk usage and I/O traffic.
