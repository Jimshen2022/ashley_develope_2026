function main(workbook: ExcelScript.Workbook, records: object[]) {
    let sheet = workbook.getWorksheet("NG_DM_Current_Status");
    let table = sheet.getTable("Data_Table");

    if (!records || records.length === 0) {
        console.log("未接收到数据，跳过写入");
        return;
    }

    // 【核心优化 1】：在写入数据前，强制把 serial_number 和 item_number 列的格式设为“文本” (@)
    // 确保长数字和物料编码不会变形，且能完美保留前导零
    let snCol = table.getColumnByName("serial_number");
    if (snCol) {
        snCol.getRangeBetweenHeaderAndTotal().setNumberFormatLocal("@");
    }

    let itemCol = table.getColumnByName("item_number");
    if (itemCol) {
        itemCol.getRangeBetweenHeaderAndTotal().setNumberFormatLocal("@");
    }

    let rowsData: (string | number | boolean)[][] = [];
    let keys = Object.keys(records[0]);

    for (let i = 0; i < records.length; i++) {
        let row = [];
        for (let key of keys) {
            let val = records[i][key];

            if (val === null || val === undefined) {
                row.push("");
            } else {
                // 【核心优化 2】：清洗 Power BI 的时间字符串
                if (key === "scanned_into_damaged_loc_datetime" || key === "received_date") {
                    if (typeof val === 'string') {
                        val = val.replace("T", " ").replace("Z", "");
                    }
                }
                // 确保 serial_number 和 item_number 传入时被强制转换为纯字符串类型
                else if (key === "serial_number" || key === "item_number") {
                    val = String(val);
                }

                row.push(val as (string | number | boolean));
            }
        }
        rowsData.push(row);
    }

    // 批量追加写入数据
    table.addRows(undefined, rowsData);

    // 【核心优化 3】：在数据写入后，对日期列应用标准的显示格式
    let dtCol = table.getColumnByName("scanned_into_damaged_loc_datetime");
    if (dtCol) {
        dtCol.getRangeBetweenHeaderAndTotal().setNumberFormatLocal("yyyy-mm-dd hh:mm:ss");
    }

    let dateCol = table.getColumnByName("received_date");
    if (dateCol) {
        dateCol.getRangeBetweenHeaderAndTotal().setNumberFormatLocal("yyyy-mm-dd");
    }
}