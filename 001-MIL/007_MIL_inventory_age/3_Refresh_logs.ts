function main(workbook: ExcelScript.Workbook) {
    // 用 full 而不是 fullRebuild，速度更快
    workbook.getApplication().calculate(ExcelScript.CalculationType.full);

    const ts = new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' });
    const ctrl = workbook.getWorksheet("Control") ?? workbook.addWorksheet("Control");
    ctrl.getRange("A1").setValue(`最后刷新: ${ts}`);
    ctrl.getRange("A2").setValue("刷新状态: 完成");
    console.log("计算完成");
}