@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 成研运营项目管理系统 - 本地构建脚本
REM 服务器信息已配置

title 成研运营项目 - 部署工具

echo ========================================
echo    成研运营项目 - 部署工具
echo ========================================
echo.
echo 服务器信息:
echo   IP 地址: 47.108.184.131
echo   用户名: root
echo   密码: Richonfo@123
echo.
echo ========================================
echo.

echo [1/5] 检查项目文件...
cd /d "%~dp0.."
if not exist package.json (
    echo [错误] 未找到 package.json
    pause
    exit /b 1
)
echo [成功] 项目检查通过

echo.
echo [2/5] 安装依赖...
if not exist node_modules (
    echo 正在安装前端依赖...
    call npm install
    if errorlevel 1 (
        echo [错误] 前端依赖安装失败
        pause
        exit /b 1
    )
) else (
    echo [跳过] 前端依赖已存在
)
cd server
if not exist node_modules (
    echo 正在安装后端依赖...
    call npm install
    if errorlevel 1 (
        echo [错误] 后端依赖安装失败
        cd ..
        pause
        exit /b 1
    )
) else (
    echo [跳过] 后端依赖已存在
)
cd ..
echo [成功] 依赖安装完成

echo.
echo [3/5] 构建前端...
call npm run build
if errorlevel 1 (
    echo [错误] 前端构建失败
    pause
    exit /b 1
)
echo [成功] 前端构建完成

echo.
echo [4/5] 构建后端...
cd server
call npm run build
if errorlevel 1 (
    echo [错误] 后端构建失败
    cd ..
    pause
    exit /b 1
)
cd ..
echo [成功] 后端构建完成

echo.
echo [5/5] 准备上传文件...
echo.
echo ========================================
echo    构建完成！
echo ========================================
echo.
echo 接下来请使用 WinSCP 上传文件到服务器:
echo.
echo WinSCP 连接信息:
echo   主机名: 47.108.184.131
echo   端口: 22
echo   用户名: root
echo   密码: Richonfo@123
echo.
echo ----------------------------------------
echo 需要上传的目录:
echo ----------------------------------------
echo   本地路径                          服务器路径
echo   --------                          ----------
echo   dist\                -^>  /var/www/chengyan-operation/dist/
echo   server\              -^>  /var/www/chengyan-operation/server/
echo   database\            -^>  /var/www/chengyan-operation/database/
echo   deploy\deploy-app.sh -^>  /var/www/chengyan-operation/
echo.
echo ========================================
echo    上传完成后，在服务器执行:
echo ========================================
echo.
echo   cd /var/www/chengyan-operation
echo   bash deploy-app.sh
echo.
echo ========================================
echo    部署完成后访问:
echo ========================================
echo.
echo   http://47.108.184.131
echo   用户名: admin
echo   密码: richinfo@123
echo.
echo ========================================
echo.
pause
