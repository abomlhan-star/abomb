# 数据恢复脚本 - 将备份数据恢复到容器化MySQL
# 使用方法: powershell -ExecutionPolicy Bypass -File restore-data.ps1 [备份文件路径]

param(
    [string]$BackupFile = ""
)

$ErrorActionPreference = "Stop"

Write-Host "=== 成研运营系统 - 数据恢复脚本 ===" -ForegroundColor Green

# 如果没有指定备份文件，查找最新的备份
if ([string]::IsNullOrWhiteSpace($BackupFile)) {
    $backupDir = "docker-data/backups"
    if (Test-Path $backupDir) {
        $latestBackup = Get-ChildItem -Path "$backupDir\*.sql" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latestBackup) {
            $BackupFile = $latestBackup.FullName
            Write-Host "使用最新备份: $BackupFile" -ForegroundColor Yellow
        } else {
            Write-Host "错误: 未找到备份文件" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "错误: 备份目录不存在: $backupDir" -ForegroundColor Red
        exit 1
    }
}

if (!(Test-Path $BackupFile)) {
    Write-Host "错误: 备份文件不存在: $BackupFile" -ForegroundColor Red
    exit 1
}

Write-Host "备份文件: $BackupFile" -ForegroundColor Yellow

# 等待MySQL容器就绪
Write-Host "`n=== 等待MySQL容器就绪 ===" -ForegroundColor Cyan
$maxRetries = 30
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        $result = docker exec chengyan-mysql mysqladmin ping -h localhost -u root -p123456 2>&1
        if ($result -match "mysqld is alive") {
            Write-Host "✓ MySQL容器已就绪" -ForegroundColor Green
            break
        }
    } catch {
        # 继续等待
    }
    
    $retryCount++
    Write-Host "等待MySQL启动... ($retryCount/$maxRetries)" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

if ($retryCount -eq $maxRetries) {
    Write-Host "错误: MySQL容器启动超时" -ForegroundColor Red
    exit 1
}

# 导入数据库
Write-Host "`n=== 导入数据库 ===" -ForegroundColor Cyan
Write-Host "正在导入数据..." -ForegroundColor Yellow

$dockerCmd = "docker exec -i chengyan-mysql mysql -u root -p123456 chengyan_operation < `"$BackupFile`""
Invoke-Expression $dockerCmd 2>&1 | Out-Null

Write-Host "✓ 数据库导入完成" -ForegroundColor Green

# 恢复上传文件
Write-Host "`n=== 恢复上传文件 ===" -ForegroundColor Cyan
$uploadsDir = [System.IO.Path]::GetDirectoryName($BackupFile)
$uploadsBackup = Get-ChildItem -Path $uploadsDir -Directory -Filter "uploads_*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($uploadsBackup) {
    Write-Host "正在恢复上传文件..." -ForegroundColor Yellow
    
    # 获取容器内的uploads卷挂载点
    docker exec chengyan-api mkdir -p /app/uploads 2>&1 | Out-Null
    
    # 复制文件到容器
    docker cp $uploadsBackup.FullName chengyan-api:/app/uploads/ 2>&1 | Out-Null
    
    Write-Host "✓ 上传文件恢复完成" -ForegroundColor Green
} else {
    Write-Host "⚠ 未找到上传文件备份，跳过恢复" -ForegroundColor Yellow
}

Write-Host "`n=== 数据恢复完成 ===" -ForegroundColor Green
Write-Host "请刷新浏览器验证数据" -ForegroundColor Cyan
