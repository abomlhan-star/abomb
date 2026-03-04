<template>
  <div class="home-container">
    <!-- 顶部导航栏 -->
    <header class="top-nav">
      <div class="nav-left">
        <h1 class="app-title">成研运营项目管理</h1>
      </div>
      <div class="nav-right">
        <span class="welcome-text">欢迎，{{ username }}</span>
        <el-button type="text" @click="handleLogout">退出登录</el-button>
      </div>
    </header>

    <!-- 主内容区域 -->
    <div class="main-content">
      <!-- 左侧边栏 - 项目列表 -->
      <aside class="sidebar">
        <div class="sidebar-header">
          <el-button type="primary" class="new-project-btn" @click="showCreateProjectDialog = true">
            <el-icon><Plus /></el-icon>
            新建项目
          </el-button>
        </div>
        
        <div class="search-box">
          <el-input
            v-model="searchQuery"
            placeholder="搜索项目..."
            prefix-icon="Search"
            class="search-input"
          ></el-input>
        </div>
        
        <nav class="project-list">
          <el-tree
            :data="projectList"
            :props="projectTreeProps"
            node-key="id"
            :default-expanded-keys="[defaultProjectId]"
            @node-click="handleProjectClick"
            class="project-tree"
          >
            <template #default="{ node, data }">
              <div class="project-node">
                <span>{{ node.label }}</span>
                <el-tag v-if="data.status" :type="getStatusType(data.status)" size="small" class="status-tag">
                  {{ data.status }}
                </el-tag>
              </div>
            </template>
          </el-tree>
        </nav>
      </aside>

      <!-- 右侧内容区域 -->
      <section class="content-area">
        <!-- 项目详情头部 -->
        <div class="project-header">
          <h2 class="project-title">{{ currentProject?.name || '请选择项目' }}</h2>
          <div class="project-actions">
            <el-button type="primary" plain>预算管理</el-button>
            <el-button type="primary" plain>项目配置</el-button>
            <el-button type="primary" plain>编辑</el-button>
            <el-button type="danger" plain>删除</el-button>
          </div>
        </div>

        <!-- 项目概览卡片 -->
        <div class="overview-cards">
          <el-card class="overview-card">
            <div class="card-content">
              <div class="card-label">项目类型</div>
              <div class="card-value">{{ currentProject?.type || '运营类' }}</div>
            </div>
          </el-card>
          <el-card class="overview-card">
            <div class="card-content">
              <div class="card-label">合同金额</div>
              <div class="card-value">¥{{ currentProject?.amount || '5,000,000.00' }}</div>
            </div>
          </el-card>
          <el-card class="overview-card">
            <div class="card-content">
              <div class="card-label">合同周期</div>
              <div class="card-value">{{ currentProject?.contractPeriod || '2026-01-01 ~ 12-31' }}</div>
            </div>
          </el-card>
          <el-card class="overview-card">
            <div class="card-content">
              <div class="card-label">客户名称</div>
              <div class="card-value">{{ currentProject?.customer || '成都研发中心' }}</div>
            </div>
          </el-card>
          <el-card class="overview-card">
            <div class="card-content">
              <div class="card-label">立项金额</div>
              <div class="card-value">¥{{ currentProject?.approvalAmount || '5,000,000.00' }}</div>
            </div>
          </el-card>
          <el-card class="overview-card">
            <div class="card-content">
              <div class="card-label">毛利率</div>
              <div class="card-value">{{ currentProject?.grossMargin || '30.00' }}%</div>
            </div>
          </el-card>
        </div>

        <!-- 项目详情标签页 -->
        <el-tabs class="project-tabs">
          <el-tab-pane label="项目重要事项">
            <div class="important-matters">
              <el-table :data="importantMatters" style="width: 100%">
                <el-table-column prop="title" label="事项" width="200" />
                <el-table-column prop="date" label="日期" />
              </el-table>
            </div>
          </el-tab-pane>
          <el-tab-pane label="财务数据分析">
            <div class="financial-analysis">
              <el-row :gutter="20">
                <el-col :span="8">
                  <el-card class="financial-card">
                    <div class="financial-title">当前毛利率</div>
                    <div class="financial-value negative">¥-501,415.09</div>
                    <div class="financial-change">-2126.00%</div>
                  </el-card>
                </el-col>
                <el-col :span="8">
                  <el-card class="financial-card">
                    <div class="financial-title">目标毛利率</div>
                    <div class="financial-value">¥-2126.00</div>
                  </el-card>
                </el-col>
                <el-col :span="8">
                  <el-card class="financial-card">
                    <div class="financial-title">实际毛利率</div>
                    <div class="financial-value positive">33.22%</div>
                  </el-card>
                </el-col>
              </el-row>
            </div>
          </el-tab-pane>
          <el-tab-pane label="合同与订单管理">
            <div class="contract-management">
              <div class="contract-tabs">
                <el-tabs>
                  <el-tab-pane label="合同">
                    <el-button type="primary" class="add-contract-btn">+ 添加合同</el-button>
                    <el-table :data="contracts" style="width: 100%">
                      <el-table-column prop="name" label="合同名称" width="200" />
                      <el-table-column prop="code" label="合同编号" />
                      <el-table-column prop="amount" label="合同金额" />
                      <el-table-column prop="period" label="期限" />
                      <el-table-column prop="status" label="状态" />
                      <el-table-column label="操作" width="120">
                        <template #default>
                          <el-button size="small" type="primary" plain>查看</el-button>
                        </template>
                      </el-table-column>
                    </el-table>
                  </el-tab-pane>
                  <el-tab-pane label="采购合同">
                    <!-- 采购合同内容 -->
                  </el-tab-pane>
                </el-tabs>
              </div>
            </div>
          </el-tab-pane>
          <el-tab-pane label="项目人员">
            <div class="project-personnel">
              <el-button type="primary" class="add-person-btn">+ 添加人员</el-button>
              <el-table :data="personnel" style="width: 100%">
                <el-table-column prop="name" label="人员姓名" />
                <el-table-column prop="department" label="所属部门" />
                <el-table-column prop="position" label="岗位职级" />
                <el-table-column prop="costType" label="结算类型" />
                <el-table-column prop="startDate" label="入场日期" />
                <el-table-column prop="endDate" label="离场日期" />
                <el-table-column prop="unitPrice" label="结算单价(日)" />
                <el-table-column prop="workload" label="工时系数" />
                <el-table-column prop="status" label="状态" />
                <el-table-column label="操作" width="120">
                  <template #default>
                    <el-button size="small" type="primary" plain>编辑</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </el-tab-pane>
          <el-tab-pane label="采购">
            <div class="procurement">
              <el-button type="primary" class="add-procurement-btn">+ 添加采购</el-button>
              <el-table :data="procurements" style="width: 100%">
                <el-table-column prop="item" label="采购事项" />
                <el-table-column prop="quantity" label="数量" />
                <el-table-column prop="totalCost" label="费用总价" />
                <el-table-column prop="usedCost" label="已使用资金" />
                <el-table-column prop="note" label="采购备注" />
                <el-table-column label="操作" width="120">
                  <template #default>
                    <el-button size="small" type="primary" plain>查看</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <div class="total-expense">
                <div class="total-label">Total Expenditure:</div>
                <div class="total-value">¥25,000.00</div>
              </div>
            </div>
          </el-tab-pane>
          <el-tab-pane label="部门结算预估(按月)">
            <div class="department-budget">
              <el-table :data="departmentBudgets" style="width: 100%">
                <el-table-column prop="month" label="月份" />
                <el-table-column prop="personnel" label="人员费用" />
                <el-table-column prop="totalDays" label="总人天" />
                <el-table-column prop="personnelCost" label="人员结算" />
                <el-table-column prop="procurementCost" label="采购结算" />
                <el-table-column prop="monthlyTotal" label="月度成本总额" />
              </el-table>
              <div class="department-total">
                <div class="total-label">部门成本 合计:</div>
                <div class="total-value">¥25,000.00</div>
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>
      </section>
    </div>

    <!-- 新建项目对话框 -->
    <el-dialog
      v-model="showCreateProjectDialog"
      title="新建项目"
      width="500px"
    >
      <el-form :model="newProject" :rules="projectRules" ref="projectFormRef">
        <el-form-item label="项目名称" prop="name">
          <el-input v-model="newProject.name" placeholder="请输入项目名称"></el-input>
        </el-form-item>
        <el-form-item label="合同周期" prop="contractPeriod">
          <el-date-picker
            v-model="newProject.contractPeriod"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 100%"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="客户名称" prop="customer">
          <el-input v-model="newProject.customer" placeholder="请输入客户名称"></el-input>
        </el-form-item>
        <el-form-item label="项目类型">
          <el-select v-model="newProject.type" placeholder="请选择项目类型">
            <el-option label="运营类" value="运营类"></el-option>
            <el-option label="开发类" value="开发类"></el-option>
            <el-option label="咨询类" value="咨询类"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="合同金额">
          <el-input v-model="newProject.amount" placeholder="请输入合同金额" type="number"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showCreateProjectDialog = false">取消</el-button>
          <el-button type="primary" @click="createProject">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Search, Setting } from '@element-plus/icons-vue'

