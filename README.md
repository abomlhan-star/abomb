# 成研运营项目管理系统

一个基于 Vue 3 + TypeScript + MySQL 的项目管理系统。

## 项目结构

```
cheng-yan-operation/
├── src/                    # 前端源代码
│   ├── api/               # API 服务层
│   ├── router/            # 路由配置
│   └── views/             # 页面组件
├── server/                 # 后端服务
│   ├── src/
│   │   ├── database/      # 数据库配置和迁移
│   │   ├── middleware/    # 中间件
│   │   └── routes/        # API 路由
│   └── package.json
├── database/              # 数据库初始化脚本
└── backups/               # 数据库备份目录
```

## 快速开始

### 1. 环境要求

- Node.js >= 18
- MySQL >= 5.7
- npm 或 yarn

### 2. 安装依赖

```bash
# 安装前端依赖
npm install

# 安装后端依赖
cd server && npm install
```

### 3. 配置数据库

#### 方式一：使用脚本（推荐）

```bash
# Windows
setup-database.bat

# Linux/Mac
chmod +x setup-database.sh
./setup-database.sh
```

#### 方式二：手动配置

1. 创建数据库：
```bash
mysql -u root -p < database/init-database.sql
```

2. 配置数据库连接（编辑 `server/.env`）：
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=chengyan_operation
```

3. 运行迁移和种子数据：
```bash
cd server
npm run migrate
npm run seed
```

### 4. 启动服务

```bash
# 启动后端服务（在 server 目录）
cd server
npm run dev

# 启动前端服务（在根目录）
npm run dev
```

- 前端地址：http://localhost:5173
- 后端 API：http://localhost:3000/api

## 默认账户

- 用户名：`admin`
- 密码：`richinfo@123`

## 数据库管理

### 迁移管理

```bash
cd server

# 运行迁移
npm run migrate

# 查看迁移状态
npm run migrate:status
```

### 数据备份

```bash
cd server

# 创建备份
npm run backup

# 查看备份列表
npm run backup:list

# 恢复备份
npm run backup:restore <filename>
```

## 数据库表结构

| 表名 | 说明 |
|------|------|
| users | 用户信息 |
| projects | 项目信息 |
| contracts | 合同信息 |
| persons | 人员信息 |
| orders | 订单信息 |
| settlement_levels | 结算等级配置 |
| monthly_costs | 月度成本 |
| actual_settlements | 实际结算 |
| project_purchases | 项目采购 |
| important_items | 重要事项 |
| approval_configs | 立项配置 |
| settlement_periods | 结算周期 |
| schema_versions | 迁移版本记录 |

## 生产环境部署

### 1. 环境变量配置

复制并修改环境变量文件：

```bash
cp server/.env.example server/.env
```

修改以下关键配置：

```env
NODE_ENV=production
PORT=3000

DB_HOST=your_db_host
DB_PORT=3306
DB_USER=your_db_user
DB_PASSWORD=your_secure_password
DB_NAME=chengyan_operation

JWT_SECRET=your_very_secure_jwt_secret
JWT_EXPIRES_IN=7d
```

### 2. 构建和部署

```bash
# 构建前端
npm run build

# 构建后端
cd server && npm run build

# 启动后端服务
cd server && npm start
```

### 3. 数据库备份策略

建议设置定时任务定期备份数据库：

```bash
# 每天凌晨 2 点自动备份
0 2 * * * cd /path/to/server && npm run backup
```

## 更新升级

系统更新时，数据库迁移会自动执行，不会影响现有数据：

```bash
cd server
npm run migrate
```

## 技术栈

### 前端
- Vue 3
- TypeScript
- Vite
- Element Plus
- Tailwind CSS
- Vue Router

### 后端
- Node.js
- Express
- TypeScript
- MySQL2
- JWT 认证

## License

MIT
