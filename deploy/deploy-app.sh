#!/bin/bash

#########################################################################
# 成研运营项目管理系统 - 应用部署脚本
# 在服务器上运行，用于部署应用代码
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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 项目配置
PROJECT_DIR="/var/www/chengyan-operation"

# 检查目录
if [ ! -d "$PROJECT_DIR" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    log_info "请先运行 server-setup.sh"
    exit 1
fi

cd $PROJECT_DIR

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   开始部署应用${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 步骤 1: 检查文件
log_info "步骤 1/7: 检查项目文件..."
if [ ! -d "server" ] || [ ! -d "dist" ]; then
    log_error "缺少必要文件，请先上传项目"
    exit 1
fi
log_success "项目文件检查通过"

# 步骤 2: 配置环境变量
log_info "步骤 2/7: 配置环境变量..."
if [ ! -f "server/.env" ]; then
    if [ -f "server/.env.example" ]; then
        cp server/.env.example server/.env
        log_success "已创建 .env 文件，请根据需要修改"
    else
        log_error "缺少 .env.example 文件"
        exit 1
    fi
else
    log_warning ".env 文件已存在，跳过"
fi

# 步骤 3: 安装后端依赖
log_info "步骤 3/7: 安装后端依赖..."
cd server
npm install --production
log_success "后端依赖安装完成"

# 步骤 4: 构建后端
log_info "步骤 4/7: 构建后端代码..."
npm run build
log_success "后端构建完成"

# 步骤 5: 初始化数据库
log_info "步骤 5/7: 初始化数据库..."
read -p "是否需要初始化数据库？(y/n): " init_db
if [ "$init_db" = "y" ]; then
    # 导入数据库结构
    if [ -f "../database/init-database.sql" ]; then
        DB_PASSWORD=$(grep DB_PASSWORD .env | cut -d '=' -f2)
        mysql -uroot -p"$DB_PASSWORD" < ../database/init-database.sql
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

# 步骤 6: 配置 PM2
log_info "步骤 6/7: 配置 PM2..."
cd $PROJECT_DIR
pm2 delete chengyan-api 2>/dev/null || true
pm2 start server/dist/index.js --name chengyan-api
pm2 save
pm2 startup | tail -n 1 | bash
log_success "PM2 配置完成"

# 步骤 7: 配置 Nginx
log_info "步骤 7/7: 配置 Nginx..."
read -p "请输入您的域名（没有域名直接回车）: " domain

if [ -z "$domain" ]; then
    SERVER_NAME="_"
else
    SERVER_NAME="$domain"
fi

cat > /etc/nginx/sites-available/chengyan-operation <<EOF
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
echo "  后端服务: http://localhost:3000"
if [ -z "$domain" ]; then
    echo "  访问地址: http://$(curl -s ifconfig.me)"
else
    echo "  访问地址: http://$domain"
fi
echo ""
echo -e "${YELLOW}默认登录信息：${NC}"
echo "  用户名: admin"
echo "  密码: richinfo@123"
echo ""
echo -e "${YELLOW}常用命令：${NC}"
echo "  查看服务状态: pm2 status"
echo "  查看日志: pm2 logs chengyan-api"
echo "  重启服务: pm2 restart chengyan-api"
echo "  数据库备份: cd $PROJECT_DIR/server && npm run backup"
echo ""
echo -e "${YELLOW}安全建议：${NC}"
echo "  1. 修改数据库密码和 JWT_SECRET"
echo "  2. 配置 HTTPS (使用 certbot)"
echo "  3. 修改默认管理员密码"
echo ""
