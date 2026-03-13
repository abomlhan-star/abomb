const mysql = require('mysql2/promise');

// 数据库连接配置
const config = {
  host: 'localhost',
  user: 'root',
  password: '123456',
  database: 'chengyan_operation',
  port: 3306
};

async function checkPermissionsData() {
  let connection;
  try {
    connection = await mysql.createConnection(config);
    console.log('数据库连接成功');

    // 检查项目表
    console.log('\n=== 项目列表 ===');
    const [projects] = await connection.execute(
      `SELECT id, name, creator_id FROM projects ORDER BY id`
    );
    console.log('项目数量:', projects.length);
    projects.forEach(project => {
      console.log(`项目ID: ${project.id}, 名称: ${project.name}, 创建者ID: ${project.creator_id}`);
    });

    // 检查用户表
    console.log('\n=== 用户列表 ===');
    const [users] = await connection.execute(
      `SELECT id, account, name FROM users ORDER BY id`
    );
    console.log('用户数量:', users.length);
    users.forEach(user => {
      console.log(`用户ID: ${user.id}, 账号: ${user.account}, 姓名: ${user.name}`);
    });

    // 检查项目权限表
    console.log('\n=== 项目权限列表 ===');
    const [permissions] = await connection.execute(
      `SELECT pp.id, pp.project_id, p.name as project_name, pp.user_id, u.account as user_account, pp.permission
       FROM project_permissions pp
       JOIN projects p ON pp.project_id = p.id
       JOIN users u ON pp.user_id = u.id
       ORDER BY pp.project_id, pp.user_id`
    );
    console.log('权限数量:', permissions.length);
    permissions.forEach(permission => {
      console.log(`项目ID: ${permission.project_id}, 项目名称: ${permission.project_name}, 用户ID: ${permission.user_id}, 用户账号: ${permission.user_account}, 权限: ${permission.permission}`);
    });

    // 检查cs用户的权限
    console.log('\n=== cs用户的权限 ===');
    const [csPermissions] = await connection.execute(
      `SELECT pp.id, pp.project_id, p.name as project_name, pp.user_id, u.account as user_account, pp.permission
       FROM project_permissions pp
       JOIN projects p ON pp.project_id = p.id
       JOIN users u ON pp.user_id = u.id
       WHERE u.account = 'cs'
       ORDER BY pp.project_id`
    );
    console.log('cs用户的权限数量:', csPermissions.length);
    csPermissions.forEach(permission => {
      console.log(`项目ID: ${permission.project_id}, 项目名称: ${permission.project_name}, 权限: ${permission.permission}`);
    });

    // 检查项目创建者的权限
    console.log('\n=== 检查项目创建者是否有管理权限 ===');
    for (const project of projects) {
      const [creatorPermission] = await connection.execute(
        `SELECT * FROM project_permissions
         WHERE project_id = ? AND user_id = ? AND permission = 'manage'`,
        [project.id, project.creator_id]
      );
      if (creatorPermission.length === 0) {
        console.log(`警告: 项目 ${project.name} (ID: ${project.id}) 的创建者 ${project.creator_id} 没有管理权限`);
      } else {
        console.log(`项目 ${project.name} (ID: ${project.id}) 的创建者 ${project.creator_id} 有管理权限`);
      }
    }

  } catch (error) {
    console.error('检查数据时出错:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n数据库连接已关闭');
    }
  }
}

checkPermissionsData();