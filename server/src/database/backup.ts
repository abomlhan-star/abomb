import { exec } from 'child_process'
import { promisify } from 'util'
import dotenv from 'dotenv'
import path from 'path'
import fs from 'fs'

dotenv.config()

const execAsync = promisify(exec)

const DB_HOST = process.env.DB_HOST || 'localhost'
const DB_PORT = process.env.DB_PORT || '3306'
const DB_USER = process.env.DB_USER || 'root'
const DB_PASSWORD = process.env.DB_PASSWORD || ''
const DB_NAME = process.env.DB_NAME || 'chengyan_operation'

const BACKUP_DIR = path.join(__dirname, '../../backups')

async function ensureBackupDir(): Promise<void> {
  if (!fs.existsSync(BACKUP_DIR)) {
    fs.mkdirSync(BACKUP_DIR, { recursive: true })
  }
}

export async function createBackup(): Promise<string> {
  await ensureBackupDir()

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
  const filename = `backup-${timestamp}.sql`
  const filepath = path.join(BACKUP_DIR, filename)

  const mysqldumpPath = 'mysqldump'
  const passwordPart = DB_PASSWORD ? `-p${DB_PASSWORD}` : ''

  const command = `${mysqldumpPath} -h${DB_HOST} -P${DB_PORT} -u${DB_USER} ${passwordPart} ${DB_NAME} > "${filepath}"`

  try {
    await execAsync(command, { shell: 'cmd.exe' })
    console.log(`✅ Backup created: ${filename}`)
    return filepath
  } catch (error) {
    console.error('❌ Backup failed:', error)
    throw error
  }
}

export async function restoreBackup(filename: string): Promise<void> {
  const filepath = path.join(BACKUP_DIR, filename)

  if (!fs.existsSync(filepath)) {
    throw new Error(`Backup file not found: ${filename}`)
  }

  const passwordPart = DB_PASSWORD ? `-p${DB_PASSWORD}` : ''
  const command = `mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} ${passwordPart} ${DB_NAME} < "${filepath}"`

  try {
    await execAsync(command, { shell: 'cmd.exe' })
    console.log(`✅ Backup restored: ${filename}`)
  } catch (error) {
    console.error('❌ Restore failed:', error)
    throw error
  }
}

export async function listBackups(): Promise<string[]> {
  await ensureBackupDir()

  const files = fs.readdirSync(BACKUP_DIR)
  return files.filter(f => f.endsWith('.sql')).sort().reverse()
}

async function main(): Promise<void> {
  const args = process.argv.slice(2)
  const command = args[0]

  switch (command) {
    case 'create':
      await createBackup()
      break
    case 'list':
      const backups = await listBackups()
      console.log('\n📋 Available backups:')
      backups.forEach((b, i) => console.log(`  ${i + 1}. ${b}`))
      break
    case 'restore':
      if (!args[1]) {
        console.log('Usage: tsx backup.ts restore <filename>')
        return
      }
      await restoreBackup(args[1])
      break
    default:
      console.log('Usage: tsx backup.ts [create|list|restore <filename>]')
  }
}

main().catch(console.error)
