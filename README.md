
# 

# 

# 

# This repository contains a comparative study of \*\*MySQL\*\* and \*\*MongoDB\*\* performance. It focuses on data generation at scale (up to 5M records) and the performance implications of field-level encryption.

# 

# 

# 

# 

# 

# 

# 

# \## 📌 Project Objectives

# 

# \- \*\*Scalability:\*\* Compare storage footprint of 5 million records.

# 

# \- \*\*Performance:\*\* Benchmark query speeds for range-based filtering.

# 

# \- \*\*Security:\*\* Evaluate the overhead of "Surgical Encryption" (AES) on sensitive fields.

# 

# 

# 

# ---

# 

# 

# 

# \## 🛠️ Tech Stack

# 

# \- \*\*RDBMS:\*\* MySQL 8.0 (Relational)

# 

# \- \*\*NoSQL:\*\* MongoDB 7.0 (Document-based)

# 

# \- \*\*Environment:\*\* Node.js / Mongosh

# 

# \- \*\*Security:\*\* AES-256 Bit Encryption

# 

# 

# 

# ---

# 

# 

# 

# \## 📂 Repository Structure

# 

# ```text

# 

# ├── mysql-tests/

# 

# │   └── benchmark.sql      # Stored procedures \& encryption tests

# 

# ├── mongodb-tests/

# 

# │   └── benchmark.js       # Data generation \& indexing scripts

# 

# └── README.md              # Project documentation

# 

# 

# 

# 

# 



