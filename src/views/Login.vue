<template>
  <div class="fixed inset-0 z-0 bg-tech-gradient">
    <div class="absolute inset-0 mesh-bg opacity-50"></div>
    <div class="absolute inset-0" style="background-image: radial-gradient(rgba(255,255,255,0.05) 1px, transparent 1px); background-size: 40px 40px;"></div>
    <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/10 rounded-full blur-[100px] animate-pulse-slow"></div>
    <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-500/10 rounded-full blur-[100px] animate-pulse-slow" style="animation-delay: 1.5s;"></div>
  </div>
  
  <main class="relative z-10 flex flex-col items-center justify-center min-h-screen px-4">
    <div class="w-full max-w-md">
      <div class="glass-card p-8 md:p-12 rounded-3xl shadow-2xl transition-all duration-500 hover:border-primary/40">
        <div class="text-center mb-10">
          <h1 class="text-3xl md:text-4xl font-bold tracking-tight text-white mb-3 text-glow">
            成研运营项目管理系统
          </h1>
          <p class="text-slate-300/80 text-sm md:text-base font-medium">
            请登录以进入系统
          </p>
        </div>
        
        <form class="space-y-6" @submit.prevent="handleLogin">
          <div class="space-y-1">
            <div class="relative group">
              <span class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-primary transition-colors">
                <span class="material-icons text-[20px]">person</span>
              </span>
              <input 
                v-model="loginForm.username"
                class="w-full bg-white/5 border border-white/10 rounded-xl py-3.5 pl-12 pr-4 text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary/50 transition-all input-glow"
                placeholder="请输入用户名"
                type="text"
              />
            </div>
            <p v-if="errors.username" class="text-[11px] text-red-400/80 mt-1">
              {{ errors.username }}
            </p>
          </div>
          
          <div class="space-y-1">
            <div class="relative group">
              <span class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-primary transition-colors">
                <span class="material-icons text-[20px]">lock</span>
              </span>
              <input 
                v-model="loginForm.password"
                class="w-full bg-white/5 border border-white/10 rounded-xl py-3.5 pl-12 pr-4 text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary/50 transition-all input-glow"
                placeholder="请输入密码"
                type="password"
              />
            </div>
            <p v-if="errors.password" class="text-[11px] text-red-400/80 mt-1">
              {{ errors.password }}
            </p>
          </div>
          
          <div class="flex items-center justify-between text-sm">
            <label class="flex items-center cursor-pointer group">
              <div class="relative flex items-center">
                <input 
                  v-model="loginForm.remember"
                  class="peer h-4 w-4 rounded border-white/20 bg-white/5 text-primary focus:ring-primary/50 focus:ring-offset-0 transition-all"
                  type="checkbox"
                />
              </div>
              <span class="ml-2 text-slate-300 group-hover:text-white transition-colors">记住密码</span>
            </label>
            <a class="text-primary hover:text-blue-400 transition-colors font-medium" href="#">
              忘记密码？
            </a>
          </div>
          
          <button 
            :disabled="loading"
            class="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold py-3.5 rounded-xl shadow-lg shadow-blue-900/40 hover:shadow-blue-500/30 transition-all duration-300 transform hover:-translate-y-0.5 active:scale-[0.98] animate-glow"
            type="submit"
          >
            {{ loading ? '登录中...' : '登 录' }}
          </button>
        </form>
        
        <div class="mt-10 pt-8 border-t border-white/10 flex flex-col items-center space-y-4">
          <p class="text-slate-400 text-sm">
            © 2026 成研运营项目管理系统
          </p>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

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
  // 表单验证
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
    // 模拟登录API调用
    setTimeout(() => {
      // 模拟登录成功
      localStorage.setItem('token', 'mock-token-123456')
      localStorage.setItem('user', JSON.stringify({ username: loginForm.username }))
      
      ElMessage.success('登录成功')
      router.push('/')
    }, 1000)
  } catch (error) {
    ElMessage.error('登录失败，请检查用户名和密码')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.glass-card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.dark .glass-card {
  background: rgba(15, 23, 42, 0.4);
  border: 1px solid rgba(59, 130, 246, 0.2);
}

.text-glow {
  text-shadow: 0 0 10px rgba(59, 130, 246, 0.5);
}

.input-glow:focus {
  box-shadow: 0 0 15px rgba(59, 130, 246, 0.3);
}

.mesh-bg {
  background-image: 
    radial-gradient(at 0% 0%, rgba(59, 130, 246, 0.15) 0, transparent 50%), 
    radial-gradient(at 50% 0%, rgba(139, 92, 246, 0.15) 0, transparent 50%), 
    radial-gradient(at 100% 0%, rgba(59, 130, 246, 0.15) 0, transparent 50%);
}

.bg-tech-gradient {
  background: linear-gradient(135deg, #1e1b4b 0%, #312e81 25%, #4c1d95 50%, #1e1b4b 100%);
}

@keyframes pulse-slow {
  0%, 100% {
    opacity: 0.5;
  }
  50% {
    opacity: 0.8;
  }
}

@keyframes glow-pulse {
  0%, 100% {
    box-shadow: 0 0 5px rgba(59, 130, 246, 0.5);
  }
  50% {
    box-shadow: 0 0 20px rgba(59, 130, 246, 0.8);
  }
}

.animate-pulse-slow {
  animation: pulse-slow 3s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

.animate-glow {
  animation: glow-pulse 2s infinite ease-in-out;
}
</style>
