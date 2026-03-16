<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold text-slate-800 dark:text-white">集团管理</h2>
      <button 
        class="px-4 py-2 bg-primary hover:bg-blue-600 text-white rounded-lg transition-all flex items-center gap-2"
        @click="showAddDialog = true"
      >
        <el-icon><Plus /></el-icon>
        新增集团
      </button>
    </div>
    
    <div class="bg-white dark:bg-slate-800 rounded-lg shadow-sm border border-slate-200 dark:border-slate-700 overflow-hidden">
      <el-table :data="groups" border stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="集团名称" />
        <el-table-column label="操作" width="150" align="center">
          <template #default="{ row }">
            <div class="flex items-center justify-center gap-2">
              <el-button type="primary" link size="small" @click="editGroup(row)">
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-button type="danger" link size="small" @click="deleteGroup(row.id)">
                <el-icon><Delete /></el-icon>
                删除
              </el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </div>
    
    <!-- 新增/编辑集团对话框 -->
    <el-dialog
      v-model="showAddDialog"
      :title="editingGroup ? '编辑集团' : '新增集团'"
      width="500px"
    >
      <el-form :model="formData" label-width="80px">
        <el-form-item label="集团名称" required>
          <el-input v-model="formData.name" placeholder="请输入集团名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="saveGroup">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { dataApi } from '../../api'

const groups = ref([])
const showAddDialog = ref(false)
const editingGroup = ref(null)

const formData = reactive({
  name: ''
})

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
  editingGroup.value = null
}

const saveGroup = async () => {
  if (!formData.name) {
    ElMessage.warning('请输入集团名称')
    return
  }
  
  try {
    if (editingGroup.value) {
      // 编辑集团
      await dataApi.updateGroup(editingGroup.value.id, formData)
      ElMessage.success('集团更新成功')
    } else {
      // 新增集团
      await dataApi.createGroup(formData)
      ElMessage.success('集团创建成功')
    }
    showAddDialog.value = false
    resetForm()
    await loadGroups()
  } catch (error) {
    console.error('保存集团失败:', error)
    ElMessage.error('保存集团失败')
  }
}

const editGroup = (group) => {
  editingGroup.value = group
  formData.name = group.name
  showAddDialog.value = true
}

const deleteGroup = async (id) => {
  try {
    await dataApi.deleteGroup(id)
    ElMessage.success('集团删除成功')
    await loadGroups()
  } catch (error) {
    console.error('删除集团失败:', error)
    ElMessage.error('删除集团失败')
  }
}

onMounted(async () => {
  await loadGroups()
})
</script>

<style scoped>
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>