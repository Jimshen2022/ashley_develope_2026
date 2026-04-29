# Power BI PBIX 到 PBIP 批量转换工具 - PowerShell 版本
# 使用: .\Convert-PowerBIFiles.ps1

param(
    [string]$SourceDir = "D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI",
    [string]$TargetDir = "D:\GitHub\power_bi_develop_2026\US_PBIP",
    [switch]$Verbose = $false
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "INFO" { Write-Host $logMessage -ForegroundColor Cyan }
        default { Write-Host $logMessage }
    }
}

function Get-PowerBIDesktopPath {
    <#
    .SYNOPSIS
    查找 Power BI Desktop 的安装路径
    #>
    
    $possiblePaths = @(
        "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
        "C:\Program Files (x86)\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    return $null
}

function Get-PBIXFiles {
    <#
    .SYNOPSIS
    获取源目录中的所有 .pbix 文件
    #>
    param(
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        Write-Log "源目录不存在: $Path" "ERROR"
        return $null
    }
    
    $files = Get-ChildItem -Path $Path -Filter "*.pbix" -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0) {
        Write-Log "未找到 .pbix 文件" "WARNING"
        return $null
    }
    
    Write-Log "找到 $($files.Count) 个 Power BI 文件" "SUCCESS"
    
    foreach ($file in $files) {
        Write-Host "  - $($file.Name)" -ForegroundColor Gray
    }
    
    return $files
}

function New-DirectoryStructure {
    <#
    .SYNOPSIS
    创建目标目录结构
    #>
    param(
        [string]$TargetDir,
        [System.Object[]]$Files
    )
    
    # 创建基础目录
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        Write-Log "创建基础目录: $TargetDir" "SUCCESS"
    }
    
    # 为每个文件创建文件夹
    foreach ($file in $Files) {
        $folderName = $file.BaseName
        $folderPath = Join-Path $TargetDir $folderName
        
        if (-not (Test-Path $folderPath)) {
            New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
            Write-Log "创建文件夹: $folderName" "SUCCESS"
        }
    }
}

function Open-PowerBIFile {
    <#
    .SYNOPSIS
    打开 Power BI 文件并等待用户转换
    #>
    param(
        [string]$FilePath,
        [string]$PBIDesktopPath,
        [string]$TargetFolder
    )
    
    Write-Log "处理: $(Split-Path $FilePath -Leaf)" "INFO"
    Write-Log "目标目录: $TargetFolder" "INFO"
    
    # 启动 Power BI Desktop
    try {
        Start-Process -FilePath $PBIDesktopPath -ArgumentList $FilePath -PassThru | Out-Null
        Write-Log "已打开 Power BI Desktop" "SUCCESS"
    }
    catch {
        Write-Log "打开 Power BI 失败: $_" "ERROR"
        return $false
    }
    
    # 显示操作指南
    Write-Host "`n" + "="*70
    Write-Host "请在 Power BI Desktop 中执行以下步骤:" -ForegroundColor Yellow
    Write-Host "="*70
    Write-Host "1. 点击 '文件' -> '另存为'" -ForegroundColor Gray
    Write-Host "2. 选择文件类型: 'Power BI 项目文件 (*.pbip)'" -ForegroundColor Gray
    Write-Host "3. 文件名会自动填充: $(Split-Path $FilePath -Leaf).pbip" -ForegroundColor Gray
    Write-Host "4. 保存位置: $TargetFolder" -ForegroundColor Gray
    Write-Host "5. 完成保存后，关闭 Power BI" -ForegroundColor Gray
    Write-Host "="*70
    Write-Host "⏳ 按任意键继续到下一个文件..." -ForegroundColor Cyan
    Write-Host ""
    
    # 等待用户
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # 检查转换结果
    $expectedPbipFile = Join-Path $TargetFolder "$(Split-Path $FilePath -Leaf | % {$_ -replace '\.pbix$', '.pbip'})"
    
    if (Test-Path $expectedPbipFile) {
        Write-Log "转换成功: $(Split-Path $expectedPbipFile -Leaf)" "SUCCESS"
        return $true
    }
    else {
        Write-Log "未检测到转换文件，请手动检查: $expectedPbipFile" "WARNING"
        return $false
    }
}

function Main {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          Power BI PBIX 批量转换 PBIP 工具 (PowerShell)             ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # 检查 Power BI Desktop
    Write-Log "检查 Power BI Desktop..." "INFO"
    $pbiPath = Get-PowerBIDesktopPath
    
    if (-not $pbiPath) {
        Write-Log "未找到 Power BI Desktop，请确保已安装" "ERROR"
        return $false
    }
    
    Write-Log "找到 Power BI Desktop: $pbiPath" "SUCCESS"
    Write-Host ""
    
    # 获取 PBIX 文件
    Write-Log "扫描源目录..." "INFO"
    $pbixFiles = Get-PBIXFiles -Path $SourceDir
    
    if (-not $pbixFiles) {
        return $false
    }
    
    Write-Host ""
    
    # 创建目录结构
    Write-Log "创建目录结构..." "INFO"
    New-DirectoryStructure -TargetDir $TargetDir -Files $pbixFiles
    Write-Host ""
    
    # 逐个转换
    $successCount = 0
    $totalCount = $pbixFiles.Count
    
    for ($i = 0; $i -lt $totalCount; $i++) {
        $file = $pbixFiles[$i]
        $targetFolder = Join-Path $TargetDir $file.BaseName
        
        Write-Host ""
        Write-Host "[$($i+1)/$totalCount]" -ForegroundColor Magenta
        
        if (Open-PowerBIFile -FilePath $file.FullName -PBIDesktopPath $pbiPath -TargetFolder $targetFolder) {
            $successCount++
        }
    }
    
    # 显示结果
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                         处理完成!                                  ║" -ForegroundColor Green
    Write-Host "║  成功转换: $successCount/$totalCount 个文件                              ║" -ForegroundColor Green
    Write-Host "║  目标目录: $TargetDir" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    # 询问是否打开目录
    $response = Read-Host "是否打开目标目录? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Invoke-Item $TargetDir
    }
    
    return $true
}

# 执行主程序
Main
