<template>
  <div class="flex min-h-screen">
    <!-- 左侧边栏 -->
    <aside class="w-72 border-r border-slate-200 dark:border-slate-800 bg-card-light dark:bg-card-dark flex flex-col fixed h-full z-20">
      <div class="p-6">
        <h1 class="text-xl font-bold tracking-tight">成研运营系统</h1>
        <button 
          class="mt-6 w-full flex items-center justify-center gap-2 bg-primary hover:bg-blue-600 text-white py-2.5 px-4 rounded-lg font-medium transition-all shadow-sm"
          @click="showCreateProjectDialog = true"
        >
          <span class="material-symbols-outlined">add</span>
          新建项目
        </button>
      </div>
      
      <div class="px-4 mb-4">
        <div class="relative">
          <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400 text-sm">search</span>
          <input 
            v-model="searchQuery"
            class="w-full pl-10 pr-4 py-2 text-sm bg-slate-50 dark:bg-slate-900/50 border border-slate-200 dark:border-slate-800 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
            placeholder="搜索项目..."
            type="text"
          />
        </div>
      </div>
      
      <nav class="flex-1 px-3 space-y-1 overflow-y-auto">
        <a 
          v-for="project in projectList" 
          :key="project.id"
          :class="[
            'group flex flex-col p-3 rounded-xl transition-all border-l-4',
            currentProject?.id === project.id 
              ? 'bg-blue-50 dark:bg-blue-900/20 border-primary' 
              : 'hover:bg-slate-50 dark:hover:bg-slate-800/50 border-transparent'
          ]"
          href="#"
          @click.prevent="handleProjectClick(project)"
        >
          <div class="flex justify-between items-center mb-1">
            <span :class="[
              'font-medium transition-all',
              currentProject?.id === project.id ? 'font-semibold text-primary' : 'text-slate-700 dark:text-slate-300 group-hover:text-primary'
            ]">
              {{ project.label }}
            </span>
            <span class="px-2 py-0.5 text-[10px] bg-blue-100 dark:bg-blue-800 text-primary rounded-full">
              {{ project.status }}
            </span>
          </div>
          <span class="text-xs text-slate-500 dark:text-slate-400">
            {{ project.customer }}
          </span>
        </a>
      </nav>
      
      <div class="p-4 border-t border-slate-200 dark:border-slate-800">
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800/50 cursor-pointer transition-all">
          <div class="w-9 h-9 rounded-full bg-slate-200 dark:bg-slate-700 flex items-center justify-center text-primary font-bold text-sm">
            {{ username.substring(0, 2).toUpperCase() }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold truncate">{{ username }}</p>
            <p class="text-[10px] text-slate-500 truncate">admin@chengyan.com</p>
          </div>
          <span class="material-symbols-outlined text-slate-400" @click="handleLogout">settings</span>
        </div>
      </div>
    </aside>

    <!-- 右侧主内容区域 -->
    <main class="ml-72 flex-1 p-8 pb-20 space-y-8 max-w-[1600px]">
      <header class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div class="flex items-center gap-3">
          <h2 class="text-2xl font-bold tracking-tight">{{ currentProject?.label || '请选择项目' }}</h2>
          <span class="px-3 py-1 text-xs font-medium bg-blue-50 dark:bg-blue-900/30 text-primary rounded-full border border-blue-100 dark:border-blue-800">
            {{ currentProject?.status || '进行中' }}
          </span>
        </div>
        <div class="flex items-center gap-2 flex-wrap">
          <button class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm">
            <span class="material-symbols-outlined text-slate-400">settings</span> 结算配置
          </button>
          <button class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm">
            <span class="material-symbols-outlined text-slate-400">assignment</span> 立项配置
          </button>
          <button class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm">
            <span class="material-symbols-outlined text-slate-400">edit</span> 编辑
          </button>
          <button class="px-4 py-2 text-sm font-medium bg-orange-500 hover:bg-orange-600 text-white rounded-lg transition-all flex items-center gap-2 shadow-sm">
            <span class="material-symbols-outlined">check_circle</span> 结束项目
          </button>
          <button class="px-4 py-2 text-sm font-medium border border-red-200 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-all flex items-center gap-2">
            <span class="material-symbols-outlined">delete</span> 删除
          </button>
        </div>
      </header>

      <!-- 项目概览卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">项目类型</p>
          <h3 class="text-lg font-bold">{{ currentProject?.type || '运营类' }}</h3>
        </div>
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">合同金额</p>
          <h3 class="text-lg font-bold text-red-500">¥{{ currentProject?.amount || '5,000,000.00' }}</h3>
        </div>
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">合同周期</p>
          <h3 class="text-sm font-bold">{{ currentProject?.contractPeriod || '2026-01-01 ~ 12-31' }}</h3>
        </div>
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">客户名称</p>
          <h3 class="text-lg font-bold truncate">{{ currentProject?.customer || '成都研发中心' }}</h3>
        </div>
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">立项金额</p>
          <h3 class="text-lg font-bold text-red-500">¥{{ currentProject?.approvalAmount || '5,000,000.00' }}</h3>
        </div>
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">立项毛利率</p>
          <h3 class="text-lg font-bold">{{ currentProject?.grossMargin || '30.00' }}%</h3>
        </div>
      </div>

      <!-- 项目重要事项和财务数据分析 -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- 项目重要事项 -->
        <section class="lg:col-span-1">
          <div class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 h-full flex flex-col">
            <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
              <h3 class="font-bold flex items-center gap-2">
                <span class="material-symbols-outlined text-primary">flag</span> 项目重要事项
              </h3>
              <button class="text-xs font-medium text-primary hover:underline">添加</button>
            </div>
            <div class="flex-1 divide-y divide-slate-100 dark:divide-slate-800">
              <div class="px-6 py-4 flex items-center justify-between group">
                <div class="flex items-center gap-3">
                  <div class="w-1.5 h-1.5 rounded-full bg-red-400"></div>
                  <span class="text-sm font-medium text-slate-700 dark:text-slate-200">项目启动会议</span>
                </div>
                <span class="text-xs text-slate-400">2026-01-05</span>
              </div>
              <div class="px-6 py-4 flex items-center justify-between group">
                <div class="flex items-center gap-3">
                  <div class="w-1.5 h-1.5 rounded-full bg-red-400"></div>
                  <span class="text-sm font-medium text-slate-700 dark:text-slate-200">需求评审完成</span>
                </div>
                <span class="text-xs text-slate-400">2026-01-20</span>
              </div>
            </div>
          </div>
        </section>

        <!-- 财务数据分析 -->
        <section class="lg:col-span-2">
          <div class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden">
            <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
              <h3 class="font-bold flex items-center gap-2">
                <span class="material-symbols-outlined text-primary">analytics</span> 财务数据分析
              </h3>
            </div>
            <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-8">
              <div class="space-y-6">
                <div class="flex justify-between items-start">
                  <div>
                    <p class="text-xs font-medium text-slate-500 mb-1">当前毛利暂估</p>
                    <h4 class="text-2xl font-bold text-blue-600 dark:text-blue-400">¥ -501,415.09</h4>
                    <p class="text-[10px] text-slate-400 mt-1">项目整体累计结算金额 / 1.06 - 累计成本</p>
                  </div>
                  <div class="text-right">
                    <p class="text-xs font-medium text-slate-500 mb-1">当前毛利率暂估</p>
                    <h4 class="text-2xl font-bold text-green-500">-2126.00%</h4>
                  </div>
                </div>
                <div class="pt-4 border-t border-slate-100 dark:border-slate-800 flex justify-between items-start">
                  <div>
                    <p class="text-xs font-medium text-slate-500 mb-1">实际毛利</p>
                    <h4 class="text-xl font-bold text-blue-600 dark:text-blue-400">¥ 261,164.15</h4>
                  </div>
                  <div class="text-right">
                    <p class="text-xs font-medium text-slate-500 mb-1">实际毛利率</p>
                    <h4 class="text-xl font-bold text-green-500">33.22%</h4>
                  </div>
                </div>
              </div>
              <div class="bg-slate-50 dark:bg-slate-900/50 p-5 rounded-xl border border-slate-100 dark:border-slate-800">
                <p class="text-xs font-medium text-slate-500 mb-2">滚动毛利率暂估</p>
                <h4 class="text-3xl font-bold text-green-500 mb-3">-2126.00%</h4>
                <p class="text-[10px] text-slate-400 leading-relaxed">基于人员工时变化与月本数据预估。当前累计结算截止至：2026-02-28</p>
                <div class="mt-4 grid grid-cols-3 gap-2">
                  <div class="text-center">
                    <p class="text-[9px] text-slate-500 uppercase">应结算额</p>
                    <p class="text-xs font-bold text-blue-600">¥0.00</p>
                  </div>
                  <div class="text-center">
                    <p class="text-[9px] text-slate-500 uppercase">订单结算</p>
                    <p class="text-xs font-bold text-blue-600">¥0.00</p>
                  </div>
                  <div class="text-center">
                    <p class="text-[9px] text-slate-500 uppercase">毛利产出</p>
                    <p class="text-xs font-bold text-blue-600">¥0.00</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>

      <!-- 合同与订单管理 -->
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
          <div class="flex items-center gap-6">
            <h3 class="font-bold flex items-center gap-2">
              <span class="material-symbols-outlined text-primary">description</span> 合同与订单管理
            </h3>
            <div class="flex bg-slate-100 dark:bg-slate-800 p-1 rounded-lg">
              <button class="px-3 py-1 text-xs font-medium bg-white dark:bg-slate-700 shadow-sm rounded-md">主合同</button>
              <button class="px-3 py-1 text-xs font-medium text-slate-500 dark:text-slate-400 hover:text-slate-700">采购合同</button>
            </div>
          </div>
          <button class="px-3 py-1.5 text-xs font-medium bg-primary text-white rounded-lg flex items-center gap-1 shadow-sm">
            <span class="material-symbols-outlined text-sm">add</span> 添加合同
          </button>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/50 dark:bg-slate-900/30 text-slate-500 font-medium">
              <tr>
                <th class="px-6 py-3">合同名称</th>
                <th class="px-6 py-3">合同编号</th>
                <th class="px-6 py-3 text-right">合同金额</th>
                <th class="px-6 py-3">周期</th>
                <th class="px-6 py-3">状态</th>
                <th class="px-6 py-3 text-center">操作</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
              <tr v-for="(contract, index) in contracts" :key="index">
                <td class="px-6 py-4 font-medium">{{ contract.name }}</td>
                <td class="px-6 py-4 text-slate-500 uppercase text-xs">{{ contract.code }}</td>
                <td class="px-6 py-4 text-red-500 font-semibold text-right">{{ contract.amount }}</td>
                <td class="px-6 py-4 text-xs">{{ contract.period }}</td>
                <td class="px-6 py-4">
                  <span class="px-2 py-0.5 rounded-full bg-blue-50 text-blue-600 text-[10px] font-medium border border-blue-100">
                    {{ contract.status }}
                  </span>
                </td>
                <td class="px-6 py-4">
                  <div class="flex items-center justify-center gap-4">
                    <button class="text-primary hover:text-blue-700 transition-colors">
                      <span class="material-symbols-outlined">edit_square</span>
                    </button>
                    <button class="text-slate-400 hover:text-red-500 transition-colors">
                      <span class="material-symbols-outlined">delete</span>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </main>

    <!-- 新建项目对话框 -->
    <div v-if="showCreateProjectDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-md p-6">
        <h3 class="text-lg font-semibold mb-4">新建项目</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">项目名称</label>
            <input 
              v-model="newProject.name"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入项目名称"
              type="text"
            />
            <p v-if="errors.name" class="text-xs text-red-500 mt-1">{{ errors.name }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">合同周期</label>
            <input 
              v-model="newProject.contractPeriod"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="YYYY-MM-DD ~ YYYY-MM-DD"
              type="text"
            />
            <p v-if="errors.contractPeriod" class="text-xs text-red-500 mt-1">{{ errors.contractPeriod }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">客户名称</label>
            <input 
              v-model="newProject.customer"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入客户名称"
              type="text"
            />
            <p v-if="errors.customer" class="text-xs text-red-500 mt-1">{{ errors.customer }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">项目类型</label>
            <select 
              v-model="newProject.type"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
            >
              <option value="运营类">运营类</option>
              <option value="开发类">开发类</option>
              <option value="咨询类">咨询类</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">合同金额</label>
            <input 
              v-model="newProject.amount"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入合同金额"
              type="number"
            />
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-6">
          <button 
            class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
            @click="showCreateProjectDialog = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
            @click="createProject"
          >
            确定
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const username = ref('')
const searchQuery = ref('')
const showCreateProjectDialog = ref(false)

// 项目数据
const projectList = ref([
  {
    id: 1,
    label: '成研运营项目管理系统',
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
    status: '进行中',
    type: '服务类',
    amount: '3,000,000.00',
    contractPeriod: '2025-01-01 ~ 12-31',
    customer: '四川电信',
    approvalAmount: '3,000,000.00',
    grossMargin: '25.00'
  }
])

const currentProject = ref(projectList.value[0])

// 新建项目表单
const newProject = reactive({
  name: '',
  contractPeriod: '',
  customer: '',
  type: '运营类',
  amount: ''
})

const errors = reactive({
  name: '',
  contractPeriod: '',
  customer: ''
})

// 模拟数据
const contracts = ref([
  {
    name: '成研运营项目管理系统合同',
    code: 'CY2026001',
    amount: '¥5,000,000.00',
    period: '2026-01-01 / 12-31',
    status: '已生效'
  }
])

onMounted(() => {
  // 从localStorage获取用户信息
  const userStr = localStorage.getItem('user')
  if (userStr) {
    const user = JSON.parse(userStr)
    username.value = user.username || 'Admin User'
  } else {
    username.value = 'Admin User'
  }
})

const handleLogout = () => {
  // 清除localStorage中的token和用户信息
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  
  ElMessage.success('退出登录成功')
  router.push('/login')
}

const handleProjectClick = (project: any) => {
  currentProject.value = project
}

const createProject = () => {
  // 表单验证
  let isValid = true
  
  if (!newProject.name) {
    errors.name = '请输入项目名称'
    isValid = false
  } else {
    errors.name = ''
  }
  
  if (!newProject.contractPeriod) {
    errors.contractPeriod = '请输入合同周期'
    isValid = false
  } else {
    errors.contractPeriod = ''
  }
  
  if (!newProject.customer) {
    errors.customer = '请输入客户名称'
    isValid = false
  } else {
    errors.customer = ''
  }
  
  if (!isValid) return
  
  // 模拟创建项目
  const newProjectData = {
    id: projectList.value.length + 1,
    label: newProject.name,
    status: '进行中',
    type: newProject.type,
    amount: newProject.amount,
    contractPeriod: newProject.contractPeriod,
    customer: newProject.customer,
    approvalAmount: newProject.amount,
    grossMargin: '0.00'
  }
  
  projectList.value.push(newProjectData)
  showCreateProjectDialog.value = false
  
  // 重置表单
  Object.assign(newProject, {
    name: '',
    contractPeriod: '',
    customer: '',
    type: '运营类',
    amount: ''
  })
  
  ElMessage.success('项目创建成功')
}
</script>
