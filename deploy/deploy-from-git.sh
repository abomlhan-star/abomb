#!/bin/bash

#########################################################################
# 成研运营项目管理系统 - 从 Git 部署应用
# 在服务器上运行，自动拉取代码、构建、部署
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
DB_NAME="chengyan_operation"
DB_USER="root"
DB_PASSWORD="Richonfo@123"

# 检查目录
if [ ! -d "$PROJECT_DIR" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    log_info "请先运行 server-setup-git.sh"
    exit 1
fi

cd $PROJECT_DIR

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   开始从 Git 部署应用${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 步骤 1: 拉取最新代码
log_info "步骤 1/8: 拉取最新代码..."
git fetch origin
git reset --hard origin/main 2>/dev/null || git reset --hard origin/master
log_success "代码更新完成"

# 步骤 2: 配置环境变量
log_info "步骤 2/8: 配置环境变量..."
if [ ! -f "server/.env" ]; then
    cat > server/.env << EOF
NODE_ENV=production
PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME

JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRES_IN=7d
EOF
    log_success "环境变量配置完成"
else
    log_warning ".env 文件已存在，跳过"
fi

# 步骤 3: 安装前端依赖
log_info "步骤 3/8: 安装前端依赖..."
npm install
log_success "前端依赖安装完成"

# 步骤 4: 安装后端依赖
log_info "步骤 4/8: 安装后端依赖..."
cd server
npm install
log_success "后端依赖安装完成"

# 步骤 5: 构建前端
log_info "步骤 5/8: 构建前端..."
cd $PROJECT_DIR
npm run build
log_success "前端构建完成"

# 步骤 6: 构建后端
log_info "步骤 6/8: 构建后端..."
cd server
npm run build
log_success "后端构建完成"

# 步骤 7: 初始化数据库
log_info "步骤 7/8: 初始化数据库..."
read -p "是否需要初始化数据库？(y/n): " init_db
if [ "$init_db" = "y" ]; then
    # 导入数据库结构
    if [ -f "../database/init-database.sql" ]; then
        mysql -u$DB_USER -p"$DB_PASSWORD" < ../database/init-database.sql
        log_success "数据库结构导入完成"
    fi
    
    # 运行迁移
    npm run migrate
    log_success "数据库迁移完成"
    
    # 导入种子数据
    read -p "是否导入初始数据？(y/n): " seed_data
    if [ "$seed_data" = "y" ]; then
        npm run seed
        log_success "初始数据导入完成"
    fi
fi

# 步骤 8: 配置并启动服务
log_info "步骤 8/8: 配置并启动服务..."

# 停止旧服务
pm2 delete chengyan-api 2>/dev/null || true

# 启动新服务
cd $PROJECT_DIR
pm2 start server/dist/index.js --name chengyan-api
pm2 save
pm2 startup | tail -n 1 | bash
log_success "后端服务启动完成"

# 配置 Nginx
read -p "请输入您的域名（没有域名直接回车）: " domain

if [ -z "$domain" ]; then
    SERVER_NAME="_"
else
    SERVER_NAME="$domain"
fi

cat > /etc/nginx/sites-available/chengyan-operation << EOF
server {
    listen 80;
    server_name $SERVER_NAME;
    
    # 前端静态文件
    location / {
        root $PROJECT_DIR/dist;
        try_files \$uri \$uri/ /index.html;
        index index.html;
    }
    
    # 后端 API 代理
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # 日志
    access_log /var/log/nginx/chengyan-access.log;
    error_log /var/log/nginx/chengyan-error.log;
}
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/chengyan-operation /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
log_success "Nginx 配置完成"

# 部署完成
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   部署成功！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}应用信息：${NC}"
echo "  项目目录: $PROJECT_DIR"
echo "  Git 仓库: https://github.com/abomlhan-star/abomb.git"
echo "  后端服务: http://localhost:3000"
if [ -z "$domain" ]; then
    echo "  访问地址: http://47.108.184.131"
else
    echo "  访问地址: http://$domain"
fi
echo ""
echo -e "${YELLOW}默认登录信息：${NC}"
echo "  用户名: admin"
echo "  密码: richinfo@123"
echo ""
echo -e "${YELLOW}更新代码：${NC}"
echo "  cd $PROJECT_DIR/deploy"
echo "  bash update-from-git.sh"
echo ""
echo -e "${YELLOW}常用命令：${NC}"
echo "  查看服务状态: pm2 status"
echo "  查看日志: pm2 logs chengyan-api"
echo "  重启服务: pm2 restart chengyan-api"
echo "  数据库备份: cd $PROJECT_DIR/server && npm run backup"
echo ""
