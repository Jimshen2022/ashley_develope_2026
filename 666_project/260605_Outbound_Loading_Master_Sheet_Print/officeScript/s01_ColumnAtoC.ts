function main(workbook: ExcelScript.Workbook) {
    // 1. 获取工作表
    const detailSheet = workbook.getWorksheet("Detail");
    const infoSheet = workbook.getWorksheet("ashton_trip_item_info");

    if (!detailSheet || !infoSheet) {
        console.log("错误: 未找到 'Detail' 或 'ashton_trip_item_info' 工作表，请检查工作表名称。");
        return;
    }

    // 2. 获取使用区域的数据
    const detailRange = detailSheet.getUsedRange();
    const detailValues = detailRange.getValues();

    const infoRange = infoSheet.getUsedRange();
    const infoValues = infoRange.getValues();

    if (detailValues.length <= 1 || infoValues.length <= 1) {
        console.log("工作表数据为空或只有表头。");
        return;
    }

    // 3. 动态获取列索引
    const detailHeaders = detailValues[0].map(h => String(h).trim());
    const colSTT = detailHeaders.indexOf("STT");
    const colDate = detailHeaders.indexOf("Schedule Date");
    const colGoods = detailHeaders.indexOf("Goods");
    const colTrip = detailHeaders.indexOf("Trip#/Order#");

    const infoHeaders = infoValues[0].map(h => String(h).trim());
    const colInfoTripNbr = infoHeaders.indexOf("trip_nbr");
    const colInfoContainerType = infoHeaders.indexOf("container_type");

    if (colSTT === -1 || colDate === -1 || colGoods === -1 || colTrip === -1 || colInfoTripNbr === -1 || colInfoContainerType === -1) {
        console.log("错误: 缺少必需的列，请检查表头名称。");
        return;
    }

    // 4. 构建字典 (Map)
    const tripMap = new Map<string, string>();
    for (let i = 1; i < infoValues.length; i++) {
        const tripNbr = String(infoValues[i][colInfoTripNbr]).trim();
        const containerType = String(infoValues[i][colInfoContainerType]).trim();
        if (tripNbr !== "") {
            tripMap.set(tripNbr, containerType);
        }
    }

    // 5. 【关键修改】生成 Excel 易于识别为标准日期的格式 (YYYY-MM-DD)
    const today = new Date();
    const yyyy = today.getFullYear();
    const mm = String(today.getMonth() + 1).padStart(2, '0');
    const dd = String(today.getDate()).padStart(2, '0');
    const todayStandardStr = `${yyyy}-${mm}-${dd}`;

    let lastSTT = 0;

    // 【关键修改】
    // Trip#/Order# 继续保持文本格式以防丢失前导零
    detailRange.getColumn(colTrip).setNumberFormat("@");

    // Schedule Date 设置为真正的 Excel 原生日期格式，并强制使用英文月份显示 (dd-mmm-yyyy)
    detailRange.getColumn(colDate).setNumberFormat("[$-en-US]dd-mmm-yyyy;@");

    // 6. 遍历数据
    for (let i = 1; i < detailValues.length; i++) {
        const row = detailValues[i];

        const tripVal = (row[colTrip] !== undefined && row[colTrip] !== null) ? String(row[colTrip]).trim() : "";
        detailValues[i][colTrip] = tripVal;

        const sttVal = (row[colSTT] !== undefined && row[colSTT] !== null) ? String(row[colSTT]).trim() : "";
        const dateVal = (row[colDate] !== undefined && row[colDate] !== null) ? String(row[colDate]).trim() : "";
        const goodsVal = (row[colGoods] !== undefined && row[colGoods] !== null) ? String(row[colGoods]).trim() : "";

        if (sttVal !== "" && !isNaN(Number(sttVal))) {
            lastSTT = Number(sttVal);
        }

        if (tripVal !== "" && sttVal === "" && dateVal === "" && goodsVal === "") {

            lastSTT += 1;
            detailValues[i][colSTT] = lastSTT;

            // 填入标准日期，Excel 会自动将其识别为日期对象，并应用上方设置好的英文格式
            detailValues[i][colDate] = todayStandardStr;

            if (tripMap.has(tripVal)) {
                detailValues[i][colGoods] = tripMap.get(tripVal);
            }
        }
    }

    // 7. 写回数据
    detailRange.setValues(detailValues);
    console.log("脚本执行完毕：Schedule Date 已经是真正的日期类型，且正确显示为 18-May-2026 格式！");
}