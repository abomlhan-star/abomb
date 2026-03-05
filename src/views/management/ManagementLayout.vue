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
            <span class="material-symbols-outlined">arrow_back</span>
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
            <span class="material-symbols-outlined text-sm mr-1">group</span>
            用户管理
          </button>
        </nav>
        
        <div class="flex items-center gap-3">
          <span class="text-sm text-slate-500 dark:text-slate-400">{{ username }}</span>
          <button 
            class="text-slate-400 hover:text-red-500 transition-colors"
            @click="handleLogout"
          >
            <span class="material-symbols-outlined">logout</span>
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
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()

const username = ref('admin')

const currentRoute = computed(() => {
  return route.name as string
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
  ElMessage.success('退出登录成功')
  router.push('/login')
}
</script>