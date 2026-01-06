// APP-LAYER

use company_db

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