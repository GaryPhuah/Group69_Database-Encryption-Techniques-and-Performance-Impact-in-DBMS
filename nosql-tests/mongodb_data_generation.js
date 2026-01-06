// TEST 1: (100,000 rows)
use company_db

// Clear Any Previous Records
db.employee_records.drop()

// Generate 100k Insert Loop
var bulk = db.employee_records.initializeUnorderedBulkOp();
for (var i = 0; i < 100000; i++) {
    bulk.insert({
        id_number: "ID-" + i,
        full_name: "Employee_" + i,
        salary: parseFloat((2500 + Math.random() * 5000).toFixed(2)),
        dept_code: "DEPT" + Math.floor(1 + Math.random() * 10)
    });
}
bulk.execute();

print("Created Index on Salary")
db.employee_records.createIndex({ salary: 1 })
print("SETUP COMPLETE")


// TEST 2: (1000000 rows)
use company_db

// Clear Any Previous Records
db.employee_records.drop() 

// Generate 1M Insert Loop
var bulk = db.employee_records.initializeUnorderedBulkOp();
var count = 0;
for (var i = 0; i < 1000000; i++) {
    bulk.insert({
        id_number: "ID-" + i,
        full_name: "Employee_" + i,
        salary: parseFloat((2500 + Math.random() * 5000).toFixed(2)),
        dept_code: "DEPT" + Math.floor(1 + Math.random() * 10)
    });
    count++;
    if (count % 2000 === 0) { 
	bulk.execute(); 
	bulk = db.employee_records.initializeUnorderedBulkOp(); 
    }
}

// Insert leftovers if any
if (count % 2000 !== 0) {
    bulk.execute();
}

print("Created Index on Salary")
db.employee_records.createIndex({ salary: 1 })
print("SETUP COMPLETE")


// TEST 3: (5000000 rows)
use company_db

// Clear Any Previous Records
db.employee_records.drop()

// Generate 5M Insert Loop
var bulk = db.employee_records.initializeUnorderedBulkOp();
var count = 0;

for (var i = 0; i < 5000000; i++) {
    bulk.insert({
        id_number: "ID-" + Math.floor(Math.random() * 1000000),
        full_name: "Employee_" + i,
        salary: parseFloat((2500 + Math.random() * 5000).toFixed(2)),
        dept_code: "DEPT" + Math.floor(1 + Math.random() * 10)
    });
    count++;

    // Execute every 2000 rows
    if (count % 2000 === 0) {
        bulk.execute();
        bulk = db.employee_records.initializeUnorderedBulkOp();
        // Print progress every 500,000 rows
        if (count % 500000 === 0) {
            print("Inserted " + count + " records...");
        }
    }
}

// Insert leftovers if any
if (count % 2000 !== 0) {
    bulk.execute();
}

print("Created Index on Salary")
db.employee_records.createIndex({ salary: 1 })
print("SETUP COMPLETE")
