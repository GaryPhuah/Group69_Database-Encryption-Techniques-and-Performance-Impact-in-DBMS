//Baseline Query

var explainResult = db.employee_records.find({ 
    salary: { $gt: 6000 } 
}).explain("executionStats")

var timeTaken = explainResult.executionStats.executionTimeMillis
var docsFound = explainResult.executionStats.nReturned

print("RESULT")
print("Documents Found: " + docsFound)
print("Execution Time:  " + timeTaken + " ms")