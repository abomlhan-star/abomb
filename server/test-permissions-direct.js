const mysql = require('mysql2/promise');

async function testPermissionsDirect() {
  try {
    // 创建数据库连接
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '123456',
      database: 'chengyan_operation'
    });
    
    console.log('✅ 数据库连接成功');
    
    // 获取项目列表
    const [projects] = await connection.execute(
      "SELECT id, name FROM projects"
    );
    
    console.log(`✅ 获取到 ${projects.length} 个项目`);
    
    if (projects.length > 0) {
      const projectId = projects[0].id;
      console.log(`测试项目ID: ${projectId}`);
      
      // 直接测试SQL查询
      const [permissions] = await connection.execute(
        `SELECT pp.id, pp.user_id, u.name as user_name, u.account as user_account, pp.permission
         FROM project_permissions pp
         JOIN users u ON pp.user_id = u.id
         WHERE pp.project_id = ?
         ORDER BY u.name`,
        [projectId]
      );
      
      console.log('✅ 权限查询成功');
      console.log('权限数据:', permissions);
    } else {
      console.log('❌ 没有项目，无法测试权限');
    }
    
    await connection.end();
  } catch (error) {
    console.error('测试权限失败:', error);
  }
}

testPermissionsDirect();