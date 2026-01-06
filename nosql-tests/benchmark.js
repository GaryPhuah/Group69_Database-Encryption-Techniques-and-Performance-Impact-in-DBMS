// Baseline Test

var explainResult = db.employee_records.find({ 
    salary: { $gt: 6000 } 
}).explain("executionStats")

var timeTaken = explainResult.executionStats.executionTimeMillis
var docsFound = explainResult.executionStats.nReturned

print("RESULT")
print("Documents Found: " + docsFound)

print("Execution Time:  " + timeTaken + " ms")


// App-layer Test

var explainResult = db.employee_records.find({ 
    $where: function() { 
        // We simulate 'decryption' overhead by parsing the salary 
        return (parseFloat(this.salary) > 6000) 
    } 
}).explain("executionStats")

var timeTaken = explainResult.executionStats.executionTimeMillis
var docsFound = explainResult.executionStats.nReturned

print("APP-LAYER RESULT")
print("Documents Found: " + docsFound)
print("Execution Time:  " + timeTaken + " ms")
