# 容器化部署脚本 - 将现有系统迁移到Docker容器
# 使用方法: powershell -ExecutionPolicy Bypass -File docker-deploy.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Green
Write-Host "  成研运营系统 - 容器化部署脚本" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# 检查Docker是否安装
Write-Host "=== 步骤1: 检查Docker环境 ===" -ForegroundColor Cyan
try {
    docker --version | Out-Null
    docker-compose --version | Out-Null
    Write-Host "✓ Docker环境正常" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker未安装或未启动" -ForegroundColor Red
    Write-Host "请安装Docker Desktop并确保正在运行" -ForegroundColor Yellow
    exit 1
}

# 检查现有部署脚本
Write-Host "`n=== 步骤2: 备份现有数据 ===" -ForegroundColor Cyan
if (Test-Path "backup-data.ps1") {
    Write-Host "运行数据备份脚本..." -ForegroundColor Yellow
    & powershell -ExecutionPolicy Bypass -File backup-data.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "警告: 备份脚本执行失败，但继续部署" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ 未找到备份脚本，跳过备份步骤" -ForegroundColor Yellow
}

# 构建前端
Write-Host "`n=== 步骤3: 构建前端 ===" -ForegroundColor Cyan
Write-Host "正在构建Vue前端..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ 前端构建失败" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 前端构建完成" -ForegroundColor Green

# 构建Docker镜像
Write-Host "`n=== 步骤4: 构建Docker镜像 ===" -ForegroundColor Cyan
Write-Host "正在构建Docker镜像..." -ForegroundColor Yellow
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Docker镜像构建失败" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker镜像构建完成" -ForegroundColor Green

# 启动容器
Write-Host "`n=== 步骤5: 启动容器 ===" -ForegroundColor Cyan
Write-Host "正在启动Docker容器..." -ForegroundColor Yellow
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ 容器启动失败" -ForegroundColor Red
    Write-Host "查看详细错误: docker-compose logs" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ 容器启动完成" -ForegroundColor Green

# 等待服务就绪
Write-Host "`n=== 步骤6: 等待服务就绪 ===" -ForegroundColor Cyan
$maxRetries = 60
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ 服务已就绪" -ForegroundColor Green
            break
        }
    } catch {
        # 服务尚未就绪
    }
    
    $retryCount++
    Write-Host "等待服务启动... ($retryCount/$maxRetries)" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

if ($retryCount -eq $maxRetries) {
    Write-Host "⚠ 服务启动超时，但容器已在运行" -ForegroundColor Yellow
}

# 检查容器状态
Write-Host "`n=== 步骤7: 检查容器状态 ===" -ForegroundColor Cyan
docker-compose ps

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  容器化部署完成！" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "服务地址:" -ForegroundColor Cyan
Write-Host "  - 前端: http://localhost:8080" -ForegroundColor White
Write-Host "  - 后端API: http://localhost:3001" -ForegroundColor White
Write-Host "  - MySQL: localhost:3307" -ForegroundColor White

Write-Host "`n常用命令:" -ForegroundColor Cyan
Write-Host "  - 查看日志: docker-compose logs -f" -ForegroundColor White
Write-Host "  - 停止服务: docker-compose down" -ForegroundColor White
Write-Host "  - 重启服务: docker-compose restart" -ForegroundColor White
Write-Host "  - 查看状态: docker-compose ps" -ForegroundColor White

Write-Host "`n下一步:" -ForegroundColor Yellow
Write-Host "  1. 如果需要恢复数据，运行: .\restore-data.ps1" -ForegroundColor White
Write-Host "  2. 更新Nginx配置，将流量转发到 http://localhost:8080" -ForegroundColor White
Write-Host "  3. 测试系统功能是否正常" -ForegroundColor White
