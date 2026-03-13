import { Router, Request, Response } from 'express'
import pool from '../database/connection'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import { authMiddleware, AuthRequest } from '../middleware/auth'

const router = Router()

router.post('/login', async (req: Request, res: Response): Promise<void> => {
  try {
    const { username, password } = req.body

    if (!username || !password) {
      res.status(400).json({ error: 'Username and password required' })
      return
    }

    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE account = ?',
      [username]
    )

    const users = rows as any[]

    if (users.length === 0) {
      res.status(401).json({ error: 'Invalid credentials' })
      return
    }

    const user = users[0]
    const isValidPassword = await bcrypt.compare(password, user.password)

    if (!isValidPassword) {
      res.status(401).json({ error: 'Invalid credentials' })
      return
    }

    const token = jwt.sign(
      { id: user.id, account: user.account, role: user.role },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    )

    res.json({
      token,
      user: {
        id: user.id,
        account: user.account,
        name: user.name,
        email: user.email,
        role: user.role
      }
    })
  } catch (error) {
    console.error('Login error:', error)
    res.status(500).json({ error: 'Login failed' })
  }
})

router.get('/me', authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.execute(
      'SELECT id, account, name, email, role FROM users WHERE id = ?',
      [req.user!.id]
    )

    const users = rows as any[]

    if (users.length === 0) {
      res.status(404).json({ error: 'User not found' })
      return
    }

    res.json(users[0])
  } catch (error) {
    console.error('Get user error:', error)
    res.status(500).json({ error: 'Failed to get user' })
  }
})

router.post('/refresh', authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    // 从请求中获取当前用户信息
    const userId = req.user!.id
    
    // 验证用户是否存在
    const [rows] = await pool.execute(
      'SELECT id, account, name, email, role FROM users WHERE id = ?',
      [userId]
    )

    const users = rows as any[]

    if (users.length === 0) {
      res.status(404).json({ error: 'User not found' })
      return
    }

    const user = users[0]

    // 生成新的token
    const token = jwt.sign(
      { id: user.id, account: user.account, role: user.role },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    )

    res.json({
      token,
      user: {
        id: user.id,
        account: user.account,
        name: user.name,
        email: user.email,
        role: user.role
      }
    })
  } catch (error) {
    console.error('Refresh token error:', error)
    res.status(500).json({ error: 'Failed to refresh token' })
  }
})

export default router
