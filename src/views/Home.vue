<template>
  <div class="home-container">
    <!-- 顶部导航栏 -->
    <header class="top-nav">
      <div class="nav-left">
        <h1 class="app-title">城盐运营系统</h1>
      </div>
      <div class="nav-right">
        <el-dropdown>
          <span class="user-info">
            <el-avatar size="small" :src="userAvatar"></el-avatar>
            <span class="user-name">管理员</span>
            <el-icon><arrow-down /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item>个人中心</el-dropdown-item>
              <el-dropdown-item>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>

    <!-- 主内容区域 -->
    <div class="main-content">
      <!-- 侧边栏 -->
      <aside class="sidebar">
        <nav class="sidebar-nav">
          <el-menu
            :default-active="activeMenu"
            class="sidebar-menu"
            router
          >
            <el-menu-item index="/">
              <el-icon><house /></el-icon>
              <span>首页</span>
            </el-menu-item>
            <el-menu-item index="/users">
              <el-icon><user /></el-icon>
              <span>用户管理</span>
            </el-menu-item>
            <el-menu-item index="/products">
              <el-icon><goods /></el-icon>
              <span>产品管理</span>
            </el-menu-item>
            <el-menu-item index="/orders">
              <el-icon><ticket /></el-icon>
              <span>订单管理</span>
            </el-menu-item>
            <el-menu-item index="/analytics">
              <el-icon><data-analysis /></el-icon>
              <span>数据分析</span>
            </el-menu-item>
          </el-menu>
        </nav>
      </aside>

      <!-- 内容区域 -->
      <section class="content-area">
        <!-- 页面标题 -->
        <div class="page-header">
          <h2 class="page-title">仪表盘</h2>
          <div class="page-actions">
            <el-button type="primary">
              <el-icon><plus /></el-icon>
              新增数据
            </el-button>
          </div>
        </div>

        <!-- 统计卡片 -->
        <div class="stats-cards">
          <el-card class="stat-card">
            <div class="stat-item">
              <div class="stat-icon primary">
                <el-icon><user /></el-icon>
              </div>
              <div class="stat-content">
                <div class="stat-value">1,234</div>
                <div class="stat-label">用户总数</div>
              </div>
            </div>
          </el-card>
          <el-card class="stat-card">
            <div class="stat-item">
              <div class="stat-icon success">
                <el-icon><ticket /></el-icon>
              </div>
              <div class="stat-content">
                <div class="stat-value">567</div>
                <div class="stat-label">今日订单</div>
              </div>
            </div>
          </el-card>
          <el-card class="stat-card">
            <div class="stat-item">
              <div class="stat-icon warning">
                <el-icon><money /></el-icon>
              </div>
              <div class="stat-content">
                <div class="stat-value">¥89,123</div>
                <div class="stat-label">今日销售额</div>
              </div>
            </div>
          </el-card>
          <el-card class="stat-card">
            <div class="stat-item">
              <div class="stat-icon danger">
                <el-icon><trend-charts /></el-icon>
              </div>
              <div class="stat-content">
                <div class="stat-value">+12.5%</div>
                <div class="stat-label">同比增长</div>
              </div>
            </div>
          </el-card>
        </div>

        <!-- 数据表格 -->
        <div class="data-table">
          <el-card>
            <template #header>
              <div class="table-header">
                <h3>最近订单</h3>
                <el-input
                  v-model="searchQuery"
                  placeholder="搜索订单"
                  clearable
                  class="search-input"
                >
                  <template #prefix>
                    <el-icon><search /></el-icon>
                  </template>
                </el-input>
              </div>
            </template>
            <el-table :data="orderList" style="width: 100%">
              <el-table-column prop="id" label="订单号" width="180" />
              <el-table-column prop="customer" label="客户" width="180" />
              <el-table-column prop="amount" label="金额" width="120">
                <template #default="scope">
                  ¥{{ scope.row.amount }}
                </template>
              </el-table-column>
              <el-table-column prop="status" label="状态" width="120">
                <template #default="scope">
                  <el-tag :type="getStatusType(scope.row.status)">
                    {{ scope.row.status }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="date" label="日期" />
              <el-table-column label="操作" width="150">
                <template #default>
                  <el-button size="small" type="primary">查看</el-button>
                  <el-button size="small">编辑</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ArrowDown, House, User, Goods, Ticket, DataAnalysis, Plus, Search, Money, TrendCharts } from '@element-plus/icons-vue'

const activeMenu = ref('/')
const searchQuery = ref('')
const userAvatar = ref('https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=professional%20user%20avatar&image_size=square')

// 模拟订单数据
const orderList = ref([
  { id: 'ORD-2026-001', customer: '张三', amount: 1280, status: '已完成', date: '2026-03-04' },
  { id: 'ORD-2026-002', customer: '李四', amount: 890, status: '处理中', date: '2026-03-04' },
  { id: 'ORD-2026-003', customer: '王五', amount: 2150, status: '已完成', date: '2026-03-03' },
  { id: 'ORD-2026-004', customer: '赵六', amount: 560, status: '待付款', date: '2026-03-03' },
  { id: 'ORD-2026-005', customer: '钱七', amount: 1890, status: '已完成', date: '2026-03-02' }
])

const getStatusType = (status: string) => {
  switch (status) {
    case '已完成': return 'success'
    case '处理中': return 'warning'
    case '待付款': return 'info'
    default: return 'default'
  }
}
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #f5f7fa;
}

/* 顶部导航栏 */
.top-nav {
  height: 60px;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  position: sticky;
  top: 0;
  z-index: 100;
}

.app-title {
  font-size: 18px;
  font-weight: bold;
  color: #1890ff;
  margin: 0;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 5px 10px;
  border-radius: 4px;
  transition: all 0.3s;
}

.user-info:hover {
  background-color: #f0f0f0;
}

.user-name {
  font-size: 14px;
  color: #333;
}

/* 主内容区域 */
.main-content {
  flex: 1;
  display: flex;
  overflow: hidden;
}

/* 侧边栏 */
.sidebar {
  width: 200px;
  background-color: #fff;
  box-shadow: 2px 0 4px rgba(0, 0, 0, 0.1);
  height: calc(100vh - 60px);
  position: sticky;
  left: 0;
  top: 60px;
}

.sidebar-menu {
  border-right: none;
  height: 100%;
}

/* 内容区域 */
.content-area {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

/* 页面标题 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  font-size: 20px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

/* 统计卡片 */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #fff;
}

.stat-icon.primary {
  background-color: #1890ff;
}

.stat-icon.success {
  background-color: #52c41a;
}

.stat-icon.warning {
  background-color: #faad14;
}

.stat-icon.danger {
  background-color: #f5222d;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

/* 数据表格 */
.data-table {
  margin-top: 30px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.table-header h3 {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.search-input {
  width: 300px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .sidebar {
    width: 180px;
  }
  
  .stats-cards {
    grid-template-columns: 1fr;
  }
  
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .search-input {
    width: 100%;
  }
}
</style>
