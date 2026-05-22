function main(workbook: ExcelScript.Workbook) {
    console.log("正在向服务器发送后台数据刷新指令...");

    // 仅保留数据连接刷新，去掉所有透视表刷新和强制重算
    workbook.refreshAllDataConnections();

    console.log("指令发送完毕，脚本结束。实际数据下载将在后台继续进行。");
}