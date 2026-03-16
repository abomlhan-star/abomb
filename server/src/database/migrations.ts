import pool from './connection'

const migrations = [
  {
    version: '1.0.0',
    description: 'Initial schema - create all base tables',
    sql: `
      SET NAMES utf8mb4;
      SET FOREIGN_KEY_CHECKS = 0;

      CREATE TABLE IF NOT EXISTS schema_versions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        version VARCHAR(50) NOT NULL,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        description TEXT
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        account VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        role ENUM('admin', 'project_manager') DEFAULT 'project_manager',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_account (account),
        INDEX idx_email (email)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS projects (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(200) NOT NULL,
        status VARCHAR(50) DEFAULT '进行中',
        type VARCHAR(50) DEFAULT '运营类',
        amount DECIMAL(15, 2) DEFAULT 0,
        contract_period VARCHAR(100),
        customer VARCHAR(200),
        approval_amount DECIMAL(15, 2) DEFAULT 0,
        gross_margin DECIMAL(5, 2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_status (status),
        INDEX idx_customer (customer)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS contracts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        type ENUM('main', 'purchase') DEFAULT 'main',
        name VARCHAR(200) NOT NULL,
        code VARCHAR(100),
        amount DECIMAL(15, 2) DEFAULT 0,
        period VARCHAR(100),
        customer VARCHAR(200),
        attachment VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        INDEX idx_project (project_id),
        INDEX idx_type (type)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS persons (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        team VARCHAR(100),
        position VARCHAR(100),
        settlement_dept VARCHAR(100),
        contact VARCHAR(100),
        entry_date DATE,
        exit_date DATE,
        settlement_level VARCHAR(50),
        price_with_tax DECIMAL(10, 2) DEFAULT 0,
        price_without_tax DECIMAL(10, 2) DEFAULT 0,
        input_type ENUM('actual', 'virtual') DEFAULT 'actual',
        work_days JSON,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        INDEX idx_project (project_id),
        INDEX idx_name (name),
        INDEX idx_dept (settlement_dept)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        code VARCHAR(100),
        period VARCHAR(100),
        order_date DATE,
        attachment VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        INDEX idx_project (project_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS settlement_levels (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        price_with_tax DECIMAL(10, 2) DEFAULT 0,
        price_without_tax DECIMAL(10, 2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE INDEX idx_name (name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS monthly_costs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        month VARCHAR(20) NOT NULL,
        direct_cost DECIMAL(15, 2) DEFAULT 0,
        operating_cost DECIMAL(15, 2) DEFAULT 0,
        shared_cost DECIMAL(15, 2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE INDEX idx_project_month (project_id, month)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS actual_settlements (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        period_start DATE,
        period_end DATE,
        dept VARCHAR(100),
        amount_with_tax DECIMAL(15, 2) DEFAULT 0,
        amount_without_tax DECIMAL(15, 2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        INDEX idx_project (project_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS project_purchases (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        matter VARCHAR(200),
        item VARCHAR(200),
        quantity INT DEFAULT 1,
        unit_price DECIMAL(10, 2) DEFAULT 0,
        total_price DECIMAL(15, 2) DEFAULT 0,
        settlement_ratio DECIMAL(5, 2) DEFAULT 1,
        purchase_dept VARCHAR(100),
        purchase_time DATE,
        settlement_month VARCHAR(20),
        executor VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        INDEX idx_project (project_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS important_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        title VARCHAR(200) NOT NULL,
        date DATE,
        color VARCHAR(20) DEFAULT 'red',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        INDEX idx_project (project_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS approval_configs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        amount DECIMAL(15, 2) DEFAULT 0,
        gross_margin DECIMAL(5, 2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE INDEX idx_project (project_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS settlement_periods (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        start_date DATE,
        end_date DATE,
        assessment_date DATE,
        payment_date DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        INDEX idx_project (project_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      SET FOREIGN_KEY_CHECKS = 1;
    `
  },
  {
    version: '1.0.1',
    description: 'Add project user relation table',
    sql: `
      CREATE TABLE IF NOT EXISTS project_users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        user_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE INDEX idx_project_user (project_id, user_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `
  },
  {
    version: '1.0.2',
    description: 'Fix charset for existing tables',
    sql: `
      ALTER TABLE users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      ALTER TABLE projects CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      ALTER TABLE contracts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      ALTER TABLE persons CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      ALTER TABLE orders CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      ALTER TABLE settlement_levels CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      ALTER TABLE project_users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    `
  },
  {
    version: '1.0.3',
    description: 'Add project permissions table',
    sql: `
      CREATE TABLE IF NOT EXISTS project_permissions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id INT NOT NULL,
        user_id INT NOT NULL,
        permission ENUM('view', 'manage') DEFAULT 'view',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE INDEX idx_project_user (project_id, user_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      
      ALTER TABLE projects ADD COLUMN creator_id INT DEFAULT NULL;
      ALTER TABLE projects ADD FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL;
    `
  },
  {
    version: '1.0.4',
    description: 'Add employee_id field to persons table',
    sql: `
      ALTER TABLE persons ADD COLUMN employee_id VARCHAR(50) DEFAULT NULL;
      ALTER TABLE persons ADD INDEX idx_employee_id (employee_id);
    `
  },
  {
    version: '1.0.5',
    description: 'Add groups and customers tables',
    sql: `
      CREATE TABLE IF NOT EXISTS company_groups (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(200) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE INDEX idx_name (name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      CREATE TABLE IF NOT EXISTS customers (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(200) NOT NULL,
        group_id INT DEFAULT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (group_id) REFERENCES company_groups(id) ON DELETE SET NULL,
        UNIQUE INDEX idx_name (name),
        INDEX idx_group (group_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

      ALTER TABLE projects ADD COLUMN group_id INT DEFAULT NULL;
      ALTER TABLE projects ADD COLUMN customer_id INT DEFAULT NULL;
      ALTER TABLE projects ADD FOREIGN KEY (group_id) REFERENCES company_groups(id) ON DELETE SET NULL;
      ALTER TABLE projects ADD FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL;
      ALTER TABLE projects ADD INDEX idx_group (group_id);
      ALTER TABLE projects ADD INDEX idx_customer_id (customer_id);
    `
  }
]

