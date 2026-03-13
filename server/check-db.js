const mysql = require('mysql2/promise');

async function checkDatabase() {
  try {
    // 创建数据库连接
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '123456',
      database: 'chengyan_operation'
    });
    
    console.log('✅ 数据库连接成功');
    
    // 检查project_permissions表是否存在
    const [tables] = await connection.execute(
      "SHOW TABLES LIKE 'project_permissions'"
    );
    
    if (tables.length > 0) {
      console.log('✅ project_permissions表存在');
      
      // 检查表结构
      const [columns] = await connection.execute(
        "SHOW COLUMNS FROM project_permissions"
      );
      console.log('表结构:');
      columns.forEach(col => {
        console.log(`  ${col.Field}: ${col.Type} ${col.Null === 'YES' ? '(NULL)' : ''}`);
      });
      
      // 检查是否有数据
      const [data] = await connection.execute(
        "SELECT COUNT(*) as count FROM project_permissions"
      );
      console.log(`表中数据数量: ${data[0].count}`);
    } else {
      console.log('❌ project_permissions表不存在');
    }
    
    // 检查users表是否存在
    const [usersTables] = await connection.execute(
      "SHOW TABLES LIKE 'users'"
    );
    
    if (usersTables.length > 0) {
      console.log('✅ users表存在');
      
      // 检查是否有用户数据
      const [usersData] = await connection.execute(
        "SELECT COUNT(*) as count FROM users"
      );
      console.log(`用户数量: ${usersData[0].count}`);
    } else {
      console.log('❌ users表不存在');
    }
    
    await connection.end();
  } catch (error) {
    console.error('数据库检查失败:', error);
  }
}

checkDatabase();