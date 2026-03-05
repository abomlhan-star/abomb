<template>
  <div class="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700">
    <!-- 页面标题 -->
    <div class="px-6 py-4 border-b border-slate-200 dark:border-slate-700 flex justify-between items-center">
      <h2 class="text-xl font-bold text-slate-800 dark:text-white">用户管理</h2>
      <button 
        class="bg-primary hover:bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-all"
        @click="showAddUserDialog = true"
      >
        <span class="material-symbols-outlined text-sm">add</span>
        新增用户
      </button>
    </div>
    
    <!-- 用户列表 -->
    <div class="p-6">
      <el-table
        :data="users"
        border
        stripe
        style="width: 100%"
      >
        <el-table-column
          prop="account"
          label="用户账号"
          min-width="150"
        />
        <el-table-column
          prop="name"
          label="姓名"
          min-width="120"
        />
        <el-table-column
          prop="email"
          label="邮箱"
          min-width="200"
        />
        <el-table-column
          prop="role"
          label="角色"
          min-width="120"
        >
          <template #default="{ row }">
            <el-tag :type="row.role === 'admin' ? 'danger' : 'primary'" size="small">
              {{ row.role === 'admin' ? '系统管理员' : '项目管理' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
          prop="createdAt"
          label="创建时间"
          min-width="180"
        />
        <el-table-column
          label="操作"
          width="280"
          fixed="right"
        >
          <template #default="{ row }">
            <div class="flex items-center gap-2">
              <el-button 
                link 
                type="primary" 
                size="small"
                @click="handleEdit(row)"
              >
                <span class="material-symbols-outlined text-sm mr-1">edit</span>
                编辑
              </el-button>
              <el-button 
                link 
                type="warning" 
                size="small"
                @click="handleResetPassword(row)"
              >
                <span class="material-symbols-outlined text-sm mr-1">lock_reset</span>
                重置密码
              </el-button>
              <el-button 
                link 
                type="danger" 
                size="small"
                @click="handleDelete(row)"
              >
                <span class="material-symbols-outlined text-sm mr-1">delete</span>
                删除
              </el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
  
  <!-- 新增/编辑用户对话框 -->
  <el-dialog
    v-model="showAddUserDialog"
    :title="isEditing ? '编辑用户' : '新增用户'"
    width="500px"
    destroy-on-close
  >
    <div class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">用户账号</label>
        <el-input
          v-model="userForm.account"
          placeholder="请输入用户账号"
          :disabled="isEditing"
        />
      </div>
      <div v-if="!isEditing">
        <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">密码</label>
        <el-input
          v-model="userForm.password"
          type="password"
          placeholder="请输入密码"
          show-password
        />
      </div>
      <div>
        <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">姓名</label>
        <el-input
          v-model="userForm.name"
          placeholder="请输入姓名"
        />
      </div>
      <div>
        <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">邮箱</label>
        <el-input
          v-model="userForm.email"
          placeholder="请输入邮箱"
        />
      </div>
      <div>
        <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">角色</label>
        <el-select v-model="userForm.role" placeholder="请选择角色" class="w-full">
          <el-option
            v-for="option in roleOptions"
            :key="option.value"
            :label="option.label"
            :value="option.value"
          />
        </el-select>
      </div>
    </div>
    <template #footer>
      <div class="flex justify-end gap-2">
        <el-button @click="showAddUserDialog = false">取消</el-button>
        <el-button type="primary" @click="saveUser">确定</el-button>
      </div>
    </template>
  </el-dialog>
  
  <!-- 重置密码对话框 -->
  <el-dialog
    v-model="showResetPasswordDialog"
    title="重置密码"
    width="400px"
  >
    <div class="space-y-4">
      <p class="text-sm text-slate-600 dark:text-slate-400">
        正在为 <span class="font-semibold text-slate-800 dark:text-white">{{ currentUser?.name }}</span> 重置密码
      </p>
      <div>
        <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">新密码</label>
        <el-input
          v-model="newPassword"
          type="password"
          placeholder="请输入新密码"
          show-password
        />
      </div>
    </div>
    <template #footer>
      <div class="flex justify-end gap-2">
        <el-button @click="showResetPasswordDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmResetPassword">确定</el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// 角色选项
const roleOptions = [
  { label: '系统管理员', value: 'admin' },
  { label: '项目管理', value: 'project_manager' }
]

// 用户数据
const users = ref([
  {
    id: 1,
    account: 'admin',
    name: '系统管理员',
    email: 'admin@chengyan.com',
    password: 'richinfo@123',
    role: 'admin',
    createdAt: '2026-03-04 10:00:00'
  }
])

// 对话框显示状态
const showAddUserDialog = ref(false)
const showResetPasswordDialog = ref(false)
const isEditing = ref(false)
const currentUser = ref<any>(null)
const newPassword = ref('')

// 用户表单
const userForm = reactive({
  id: 0,
  account: '',
  password: '',
  name: '',
  email: '',
  role: 'project_manager'
})

// 初始化
onMounted(() => {
  // 从localStorage加载用户数据
  const savedUsers = localStorage.getItem('system_users')
  if (savedUsers) {
    users.value = JSON.parse(savedUsers)
  } else {
    // 初始化默认用户
    saveUsersToStorage()
  }
})

// 保存用户数据到localStorage
const saveUsersToStorage = () => {
  localStorage.setItem('system_users', JSON.stringify(users.value))
}

// 保存用户
const saveUser = () => {
  // 表单验证
  if (!userForm.account) {
    ElMessage.error('请输入用户账号')
    return
  }
  if (!isEditing.value && !userForm.password) {
    ElMessage.error('请输入密码')
    return
  }
  if (!userForm.name) {
    ElMessage.error('请输入姓名')
    return
  }
  if (!userForm.email) {
    ElMessage.error('请输入邮箱')
    return
  }
  // 邮箱格式验证
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(userForm.email)) {
    ElMessage.error('请输入有效的邮箱地址')
    return
  }
  
  if (isEditing.value) {
    // 编辑用户
    const index = users.value.findIndex(u => u.id === userForm.id)
    if (index !== -1) {
      users.value[index] = {
        ...users.value[index],
        name: userForm.name,
        email: userForm.email,
        role: userForm.role
      }
      ElMessage.success('用户编辑成功')
    }
  } else {
    // 检查账号是否已存在
    if (users.value.some(u => u.account === userForm.account)) {
      ElMessage.error('用户账号已存在')
      return
    }
    // 检查邮箱是否已存在
    if (users.value.some(u => u.email === userForm.email)) {
      ElMessage.error('邮箱已被使用')
      return
    }
    
    // 新增用户
    const newUser = {
      id: Date.now(),
      account: userForm.account,
      password: userForm.password,
      name: userForm.name,
      email: userForm.email,
      role: userForm.role,
      createdAt: new Date().toLocaleString('zh-CN')
    }
    users.value.push(newUser)
    ElMessage.success('用户新增成功')
  }
  
  saveUsersToStorage()
  showAddUserDialog.value = false
  resetForm()
}

// 编辑用户
const handleEdit = (row: any) => {
  isEditing.value = true
  currentUser.value = row
  userForm.id = row.id
  userForm.account = row.account
  userForm.name = row.name
  userForm.email = row.email || ''
  userForm.role = row.role || 'project_manager'
  userForm.password = ''
  showAddUserDialog.value = true
}

// 删除用户
const handleDelete = (row: any) => {
  if (row.account === 'admin') {
    ElMessage.error('系统管理员账户不能删除')
    return
  }
  
  ElMessageBox.confirm(
    `确定要删除用户 "${row.name}" 吗？`,
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    const index = users.value.findIndex(u => u.id === row.id)
    if (index !== -1) {
      users.value.splice(index, 1)
      saveUsersToStorage()
      ElMessage.success('用户删除成功')
    }
  }).catch(() => {
    // 取消删除
  })
}

// 重置密码
const handleResetPassword = (row: any) => {
  currentUser.value = row
  newPassword.value = ''
  showResetPasswordDialog.value = true
}

// 确认重置密码
const confirmResetPassword = () => {
  if (!newPassword.value) {
    ElMessage.error('请输入新密码')
    return
  }
  
  const index = users.value.findIndex(u => u.id === currentUser.value.id)
  if (index !== -1) {
    users.value[index].password = newPassword.value
    saveUsersToStorage()
    ElMessage.success('密码重置成功')
    showResetPasswordDialog.value = false
    newPassword.value = ''
  }
}

// 重置表单
const resetForm = () => {
  userForm.id = 0
  userForm.account = ''
  userForm.password = ''
  userForm.name = ''
  userForm.email = ''
  userForm.role = 'project_manager'
  isEditing.value = false
  currentUser.value = null
}
</script>