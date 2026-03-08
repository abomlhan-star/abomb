import { Database, open } from 'sqlite3'
import path from 'path'

class SQLiteConnection {
  private db: Database | null = null
  private dbPath: string

  constructor() {
    this.dbPath = path.join(__dirname, '../../database.sqlite')
  }

  async connect(): Promise<Database> {
    if (!this.db) {
      this.db = await new Promise((resolve, reject) => {
        const db = new Database(this.dbPath, (err) => {
          if (err) {
            reject(err)
          } else {
            resolve(db)
          }
        })
      })
    }
    return this.db
  }

  async execute(sql: string, params?: any[]): Promise<any[]>
  async execute(sql: string, params?: any[]): Promise<any> {
    const db = await this.connect()
    return new Promise((resolve, reject) => {
      db.all(sql, params || [], (err, rows) => {
        if (err) {
          reject(err)
        } else {
          resolve(rows)
        }
      })
    })
  }

  async close(): Promise<void> {
    if (this.db) {
      await new Promise((resolve, reject) => {
        this.db!.close((err) => {
          if (err) {
            reject(err)
          } else {
            resolve(undefined)
          }
        })
      })
      this.db = null
    }
  }
}

export const sqlite = new SQLiteConnection()

export async function testConnection(): Promise<boolean> {
  try {
    const db = await sqlite.connect()
    console.log('✅ SQLite connection successful')
    return true
  } catch (error) {
    console.error('❌ SQLite connection failed:', error)
    return false
  }
}

export default sqlite
