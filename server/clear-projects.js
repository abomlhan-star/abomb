import mysql from 'mysql2/promise'
import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306'),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'chengyan_operation',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  charset: 'utf8mb4',
  namedPlaceholders: true
})

async function clearAllProjectData() {
  const connection = await pool.getConnection()
  try {
    console.log('开始清除所有项目数据...')

    await connection.execute('SET FOREIGN_KEY_CHECKS = 0')

    await connection.execute('TRUNCATE TABLE project_purchases')
    console.log('✅ 已清空 project_purchases 表')

    await connection.execute('TRUNCATE TABLE actual_settlements')
    console.log('✅ 已清空 actual_settlements 表')

    await connection.execute('TRUNCATE TABLE monthly_costs')
    console.log('✅ 已清空 monthly_costs 表')

    await connection.execute('TRUNCATE TABLE orders')
    console.log('✅ 已清空 orders 表')

    await connection.execute('TRUNCATE TABLE contracts')
    console.log('✅ 已清空 contracts 表')

    await connection.execute('TRUNCATE TABLE persons')
    console.log('✅ 已清空 persons 表')

    await connection.execute('TRUNCATE TABLE project_permissions')
    console.log('✅ 已清空 project_permissions 表')

    await connection.execute('TRUNCATE TABLE project_users')
    console.log('✅ 已清空 project_users 表')

    await connection.execute('TRUNCATE TABLE important_items')
    console.log('✅ 已清空 important_items 表')

    await connection.execute('TRUNCATE TABLE projects')
    console.log('✅ 已清空 projects 表')

    await connection.execute('SET FOREIGN_KEY_CHECKS = 1')

    console.log('\n🎉 所有项目数据已成功清除！')
    console.log('保留的数据表：users, settlement_levels, approval_configs, settlement_periods, company_groups, customers, schema_versions')

  } catch (error) {
    console.error('❌ 清除数据失败:', error)
    await connection.execute('SET FOREIGN_KEY_CHECKS = 1')
  } finally {
    connection.release()
    await pool.end()
  }
}

clearAllProjectData()
