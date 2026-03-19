import { Router, Response } from 'express'
import pool from '../database/connection'
import { authMiddleware, AuthRequest } from '../middleware/auth'

const router = Router()

// 清空所有项目数据的端点（无需认证）
router.delete('/projects/all', async (req: any, res: Response): Promise<void> => {
  try {
    // 由于外键约束和ON DELETE CASCADE，删除projects表中的所有记录会自动级联删除所有相关数据
    await pool.execute('DELETE FROM projects')
    res.json({ message: 'All projects and related data deleted successfully' })
  } catch (error) {
    console.error('Delete all projects error:', error)
    res.status(500).json({ error: 'Failed to delete all projects' })
  }
})

router.use(authMiddleware)

const getProjectId = (req: AuthRequest): number => {
  return parseInt(req.headers['x-project-id'] as string) || 1
}

// 检查用户是否有权限访问项目
const checkProjectPermission = async (projectId: number, userId: number): Promise<boolean> => {
  const [rows] = await pool.execute(
    `SELECT 1 FROM projects p
     LEFT JOIN project_permissions pp ON p.id = pp.project_id
     WHERE p.id = ? AND (pp.user_id = ? OR p.creator_id = ?)`,
    [projectId, userId, userId]
  )
  return Array.isArray(rows) && rows.length > 0
}

router.get('/contracts', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    const [rows] = await pool.execute(
      'SELECT * FROM contracts WHERE project_id = ? ORDER BY created_at DESC',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get contracts error:', error)
    res.status(500).json({ error: 'Failed to get contracts' })
  }
})

router.post('/contracts', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    const { type, name, code, amount, period, customer, attachment } = req.body

    const [result] = await pool.execute(
      `INSERT INTO contracts (project_id, type, name, code, amount, period, customer, attachment)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [projectId, type || 'main', name, code, amount || 0, period || null, customer || null, attachment || null]
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      type,
      name,
      code,
      amount,
      period,
      customer,
      attachment
    })
  } catch (error) {
    console.error('Create contract error:', error)
    res.status(500).json({ error: 'Failed to create contract' })
  }
})

router.put('/contracts/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    const { type, name, code, amount, period, customer, attachment } = req.body

    await pool.execute(
      `UPDATE contracts SET type = ?, name = ?, code = ?, amount = ?, period = ?, customer = ?, attachment = ? WHERE id = ?`,
      [type || 'main', name, code, amount || 0, period || null, customer || null, attachment || null, id]
    )

    res.json({ id, type, name, code, amount, period, customer, attachment })
  } catch (error) {
    console.error('Update contract error:', error)
    res.status(500).json({ error: 'Failed to update contract' })
  }
})

router.delete('/contracts/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    await pool.execute('DELETE FROM contracts WHERE id = ?', [id])
    res.json({ message: 'Contract deleted' })
  } catch (error) {
    console.error('Delete contract error:', error)
    res.status(500).json({ error: 'Failed to delete contract' })
  }
})

router.get('/persons', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    const [rows] = await pool.execute(
      'SELECT * FROM persons WHERE project_id = ? ORDER BY created_at DESC',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get persons error:', error)
    res.status(500).json({ error: 'Failed to get persons' })
  }
})

router.post('/persons', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    const {
      name,
      team,
      position,
      settlement_dept,
      contact,
      entry_date,
      exit_date,
      settlement_level,
      price_with_tax,
      price_without_tax,
      input_type,
      work_days
    } = req.body

    const [result] = await pool.execute(
      `INSERT INTO persons (project_id, name, team, position, settlement_dept, contact, entry_date, exit_date, settlement_level, price_with_tax, price_without_tax, input_type, work_days)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        projectId,
        name,
        team,
        position,
        settlement_dept,
        contact,
        entry_date || null,
        exit_date || null,
        settlement_level,
        price_with_tax || 0,
        price_without_tax || 0,
        input_type || 'actual',
        JSON.stringify(work_days || {})
      ]
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      name,
      team,
      position,
      settlement_dept,
      contact,
      entry_date,
      exit_date,
      settlement_level,
      price_with_tax,
      price_without_tax,
      input_type,
      work_days
    })
  } catch (error) {
    console.error('Create person error:', error)
    res.status(500).json({ error: 'Failed to create person' })
  }
})

