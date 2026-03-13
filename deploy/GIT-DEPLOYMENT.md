# 成研运营项目 - Git 自动化部署指南

## 📋 部署信息

- **服务器公网 IP**：47.108.184.131
- **服务器私网 IP**：172.25.119.89
- **Git 仓库**：https://github.com/abomlhan-star/abomb.git
- **登录账号**：root
- **登录密码**：Richonfo@123

---

## 🚀 快速部署（两步完成）

### 第一步：准备服务器环境

1. **登录阿里云控制台**
   - 访问：https://ecs.console.aliyun.com/
   - 找到 ECS 实例（IP：47.108.184.131）

2. **使用 Workbench 远程连接**
   - 点击「远程连接」→「通过 Workbench 远程连接」
   - 用户名：`root`
   - 密码：`Richonfo@123`

3. **运行环境准备脚本**

   在 Workbench 终端中执行：

   ```bash
   # 创建脚本文件
   cat > /tmp/server-setup-git.sh << 'EOF'
   #!/bin/bash
   # 复制 deploy/server-setup-git.sh 的内容
   EOF
   
   # 或者直接下载（如果代码已推送）
   cd /tmp
   git clone https://github.com/abomlhan-star/abomb.git
   cd abomb/deploy
   bash server-setup-git.sh
   ```

---

### 第二步：部署应用

在服务器上执行：

```bash
cd /var/www/chengyan-operation/deploy
bash deploy-from-git.sh
```

按提示操作：
- 是否初始化数据库？输入 `y`
- 是否导入初始数据？输入 `y`
- 输入域名（没有直接回车）

---

## ✅ 部署完成！

- **访问地址**：http://47.108.184.131
- **用户名**：`admin`
- **密码**：`richinfo@123`

---

## 🔄 代码更新流程

当您在本地修改代码并推送到 GitHub 后，在服务器上执行：

```bash
cd /var/www/chengyan-operation/deploy
bash update-from-git.sh
```

脚本会自动：
1. 拉取最新代码
2. 安装依赖
3. 构建前端和后端
4. 运行数据库迁移
5. 重启服务

---

## 📁 服务器目录结构

```
/var/www/chengyan-operation/
├── dist/                    # 前端构建文件
├── server/                  # 后端代码
│   ├── dist/               # 后端构建文件
│   ├── .env                # 环境变量（生产环境）
│   └── ...
├── database/               # 数据库脚本
├── deploy/                 # 部署脚本
│   ├── server-setup-git.sh
│   ├── deploy-from-git.sh
│   └── update-from-git.sh
└── .git/                   # Git 仓库
```

---

## 🔧 详细步骤说明

### 方式一：首次部署（完整流程）

如果您是第一次部署，请按以下步骤操作：

#### 1. 连接服务器

使用阿里云 Workbench 或 SSH 客户端：

```bash
ssh root@47.108.184.131
# 密码：Richonfo@123
```

#### 2. 准备环境

```bash
# 更新系统
apt-get update -y

# 安装必要软件
apt-get install -y git curl

# 安装 Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# 安装 PM2
npm install -g pm2

# 安装 Nginx
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# 创建项目目录
mkdir -p /var/www/chengyan-operation
```

#### 3. 克隆代码

```bash
cd /var/www
git clone https://github.com/abomlhan-star/abomb.git chengyan-operation
cd chengyan-operation
```

#### 4. 配置环境变量

```bash
cat > server/.env << EOF
NODE_ENV=production
PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=Richonfo@123
DB_NAME=chengyan_operation

JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRES_IN=7d
EOF
```

#### 5. 安装依赖

```bash
# 前端依赖
npm install

# 后端依赖
cd server
npm install
cd ..
```

#### 6. 构建项目

```bash
# 构建前端
npm run build

# 构建后端
cd server
npm run build
cd ..
```

#### 7. 初始化数据库

```bash
# 创建数据库
mysql -uroot -p'Richonfo@123' -e "CREATE DATABASE IF NOT EXISTS chengyan_operation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 导入数据库结构
mysql -uroot -p'Richonfo@123' < database/init-database.sql

# 运行迁移
cd server
npm run migrate

# 导入初始数据
npm run seed
cd ..
```

