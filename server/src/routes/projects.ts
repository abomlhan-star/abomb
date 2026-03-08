import { Router, Response } from 'express'
import pool from '../database/connection'
import { authMiddleware, AuthRequest } from '../middleware/auth'

const router = Router()

router.use(authMiddleware)

router.get('/', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM projects ORDER BY created_at DESC'
    )
    res.json(rows)
  } catch (error) {
    console.error('Get projects error:', error)
    res.status(500).json({ error: 'Failed to get projects' })
  }
})

router.get('/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    const [rows] = await pool.execute(
      'SELECT * FROM projects WHERE id = ?',
      [id]
    )

    const projects = rows as any[]
    if (projects.length === 0) {
      res.status(404).json({ error: 'Project not found' })
      return
    }

    res.json(projects[0])
  } catch (error) {
    console.error('Get project error:', error)
    res.status(500).json({ error: 'Failed to get project' })
  }
})

router.post('/', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const {
      name,
      status,
      type,
      amount,
      contract_period,
      customer,
      approval_amount,
      gross_margin
    } = req.body

    if (!name || !customer) {
      res.status(400).json({ error: 'Name and customer are required' })
      return
    }

    const [result] = await pool.execute(
      `INSERT INTO projects (name, status, type, amount, contract_period, customer, approval_amount, gross_margin)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        name,
        status || '进行中',
        type || '运营类',
        amount || 0,
        contract_period,
        customer,
        approval_amount || 0,
        gross_margin || 0
      ]
    )

    res.status(201).json({
      id: (result as any).insertId,
      name,
      status,
      type,
      amount,
      contract_period,
      customer,
      approval_amount,
      gross_margin
    })
  } catch (error) {
    console.error('Create project error:', error)
    res.status(500).json({ error: 'Failed to create project' })
  }
})

router.put('/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const {
      name,
      status,
      type,
      amount,
      contract_period,
      customer,
      approval_amount,
      gross_margin
    } = req.body

    await pool.execute(
      `UPDATE projects
       SET name = ?, status = ?, type = ?, amount = ?, contract_period = ?, customer = ?, approval_amount = ?, gross_margin = ?
       WHERE id = ?`,
      [name, status, type, amount, contract_period, customer, approval_amount, gross_margin, id]
    )

    res.json({
      id,
      name,
      status,
      type,
      amount,
      contract_period,
      customer,
      approval_amount,
      gross_margin
    })
  } catch (error) {
    console.error('Update project error:', error)
    res.status(500).json({ error: 'Failed to update project' })
  }
})

router.delete('/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM projects WHERE id = ?', [id])
    res.json({ message: 'Project deleted' })
  } catch (error) {
    console.error('Delete project error:', error)
    res.status(500).json({ error: 'Failed to delete project' })
  }
})

export default router
