import { Router, Response } from 'express'
import pool from '../database/connection'
import { authMiddleware, AuthRequest, adminMiddleware } from '../middleware/auth'
import bcrypt from 'bcryptjs'

const router = Router()

router.use(authMiddleware)

router.get('/', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.execute(
      'SELECT id, account, name, email, role, created_at FROM users ORDER BY created_at DESC'
    )
    res.json(rows)
  } catch (error) {
    console.error('Get users error:', error)
    res.status(500).json({ error: 'Failed to get users' })
  }
})

router.post('/', adminMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { account, password, name, email, role } = req.body

    if (!account || !password || !name || !email) {
      res.status(400).json({ error: 'All fields are required' })
      return
    }

    const hashedPassword = await bcrypt.hash(password, 10)

    const [result] = await pool.execute(
      `INSERT INTO users (account, password, name, email, role)
       VALUES (?, ?, ?, ?, ?)`,
      [account, hashedPassword, name, email, role || 'project_manager']
    )

    res.status(201).json({
      id: (result as any).insertId,
      account,
      name,
      email,
      role: role || 'project_manager'
    })
  } catch (error: any) {
    if (error.code === 'ER_DUP_ENTRY') {
      res.status(400).json({ error: 'Account or email already exists' })
      return
    }
    console.error('Create user error:', error)
    res.status(500).json({ error: 'Failed to create user' })
  }
})

router.put('/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const { name, email, role } = req.body

    await pool.execute(
      `UPDATE users SET name = ?, email = ?, role = ? WHERE id = ?`,
      [name, email, role, id]
    )

    res.json({ id, name, email, role })
  } catch (error) {
    console.error('Update user error:', error)
    res.status(500).json({ error: 'Failed to update user' })
  }
})

router.delete('/:id', adminMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    const [rows] = await pool.execute(
      'SELECT account FROM users WHERE id = ?',
      [id]
    )

    const users = rows as any[]
    if (users.length > 0 && users[0].account === 'admin') {
      res.status(400).json({ error: 'Cannot delete admin account' })
      return
    }

    await pool.execute('DELETE FROM users WHERE id = ?', [id])
    res.json({ message: 'User deleted' })
  } catch (error) {
    console.error('Delete user error:', error)
    res.status(500).json({ error: 'Failed to delete user' })
  }
})

router.post('/:id/reset-password', adminMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const { password } = req.body

    if (!password) {
      res.status(400).json({ error: 'Password is required' })
      return
    }

    const hashedPassword = await bcrypt.hash(password, 10)

    await pool.execute(
      'UPDATE users SET password = ? WHERE id = ?',
      [hashedPassword, id]
    )

    res.json({ message: 'Password reset successful' })
  } catch (error) {
    console.error('Reset password error:', error)
    res.status(500).json({ error: 'Failed to reset password' })
  }
})

export default router
