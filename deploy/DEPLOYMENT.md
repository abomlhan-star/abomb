# 成研运营项目管理系统 - 部署指南

## 📋 部署概览

本指南将帮助您将成研运营项目管理系统部署到阿里云 Ubuntu 服务器。

**部署架构：**
- 前端：Vue 3 应用 → Nginx 托管静态文件
- 后端：Node.js + Express → PM2 进程管理
- 数据库：MySQL
- 反向代理：Nginx

---

## 🚀 快速部署（三步完成）

### 第一步：准备服务器环境

1. **登录阿里云控制台**
   - 访问：https://ecs.console.aliyun.com/
   - 找到您的 ECS 实例

2. **使用 Workbench 远程连接**
   - 点击实例右侧的「远程连接」
   - 选择「通过 Workbench 远程连接」
   - 输入用户名：`root`
   - 输入密码：`Richonfo@123`

3. **运行环境准备脚本**
   ```bash
   # 下载并运行环境准备脚本
   curl -o server-setup.sh https://your-domain.com/server-setup.sh
   bash server-setup.sh
   ```
   
   或者手动创建脚本：
   ```bash
   nano server-setup.sh
   # 复制 deploy/server-setup.sh 的内容，粘贴保存
   # Ctrl+O 保存，Ctrl+X 退出
   bash server-setup.sh
   ```

---

### 第二步：本地构建和上传

#### 方式一：使用自动化脚本（推荐）

1. **在本地电脑上运行**
   ```powershell
   # 在项目根目录打开 PowerShell
   cd d:\trea\cheng-yan-operation
   .\deploy\deploy-local.bat
   ```

2. **按提示输入服务器信息**
   - 服务器 IP
   - 用户名（默认 root）
   - 密码

3. **使用 WinSCP 上传文件**
   - 下载 WinSCP：https://winscp.net/
   - 连接服务器后，上传以下目录：
     - `dist/` → `/var/www/chengyan-operation/dist/`
     - `server/` → `/var/www/chengyan-operation/server/`
     - `database/` → `/var/www/chengyan-operation/database/`
     - `deploy/deploy-app.sh` → `/var/www/chengyan-operation/`

#### 方式二：使用 Git（推荐）

如果您的代码在 Git 仓库：

```bash
# 在服务器上执行
cd /var/www/chengyan-operation
git clone https://your-repo-url.git .

# 或者如果已有代码
git pull origin main
```

---

### 第三步：服务器上部署应用

1. **在 Workbench 中执行**
   ```bash
   cd /var/www/chengyan-operation
   bash deploy-app.sh
   ```

2. **按提示操作**
   - 是否初始化数据库？输入 `y`
   - 是否导入初始数据？输入 `y`
   - 输入域名（没有直接回车）

3. **部署完成！**
   - 访问地址：`http://您的服务器IP`
   - 默认账号：`admin`
   - 默认密码：`richinfo@123`

---

## 📁 文件结构

部署后的服务器目录结构：

```
/var/www/chengyan-operation/
├── dist/                    # 前端构建文件
│   ├── index.html
│   ├── assets/
│   └── ...
├── server/                  # 后端代码
│   ├── dist/               # 后端构建文件
│   ├── src/                # 源代码
│   ├── .env                # 环境变量
│   └── package.json
├── database/               # 数据库脚本
│   └── init-database.sql
├── backups/                # 数据库备份目录
└── deploy-app.sh          # 部署脚本
```

---

## ⚙️ 配置说明

### 环境变量配置

编辑 `/var/www/chengyan-operation/server/.env`：

```env
NODE_ENV=production
PORT=3000

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=Richonfo@123
DB_NAME=chengyan_operation

# JWT 配置（请修改为随机字符串）
JWT_SECRET=your_random_secret_key_here
JWT_EXPIRES_IN=7d
```

### Nginx 配置

配置文件：`/etc/nginx/sites-available/chengyan-operation`

```nginx
server {
    listen 80;
    server_name _;  # 或您的域名
    
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
```

---

## 🔧 常用命令

### PM2 进程管理

