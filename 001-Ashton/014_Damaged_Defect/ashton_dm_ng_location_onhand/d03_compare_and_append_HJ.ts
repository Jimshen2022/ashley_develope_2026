function main(workbook: ExcelScript.Workbook) {
    let damagedSheet = workbook.getWorksheet("Damaged_Defect");
    let ngSheet = workbook.getWorksheet("NG_DM_Current_Status");

    if (!damagedSheet || !ngSheet) {
        console.log("未找到对应的工作表(Sheet)，请检查底部工作表页签的名称。");
        return;
    }

    let damagedTable = damagedSheet.getTables()[0];
    let ngTable = ngSheet.getTables()[0];

    if (!damagedTable || !ngTable) {
        console.log("在工作表中未找到‘表格’对象！");
        return;
    }

    // =========================================================
    // 🛡️ 【新增防错】：强制清除主表(Damaged_Defect)的所有筛选状态
    // 确保所有隐藏行全部展开，防止回填数据错位或追加数据报错
    let damagedFilter = damagedTable.getAutoFilter();
    if (damagedFilter) {
        damagedFilter.clearCriteria();
    }
    // =========================================================

    // --- 强制刷新文本格式解决科学计数法 ---
    let d_snCol = damagedTable.getColumnByName("Serial Number");
    if (d_snCol) {
        let snRange = d_snCol.getRangeBetweenHeaderAndTotal();
        snRange.setNumberFormatLocal("@");
        let existingVals = snRange.getValues();
        let stringVals = existingVals.map(row => [String(row[0])]);
        snRange.setValues(stringVals);
    }

    let statusColName = "HJCurrentStatus";
    let statusCol = damagedTable.getColumnByName(statusColName);
    if (!statusCol) {
        damagedTable.addColumn(-1, null, statusColName);
        statusCol = damagedTable.getColumnByName(statusColName);
    }

    let d_Data = damagedTable.getRangeBetweenHeaderAndTotal().getValues();
    let n_Data = ngTable.getRangeBetweenHeaderAndTotal().getValues();

    let d_Headers = damagedTable.getHeaderRowRange().getValues()[0].map(h => String(h).trim());
    let n_Headers = ngTable.getHeaderRowRange().getValues()[0].map(h => String(h).trim());

    let d_snIdx = d_Headers.indexOf("Serial Number");
    let d_locIdx = d_Headers.indexOf("Location");
    let n_snIdx = n_Headers.indexOf("serial_number");
    let n_locIdx = n_Headers.indexOf("location_id");

    let ngMap = new Map<string, string>();
    for (let i = 0; i < n_Data.length; i++) {
        let sn = String(n_Data[i][n_snIdx]).trim();
        let loc = String(n_Data[i][n_locIdx]).trim();
        if (sn) {
            ngMap.set(sn, loc);
        }
    }

    let statusUpdates: string[][] = [];
    let d_snSet = new Set<string>();

    for (let i = 0; i < d_Data.length; i++) {
        let sn = String(d_Data[i][d_snIdx]).trim();
        let loc = String(d_Data[i][d_locIdx]).trim();

        if (sn) {
            d_snSet.add(sn);
        }

        if (!sn) {
            statusUpdates.push([""]);
        } else if (ngMap.has(sn)) {
            let ngLoc = ngMap.get(sn);
            if (loc === ngLoc) {
                statusUpdates.push(["= HJ"]);
            } else {
                statusUpdates.push(["Location <> HJ"]);
            }
        } else {
            statusUpdates.push(["Not in HJ Damaged location, please check if it is closed"]);
        }
    }

    statusCol.getRangeBetweenHeaderAndTotal().setValues(statusUpdates);

    let rowsToAppend: (string | number | boolean)[][] = [];
    let d_ColCount = damagedTable.getColumns().length;

    // 追加新记录（包含 DM001AA1 拦截逻辑）
    for (let i = 0; i < n_Data.length; i++) {
        let sn = String(n_Data[i][n_snIdx]).trim();
        let loc = String(n_Data[i][n_locIdx]).trim();

        if (sn && !d_snSet.has(sn) && loc !== "DM001AA1") {
            let newRow: (string | number | boolean)[] = new Array(d_ColCount).fill("");

            for (let j = 0; j < 7; j++) {
                let val = n_Data[i][j];
                if (val !== undefined && val !== null) {
                    if (j === 0 && typeof val === 'string') {
                        val = val.replace("T", " ").replace("Z", "");
                        newRow[j] = val;
                    }
                    else if (j === 1 || j === 4) {
                        newRow[j] = String(val);
                    } else {
                        newRow[j] = val as (string | number | boolean);
                    }
                }
            }
            rowsToAppend.push(newRow);
        }
    }

    if (rowsToAppend.length > 0) {
        damagedTable.addRows(undefined, rowsToAppend);
    }
}