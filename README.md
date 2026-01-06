#  Database Security & Scalability Benchmark  
## MySQL vs MongoDB (5 Million Records + Field-Level Encryption)

## Overview
This project presents a **comparative benchmarking study** between **MySQL (Relational Database)** and **MongoDB (NoSQL Document Database)**, focusing on:

- **Scalability** at large data volumes (up to **5 million records**)
- **Query performance** for range-based filtering
- **Security overhead** introduced by **field-level AES-256 encryption**

The benchmark simulates **real-world enterprise scenarios** where sensitive attributes (such as salary or personal data) must be encrypted while still supporting analytical queries.

---

## Project Objectives

###  Scalability
- Compare storage footprint for **5 million records**
- Measure bulk insert performance

### Performance
- Benchmark range-based queries on indexed fields
- Measure query latency with and without encryption

### Security
- Evaluate overhead of **surgical (field-level) encryption**
- Compare encrypted read performance across databases

---

## 🛠️ Technology Stack

| Category | Technology |
|-------|-----------|
| Relational DB | MySQL 8.0 |
| NoSQL DB | MongoDB 7.0 |
| Scripting | SQL, JavaScript |
| Runtime | Node.js / Mongosh |
| Encryption | AES-256 |
| Platform | Windows / Linux / macOS |

---

## Benchmark Methodology

### Dataset
- **Total Records:** 5,000,000
- **Fields:**
  - `id`
  - `name`
  - `age`
  - `salary` (AES-256 encrypted)
  - `created_at`

### Queries Tested
- Range queries on non-encrypted fields
- Equality queries on encrypted fields
- Aggregation queries (`COUNT`, `AVG`)

### Indexing Strategy
- **MySQL:** BTREE indexes
- **MongoDB:** Single-field indexes

### Encryption Strategy
- AES-256
- Field-level encryption only
- Encryption applied during insert (server-side)

---

## Repository Structure
```text
database-security-scalability-benchmark/
├── mysql-tests/
│   ├── data_generator.sql
│   └── benchmark.sql
├── mongodb-tests/
│   ├── data_generator.js
│   └── benchmark.js
├── docs/
│   ├── query-latency.png
│   └── storage-comparison.png
└── README.md
```
## Sample Benchmark Results (5M Records)

## 📊 Sample Benchmark Results (5M Records)

| Test Case | MySQL (No Encryption) | MySQL (TDE) | MySQL (Field-Level AES) | MongoDB (No Encryption) | MongoDB (FLE) |
|---------|----------------------|------------|-------------------------|-------------------------|---------------|
| Insert Throughput | High | Medium | Low | Very High | High |
| Range Query (Non-Encrypted) | Fast | Slightly Slower | Slower | Fastest | Slightly Slower |
| Encrypted Field Query | N/A | Medium Latency | Higher Latency | N/A | Lower Latency |
| Storage Footprint | Small | Slightly Larger | Larger | Large | Larger |
| Encryption Scope | None | Full Database | Selected Fields | None | Selected Fields |
| Schema Flexibility | Low | Low | Low | High | High |

*Results may vary depending on system configuration, hardware resources, and database tuning.*


