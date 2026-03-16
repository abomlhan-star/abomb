<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold text-slate-800 dark:text-white">客户管理</h2>
      <button 
        class="px-4 py-2 bg-primary hover:bg-blue-600 text-white rounded-lg transition-all flex items-center gap-2"
        @click="showAddDialog = true"
      >
        <el-icon><Plus /></el-icon>
        新增客户
      </button>
    </div>
    
    <div class="bg-white dark:bg-slate-800 rounded-lg shadow-sm border border-slate-200 dark:border-slate-700 overflow-hidden">
      <el-table :data="customers" border stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="客户名称" />
        <el-table-column prop="group_name" label="所属集团" />
        <el-table-column label="操作" width="150" align="center">
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
    </div>
    
    <!-- 新增/编辑客户对话框 -->
    <el-dialog
      v-model="showAddDialog"
      :title="editingCustomer ? '编辑客户' : '新增客户'"
      width="500px"
    >
      <el-form :model="formData" label-width="80px">
        <el-form-item label="客户名称" required>
          <el-input v-model="formData.name" placeholder="请输入客户名称" />
        </el-form-item>
        <el-form-item label="所属集团">
          <el-select v-model="formData.group_id" placeholder="请选择所属集团">
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
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="saveCustomer">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { dataApi } from '../../api'

const customers = ref([])
const groups = ref([])
const showAddDialog = ref(false)
const editingCustomer = ref(null)

const formData = reactive({
  name: '',
  group_id: ''
})

const loadCustomers = async () => {
  try {
    const data = await dataApi.getCustomers()
    customers.value = data
  } catch (error) {
    console.error('加载客户数据失败:', error)
    ElMessage.error('加载客户数据失败')
  }
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

const resetForm = () => {
  formData.name = ''
  formData.group_id = ''
  editingCustomer.value = null
}

const saveCustomer = async () => {
  if (!formData.name) {
    ElMessage.warning('请输入客户名称')
    return
  }
  
  try {
    if (editingCustomer.value) {
      // 编辑客户
      await dataApi.updateCustomer(editingCustomer.value.id, formData)
      ElMessage.success('客户更新成功')
    } else {
      // 新增客户
      await dataApi.createCustomer(formData)
      ElMessage.success('客户创建成功')
    }
    showAddDialog.value = false
    resetForm()
    await loadCustomers()
  } catch (error) {
    console.error('保存客户失败:', error)
    ElMessage.error('保存客户失败')
  }
}

const editCustomer = (customer) => {
  editingCustomer.value = customer
  formData.name = customer.name
  formData.group_id = customer.group_id
  showAddDialog.value = true
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