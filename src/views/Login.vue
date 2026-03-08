<template>
  <div class="fixed inset-0 bg-gradient-to-br from-indigo-900 via-purple-900 to-indigo-900 flex items-center justify-center px-4">
    <!-- 背景装饰 -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-500/20 rounded-full blur-[100px]"></div>
      <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-blue-500/20 rounded-full blur-[100px]"></div>
      <div class="absolute inset-0" style="background-image: radial-gradient(rgba(255,255,255,0.03) 1px, transparent 1px); background-size: 40px 40px;"></div>
    </div>
    
    <!-- 登录卡片 -->
    <div class="relative z-10 w-full max-w-md">
      <div class="bg-white/10 backdrop-blur-xl border border-white/20 rounded-3xl p-8 md:p-12 shadow-2xl">
        <div class="text-center mb-10">
          <h1 class="text-3xl md:text-4xl font-bold text-white mb-3">
            成研运营项目管理
          </h1>
          <p class="text-purple-200 text-sm md:text-base font-medium">
            请登录以进入系统
          </p>
        </div>
        
        <form class="space-y-6" @submit.prevent="handleLogin">
          <div class="space-y-1">
            <input 
              v-model="loginForm.username"
              class="w-full bg-white/5 border border-white/10 rounded-xl py-3.5 px-4 text-white placeholder-purple-300/50 focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-purple-500/50 transition-all"
              placeholder="请输入用户名"
              type="text"
            />
            <p v-if="errors.username" class="text-red-400 text-xs mt-1">
              {{ errors.username }}
            </p>
          </div>
          
          <div class="space-y-1">
            <input 
              v-model="loginForm.password"
              class="w-full bg-white/5 border border-white/10 rounded-xl py-3.5 px-4 text-white placeholder-purple-300/50 focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-purple-500/50 transition-all"
              placeholder="请输入密码"
              type="password"
            />
            <p v-if="errors.password" class="text-red-400 text-xs mt-1">
              {{ errors.password }}
            </p>
          </div>
          
          <div class="flex items-center justify-between text-sm">
            <label class="flex items-center cursor-pointer text-purple-200 hover:text-white transition-colors">
              <input 
                v-model="loginForm.remember"
                class="mr-2 h-4 w-4 rounded border-white/20 bg-white/5 text-purple-500 focus:ring-purple-500/50"
                type="checkbox"
              />
              记住密码
            </label>
            <a class="text-purple-300 hover:text-white transition-colors font-medium" href="#">
              忘记密码？
            </a>
          </div>
          
          <button 
            :disabled="loading"
            class="w-full bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-500 hover:to-indigo-500 text-white font-bold py-3.5 rounded-xl shadow-lg shadow-purple-900/50 hover:shadow-purple-500/30 transition-all duration-300 transform hover:-translate-y-0.5 active:scale-[0.98]"
            type="submit"
          >
            {{ loading ? '登录中...' : '登 录' }}
          </button>
        </form>
        
        <div class="mt-10 pt-8 border-t border-white/10 text-center">
          <p class="text-purple-300 text-sm">
            © 2026 成研运营项目管理
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { authApi } from '../api'

const router = useRouter()
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: '',
  remember: false
})

const errors = reactive({
  username: '',
  password: ''
})

const handleLogin = async () => {
  let isValid = true
  
  if (!loginForm.username) {
    errors.username = '请输入用户名'
    isValid = false
  } else {
    errors.username = ''
  }
  
  if (!loginForm.password) {
    errors.password = '请输入密码'
    isValid = false
  } else {
    errors.password = ''
  }
  
  if (!isValid) return
  
  loading.value = true
  try {
    // 调用后端API登录
    const response = await authApi.login({
      username: loginForm.username,
      password: loginForm.password
    })
    
    // 保存token和用户信息
    localStorage.setItem('token', response.token)
    localStorage.setItem('user', JSON.stringify({ 
      username: loginForm.username,
      email: response.user?.email || 'admin@chengyan.com',
      role: response.user?.role || 'admin'
    }))
    
    ElMessage.success('登录成功')
    router.push('/')
  } catch (error: any) {
    console.error('登录失败:', error)
    ElMessage.error(error.message || '登录失败，请检查用户名和密码')
  } finally {
    loading.value = false
  }
}
</script>
