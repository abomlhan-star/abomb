const mysql = require('mysql2/promise');

async function checkPermissions() {
  try {
    // 创建数据库连接
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '123456',
      database: 'chengyan_operation'
    });
    
    console.log('✅ 数据库连接成功');
    
    // 获取用户数据
    const [users] = await connection.execute(
      "SELECT id, account, name FROM users"
    );
    
    console.log('用户数据:');
    users.forEach(user => {
      console.log(`  ID: ${user.id}, 账号: ${user.account}, 姓名: ${user.name}`);
    });
    
    // 获取项目数据
    const [projects] = await connection.execute(
      "SELECT id, name FROM projects"
    );
    
    console.log('\n项目数据:');
    projects.forEach(project => {
      console.log(`  ID: ${project.id}, 名称: ${project.name}`);
    });
    
    // 获取权限数据
    const [permissions] = await connection.execute(
      `SELECT pp.id, pp.project_id, p.name as project_name, pp.user_id, u.account as user_account, pp.permission
       FROM project_permissions pp
       JOIN projects p ON pp.project_id = p.id
       JOIN users u ON pp.user_id = u.id
       ORDER BY pp.project_id, pp.user_id`
    );
    
    console.log('\n权限数据:');
    if (permissions.length > 0) {
      permissions.forEach(perm => {
        console.log(`  项目: ${perm.project_name}, 用户: ${perm.user_account}, 权限: ${perm.permission}`);
      });
    } else {
      console.log('  没有权限数据');
    }
    
    await connection.end();
  } catch (error) {
    console.error('检查权限数据失败:', error);
  }
}

checkPermissions();