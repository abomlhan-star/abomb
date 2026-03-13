#!/bin/bash

#########################################################################
# 成研运营项目管理系统 - 服务器一键部署脚本
# 适用于：Ubuntu/Debian 系统
# 使用方法：bash server-setup.sh
#########################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 项目配置
PROJECT_DIR="/var/www/chengyan-operation"
PROJECT_NAME="chengyan-operation"
DB_NAME="chengyan_operation"
DB_USER="root"
DB_PASSWORD="Richonfo@123"

# 开始部署
clear
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   成研运营项目管理系统 - 自动部署${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    log_error "请使用 root 用户运行此脚本"
    exit 1
fi

# 步骤 1: 更新系统
log_info "步骤 1/8: 更新系统软件包..."
apt-get update -y
log_success "系统更新完成"

# 步骤 2: 安装 Node.js
log_info "步骤 2/8: 安装 Node.js 18.x..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    log_success "Node.js 安装完成: $(node -v)"
else
    log_warning "Node.js 已安装: $(node -v)"
fi

# 步骤 3: 安装 PM2
log_info "步骤 3/8: 安装 PM2 进程管理器..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
    log_success "PM2 安装完成"
else
    log_warning "PM2 已安装"
fi

# 步骤 4: 安装 Nginx
log_info "步骤 4/8: 安装 Nginx..."
if ! command -v nginx &> /dev/null; then
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    log_success "Nginx 安装完成"
else
    log_warning "Nginx 已安装"
fi

# 步骤 5: 创建项目目录
log_info "步骤 5/8: 创建项目目录..."
mkdir -p $PROJECT_DIR
mkdir -p $PROJECT_DIR/backups
log_success "项目目录创建完成: $PROJECT_DIR"

# 步骤 6: 配置数据库
log_info "步骤 6/8: 配置数据库..."
read -p "请确认 MySQL root 密码 (默认: Richonfo@123): " input_password
DB_PASSWORD=${input_password:-$DB_PASSWORD}

# 测试数据库连接
if mysql -u$DB_USER -p"$DB_PASSWORD" -e "SELECT 1;" &> /dev/null; then
    log_success "数据库连接成功"
    
    # 创建数据库（如果不存在）
    mysql -u$DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    log_success "数据库 $DB_NAME 创建成功"
else
    log_error "数据库连接失败，请检查密码"
    exit 1
fi

# 步骤 7: 配置防火墙
log_info "步骤 7/8: 配置防火墙..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp    # SSH
    ufw allow 80/tcp    # HTTP
    ufw allow 443/tcp   # HTTPS
    ufw allow 3000/tcp  # API (可选，建议通过 Nginx 代理)
    echo "y" | ufw enable
    log_success "防火墙配置完成"
else
    log_warning "ufw 未安装，跳过防火墙配置"
fi

# 步骤 8: 创建环境变量文件模板
log_info "步骤 8/8: 创建配置文件模板..."
cat > $PROJECT_DIR/server/.env.example <<EOF
NODE_ENV=production
PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME

JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRES_IN=7d
EOF

log_success "配置文件模板创建完成"

# 部署完成
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   服务器环境准备完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}接下来请执行以下步骤：${NC}"
echo ""
echo "1. 上传项目文件到服务器："
echo "   本地运行: deploy-local.ps1"
echo ""
echo "2. 在服务器上运行部署脚本："
echo "   cd $PROJECT_DIR"
echo "   bash deploy-app.sh"
echo ""
echo "3. 访问您的应用："
echo "   http://您的服务器IP"
echo ""
echo -e "${YELLOW}提示：请确保阿里云安全组已开放 80 和 443 端口${NC}"
echo ""
