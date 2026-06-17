function main(workbook: ExcelScript.Workbook) {
    let sheet = workbook.getWorksheet("NG_DM_Current_Status");
    let table = sheet.getTable("Data_Table"); // 此处填写你准备工作中的表格名
    let rowCount = table.getRowCount();
    if (rowCount > 0) {
        // 删除所有数据行，保留表头
        table.getRangeBetweenHeaderAndTotal().delete(ExcelScript.DeleteShiftDirection.up);
    }
}