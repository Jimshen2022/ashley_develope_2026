function main(workbook: ExcelScript.Workbook) {
    // === 1. 获取需要的工作表 ===
    const sourceSheet = workbook.getWorksheet("Export (2)"); // 数据源表
    const targetSheet = workbook.getWorksheet("Export");     // 要复制到的目标表
    const inventorySheet = workbook.getWorksheet("MILInventoryAge"); // 外部库存表

    // === 2. 从 Export (2) 复制完整数据到 Export ===
    const lastCell = sourceSheet.getUsedRange().getLastCell();   // 找到最后一个非空单元格
    const lastRow = lastCell.getRowIndex();                      // 行号
    const lastCol = lastCell.getColumnIndex();                   // 列号
    const copyRange = sourceSheet.getRangeByIndexes(0, 0, lastRow + 1, lastCol + 1); // 定义复制范围
    const values = copyRange.getValues();                        // 获取源表的数据值

    targetSheet.getUsedRange()?.clear(ExcelScript.ClearApplyTo.contents); // 清空目标表原内容
    targetSheet.getRangeByIndexes(0, 0, values.length, values[0].length).setValues(values); // 粘贴数据

    // === 3. 获取 Export (2) 中的表格对象 ===
    const tables = sourceSheet.getTables();
    if (tables.length === 0) throw new Error("No table found in Export (2).");
    const table = tables[0]; // 默认取第一个表

    const headerValues = table.getHeaderRowRange().getValues()[0]; // 表头行
    const dataValues = table.getRangeBetweenHeaderAndTotal().getValues(); // 数据区

    // === 4. 查找 Item Number 列索引 ===
    const itemNumberIndex = headerValues.indexOf("Item Number");
    if (itemNumberIndex === -1) throw new Error("Column 'Item Number' not found.");

    // === 5. 去重：按 Item Number 保留首次出现的行 ===
    const seen = new Set<string>();
    const uniqueRows: (string | number | boolean)[][] = [];
    for (const row of dataValues) {
        const key = (row[itemNumberIndex] ?? "").toString(); // 当前行的 Item Number
        if (!seen.has(key)) {
            seen.add(key);
            uniqueRows.push(row); // 首次出现才加入结果
        }
    }

    // === 6. 获取 MILInventoryAge 表中的 Table_ExternalData_1 ===
    const externalTables = inventorySheet.getTables();
    let externalTable: ExcelScript.Table | null = null;

    // 先精确匹配表名
    for (const t of externalTables) {
        if (t.getName() === "Table_ExternalData_1") { externalTable = t; break; }
    }
    // 如果找不到，做宽松匹配
    if (!externalTable) {
        for (const t of externalTables) {
            const n = (t.getName() || "").toString().toLowerCase().trim();
            if (n === "table_externaldata_1" || n.indexOf("external") >= 0) {
                externalTable = t;
                break;
            }
        }
    }
    if (!externalTable) throw new Error("Table_ExternalData_1 not found in 'MILInventoryAge'.");

    // === 7. 找到 ITNBR 列（Inventory_age_days[ITNBR]）并提取所有有效值 ===
    const extHeaders = externalTable.getHeaderRowRange().getValues()[0];
    const extITNBRIndex = extHeaders.indexOf("Inventory_age_days[ITNBR]");
    if (extITNBRIndex === -1) throw new Error("Column 'Inventory_age_days[ITNBR]' not found.");

    const extData = externalTable.getRangeBetweenHeaderAndTotal().getValues();
    const validITNBRSet = new Set<string>(
        extData.map(r => (r[extITNBRIndex] ?? "").toString()).filter(s => s !== "")
    );

    // === 8. 过滤：剔除 D 列为空，且 ITNBR 不在外部表的行 ===
    const colDIndex = 3; // D列
    const filtered = uniqueRows.filter(r => {
        const d = r[colDIndex]; // D列值
        const item = (r[itemNumberIndex] ?? "").toString(); // Item Number
        const dNotEmpty = !(d === null || d === ""); // D列必须有值
        const inITNBR = validITNBRSet.has(item);     // Item Number 必须存在于外部表
        return dNotEmpty && inITNBR;
    });

    // === 9. 重建表格：避免逐行 deleteRowsAt 引发错误 ===
    const tblWs = table.getWorksheet();     // 表格所在工作表
    const tblRange = table.getRange();      // 原表格区域
    const topLeft = tblRange.getCell(0, 0); // 左上角单元格（表头位置）

    table.convertToRange(); // 把原表转换为普通区域，便于覆盖写入

    const outRows = Math.max(1 + filtered.length, 2); // 最少留表头+1行
    const outCols = headerValues.length;

    // 清空原表区域，避免残留
    const bigClear = topLeft.getResizedRange(
        Math.max(tblRange.getRowCount(), outRows) - 1,
        Math.max(tblRange.getColumnCount(), outCols) - 1
    );
    bigClear.clear(ExcelScript.ClearApplyTo.contents);

    // 写入表头
    const headerTarget = topLeft.getResizedRange(0, outCols - 1);
    headerTarget.setValues([headerValues]);

    // 写入数据（若没有，则写入一行空数据，避免建表失败）
    const bodyTarget = topLeft.getOffsetRange(1, 0).getResizedRange(Math.max(filtered.length, 1) - 1, outCols - 1);
    if (filtered.length > 0) {
        bodyTarget.setValues(filtered);
    } else {
        bodyTarget.setValues([new Array(outCols).fill("")]);
    }

    // 新建表格，范围包括表头+数据
    const newTableRange = topLeft.getResizedRange(outRows - 1, outCols - 1);
    const newTable = tblWs.addTable(newTableRange, true);
    newTable.setName("InvAgeTable");   // ✅ 在这里改名

    // === 10. 设置 Item Number 列为文本格式（避免前导0丢失） ===
    const newHeader = newTable.getHeaderRowRange().getValues()[0];
    const newItemIdx = newHeader.indexOf("Item Number");
    if (newItemIdx >= 0) {
        const bodyRange = newTable.getRangeBetweenHeaderAndTotal(); // 获取数据区
        bodyRange.getColumn(newItemIdx).setNumberFormat("@");       // 设置文本格式
    }

    // 不显示总计行
    newTable.setShowTotals(false);
}