router.put('/persons/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    const {
      name,
      team,
      position,
      settlement_dept,
      contact,
      entry_date,
      exit_date,
      settlement_level,
      price_with_tax,
      price_without_tax,
      input_type,
      work_days
    } = req.body

    await pool.execute(
      `UPDATE persons SET name = ?, team = ?, position = ?, settlement_dept = ?, contact = ?, entry_date = ?, exit_date = ?, settlement_level = ?, price_with_tax = ?, price_without_tax = ?, input_type = ?, work_days = ? WHERE id = ?`,
      [
        name,
        team,
        position,
        settlement_dept,
        contact,
        entry_date || null,
        exit_date || null,
        settlement_level,
        price_with_tax,
        price_without_tax,
        input_type,
        JSON.stringify(work_days || {}),
        id
      ]
    )

    res.json({
      id,
      name,
      team,
      position,
      settlement_dept,
      contact,
      entry_date,
      exit_date,
      settlement_level,
      price_with_tax,
      price_without_tax,
      input_type,
      work_days
    })
  } catch (error) {
    console.error('Update person error:', error)
    res.status(500).json({ error: 'Failed to update person' })
  }
})

router.delete('/persons/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    await pool.execute('DELETE FROM persons WHERE id = ?', [id])
    res.json({ message: 'Person deleted' })
  } catch (error) {
    console.error('Delete person error:', error)
    res.status(500).json({ error: 'Failed to delete person' })
  }
})

router.delete('/persons', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    await pool.execute('DELETE FROM persons WHERE project_id = ?', [projectId])
    res.json({ message: 'All persons deleted' })
  } catch (error) {
    console.error('Delete all persons error:', error)
    res.status(500).json({ error: 'Failed to delete all persons' })
  }
})

router.get('/orders', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    const [rows] = await pool.execute(
      'SELECT * FROM orders WHERE project_id = ? ORDER BY created_at DESC',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get orders error:', error)
    res.status(500).json({ error: 'Failed to get orders' })
  }
})

