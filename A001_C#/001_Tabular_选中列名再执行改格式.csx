// 1. 遍历你在左侧树状图中手动选中的所有度量值
foreach(var m in Selected.Measures)
{
    // 2. 设置格式字符串
    // #,0.0 表示：强制保留一位小数，且显示千分位分隔符
    m.FormatString = "#,0.0";
    
    // 3. (可选) 在描述中记录一下修改时间，方便追踪
    m.Description = "Format updated to 1 decimal place on " + DateTime.Now.ToString("yyyy-MM-dd");
}

// 4. 运行完成后在左下角状态栏提示
Info("已成功将 " + Selected.Measures.Count() + " 个度量值的格式修改为保留一位小数。");