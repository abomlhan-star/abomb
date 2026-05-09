# 数据备份脚本 - 从现有MySQL导出所有数据
# 使用方法: powershell -ExecutionPolicy Bypass -File backup-data.ps1

$ErrorActionPreference = "Stop"

Write-Host "=== 成研运营系统 - 数据备份脚本 ===" -ForegroundColor Green

# 配置
$backupDir = "docker-data/backups"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$backupDir/chengyan_backup_$timestamp.sql"
$uploadsBackupDir = "$backupDir/uploads_$timestamp"

# MySQL配置（从.env.docker读取）
$dbHost = "localhost"
$dbPort = "3306"
$dbUser = "root"
$dbPassword = "123456"
$dbName = "chengyan_operation"

# 创建备份目录
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Host "创建备份目录: $backupDir" -ForegroundColor Yellow
}

# 1. 备份MySQL数据库
Write-Host "`n=== 步骤1: 备份MySQL数据库 ===" -ForegroundColor Cyan
$mysqldumpPath = "mysqldump"

# 检查mysqldump是否可用
try {
    & $mysqldumpPath --version 2>&1 | Out-Null
} catch {
    Write-Host "错误: 找不到mysqldump命令，请确保已安装MySQL客户端工具" -ForegroundColor Red
    Write-Host "提示: 可以从MySQL官网下载MySQL Shell或使用XAMPP等工具" -ForegroundColor Yellow
    exit 1
}

Write-Host "正在导出数据库: $dbName ..." -ForegroundColor Yellow
$mysqldumpCmd = "$mysqldumpPath -h$dbHost -P$dbPort -u$dbUser -p$dbPassword --databases $dbName --single-transaction --routines --triggers"
Invoke-Expression "$mysqldumpCmd > `"$backupFile`"" 2>&1 | Out-Null

if (Test-Path $backupFile) {
    $fileSize = (Get-Item $backupFile).Length / 1MB
    Write-Host "✓ 数据库备份完成: $backupFile ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "✗ 数据库备份失败" -ForegroundColor Red
    exit 1
}

# 2. 备份上传文件
Write-Host "`n=== 步骤2: 备份上传文件 ===" -ForegroundColor Cyan
$uploadsSource = "server/uploads"

if (Test-Path $uploadsSource) {
    Write-Host "正在复制上传文件..." -ForegroundColor Yellow
    Copy-Item -Path $uploadsSource -Destination $uploadsBackupDir -Recurse -Force
    Write-Host "✓ 上传文件备份完成: $uploadsBackupDir" -ForegroundColor Green
} else {
    Write-Host "⚠ 上传文件目录不存在，跳过备份" -ForegroundColor Yellow
}

# 3. 生成备份清单
$manifest = @"
备份时间: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
数据库备份: $backupFile
上传文件备份: $uploadsBackupDir
MySQL主机: $dbHost:$dbPort
数据库名: $dbName
"@

$manifest | Out-File -FilePath "$backupDir/backup_manifest_$timestamp.txt" -Encoding UTF8

Write-Host "`n=== 备份完成 ===" -ForegroundColor Green
Write-Host "备份位置: $backupDir" -ForegroundColor Yellow
Write-Host "备份文件:" -ForegroundColor Yellow
Write-Host "  - 数据库: $backupFile" -ForegroundColor White
Write-Host "  - 上传文件: $uploadsBackupDir" -ForegroundColor White
Write-Host "  - 清单文件: backup_manifest_$timestamp.txt" -ForegroundColor White
Write-Host "`n下一步: 运行 docker-compose-up.ps1 启动容器化部署" -ForegroundColor Cyan
