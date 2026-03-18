const mysql = require('mysql2/promise');

async function updateTable() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'chengyan_operation',
    charset: 'utf8mb4'
  });

  try {
    console.log('开始更新 settlement_levels 表结构...');

    // 检查表结构
    const [columns] = await connection.execute('DESCRIBE settlement_levels');
    console.log('当前表结构:', columns.map(c => c.Field));

    // 检查是否有 project_id 字段
    const hasProjectId = columns.some(c => c.Field === 'project_id');

    if (!hasProjectId) {
      console.log('添加 project_id 字段...');
      await connection.execute(`
        ALTER TABLE settlement_levels
        ADD COLUMN project_id INT NOT NULL AFTER id,
        ADD FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        ADD INDEX idx_project (project_id),
        DROP INDEX idx_name,
        ADD UNIQUE INDEX idx_project_name (project_id, name)
      `);
      console.log('project_id 字段添加成功！');
    } else {
      console.log('project_id 字段已存在');
    }

    console.log('更新完成！');
  } catch (error) {
    console.error('更新失败:', error.message);
  } finally {
    await connection.end();
  }
}

updateTable();
