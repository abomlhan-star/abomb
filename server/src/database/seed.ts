import pool from './connection'
import bcrypt from 'bcryptjs'

async function seedUsers(): Promise<void> {
  const hashedPassword = await bcrypt.hash('richinfo@123', 10)

  const users = [
    {
      account: 'admin',
      password: hashedPassword,
      name: '系统管理员',
      email: 'admin@chengyan.com',
      role: 'admin'
    }
  ]

  for (const user of users) {
    await pool.execute(
      `INSERT INTO users (account, password, name, email, role)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE name = VALUES(name), email = VALUES(email)`,
      [user.account, user.password, user.name, user.email, user.role]
    )
  }

  console.log('✅ Users seeded')
}

async function seedSettlementLevels(): Promise<void> {
  const levels = [
    { name: '高级', price_with_tax: 1000, price_without_tax: 943.4 },
    { name: '中级', price_with_tax: 800, price_without_tax: 754.72 },
    { name: '初级', price_with_tax: 600, price_without_tax: 566.04 }
  ]

  for (const level of levels) {
    await pool.execute(
      `INSERT INTO settlement_levels (name, price_with_tax, price_without_tax)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE price_with_tax = VALUES(price_with_tax), price_without_tax = VALUES(price_without_tax)`,
      [level.name, level.price_with_tax, level.price_without_tax]
    )
  }

  console.log('✅ Settlement levels seeded')
}

async function seedDemoProject(): Promise<void> {
  const [existingProjects] = await pool.execute(
    'SELECT id FROM projects LIMIT 1'
  )

  if ((existingProjects as any[]).length > 0) {
    console.log('⏭️ Demo project already exists')
    return
  }

  const [result] = await pool.execute(
    `INSERT INTO projects (name, status, type, amount, contract_period, customer, approval_amount, gross_margin)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      '成研运营项目管理系统',
      '进行中',
      '运营类',
      5000000,
      '2026-01-01 ~ 2026-12-31',
      '成都研发中心',
      5000000,
      30.0
    ]
  )

  const projectId = (result as any).insertId

  await pool.execute(
    `INSERT INTO contracts (project_id, type, name, code, amount, period, customer)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      projectId,
      'main',
      '成研运营项目管理系统合同',
      'CY2026001',
      5000000,
      '2026-01-01 / 2026-12-31',
      '成都研发中心'
    ]
  )

  await pool.execute(
    `INSERT INTO important_items (project_id, title, date, color)
     VALUES (?, ?, ?, ?), (?, ?, ?, ?)`,
    [
      projectId, '项目启动会议', '2026-01-05', 'red',
      projectId, '需求评审完成', '2026-01-20', 'red'
    ]
  )

  await pool.execute(
    `INSERT INTO persons (project_id, name, team, position, settlement_dept, contact, entry_date, settlement_level, price_with_tax, price_without_tax, input_type)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      projectId,
      '张三',
      '开发组',
      '前端工程师',
      '技术部',
      '李四',
      '2026-01-01',
      '高级',
      1000,
      943.4,
      'actual'
    ]
  )

  console.log('✅ Demo project seeded')
}

export async function runSeeders(): Promise<void> {
  console.log('🔄 Starting database seeding...')

  await seedUsers()
  await seedSettlementLevels()
  await seedDemoProject()

  console.log('✅ All seeders completed')
}