const router = useRouter()
const username = ref('')
const searchQuery = ref('')
const showCreateProjectDialog = ref(false)
const projectFormRef = ref()

// 项目数据
const projectList = ref([
  {
    id: 1,
    label: '运营管理系统',
    status: '进行中',
    type: '运营类',
    amount: '5,000,000.00',
    contractPeriod: '2026-01-01 ~ 12-31',
    customer: '成都研发中心',
    approvalAmount: '5,000,000.00',
    grossMargin: '30.00'
  },
  {
    id: 2,
    label: '数据中心外包服务',
    status: '已完成',
    type: '服务类',
    amount: '3,000,000.00',
    contractPeriod: '2025-01-01 ~ 12-31',
    customer: '北京总部',
    approvalAmount: '3,000,000.00',
    grossMargin: '25.00'
  }
])

const defaultProjectId = ref(1)
const currentProject = ref(projectList.value[0])

// 项目树配置
const projectTreeProps = {
  label: 'label'
}

// 新建项目表单
const newProject = reactive({
  name: '',
  contractPeriod: null,
  customer: '',
  type: '运营类',
  amount: ''
})

const projectRules = {
  name: [
    { required: true, message: '请输入项目名称', trigger: 'blur' }
  ],
  contractPeriod: [
    { required: true, message: '请选择合同周期', trigger: 'change' }
  ],
  customer: [
    { required: true, message: '请输入客户名称', trigger: 'blur' }
  ]
}

