<template>
  <div class="home-container">
    <!-- 顶部导航栏 -->
    <header class="top-nav">
      <div class="nav-left">
        <h1 class="app-title">成研运营项目管理</h1>
      </div>
      <div class="nav-right">
        <span class="welcome-text">欢迎，{{ username }}</span>
        <el-button type="text" @click="handleLogout">退出登录</el-button>
      </div>
    </header>

    <!-- 主内容区域 -->
    <main class="main-content">
      <div class="welcome-container">
        <el-card class="welcome-card">
          <template #header>
            <div class="card-header">
              <span>系统概览</span>
            </div>
          </template>
          <div class="welcome-content">
            <el-avatar size="large" :src="userAvatar"></el-avatar>
            <h2>欢迎回来，{{ username }}！</h2>
            <p class="welcome-message">您已成功登录城盐运营系统，开始您的工作吧。</p>
            <div class="quick-actions">
              <el-button type="primary">
                <el-icon><Plus /></el-icon>
                新增数据
              </el-button>
              <el-button>
                <el-icon><DataAnalysis /></el-icon>
                查看报表
              </el-button>
              <el-button>
                <el-icon><Setting /></el-icon>
                系统设置
              </el-button>
            </div>
          </div>
        </el-card>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, DataAnalysis, Setting } from '@element-plus/icons-vue'

const router = useRouter()
const username = ref('')
const userAvatar = ref('https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=professional%20user%20avatar&image_size=square')

onMounted(() => {
  // 从localStorage获取用户信息
  const userStr = localStorage.getItem('user')
  if (userStr) {
    const user = JSON.parse(userStr)
    username.value = user.username
  }
})

const handleLogout = () => {
  // 清除localStorage中的token和用户信息
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  
  ElMessage.success('退出登录成功')
  router.push('/login')
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

.nav-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.welcome-text {
  font-size: 14px;
  color: #666;
}

/* 主内容区域 */
.main-content {
  flex: 1;
  padding: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.welcome-container {
  width: 100%;
  max-width: 600px;
}

.welcome-card {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card-header {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.welcome-content {
  text-align: center;
  padding: 40px 20px;
}

.welcome-content h2 {
  margin: 20px 0 10px;
  color: #333;
}

.welcome-message {
  color: #666;
  margin-bottom: 30px;
}

.quick-actions {
  display: flex;
  justify-content: center;
  gap: 20px;
  flex-wrap: wrap;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .main-content {
    padding: 20px;
  }
  
  .quick-actions {
    flex-direction: column;
    align-items: center;
  }
  
  .quick-actions el-button {
    width: 100%;
    max-width: 200px;
  }
}
</style>
