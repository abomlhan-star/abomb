#########################################################################
# 成研运营项目管理系统 - 本地构建和上传脚本
# 在本地 Windows 电脑上运行
#########################################################################

param(
    [string]$ServerIP = "",
    [string]$ServerUser = "root",
    [string]$ServerPassword = "",
    [string]$ProjectDir = "/var/www/chengyan-operation"
)

# 颜色函数
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Log-Info {
    Write-ColorOutput Cyan "[INFO] $args"
}

function Log-Success {
    Write-ColorOutput Green "[SUCCESS] $args"
}

function Log-Error {
    Write-ColorOutput Red "[ERROR] $args"
}

function Log-Warning {
    Write-ColorOutput Yellow "[WARNING] $args"
}

# 开始
Clear-Host
Write-ColorOutput Green "========================================"
Write-ColorOutput Green "   成研运营项目 - 本地构建和上传"
Write-ColorOutput Green "========================================"
Write-Output ""

# 获取服务器信息
if ([string]::IsNullOrEmpty($ServerIP)) {
    $ServerIP = Read-Host "请输入服务器 IP 地址"
}

if ([string]::IsNullOrEmpty($ServerPassword)) {
    $ServerPassword = Read-Host "请输入服务器密码" -AsSecureString
    $ServerPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ServerPassword)
    )
}

# 步骤 1: 检查项目
Log-Info "步骤 1/5: 检查项目文件..."
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

if (-not (Test-Path "package.json")) {
    Log-Error "未找到 package.json，请在项目根目录运行"
    exit 1
}
Log-Success "项目检查通过"

# 步骤 2: 安装依赖
Log-Info "步骤 2/5: 安装前端依赖..."
if (-not (Test-Path "node_modules")) {
    npm install
    if ($LASTEXITCODE -ne 0) {
        Log-Error "前端依赖安装失败"
        exit 1
    }
} else {
    Log-Warning "node_modules 已存在，跳过安装"
}

Log-Info "安装后端依赖..."
if (-not (Test-Path "server\node_modules")) {
    Set-Location server
    npm install
    Set-Location ..
    if ($LASTEXITCODE -ne 0) {
        Log-Error "后端依赖安装失败"
        exit 1
    }
} else {
    Log-Warning "server\node_modules 已存在，跳过安装"
}

# 步骤 3: 构建前端
Log-Info "步骤 3/5: 构建前端..."
npm run build
if ($LASTEXITCODE -ne 0) {
    Log-Error "前端构建失败"
    exit 1
}
Log-Success "前端构建完成"

# 步骤 4: 构建后端
Log-Info "步骤 4/5: 构建后端..."
Set-Location server
npm run build
Set-Location ..
if ($LASTEXITCODE -ne 0) {
    Log-Error "后端构建失败"
    exit 1
}
Log-Success "后端构建完成"

# 步骤 5: 上传到服务器
Log-Info "步骤 5/5: 上传文件到服务器..."

# 检查是否安装了 WinSCP 或使用 scp
$useWinSCP = Get-Command "WinSCP.com" -ErrorAction SilentlyContinue

if ($useWinSCP) {
    # 使用 WinSCP
    Log-Info "使用 WinSCP 上传..."
    $winscpScript = @"
option batch abort
option confirm off
open sftp://${ServerUser}:${ServerPassword}@${ServerIP}
option transfer binary
put -delete "$projectRoot\dist\*" "$ProjectDir/dist/"
put -delete "$projectRoot\server\*" "$ProjectDir/server/"
put -delete "$projectRoot\database\*" "$ProjectDir/database/"
put "$projectRoot\deploy\deploy-app.sh" "$ProjectDir/"
exit
"@
    
    $winscpScript | Out-File -FilePath "winscp_script.tmp" -Encoding ASCII
    & WinSCP.com /script=winscp_script.tmp
    Remove-Item "winscp_script.tmp"
} else {
    # 使用 scp (需要安装 OpenSSH 或 Git Bash)
    Log-Info "使用 scp 上传..."
    Log-Warning "请确保已安装 OpenSSH 或 Git Bash"
    
    # 创建临时目录结构
    $tempDir = "$env:TEMP\chengyan-deploy"
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    # 复制文件
    Copy-Item -Path "dist" -Destination "$tempDir\dist" -Recurse
    Copy-Item -Path "server" -Destination "$tempDir\server" -Recurse
    Copy-Item -Path "database" -Destination "$tempDir\database" -Recurse
    Copy-Item -Path "deploy\deploy-app.sh" -Destination $tempDir
    
    # 使用 scp 上传
    $env:SSHPASS = $ServerPassword
    sshpass -p $ServerPassword scp -o StrictHostKeyChecking=no -r $tempDir/* "${ServerUser}@${ServerIP}:${ProjectDir}/"
    
    Remove-Item $tempDir -Recurse -Force
}

Log-Success "文件上传完成"

# 完成
Write-Output ""
Write-ColorOutput Green "========================================"
Write-ColorOutput Green "   构建和上传完成！"
Write-ColorOutput Green "========================================"
Write-Output ""
Write-ColorOutput Yellow "接下来请在服务器上执行："
Write-Output "  1. 登录服务器: ssh root@$ServerIP"
Write-Output "  2. 运行部署脚本: cd $ProjectDir && bash deploy-app.sh"
Write-Output ""
Write-ColorOutput Yellow "或者使用阿里云 Workbench："
Write-Output "  1. 登录阿里云控制台"
Write-Output "  2. 找到您的 ECS 实例"
Write-Output "  3. 点击 '远程连接' -> '通过 Workbench 远程连接'"
Write-Output "  4. 执行: cd $ProjectDir && bash deploy-app.sh"
Write-Output ""