// 模拟数据
const importantMatters = ref([
  { title: '项目启动会议', date: '2026-01-05' },
  { title: '需求评审', date: '2026-01-20' }
])

const contracts = ref([
  {
    name: '成研运营项目管理系统合同',
    code: 'CY20260001',
    amount: '¥5,000,000.00',
    period: '2026-01-01 ~ 12-31',
    status: '已生效'
  }
])

const personnel = ref([
  {
    name: '张明',
    department: '技术部/开发组',
    position: '前端开发(高级)',
    costType: '实报实销',
    startDate: '2026-01-01',
    endDate: '持续中',
    unitPrice: '¥800.00',
    workload: '1.0',
    status: '在职'
  },
  {
    name: '李四',
    department: '技术部/开发组',
    position: '后端开发(中级)',
    costType: '实报实销',
    startDate: '2026-01-15',
    endDate: '持续中',
    unitPrice: '¥600.00',
    workload: '1.0',
    status: '在职'
  },
  {
    name: '王丽',
    department: '设计部/设计组',
    position: 'UI设计(中级)',
    costType: '固定成本',
    startDate: '2026-02-01',
    endDate: '2026-12-31',
    unitPrice: '¥500.00',
    workload: '0.8',
    status: '在职'
  }
])

const procurements = ref([
  {
    item: '服务器采购(云服务端)',
    quantity: '2',
    totalCost: '¥20,000.00',
    usedCost: '¥0.00',
    note: '0.5核2G/万可扩展'
  },
  {
    item: '软件开发(开发工具包)',
    quantity: '5',
    totalCost: '¥5,000.00',
    usedCost: '¥5,000.00',
    note: '企业版/2年许可'
  }
])

const departmentBudgets = ref([
  {
    month: '2026-01',
    personnel: '新入职人员入职',
    totalDays: '0.00',
    personnelCost: '¥0.00',
    procurementCost: '¥20,000.00',
    monthlyTotal: '¥20,000.00'
  },
  {
    month: '2026-02',
    personnel: '新入职人员/总人数',
    totalDays: '0.00',
    personnelCost: '¥0.00',
    procurementCost: '¥5,000.00',
    monthlyTotal: '¥5,000.00'
  }
])

onMounted(() => {
  // 从localStorage获取用户信息
  const userStr = localStorage.getItem('user')
  if (userStr) {
    const user = JSON.parse(userStr)
    username.value = user.username
  }
})

const handleLogout = () => {
  // 清除localStorage中的token和用户信息
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  
  ElMessage.success('退出登录成功')
  router.push('/login')
}

const handleProjectClick = (data: any) => {
  currentProject.value = data
}

