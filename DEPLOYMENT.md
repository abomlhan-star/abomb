# 成研运营系统 - 容器化部署方案

## 一、部署架构

```
─────────────────────────────────────────────────────────────┐
│                    Docker Compose 编排                       │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Nginx      │───→│   Node.js    │───→│    MySQL     │  │
│  │  (frontend)  │    │   (backend)  │    │  (database)  │  │
│  │  Port: 8080  │    │  Port: 3001  │    │  Port: 3307  │  │
│  ──────────────┘    └──────────────┘    └──────────────┘  │
│                                                             │
│  数据持久化卷：                                                │
│  - mysql_data: MySQL数据库数据                                 │
│  - api_uploads: 上传文件                                     │
─────────────────────────────────────────────────────────────┘
```

## 二、端口规划

| 服务 | 容器端口 | 宿主机映射 | 说明 |
|------|---------|-----------|------|
| 前端Nginx | 80 | 8080 | 前端静态文件 |
| 后端API | 3000 | 3001 | Node.js服务 |
| MySQL | 3306 | 3307 | 数据库 |

**端口设计原则：**
- 使用8080/3001/3307端口，避免与宿主机现有服务冲突
- 可以在同一台机器上部署多个不同系统

## 三、数据持久化方案

### 3.1 MySQL数据
- 使用Docker Volume `mysql_data` 持久化
- 数据存储在：`/var/lib/docker/volumes/chengyan_mysql_data/_data`
- 容器重启或重建时数据不会丢失

### 3.2 上传文件
- 使用Docker Volume `api_uploads` 持久化
- 文件存储在：`/var/lib/docker/volumes/chengyan_api_uploads/_data`

## 四、迁移步骤

### 4.1 备份现有数据

```bash
# 执行备份脚本
powershell -ExecutionPolicy Bypass -File backup-data.ps1
```

备份内容：
- MySQL数据库导出为SQL文件
- server/uploads/ 目录完整备份

### 4.2 构建并启动容器

```bash
# 执行部署脚本（自动完成构建、启动）
powershell -ExecutionPolicy Bypass -File docker-deploy.ps1
```

部署脚本自动完成：
1. 检查Docker环境
2. 备份现有数据
3. 构建Vue前端
4. 构建Docker镜像
5. 启动所有容器
6. 验证服务就绪

### 4.3 恢复数据

```bash
# 执行数据恢复脚本
powershell -ExecutionPolicy Bypass -File restore-data.ps1
```

恢复内容：
- 将SQL文件导入容器化MySQL
- 将上传文件恢复到容器卷

### 4.4 更新Nginx配置（可选）

如果需要将域名指向新容器服务，更新宿主机Nginx配置：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 五、常用运维命令

### 查看服务状态
```bash
docker-compose ps
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f chengyan-api
```

### 重启服务
```bash
# 重启所有服务
docker-compose restart

# 重启单个服务
docker-compose restart chengyan-api
```

### 停止服务
```bash
docker-compose down
```

### 更新部署
```bash
# 停止服务
docker-compose down

# 重新构建并启动
docker-compose up -d --build
```

### 数据库操作
```bash
# 进入MySQL容器
docker exec -it chengyan-mysql mysql -u root -p123456

# 备份数据库
docker exec chengyan-mysql mysqldump -u root -p123456 chengyan_operation > backup.sql

# 恢复数据库
docker exec -i chengyan-mysql mysql -u root -p123456 chengyan_operation < backup.sql
```

## 六、多系统共存

可以在同一台机器上部署多个系统，只需修改端口：

### 系统A（当前系统）
- 前端: 8080
- 后端: 3001
- MySQL: 3307

### 系统B（新系统）
复制项目，修改 `.env.docker` 中的端口：
```
FRONTEND_PORT=8081
API_PORT=3002
MYSQL_PORT=3308
```

## 七、优势

1. **环境隔离**: 每个服务独立容器，互不影响
2. **数据持久化**: 使用Docker Volume，数据不会丢失
3. **便于迁移**: 可以轻松迁移到其他服务器
4. **快速部署**: 一条命令完成部署
5. **多系统共存**: 可以在同一台机器部署多个系统
6. **版本管理**: 可以使用Docker镜像标签进行版本管理

## 八、文件清单

| 文件 | 说明 |
|------|------|
| Dockerfile | 前端Nginx镜像配置 |
| server/Dockerfile | 后端Node.js镜像配置 |
| docker-compose.yml | Docker编排配置 |
| nginx.conf | 容器内Nginx配置 |
| .env.docker | 容器化环境变量 |
| .dockerignore | Docker构建排除文件 |
| server/.dockerignore | 后端Docker构建排除文件 |
| backup-data.ps1 | 数据备份脚本 |
| restore-data.ps1 | 数据恢复脚本 |
| docker-deploy.ps1 | 容器化部署脚本 |
