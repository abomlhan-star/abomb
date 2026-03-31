import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import path from 'path'
import { testConnection } from './database/connection'
import { runMigrations } from './database/migrations'
import { errorHandler, notFoundHandler } from './middleware/error'

import authRoutes from './routes/auth'
import userRoutes from './routes/users'
import projectRoutes from './routes/projects'
import dataRoutes from './routes/data'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000

app.use(cors({
  origin: true,
  credentials: true
}))

// 注册上传路由（放在express.json之前，避免解析multipart/form-data）
import uploadRoutes from './routes/uploads'
app.use('/api/uploads', uploadRoutes)

app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0'
  })
})

app.use('/api/auth', authRoutes)
app.use('/api/users', userRoutes)
app.use('/api/projects', projectRoutes)
app.use('/api/data', dataRoutes)

// 静态文件服务
app.use('/uploads', express.static(path.join(__dirname, '../uploads')))

app.use(notFoundHandler)
app.use(errorHandler)

async function startServer(): Promise<void> {
  try {
    console.log('🚀 Starting server...\n')

    const connected = await testConnection()
    if (!connected) {
      console.error('❌ Failed to connect to database. Exiting...')
      process.exit(1)
    }

    await runMigrations()

    app.listen(PORT, () => {
      console.log(`\n✅ Server running on http://localhost:${PORT}`)
      console.log(`📚 API available at http://localhost:${PORT}/api`)
      console.log(`🏥 Health check at http://localhost:${PORT}/api/health\n`)
    })
  } catch (error) {
    console.error('❌ Failed to start server:', error)
    process.exit(1)
  }
}

startServer()

export default app
