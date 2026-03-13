<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'
import { authApi } from './api'

let tokenCheckInterval: number | null = null

// 检查token是否即将过期
const checkTokenExpiration = async () => {
  const token = localStorage.getItem('token')
  const expireTimeStr = localStorage.getItem('tokenExpireTime')
  
  if (!token || !expireTimeStr) {
    return
  }
  
  const expireTime = parseInt(expireTimeStr)
  const currentTime = new Date().getTime()
  const timeUntilExpire = expireTime - currentTime
  
  // 如果token将在24小时内过期，自动刷新
  if (timeUntilExpire < 24 * 60 * 60 * 1000) {
    try {
      const response = await authApi.refreshToken()
      // 保存新token和过期时间
      localStorage.setItem('token', response.token)
      const newExpireTime = new Date()
      newExpireTime.setDate(newExpireTime.getDate() + 7)
      localStorage.setItem('tokenExpireTime', newExpireTime.getTime().toString())
      console.log('Token refreshed automatically')
    } catch (error) {
      console.error('Token refresh failed:', error)
      // 刷新失败，跳转到登录页面
      localStorage.removeItem('token')
      localStorage.removeItem('tokenExpireTime')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
  }
}

onMounted(() => {
  // 立即检查一次
  checkTokenExpiration()
  
  // 每1小时检查一次
  tokenCheckInterval = window.setInterval(checkTokenExpiration, 60 * 60 * 1000)
})

onUnmounted(() => {
  if (tokenCheckInterval) {
    clearInterval(tokenCheckInterval)
  }
})
</script>

<style scoped>
/* 全局样式移至非登录页面 */
</style>
