const mysql = require('mysql2/promise')

async function checkProjects() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '123456',
      database: 'chengyan_operation'
    })

    const [rows] = await connection.execute('SELECT id, name, customer FROM projects')
    console.log('项目列表:')
    console.table(rows)

    await connection.end()
  } catch (error) {
    console.error('查询失败:', error.message)
  }
}

checkProjects()
