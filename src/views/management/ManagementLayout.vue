<template>
  <div class="min-h-screen bg-slate-50 dark:bg-slate-900">
    <!-- 顶部导航条 -->
    <header class="bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700 shadow-sm">
      <div class="px-6 py-3 flex items-center justify-between">
        <div class="flex items-center gap-4">
          <button 
            class="flex items-center gap-2 text-slate-600 dark:text-slate-300 hover:text-primary transition-colors"
            @click="goBack"
          >
            <el-icon><ArrowLeft /></el-icon>
            <span class="text-sm font-medium">返回项目管理</span>
          </button>
          <div class="h-6 w-px bg-slate-200 dark:bg-slate-700"></div>
          <h1 class="text-lg font-bold text-slate-800 dark:text-white">系统后台管理</h1>
        </div>
        
        <nav class="flex items-center gap-2">
          <button 
            class="px-4 py-2 text-sm font-medium rounded-lg transition-all"
            :class="currentRoute === 'users' ? 'bg-primary text-white' : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700'"
            @click="navigateTo('users')"
          >
            <el-icon class="text-sm mr-1"><UserFilled /></el-icon>
            用户管理
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium rounded-lg transition-all"
            :class="currentRoute === 'group-customer' ? 'bg-primary text-white' : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700'"
            @click="navigateTo('group-customer')"
          >
            <el-icon class="text-sm mr-1"><OfficeBuilding /></el-icon>
            集团&客户管理
          </button>
        </nav>
        
        <div class="flex items-center gap-3">
          <span class="text-sm text-slate-500 dark:text-slate-400">{{ userDisplayName }}</span>
          <button 
            class="text-slate-400 hover:text-red-500 transition-colors"
            @click="handleLogout"
          >
            <el-icon><SwitchButton /></el-icon>
          </button>
        </div>
      </div>
    </header>
    
    <!-- 主内容区域 -->
    <main class="p-6" style="width: 1280px; margin: 0 auto;">
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()

const userDisplayName = ref('')

const currentRoute = computed(() => {
  return route.name as string
})

onMounted(() => {
  // 从localStorage获取用户信息
  const userStr = localStorage.getItem('user')
  if (userStr) {
    try {
      const user = JSON.parse(userStr)
      userDisplayName.value = user.name || user.username || 'Admin'
    } catch (error) {
      console.error('解析用户信息失败:', error)
      userDisplayName.value = 'Admin'
    }
  } else {
    userDisplayName.value = 'Admin'
  }
})

const goBack = () => {
  router.push('/')
}

const navigateTo = (name: string) => {
  router.push({ name })
}

const handleLogout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  localStorage.removeItem('tokenExpireTime')
  ElMessage.success('退出登录成功')
  router.push('/login')
}
</script>