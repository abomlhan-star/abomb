const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

async function createAdminUser() {
  const connection = await mysql.createConnection({
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '123456',
    database: 'chengyan_operation'
  });

  const hashedPassword = await bcrypt.hash('richinfo@123', 10);
  
  await connection.execute(
    `INSERT INTO users (account, password, name, email, role)
     VALUES (?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE password = VALUES(password)`,
    ['admin', hashedPassword, '系统管理员', 'admin@chengyan.com', 'admin']
  );

  console.log('✅ Admin user created');
  await connection.end();
}

createAdminUser().catch(console.error);
