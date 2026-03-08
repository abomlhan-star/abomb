export interface User {
  id: number
  account: string
  password: string
  name: string
  email: string
  role: 'admin' | 'project_manager'
  created_at: Date
  updated_at: Date
}

export interface Project {
  id: number
  name: string
  status: string
  type: string
  amount: number
  contract_period: string
  customer: string
  approval_amount: number
  gross_margin: number
  created_at: Date
  updated_at: Date
}

export interface Contract {
  id: number
  project_id: number
  type: 'main' | 'purchase'
  name: string
  code: string
  amount: number
  period: string
  customer: string
  attachment: string | null
  created_at: Date
  updated_at: Date
}

export interface Person {
  id: number
  project_id: number
  name: string
  team: string
  position: string
  settlement_dept: string
  contact: string
  entry_date: string
  exit_date: string | null
  settlement_level: string
  price_with_tax: number
  price_without_tax: number
  input_type: 'actual' | 'virtual'
  work_days: Record<string, number>
  created_at: Date
  updated_at: Date
}

export interface Order {
  id: number
  project_id: number
  code: string
  period: string
  order_date: string
  attachment: string | null
  created_at: Date
  updated_at: Date
}

export interface SettlementLevel {
  id: number
  name: string
  price_with_tax: number
  price_without_tax: number
  created_at: Date
  updated_at: Date
}

export interface MonthlyCost {
  id: number
  project_id: number
  month: string
  direct_cost: number
  operating_cost: number
  shared_cost: number
  created_at: Date
  updated_at: Date
}

export interface ActualSettlement {
  id: number
  project_id: number
  period_start: string
  period_end: string
  dept: string
  amount_with_tax: number
  amount_without_tax: number
  created_at: Date
  updated_at: Date
}

export interface ProjectPurchase {
  id: number
  project_id: number
  matter: string
  item: string
  quantity: number
  unit_price: number
  total_price: number
  settlement_ratio: number
  purchase_dept: string
  purchase_time: string
  settlement_month: string
  executor: string
  created_at: Date
  updated_at: Date
}

export interface ImportantItem {
  id: number
  project_id: number
  title: string
  date: string
  color: string
  created_at: Date
  updated_at: Date
}

export interface ApprovalConfig {
  id: number
  project_id: number
  amount: number
  gross_margin: number
  created_at: Date
  updated_at: Date
}

export interface SettlementPeriod {
  id: number
  project_id: number
  start_date: string
  end_date: string
  assessment_date: string
  payment_date: string
  created_at: Date
  updated_at: Date
}

export interface SchemaVersion {
  id: number
  version: string
  applied_at: Date
  description: string
}