router.post('/orders', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    // 兼容前端发送的字段名 (start_date, end_date, order_date) 和 后端格式 (startDate, endDate, orderDate)
    const { code, startDate, endDate, orderDate, amount, attachment, start_date, end_date, order_date } = req.body
    
    // 确定使用的日期字段
    const sDate = startDate || start_date
    const eDate = endDate || end_date
    const oDate = orderDate || order_date
    
    // 将 startDate 和 endDate 合并为 period
    let period = ''
    if (sDate || eDate) {
      period = [sDate, eDate].filter(Boolean).join(' / ')
    }

    const [result] = await pool.execute(
      `INSERT INTO orders (project_id, code, period, order_date, amount, attachment)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [projectId, code, period || null, oDate || null, amount || 0, attachment || null]
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      code,
      period,
      orderDate: oDate,
      amount,
      attachment
    })
  } catch (error) {
    console.error('Create order error:', error)
    res.status(500).json({ error: 'Failed to create order' })
  }
})

router.put('/orders/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    // 兼容前端发送的字段名 (start_date, end_date, order_date) 和 后端格式 (startDate, endDate, orderDate)
    const { code, startDate, endDate, orderDate, amount, attachment, start_date, end_date, order_date } = req.body
    
    // 确定使用的日期字段
    const sDate = startDate || start_date
    const eDate = endDate || end_date
    const oDate = orderDate || order_date
    
    // 将 startDate 和 endDate 合并为 period
    let period = ''
    if (sDate || eDate) {
      period = [sDate, eDate].filter(Boolean).join(' / ')
    }

    await pool.execute(
      `UPDATE orders SET code = ?, period = ?, order_date = ?, amount = ?, attachment = ? WHERE id = ? AND project_id = ?`,
      [code, period || null, oDate || null, amount || 0, attachment || null, id, projectId]
    )

    res.json({
      id,
      project_id: projectId,
      code,
      period,
      orderDate: oDate,
      amount,
      attachment
    })
  } catch (error) {
    console.error('Update order error:', error)
    res.status(500).json({ error: 'Failed to update order' })
  }
})

router.delete('/orders/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const projectId = getProjectId(req)
    const userId = req.user!.id

    // 检查权限
    const hasPermission = await checkProjectPermission(projectId, userId)
    if (!hasPermission) {
      res.status(403).json({ error: 'No permission to access this project' })
      return
    }

    await pool.execute('DELETE FROM orders WHERE id = ?', [id])
    res.json({ message: 'Order deleted' })
  } catch (error) {
    console.error('Delete order error:', error)
    res.status(500).json({ error: 'Failed to delete order' })
  }
})

router.get('/settlement-levels', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const [rows] = await pool.execute(
      'SELECT * FROM settlement_levels WHERE project_id = ? ORDER BY price_with_tax DESC',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get settlement levels error:', error)
    res.status(500).json({ error: 'Failed to get settlement levels' })
  }
})

router.post('/settlement-levels', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const { name, price_with_tax, price_without_tax } = req.body

    console.log('创建结算等级:', { projectId, name, price_with_tax, price_without_tax, projectIdType: typeof projectId })

    if (!projectId) {
      res.status(400).json({ error: 'Invalid project ID' })
      return
    }

    if (!name) {
      res.status(400).json({ error: 'Name is required' })
      return
    }

    // 检查项目是否存在
    const [projectRows] = await pool.execute('SELECT id FROM projects WHERE id = ?', [projectId])
    if (!projectRows || (projectRows as any[]).length === 0) {
      res.status(400).json({ error: 'Project not found' })
      return
    }

    const [result] = await pool.execute(
      `INSERT INTO settlement_levels (project_id, name, price_with_tax, price_without_tax)
       VALUES (?, ?, ?, ?)`,
      [projectId, name, price_with_tax || 0, price_without_tax || 0]
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      name,
      price_with_tax,
      price_without_tax
    })
  } catch (error: any) {
    console.error('创建结算等级详细错误:', error)
    console.error('错误堆栈:', error.stack)
    res.status(500).json({ error: `Failed to create settlement level: ${error.message}` })
  }
})

router.put('/settlement-levels/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const { id } = req.params
    const { name, price_with_tax, price_without_tax } = req.body

    await pool.execute(
      `UPDATE settlement_levels SET name = ?, price_with_tax = ?, price_without_tax = ? WHERE id = ? AND project_id = ?`,
      [name, price_with_tax, price_without_tax, id, projectId]
    )

    res.json({ id, project_id: projectId, name, price_with_tax, price_without_tax })
  } catch (error) {
    console.error('Update settlement level error:', error)
    res.status(500).json({ error: 'Failed to update settlement level' })
  }
})

router.delete('/settlement-levels/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM settlement_levels WHERE id = ?', [id])
    res.json({ message: 'Settlement level deleted' })
  } catch (error) {
    console.error('Delete settlement level error:', error)
    res.status(500).json({ error: 'Failed to delete settlement level' })
  }
})

router.get('/monthly-costs', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)

    const [rows] = await pool.execute(
      'SELECT * FROM monthly_costs WHERE project_id = ? ORDER BY month DESC',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get monthly costs error:', error)
    res.status(500).json({ error: 'Failed to get monthly costs' })
  }
})

router.post('/monthly-costs', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const { month, direct_cost, operating_cost, shared_cost } = req.body

    const [result] = await pool.execute(
      `INSERT INTO monthly_costs (project_id, month, direct_cost, operating_cost, shared_cost)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE direct_cost = VALUES(direct_cost), operating_cost = VALUES(operating_cost), shared_cost = VALUES(shared_cost)`,
      [projectId, month, direct_cost || 0, operating_cost || 0, shared_cost || 0]
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      month,
      direct_cost,
      operating_cost,
      shared_cost
    })
  } catch (error) {
    console.error('Create monthly cost error:', error)
    res.status(500).json({ error: 'Failed to create monthly cost' })
  }
})

router.delete('/monthly-costs/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM monthly_costs WHERE id = ?', [id])
    res.json({ message: 'Monthly cost deleted' })
  } catch (error) {
    console.error('Delete monthly cost error:', error)
    res.status(500).json({ error: 'Failed to delete monthly cost' })
  }
})

router.get('/actual-settlements', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)

    const [rows] = await pool.execute(
      'SELECT * FROM actual_settlements WHERE project_id = ? ORDER BY period_start DESC',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get actual settlements error:', error)
    res.status(500).json({ error: 'Failed to get actual settlements' })
  }
})

router.post('/actual-settlements', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const { period_start, period_end, dept, amount_with_tax, amount_without_tax } = req.body

    const [result] = await pool.execute(
      `INSERT INTO actual_settlements (project_id, period_start, period_end, dept, amount_with_tax, amount_without_tax)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [projectId, period_start, period_end, dept, amount_with_tax || 0, amount_without_tax || 0]
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      period_start,
      period_end,
      dept,
      amount_with_tax,
      amount_without_tax
    })
  } catch (error) {
    console.error('Create actual settlement error:', error)
    res.status(500).json({ error: 'Failed to create actual settlement' })
  }
})

router.put('/actual-settlements/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const projectId = getProjectId(req)
    const { period_start, period_end, dept, amount_with_tax, amount_without_tax } = req.body

    await pool.execute(
      `UPDATE actual_settlements SET period_start = ?, period_end = ?, dept = ?, amount_with_tax = ?, amount_without_tax = ? WHERE id = ? AND project_id = ?`,
      [period_start, period_end, dept, amount_with_tax || 0, amount_without_tax || 0, id, projectId]
    )

    res.json({ 
      id, 
      project_id: projectId, 
      period_start, 
      period_end, 
      dept, 
      amount_with_tax, 
      amount_without_tax 
    })
  } catch (error) {
    console.error('Update actual settlement error:', error)
    res.status(500).json({ error: 'Failed to update actual settlement' })
  }
})

