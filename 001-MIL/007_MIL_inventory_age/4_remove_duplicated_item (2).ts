function main(workbook: ExcelScript.Workbook) {
    const CHUNK_SIZE = 1000;

    // === 1. 获取工作表 ===
    const sourceSheet = workbook.getWorksheet("Export (2)");
    const targetSheet = workbook.getWorksheet("Export");
    const inventorySheet = workbook.getWorksheet("MILInventoryAge");

    // === 2. 先读元数据（行列数），循环外只读一次 ===
    const usedRange = sourceSheet.getUsedRange();
    const totalRows: number = usedRange.getRowCount();
    const totalCols: number = usedRange.getColumnCount();

    // === 3. 分批复制 Export(2) → Export ===
    targetSheet.getUsedRange()?.clear(ExcelScript.ClearApplyTo.contents);
    for (let r = 0; r < totalRows; r += CHUNK_SIZE) {
        const rowCount = Math.min(CHUNK_SIZE, totalRows - r);
        // ✅ 用 worksheet.getRangeByIndexes，不是 range.getRangeByIndexes
        const chunk: (string | number | boolean)[][] = sourceSheet
            .getRangeByIndexes(r, 0, rowCount, totalCols)
            .getValues();
        targetSheet
            .getRangeByIndexes(r, 0, rowCount, totalCols)
            .setValues(chunk);
    }
    console.log(`Export(2) → Export 复制完成，共 ${totalRows} 行`);

    // === 4. 获取表格元数据（循环外读取） ===
    const tables = sourceSheet.getTables();
    if (tables.length === 0) throw new Error("No table found in Export (2).");
    const table = tables[0];

    const headerValues: (string | number | boolean)[] = table.getHeaderRowRange().getValues()[0];
    const itemNumberIndex: number = headerValues.indexOf("Item Number");
    if (itemNumberIndex === -1) throw new Error("Column 'Item Number' not found.");

    const tableBody = table.getRangeBetweenHeaderAndTotal();
    const tableRows: number = tableBody.getRowCount();
    const tableCols: number = tableBody.getColumnCount();
    // ✅ 记录表格体起始行（相对于工作表），循环外读取
    const tableBodyStartRow: number = tableBody.getRowIndex();

    // === 5. 分批读取表格数据，去重 ===
    const seen = new Set<string>();
    const uniqueRows: (string | number | boolean)[][] = [];
    const colDIndex = 3;

    for (let r = 0; r < tableRows; r += CHUNK_SIZE) {
        const rowCount = Math.min(CHUNK_SIZE, tableRows - r);
        // ✅ 用 worksheet.getRangeByIndexes，基于工作表坐标
        const chunk: (string | number | boolean)[][] = sourceSheet
            .getRangeByIndexes(tableBodyStartRow + r, 0, rowCount, tableCols)
            .getValues();
        for (const row of chunk) {
            const key: string = (row[itemNumberIndex] ?? "").toString();
            if (key && !seen.has(key)) {
                seen.add(key);
                uniqueRows.push(row);
            }
        }
    }
    console.log(`去重后剩余 ${uniqueRows.length} 行`);

    // === 6. 获取外部表元数据（循环外读取） ===
    const externalTables = inventorySheet.getTables();
    let externalTable: ExcelScript.Table | undefined;
    for (const t of externalTables) {
        const n: string = t.getName().toLowerCase().trim();
        if (n === "table_externaldata_1" || n.indexOf("external") >= 0) {
            externalTable = t;
            break;
        }
    }
    if (!externalTable) throw new Error("Table_ExternalData_1 not found.");

    const extHeaders: (string | number | boolean)[] = externalTable.getHeaderRowRange().getValues()[0];
    const extITNBRIndex: number = extHeaders.indexOf("Inventory_age_days[ITNBR]");
    if (extITNBRIndex === -1) throw new Error("Column 'Inventory_age_days[ITNBR]' not found.");

    const extBody = externalTable.getRangeBetweenHeaderAndTotal();
    const extRows: number = extBody.getRowCount();
    const extCols: number = extBody.getColumnCount();
    // ✅ 记录起始行，循环外读取
    const extBodyStartRow: number = extBody.getRowIndex();
    const validITNBRSet = new Set<string>();

    for (let r = 0; r < extRows; r += CHUNK_SIZE) {
        const rowCount = Math.min(CHUNK_SIZE, extRows - r);
        // ✅ 用 worksheet.getRangeByIndexes
        const chunk: (string | number | boolean)[][] = inventorySheet
            .getRangeByIndexes(extBodyStartRow + r, 0, rowCount, extCols)
            .getValues();
        for (const row of chunk) {
            const val: string = (row[extITNBRIndex] ?? "").toString();
            if (val) validITNBRSet.add(val);
        }
    }
    console.log(`外部表有效 ITNBR 数量: ${validITNBRSet.size}`);

    // === 7. 过滤 ===
    const filtered: (string | number | boolean)[][] = uniqueRows.filter(r => {
        const d = r[colDIndex];
        const item: string = (r[itemNumberIndex] ?? "").toString();
        return !(d === null || d === "") && validITNBRSet.has(item);
    });
    console.log(`过滤后剩余 ${filtered.length} 行`);

    // === 8. 重建表格 ===
    const tblRange = table.getRange();
    const tblStartRow: number = tblRange.getRowIndex();
    const tblStartCol: number = tblRange.getColumnIndex();
    const tblOldRowCount: number = tblRange.getRowCount();
    const tblOldColCount: number = tblRange.getColumnCount();
    const tblWs = table.getWorksheet();

    table.convertToRange();

    const outRows: number = Math.max(1 + filtered.length, 2);
    const outCols: number = headerValues.length;

    // 清空旧区域
    tblWs.getRangeByIndexes(
        tblStartRow, tblStartCol,
        Math.max(tblOldRowCount, outRows),
        Math.max(tblOldColCount, outCols)
    ).clear(ExcelScript.ClearApplyTo.contents);

    // 写表头
    tblWs.getRangeByIndexes(tblStartRow, tblStartCol, 1, outCols)
        .setValues([headerValues]);

    // 分批写数据
    const dataToWrite: (string | number | boolean)[][] = filtered.length > 0
        ? filtered
        : [new Array(outCols).fill("")];

    for (let r = 0; r < dataToWrite.length; r += CHUNK_SIZE) {
        const rowCount = Math.min(CHUNK_SIZE, dataToWrite.length - r);
        const chunk: (string | number | boolean)[][] = dataToWrite.slice(r, r + rowCount);
        tblWs.getRangeByIndexes(tblStartRow + 1 + r, tblStartCol, rowCount, outCols)
            .setValues(chunk);
    }

    // 建表
    const newTableRange = tblWs.getRangeByIndexes(tblStartRow, tblStartCol, outRows, outCols);
    const newTable = tblWs.addTable(newTableRange, true);
    newTable.setName("InvAgeTable");

    // Item Number 列设为文本格式
    const newHeader: (string | number | boolean)[] = newTable.getHeaderRowRange().getValues()[0];
    const newItemIdx: number = newHeader.indexOf("Item Number");
    if (newItemIdx >= 0) {
        newTable.getRangeBetweenHeaderAndTotal()
            .getColumn(newItemIdx)
            .setNumberFormat("@");
    }

    newTable.setShowTotals(false);
    console.log("脚本执行完成 ✅");
}