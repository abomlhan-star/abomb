const mysql = require('mysql2/promise');

async function checkUsers() {
  try {
    // 创建数据库连接
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '123456',
      database: 'chengyan_operation'
    });
    
    console.log('✅ 数据库连接成功');
    
    // 检查users表数据
    const [users] = await connection.execute(
      "SELECT id, account, name, role FROM users"
    );
    
    console.log('用户数据:');
    users.forEach(user => {
      console.log(`  ID: ${user.id}, 账号: ${user.account}, 姓名: ${user.name}, 角色: ${user.role}`);
    });
    
    await connection.end();
  } catch (error) {
    console.error('检查用户数据失败:', error);
  }
}

checkUsers();