const getStatusType = (status: string) => {
  switch (status) {
    case '进行中': return 'success'
    case '已完成': return 'info'
    case '已暂停': return 'warning'
    case '已取消': return 'danger'
    default: return 'default'
  }
}

const createProject = async () => {
  if (!projectFormRef.value) return
  
  await projectFormRef.value.validate(async (valid: boolean) => {
    if (valid) {
      // 模拟创建项目
      const newProjectData = {
        id: projectList.value.length + 1,
        label: newProject.name,
        status: '进行中',
        type: newProject.type,
        amount: newProject.amount,
        contractPeriod: newProject.contractPeriod ? `${newProject.contractPeriod[0]} ~ ${newProject.contractPeriod[1]}` : '',
        customer: newProject.customer,
        approvalAmount: newProject.amount,
        grossMargin: '0.00'
      }
      
      projectList.value.push(newProjectData)
      showCreateProjectDialog.value = false
      
      // 重置表单
      Object.assign(newProject, {
        name: '',
        contractPeriod: null,
        customer: '',
        type: '运营类',
        amount: ''
      })
      
      ElMessage.success('项目创建成功')
    }
  })
}
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #f5f7fa;
}

/* 顶部导航栏 */
.top-nav {
  height: 60px;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  position: sticky;
  top: 0;
  z-index: 100;
}

.app-title {
  font-size: 18px;
  font-weight: bold;
  color: #1890ff;
  margin: 0;
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.welcome-text {
  font-size: 14px;
  color: #666;
}

/* 主内容区域 */
.main-content {
  flex: 1;
  display: flex;
  overflow: hidden;
}

/* 侧边栏 */
.sidebar {
  width: 280px;
  background-color: #fff;
  box-shadow: 2px 0 4px rgba(0, 0, 0, 0.1);
  height: calc(100vh - 60px);
  display: flex;
  flex-direction: column;
  padding: 20px;
  overflow-y: auto;
}

.sidebar-header {
  margin-bottom: 20px;
}

.new-project-btn {
  width: 100%;
}

.search-box {
  margin-bottom: 20px;
}

.search-input {
  width: 100%;
}

.project-list {
  flex: 1;
}

.project-tree {
  border: none;
}

.project-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.status-tag {
  margin-left: 10px;
}

/* 内容区域 */
.content-area {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background-color: #f5f7fa;
}

/* 项目详情头部 */
.project-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  background-color: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.project-title {
  font-size: 20px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.project-actions {
  display: flex;
  gap: 10px;
}

/* 概览卡片 */
.overview-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.overview-card {
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.card-content {
  text-align: center;
  padding: 16px 0;
}

.card-label {
  font-size: 14px;
  color: #666;
  margin-bottom: 8px;
}

.card-value {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

/* 项目标签页 */
.project-tabs {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* 重要事项 */
.important-matters {
  padding: 20px;
}

/* 财务分析 */
.financial-analysis {
  padding: 20px;
}

.financial-card {
  text-align: center;
}

.financial-title {
  font-size: 14px;
  color: #666;
  margin-bottom: 12px;
}

.financial-value {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 8px;
}

.financial-value.positive {
  color: #52c41a;
}

.financial-value.negative {
  color: #f5222d;
}

.financial-change {
  font-size: 14px;
  color: #f5222d;
}

/* 合同管理 */
.contract-management {
  padding: 20px;
}

.add-contract-btn {
  margin-bottom: 16px;
}

/* 项目人员 */
.project-personnel {
  padding: 20px;
}

.add-person-btn {
  margin-bottom: 16px;
}

/* 采购 */
.procurement {
  padding: 20px;
}

.add-procurement-btn {
  margin-bottom: 16px;
}

.total-expense {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #e8e8e8;
}

.total-label {
  font-weight: bold;
  margin-right: 10px;
}

.total-value {
  font-weight: bold;
  color: #f5222d;
}

/* 部门预算 */
.department-budget {
  padding: 20px;
}

.department-total {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #e8e8e8;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .sidebar {
    width: 240px;
  }
  
  .overview-cards {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  }
}

@media (max-width: 768px) {
  .main-content {
    flex-direction: column;
  }
  
  .sidebar {
    width: 100%;
    height: auto;
    max-height: 300px;
  }
  
  .project-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .project-actions {
    width: 100%;
    justify-content: space-between;
  }
  
  .overview-cards {
    grid-template-columns: 1fr;
  }
}
</style>