router.delete('/actual-settlements/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM actual_settlements WHERE id = ?', [id])
    res.json({ message: 'Actual settlement deleted' })
  } catch (error) {
    console.error('Delete actual settlement error:', error)
    res.status(500).json({ error: 'Failed to delete actual settlement' })
  }
})

router.get('/purchases', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)

    const [rows] = await pool.execute(
      'SELECT * FROM project_purchases WHERE project_id = ? ORDER BY purchase_time DESC',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get purchases error:', error)
    res.status(500).json({ error: 'Failed to get purchases' })
  }
})

router.post('/purchases', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const {
      matter,
      item,
      quantity,
      unit_price,
      total_price,
      settlement_ratio,
      purchase_dept,
      purchase_time,
      settlement_month,
      executor
    } = req.body

    const [result] = await pool.execute(
      `INSERT INTO project_purchases (project_id, matter, item, quantity, unit_price, total_price, settlement_ratio, purchase_dept, purchase_time, settlement_month, executor)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        projectId,
        matter,
        item,
        quantity || 1,
        unit_price || 0,
        total_price || 0,
        settlement_ratio || 1,
        purchase_dept,
        purchase_time,
        settlement_month,
        executor
      ]
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      matter,
      item,
      quantity,
      unit_price,
      total_price,
      settlement_ratio,
      purchase_dept,
      purchase_time,
      settlement_month,
      executor
    })
  } catch (error) {
    console.error('Create purchase error:', error)
    res.status(500).json({ error: 'Failed to create purchase' })
  }
})

router.put('/purchases/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const projectId = getProjectId(req)
    const {
      matter,
      item,
      quantity,
      unit_price,
      total_price,
      settlement_ratio,
      purchase_dept,
      purchase_time,
      settlement_month,
      executor
    } = req.body

    await pool.execute(
      `UPDATE project_purchases SET matter = ?, item = ?, quantity = ?, unit_price = ?, total_price = ?, settlement_ratio = ?, purchase_dept = ?, purchase_time = ?, settlement_month = ?, executor = ? WHERE id = ? AND project_id = ?`,
      [
        matter,
        item,
        quantity || 1,
        unit_price || 0,
        total_price || 0,
        settlement_ratio || 1,
        purchase_dept,
        purchase_time,
        settlement_month,
        executor,
        id,
        projectId
      ]
    )

    res.json({
      id,
      project_id: projectId,
      matter,
      item,
      quantity,
      unit_price,
      total_price,
      settlement_ratio,
      purchase_dept,
      purchase_time,
      settlement_month,
      executor
    })
  } catch (error) {
    console.error('Update purchase error:', error)
    res.status(500).json({ error: 'Failed to update purchase' })
  }
})

router.delete('/purchases/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM project_purchases WHERE id = ?', [id])
    res.json({ message: 'Purchase deleted' })
  } catch (error) {
    console.error('Delete purchase error:', error)
    res.status(500).json({ error: 'Failed to delete purchase' })
  }
})

router.get('/important-items', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)

    const [rows] = await pool.execute(
      'SELECT * FROM important_items WHERE project_id = ? ORDER BY date DESC',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get important items error:', error)
    res.status(500).json({ error: 'Failed to get important items' })
  }
})

router.post('/important-items', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const { title, date, color } = req.body

    const [result] = await pool.execute(
      `INSERT INTO important_items (project_id, title, date, color)
       VALUES (?, ?, ?, ?)`,
      [projectId, title, date, color || 'red']
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      title,
      date,
      color
    })
  } catch (error) {
    console.error('Create important item error:', error)
    res.status(500).json({ error: 'Failed to create important item' })
  }
})

router.delete('/important-items/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM important_items WHERE id = ?', [id])
    res.json({ message: 'Important item deleted' })
  } catch (error) {
    console.error('Delete important item error:', error)
    res.status(500).json({ error: 'Failed to delete important item' })
  }
})

router.get('/approval-config', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)

    const [rows] = await pool.execute(
      'SELECT * FROM approval_configs WHERE project_id = ?',
      [projectId]
    )

    const configs = rows as any[]
    res.json(configs.length > 0 ? configs[0] : null)
  } catch (error) {
    console.error('Get approval config error:', error)
    res.status(500).json({ error: 'Failed to get approval config' })
  }
})

router.post('/approval-config', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const { amount, gross_margin } = req.body

    await pool.execute(
      `INSERT INTO approval_configs (project_id, amount, gross_margin)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE amount = VALUES(amount), gross_margin = VALUES(gross_margin)`,
      [projectId, amount || 0, gross_margin || 0]
    )

    res.json({ project_id: projectId, amount, gross_margin })
  } catch (error) {
    console.error('Save approval config error:', error)
    res.status(500).json({ error: 'Failed to save approval config' })
  }
})

router.get('/settlement-periods', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)

    const [rows] = await pool.execute(
      'SELECT * FROM settlement_periods WHERE project_id = ? ORDER BY start_date',
      [projectId]
    )
    res.json(rows)
  } catch (error) {
    console.error('Get settlement periods error:', error)
    res.status(500).json({ error: 'Failed to get settlement periods' })
  }
})

router.post('/settlement-periods', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const projectId = getProjectId(req)
    const { start_date, end_date, assessment_date, payment_date } = req.body

    const [result] = await pool.execute(
      `INSERT INTO settlement_periods (project_id, start_date, end_date, assessment_date, payment_date)
       VALUES (?, ?, ?, ?, ?)`,
      [projectId, start_date || null, end_date || null, assessment_date || null, payment_date || null]
    )

    res.status(201).json({
      id: (result as any).insertId,
      project_id: projectId,
      start_date,
      end_date,
      assessment_date,
      payment_date
    })
  } catch (error) {
    console.error('Create settlement period error:', error)
    res.status(500).json({ error: 'Failed to create settlement period' })
  }
})

router.delete('/settlement-periods/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM settlement_periods WHERE id = ?', [id])
    res.json({ message: 'Settlement period deleted' })
  } catch (error) {
    console.error('Delete settlement period error:', error)
    res.status(500).json({ error: 'Failed to delete settlement period' })
  }
})

// Groups API
router.get('/groups', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM company_groups ORDER BY created_at DESC'
    )
    res.json(rows)
  } catch (error) {
    console.error('Get groups error:', error)
    res.status(500).json({ error: 'Failed to get groups' })
  }
})

router.post('/groups', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { name } = req.body

    const [result] = await pool.execute(
      `INSERT INTO company_groups (name)
       VALUES (?)`,
      [name]
    )

    res.status(201).json({
      id: (result as any).insertId,
      name
    })
  } catch (error) {
    console.error('Create group error:', error)
    res.status(500).json({ error: 'Failed to create group' })
  }
})

router.put('/groups/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const { name } = req.body

    await pool.execute(
      `UPDATE company_groups SET name = ? WHERE id = ?`,
      [name, id]
    )

    res.json({ id, name })
  } catch (error) {
    console.error('Update group error:', error)
    res.status(500).json({ error: 'Failed to update group' })
  }
})

router.delete('/groups/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM company_groups WHERE id = ?', [id])
    res.json({ message: 'Group deleted' })
  } catch (error) {
    console.error('Delete group error:', error)
    res.status(500).json({ error: 'Failed to delete group' })
  }
})

// Customers API
router.get('/customers', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.execute(
      'SELECT c.*, g.name as group_name FROM customers c LEFT JOIN company_groups g ON c.group_id = g.id ORDER BY c.created_at DESC'
    )
    res.json(rows)
  } catch (error) {
    console.error('Get customers error:', error)
    res.status(500).json({ error: 'Failed to get customers' })
  }
})

router.post('/customers', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { name, group_id } = req.body

    const [result] = await pool.execute(
      `INSERT INTO customers (name, group_id)
       VALUES (?, ?)`,
      [name, group_id]
    )

    res.status(201).json({
      id: (result as any).insertId,
      name,
      group_id
    })
  } catch (error) {
    console.error('Create customer error:', error)
    res.status(500).json({ error: 'Failed to create customer' })
  }
})

router.put('/customers/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params
    const { name, group_id } = req.body

    await pool.execute(
      `UPDATE customers SET name = ?, group_id = ? WHERE id = ?`,
      [name, group_id, id]
    )

    res.json({ id, name, group_id })
  } catch (error) {
    console.error('Update customer error:', error)
    res.status(500).json({ error: 'Failed to update customer' })
  }
})

router.delete('/customers/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params

    await pool.execute('DELETE FROM customers WHERE id = ?', [id])
    res.json({ message: 'Customer deleted' })
  } catch (error) {
    console.error('Delete customer error:', error)
    res.status(500).json({ error: 'Failed to delete customer' })
  }
})

export default router