```bash
# 查看服务状态
pm2 status

# 查看日志
pm2 logs chengyan-api

# 重启服务
pm2 restart chengyan-api

# 停止服务
pm2 stop chengyan-api

# 开机自启
pm2 startup
pm2 save
```

### Nginx 管理

```bash
# 测试配置
nginx -t

# 重载配置
systemctl reload nginx

# 重启 Nginx
systemctl restart nginx

# 查看状态
systemctl status nginx

# 查看日志
tail -f /var/log/nginx/chengyan-error.log
```

### 数据库管理

```bash
# 进入项目目录
cd /var/www/chengyan-operation/server

# 创建备份
npm run backup

# 查看备份列表
npm run backup:list

# 恢复备份
npm run backup:restore backup_filename.sql

# 运行迁移
npm run migrate
```

---

## 🔒 安全配置

### 1. 配置阿里云安全组

在阿里云控制台配置安全组规则：

| 端口 | 协议 | 说明 |
|------|------|------|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 3306 | TCP | MySQL（仅内网） |

### 2. 配置 HTTPS（推荐）

使用 Let's Encrypt 免费证书：

```bash
# 安装 certbot
apt-get install certbot python3-certbot-nginx

# 申请证书
certbot --nginx -d your-domain.com

# 自动续期
certbot renew --dry-run
```

### 3. 修改默认密码

```bash
# 登录应用后，立即修改管理员密码
# 或使用命令行修改
mysql -uroot -p
USE chengyan_operation;
UPDATE users SET password = 'new_hashed_password' WHERE username = 'admin';
```

### 4. 修改 JWT_SECRET

```bash
# 生成随机密钥
openssl rand -base64 32

# 更新 .env 文件
nano /var/www/chengyan-operation/server/.env
# 修改 JWT_SECRET 为生成的密钥

# 重启服务
pm2 restart chengyan-api
```

---

## 🔄 更新部署

当代码更新后，重新部署：

```bash
# 方式一：使用 Git
cd /var/www/chengyan-operation
git pull
bash deploy-app.sh

# 方式二：手动上传
# 1. 本地运行 deploy-local.bat 构建新版本
# 2. 使用 WinSCP 上传覆盖文件
# 3. 在服务器执行：
pm2 restart chengyan-api
```

---

## 🐛 故障排查

### 问题 1：无法访问网站

**检查步骤：**
```bash
# 1. 检查 Nginx 状态
systemctl status nginx

# 2. 检查后端服务
pm2 status

# 3. 检查端口占用
netstat -tlnp | grep -E '80|3000'

# 4. 检查防火墙
ufw status

# 5. 检查阿里云安全组
# 确保开放了 80 端口
```

### 问题 2：数据库连接失败

**检查步骤：**
```bash
# 1. 检查 MySQL 状态
systemctl status mysql

# 2. 测试数据库连接
mysql -uroot -p

# 3. 检查 .env 配置
cat /var/www/chengyan-operation/server/.env

# 4. 查看后端日志
pm2 logs chengyan-api
```

### 问题 3：API 请求失败

**检查步骤：**
```bash
# 1. 检查后端日志
pm2 logs chengyan-api

# 2. 测试 API
curl http://localhost:3000/api

# 3. 检查 Nginx 配置
nginx -t

# 4. 查看 Nginx 错误日志
tail -f /var/log/nginx/chengyan-error.log
```

---

## 📞 技术支持

如遇到问题，请检查：
1. 服务状态：`pm2 status` 和 `systemctl status nginx`
2. 日志文件：`pm2 logs` 和 `/var/log/nginx/`
3. 数据库连接：`mysql -uroot -p`
4. 防火墙和安全组配置

---

## 📝 部署检查清单

- [ ] 服务器环境准备完成（Node.js, Nginx, PM2）
- [ ] 数据库创建并初始化
- [ ] 项目文件上传到服务器
- [ ] 环境变量配置正确
- [ ] PM2 服务启动成功
- [ ] Nginx 配置正确
- [ ] 阿里云安全组开放端口
- [ ] 可以正常访问网站
- [ ] 修改了默认密码
- [ ] 配置了 HTTPS（可选）
- [ ] 设置了数据库定时备份

---

**祝您部署顺利！🎉**
