const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function checkPassword() {
  try {
    // 创建数据库连接
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '123456',
      database: 'chengyan_operation'
    });
    
    console.log('✅ 数据库连接成功');
    
    // 检查users表数据，包括密码哈希
    const [users] = await connection.execute(
      "SELECT id, account, name, role, password FROM users"
    );
    
    console.log('用户数据:');
    users.forEach(user => {
      console.log(`  ID: ${user.id}, 账号: ${user.account}, 姓名: ${user.name}, 角色: ${user.role}`);
      console.log(`  密码哈希: ${user.password}`);
      
      // 测试密码是否为 '123456'
      const isPasswordCorrect = bcrypt.compareSync('123456', user.password);
      console.log(`  密码是否为 '123456': ${isPasswordCorrect}`);
      console.log('');
    });
    
    await connection.end();
  } catch (error) {
    console.error('检查密码数据失败:', error);
  }
}

checkPassword();