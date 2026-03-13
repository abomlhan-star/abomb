#!/bin/bash

#########################################################################
# 成研运营项目管理系统 - 更新部署
# 从 Git 拉取最新代码并重新部署
#########################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 配置
PROJECT_DIR="/var/www/chengyan-operation"

# 检查目录
if [ ! -d "$PROJECT_DIR" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi

cd $PROJECT_DIR

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   更新部署${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 步骤 1: 拉取最新代码
log_info "步骤 1/6: 拉取最新代码..."
git fetch origin
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ $LOCAL = $REMOTE ]; then
    log_warning "代码已是最新，无需更新"
    read -p "是否强制重新部署？(y/n): " force
    if [ "$force" != "y" ]; then
        exit 0
    fi
else
    git reset --hard origin/main 2>/dev/null || git reset --hard origin/master
    log_success "代码更新完成"
fi

# 步骤 2: 安装依赖
log_info "步骤 2/6: 安装依赖..."
npm install
cd server
npm install
cd ..
log_success "依赖安装完成"

# 步骤 3: 构建前端
log_info "步骤 3/6: 构建前端..."
npm run build
log_success "前端构建完成"

# 步骤 4: 构建后端
log_info "步骤 4/6: 构建后端..."
cd server
npm run build
cd ..
log_success "后端构建完成"

# 步骤 5: 运行数据库迁移
log_info "步骤 5/6: 检查数据库迁移..."
cd server
if npm run migrate:status 2>/dev/null | grep -q "pending"; then
    npm run migrate
    log_success "数据库迁移完成"
else
    log_warning "无需数据库迁移"
fi
cd ..

# 步骤 6: 重启服务
log_info "步骤 6/6: 重启服务..."
pm2 restart chengyan-api
log_success "服务重启完成"

# 完成
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   更新部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}访问地址：${NC}"
echo "  http://47.108.184.131"
echo ""
echo -e "${YELLOW}查看日志：${NC}"
echo "  pm2 logs chengyan-api"
echo ""
