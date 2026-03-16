<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold text-slate-800 dark:text-white">集团&客户管理</h2>
      <div class="flex gap-2">
        <button 
          class="px-4 py-2 bg-primary hover:bg-blue-600 text-white rounded-lg transition-all flex items-center gap-2"
          @click="showAddGroupDialog = true"
        >
          <el-icon><Plus /></el-icon>
          新增集团
        </button>
        <button 
          class="px-4 py-2 bg-green-500 hover:bg-green-600 text-white rounded-lg transition-all flex items-center gap-2"
          @click="showAddCustomerDialog = true"
        >
          <el-icon><Plus /></el-icon>
          新增客户
        </button>
      </div>
    </div>
    
    <!-- 集团和客户搜索 -->
    <div class="mb-6">
      <el-input 
        v-model="searchKeyword" 
        placeholder="搜索集团或客户名称" 
        prefix-icon="Search"
        @input="handleSearch"
      />
    </div>
    
    <!-- 集团列表 -->
    <div class="space-y-4">
      <div 
        v-for="group in filteredGroups" 
        :key="group.id"
        class="bg-white dark:bg-slate-800 rounded-lg shadow-sm border border-slate-200 dark:border-slate-700 overflow-hidden"
      >
        <!-- 集团信息 -->
        <div class="px-6 py-4 bg-slate-50 dark:bg-slate-900/50 flex justify-between items-center">
          <div class="flex items-center gap-4">
            <h3 class="text-lg font-semibold text-slate-800 dark:text-white">{{ group.name }}</h3>
            <span class="text-sm text-slate-500 dark:text-slate-400">{{ group.customerCount }} 个客户</span>
          </div>
          <div class="flex gap-2">
            <el-button type="primary" link size="small" @click="editGroup(group)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-button type="danger" link size="small" @click="deleteGroup(group.id)">
              <el-icon><Delete /></el-icon>
              删除
            </el-button>
          </div>
        </div>
        
        <!-- 客户列表 -->
        <div class="px-6 py-4">
          <el-table :data="getCustomersByGroup(group.id)" border stripe size="small">
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="name" label="客户名称" />
            <el-table-column label="操作" width="120" align="center">
              <template #default="{ row }">
                <div class="flex items-center justify-center gap-2">
                  <el-button type="primary" link size="small" @click="editCustomer(row)">
                    <el-icon><Edit /></el-icon>
                    编辑
                  </el-button>
                  <el-button type="danger" link size="small" @click="deleteCustomer(row.id)">
                    <el-icon><Delete /></el-icon>
                    删除
                  </el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>
          <div v-if="getCustomersByGroup(group.id).length === 0" class="text-center py-4 text-slate-500 dark:text-slate-400">
            暂无客户
          </div>
        </div>
      </div>
    </div>
    
    <!-- 新增/编辑集团对话框 -->
    <el-dialog
      v-model="showAddGroupDialog"
      :title="editingGroup ? '编辑集团' : '新增集团'"
      width="500px"
    >
      <el-form :model="groupForm" label-width="80px">
        <el-form-item label="集团名称" required>
          <el-input v-model="groupForm.name" placeholder="请输入集团名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddGroupDialog = false">取消</el-button>
          <el-button type="primary" @click="saveGroup">确定</el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- 新增/编辑客户对话框 -->
    <el-dialog
      v-model="showAddCustomerDialog"
      :title="editingCustomer ? '编辑客户' : '新增客户'"
      width="500px"
    >
      <el-form :model="customerForm" label-width="80px">
        <el-form-item label="客户名称" required>
          <el-input v-model="customerForm.name" placeholder="请输入客户名称" />
        </el-form-item>
        <el-form-item label="所属集团" required>
          <el-select v-model="customerForm.group_id" placeholder="请选择所属集团">
            <el-option 
              v-for="group in groups" 
              :key="group.id"
              :label="group.name"
              :value="group.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddCustomerDialog = false">取消</el-button>
          <el-button type="primary" @click="saveCustomer">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { dataApi } from '../../api'

const groups = ref([])
const customers = ref([])
const showAddGroupDialog = ref(false)
const showAddCustomerDialog = ref(false)
const editingGroup = ref(null)
const editingCustomer = ref(null)
const searchKeyword = ref('')

const groupForm = reactive({
  name: ''
})

const customerForm = reactive({
  name: '',
  group_id: ''
})

