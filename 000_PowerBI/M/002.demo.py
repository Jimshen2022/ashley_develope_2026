import pandas as pd

   #"Added Conditional Column" = Table.AddColumn(#"Renamed Columns", "Reason Code", each if [return_dispostion] = "10" then "[10] Overcubed; Uncontrollable" else if [return_dispostion] = "11" then "[11] Cubed OK - No Room; Controllable" else if [return_dispostion] = "12" then "[12] Product Late; Uncontrollable" else if [return_dispostion] = "13" then "[13] Inventory Problem; Controllable" else if [return_dispostion] = "17" then "[17] Cubed Wrong; Controllable" else if [return_dispostion] = "18" then "[18] Product is on Hold; Uncontrollable" else if [return_dispostion] = "19" then "[19] No Loading Dock at Customer; Controllable" else if [return_dispostion] = "21" then "[21] Customer Changed Order; Uncontrollable" else if [return_dispostion] = "23" then "[23] Express Address Error; Uncontrollable" else if [return_dispostion] = "25" then "[25] Unable to Ship Complete Set/Order; Controllable" else if [return_dispostion] = "34" then "[34] Too Much Fill Sent to Traffic; Controllable" else if [return_dispostion] = "37" then "[37] Not Enough Pcs to Ship; Controllable" else if [return_dispostion] = "39" then "[39] In Yard Not Unloaded; Controllable" else if [return_dispostion] = "45" then "[45] Product Damaged in Warehouse; Controllable" else if [return_dispostion] = "47" then "[47] Items on Trailer Prior to Load; Uncontrollable" else if [return_dispostion] = "52" then "[52] Homestore Cancelled; Uncontrollable" else if [return_dispostion] = "53" then "[53] Odds & Ends Cancelled; Uncontrollable" else if [return_dispostion] = "56" then "[56] Pulled Per Kingswere; Uncontrollable" else if [return_dispostion] = "57" then "[57] Samples on Truck; Uncontrollable" else if [return_dispostion] = "58" then "[58] Reefer Trailer; Uncontrollable" else if [return_dispostion] = "77" then "[77] Closed Short by Traffic; Controllable" else if [return_dispostion] = "78" then "[78] In Offsite Storage Facility; Controllable" else if [return_dispostion] = "60" then "[60] Ecomm Mass Backorder; Controllable" else if [return_dispostion] = "61" then "[61] MDRDC Late; Controllable" else if [return_dispostion] = null then "[n] No Reason Recorded" else "Unknown Return Code"),
# Define the mapping as a list of dictionaries
data = [
    {"Category": "Uncontrollable", "Code": "10", "Description": "[10] Overcubed; Uncontrollable"},
    {"Category": "Controllable", "Code": "11", "Description": "[11] Cubed OK - No Room; Controllable"},
    {"Category": "Uncontrollable", "Code": "12", "Description": "[12] Product Late; Uncontrollable"},
    {"Category": "Controllable", "Code": "13", "Description": "[13] Inventory Problem; Controllable"},
    {"Category": "Controllable", "Code": "17", "Description": "[17] Cubed Wrong; Controllable"},
    {"Category": "Uncontrollable", "Code": "18", "Description": "[18] Product is on Hold; Uncontrollable"},
    {"Category": "Controllable", "Code": "19", "Description": "[19] No Loading Dock at Customer; Controllable"},
    {"Category": "Uncontrollable", "Code": "21", "Description": "[21] Customer Changed Order; Uncontrollable"},
    {"Category": "Uncontrollable", "Code": "23", "Description": "[23] Express Address Error; Uncontrollable"},
    {"Category": "Controllable", "Code": "25", "Description": "[25] Unable to Ship Complete Set/Order; Controllable"},
    {"Category": "Controllable", "Code": "34", "Description": "[34] Too Much Fill Sent to Traffic; Controllable"},
    {"Category": "Controllable", "Code": "37", "Description": "[37] Not Enough Pcs to Ship; Controllable"},
    {"Category": "Controllable", "Code": "39", "Description": "[39] In Yard Not Unloaded; Controllable"},
    {"Category": "Controllable", "Code": "45", "Description": "[45] Product Damaged in Warehouse; Controllable"},
    {"Category": "Uncontrollable", "Code": "47", "Description": "[47] Items on Trailer Prior to Load; Uncontrollable"},
    {"Category": "Uncontrollable", "Code": "52", "Description": "[52] Homestore Cancelled; Uncontrollable"},
    {"Category": "Uncontrollable", "Code": "53", "Description": "[53] Odds & Ends Cancelled; Uncontrollable"},
    {"Category": "Uncontrollable", "Code": "56", "Description": "[56] Pulled Per Kingswere; Uncontrollable"},
    {"Category": "Uncontrollable", "Code": "57", "Description": "[57] Samples on Truck; Uncontrollable"},
    {"Category": "Uncontrollable", "Code": "58", "Description": "[58] Reefer Trailer; Uncontrollable"},
    {"Category": "Controllable", "Code": "77", "Description": "[77] Closed Short by Traffic; Controllable"},
    {"Category": "Controllable", "Code": "78", "Description": "[78] In Offsite Storage Facility; Controllable"},
    {"Category": "Controllable", "Code": "60", "Description": "[60] Ecomm Mass Backorder; Controllable"},
    {"Category": "Controllable", "Code": "61", "Description": "[61] MDRDC Late; Controllable"},
    {"Category": "Uncontrollable", "Code": "n", "Description": "[n] No Reason Recorded"},
]

# Create a DataFrame
df = pd.DataFrame(data)

# Export to Excel
output_file = "reason_codes.xlsx"
df.to_excel(output_file, index=False, header=["Category", "Controllable_Code", "Code_Description"])
print(f"Data exported to {output_file}")