import { testConnection } from './connection'
import { runMigrations, checkMigrationStatus } from './migrations'
import { runSeeders } from './seed'

async function main(): Promise<void> {
  console.log('🚀 Database Migration Tool\n')

  const connected = await testConnection()
  if (!connected) {
    process.exit(1)
  }

  const args = process.argv.slice(2)
  const command = args[0] || 'migrate'

  switch (command) {
    case 'status':
      await checkMigrationStatus()
      break
    case 'migrate':
      await runMigrations()
      break
    case 'seed':
      await runSeeders()
      break
    case 'fresh':
      console.log('⚠️ Fresh migration not implemented for safety')
      break
    default:
      console.log('Usage: tsx migrate.ts [status|migrate|seed|fresh]')
  }

  process.exit(0)
}

main().catch(console.error)
