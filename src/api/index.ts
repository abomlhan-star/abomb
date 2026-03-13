const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api'

interface RequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  body?: any
  headers?: Record<string, string>
}

class ApiService {
  private baseUrl: string

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl
  }

  private async request<T>(endpoint: string, options: RequestOptions = {}): Promise<T> {
    const { method = 'GET', body, headers = {} } = options

    const defaultHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      ...headers
    }

    const token = localStorage.getItem('token')
    if (token) {
      defaultHeaders['Authorization'] = `Bearer ${token}`
    }

    const currentProjectId = localStorage.getItem('current_project_id')
    if (currentProjectId) {
      defaultHeaders['X-Project-Id'] = currentProjectId
    }

    const config: RequestInit = {
      method,
      headers: defaultHeaders
    }

    if (body && method !== 'GET') {
      config.body = JSON.stringify(body)
    }

    const response = await fetch(`${this.baseUrl}${endpoint}`, config)

    if (!response.ok) {
      if (response.status === 401 && endpoint !== '/auth/refresh') {
        // Token过期，尝试刷新
        try {
          const refreshResponse = await authApi.refreshToken()
          // 保存新token和过期时间
          localStorage.setItem('token', refreshResponse.token)
          const expireTime = new Date()
          expireTime.setDate(expireTime.getDate() + 7)
          localStorage.setItem('tokenExpireTime', expireTime.getTime().toString())
          // 用新token重新请求
          defaultHeaders['Authorization'] = `Bearer ${refreshResponse.token}`
          const retryResponse = await fetch(`${this.baseUrl}${endpoint}`, {
            ...config,
            headers: defaultHeaders
          })
          if (!retryResponse.ok) {
            const error = await retryResponse.json().catch(() => ({ error: 'Unknown error' }))
            throw new Error(error.error || `HTTP error! status: ${retryResponse.status}`)
          }
          return retryResponse.json()
        } catch (refreshError) {
          // 刷新失败，跳转到登录页面
          localStorage.removeItem('token')
          localStorage.removeItem('tokenExpireTime')
          localStorage.removeItem('user')
          window.location.href = '/login'
          throw new Error('Token expired and refresh failed')
        }
      }
      const error = await response.json().catch(() => ({ error: 'Unknown error' }))
      throw new Error(error.error || `HTTP error! status: ${response.status}`)
    }

    return response.json()
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint)
  }

  async post<T>(endpoint: string, body?: any): Promise<T> {
    return this.request<T>(endpoint, { method: 'POST', body })
  }

  async put<T>(endpoint: string, body?: any): Promise<T> {
    return this.request<T>(endpoint, { method: 'PUT', body })
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' })
  }
}

export const api = new ApiService(API_BASE_URL)

export const authApi = {
  login: (credentials: { username: string; password: string }) =>
    api.post<{ token: string; user: any }>('/auth/login', credentials),

  getMe: () =>
    api.get<any>('/auth/me'),

  refreshToken: () =>
    api.post<{ token: string; user: any }>('/auth/refresh')
}

export const userApi = {
  getAll: () =>
    api.get<any[]>('/users'),

  create: (data: any) =>
    api.post<any>('/users', data),

  update: (id: number, data: any) =>
    api.put<any>(`/users/${id}`, data),

  delete: (id: number) =>
    api.delete(`/users/${id}`),

  resetPassword: (id: number, password: string) =>
    api.post(`/users/${id}/reset-password`, { password })
}

export const projectApi = {
  getAll: () =>
    api.get<any[]>('/projects'),

  getById: (id: number) =>
    api.get<any>(`/projects/${id}`),

  create: (data: any) =>
    api.post<any>('/projects', data),

  update: (id: number, data: any) =>
    api.put<any>(`/projects/${id}`, data),

  delete: (id: number) =>
    api.delete(`/projects/${id}`)
}

export const dataApi = {
  getContracts: () =>
    api.get<any[]>('/data/contracts'),

  createContract: (data: any) =>
    api.post<any>('/data/contracts', data),

  updateContract: (id: number, data: any) =>
    api.put<any>(`/data/contracts/${id}`, data),

  deleteContract: (id: number) =>
    api.delete(`/data/contracts/${id}`),

  getPersons: () =>
    api.get<any[]>('/data/persons'),

  createPerson: (data: any) =>
    api.post<any>('/data/persons', data),

  updatePerson: (id: number, data: any) =>
    api.put<any>(`/data/persons/${id}`, data),

  deletePerson: (id: number) =>
    api.delete(`/data/persons/${id}`),
  
  deleteAllPersons: () =>
    api.delete('/data/persons'),

  getOrders: () =>
    api.get<any[]>('/data/orders'),

  createOrder: (data: any) =>
    api.post<any>('/data/orders', data),

  deleteOrder: (id: number) =>
    api.delete(`/data/orders/${id}`),

  getSettlementLevels: () =>
    api.get<any[]>('/data/settlement-levels'),

  createSettlementLevel: (data: any) =>
    api.post<any>('/data/settlement-levels', data),

  updateSettlementLevel: (id: number, data: any) =>
    api.put<any>(`/data/settlement-levels/${id}`, data),

  deleteSettlementLevel: (id: number) =>
    api.delete(`/data/settlement-levels/${id}`),

  getMonthlyCosts: () =>
    api.get<any[]>('/data/monthly-costs'),

  createMonthlyCost: (data: any) =>
    api.post<any>('/data/monthly-costs', data),

  deleteMonthlyCost: (id: number) =>
    api.delete(`/data/monthly-costs/${id}`),

  getActualSettlements: () =>
    api.get<any[]>('/data/actual-settlements'),

  createActualSettlement: (data: any) =>
    api.post<any>('/data/actual-settlements', data),

  deleteActualSettlement: (id: number) =>
    api.delete(`/data/actual-settlements/${id}`),

  getPurchases: () =>
    api.get<any[]>('/data/purchases'),

  createPurchase: (data: any) =>
    api.post<any>('/data/purchases', data),

  deletePurchase: (id: number) =>
    api.delete(`/data/purchases/${id}`),

  getImportantItems: () =>
    api.get<any[]>('/data/important-items'),

  createImportantItem: (data: any) =>
    api.post<any>('/data/important-items', data),

  deleteImportantItem: (id: number) =>
    api.delete(`/data/important-items/${id}`),

  getApprovalConfig: () =>
    api.get<any>('/data/approval-config'),

  saveApprovalConfig: (data: any) =>
    api.post<any>('/data/approval-config', data),

  getSettlementPeriods: () =>
    api.get<any[]>('/data/settlement-periods'),

  createSettlementPeriod: (data: any) =>
    api.post<any>('/data/settlement-periods', data),

  deleteSettlementPeriod: (id: number) =>
    api.delete(`/data/settlement-periods/${id}`)
}

export default api