// 过滤后的集团列表
const filteredGroups = computed(() => {
  if (!searchKeyword.value) {
    return groups.value.map(group => ({
      ...group,
      customerCount: customers.value.filter(customer => customer.group_id === group.id).length
    }))
  }
  const keyword = searchKeyword.value.toLowerCase()
  return groups.value
    .filter(group => {
      // 检查集团名称是否包含关键词
      const groupMatch = group.name.toLowerCase().includes(keyword)
      // 检查该集团下是否有客户名称包含关键词
      const customerMatch = customers.value.some(customer => 
        customer.group_id === group.id && 
        customer.name.toLowerCase().includes(keyword)
      )
      return groupMatch || customerMatch
    })
    .map(group => ({
      ...group,
      customerCount: customers.value.filter(customer => customer.group_id === group.id).length
    }))
})

// 根据集团ID获取客户列表
const getCustomersByGroup = (groupId) => {
  let filteredCustomers = customers.value.filter(customer => customer.group_id === groupId)
  
  // 如果有搜索关键词，还需要过滤客户名称
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    filteredCustomers = filteredCustomers.filter(customer => 
      customer.name.toLowerCase().includes(keyword)
    )
  }
  
  return filteredCustomers
}

const loadGroups = async () => {
  try {
    const data = await dataApi.getGroups()
    groups.value = data
  } catch (error) {
    console.error('加载集团数据失败:', error)
    ElMessage.error('加载集团数据失败')
  }
}

const loadCustomers = async () => {
  try {
    const data = await dataApi.getCustomers()
    customers.value = data
  } catch (error) {
    console.error('加载客户数据失败:', error)
    ElMessage.error('加载客户数据失败')
  }
}

const resetGroupForm = () => {
  groupForm.name = ''
  editingGroup.value = null
}

const resetCustomerForm = () => {
  customerForm.name = ''
  customerForm.group_id = ''
  editingCustomer.value = null
}

const saveGroup = async () => {
  if (!groupForm.name) {
    ElMessage.warning('请输入集团名称')
    return
  }
  
  try {
    if (editingGroup.value) {
      // 编辑集团
      await dataApi.updateGroup(editingGroup.value.id, groupForm)
      ElMessage.success('集团更新成功')
    } else {
      // 新增集团
      await dataApi.createGroup(groupForm)
      ElMessage.success('集团创建成功')
    }
    showAddGroupDialog.value = false
    resetGroupForm()
    await loadGroups()
  } catch (error) {
    console.error('保存集团失败:', error)
    ElMessage.error('保存集团失败')
  }
}

const saveCustomer = async () => {
  if (!customerForm.name) {
    ElMessage.warning('请输入客户名称')
    return
  }
  
  if (!customerForm.group_id) {
    ElMessage.warning('请选择所属集团')
    return
  }
  
  try {
    if (editingCustomer.value) {
      // 编辑客户
      await dataApi.updateCustomer(editingCustomer.value.id, customerForm)
      ElMessage.success('客户更新成功')
    } else {
      // 新增客户
      await dataApi.createCustomer(customerForm)
      ElMessage.success('客户创建成功')
    }
    showAddCustomerDialog.value = false
    resetCustomerForm()
    await loadCustomers()
  } catch (error) {
    console.error('保存客户失败:', error)
    ElMessage.error('保存客户失败')
  }
}

const editGroup = (group) => {
  editingGroup.value = group
  groupForm.name = group.name
  showAddGroupDialog.value = true
}

const editCustomer = (customer) => {
  editingCustomer.value = customer
  customerForm.name = customer.name
  customerForm.group_id = customer.group_id
  showAddCustomerDialog.value = true
}

const deleteGroup = async (id) => {
  try {
    // 检查是否有客户关联到该集团
    const groupCustomers = customers.value.filter(customer => customer.group_id === id)
    if (groupCustomers.length > 0) {
      ElMessage.warning('该集团下有客户，无法删除')
      return
    }
    
    await dataApi.deleteGroup(id)
    ElMessage.success('集团删除成功')
    await loadGroups()
  } catch (error) {
    console.error('删除集团失败:', error)
    ElMessage.error('删除集团失败')
  }
}

const deleteCustomer = async (id) => {
  try {
    await dataApi.deleteCustomer(id)
    ElMessage.success('客户删除成功')
    await loadCustomers()
  } catch (error) {
    console.error('删除客户失败:', error)
    ElMessage.error('删除客户失败')
  }
}

const handleSearch = () => {
  // 搜索逻辑已在computed中实现
}

onMounted(async () => {
  await loadGroups()
  await loadCustomers()
})
</script>

<style scoped>
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>