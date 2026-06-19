function main(workbook: ExcelScript.Workbook) {
    let sheet = workbook.getWorksheet("NG_DM_Current_Status");

    // 稳妥起见，直接抓取该工作表下的第一个表格
    let table = sheet.getTables()[0];

    if (!table) {
        console.log("未找到表格对象");
        return;
    }

    let rowCount = table.getRowCount();

    // 如果表格中有数据，则执行安全清空
    if (rowCount > 0) {
        // 【关键修复】：使用表格专属的 deleteRowsAt 方法
        // 从第 0 行开始，删除所有行。这只会清空数据，不会破坏工作表网格。
        table.deleteRowsAt(0, rowCount);
    }
}