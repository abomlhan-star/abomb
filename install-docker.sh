#!/bin/bash
# Docker 和 Docker Compose 安装脚本
# 使用方法: 在服务器上以root用户运行此脚本

set -e

echo "=== Docker 和 Docker Compose 安装脚本 ==="
echo ""

# 检查是否是root用户
if [ "$EUID" -ne 0 ]; then
    echo "请以root用户运行此脚本"
    exit 1
fi

# 步骤1: 检查Docker是否已安装
echo "=== 步骤1: 检查Docker ==="
if command -v docker &> /dev/null; then
    echo "Docker已安装: $(docker --version)"
else
    echo "Docker未安装，开始安装..."
    
    # 更新系统包
    echo "更新系统包..."
    yum update -y
    
    # 安装必要的工具
    echo "安装必要工具..."
    yum install -y yum-utils device-mapper-persistent-data lvm2
    
    # 添加Docker仓库
    echo "添加Docker仓库..."
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # 安装Docker
    echo "安装Docker CE..."
    yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # 启动Docker
    echo "启动Docker..."
    systemctl start docker
    
    # 设置开机自启
    echo "设置开机自启..."
    systemctl enable docker
    
    echo "Docker安装完成"
fi

# 步骤2: 安装Docker Compose
echo ""
echo "=== 步骤2: 检查Docker Compose ==="
if command -v docker-compose &> /dev/null; then
    echo "Docker Compose已安装: $(docker-compose --version)"
elif command -v docker compose &> /dev/null; then
    echo "Docker Compose (plugin)已安装: $(docker compose version)"
else
    echo "Docker Compose未安装，开始安装..."
    
    # 下载Docker Compose
    echo "下载Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    
    # 设置执行权限
    echo "设置执行权限..."
    chmod +x /usr/local/bin/docker-compose
    
    # 创建符号链接
    echo "创建符号链接..."
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo "Docker Compose安装完成"
fi

# 步骤3: 验证安装
echo ""
echo "=== 步骤3: 验证安装 ==="
echo "Docker版本: $(docker --version)"
echo "Docker Compose版本: $(docker-compose --version 2>/dev/null || docker compose version)"
echo "Docker服务状态: $(systemctl is-active docker)"

# 测试Docker
echo ""
echo "=== 测试Docker ==="
docker run --rm hello-world 2>&1 || echo "Docker测试失败，请检查Docker守护进程是否正常运行"

echo ""
echo "=== 安装完成 ==="
echo ""
echo "下一步操作:"
echo "1. 运行: systemctl restart docker  (如果Docker未启动)"
echo "2. 验证Docker: docker ps"
echo "3. 上传项目代码并运行docker-compose"