#### 8. 启动服务

```bash
# 使用 PM2 启动后端
pm2 start server/dist/index.js --name chengyan-api
pm2 save
pm2 startup | tail -n 1 | bash
```

#### 9. 配置 Nginx

```bash
cat > /etc/nginx/sites-available/chengyan-operation << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        root /var/www/chengyan-operation/dist;
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/chengyan-operation /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

#### 10. 配置防火墙

```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable
```

---

### 方式二：使用自动化脚本（推荐）

```bash
# 1. 克隆代码
cd /var/www
git clone https://github.com/abomlhan-star/abomb.git chengyan-operation

# 2. 运行环境准备脚本
cd chengyan-operation/deploy
bash server-setup-git.sh

# 3. 运行部署脚本
bash deploy-from-git.sh
```

---

## 🔒 安全配置

### 1. 配置阿里云安全组

在阿里云控制台添加安全组规则：

| 端口 | 协议 | 授权对象 | 说明 |
|------|------|---------|------|
| 22 | TCP | 0.0.0.0/0 | SSH |
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS |

### 2. 配置 HTTPS（可选）

```bash
# 安装 certbot
apt-get install certbot python3-certbot-nginx

# 申请证书（需要域名）
certbot --nginx -d your-domain.com

# 自动续期
certbot renew --dry-run
```

### 3. 修改默认密码

```bash
# 登录应用后修改管理员密码
# 或修改 JWT_SECRET
nano /var/www/chengyan-operation/server/.env
pm2 restart chengyan-api
```

---

## 🛠️ 常用命令

### PM2 管理

```bash
pm2 status              # 查看服务状态
pm2 logs chengyan-api   # 查看日志
pm2 restart chengyan-api # 重启服务
pm2 stop chengyan-api   # 停止服务
pm2 monit               # 监控面板
```

### Nginx 管理

```bash
systemctl status nginx  # 查看状态
systemctl restart nginx # 重启 Nginx
nginx -t               # 测试配置
tail -f /var/log/nginx/chengyan-error.log # 查看错误日志
```

### Git 操作

```bash
cd /var/www/chengyan-operation
git status              # 查看状态
git pull                # 拉取最新代码
git log --oneline -10   # 查看最近提交
```

### 数据库管理

```bash
cd /var/www/chengyan-operation/server
npm run backup          # 创建备份
npm run backup:list     # 查看备份列表
npm run migrate         # 运行迁移
```

---

## 🐛 故障排查

### 问题 1：无法访问网站

```bash
# 检查服务状态
pm2 status
systemctl status nginx

# 检查端口
netstat -tlnp | grep -E '80|3000'

# 检查防火墙
ufw status

# 检查阿里云安全组
```

### 问题 2：Git 拉取失败

```bash
# 检查网络连接
ping github.com

# 使用代理（如果需要）
git config --global http.proxy http://proxy-server:port

# 或使用 Gitee 镜像
git remote set-url origin https://gitee.com/your-repo.git
```

### 问题 3：数据库连接失败

```bash
# 检查 MySQL 状态
systemctl status mysql

# 测试连接
mysql -uroot -p'Richonfo@123'

# 检查配置
cat /var/www/chengyan-operation/server/.env
```

---

## 📝 开发流程

### 本地开发 → 服务器部署

1. **本地修改代码**
   ```bash
   # 在本地项目目录
   git add .
   git commit -m "描述您的修改"
   git push origin main
   ```

2. **服务器更新部署**
   ```bash
   # 在服务器上
   cd /var/www/chengyan-operation/deploy
   bash update-from-git.sh
   ```

---

## 📞 技术支持

如遇到问题，请检查：
1. 服务状态：`pm2 status`
2. 日志文件：`pm2 logs chengyan-api`
3. Nginx 日志：`/var/log/nginx/chengyan-error.log`
4. 数据库连接：`mysql -uroot -p`

---

**祝您部署顺利！🎉**
