// 1. Locate the specific table "A_Measure"
var targetTable = Model.Tables.FirstOrDefault(t => t.Name == "A_Measure");

// 2. Safety check: ensure the table exists
if (targetTable == null) {
    Error("Cannot find table: A_Measure. Please check the table name.");
    return;
}

// Variable to keep track of how many measures were updated
int updatedCount = 0;

// 3. Loop through ALL measures inside "A_Measure" only
foreach(var m in targetTable.Measures)
{
// 4. Check if the trimmed measure name ends with "PPH"
    if (m.Name.Trim().EndsWith("PPH"))
    {
        // 5. Update the format string to 1 decimal place with a thousand separator
        m.FormatString = "#,0.0";
        
        // Increment the counter
        updatedCount++;
    }
}

// 6. Show a completion message with the total count
Info("Successfully updated the format for " + updatedCount + " 'PPH' measures in A_Measure.");