async function getAppliedVersions(): Promise<string[]> {
  try {
    const [rows] = await pool.execute(
      'SELECT version FROM schema_versions ORDER BY id'
    )
    return (rows as any[]).map(row => row.version)
  } catch (error) {
    return []
  }
}

async function applyMigration(
  version: string,
  description: string,
  sql: string
): Promise<void> {
  const connection = await pool.getConnection()
  try {
    await connection.beginTransaction()

    const statements = sql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0)

    for (const statement of statements) {
      await connection.execute(statement)
    }

    await connection.execute(
      'INSERT INTO schema_versions (version, description) VALUES (?, ?)',
      [version, description]
    )

    await connection.commit()
    console.log(`✅ Migration ${version} applied: ${description}`)
  } catch (error) {
    await connection.rollback()
    throw error
  } finally {
    connection.release()
  }
}

export async function runMigrations(): Promise<void> {
  console.log('🔄 Starting database migrations...')

  const appliedVersions = await getAppliedVersions()
  console.log(`📋 Applied versions: ${appliedVersions.join(', ') || 'none'}`)

  for (const migration of migrations) {
    if (!appliedVersions.includes(migration.version)) {
      try {
        await applyMigration(migration.version, migration.description, migration.sql)
      } catch (error) {
        console.error(`❌ Migration ${migration.version} failed:`, error)
        throw error
      }
    } else {
      console.log(`⏭️ Migration ${migration.version} already applied`)
    }
  }

  console.log('✅ All migrations completed')
}

export async function checkMigrationStatus(): Promise<void> {
  const appliedVersions = await getAppliedVersions()
  console.log('\n📊 Migration Status:')
  console.log('─'.repeat(50))

  for (const migration of migrations) {
    const applied = appliedVersions.includes(migration.version)
    console.log(
      `${applied ? '✅' : '⏳'} ${migration.version}: ${migration.description}`
    )
  }

  console.log('─'.repeat(50))
}
