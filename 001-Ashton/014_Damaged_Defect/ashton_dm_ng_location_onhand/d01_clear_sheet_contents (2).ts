function main(workbook: ExcelScript.Workbook) {
    // 直接通过全局表名精确获取，无视它在哪个工作表、排在第几个
    let table = workbook.getTable("Data_Table");

    if (!table) {
        console.log("未找到名为 'Data_Table' 的表格，请确认表设计中的名称。");
        return;
    }

    let rowCount = table.getRowCount();

    // 如果表格中有数据，则执行安全清空
    if (rowCount > 0) {
        // 【完美组合】：精确表名 + 专属的数据行删除方法
        // 这只会清空 Data_Table 里的数据，绝对不会影响工作簿里的任何其他表格
        table.deleteRowsAt(0, rowCount);
    }
}