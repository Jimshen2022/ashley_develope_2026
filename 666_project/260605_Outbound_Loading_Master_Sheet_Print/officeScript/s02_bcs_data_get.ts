function main(workbook: ExcelScript.Workbook) {
    // 1. 获取工作表
    const detailSheet = workbook.getWorksheet("Detail");
    const bcsSheet = workbook.getWorksheet("ashton_bcs_info");

    if (!detailSheet || !bcsSheet) {
        console.log("错误: 未找到 'Detail' 或 'ashton_bcs_info' 工作表，请检查工作表名称。");
        return;
    }

    // 2. 获取使用区域的数据 (在内存中处理以提升性能)
    const detailRange = detailSheet.getUsedRange();
    const detailValues = detailRange.getValues();

    const bcsRange = bcsSheet.getUsedRange();
    const bcsValues = bcsRange.getValues();

    if (detailValues.length <= 1 || bcsValues.length <= 1) {
        console.log("工作表数据为空或只有表头。");
        return;
    }

    // 3. 动态获取 Detail 表的列索引
    const detailHeaders = detailValues[0].map(h => String(h).trim());
    const colTrip = detailHeaders.indexOf("Trip#/Order#");
    const colBooking = detailHeaders.indexOf("Booking");
    const colContainers = detailHeaders.indexOf("Containers");
    const colSeal = detailHeaders.indexOf("Seal#");

    // 动态获取 ashton_bcs_info 表的列索引
    const bcsHeaders = bcsValues[0].map(h => String(h).trim());
    const colBcsTripNbr = bcsHeaders.indexOf("trip_nbr");
    const colBcsBooking = bcsHeaders.indexOf("BokBookingNumber");
    const colBcsContainer = bcsHeaders.indexOf("ContainerNumber");
    const colBcsSeal = bcsHeaders.indexOf("BoksealNo");

    // 校验必须的列是否存在
    if (colTrip === -1 || colBooking === -1 || colContainers === -1 || colSeal === -1) {
        console.log("错误: 在 Detail 表中未找到必需的列 [Trip#/Order#, Booking, Containers, Seal#]");
        return;
    }
    if (colBcsTripNbr === -1 || colBcsBooking === -1 || colBcsContainer === -1 || colBcsSeal === -1) {
        console.log("错误: 在 ashton_bcs_info 表中未找到必需的列 [trip_nbr, BokBookingNumber, ContainerNumber, BoksealNo]");
        return;
    }

    // 4. 构建快速查找字典 (Map)
    const bcsMap = new Map<string, { booking: string, container: string, seal: string }>();
    for (let i = 1; i < bcsValues.length; i++) {
        const tripNbr = String(bcsValues[i][colBcsTripNbr]).trim();
        const bookingVal = String(bcsValues[i][colBcsBooking]).trim();
        const containerVal = String(bcsValues[i][colBcsContainer]).trim();
        const sealVal = String(bcsValues[i][colBcsSeal]).trim();

        if (tripNbr !== "") {
            bcsMap.set(tripNbr, {
                booking: bookingVal,
                container: containerVal,
                seal: sealVal
            });
        }
    }

    // 5. 将 Detail 表中的目标列设置为文本格式 ("@")，防止数字前导零丢失
    detailRange.getColumn(colBooking).setNumberFormat("@");
    detailRange.getColumn(colContainers).setNumberFormat("@");
    detailRange.getColumn(colSeal).setNumberFormat("@");

    // 6. 遍历 Detail 表格进行条件匹配和内存更新
    for (let i = 1; i < detailValues.length; i++) {
        const row = detailValues[i];
        const tripVal = (row[colTrip] !== undefined && row[colTrip] !== null) ? String(row[colTrip]).trim() : "";

        // 当 Trip#/Order# 不为空，且在 bcs 字典中找到了对应的数据时
        if (tripVal !== "" && bcsMap.has(tripVal)) {
            const matchData = bcsMap.get(tripVal);

            // 【关键更新】读取 Detail 表当前行现有的值，并去除首尾空格
            const currentBooking = (row[colBooking] !== undefined && row[colBooking] !== null) ? String(row[colBooking]).trim() : "";
            const currentContainers = (row[colContainers] !== undefined && row[colContainers] !== null) ? String(row[colContainers]).trim() : "";
            const currentSeal = (row[colSeal] !== undefined && row[colSeal] !== null) ? String(row[colSeal]).trim() : "";

            // 条件判断：只有当 Detail 表中对应单元格为空白时，才用匹配到的新值覆盖
            if (currentBooking === "") {
                detailValues[i][colBooking] = matchData.booking;
            }
            if (currentContainers === "") {
                detailValues[i][colContainers] = matchData.container;
            }
            if (currentSeal === "") {
                detailValues[i][colSeal] = matchData.seal;
            }
        }
    }

    // 7. 将更新后的数据二维数组一次性写回 Detail 工作表
    detailRange.setValues(detailValues);
    console.log("脚本执行完毕：已成功运行！原有非空数据已被完整保留，仅更新了空白单元格。");
}