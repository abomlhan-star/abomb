import sqlite from './sqlite'

const migrations = [
  {
    version: '1.0.0',
    description: 'Initial schema - create all base tables',
    sql: `
      CREATE TABLE IF NOT EXISTS schema_versions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version TEXT NOT NULL,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        description TEXT
      );

      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        role TEXT DEFAULT 'project_manager',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        status TEXT DEFAULT '进行中',
        type TEXT DEFAULT '运营类',
        amount REAL DEFAULT 0,
        contract_period TEXT,
        customer TEXT,
        approval_amount REAL DEFAULT 0,
        gross_margin REAL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS contracts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        type TEXT DEFAULT 'main',
        name TEXT NOT NULL,
        code TEXT,
        amount REAL DEFAULT 0,
        period TEXT,
        customer TEXT,
        attachment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      );

      CREATE TABLE IF NOT EXISTS persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        team TEXT,
        position TEXT,
        settlement_dept TEXT,
        contact TEXT,
        entry_date TEXT,
        exit_date TEXT,
        settlement_level TEXT,
        price_with_tax REAL DEFAULT 0,
        price_without_tax REAL DEFAULT 0,
        input_type TEXT DEFAULT 'actual',
        work_days TEXT DEFAULT '{}',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      );

      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        code TEXT,
        period TEXT,
        order_date TEXT,
        attachment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      );

      CREATE TABLE IF NOT EXISTS settlement_levels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        price_with_tax REAL DEFAULT 0,
        price_without_tax REAL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS monthly_costs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        month TEXT NOT NULL,
        direct_cost REAL DEFAULT 0,
        operating_cost REAL DEFAULT 0,
        shared_cost REAL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE(project_id, month)
      );

      CREATE TABLE IF NOT EXISTS actual_settlements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        period_start TEXT,
        period_end TEXT,
        dept TEXT,
        amount_with_tax REAL DEFAULT 0,
        amount_without_tax REAL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      );

      CREATE TABLE IF NOT EXISTS project_purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        matter TEXT,
        item TEXT,
        quantity INTEGER DEFAULT 1,
        unit_price REAL DEFAULT 0,
        total_price REAL DEFAULT 0,
        settlement_ratio REAL DEFAULT 1,
        purchase_dept TEXT,
        purchase_time TEXT,
        settlement_month TEXT,
        executor TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      );

      CREATE TABLE IF NOT EXISTS important_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        date TEXT,
        color TEXT DEFAULT 'red',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      );

      CREATE TABLE IF NOT EXISTS approval_configs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        amount REAL DEFAULT 0,
        gross_margin REAL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE(project_id)
      );

      CREATE TABLE IF NOT EXISTS settlement_periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        start_date TEXT,
        end_date TEXT,
        assessment_date TEXT,
        payment_date TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      );

      CREATE TABLE IF NOT EXISTS project_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(project_id, user_id)
      );
    `
  }
]

async function getAppliedVersions(): Promise<string[]> {
  try {
    const rows = await sqlite.execute('SELECT version FROM schema_versions ORDER BY id') as any[]
    return rows.map(row => row.version)
  } catch (error) {
    return []
  }
}

async function applyMigration(
  version: string,
  description: string,
  sql: string
): Promise<void> {
  const statements = sql
    .split(';')
    .map(s => s.trim())
    .filter(s => s.length > 0)

  for (const statement of statements) {
    await sqlite.execute(statement)
  }

  await sqlite.execute(
    'INSERT INTO schema_versions (version, description) VALUES (?, ?)',
    [version, description]
  )

  console.log(`✅ Migration ${version} applied: ${description}`)
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
