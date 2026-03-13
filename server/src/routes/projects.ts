import { Router, Response } from 'express'
import pool from '../database/connection'
import { authMiddleware, AuthRequest } from '../middleware/auth'

const router = Router()

router.use(authMiddleware)

router.get('/', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.id

    // 查询用户有权限的项目
    const [rows] = await pool.execute(
      `SELECT DISTINCT p.* FROM projects p
       LEFT JOIN project_permissions pp ON p.id = pp.project_id
       WHERE pp.user_id = ? OR p.creator_id = ?
       ORDER BY p.created_at DESC`,
      [userId, userId]
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
    const userId = req.user!.id

    // 检查用户是否有权限访问该项目
    const [permissionRows] = await pool.execute(
      `SELECT p.* FROM projects p
       LEFT JOIN project_permissions pp ON p.id = pp.project_id
       WHERE p.id = ? AND (pp.user_id = ? OR p.creator_id = ?)`,
      [id, userId, userId]
    )

    const projects = permissionRows as any[]
    if (projects.length === 0) {
      res.status(403).json({ error: 'No permission to access this project' })
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

    const connection = await pool.getConnection()
    try {
      await connection.beginTransaction()

      const [result] = await connection.execute(
        `INSERT INTO projects (name, status, type, amount, contract_period, customer, approval_amount, gross_margin, creator_id)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          name,
          status || '进行中',
          type || '运营类',
          amount || 0,
          contract_period,
          customer,
          approval_amount || 0,
          gross_margin || 0,
          req.user!.id
        ]
      )

      const projectId = (result as any).insertId

      // 为创建者添加管理权限
      await connection.execute(
        `INSERT INTO project_permissions (project_id, user_id, permission)
         VALUES (?, ?, ?)`,
        [projectId, req.user!.id, 'manage']
      )

      await connection.commit()

      res.status(201).json({
        id: projectId,
        name,
        status,
        type,
        amount,
        contract_period,
        customer,
        approval_amount,
        gross_margin,
        creator_id: req.user!.id
      })
    } catch (error) {
      await connection.rollback()
      throw error
    } finally {
      connection.release()
    }
  } catch (error) {
    console.error('Create project error:', error)
    res.status(500).json({ error: 'Failed to create project' })
  }
})

router.put('/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const userId = req.user!.id
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

    // 检查用户是否有管理权限
    const [permissionRows] = await pool.execute(
      `SELECT pp.permission FROM project_permissions pp
       WHERE pp.project_id = ? AND pp.user_id = ? AND pp.permission = 'manage'
       UNION
       SELECT 'manage' FROM projects p WHERE p.id = ? AND p.creator_id = ?`,
      [id, userId, id, userId]
    )

    if (permissionRows.length === 0) {
      res.status(403).json({ error: 'No permission to update this project' })
      return
    }

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
    const userId = req.user!.id

    // 检查用户是否有管理权限
    const [permissionRows] = await pool.execute(
      `SELECT pp.permission FROM project_permissions pp
       WHERE pp.project_id = ? AND pp.user_id = ? AND pp.permission = 'manage'
       UNION
       SELECT 'manage' FROM projects p WHERE p.id = ? AND p.creator_id = ?`,
      [id, userId, id, userId]
    )

    if (permissionRows.length === 0) {
      res.status(403).json({ error: 'No permission to delete this project' })
      return
    }

    await pool.execute('DELETE FROM projects WHERE id = ?', [id])
    res.json({ message: 'Project deleted' })
  } catch (error) {
    console.error('Delete project error:', error)
    res.status(500).json({ error: 'Failed to delete project' })
  }
})

// 项目权限相关端点
router.get('/:id/permissions', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const userId = req.user!.id

    // 检查用户是否有权限访问该项目
    const [projectRows] = await pool.execute(
      `SELECT 1 FROM projects p
       LEFT JOIN project_permissions pp ON p.id = pp.project_id
       WHERE p.id = ? AND (pp.user_id = ? OR p.creator_id = ?)`,
      [id, userId, userId]
    )

    if (projectRows.length === 0) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    const [rows] = await pool.execute(
      `SELECT pp.id, pp.user_id, u.name as user_name, u.account as user_account, pp.permission
       FROM project_permissions pp
       JOIN users u ON pp.user_id = u.id
       WHERE pp.project_id = ?
       ORDER BY u.name`,
      [id]
    )

    res.json(rows)
  } catch (error) {
    console.error('Get project permissions error:', error)
    res.status(500).json({ error: 'Failed to get project permissions' })
  }
})

router.post('/:id/permissions', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const userId = req.user!.id
    const { user_id, permission } = req.body

    // 检查用户是否有管理权限
    const [permissionRows] = await pool.execute(
      `SELECT pp.permission FROM project_permissions pp
       WHERE pp.project_id = ? AND pp.user_id = ? AND pp.permission = 'manage'
       UNION
       SELECT 'manage' FROM projects p WHERE p.id = ? AND p.creator_id = ?`,
      [id, userId, id, userId]
    )

    if (permissionRows.length === 0) {
      res.status(403).json({ error: 'No permission to manage project permissions' })
      return
    }

    if (!user_id || !permission) {
      res.status(400).json({ error: 'User ID and permission are required' })
      return
    }

    const [result] = await pool.execute(
      `INSERT INTO project_permissions (project_id, user_id, permission)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE permission = VALUES(permission)`,
      [id, user_id, permission]
    )

    res.json({
      id: (result as any).insertId,
      project_id: id,
      user_id,
      permission
    })
  } catch (error) {
    console.error('Add project permission error:', error)
    res.status(500).json({ error: 'Failed to add project permission' })
  }
})

router.delete('/:id/permissions/:userId', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id, userId } = req.params
    const currentUserId = req.user!.id

    // 检查用户是否有管理权限
    const [permissionRows] = await pool.execute(
      `SELECT pp.permission FROM project_permissions pp
       WHERE pp.project_id = ? AND pp.user_id = ? AND pp.permission = 'manage'
       UNION
       SELECT 'manage' FROM projects p WHERE p.id = ? AND p.creator_id = ?`,
      [id, currentUserId, id, currentUserId]
    )

    if (permissionRows.length === 0) {
      res.status(403).json({ error: 'No permission to manage project permissions' })
      return
    }

    await pool.execute(
      'DELETE FROM project_permissions WHERE project_id = ? AND user_id = ?',
      [id, userId]
    )

    res.json({ message: 'Permission deleted' })
  } catch (error) {
    console.error('Delete project permission error:', error)
    res.status(500).json({ error: 'Failed to delete project permission' })
  }
})

export default router
