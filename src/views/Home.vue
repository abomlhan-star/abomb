<template>
  <div class="home-container">
    <!-- 左侧边栏 -->
    <aside class="sidebar">
      <div class="p-6">
        <h1 class="text-xl font-bold tracking-tight">成研运营系统</h1>
        <button 
          class="mt-6 w-full flex items-center justify-center gap-2 bg-primary hover:bg-blue-600 text-white py-2.5 px-4 rounded-lg font-medium transition-all shadow-sm"
          @click="showCreateProjectDialog = true"
        >
          <el-icon><Plus /></el-icon>
          新建项目
        </button>
      </div>
      
      <div class="px-4 mb-4">
        <div class="relative">
          <input 
            v-model="searchQuery"
            class="w-full pl-10 pr-4 py-2 text-sm bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all shadow-sm"
            placeholder="搜索项目..."
            type="text"
          />
          <div class="absolute left-3 top-0 bottom-0 flex items-center pointer-events-none">
            <el-icon class="text-slate-400"><Search /></el-icon>
          </div>
        </div>
      </div>
      
      <nav class="flex-1 px-3 space-y-1 overflow-y-auto">
        <draggable v-model="sortedProjects" item-key="id" @end="onDragEnd" handle=".drag-handle" class="space-y-1">
          <template #item="{ element: project }">
            <a 
              :class="[
                'group flex flex-col p-3 rounded-xl transition-all border-l-4 relative',
                currentProject?.id === project.id 
                  ? 'bg-blue-50 dark:bg-blue-900/20 border-primary' 
                  : 'hover:bg-slate-50 dark:hover:bg-slate-800/50 border-transparent'
              ]"
              href="#"
              @click.prevent="handleProjectClick(project)"
            >
              <div class="drag-handle absolute left-1 top-1/2 -translate-y-1/2 cursor-grab active:cursor-grabbing text-slate-300 hover:text-slate-500 opacity-0 group-hover:opacity-100 transition-opacity">
                <el-icon><Rank /></el-icon>
              </div>
              <div class="flex justify-between items-start mb-1 ml-4">
                <span :class="[
                  'font-medium transition-all flex-1',
                  currentProject?.id === project.id ? 'font-semibold text-primary' : 'text-slate-700 dark:text-slate-300 group-hover:text-primary'
                ]">
                  {{ project.label }}
                </span>
                <span :class="[
                  'px-2 py-0.5 text-[10px] rounded-full flex-shrink-0',
                  project.status === '已结束' 
                    ? 'bg-slate-100 dark:bg-slate-700 text-slate-500 dark:text-slate-400' 
                    : 'bg-blue-100 dark:bg-blue-800 text-primary'
                ]">
                  {{ project.status }}
                </span>
              </div>
              <span class="text-xs text-slate-500 dark:text-slate-400 ml-4">
                {{ project.customer }}
              </span>
            </a>
          </template>
        </draggable>
      </nav>
      
      <div class="p-4 border-t border-slate-200 dark:border-slate-800">
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800/50 cursor-pointer transition-all">
          <div class="w-9 h-9 rounded-full bg-slate-200 dark:bg-slate-700 flex items-center justify-center text-primary font-bold text-sm">
            {{ userDisplayName.substring(0, 2).toUpperCase() }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold truncate">{{ userDisplayName }}</p>
            <p class="text-[10px] text-slate-500 truncate">{{ userEmail }}</p>
          </div>
          <el-dropdown trigger="click" placement="top-end">
            <el-icon class="text-slate-400 cursor-pointer hover:text-primary transition-colors"><Setting /></el-icon>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item v-if="isAdmin" @click="handleEnterManagement">
                  <el-icon class="text-sm mr-2"><Management /></el-icon>
                  进入管理
                </el-dropdown-item>
                <el-dropdown-item @click="handleChangePassword">
                  <el-icon class="text-sm mr-2"><Lock /></el-icon>
                  修改密码
                </el-dropdown-item>
                <el-dropdown-item :divided="isAdmin" @click="handleLogout">
                  <el-icon class="text-sm mr-2 text-red-500"><SwitchButton /></el-icon>
                  <span class="text-red-500">退出系统</span>
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </aside>

    <!-- 右侧主内容区域 -->
    <main class="main-content">
      <!-- 无项目时的缺省页面 -->
      <div v-if="projectList.length === 0 || !currentProject" class="flex flex-col items-center justify-center h-full min-h-[600px]">
        <div class="text-center">
          <div class="mb-8">
            <el-icon class="text-8xl text-slate-300 dark:text-slate-600"><FolderOpened /></el-icon>
          </div>
          <h2 class="text-2xl font-bold text-slate-600 dark:text-slate-400 mb-4">暂无项目</h2>
          <p class="text-slate-500 dark:text-slate-500 mb-8">请先创建一个项目开始使用系统</p>
          <button 
            class="px-6 py-3 bg-primary hover:bg-blue-600 text-white rounded-lg font-medium transition-all flex items-center gap-2 mx-auto shadow-lg"
            @click="showCreateProjectDialog = true"
          >
            <el-icon><Plus /></el-icon>
            新建项目
          </button>
        </div>
      </div>

      <!-- 有项目时显示项目详情 -->
      <template v-else>
      <header class="flex flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-3">
          <h2 class="text-2xl font-bold tracking-tight">{{ currentProject?.label || '请选择项目' }}</h2>
          <span :class="[
            'px-3 py-1 text-xs font-medium rounded-full border',
            currentProject?.status === '已结束'
              ? 'bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-400 border-slate-200 dark:border-slate-700'
              : 'bg-blue-50 dark:bg-blue-900/30 text-primary border-blue-100 dark:border-blue-800'
          ]">
            {{ currentProject?.status || '进行中' }}
          </span>
        </div>
        <div class="flex items-center gap-2 flex-wrap">
          <button v-if="hasManagePermission" class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm"
            @click="showSettlementConfigDialog = true">
            <el-icon class="text-slate-400"><Setting /></el-icon> 结算配置
          </button>
          <button v-if="hasManagePermission" class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm"
            @click="openApprovalConfigDialog">
            <el-icon class="text-slate-400"><Document /></el-icon> 立项配置
          </button>
          <button v-if="hasManagePermission" class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm"
            @click="handleEditProject">
            <el-icon class="text-slate-400"><Edit /></el-icon> 编辑
          </button>
          <button 
            v-if="hasManagePermission && currentProject?.status !== '已结束'"
            class="px-4 py-2 text-sm font-medium bg-orange-500 hover:bg-orange-600 text-white rounded-lg transition-all flex items-center gap-2 shadow-sm"
            @click="handleEndProject">
            <el-icon><Check /></el-icon> 结束项目
          </button>
          <button 
            v-if="hasManagePermission"
            class="px-4 py-2 text-sm font-medium border border-red-200 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-all flex items-center gap-2"
            @click="handleDeleteProject">
            <el-icon><Delete /></el-icon> 删除
          </button>
          <button 
            v-if="hasManagePermission"
            class="px-4 py-2 text-sm font-medium bg-blue-500 hover:bg-blue-600 text-white rounded-lg transition-all flex items-center gap-2 shadow-sm"
            @click="openProjectPermissionsDialog">
            <el-icon><Key /></el-icon> 项目权限
          </button>
        </div>
      </header>

      <!-- 项目概览卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 min-w-[1380px] max-w-[6000px] w-full mt-6 mb-6">
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
          <h3 class="text-sm font-bold">{{ formatContractPeriod(currentProject?.contractPeriod) }}</h3>
        </div>
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">客户名称</p>
          <h3 class="text-lg font-bold truncate">{{ currentProject?.customer || '成都研发中心' }}</h3>
        </div>
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">立项金额</p>
          <h3 class="text-lg font-bold text-red-500">¥{{ approvalConfig.amount || '' }}</h3>
        </div>
        <div class="bg-card-light dark:bg-card-dark p-5 rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
          <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">立项毛利率</p>
          <h3 class="text-lg font-bold">{{ approvalConfig.grossMargin || '' }}%</h3>
        </div>
      </div>

      <!-- 项目重要事项 -->
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 min-w-[1380px] max-w-[6000px] w-full">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><Warning /></el-icon> 项目重要事项
          </h3>
          <button v-if="hasManagePermission" class="text-xs font-medium text-primary hover:underline" @click="showAddImportantItemDialog = true">添加</button>
        </div>
        <div class="divide-y divide-slate-100 dark:divide-slate-800">
          <div 
            v-for="(item, index) in filteredImportantItems" 
            :key="index"
            class="px-6 py-4 flex items-center justify-between group"
          >
            <div class="flex items-center gap-3">
              <div 
                class="w-1.5 h-1.5 rounded-full"
                :class="{
                  'bg-red-400': item.color === 'red',
                  'bg-yellow-400': item.color === 'yellow',
                  'bg-green-400': item.color === 'green',
                  'bg-blue-400': item.color === 'blue'
                }"
              ></div>
              <span class="text-sm font-medium text-slate-700 dark:text-slate-200">{{ item.title }}</span>
            </div>
            <div class="flex items-center gap-3">
                <span class="text-xs text-slate-400">{{ item.date }}</span>
                <button v-if="hasManagePermission" class="text-primary hover:text-blue-700 transition-colors" @click="editImportantItem(index)">
                  <el-icon class="text-sm"><Edit /></el-icon>
                </button>
                <button v-if="hasManagePermission" class="text-slate-400 hover:text-red-500 transition-colors" @click="deleteImportantItem(index)">
                  <el-icon class="text-sm"><Delete /></el-icon>
                </button>
              </div>
          </div>
        </div>
      </section>

      <!-- 财务数据分析 -->
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden min-w-[1380px] max-w-[6000px] w-full">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><DataAnalysis /></el-icon> 财务数据分析
          </h3>
        </div>
        <div class="p-6 space-y-6">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-xs font-medium text-slate-500 mb-1">当前毛利暂估<span v-if="currentGrossProfitLatestMonth" class="text-slate-400 font-normal">（统计至{{ currentGrossProfitLatestMonth.split('-')[0] + '年' + parseInt(currentGrossProfitLatestMonth.split('-')[1]) + '月' }}）</span></p>
              <h4 class="text-2xl font-bold text-blue-600 dark:text-blue-400">¥ {{ formatNumber(currentGrossProfit) }}</h4>
              <p class="text-[10px] text-slate-400 mt-1">项目暂估不含税结算金额 - 项目累计成本</p>
            </div>
            <div class="text-right">
              <p class="text-xs font-medium text-slate-500 mb-1">当前毛利率暂估</p>
              <h4 class="text-2xl font-bold text-green-500">{{ formatNumber(currentGrossMarginRate) }}%</h4>
            </div>
          </div>
          <div class="pt-4 border-t border-slate-100 dark:border-slate-800 flex justify-between items-start">
            <div>
              <p class="text-xs font-medium text-slate-500 mb-1">实际毛利<span v-if="actualGrossProfitLatestMonth" class="text-slate-400 font-normal">（统计至{{ actualGrossProfitLatestMonth }}）</span></p>
              <h4 class="text-xl font-bold text-blue-600 dark:text-blue-400">¥ {{ formatNumber(actualGrossProfit) }}</h4>
              <p class="text-[10px] text-slate-400 mt-1">项目实际结算周期不含税金额 - 周期内月成本累计</p>
            </div>
            <div class="text-right">
              <p class="text-xs font-medium text-slate-500 mb-1">实际毛利率</p>
              <h4 class="text-xl font-bold text-green-500">{{ formatNumber(actualGrossMarginRate) }}%</h4>
            </div>
          </div>
          <div class="pt-4 border-t border-slate-100 dark:border-slate-800">
            <div class="flex flex-wrap gap-6">
              <div>
                <p class="text-xs font-medium text-slate-500 mb-1">应结算金额（按立项金额计算）</p>
                <p class="text-sm font-bold text-blue-600">¥{{ formatNumber(payableSettlement) }}</p>
              </div>
              <div>
                <p class="text-xs font-medium text-slate-500 mb-1">应结算金额（按照订单金额计算）</p>
                <p class="text-sm font-bold text-blue-600">¥{{ formatNumber(orderSettlement) }}</p>
              </div>
              <div>
                <p class="text-xs font-medium text-slate-500 mb-1">应该产生毛利</p>
                <p class="text-sm font-bold text-blue-600">¥{{ formatNumber(grossProfitOutput) }}</p>
              </div>
              <div>
                <p class="text-xs font-medium text-slate-500 mb-1">毛利差额</p>
                <p class="text-sm font-bold" :class="grossProfitDifference >= 0 ? 'text-green-600' : 'text-red-600'">¥{{ formatNumber(grossProfitDifference) }}</p>
              </div>
              <div>
                <p class="text-xs font-medium text-slate-500 mb-1">毛利率差额</p>
                <p class="text-sm font-bold" :class="grossMarginDifference >= 0 ? 'text-green-600' : 'text-red-600'">{{ formatNumber(grossMarginDifference) }}%</p>
              </div>
            </div>
          </div>
          <div class="pt-4 border-t border-slate-100 dark:border-slate-800">
            <div class="bg-slate-50 dark:bg-slate-900/50 p-5 rounded-xl border border-slate-100 dark:border-slate-800">
              <div class="flex justify-between items-start">
                <div>
                  <p class="text-xs font-medium text-slate-500 mb-2">滚动毛利率暂估</p>
                  <h4 class="text-3xl font-bold text-green-500 mb-3">{{ formatNumber(rollingGrossMarginRate) }}%</h4>
                  <p class="text-[10px] text-slate-400 leading-relaxed">预估到项目结束的整体毛利率。未录入成本的月份按已有月成本平均值预估。</p>
                </div>
                <div class="text-right">
                  <p class="text-xs font-medium text-slate-500 mb-2">项目结算率</p>
                  <h4 class="text-3xl font-bold text-blue-600 mb-3">{{ formatNumber(projectSettlementRate) }}%</h4>
                  <p class="text-[10px] text-slate-400 leading-relaxed">项目结算暂估金额 / 立项金额</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 合同管理 -->
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden min-w-[1380px] max-w-[6000px] w-full">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
          <div class="flex items-center gap-6">
            <h3 class="font-bold flex items-center gap-2">
              <el-icon class="text-primary"><Document /></el-icon> 合同管理
            </h3>
            <div class="flex bg-slate-100 dark:bg-slate-800 p-1 rounded-lg">
              <button 
                class="px-3 py-1 text-xs font-medium rounded-md transition-all"
                :class="currentContractType === 'main' ? 'bg-white dark:bg-slate-700 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'"
                @click="currentContractType = 'main'"
              >主合同</button>
              <button 
                class="px-3 py-1 text-xs font-medium rounded-md transition-all"
                :class="currentContractType === 'purchase' ? 'bg-white dark:bg-slate-700 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'"
                @click="currentContractType = 'purchase'"
              >采购合同</button>
            </div>
          </div>
          <button 
            v-if="hasManagePermission"
            class="px-3 py-1.5 text-xs font-medium bg-primary text-white rounded-lg flex items-center gap-1 shadow-sm"
            @click="openAddContractDialog"
            :disabled="currentContractType === 'main' && mainContractExists"
          >
            <el-icon class="text-sm"><Plus /></el-icon> 添加合同
          </button>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/50 dark:bg-slate-900/30 text-slate-500 font-medium">
              <tr>
                <th class="px-6 py-3">合同名称</th>
                <th class="px-6 py-3">合同编号</th>
                <th class="px-6 py-3 text-left">合同金额</th>
                <th class="px-6 py-3">周期</th>
                <th class="px-6 py-3">客户名称</th>
                <th class="px-6 py-3">附件</th>
                <th class="px-6 py-3 text-center">操作</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
              <tr v-for="(contract, index) in filteredContracts" :key="index">
                <td class="px-6 py-4 font-medium">{{ contract.name }}</td>
                <td class="px-6 py-4 text-slate-500 uppercase text-xs">{{ contract.code }}</td>
                <td class="px-6 py-4 text-red-500 font-semibold text-left">{{ contract.amount }}</td>
                <td class="px-6 py-4 text-xs">{{ contract.period }}</td>
                <td class="px-6 py-4">{{ contract.customer }}</td>
                <td class="px-6 py-4">
                  <button 
                    v-if="contract.attachment"
                    class="text-primary hover:text-blue-700 transition-colors flex items-center gap-1"
                    @click="downloadAttachment(contract.attachment)"
                  >
                    <el-icon class="text-sm"><Download /></el-icon>
                    <span class="text-xs">下载</span>
                  </button>
                  <span v-else class="text-slate-400 text-xs">无附件</span>
                </td>
                <td class="px-6 py-4">
                  <div class="flex items-center justify-center gap-4">
                    <button v-if="hasManagePermission" class="text-primary hover:text-blue-700 transition-colors" @click="editContract(contract)">
                      <el-icon><Edit /></el-icon>
                    </button>
                    <button v-if="hasManagePermission" class="text-slate-400 hover:text-red-500 transition-colors" @click="deleteContract(index)">
                      <el-icon><Delete /></el-icon>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- 订单管理 -->
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden min-w-[1380px] max-w-[6000px] w-full">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><Document /></el-icon> 订单管理
          </h3>
          <button 
            v-if="hasManagePermission"
            class="px-3 py-1.5 text-xs font-medium bg-primary text-white rounded-lg flex items-center gap-1 shadow-sm"
            @click="showAddOrderDialog = true"
          >
            <el-icon class="text-sm"><Plus /></el-icon> 新增订单
          </button>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/50 dark:bg-slate-900/30 text-slate-500 font-medium">
              <tr>
                <th class="px-6 py-3">订单编号</th>
                <th class="px-6 py-3">订单周期</th>
                <th class="px-6 py-3">订单时间</th>
                <th class="px-6 py-3">订单金额</th>
                <th class="px-6 py-3">附件</th>
                <th class="px-6 py-3 text-center">操作</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
              <tr v-for="(order, index) in filteredOrders" :key="index">
                <td class="px-6 py-4 text-slate-500 uppercase text-xs">{{ order.code }}</td>
                <td class="px-6 py-4 text-xs">{{ order.period }}</td>
                <td class="px-6 py-4 text-xs">{{ formatDate(order.orderDate) }}</td>
                <td class="px-6 py-4 text-xs font-medium text-slate-700 dark:text-slate-300">
                  {{ order.amount ? `¥${order.amount}` : '-' }}
                </td>
                <td class="px-6 py-4">
                  <div class="flex items-center gap-2">
                    <button 
                      v-if="order.attachment"
                      class="text-primary hover:text-blue-700 transition-colors flex items-center gap-1"
                      @click="previewOrderAttachment(order.attachment)"
                    >
                      <el-icon class="text-sm"><Document /></el-icon>
                      <span class="text-xs">预览</span>
                    </button>
                    <button 
                      v-if="order.attachment"
                      class="text-slate-600 hover:text-blue-700 transition-colors flex items-center gap-1"
                      @click="downloadOrderAttachment(order.attachment)"
                    >
                      <el-icon class="text-sm"><Download /></el-icon>
                      <span class="text-xs">下载</span>
                    </button>
                    <span v-else class="text-slate-400 text-xs">无附件</span>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <div class="flex items-center justify-center gap-4">
                    <button v-if="hasManagePermission" class="text-primary hover:text-blue-700 transition-colors" @click="editOrder(order)">
                      <el-icon><Edit /></el-icon>
                    </button>
                    <button v-if="hasManagePermission" class="text-slate-400 hover:text-red-500 transition-colors" @click="deleteOrder(index)">
                      <el-icon><Delete /></el-icon>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- 人员管理 -->
      <section 
        ref="fullscreenRef"
        :class="[
          'bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 min-w-[1380px] max-w-[6000px] w-full',
          isFullscreen ? 'css-fullscreen' : 'overflow-hidden'
        ]"
      >
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><UserFilled /></el-icon> 项目人员管理
          </h3>
          <div class="flex flex-wrap items-center gap-3">
            <div class="relative">
              <input 
                v-model="personSearchQuery"
                class="pl-9 pr-4 py-1.5 text-xs bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all shadow-sm w-48 md:w-64"
                placeholder="搜索人员/岗位..."
                type="text"
              />
              <div class="absolute left-3 top-0 bottom-0 flex items-center pointer-events-none">
                <el-icon class="text-slate-400 text-sm"><Search /></el-icon>
              </div>
            </div>
            <button 
              class="border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-700 dark:text-slate-300 hover:text-slate-900 dark:hover:text-slate-100 px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
              :class="showAdvancedFilter ? 'bg-primary text-white border-primary hover:bg-blue-600' : ''"
              @click="showAdvancedFilter = !showAdvancedFilter"
            >
              <el-icon><Filter /></el-icon>
              高级筛选
            </button>
            <div class="flex bg-slate-100 dark:bg-slate-800 p-1 rounded-lg">
              <button 
                class="px-3 py-1 text-xs font-medium rounded-md transition-all"
                :class="showTaxPrice ? 'bg-white dark:bg-slate-700 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'"
                @click="showTaxPrice = true"
              >含税单价</button>
              <button 
                class="px-3 py-1 text-xs font-medium rounded-md transition-all"
                :class="!showTaxPrice ? 'bg-white dark:bg-slate-700 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'"
                @click="showTaxPrice = false"
              >不含税单价</button>
            </div>
            <button 
              class="border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-700 dark:text-slate-300 px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
              @click="toggleFullscreen"
            >
              <el-icon v-if="!isFullscreen" class="text-[16px]"><FullScreen /></el-icon>
              <el-icon v-else class="text-[16px]"><SwitchButton /></el-icon>
              {{ isFullscreen ? '退出全屏' : '全屏' }}
            </button>
            <button 
              v-if="hasManagePermission"
              class="border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-700 dark:text-slate-300 px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
              @click="downloadPersonList"
            >
              <el-icon class="text-[16px]"><Download /></el-icon> 下载
            </button>
            <button 
              v-if="hasManagePermission"
              class="bg-green-500 hover:bg-green-600 text-white px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
              @click="showExcelImportDialog = true"
            >
              <el-icon class="text-[16px]"><Upload /></el-icon> Excel导入
            </button>
            <button 
              v-if="hasManagePermission"
              class="bg-primary hover:bg-blue-600 text-white px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
              @click="showAddPersonDialog = true"
            >
              <el-icon class="text-[16px]"><Plus /></el-icon> 添加人员
            </button>
            <button 
              v-if="hasManagePermission"
              class="border border-red-200 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
              @click="confirmClearPersons"
            >
              <el-icon class="text-[16px]"><Delete /></el-icon> 一键清空
            </button>
          </div>
        </div>
        
        <!-- 高级筛选面板 -->
        <div v-if="showAdvancedFilter" class="px-6 py-4 bg-slate-50/80 dark:bg-slate-800/30 border-b border-slate-200/60 dark:border-slate-700">
          <div class="flex flex-wrap gap-4 items-end">
            <!-- 小组筛选 -->
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-slate-600 dark:text-slate-400">小组</label>
              <el-select v-model="selectedTeam" placeholder="全部" clearable class="filter-select" teleported>
                <el-option v-for="team in teamOptions" :key="team" :label="team" :value="team" />
              </el-select>
            </div>
            
            <!-- 部门筛选 -->
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-slate-600 dark:text-slate-400">部门</label>
              <el-select v-model="selectedDept" placeholder="全部" clearable class="filter-select" teleported>
                <el-option v-for="stat in departmentStats" :key="stat.dept" :label="stat.dept" :value="stat.dept" />
              </el-select>
            </div>
            
            <!-- 投入类型筛选 -->
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-slate-600 dark:text-slate-400">投入类型</label>
              <el-select v-model="selectedInputType" placeholder="全部" clearable class="filter-select" teleported>
                <el-option label="真实" value="actual" />
                <el-option label="虚拟" value="virtual" />
              </el-select>
            </div>
            
            <!-- 对接人筛选 -->
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-slate-600 dark:text-slate-400">对接人</label>
              <el-select v-model="selectedContact" placeholder="全部" clearable class="filter-select" teleported>
                <el-option v-for="contact in contactOptions" :key="contact" :label="contact" :value="contact" />
              </el-select>
            </div>
            
            <!-- 结算等级筛选 -->
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-slate-600 dark:text-slate-400">结算等级</label>
              <el-select v-model="selectedSettlementLevel" placeholder="全部" clearable class="filter-select" teleported>
                <el-option v-for="level in settlementLevelOptions" :key="level" :label="level" :value="level" />
              </el-select>
            </div>
            
            <!-- 在场状态筛选 -->
            <div class="flex flex-col gap-1">
              <label class="text-xs font-medium text-slate-600 dark:text-slate-400">在场状态</label>
              <el-select v-model="selectedAttendanceStatus" placeholder="全部" clearable class="filter-select" teleported>
                <el-option label="在场" value="present" />
                <el-option label="离场" value="left" />
              </el-select>
            </div>
            
            <!-- 操作按钮 -->
            <div class="flex gap-2 pt-4">
              <button 
                class="border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-700 dark:text-slate-300 px-4 py-2 rounded-lg text-xs font-medium transition-colors"
                @click="clearAllFilters"
              >
                清除筛选
              </button>
              <button 
                class="bg-primary hover:bg-blue-600 text-white px-4 py-2 rounded-lg text-xs font-medium transition-colors"
                @click="showAdvancedFilter = false"
              >
                应用筛选
              </button>
            </div>
          </div>
        </div>
        
        <div class="overflow-x-auto">
          <el-table
            :data="filteredPersons"
            border
            stripe
          >
            <el-table-column
              prop="name"
              label="人员姓名"
              width="120"
              fixed="left"
            >
              <template #default="{ row }">
                <div class="flex flex-col">
                  <span class="font-medium text-slate-900 dark:text-white">{{ row.name }}</span>
                  <span class="text-[11px] text-slate-400">{{ row.position }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column
              prop="employeeId"
              label="工号"
              width="80"
            />
            <el-table-column
              prop="team"
              label="小组"
              width="80"
            />
            <el-table-column
              prop="settlementDept"
              label="部门"
              width="80"
            />
            <el-table-column
              prop="inputType"
              label="投入类型"
              width="80"
              align="center"
            >
              <template #default="{ row }">
                <span :class="{
                  
                  'text-green-500 dark:text-green-400': row.inputType === 'actual' || row.inputType === '真实',
                  'text-gray-500 dark:text-gray-400': row.inputType === 'virtual' || row.inputType === '虚拟'
                }">
                  {{ row.inputType === 'actual' ? '真实' : row.inputType === 'virtual' ? '虚拟' : row.inputType }}
                </span>
              </template>
            </el-table-column>
            <el-table-column
              prop="contact"
              label="对接人"
              width="90"
            />
            <el-table-column
              label="入场日期"
              width="100"
            >
              <template #default="{ row }">
                <span>{{ formatDate(row.entryDate) }}</span>
              </template>
            </el-table-column>
            <el-table-column
              label="离场日期"
              width="100"
            >
              <template #default="{ row }">
                <span>{{ row.exitDate ? formatDate(row.exitDate) : '未离场' }}</span>
              </template>
            </el-table-column>
            <el-table-column
              prop="settlementLevel"
              label="结算等级"
              width="80"
              align="center"
            >
              <template #default="{ row }">
                <span :class="[
                  'px-2 py-0.5 rounded text-[11px] font-medium',
                  row.settlementLevel === '高级' ? 'bg-blue-100 text-blue-600 dark:bg-blue-900/50 dark:text-blue-300' :
                  row.settlementLevel === '中级' ? 'bg-orange-100 text-orange-600 dark:bg-orange-900/50 dark:text-orange-300' :
                  'bg-green-100 text-green-600 dark:bg-green-900/50 dark:text-green-300'
                ]">
                  {{ row.settlementLevel }}
                </span>
              </template>
            </el-table-column>
            <el-table-column
              prop="priceWithTax"
              label="结算单价"
              width="110"
            >
              <template #default="{ row }">
                <span class="font-semibold text-slate-700 dark:text-slate-300">
                  ¥{{ showTaxPrice ? row.priceWithTax : row.priceWithoutTax }} / 天
                </span>
              </template>
            </el-table-column>
            <el-table-column
              v-for="m in months"
              :key="m.key"
              :label="m.label"
              width="75"
              align="right"
            >
              <template #default="{ row }">
                <div class="relative">
                  <span 
                    class="font-semibold cursor-pointer hover:text-primary transition-colors"
                    @click="showWorkDayInput(row, m)"
                  >
                    {{ row.workDays && row.workDays[m.key] ? row.workDays[m.key] : calculateMonthlyWorkDays(row, m) }}
                  </span>
                  <el-input
                    v-if="editingCell === `${row.name}-${m.key}`"
                    v-model="editValue"
                    size="small"
                    @blur="saveWorkDay(row, m)"
                    @keyup.enter="saveWorkDay(row, m)"
                    @keyup.esc="cancelEdit"
                    class="absolute top-0 left-0 w-full"
                    ref="inputRef"
                  />
                </div>
              </template>
            </el-table-column>
            <el-table-column
              label="操作"
              width="100"
              fixed="right"
              align="right"
            >
              <template #default="{ row, $index }">
                <div class="space-x-2">
                  <el-button v-if="hasManagePermission" link type="primary" size="small" @click="editPerson(row)">编辑</el-button>
                  <el-button v-if="hasManagePermission" link type="danger" size="small" @click="deletePerson($index)">删除</el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </div>
        <div class="px-6 py-3 border-t border-slate-200 dark:border-slate-700 flex items-center justify-between text-xs text-slate-500">
          <span>显示 {{ (currentPage - 1) * pageSize + 1 }} 到 {{ Math.min(currentPage * pageSize, totalPersons) }} 条，共 {{ totalPersons }} 条数据</span>
          <div class="flex gap-1">
            <button 
              class="px-2 py-1 border border-slate-200 dark:border-slate-700 rounded hover:bg-slate-50 disabled:opacity-50" 
              :disabled="currentPage === 1"
              @click="handlePrevPage"
            >上一页</button>
            <button class="px-2 py-1 bg-primary text-white rounded">{{ currentPage }}</button>
            <button 
              class="px-2 py-1 border border-slate-200 dark:border-slate-700 rounded hover:bg-slate-50" 
              :disabled="currentPage * pageSize >= totalPersons"
              @click="handleNextPage"
            >下一页</button>
          </div>
        </div>
      </section>

      <!-- 项目采购列表 -->
      <section 
        class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden mt-6 min-w-[1380px] max-w-[6000px] w-full"
      >
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><ShoppingCart /></el-icon> 项目采购列表
          </h3>
          <button
            v-if="hasManagePermission"
            class="px-3 py-1.5 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm font-medium flex items-center gap-1"
            @click="openAddProjectPurchase"
          >
            <el-icon><Plus /></el-icon>
            新增采购
          </button>
        </div>
        
        <div class="p-6">
          <el-table
            :data="filteredProjectPurchaseList"
            border
            stripe
          >
            <el-table-column prop="purchaseDept" label="采购部门" width="120" />
            <el-table-column prop="matter" label="采购事项" min-width="150" />
            <el-table-column prop="item" label="采购物品" min-width="150" />
            <el-table-column prop="quantity" label="采购数量" width="100" align="right" />
            <el-table-column prop="unitPrice" label="采购单价" width="120" align="right">
              <template #default="{ row }">
                <span>¥{{ formatNumber(row.unitPrice || 0) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="totalPrice" label="采购总价" width="130" align="right">
              <template #default="{ row }">
                <span class="font-medium text-orange-600 dark:text-orange-400">¥{{ formatNumber(row.totalPrice || 0) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="settlementRatio" label="结算系数" width="100" align="center">
              <template #default="{ row }">
                <span class="text-blue-600 dark:text-blue-400">{{ row.settlementRatio || 1 }}</span>
              </template>
            </el-table-column>
            <el-table-column label="采购时间" width="120">
              <template #default="{ row }">
                <span>{{ formatDate(row.purchaseTime) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="settlementMonth" label="结算月" width="100" />
            <el-table-column prop="executor" label="执行人" width="100" />
            <el-table-column label="结算金额" width="130" align="right">
              <template #default="{ row }">
                <span class="font-bold text-primary">¥{{ formatNumber(getPurchaseSettlementAmount(row)) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row, $index }">
                <div class="flex items-center justify-center gap-2">
                  <el-button v-if="hasManagePermission" type="primary" link size="small" @click="editProjectPurchase(row, $index)">
                    <el-icon><Edit /></el-icon>
                  </el-button>
                  <el-button v-if="hasManagePermission" type="danger" link size="small" @click="deleteProjectPurchase($index)">
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>



          <div v-if="projectPurchaseList.length > 0" class="mt-4 flex justify-end gap-4">
            <div class="bg-slate-100 dark:bg-slate-800 rounded-lg px-6 py-3">
              <span class="text-sm text-slate-600 dark:text-slate-400">结算金额合计：</span>
              <span class="text-lg font-bold text-primary ml-2">¥{{ formatNumber(totalPurchaseSettlementAmount) }}</span>
            </div>
            <div class="bg-blue-50 dark:bg-blue-900/30 rounded-lg px-6 py-3 border border-blue-200 dark:border-blue-800">
              <span class="text-sm text-blue-600 dark:text-blue-400">对应结算情况：</span>
              <span class="text-lg font-bold text-blue-700 dark:text-blue-300 ml-2">¥{{ formatNumber(virtualPersonSettlementAmount) }}</span>
            </div>
          </div>
          <div v-else class="mt-4 flex justify-end">
            <div class="bg-blue-50 dark:bg-blue-900/30 rounded-lg px-6 py-3 border border-blue-200 dark:border-blue-800">
              <span class="text-sm text-blue-600 dark:text-blue-400">对应结算情况：</span>
              <span class="text-lg font-bold text-blue-700 dark:text-blue-300 ml-2">¥{{ formatNumber(virtualPersonSettlementAmount) }}</span>
            </div>
          </div>
        </div>
      </section>

      <!-- 项目结算暂估 -->
      <section 
        class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden min-w-[1380px] max-w-[6000px] w-full"
      >
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><DataAnalysis /></el-icon> 项目结算暂估
          </h3>
          <div class="flex bg-slate-100 dark:bg-slate-800 p-1 rounded-lg">
            <button 
              class="px-3 py-1 text-xs font-medium rounded-md transition-all"
              :class="showSettlementTaxPrice ? 'bg-white dark:bg-slate-700 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'"
              @click="showSettlementTaxPrice = true"
            >含税金额</button>
            <button 
              class="px-3 py-1 text-xs font-medium rounded-md transition-all"
              :class="!showSettlementTaxPrice ? 'bg-white dark:bg-slate-700 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'"
              @click="showSettlementTaxPrice = false"
            >不含税金额</button>
          </div>
        </div>
        <div class="overflow-x-auto">
          <el-table
            :data="departmentSettlementList"
            border
            stripe
            :row-class-name="({ row }) => row.isTotal ? 'bg-blue-50 dark:bg-blue-900/20 font-bold' : (row.isDeptTotal ? 'bg-slate-50 dark:bg-slate-800/50' : '')"
          >
            <el-table-column
              prop="dept"
              label="部门"
              width="120"
              fixed="left"
            >
              <template #default="{ row }">
                <span :class="row.isTotal ? 'font-bold' : 'font-medium'">{{ row.dept }}</span>
              </template>
            </el-table-column>
            <el-table-column
              prop="level"
              label="人员等级"
              width="100"
            >
              <template #default="{ row }">
                <span :class="row.isDeptTotal ? 'font-medium text-slate-600' : ''">{{ row.level || '-' }}</span>
              </template>
            </el-table-column>
            <el-table-column
              prop="count"
              label="人员数量"
              width="90"
              align="right"
            >
              <template #default="{ row }">
                <span :class="row.isTotal || row.isDeptTotal ? 'font-bold' : 'font-medium'">{{ row.count }}</span>
              </template>
            </el-table-column>
            <el-table-column
              v-for="m in months"
              :key="m.key"
              :label="m.label"
              width="85"
              align="right"
            >
              <template #default="{ row }">
                <span :class="row.isTotal || row.isDeptTotal ? 'font-bold' : 'font-medium'">¥{{ formatNumber(row.monthlyTotals[m.key] || 0) }}</span>
              </template>
            </el-table-column>
            <el-table-column
              :label="'累计金额(' + (showSettlementTaxPrice ? '含税' : '不含税') + ')'"
              width="130"
              align="right"
              fixed="right"
            >
              <template #default="{ row }">
                <span :class="[row.isTotal ? 'font-bold text-red-500' : (row.isDeptTotal ? 'font-bold text-primary' : 'font-medium text-slate-700 dark:text-slate-200')]">¥{{ formatNumber(row.totalAmount) }}</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </section>

      <!-- 自由计算模块 -->
      <section 
        class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden mt-6 min-w-[1380px] max-w-[6000px] w-full"
      >
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><Calendar /></el-icon> 自由计算
          </h3>
        </div>
        
        <div class="p-6">
          <div class="flex flex-wrap items-end gap-4 mb-6" style="min-width: 100%;">
            <div class="flex flex-col gap-1">
              <label class="text-sm font-medium text-slate-700 dark:text-slate-300">开始月份</label>
              <el-date-picker
                v-model="freeCalcStartMonth"
                type="month"
                placeholder="选择开始月份"
                value-format="YYYY-MM"
                format="YYYY年MM月"
                class="w-40"
              />
            </div>
            <div class="flex flex-col gap-1">
              <label class="text-sm font-medium text-slate-700 dark:text-slate-300">结束月份</label>
              <el-date-picker
                v-model="freeCalcEndMonth"
                type="month"
                placeholder="选择结束月份"
                value-format="YYYY-MM"
                format="YYYY年MM月"
                class="w-40"
              />
            </div>
            <div class="flex flex-col gap-1 flex-grow min-w-[320px]">
              <label class="text-sm font-medium text-slate-700 dark:text-slate-300">选择部门</label>
              <el-select
                v-model="freeCalcDept"
                placeholder="请选择部门"
                clearable
                class="w-full"
              >
                <el-option label="全部部门" value="" />
                <el-option
                  v-for="dept in departments"
                  :key="dept"
                  :label="dept"
                  :value="dept"
                />
              </el-select>
            </div>
            <button
              class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm font-medium"
              @click="calculateFreeSettlement"
            >
              计算暂估金额
            </button>
          </div>

          <div v-if="freeCalcResult" class="grid grid-cols-2 gap-6">
            <div class="bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/30 dark:to-blue-800/30 rounded-xl p-6 border border-blue-200 dark:border-blue-800">
              <div class="flex items-center gap-2 mb-2">
                <el-icon class="text-blue-600 dark:text-blue-400 text-xl"><Money /></el-icon>
                <span class="text-sm font-medium text-blue-700 dark:text-blue-300">含税金额</span>
              </div>
              <div class="text-3xl font-bold text-blue-800 dark:text-blue-200">
                ¥{{ formatNumber(freeCalcResult.withTax) }}
              </div>
              <div class="mt-2 text-xs text-blue-600 dark:text-blue-400">
                时间周期: {{ freeCalcResult.monthCount }} 个月
              </div>
            </div>
            <div class="bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/30 dark:to-green-800/30 rounded-xl p-6 border border-green-200 dark:border-green-800">
              <div class="flex items-center gap-2 mb-2">
                <el-icon class="text-green-600 dark:text-green-400 text-xl"><Money /></el-icon>
                <span class="text-sm font-medium text-green-700 dark:text-green-300">不含税金额</span>
              </div>
              <div class="text-3xl font-bold text-green-800 dark:text-green-200">
                ¥{{ formatNumber(freeCalcResult.withoutTax) }}
              </div>
              <div class="mt-2 text-xs text-green-600 dark:text-green-400">
                部门: {{ freeCalcDept || '全部部门' }}
              </div>
            </div>
          </div>

          <div v-if="freeCalcResult && freeCalcResult.detailList.length > 0" class="mt-6">
            <h4 class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-3">详细统计</h4>
            <el-table
              :data="freeCalcResult.detailList"
              border
              stripe
              size="small"
            >
              <el-table-column prop="dept" label="部门" width="150" />
              <el-table-column prop="level" label="等级" width="100" />
              <el-table-column prop="count" label="人数" width="80" align="right" />
              <el-table-column label="含税金额" width="150" align="right">
                <template #default="{ row }">
                  <span class="text-blue-600 dark:text-blue-400 font-medium">¥{{ formatNumber(row.withTax) }}</span>
                </template>
              </el-table-column>
              <el-table-column label="不含税金额" width="150" align="right">
                <template #default="{ row }">
                  <span class="text-green-600 dark:text-green-400 font-medium">¥{{ formatNumber(row.withoutTax) }}</span>
                </template>
              </el-table-column>
              <el-table-column label="月度明细">
                <template #default="{ row }">
                  <div class="flex flex-wrap gap-1">
                    <span 
                      v-for="(amount, monthKey) in row.monthlyAmounts" 
                      :key="monthKey"
                      class="text-xs px-2 py-0.5 bg-slate-100 dark:bg-slate-700 rounded"
                    >
                      {{ monthKey }}: ¥{{ formatNumber(amount) }}
                    </span>
                  </div>
                </template>
              </el-table-column>
            </el-table>
          </div>

        </div>
      </section>

      <!-- 月成本列表 -->
      <section 
        class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden mt-6 min-w-[1380px] max-w-[6000px] w-full"
      >
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><Coin /></el-icon> 月成本列表
          </h3>
          <button
            v-if="hasManagePermission"
            class="px-3 py-1.5 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm font-medium flex items-center gap-1"
            @click="openAddMonthlyCost"
          >
            <el-icon><Plus /></el-icon>
            新增月成本
          </button>
        </div>
        
        <div class="p-6">
          <el-table
            :data="filteredMonthlyCostList"
            border
            stripe
          >
            <el-table-column prop="month" label="成本月" width="120" />
            <el-table-column prop="directCost" label="直接成本" width="140" align="right">
              <template #default="{ row }">
                <span class="text-red-500">¥{{ formatNumber(row.directCost || 0) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="operatingCost" label="经营成本" width="140" align="right">
              <template #default="{ row }">
                <span class="text-orange-500">¥{{ formatNumber(row.operatingCost || 0) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="sharedCost" label="公摊" width="120" align="right">
              <template #default="{ row }">
                <span class="text-yellow-600 dark:text-yellow-400">¥{{ formatNumber(row.sharedCost || 0) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="月成本总计" width="140" align="right">
              <template #default="{ row }">
                <span class="font-bold text-primary">¥{{ formatNumber(getMonthlyCostTotal(row)) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row, $index }">
                <div class="flex items-center justify-center gap-2">
                  <el-button v-if="hasManagePermission" type="primary" link size="small" @click="editMonthlyCost(row, $index)">
                    <el-icon><Edit /></el-icon>
                  </el-button>
                  <el-button v-if="hasManagePermission" type="danger" link size="small" @click="deleteMonthlyCost($index)">
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>

          <div v-if="monthlyCostList.length > 0" class="mt-4 flex justify-end">
            <div class="bg-slate-100 dark:bg-slate-800 rounded-lg px-6 py-3">
              <span class="text-sm text-slate-600 dark:text-slate-400">成本合计：</span>
              <span class="text-lg font-bold text-primary ml-2">¥{{ formatNumber(totalMonthlyCost) }}</span>
            </div>
          </div>
        </div>
      </section>

      <!-- 项目实际结算列表 -->
      <section 
        class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden mt-6 min-w-[1380px] max-w-[6000px] w-full"
      >
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><Wallet /></el-icon> 项目实际结算列表
          </h3>
          <button
            v-if="hasManagePermission"
            class="px-3 py-1.5 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm font-medium flex items-center gap-1"
            @click="openAddActualSettlement"
          >
            <el-icon><Plus /></el-icon>
            新增实际结算
          </button>
        </div>
        
        <div class="p-6">
          <el-table
            :data="filteredActualSettlementList"
            border
            stripe
          >
            <el-table-column label="结算周期" min-width="200">
              <template #default="{ row }">
                <span v-if="row.period && row.period.length === 2">{{ row.period[0] }} ~ {{ row.period[1] }}</span>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column prop="dept" label="结算部门" width="150" />
            <el-table-column prop="amountWithTax" label="含税金额" width="140" align="right">
              <template #default="{ row }">
                <span class="text-blue-600 dark:text-blue-400">¥{{ formatNumber(row.amountWithTax || 0) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="amountWithoutTax" label="不含税金额" width="140" align="right">
              <template #default="{ row }">
                <span class="text-green-600 dark:text-green-400">¥{{ formatNumber(row.amountWithoutTax || 0) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row, $index }">
                <div class="flex items-center justify-center gap-2">
                  <el-button v-if="hasManagePermission" type="primary" link size="small" @click="editActualSettlement(row, $index)">
                    <el-icon><Edit /></el-icon>
                  </el-button>
                  <el-button v-if="hasManagePermission" type="danger" link size="small" @click="deleteActualSettlement($index)">
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>

          <div v-if="actualSettlementList.length > 0" class="mt-4 flex justify-end gap-6">
            <div class="bg-slate-100 dark:bg-slate-800 rounded-lg px-6 py-3">
              <span class="text-sm text-slate-600 dark:text-slate-400">含税金额合计：</span>
              <span class="text-lg font-bold text-blue-600 dark:text-blue-400 ml-2">¥{{ formatNumber(totalActualSettlementWithTax) }}</span>
            </div>
            <div class="bg-slate-100 dark:bg-slate-800 rounded-lg px-6 py-3">
              <span class="text-sm text-slate-600 dark:text-slate-400">不含税金额合计：</span>
              <span class="text-lg font-bold text-green-600 dark:text-green-400 ml-2">¥{{ formatNumber(totalActualSettlementWithoutTax) }}</span>
            </div>
          </div>
        </div>
      </section>

      </template>
    </main>

    <!-- 月成本对话框 -->
    <div v-if="showMonthlyCostDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-md p-6">
        <h3 class="text-lg font-semibold mb-4">{{ isEditingMonthlyCost.value ? '编辑月成本' : '新增月成本' }}</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">成本月</label>
            <el-date-picker
              v-model="monthlyCostForm.month"
              type="month"
              placeholder="选择月份"
              value-format="YYYY-MM"
              format="YYYY年MM月"
              class="w-full"
              :disabled="isEditingMonthlyCost"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">直接成本</label>
            <input 
              v-model.number="monthlyCostForm.directCost"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入直接成本"
              type="number"
              min="0"
              step="0.01"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">经营成本</label>
            <input 
              v-model.number="monthlyCostForm.operatingCost"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入经营成本"
              type="number"
              min="0"
              step="0.01"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">公摊</label>
            <input 
              v-model.number="monthlyCostForm.sharedCost"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入公摊"
              type="number"
              min="0"
              step="0.01"
            />
          </div>
          <div class="bg-slate-50 dark:bg-slate-800 rounded-lg p-3 mt-4">
            <div class="flex justify-between items-center">
              <span class="text-sm font-medium text-slate-600 dark:text-slate-400">月成本总计：</span>
              <span class="text-lg font-bold text-primary">
                ¥{{ formatNumber(monthlyCostForm.directCost + monthlyCostForm.operatingCost + monthlyCostForm.sharedCost) }}
              </span>
            </div>
          </div>
        </div>
        <div class="flex justify-end gap-3 mt-6">
          <button
            class="px-4 py-2 border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors text-sm font-medium"
            @click="showMonthlyCostDialog = false"
          >
            取消
          </button>
          <button
            class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm font-medium"
            @click="saveMonthlyCost"
          >
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- 项目实际结算对话框 -->
    <div v-if="showActualSettlementDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-md p-6">
        <h3 class="text-lg font-semibold mb-4">{{ isEditingActualSettlement.value ? '编辑实际结算' : '新增实际结算' }}</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结算周期</label>
            <el-date-picker
              v-model="actualSettlementForm.period"
              type="daterange"
              range-separator="~"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              value-format="YYYY-MM-DD"
              format="YYYY年MM月DD日"
              class="w-full"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结算部门</label>
            <el-select
              v-model="actualSettlementForm.dept"
              placeholder="请选择结算部门"
              clearable
              class="w-full"
            >
              <el-option
                v-for="dept in departments"
                :key="dept"
                :label="dept"
                :value="dept"
              />
            </el-select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">含税金额</label>
            <input 
              v-model.number="actualSettlementForm.amountWithTax"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入含税金额"
              type="number"
              min="0"
              step="0.01"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">不含税金额</label>
            <input 
              v-model.number="actualSettlementForm.amountWithoutTax"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入不含税金额"
              type="number"
              min="0"
              step="0.01"
            />
          </div>
        </div>
        <div class="flex justify-end gap-3 mt-6">
          <button
            class="px-4 py-2 border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors text-sm font-medium"
            @click="showActualSettlementDialog = false"
          >
            取消
          </button>
          <button
            class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm font-medium"
            @click="saveActualSettlement"
          >
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- 项目采购对话框 -->
    <div v-if="showProjectPurchaseDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-lg p-6">
        <h3 class="text-lg font-semibold mb-4">{{ isEditingProjectPurchase.value ? '编辑采购' : '新增采购' }}</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">采购部门</label>
            <el-select
              v-model="projectPurchaseForm.purchaseDept"
              placeholder="请选择采购部门"
              clearable
              class="w-full"
            >
              <el-option
                v-for="dept in departments"
                :key="dept"
                :label="dept"
                :value="dept"
              />
            </el-select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">采购事项</label>
            <input 
              v-model="projectPurchaseForm.matter"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入采购事项"
              type="text"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">采购物品</label>
            <input 
              v-model="projectPurchaseForm.item"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入采购物品"
              type="text"
            />
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">采购数量</label>
              <input 
                v-model.number="projectPurchaseForm.quantity"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入采购数量"
                type="number"
                min="1"
                @input="calculateTotalPrice"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">采购单价</label>
              <input 
                v-model.number="projectPurchaseForm.unitPrice"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入采购单价"
                type="number"
                min="0"
                step="0.01"
                @input="calculateTotalPrice"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">采购总价</label>
            <input 
              v-model.number="projectPurchaseForm.totalPrice"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="采购单价×采购数量，可手动修改"
              type="number"
              min="0"
              step="0.01"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结算系数</label>
            <input 
              v-model.number="projectPurchaseForm.settlementRatio"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入结算系数"
              type="number"
              min="0"
              step="0.01"
            />
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">采购时间</label>
              <el-date-picker
                v-model="projectPurchaseForm.purchaseTime"
                type="date"
                placeholder="选择采购时间"
                value-format="YYYY-MM-DD"
                format="YYYY年MM月DD日"
                class="w-full"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结算月</label>
              <el-date-picker
                v-model="projectPurchaseForm.settlementMonth"
                type="month"
                placeholder="选择结算月"
                value-format="YYYY-MM"
                format="YYYY年MM月"
                class="w-full"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">执行人</label>
            <input 
              v-model="projectPurchaseForm.executor"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入执行人"
              type="text"
            />
          </div>
          <div class="bg-slate-50 dark:bg-slate-800 rounded-lg p-3 mt-4">
            <div class="flex justify-between items-center">
              <span class="text-sm font-medium text-slate-600 dark:text-slate-400">结算金额（采购总价×结算系数）：</span>
              <span class="text-lg font-bold text-primary">
                ¥{{ formatNumber(projectPurchaseForm.totalPrice * projectPurchaseForm.settlementRatio) }}
              </span>
            </div>
          </div>
        </div>
        <div class="flex justify-end gap-3 mt-6">
          <button
            class="px-4 py-2 border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors text-sm font-medium"
            @click="showProjectPurchaseDialog = false"
          >
            取消
          </button>
          <button
            class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm font-medium"
            @click="saveProjectPurchase"
          >
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- Excel导入对话框 -->
    <div v-if="showExcelImportDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-2xl p-6">
        <h3 class="text-lg font-semibold mb-4">Excel导入人员</h3>
        <div class="space-y-4">
          <div class="border-2 border-dashed border-slate-300 dark:border-slate-600 rounded-lg p-8 text-center">
            <input 
              ref="excelFileInput"
              type="file" 
              accept=".xlsx,.xls"
              class="hidden"
              @change="handleExcelFileChange"
            />
            <el-icon class="text-4xl text-slate-400 mb-2"><Upload /></el-icon>
            <p class="text-sm text-slate-600 dark:text-slate-400 mb-2">点击或拖拽Excel文件到此处</p>
            <button 
              class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm"
              @click="($refs.excelFileInput as HTMLInputElement).click()"
            >
              选择文件
            </button>
            <p v-if="excelFileName" class="mt-2 text-sm text-green-600 dark:text-green-400">
              已选择: {{ excelFileName }}
            </p>
          </div>
          
          <div v-if="excelPreviewData.length > 0" class="mt-4">
            <div class="flex justify-between items-center mb-2">
              <h4 class="text-sm font-medium text-slate-700 dark:text-slate-300">预览数据 (共{{ excelPreviewData.length }}条)</h4>
              <div class="flex items-center gap-2">
                <span v-if="duplicatePersonNames.length > 0" class="text-xs text-red-500">
                  检测到{{ duplicatePersonNames.length }}个重复人员
                </span>
              </div>
            </div>
            <el-table
              :data="excelPreviewData"
              border
              stripe
              max-height="300"
              size="small"
            >
              <el-table-column prop="name" label="姓名" width="100">
                <template #default="{ row }">
                  <span :class="isDuplicatePerson(row.name) ? 'text-red-500 font-bold' : ''">{{ row.name }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="team" label="团队" width="100" />
              <el-table-column prop="position" label="岗位" width="120" />
              <el-table-column prop="settlementDept" label="结算部门" width="100" />
              <el-table-column prop="settlementLevel" label="结算等级" width="100" />
              <el-table-column prop="entryDate" label="入场日期" width="120" />
            </el-table>
          </div>
        </div>
        <div class="flex justify-end gap-3 mt-6">
          <button
            class="px-4 py-2 border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors text-sm font-medium"
            @click="cancelExcelImport"
          >
            取消
          </button>
          <button
            class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 transition-colors text-sm font-medium"
            :disabled="excelPreviewData.length === 0"
            @click="confirmExcelImport"
          >
            确认导入
          </button>
        </div>
      </div>
    </div>
    
    <!-- 导入进度对话框 -->
    <div v-if="showImportProgressDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-md p-6">
        <h3 class="text-lg font-semibold mb-4">导入进度</h3>
        <div class="space-y-4">
          <div>
            <div class="flex justify-between items-center mb-1">
              <span class="text-sm font-medium text-slate-700 dark:text-slate-300">导入进度</span>
              <span class="text-sm font-medium text-slate-700 dark:text-slate-300">{{ importProgress }}%</span>
            </div>
            <div class="w-full bg-slate-200 dark:bg-slate-700 rounded-full h-2">
              <div 
                class="bg-primary h-2 rounded-full transition-all duration-300 ease-in-out"
                :style="{ width: importProgress + '%' }"
              ></div>
            </div>
          </div>
          <div class="text-center">
            <p class="text-sm text-slate-600 dark:text-slate-400">
              正在导入人员数据，请勿关闭此窗口
            </p>
            <p class="text-sm font-medium text-slate-700 dark:text-slate-300 mt-2">
              已导入: {{ importedCount }} / {{ totalCount }}
            </p>
          </div>
        </div>
      </div>
    </div>

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
            <el-date-picker
              v-model="newProject.contractPeriod"
              type="daterange"
              range-separator="~"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              value-format="YYYY-MM-DD"
              class="w-full"
            />
            <p v-if="errors.contractPeriod" class="text-xs text-red-500 mt-1">{{ errors.contractPeriod }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">所属集团</label>
            <el-select 
              v-model="newProject.group_id"
              class="w-full"
              placeholder="请选择所属集团"
            >
              <el-option 
                v-for="group in groups" 
                :key="group.id"
                :label="group.name"
                :value="group.id"
              />
            </el-select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">所属客户</label>
            <el-select 
              v-model="newProject.customer_id"
              class="w-full"
              placeholder="请选择所属客户"
            >
              <el-option 
                v-for="customer in newProjectFilteredCustomers"
                :key="customer.id"
                :label="customer.name"
                :value="customer.id"
              />
            </el-select>
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

    <!-- 结算配置对话框 -->
    <div v-if="showSettlementConfigDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-2xl p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-semibold">结算配置</h3>
          <button 
            class="text-slate-400 hover:text-slate-600 transition-colors"
            @click="showSettlementConfigDialog = false"
          >
            <el-icon><Close /></el-icon>
          </button>
        </div>
        
        <div class="space-y-6">
          <div>
            <h4 class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-3">结算等级配置</h4>
            <div class="space-y-4">
              <div 
                v-for="(level, index) in filteredSettlementLevels" 
                :key="index"
                class="grid grid-cols-4 gap-4 items-center p-4 bg-slate-50 dark:bg-slate-900/50 rounded-lg"
              >
                <div>
                  <label class="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">等级名称</label>
                  <input 
                    v-model="level.name"
                    class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                    placeholder="例如：高级"
                    type="text"
                  />
                </div>
                <div>
                  <label class="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">含税单价</label>
                  <input 
                    v-model="level.priceWithTax"
                    class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                    placeholder="0.00"
                    type="number"
                    step="0.01"
                  />
                </div>
                <div>
                  <label class="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">不含税单价</label>
                  <input 
                    v-model="level.priceWithoutTax"
                    class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                    placeholder="0.00"
                    type="number"
                    step="0.01"
                  />
                </div>
                <div class="flex items-end">
                  <button 
                    class="px-3 py-2 text-sm font-medium border border-red-200 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-all"
                    @click="removeSettlementLevel(index)"
                  >
                    <el-icon class="text-sm"><Delete /></el-icon>
                  </button>
                </div>
              </div>
              
              <button 
                class="w-full flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium border border-dashed border-slate-300 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800/50 rounded-md transition-all"
                @click="addSettlementLevel"
              >
                <el-icon class="text-sm"><Plus /></el-icon>
                添加结算等级
              </button>
            </div>
          </div>
        </div>
        
        <div class="flex justify-end gap-2 mt-6">
          <button 
            class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
            @click="showSettlementConfigDialog = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
            @click="saveSettlementConfig"
          >
            保存配置
          </button>
        </div>
      </div>
    </div>

    <!-- 编辑项目对话框 -->
    <div v-if="showEditProjectDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-md p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-semibold">编辑项目</h3>
          <button 
            class="text-slate-400 hover:text-slate-600 transition-colors"
            @click="showEditProjectDialog = false"
          >
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">项目名称</label>
            <input 
              v-model="editProject.name"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入项目名称"
              type="text"
            />
            <p v-if="editErrors.name" class="text-xs text-red-500 mt-1">{{ editErrors.name }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">合同周期</label>
            <el-date-picker
              v-model="editProject.contractPeriod"
              type="daterange"
              range-separator="~"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              value-format="YYYY-MM-DD"
              class="w-full"
            />
            <p v-if="editErrors.contractPeriod" class="text-xs text-red-500 mt-1">{{ editErrors.contractPeriod }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">所属集团</label>
            <el-select 
              v-model="editProject.group_id"
              class="w-full"
              placeholder="请选择所属集团"
            >
              <el-option 
                v-for="group in groups" 
                :key="group.id"
                :label="group.name"
                :value="group.id"
              />
            </el-select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">所属客户</label>
            <el-select 
              v-model="editProject.customer_id"
              class="w-full"
              placeholder="请选择所属客户"
            >
              <el-option 
                v-for="customer in filteredCustomers"
                :key="customer.id"
                :label="customer.name"
                :value="customer.id"
              />
            </el-select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">项目类型</label>
            <select 
              v-model="editProject.type"
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
              v-model="editProject.amount"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入合同金额"
              type="text"
            />
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-6">
          <button 
            class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
            @click="showEditProjectDialog = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
            @click="updateProject"
          >
            保存修改
          </button>
        </div>
      </div>
    </div>

    <!-- 立项配置对话框 -->
    <div v-if="showApprovalConfigDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-2xl p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-semibold">立项配置</h3>
          <button 
            class="text-slate-400 hover:text-slate-600 transition-colors"
            @click="showApprovalConfigDialog = false"
          >
            <el-icon><Close /></el-icon>
          </button>
        </div>
        
        <div class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">立项金额</label>
              <input 
                v-model="approvalConfigForm.amount"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入立项金额"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">立项毛利率</label>
              <input 
                v-model="approvalConfigForm.grossMargin"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入立项毛利率"
                type="text"
              />
            </div>
          </div>
          
          <div>
            <h4 class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-3">结算周期配置</h4>
            <div class="space-y-4">
              <div 
                v-for="(period, index) in approvalConfigForm.settlementPeriods" 
                :key="index"
                class="p-4 bg-slate-50 dark:bg-slate-900/50 rounded-lg"
              >
                <div class="flex justify-between items-start mb-4">
                  <h5 class="text-sm font-medium text-slate-700 dark:text-slate-300">结算周期 {{ index + 1 }}</h5>
                  <button 
                    class="text-slate-400 hover:text-red-500 transition-colors"
                    @click="removeSettlementPeriod(index)"
                  >
                    <el-icon class="text-sm"><Delete /></el-icon>
                  </button>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">开始日期</label>
                    <input 
                      v-model="period.startDate"
                      class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                      type="date"
                    />
                  </div>
                  <div>
                    <label class="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">结束日期</label>
                    <input 
                      v-model="period.endDate"
                      class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                      type="date"
                    />
                  </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
                  <div>
                    <label class="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">考核时间</label>
                    <input 
                      v-model="period.assessmentDate"
                      class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                      type="date"
                    />
                  </div>
                  <div>
                    <label class="block text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">回款时间</label>
                    <input 
                      v-model="period.paymentDate"
                      class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                      type="date"
                    />
                  </div>
                </div>
              </div>
              
              <button 
                class="w-full flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium border border-dashed border-slate-300 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800/50 rounded-md transition-all"
                @click="addSettlementPeriod"
              >
                <el-icon class="text-sm"><Plus /></el-icon>
                添加结算周期
              </button>
            </div>
          </div>
        </div>
        
        <div class="flex justify-end gap-2 mt-6">
          <button 
            class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
            @click="showApprovalConfigDialog = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
            @click="saveApprovalConfig"
          >
            保存配置
          </button>
        </div>
      </div>
    </div>

    <!-- 添加项目重要事项对话框 -->
    <div v-if="showAddImportantItemDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-md p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-semibold">{{ isEditingImportantItem ? '编辑重要事项' : '添加重要事项' }}</h3>
          <button 
            class="text-slate-400 hover:text-slate-600 transition-colors"
            @click="showAddImportantItemDialog = false"
          >
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="space-y-4">
          <div>
            <input 
              v-model="importantItemForm.title"
              class="w-full px-3 py-4 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入事项内容"
              type="text"
            />
          </div>
          <div>
            <p class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">选择颜色</p>
            <div class="flex gap-2">
              <button 
                v-for="color in ['red', 'yellow', 'green', 'blue']" 
                :key="color"
                :class="[
                  'w-8 h-8 rounded-full border-2 transition-all',
                  importantItemForm.color === color ? 'border-slate-500' : 'border-transparent'
                ]"
                :style="{ backgroundColor: color }"
                @click="importantItemForm.color = color"
              ></button>
            </div>
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-6">
          <button 
            class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
            @click="showAddImportantItemDialog = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
            @click="saveImportantItem"
          >
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- 添加合同对话框 -->
    <div v-if="showAddContractDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-2xl p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-semibold">添加{{ currentContractType === 'main' ? '主合同' : '采购合同' }}</h3>
          <button 
            class="text-slate-400 hover:text-slate-600 transition-colors"
            @click="showAddContractDialog = false"
          >
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">合同名称</label>
              <input 
                v-model="contractForm.name"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入合同名称"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">合同编号</label>
              <input 
                v-model="contractForm.code"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入合同编号"
                type="text"
              />
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">合同金额</label>
              <input 
                v-model="contractForm.amount"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入合同金额"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">客户名称</label>
              <input 
                v-model="contractForm.customer"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入客户名称"
                type="text"
              />
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">开始日期</label>
              <input 
                v-model="contractForm.startDate"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                type="date"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结束日期</label>
              <input 
                v-model="contractForm.endDate"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                type="date"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">合同附件 (PDF格式)</label>
            <div class="flex items-center gap-2">
              <input 
                type="file"
                accept=".pdf"
                class="hidden"
                id="file-upload"
                @change="handleFileUpload"
              />
              <label 
                for="file-upload"
                class="flex-1 px-4 py-2 border border-dashed border-slate-300 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-all cursor-pointer text-center"
              >
                <el-icon class="text-slate-400 mb-1"><Upload /></el-icon>
                <p class="text-sm text-slate-500">点击或拖拽文件到此处上传</p>
              </label>
            </div>
            <p v-if="contractForm.attachment" class="text-xs text-slate-500 mt-1">已选择文件: {{ contractForm.attachment.name }}</p>
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-6">
          <button 
            class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
            @click="showAddContractDialog = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
            @click="saveContract"
          >
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- 新增订单对话框 -->
    <div v-if="showAddOrderDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-2xl p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-semibold">{{ isEditingOrder ? '编辑订单' : '新增订单' }}</h3>
          <button 
            class="text-slate-400 hover:text-slate-600 transition-colors"
            @click="showAddOrderDialog = false"
          >
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">订单编号</label>
            <input 
              v-model="orderForm.code"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入订单编号"
              type="text"
            />
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">开始日期</label>
              <input 
                v-model="orderForm.startDate"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                type="date"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结束日期</label>
              <input 
                v-model="orderForm.endDate"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                type="date"
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">订单时间</label>
            <input 
              v-model="orderForm.orderDate"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              type="date"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">订单金额</label>
            <input 
              v-model="orderForm.amount"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入订单金额"
              type="number"
              step="0.01"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">订单附件 (PDF格式)</label>
            <div class="flex items-center gap-2">
              <input 
                type="file"
                accept=".pdf"
                class="hidden"
                id="order-file-upload"
                @change="handleOrderFileUpload"
              />
              <label 
                for="order-file-upload"
                class="flex-1 px-4 py-2 border border-dashed border-slate-300 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-all cursor-pointer text-center"
              >
                <el-icon class="text-slate-400 mb-1"><Upload /></el-icon>
                <p class="text-sm text-slate-500">点击或拖拽文件到此处上传</p>
              </label>
            </div>
            <p v-if="orderForm.attachment" class="text-xs text-slate-500 mt-1">已选择文件: {{ orderForm.attachment.name }}</p>
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-6">
          <button 
            class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
            @click="showAddOrderDialog = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
            @click="saveOrder"
          >
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- 添加人员对话框 -->
    <div v-if="showAddPersonDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-3xl p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-semibold">{{ isEditingPerson ? '编辑人员' : '添加人员' }}</h3>
          <button 
            class="text-slate-400 hover:text-slate-600 transition-colors"
            @click="showAddPersonDialog = false"
          >
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">姓名</label>
              <input 
                v-model="personForm.name"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入姓名"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">员工工号</label>
              <input 
                v-model="personForm.employeeId"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入员工工号"
                type="text"
              />
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">小组</label>
              <input 
                v-model="personForm.team"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入小组"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">岗位</label>
              <input 
                v-model="personForm.position"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入岗位"
                type="text"
              />
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结算部门</label>
              <input 
                v-model="personForm.settlementDept"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入结算部门"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">对接人</label>
              <input 
                v-model="personForm.contact"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入对接人"
                type="text"
              />
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结算等级</label>
              <select 
                v-model="personForm.settlementLevel"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                @change="handleSettlementLevelChange"
                :disabled="filteredSettlementLevels.length === 0"
              >
                <option value="">{{ filteredSettlementLevels.length === 0 ? '请先配置结算等级' : '请选择结算等级' }}</option>
                <option v-for="level in filteredSettlementLevels" :key="level.name" :value="level.name">
                  {{ level.name }}
                </option>
              </select>
              <p v-if="filteredSettlementLevels.length === 0" class="text-xs text-orange-500 mt-1">
                请先在"结算配置"中添加结算等级
              </p>
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">投入类型</label>
              <select 
                v-model="personForm.inputType"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              >
                <option value="真实">真实</option>
                <option value="虚拟">虚拟</option>
              </select>
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">入场时间</label>
              <input 
                v-model="personForm.entryDate"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                type="date"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">离场时间</label>
              <input 
                v-model="personForm.exitDate"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                type="date"
              />
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">含税单价</label>
              <input 
                v-model="personForm.priceWithTax"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                type="number"
                step="0.01"
                readonly
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">不含税单价</label>
              <input 
                v-model="personForm.priceWithoutTax"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                type="number"
                step="0.01"
                readonly
              />
            </div>
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-6">
          <button 
            class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
            @click="showAddPersonDialog = false"
          >
            取消
          </button>
          <button 
            class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
            @click="savePerson"
          >
            保存
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- 项目权限管理对话框 -->
  <div v-if="showProjectPermissionsDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
    <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-2xl p-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-semibold">项目权限管理</h3>
        <button 
          class="text-slate-400 hover:text-slate-600 transition-colors"
          @click="showProjectPermissionsDialog = false"
        >
          <el-icon><Close /></el-icon>
        </button>
      </div>
      
      <div class="space-y-6">
        <!-- 添加权限表单 -->
        <div class="p-4 bg-slate-50 dark:bg-slate-900/50 rounded-lg">
          <h4 class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-3">添加用户权限</h4>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">选择用户</label>
              <el-select v-model="permissionForm.user_id" placeholder="请选择用户" class="w-full" filterable>
                <el-option
                  v-for="user in systemUsers"
                  :key="user.id"
                  :label="`${user.name} (${user.account})`"
                  :value="user.id"
                />
              </el-select>
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">权限类型</label>
              <el-select v-model="permissionForm.permission" placeholder="请选择权限" class="w-full">
                <el-option label="查看权限" value="view" />
                <el-option label="管理权限" value="manage" />
              </el-select>
            </div>
          </div>
          <div class="mt-4">
            <button 
              class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
              @click="addProjectPermission"
            >
              添加权限
            </button>
          </div>
        </div>
        
        <!-- 权限列表 -->
        <div>
          <h4 class="text-sm font-medium text-slate-700 dark:text-slate-300 mb-3">当前权限列表</h4>
          <div class="overflow-x-auto">
            <el-table
              :data="projectPermissions"
              border
              stripe
              style="width: 100%"
            >
              <el-table-column
                prop="user_name"
                label="用户姓名"
                min-width="120"
              />
              <el-table-column
                prop="user_account"
                label="用户账号"
                min-width="120"
              />
              <el-table-column
                prop="permission"
                label="权限类型"
                min-width="100"
              >
                <template #default="{ row }">
                  <el-tag :type="row.permission === 'manage' ? 'primary' : 'info'" size="small">
                    {{ row.permission === 'manage' ? '管理权限' : '查看权限' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column
                label="操作"
                width="120"
                fixed="right"
              >
                <template #default="{ row }">
                  <button 
                    class="text-red-500 hover:text-red-700 transition-colors text-sm"
                    @click="deleteProjectPermission(row.user_id)"
                  >
                    <el-icon class="text-sm mr-1"><Delete /></el-icon> 删除
                  </button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>
      </div>
      
      <div class="flex justify-end gap-2 mt-6">
        <button 
          class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
          @click="showProjectPermissionsDialog = false"
        >
          关闭
        </button>
      </div>
    </div>
  </div>
  
  <!-- 修改密码弹窗 -->
  <div v-if="showChangePasswordDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
    <div class="bg-white dark:bg-card-dark rounded-lg shadow-xl w-full max-w-md p-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-semibold">修改密码</h3>
        <button 
          class="text-slate-400 hover:text-slate-600 transition-colors"
          @click="showChangePasswordDialog = false"
        >
          <el-icon><Close /></el-icon>
        </button>
      </div>
      
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1">当前密码</label>
          <el-input
            v-model="changePasswordForm.currentPassword"
            type="password"
            placeholder="请输入当前密码"
            class="w-full"
          />
          <p v-if="changePasswordErrors.currentPassword" class="text-red-500 text-xs mt-1">
            {{ changePasswordErrors.currentPassword }}
          </p>
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-1">新密码</label>
          <el-input
            v-model="changePasswordForm.newPassword"
            type="password"
            placeholder="请输入新密码"
            class="w-full"
          />
          <p v-if="changePasswordErrors.newPassword" class="text-red-500 text-xs mt-1">
            {{ changePasswordErrors.newPassword }}
          </p>
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-1">确认新密码</label>
          <el-input
            v-model="changePasswordForm.confirmPassword"
            type="password"
            placeholder="请再次输入新密码"
            class="w-full"
          />
          <p v-if="changePasswordErrors.confirmPassword" class="text-red-500 text-xs mt-1">
            {{ changePasswordErrors.confirmPassword }}
          </p>
        </div>
      </div>
      
      <div class="flex justify-end gap-2 mt-6">
        <button 
          class="px-4 py-2 text-sm font-medium border border-slate-200 dark:border-slate-700 rounded-md hover:bg-slate-50 dark:hover:bg-slate-800 transition-all"
          @click="showChangePasswordDialog = false"
        >
          取消
        </button>
        <button 
          class="px-4 py-2 text-sm font-medium bg-primary hover:bg-blue-600 text-white rounded-md transition-all"
          @click="handleSubmitChangePassword"
        >
          确定
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox, ElIcon } from 'element-plus'
import { Lock, Close, Management, SwitchButton, Setting, Rank } from '@element-plus/icons-vue'
import * as XLSX from 'xlsx'
import draggable from 'vuedraggable'
import { projectApi, dataApi, userApi, uploadApi } from '../api'

const router = useRouter()
const username = ref('')
const userDisplayName = ref('')
const userEmail = ref('')
const userRole = ref('')
const searchQuery = ref('')
const loginAccount = ref('')
const projectSortOrder = ref<number[]>([])

// 按账号加载项目排序
const loadProjectSortOrder = () => {
  if (!loginAccount.value) return []
  const saved = localStorage.getItem(`project_sort_${loginAccount.value}`)
  if (saved) {
    try {
      return JSON.parse(saved)
    } catch (e) {
      return []
    }
  }
  return []
}

// 按账号保存项目排序
const saveProjectSortOrder = () => {
  if (!loginAccount.value) return
  localStorage.setItem(`project_sort_${loginAccount.value}`, JSON.stringify(projectSortOrder.value))
}

// 计算属性：是否为系统管理员
const isAdmin = computed(() => {
  // 直接检查 userRole.value
  return userRole.value === 'admin'
})
const showCreateProjectDialog = ref(false)
const showSettlementConfigDialog = ref(false)
const showEditProjectDialog = ref(false)
const showApprovalConfigDialog = ref(false)
const showAddImportantItemDialog = ref(false)
const showAddContractDialog = ref(false)
const showProjectPermissionsDialog = ref(false)
const projectPermissions = ref<any[]>([])
const systemUsers = ref<any[]>([])
const permissionForm = reactive({
  user_id: '',
  permission: 'view'
})
const currentContractType = ref('main')

// 修改密码相关
const showChangePasswordDialog = ref(false)
const changePasswordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})
const changePasswordErrors = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 订单管理相关
const showAddOrderDialog = ref(false)
const isEditingOrder = ref(false)
const currentOrderIndex = ref(-1)

// 人员管理相关
const showAddPersonDialog = ref(false)
const isEditingPerson = ref(false)
const currentPersonIndex = ref(-1)
const showTaxPrice = ref(true)
const showSettlementTaxPrice = ref(true)
const personSearchQuery = ref('')
const selectedDept = ref('')
const selectedTeam = ref('')
const selectedInputType = ref('')
const selectedContact = ref('')
const selectedSettlementLevel = ref('')
const selectedAttendanceStatus = ref('')
const showAdvancedFilter = ref(false)

// Excel导入相关
const showExcelImportDialog = ref(false)
const showImportProgressDialog = ref(false)
const importProgress = ref(0)
const importedCount = ref(0)
const totalCount = ref(0)
const excelFileName = ref('')
const excelPreviewData = ref<Array<any>>([])
const duplicatePersonNames = ref<string[]>([])

const isDuplicatePerson = (name: string) => {
  return duplicatePersonNames.value.includes(name)
}

const handleExcelFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return
  
  excelFileName.value = file.name
  
  const reader = new FileReader()
  reader.onload = (e) => {
    const data = e.target?.result
    const workbook = XLSX.read(data, { type: 'array' })
    const sheetName = workbook.SheetNames[0]
    const worksheet = workbook.Sheets[sheetName]
    const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 })
    
    if (jsonData.length < 2) {
      ElMessage.warning('Excel文件为空或格式不正确')
      return
    }
    
    const headers = jsonData[0] as string[]
    const headerMap: Record<string, number> = {}
    headers.forEach((header, index) => {
      if (header) {
        headerMap[header.trim()] = index
      }
    })
    
    const parsedData: any[] = []
    const duplicates: string[] = []
    
    for (let i = 1; i < jsonData.length; i++) {
      const row = jsonData[i] as any[]
      if (!row || row.length === 0) continue
      
      const excelLevel = row[headerMap['结算等级']] || row[headerMap['等级']] || row[headerMap['人员等级']] || row[headerMap['级别']] || ''
      
      let settlementLevel = excelLevel
      if (!settlementLevel || settlementLevel === '') {
        settlementLevel = filteredSettlementLevels.value.length > 0 ? filteredSettlementLevels.value[0].name : ''
      } else {
        const matchedLevel = filteredSettlementLevels.value.find(level => 
          level.name === settlementLevel || 
          level.name.toLowerCase() === settlementLevel.toLowerCase() ||
          level.name.includes(settlementLevel) ||
          settlementLevel.includes(level.name)
        )
        if (matchedLevel) {
          settlementLevel = matchedLevel.name
        } else {
          settlementLevel = filteredSettlementLevels.value.length > 0 ? filteredSettlementLevels.value[0].name : ''
        }
      }
      
      // 转换Excel日期序列号为正常日期
      const excelDateToDate = (excelDate: any): string => {
        if (!excelDate || isNaN(excelDate)) return ''
        // Excel日期序列号转换（1900年1月1日为起点）
        const date = new Date(Math.round((excelDate - 25569) * 86400 * 1000))
        return date.toISOString().split('T')[0]
      }
      
      const person: any = {
        name: row[headerMap['姓名']] || row[headerMap['人员姓名']] || row[0] || '',
        employeeId: row[headerMap['员工工号']] || row[headerMap['工号']] || row[headerMap['id']] || '',
        team: row[headerMap['团队']] || row[headerMap['所属团队']] || '',
        position: row[headerMap['岗位']] || row[headerMap['职位']] || '',
        settlementDept: row[headerMap['结算部门']] || row[headerMap['部门']] || '',
        settlementLevel: settlementLevel,
        contact: row[headerMap['对接人']] || '',
        entryDate: excelDateToDate(row[headerMap['入场日期']] || row[headerMap['入场时间']]),
        exitDate: excelDateToDate(row[headerMap['离场日期']] || row[headerMap['离场时间']]),
        priceWithTax: parseFloat(row[headerMap['含税单价']]) || 0,
        priceWithoutTax: parseFloat(row[headerMap['不含税单价']]) || 0,
        inputType: row[headerMap['投入类型']] || '真实',
        workDays: {}
      }
      
      if (!person.priceWithTax || person.priceWithTax === 0) {
        const levelConfig = filteredSettlementLevels.value.find(level => level.name === settlementLevel)
        if (levelConfig) {
          person.priceWithTax = levelConfig.priceWithTax
          person.priceWithoutTax = levelConfig.priceWithoutTax
        }
      }
      
      if (person.name) {
        const existingPerson = persons.value.find((p: any) => p.name === person.name)
        if (existingPerson) {
          duplicates.push(person.name)
        }
        parsedData.push(person)
      }
    }
    
    excelPreviewData.value = parsedData
    duplicatePersonNames.value = duplicates
    
    if (duplicates.length > 0) {
      ElMessage.warning(`检测到${duplicates.length}个重复人员，导入后将标红显示`)
    }
  }
  reader.readAsArrayBuffer(file)
}

const cancelExcelImport = () => {
  showExcelImportDialog.value = false
  excelFileName.value = ''
  excelPreviewData.value = []
  duplicatePersonNames.value = []
}

const confirmExcelImport = async () => {
  if (excelPreviewData.value.length === 0) {
    ElMessage.warning('没有可导入的数据')
    return
  }
  
  const currentProjectId = currentProject.value?.id
  if (!currentProjectId) {
    ElMessage.error('请先选择项目')
    return
  }
  
  // 打开进度弹窗
  showImportProgressDialog.value = true
  // 初始化进度变量
  totalCount.value = excelPreviewData.value.length
  importedCount.value = 0
  importProgress.value = 0
  
  let importCount = 0
  try {
    for (let i = 0; i < excelPreviewData.value.length; i++) {
      const person = excelPreviewData.value[i]
      // 准备后端API需要的数据格式
      const personData = {
        name: person.name,
        employee_id: person.employeeId,
        team: person.team,
        position: person.position,
        settlement_dept: person.settlementDept,
        contact: person.contact,
        entry_date: person.entryDate,
        exit_date: person.exitDate,
        settlement_level: person.settlementLevel,
        price_with_tax: person.priceWithTax,
        price_without_tax: person.priceWithoutTax,
        input_type: person.inputType === '真实' ? 'actual' : 'virtual',
        project_id: currentProject.value?.id
      }
      
      // 调用后端API
      await dataApi.createPerson(personData)
      
      // 添加到本地数组
      persons.value.push({ 
        ...person,
        project_id: currentProjectId
      })
      importCount++
      
      // 更新进度
      importedCount.value = importCount
      importProgress.value = Math.round((importCount / totalCount.value) * 100)
      
      // 为了更好的视觉效果，添加一个小延迟
      await new Promise(resolve => setTimeout(resolve, 50))
    }
    
    // 关闭进度弹窗
    showImportProgressDialog.value = false
    ElMessage.success(`成功导入${importCount}条人员数据`)
    cancelExcelImport()
  } catch (error) {
    console.error('导入人员数据失败:', error)
    // 关闭进度弹窗
    showImportProgressDialog.value = false
    ElMessage.error('导入失败，请重试')
  }
}

// 自由计算相关
const freeCalcStartMonth = ref('')
const freeCalcEndMonth = ref('')
const freeCalcDept = ref('')
const freeCalcResult = ref<{
  withTax: number
  withoutTax: number
  monthCount: number
  detailList: Array<{
    dept: string
    level: string
    count: number
    withTax: number
    withoutTax: number
    monthlyAmounts: Record<string, number>
  }>
} | null>(null)

// 月成本列表相关
const monthlyCostList = ref<Array<{
  project_id: number
  month: string
  directCost: number
  operatingCost: number
  sharedCost: number
}>>([])
const showMonthlyCostDialog = ref(false)
const isEditingMonthlyCost = ref(false)
const currentMonthlyCostIndex = ref(-1)
const monthlyCostForm = reactive({
  month: '',
  directCost: 0,
  operatingCost: 0,
  sharedCost: 0
})

// 过滤后的月成本列表
const filteredMonthlyCostList = computed(() => {
  return monthlyCostList.value.filter(item => item.project_id === currentProject.value?.id)
})

const totalMonthlyCost = computed(() => {
  return filteredMonthlyCostList.value.reduce((sum, item) => {
    const directCost = parseFloat(item.directCost) || 0
    const operatingCost = parseFloat(item.operatingCost) || 0
    const sharedCost = parseFloat(item.sharedCost) || 0
    return sum + directCost + operatingCost + sharedCost
  }, 0)
})

const getMonthlyCostTotal = (row: any) => {
  const directCost = parseFloat(row.directCost) || 0
  const operatingCost = parseFloat(row.operatingCost) || 0
  const sharedCost = parseFloat(row.sharedCost) || 0
  return directCost + operatingCost + sharedCost
}

const openAddMonthlyCost = () => {
  monthlyCostForm.month = ''
  monthlyCostForm.directCost = 0
  monthlyCostForm.operatingCost = 0
  monthlyCostForm.sharedCost = 0
  isEditingMonthlyCost.value = false
  currentMonthlyCostIndex.value = -1
  showMonthlyCostDialog.value = true
}

const editMonthlyCost = (row: any, index: number) => {
  monthlyCostForm.month = row.month
  monthlyCostForm.directCost = row.directCost
  monthlyCostForm.operatingCost = row.operatingCost
  monthlyCostForm.sharedCost = row.sharedCost
  isEditingMonthlyCost.value = true
  currentMonthlyCostIndex.value = index
  showMonthlyCostDialog.value = true
}

const saveMonthlyCost = async () => {
  if (!monthlyCostForm.month) {
    ElMessage.warning('请选择成本月')
    return
  }

  try {
    // 准备后端API需要的数据格式
    const monthlyCostData = {
      month: monthlyCostForm.month,
      direct_cost: monthlyCostForm.directCost,
      operating_cost: monthlyCostForm.operatingCost,
      shared_cost: monthlyCostForm.sharedCost
    }

    // 调用后端API
    await dataApi.createMonthlyCost(monthlyCostData)

    if (isEditingMonthlyCost.value) {
      monthlyCostList.value[currentMonthlyCostIndex.value] = { 
        ...monthlyCostForm,
        project_id: currentProject.value?.id || 0
      }
      ElMessage.success('修改成功')
    } else {
      const existsIndex = monthlyCostList.value.findIndex(item => 
        item.month === monthlyCostForm.month && 
        item.project_id === currentProject.value?.id
      )
      if (existsIndex >= 0) {
        ElMessage.warning('该月份成本已存在，请选择编辑')
        return
      }
      monthlyCostList.value.push({ 
        ...monthlyCostForm,
        project_id: currentProject.value?.id || 0
      })
      ElMessage.success('添加成功')
    }

    monthlyCostList.value.sort((a, b) => a.month.localeCompare(b.month))
    showMonthlyCostDialog.value = false
  } catch (error) {
    console.error('保存月成本失败:', error)
    ElMessage.error('保存失败，请重试')
  }
}

const deleteMonthlyCost = async (index: number) => {
  try {
    // 从过滤后的列表中获取要删除的项
    const costToDelete = filteredMonthlyCostList.value[index]
    if (costToDelete) {
      // 如果有ID，调用后端API删除
      if (costToDelete.id) {
        await dataApi.deleteMonthlyCost(costToDelete.id)
      }
      // 在原始列表中找到正确的索引并删除
      const originalIndex = monthlyCostList.value.findIndex(c => c.id === costToDelete.id)
      if (originalIndex !== -1) {
        monthlyCostList.value.splice(originalIndex, 1)
      }
      ElMessage.success('删除成功')
    }
  } catch (error) {
    console.error('删除月成本失败:', error)
    ElMessage.error('删除失败，请重试')
  }
}

// 项目实际结算列表相关
const loadActualSettlementFromStorage = () => {
  const saved = localStorage.getItem('project_actual_settlements')
  if (saved) {
    try {
      return JSON.parse(saved)
    } catch (e) {
      return []
    }
  }
  return []
}

const actualSettlementList = ref<Array<{
  project_id: number
  period: string[]
  dept: string
  amountWithTax: number
  amountWithoutTax: number
}>>(loadActualSettlementFromStorage())

watch(actualSettlementList, (newVal) => {
  localStorage.setItem('project_actual_settlements', JSON.stringify(newVal))
}, { deep: true })
const showActualSettlementDialog = ref(false)
const isEditingActualSettlement = ref(false)
const currentActualSettlementIndex = ref(-1)
const actualSettlementForm = reactive({
  period: [] as string[],
  dept: '',
  amountWithTax: 0,
  amountWithoutTax: 0
})

// 过滤后的实际结算列表
const filteredActualSettlementList = computed(() => {
  return actualSettlementList.value.filter(item => item.project_id === currentProject.value?.id)
})

const totalActualSettlementWithTax = computed(() => {
  return filteredActualSettlementList.value.reduce((sum, item) => {
    const amount = parseFloat(item.amountWithTax) || 0
    return sum + amount
  }, 0)
})

const totalActualSettlementWithoutTax = computed(() => {
  return filteredActualSettlementList.value.reduce((sum, item) => {
    const amount = parseFloat(item.amountWithoutTax) || 0
    return sum + amount
  }, 0)
})

const openAddActualSettlement = () => {
  actualSettlementForm.period = []
  actualSettlementForm.dept = ''
  actualSettlementForm.amountWithTax = 0
  actualSettlementForm.amountWithoutTax = 0
  isEditingActualSettlement.value = false
  currentActualSettlementIndex.value = -1
  showActualSettlementDialog.value = true
}

const editActualSettlement = (row: any, index: number) => {
  actualSettlementForm.period = row.period || []
  actualSettlementForm.dept = row.dept
  actualSettlementForm.amountWithTax = row.amountWithTax
  actualSettlementForm.amountWithoutTax = row.amountWithoutTax
  isEditingActualSettlement.value = true
  currentActualSettlementIndex.value = index
  showActualSettlementDialog.value = true
}

const saveActualSettlement = async () => {
  if (!actualSettlementForm.period || actualSettlementForm.period.length === 0) {
    ElMessage.warning('请选择结算周期')
    return
  }
  if (!actualSettlementForm.dept) {
    ElMessage.warning('请选择结算部门')
    return
  }

  try {
    // 准备后端API需要的数据格式
    const actualSettlementData = {
      period_start: actualSettlementForm.period[0],
      period_end: actualSettlementForm.period[1],
      dept: actualSettlementForm.dept,
      amount_with_tax: actualSettlementForm.amountWithTax,
      amount_without_tax: actualSettlementForm.amountWithoutTax
    }

    // 调用后端API
    if (isEditingActualSettlement.value) {
      // 获取当前编辑的结算记录
      const currentSettlement = filteredActualSettlementList.value[currentActualSettlementIndex.value]
      if (currentSettlement && currentSettlement.id) {
        // 调用更新API
        await dataApi.updateActualSettlement(currentSettlement.id, actualSettlementData)
        // 更新本地数据 - 找到原始列表中的索引
        const originalIndex = actualSettlementList.value.findIndex(s => s.id === currentSettlement.id)
        if (originalIndex !== -1) {
          actualSettlementList.value[originalIndex] = { 
            ...actualSettlementForm,
            project_id: currentProject.value?.id || 0,
            id: currentSettlement.id
          }
          ElMessage.success('修改成功')
        }
      }
    } else {
      // 调用创建API
      const result = await dataApi.createActualSettlement(actualSettlementData)
      // 添加到本地数组
      actualSettlementList.value.push({ 
        ...actualSettlementForm,
        project_id: currentProject.value?.id || 0,
        id: result.id
      })
      ElMessage.success('添加成功')
    }

    showActualSettlementDialog.value = false
  } catch (error) {
    console.error('保存实际结算失败:', error)
    ElMessage.error('保存失败，请重试')
  }
}

const deleteActualSettlement = async (index: number) => {
  try {
    // 从过滤后的列表中获取要删除的项
    const settlementToDelete = filteredActualSettlementList.value[index]
    if (settlementToDelete) {
      // 如果有ID，调用后端API删除
      if (settlementToDelete.id) {
        await dataApi.deleteActualSettlement(settlementToDelete.id)
      }
      // 在原始列表中找到正确的索引并删除
      const originalIndex = actualSettlementList.value.findIndex(s => s.id === settlementToDelete.id)
      if (originalIndex !== -1) {
        actualSettlementList.value.splice(originalIndex, 1)
      }
      ElMessage.success('删除成功')
    }
  } catch (error) {
    console.error('删除实际结算失败:', error)
    ElMessage.error('删除失败，请重试')
  }
}

// 项目采购列表相关
const loadProjectPurchaseFromStorage = () => {
  const saved = localStorage.getItem('project_purchases')
  if (saved) {
    try {
      return JSON.parse(saved)
    } catch (e) {
      return []
    }
  }
  return []
}

const projectPurchaseList = ref<Array<{
  project_id: number
  matter: string
  item: string
  quantity: number
  unitPrice: number
  totalPrice: number
  settlementRatio: number
  purchaseDept: string
  purchaseTime: string
  settlementMonth: string
  executor: string
}>>(loadProjectPurchaseFromStorage())

watch(projectPurchaseList, (newVal) => {
  localStorage.setItem('project_purchases', JSON.stringify(newVal))
}, { deep: true })
const showProjectPurchaseDialog = ref(false)
const isEditingProjectPurchase = ref(false)
const currentProjectPurchaseIndex = ref(-1)
const projectPurchaseForm = reactive({
  matter: '',
  item: '',
  quantity: 1,
  unitPrice: 0,
  totalPrice: 0,
  settlementRatio: 1,
  purchaseDept: '',
  purchaseTime: '',
  settlementMonth: '',
  executor: ''
})

const getPurchaseSettlementAmount = (row: any) => {
  const totalPrice = parseFloat(row.totalPrice) || 0
  const settlementRatio = parseFloat(row.settlementRatio) || 1
  return totalPrice * settlementRatio
}

// 过滤后的项目采购列表
const filteredProjectPurchaseList = computed(() => {
  return projectPurchaseList.value.filter(item => item.project_id === currentProject.value?.id)
})

const totalPurchaseSettlementAmount = computed(() => {
  return filteredProjectPurchaseList.value.reduce((sum, item) => {
    return sum + getPurchaseSettlementAmount(item)
  }, 0)
})

const virtualPersonSettlementAmount = computed(() => {
  let totalAmount = 0
  const virtualPersons = persons.value.filter((person: any) => 
    person.inputType === '虚拟' && person.project_id === currentProject.value?.id
  )
  
  virtualPersons.forEach((person: any) => {
    months.value.forEach(m => {
      const workDays = parseFloat(calculateMonthlyWorkDays(person, m))
      const unitPrice = parseFloat(person.priceWithTax) || 0
      const monthlyAmount = workDays * unitPrice
      totalAmount += monthlyAmount
    })
  })
  
  return totalAmount
})

const openAddProjectPurchase = () => {
  projectPurchaseForm.matter = ''
  projectPurchaseForm.item = ''
  projectPurchaseForm.quantity = 1
  projectPurchaseForm.unitPrice = 0
  projectPurchaseForm.totalPrice = 0
  projectPurchaseForm.settlementRatio = 1
  projectPurchaseForm.purchaseDept = ''
  projectPurchaseForm.purchaseTime = ''
  projectPurchaseForm.settlementMonth = ''
  projectPurchaseForm.executor = ''
  isEditingProjectPurchase.value = false
  currentProjectPurchaseIndex.value = -1
  showProjectPurchaseDialog.value = true
}

const editProjectPurchase = (row: any, index: number) => {
  projectPurchaseForm.matter = row.matter
  projectPurchaseForm.item = row.item
  projectPurchaseForm.quantity = row.quantity
  projectPurchaseForm.unitPrice = row.unitPrice
  projectPurchaseForm.totalPrice = row.totalPrice
  projectPurchaseForm.settlementRatio = row.settlementRatio
  projectPurchaseForm.purchaseDept = row.purchaseDept || ''
  projectPurchaseForm.purchaseTime = row.purchaseTime || ''
  projectPurchaseForm.settlementMonth = row.settlementMonth || ''
  projectPurchaseForm.executor = row.executor || ''
  isEditingProjectPurchase.value = true
  // 使用 row.id 在原始列表中找到正确的索引
  currentProjectPurchaseIndex.value = projectPurchaseList.value.findIndex(p => p.id === row.id)
  showProjectPurchaseDialog.value = true
}

const saveProjectPurchase = async () => {
  if (!projectPurchaseForm.matter) {
    ElMessage.warning('请填写采购事项')
    return
  }
  if (!projectPurchaseForm.item) {
    ElMessage.warning('请填写采购物品')
    return
  }

  try {
    // 准备后端API需要的数据格式
    const projectPurchaseData = {
      matter: projectPurchaseForm.matter,
      item: projectPurchaseForm.item,
      quantity: projectPurchaseForm.quantity,
      unit_price: projectPurchaseForm.unitPrice,
      total_price: projectPurchaseForm.totalPrice,
      settlement_ratio: projectPurchaseForm.settlementRatio,
      purchase_dept: projectPurchaseForm.purchaseDept,
      purchase_time: projectPurchaseForm.purchaseTime,
      settlement_month: projectPurchaseForm.settlementMonth,
      executor: projectPurchaseForm.executor
    }

    if (isEditingProjectPurchase.value) {
      // 编辑模式 - 调用更新API
      const currentPurchase = projectPurchaseList.value[currentProjectPurchaseIndex.value]
      if (currentPurchase.id) {
        await dataApi.updatePurchase(currentPurchase.id, projectPurchaseData)
      }
      projectPurchaseList.value[currentProjectPurchaseIndex.value] = { 
        ...projectPurchaseForm,
        id: currentPurchase.id,
        project_id: currentProject.value?.id || 0
      }
      ElMessage.success('修改成功')
    } else {
      // 新增模式 - 调用创建API
      const result = await dataApi.createPurchase(projectPurchaseData)
      projectPurchaseList.value.push({ 
        ...projectPurchaseForm,
        id: result.id,
        project_id: currentProject.value?.id || 0
      })
      ElMessage.success('添加成功')
    }

    showProjectPurchaseDialog.value = false
  } catch (error) {
    console.error('保存项目采购失败:', error)
    ElMessage.error('保存失败，请重试')
  }
}

const deleteProjectPurchase = async (index: number) => {
  try {
    // 从过滤后的列表中获取要删除的项
    const purchaseToDelete = filteredProjectPurchaseList.value[index]
    if (purchaseToDelete) {
      // 如果有ID，调用后端API删除
      if (purchaseToDelete.id) {
        await dataApi.deletePurchase(purchaseToDelete.id)
      }
      // 在原始列表中找到正确的索引并删除
      const originalIndex = projectPurchaseList.value.findIndex(p => p.id === purchaseToDelete.id)
      if (originalIndex !== -1) {
        projectPurchaseList.value.splice(originalIndex, 1)
      }
      ElMessage.success('删除成功')
    }
  } catch (error) {
    console.error('删除项目采购失败:', error)
    ElMessage.error('删除失败，请重试')
  }
}

const calculateTotalPrice = () => {
  projectPurchaseForm.totalPrice = projectPurchaseForm.quantity * projectPurchaseForm.unitPrice
}

// 计算所有唯一的部门
const departments = computed(() => {
  const currentProjectId = currentProject.value?.id
  const depts = new Set(persons.value
    .filter(person => person.project_id === currentProjectId)
    .map(person => person.settlementDept)
  )
  return Array.from(depts).filter(dept => dept)
})

// 统计部门人员数量
const departmentStats = computed(() => {
  const currentProjectId = currentProject.value?.id
  return departments.value.map(dept => {
    const projectPersons = persons.value.filter(person => person.project_id === currentProjectId)
    const allCount = projectPersons.filter(person => person.settlementDept === dept).length
    const activeCount = projectPersons.filter(person => person.settlementDept === dept && !person.exitDate).length
    return { dept, allCount, activeCount }
  })
})

// 分页相关
const currentPage = ref(1)
const pageSize = ref(300)
const totalPersons = ref(0)

// 编辑相关
const editingCell = ref('')
const editValue = ref('')
const inputRef = ref(null)

// 全屏相关
const isFullscreen = ref(false)
const fullscreenRef = ref(null)

// 根据合同周期动态计算月份列表（支持跨年）
const months = computed(() => {
  const contractPeriod = currentProject.value?.contractPeriod || '2026-01-01 ~ 2026-12-31'
  const [startStr, endStr] = contractPeriod.split(' ~ ')
  
  let startDate = new Date(startStr)
  let endDateStr = endStr
  
  // 如果结束日期没有年份，添加开始日期的年份
  if (endStr && (endStr.indexOf('-') === 2 || endStr.length === 5)) {
    const year = startDate.getFullYear()
    endDateStr = `${year}-${endStr}`
  }
  let endDate = new Date(endDateStr)
  
  const monthList: { year: number; month: number; label: string; key: string }[] = []
  
  let currentYear = startDate.getFullYear()
  let currentMonth = startDate.getMonth() + 1
  const endYear = endDate.getFullYear()
  const endMonth = endDate.getMonth() + 1
  
  while (currentYear < endYear || (currentYear === endYear && currentMonth <= endMonth)) {
    const yearShort = currentYear.toString().substring(2)
    monthList.push({
      year: currentYear,
      month: currentMonth,
      label: `${yearShort}年${currentMonth}月`,
      key: `${currentYear}-${String(currentMonth).padStart(2, '0')}`
    })
    
    currentMonth++
    if (currentMonth > 12) {
      currentMonth = 1
      currentYear++
    }
  }
  
  return monthList
})

// 项目数据 - 从localStorage加载
const loadProjectsFromStorage = () => {
  const saved = localStorage.getItem('project_list')
  if (saved) {
    try {
      return JSON.parse(saved)
    } catch (e) {
      return null
    }
  }
  return null
}

const defaultProjects = [
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
]

const projectList = ref(loadProjectsFromStorage() || [])
const groups = ref([])
const customers = ref([])

// 监听项目列表变化，自动保存到localStorage
watch(projectList, (newVal) => {
  localStorage.setItem('project_list', JSON.stringify(newVal))
}, { deep: true })

// 过滤后的项目列表
const filteredProjects = computed(() => {
  let projects = projectList.value
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    projects = projects.filter(project => 
      project.label.toLowerCase().includes(query) || 
      project.customer.toLowerCase().includes(query)
    )
  }
  
  return projects.sort((a, b) => {
    const statusOrder: Record<string, number> = {
      '进行中': 0,
      '已结束': 1
    }
    const orderA = statusOrder[a.status] ?? 0
    const orderB = statusOrder[b.status] ?? 0
    return orderA - orderB
  })
})

const sortedProjects = computed({
  get: () => {
    let projects = [...projectList.value]
    
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      projects = projects.filter(project => 
        project.label.toLowerCase().includes(query) || 
        project.customer.toLowerCase().includes(query)
      )
    }
    
    if (projectSortOrder.value && projectSortOrder.value.length > 0) {
      projects.sort((a, b) => {
        const indexA = projectSortOrder.value.indexOf(a.id)
        const indexB = projectSortOrder.value.indexOf(b.id)
        if (indexA !== -1 && indexB !== -1) {
          return indexA - indexB
        }
        if (indexA !== -1) return -1
        if (indexB !== -1) return 1
        const statusOrder: Record<string, number> = {
          '进行中': 0,
          '已结束': 1
        }
        const orderA = statusOrder[a.status] ?? 0
        const orderB = statusOrder[b.status] ?? 0
        return orderA - orderB
      })
    } else {
      projects.sort((a, b) => {
        const statusOrder: Record<string, number> = {
          '进行中': 0,
          '已结束': 1
        }
        const orderA = statusOrder[a.status] ?? 0
        const orderB = statusOrder[b.status] ?? 0
        return orderA - orderB
      })
    }
    
    return projects
  },
  set: (value) => {
    projectSortOrder.value = value.map(p => p.id)
    saveProjectSortOrder()
  }
})

const onDragEnd = () => {
  saveProjectSortOrder()
}

const currentProject = ref(null)

// 高级筛选选项计算属性
const teamOptions = computed(() => {
  if (!currentProject.value) return []
  const projectPersons = persons.value.filter(p => p.project_id === currentProject.value?.id && p.team)
  return [...new Set(projectPersons.map(p => p.team))].sort()
})

const contactOptions = computed(() => {
  if (!currentProject.value) return []
  const projectPersons = persons.value.filter(p => p.project_id === currentProject.value?.id && p.contact)
  return [...new Set(projectPersons.map(p => p.contact))].sort()
})

const settlementLevelOptions = computed(() => {
  if (!currentProject.value) return []
  const projectPersons = persons.value.filter(p => p.project_id === currentProject.value?.id && p.settlementLevel)
  return [...new Set(projectPersons.map(p => p.settlementLevel))].sort()
})

// 清除所有筛选
const clearAllFilters = () => {
  selectedTeam.value = ''
  selectedDept.value = ''
  selectedInputType.value = ''
  selectedContact.value = ''
  selectedSettlementLevel.value = ''
  selectedAttendanceStatus.value = ''
  personSearchQuery.value = ''
}

// 新建项目表单
const newProject = reactive({
  name: '',
  contractPeriod: [] as string[],
  type: '运营类',
  amount: '',
  group_id: '',
  customer_id: ''
})

const errors = reactive({
  name: '',
  contractPeriod: ''
})

// 合同数据
const contracts = ref([
  {
    project_id: 1,
    type: 'main',
    name: '成研运营项目管理系统合同',
    code: 'CY2026001',
    amount: '¥5,000,000.00',
    period: '2026-01-01 / 12-31',
    customer: '成都研发中心',
    attachment: null
  }
])

// 过滤后的合同列表
const filteredContracts = computed(() => {
  return contracts.value.filter(contract => 
    contract.type === currentContractType.value && 
    contract.project_id === currentProject.value?.id
  )
})

// 主合同是否存在
const mainContractExists = computed(() => {
  return contracts.value.some(contract => 
    contract.type === 'main' && 
    contract.project_id === currentProject.value?.id
  )
})

// 订单数据
const orders = ref([
  {
    project_id: 1,
    code: 'ORD2026001',
    period: '2026-01-01 / 01-31',
    orderDate: '2026-01-01',
    attachment: null
  }
])

// 过滤后的订单列表
const filteredOrders = computed(() => {
  return orders.value.filter(order => 
    order.project_id === currentProject.value?.id
  )
})

// 订单表单
const orderForm = reactive({
  project_id: 0,
  code: '',
  startDate: '',
  endDate: '',
  orderDate: '',
  amount: '',
  attachment: null
})

// 人员数据 - 从localStorage加载
const loadPersonsFromStorage = () => {
  const saved = localStorage.getItem('project_persons')
  if (saved) {
    try {
      const persons = JSON.parse(saved)
      // 确保单价字段是数字类型
      return persons.map((person: any) => ({
        ...person,
        priceWithTax: parseFloat(person.priceWithTax) || 0,
        priceWithoutTax: parseFloat(person.priceWithoutTax) || 0
      }))
    } catch (e) {
      return null
    }
  }
  return null
}

const defaultPersons = [
  {
    project_id: 1,
    name: '张三',
    employeeId: 'EMP001',
    team: '开发组',
    position: '前端工程师',
    settlementDept: '技术部',
    contact: '李四',
    entryDate: '2026-01-01',
    exitDate: '',
    settlementLevel: '高级',
    priceWithTax: 1000,
    priceWithoutTax: 943.4,
    inputType: '真实'
  }
]

const persons = ref(loadPersonsFromStorage() || defaultPersons)

// 监听人员数据变化，自动保存到localStorage
watch(persons, (newVal) => {
  localStorage.setItem('project_persons', JSON.stringify(newVal))
}, { deep: true })

// 人员表单
const personForm = reactive({
  name: '',
  employeeId: '',
  team: '',
  position: '',
  settlementDept: '',
  contact: '',
  entryDate: '',
  exitDate: '',
  settlementLevel: '',
  inputType: '真实', // 投入类型：真实或虚拟
  priceWithTax: 0,
  priceWithoutTax: 0
})

// 过滤后的人员列表
const filteredPersons = computed(() => {
  let result = persons.value.filter(person => 
    person.project_id === currentProject.value?.id
  )
  
  // 按小组筛选
  if (selectedTeam.value) {
    result = result.filter(person => person.team === selectedTeam.value)
  }
  
  // 按部门筛选
  if (selectedDept.value) {
    result = result.filter(person => person.settlementDept === selectedDept.value)
  }
  
  // 按投入类型筛选
  if (selectedInputType.value) {
    if (selectedInputType.value === 'actual') {
      result = result.filter(person => person.inputType === 'actual' || person.inputType === '实际')
    } else if (selectedInputType.value === 'virtual') {
      result = result.filter(person => person.inputType === 'virtual' || person.inputType === '虚拟')
    }
  }
  
  // 按对接人筛选
  if (selectedContact.value) {
    result = result.filter(person => person.contact === selectedContact.value)
  }
  
  // 按结算等级筛选
  if (selectedSettlementLevel.value) {
    result = result.filter(person => person.settlementLevel === selectedSettlementLevel.value)
  }
  
  // 按在场状态筛选
  if (selectedAttendanceStatus.value) {
    if (selectedAttendanceStatus.value === 'present') {
      result = result.filter(person => !person.exitDate)
    } else if (selectedAttendanceStatus.value === 'left') {
      result = result.filter(person => person.exitDate)
    }
  }
  
  // 按搜索查询筛选
  if (personSearchQuery.value) {
    const query = personSearchQuery.value.toLowerCase()
    result = result.filter(person => 
      person.name.toLowerCase().includes(query) ||
      person.position.toLowerCase().includes(query) ||
      person.team.toLowerCase().includes(query)
    )
  }
  
  // 更新总记录数
  totalPersons.value = result.length
  
  // 分页处理
  const startIndex = (currentPage.value - 1) * pageSize.value
  const endIndex = startIndex + pageSize.value
  return result.slice(startIndex, endIndex)
})

// 监听搜索和筛选变化，重置页码
watch([personSearchQuery, selectedDept, selectedTeam, selectedInputType, selectedContact, selectedSettlementLevel, selectedAttendanceStatus], () => {
  currentPage.value = 1
})

// 结算等级配置 - 从localStorage加载
const loadSettlementLevelsFromStorage = () => {
  const saved = localStorage.getItem('settlement_levels')
  if (saved) {
    try {
      return JSON.parse(saved)
    } catch (e) {
      return null
    }
  }
  return null
}

const defaultSettlementLevels: any[] = []

const settlementLevels = ref(loadSettlementLevelsFromStorage() || defaultSettlementLevels)

// 过滤后的结算等级配置
const filteredSettlementLevels = computed(() => {
  return settlementLevels.value.filter(level => level.project_id === currentProject.value?.id)
})

// 根据选择的集团过滤客户
const filteredCustomers = computed(() => {
  if (!editProject.group_id) {
    return []
  }
  return customers.value.filter(customer => customer.group_id === editProject.group_id)
})

// 项目创建时根据选择的集团过滤客户
const newProjectFilteredCustomers = computed(() => {
  if (!newProject.group_id) {
    return []
  }
  return customers.value.filter(customer => customer.group_id === newProject.group_id)
})

watch(settlementLevels, (newVal) => {
  localStorage.setItem('settlement_levels', JSON.stringify(newVal))
}, { deep: true })

// 立项配置 - 从localStorage加载
const loadApprovalConfigsFromStorage = () => {
  const saved = localStorage.getItem('project_approval_configs')
  if (saved) {
    try {
      return JSON.parse(saved)
    } catch (e) {
      return null
    }
  }
  return null
}

const approvalConfigs = ref(loadApprovalConfigsFromStorage() || [
  {
    project_id: 1,
    amount: '5,000,000.00',
    grossMargin: '30.00',
    settlementPeriods: []
  }
])

watch(approvalConfigs, (newVal) => {
  localStorage.setItem('project_approval_configs', JSON.stringify(newVal))
}, { deep: true })

// 当前项目的立项配置
const approvalConfig = computed(() => {
  const config = approvalConfigs.value.find(c => c.project_id === currentProject.value?.id)
  if (config) {
    return config
  }
  return {
    project_id: currentProject.value?.id || 0,
    amount: '',
    grossMargin: '',
    settlementPeriods: []
  }
})

// 立项配置表单（响应式）
const approvalConfigForm = reactive({
  amount: '',
  grossMargin: '',
  settlementPeriods: [] as Array<{
    startDate: string
    endDate: string
    assessmentDate: string
    paymentDate: string
  }>
})

// 打开立项配置对话框时，初始化表单数据
const openApprovalConfigDialog = async () => {
  const config = approvalConfigs.value.find(c => c.project_id === currentProject.value?.id)
  if (config) {
    approvalConfigForm.amount = config.amount || ''
    approvalConfigForm.grossMargin = config.grossMargin || ''
  } else {
    approvalConfigForm.amount = ''
    approvalConfigForm.grossMargin = ''
  }
  
  // 从后端加载结算周期数据
  try {
    const periods = await dataApi.getSettlementPeriods()
    if (periods && periods.length > 0) {
      approvalConfigForm.settlementPeriods = periods.map((p: any) => ({
        startDate: formatDate(p.start_date),
        endDate: formatDate(p.end_date),
        assessmentDate: formatDate(p.assessment_date),
        paymentDate: formatDate(p.payment_date)
      }))
    } else {
      approvalConfigForm.settlementPeriods = []
    }
  } catch (error) {
    console.error('加载结算周期失败:', error)
    approvalConfigForm.settlementPeriods = []
  }
  
  showApprovalConfigDialog.value = true
}

// 项目重要事项
const importantItems = ref([
  {
    project_id: 1,
    title: '项目启动会议',
    date: '2026-01-05',
    color: 'red'
  },
  {
    project_id: 1,
    title: '需求评审完成',
    date: '2026-01-20',
    color: 'red'
  }
])

// 过滤后的重要事项
const filteredImportantItems = computed(() => {
  return importantItems.value.filter(item => 
    item.project_id === currentProject.value?.id
  )
})

// 重要事项表单
const importantItemForm = reactive({
  title: '',
  color: 'red'
})

const isEditingImportantItem = ref(false)
const currentImportantItemIndex = ref(-1)

// 合同表单
const contractForm = reactive({
  name: '',
  code: '',
  amount: '',
  startDate: '',
  endDate: '',
  customer: '',
  attachment: null
})

// 编辑项目表单
const editProject = reactive({
  name: '',
  contractPeriod: [] as string[],
  type: '运营类',
  amount: '',
  approvalAmount: '',
  grossMargin: '',
  group_id: '',
  customer_id: ''
})

const editErrors = reactive({
  name: '',
  contractPeriod: ''
})

onMounted(async () => {
  // 从localStorage获取用户信息
  const userStr = localStorage.getItem('user')
  if (userStr) {
    const user = JSON.parse(userStr)
    console.log('用户信息:', user)
    loginAccount.value = user.username || ''
    username.value = user.username || 'Admin User'
    // 优先使用localStorage中的用户姓名
    userDisplayName.value = user.name || user.username || 'Admin User'
    console.log('显示姓名:', userDisplayName.value)
    userEmail.value = user.email || 'admin@chengyan.com'
    userRole.value = user.role || 'admin'
  } else {
    console.log('没有找到用户信息')
    username.value = 'Admin User'
    userDisplayName.value = 'Admin User'
    userEmail.value = 'admin@chengyan.com'
    userRole.value = 'admin'
  }
  
  // 加载项目排序
  projectSortOrder.value = loadProjectSortOrder()
  
  // 从系统用户数据中查找用户的显示姓名、邮箱和角色（作为备用）
  const systemUsers = localStorage.getItem('system_users')
  if (systemUsers) {
    const users = JSON.parse(systemUsers)
    const currentUser = users.find((u: any) => u.account === loginAccount.value || u.account === username.value)
    if (currentUser) {
      // 如果系统用户数据中有姓名，使用它
      if (currentUser.name) {
        userDisplayName.value = currentUser.name
      }
      if (currentUser.email) {
        userEmail.value = currentUser.email
      }
      if (currentUser.role) {
        userRole.value = currentUser.role
      }
    }
  }
  
  // 从后端加载项目列表
  await loadProjects()
  // 加载集团和客户数据
  await loadGroupsAndCustomers()
})

// 从后端加载项目列表
const loadProjects = async () => {
  try {
    // 强制清除 localStorage 中的项目列表数据，确保使用后端返回的最新数据
    localStorage.removeItem('project_list')
    localStorage.removeItem('project_persons')
    
    const projects = await projectApi.getAll()
    if (projects && projects.length > 0) {
      projectList.value = projects.map((p: any) => ({
        id: p.id,
        label: p.name,
        status: p.status,
        type: p.type,
        amount: p.amount ? p.amount.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) : '0.00',
        contractPeriod: p.contract_period || '',
        customer: p.customer || '',
        approvalAmount: p.approval_amount != null ? p.approval_amount.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) : '',
        grossMargin: p.gross_margin != null ? p.gross_margin : '',
        group_id: p.group_id || '',
        customer_id: p.customer_id || ''
      }))
      // 设置当前项目为第一个项目
      if (projectList.value.length > 0) {
        currentProject.value = projectList.value[0]
        // 保存当前项目ID到localStorage
        localStorage.setItem('current_project_id', projectList.value[0].id.toString())
        // 加载当前项目的财务数据
        await loadFinancialData()
        // 加载当前项目的权限
        await loadProjectPermissions()
      }
    } else {
      // 后端返回空列表，说明没有项目，清空 localStorage
      projectList.value = []
      currentProject.value = null
      localStorage.removeItem('project_list')
    }
  } catch (error) {
    console.error('加载项目列表失败:', error)
    // 清空项目列表，确保没有权限的项目不会显示
    projectList.value = []
    currentProject.value = null
    localStorage.removeItem('project_list')
  }
}

// 加载集团和客户数据
const loadGroupsAndCustomers = async () => {
  try {
    const groupsData = await dataApi.getGroups()
    groups.value = groupsData
    const customersData = await dataApi.getCustomers()
    customers.value = customersData
  } catch (error) {
    console.error('加载集团和客户数据失败:', error)
  }
}

// 加载财务数据
const loadFinancialData = async () => {
  if (!currentProject.value) return
  
  try {
    // 加载月成本数据
    const monthlyCosts = await dataApi.getMonthlyCosts()
    if (monthlyCosts && Array.isArray(monthlyCosts)) {
      monthlyCostList.value = monthlyCosts.map((cost: any) => ({
        id: cost.id,
        project_id: Number(cost.project_id) || 0,
        month: cost.month,
        directCost: cost.direct_cost,
        operatingCost: cost.operating_cost,
        sharedCost: cost.shared_cost
      }))
    }
    
    // 加载实际结算数据
    const actualSettlements = await dataApi.getActualSettlements()
    if (actualSettlements && Array.isArray(actualSettlements)) {
      actualSettlementList.value = actualSettlements.map((settlement: any) => ({
        id: settlement.id,
        project_id: Number(settlement.project_id) || 0,
        period: [formatDate(settlement.period_start), formatDate(settlement.period_end)],
        dept: settlement.dept,
        amountWithTax: settlement.amount_with_tax,
        amountWithoutTax: settlement.amount_without_tax
      }))
    }
    
    // 加载项目采购数据
    const purchases = await dataApi.getPurchases()
    if (purchases && Array.isArray(purchases)) {
      projectPurchaseList.value = purchases.map((purchase: any) => ({
        id: purchase.id,
        project_id: purchase.project_id,
        matter: purchase.matter,
        item: purchase.item,
        quantity: purchase.quantity,
        unitPrice: purchase.unit_price,
        totalPrice: purchase.total_price,
        settlementRatio: purchase.settlement_ratio,
        purchaseDept: purchase.purchase_dept,
        purchaseTime: purchase.purchase_time,
        settlementMonth: purchase.settlement_month,
        executor: purchase.executor
      }))
    }
    
    // 加载人员数据
    const personsData = await dataApi.getPersons()
    console.log('加载的人员数据:', personsData)
    if (personsData && Array.isArray(personsData)) {
      persons.value = personsData.map((person: any) => {
        // 处理日期格式
        let entryDate = person.entry_date
        let exitDate = person.exit_date
        
        // 确保日期是 YYYY-MM-DD 格式
        if (entryDate && typeof entryDate === 'string') {
          if (entryDate.includes('T')) {
            entryDate = entryDate.split('T')[0]
          }
        }
        if (exitDate && typeof exitDate === 'string') {
          if (exitDate.includes('T')) {
            exitDate = exitDate.split('T')[0]
          }
        }
        
        return {
          id: person.id,
          project_id: person.project_id,
          name: person.name,
          employeeId: person.employee_id,
          team: person.team,
          position: person.position,
          settlementDept: person.settlement_dept,
          contact: person.contact,
          entryDate: entryDate || '',
          exitDate: exitDate || '',
          settlementLevel: person.settlement_level,
          priceWithTax: parseFloat(person.price_with_tax) || 0,
          priceWithoutTax: parseFloat(person.price_without_tax) || 0,
          inputType: person.input_type === 'actual' ? '真实' : person.input_type === 'virtual' ? '虚拟' : person.input_type,
          workDays: {}
        }
      })
    }
    
    // 加载合同数据
    const contractsData = await dataApi.getContracts()
    if (contractsData && Array.isArray(contractsData)) {
      contracts.value = contractsData.map((contract: any) => {
        // 后端返回的是 period 字段，格式为 "startDate / endDate"
        const period = contract.period || ''
        
        return {
          id: contract.id,
          project_id: contract.project_id,
          type: contract.type,
          name: contract.name,
          code: contract.code,
          amount: contract.amount,
          period: period,
          customer: contract.customer,
          attachment: contract.attachment
        }
      })
    }
    
    // 加载订单数据
    const ordersData = await dataApi.getOrders()
    if (ordersData && Array.isArray(ordersData)) {
      orders.value = ordersData.map((order: any) => ({
        id: order.id,
        project_id: order.project_id,
        code: order.code,
        period: order.period || '',
        orderDate: order.orderDate || order.order_date,
        amount: order.amount,
        attachment: order.attachment
      }))
    }
    
    // 加载结算等级配置
    const settlementLevelsData = await dataApi.getSettlementLevels()
    if (settlementLevelsData && Array.isArray(settlementLevelsData)) {
      settlementLevels.value = settlementLevelsData.map((level: any) => ({
        id: level.id,
        project_id: level.project_id,
        name: level.name,
        priceWithTax: level.price_with_tax,
        priceWithoutTax: level.price_without_tax
      }))
      // 更新本地存储
      localStorage.setItem('settlement_levels', JSON.stringify(settlementLevels.value))
    }
    
    // 加载立项配置
    try {
      const approvalConfigData = await dataApi.getApprovalConfig()
      if (approvalConfigData) {
        // 检查是否已存在该项目的配置
        const existingIndex = approvalConfigs.value.findIndex(c => c.project_id === currentProject.value?.id)
        if (existingIndex !== -1) {
          approvalConfigs.value[existingIndex] = {
            project_id: approvalConfigData.project_id,
            amount: approvalConfigData.amount,
            grossMargin: approvalConfigData.gross_margin,
            settlementPeriods: approvalConfigData.settlement_periods || []
          }
        } else {
          approvalConfigs.value.push({
            project_id: approvalConfigData.project_id,
            amount: approvalConfigData.amount,
            grossMargin: approvalConfigData.gross_margin,
            settlementPeriods: approvalConfigData.settlement_periods || []
          })
        }
      }
    } catch (error) {
      console.log('加载立项配置失败或不存在:', error)
    }
  } catch (error) {
    console.error('加载财务数据失败:', error)
  }
}

const handleEnterManagement = () => {
  // 进入管理页面
  router.push('/management')
}

const handleLogout = () => {
  // 清除localStorage中的token和用户信息
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  
  ElMessage.success('退出登录成功')
  router.push('/login')
}

const handleChangePassword = () => {
  console.log('handleChangePassword called')
  console.log('Current showChangePasswordDialog value:', showChangePasswordDialog.value)
  // 打开修改密码弹窗
  showChangePasswordDialog.value = true
  console.log('After setting to true:', showChangePasswordDialog.value)
  // 重置表单
  Object.assign(changePasswordForm, {
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  })
  // 重置错误信息
  Object.assign(changePasswordErrors, {
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  })
  console.log('Form reset completed')
}

const handleSubmitChangePassword = async () => {
  // 表单验证
  let isValid = true
  
  // 重置错误信息
  Object.assign(changePasswordErrors, {
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  })
  
  if (!changePasswordForm.currentPassword) {
    changePasswordErrors.currentPassword = '请输入当前密码'
    isValid = false
  }
  
  if (!changePasswordForm.newPassword) {
    changePasswordErrors.newPassword = '请输入新密码'
    isValid = false
  } else if (changePasswordForm.newPassword.length < 6) {
    changePasswordErrors.newPassword = '新密码长度至少为6位'
    isValid = false
  }
  
  if (!changePasswordForm.confirmPassword) {
    changePasswordErrors.confirmPassword = '请确认新密码'
    isValid = false
  } else if (changePasswordForm.newPassword !== changePasswordForm.confirmPassword) {
    changePasswordErrors.confirmPassword = '两次输入的密码不一致'
    isValid = false
  }
  
  if (!isValid) return
  
  try {
    // 获取当前用户信息
    const userStr = localStorage.getItem('user')
    if (!userStr) {
      ElMessage.error('用户信息不存在')
      return
    }
    
    const user = JSON.parse(userStr)
    
    // 调用API更新密码
    await userApi.update(user.id, {
      name: user.name,
      email: user.email,
      role: user.role,
      password: changePasswordForm.newPassword
    })
    
    ElMessage.success('密码修改成功')
    showChangePasswordDialog.value = false
  } catch (error: any) {
    console.error('修改密码失败:', error)
    ElMessage.error(error.message || '修改密码失败，请重试')
  }
}

const handleProjectClick = async (project: any) => {
  currentProject.value = project
  // 保存当前项目到 localStorage
  localStorage.setItem('current_project_id', project.id.toString())
  // 加载当前项目的财务数据
  await loadFinancialData()
  // 加载当前项目的权限
  await loadProjectPermissions()
}

const handleEditProject = () => {
  if (currentProject.value) {
    // 填充编辑表单
    editProject.name = currentProject.value.label || ''
    
    // 解析合同周期字符串为数组
    const periodStr = currentProject.value.contractPeriod || ''
    console.log('periodStr:', periodStr)
    
    if (periodStr && periodStr.includes(' ~ ') && !periodStr.includes('undefined')) {
      const parts = periodStr.split(' ~ ')
      if (parts.length === 2 && parts[0] && parts[1]) {
        // 直接使用完整日期
        editProject.contractPeriod = [parts[0], parts[1]]
      } else {
        editProject.contractPeriod = []
      }
    } else {
      editProject.contractPeriod = []
    }
    
    console.log('editProject.contractPeriod after parse:', editProject.contractPeriod)
    
    editProject.type = currentProject.value.type || '运营类'
    editProject.amount = currentProject.value.amount || ''
    editProject.approvalAmount = currentProject.value.approvalAmount || ''
    editProject.grossMargin = currentProject.value.grossMargin || ''
    editProject.group_id = currentProject.value.group_id || ''
    editProject.customer_id = currentProject.value.customer_id || ''
    
    // 重置错误信息
    Object.assign(editErrors, {
      name: '',
      contractPeriod: ''
    })
    
    // 显示编辑对话框
    showEditProjectDialog.value = true
  }
}

const updateProject = async () => {
  // 表单验证
  let isValid = true
  
  if (!editProject.name) {
    editErrors.name = '请输入项目名称'
    isValid = false
  } else {
    editErrors.name = ''
  }
  
  if (!editProject.contractPeriod || editProject.contractPeriod.length !== 2) {
    editErrors.contractPeriod = '请选择合同周期'
    isValid = false
  } else {
    editErrors.contractPeriod = ''
  }
  
  if (!editProject.customer_id) {
    ElMessage.warning('请选择所属客户')
    isValid = false
  }
  
  if (!isValid) return
  
  // 从所选客户中获取客户名称
  const selectedCustomer = customers.value.find(c => c.id === editProject.customer_id)
  const customerName = selectedCustomer ? selectedCustomer.name : ''
  
  // 格式化合同周期（保留完整日期）
  let contractPeriodStr = ''
  console.log('editProject.contractPeriod:', editProject.contractPeriod)
  if (editProject.contractPeriod && editProject.contractPeriod.length === 2) {
    contractPeriodStr = `${editProject.contractPeriod[0]} ~ ${editProject.contractPeriod[1]}`
  }
  console.log('contractPeriodStr:', contractPeriodStr)
  
  try {
    // 检查 currentProject 是否存在
    if (!currentProject.value || !currentProject.value.id) {
      ElMessage.error('项目信息不存在，请重新选择项目')
      return
    }
    
    // 调用后端API更新项目
    await projectApi.update(currentProject.value.id, {
      name: editProject.name,
      status: currentProject.value.status,
      type: editProject.type,
      amount: parseFloat(editProject.amount) || 0,
      contract_period: contractPeriodStr || null,
      customer: customerName,
      group_id: editProject.group_id || null,
      customer_id: editProject.customer_id || null,
      approval_amount: parseFloat((editProject.approvalAmount || '').replace(/,/g, '')) || 0,
      gross_margin: parseFloat(editProject.grossMargin) || 0
    })
    
    // 找到并更新项目
    const projectIndex = projectList.value.findIndex(p => p.id === currentProject.value.id)
    if (projectIndex !== -1) {
      projectList.value[projectIndex] = {
        ...projectList.value[projectIndex],
        label: editProject.name,
        type: editProject.type,
        amount: editProject.amount,
        contractPeriod: contractPeriodStr,
        customer: customerName,
        group_id: editProject.group_id,
        customer_id: editProject.customer_id
      }
      
      // 更新当前项目
      currentProject.value = projectList.value[projectIndex]
      
      showEditProjectDialog.value = false
      ElMessage.success('项目更新成功')
    }
  } catch (error: any) {
    console.error('更新项目失败:', error)
    ElMessage.error(`更新项目失败: ${error.message || '请重试'}`)
  }
}

const createProject = async () => {
  // 表单验证
  let isValid = true
  
  if (!newProject.name) {
    errors.name = '请输入项目名称'
    isValid = false
  } else {
    errors.name = ''
  }
  
  if (!newProject.contractPeriod || newProject.contractPeriod.length !== 2) {
    errors.contractPeriod = '请选择合同周期'
    isValid = false
  } else {
    errors.contractPeriod = ''
  }
  
  if (!newProject.customer_id) {
    ElMessage.warning('请选择所属客户')
    isValid = false
  }
  
  if (!isValid) return
  
  // 从所选客户中获取客户名称
  const selectedCustomer = customers.value.find(c => c.id === newProject.customer_id)
  const customerName = selectedCustomer ? selectedCustomer.name : ''
  
  // 格式化合同周期（保留完整日期）
  let contractPeriodStr = ''
  if (newProject.contractPeriod && newProject.contractPeriod.length === 2) {
    contractPeriodStr = `${newProject.contractPeriod[0]} ~ ${newProject.contractPeriod[1]}`
  }
  
  // 调用后端API创建项目
  try {
    const createdProject = await projectApi.create({
      name: newProject.name,
      status: '进行中',
      type: newProject.type,
      amount: parseFloat(newProject.amount) || 0,
      contract_period: contractPeriodStr || null,
      customer: customerName,
      group_id: newProject.group_id || null,
      customer_id: newProject.customer_id || null,
      approval_amount: null,
      gross_margin: null
    })
    
    // 添加到项目列表
    const newProjectData = {
      id: createdProject.id,
      label: createdProject.name,
      status: createdProject.status,
      type: createdProject.type,
      amount: createdProject.amount ? createdProject.amount.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) : '0.00',
      contractPeriod: createdProject.contract_period || '',
      customer: createdProject.customer || '',
      approvalAmount: createdProject.approval_amount ? createdProject.approval_amount.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) : '0.00',
      grossMargin: createdProject.gross_margin || '0.00'
    }
    
    projectList.value.push(newProjectData)
    showCreateProjectDialog.value = false
    
    // 强制触发项目列表更新
    projectList.value = [...projectList.value]
    
    // 自动选择新创建的项目
    currentProject.value = newProjectData
    
    // 为当前用户添加管理权限
    const userStr = localStorage.getItem('user')
    if (userStr) {
      const user = JSON.parse(userStr)
      // 直接使用 localStorage 中保存的用户 ID
      if (user.id) {
        try {
          await projectApi.addPermission(createdProject.id, {
            user_id: user.id,
            permission: 'manage'
          })
          console.log('为当前用户添加管理权限成功')
        } catch (error) {
          console.error('添加权限失败:', error)
        }
      } else {
        console.warn('用户信息中没有ID，无法添加权限')
      }
    }
    
    // 加载项目权限
    await loadProjectPermissions()
    
    // 重置表单
    Object.assign(newProject, {
      name: '',
      contractPeriod: [],
      type: '运营类',
      amount: '',
      group_id: '',
      customer_id: ''
    })
    
    ElMessage.success('项目创建成功')
  } catch (error) {
    console.error('创建项目失败:', error)
    ElMessage.error('创建项目失败，请重试')
  }
}

const handleEndProject = () => {
  if (!currentProject.value) {
    ElMessage.warning('请先选择项目')
    return
  }
  
  ElMessageBox.confirm(
    `确定要结束项目 "${currentProject.value.label}" 吗？结束后项目将变为只读状态。`,
    '确认结束项目',
    {
      confirmButtonText: '确定结束',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      // 调用后端API更新项目状态，传递完整的项目信息
      await projectApi.update(currentProject.value.id, {
        name: currentProject.value.label,
        status: '已结束',
        type: currentProject.value.type,
        amount: parseFloat(currentProject.value.amount.replace(/,/g, '')) || 0,
        contract_period: currentProject.value.contractPeriod,
        customer: currentProject.value.customer,
        group_id: currentProject.value.group_id || null,
        customer_id: currentProject.value.customer_id || null,
        approval_amount: parseFloat(currentProject.value.approvalAmount.replace(/,/g, '')) || 0,
        gross_margin: parseFloat(currentProject.value.grossMargin) || 0
      })
      
      const projectIndex = projectList.value.findIndex(p => p.id === currentProject.value?.id)
      if (projectIndex !== -1) {
        projectList.value[projectIndex].status = '已结束'
        currentProject.value = { ...currentProject.value, status: '已结束' }
        ElMessage.success('项目已结束')
      }
    } catch (error) {
      console.error('结束项目失败:', error)
      ElMessage.error('结束项目失败，请重试')
    }
  }).catch(() => {})
}

// 项目权限管理相关函数
const loadProjectPermissions = async () => {
  if (!currentProject.value || !currentProject.value.id) {
    console.error('加载项目权限失败: 项目不存在或项目ID不存在', currentProject.value)
    return
  }
  
  console.log('开始加载项目权限，项目ID:', currentProject.value.id)
  
  try {
    const permissions = await projectApi.getPermissions(currentProject.value.id)
    console.log('加载项目权限成功，数据:', permissions)
    projectPermissions.value = permissions
    
    // 更新当前用户的权限
    updateCurrentUserPermission()
  } catch (error: any) {
    console.error('加载项目权限失败:', error.message || error)
    console.error('错误详情:', error)
    // 不要显示错误消息，因为这可能是正常的权限检查失败
    // ElMessage.error(`加载项目权限失败: ${error.message || '未知错误'}`)
  }
}

// 当前用户的权限
const currentUserPermission = ref('')

// 更新当前用户的权限
const updateCurrentUserPermission = () => {
  const userStr = localStorage.getItem('user')
  if (!userStr) return
  
  const user = JSON.parse(userStr)
  const userPermission = projectPermissions.value.find(
    (perm: any) => perm.user_account === user.username
  )
  
  currentUserPermission.value = userPermission?.permission || ''
  console.log('当前用户权限:', currentUserPermission.value)
}

// 检查用户是否有管理权限
const hasManagePermission = computed(() => {
  return currentUserPermission.value === 'manage'
})

// 检查用户是否有查看权限
const hasViewPermission = computed(() => {
  return currentUserPermission.value === 'view' || currentUserPermission.value === 'manage'
})

const loadSystemUsers = async () => {
  try {
    const users = await userApi.getAll()
    systemUsers.value = users
  } catch (error) {
    console.error('加载系统用户失败:', error)
    ElMessage.error('加载系统用户失败')
  }
}

const addProjectPermission = async () => {
  if (!currentProject.value?.id || !permissionForm.user_id) {
    ElMessage.warning('请选择用户')
    return
  }
  
  try {
    await projectApi.addPermission(currentProject.value.id, {
      user_id: permissionForm.user_id,
      permission: permissionForm.permission
    })
    await loadProjectPermissions()
    ElMessage.success('权限添加成功')
    // 重置表单
    permissionForm.user_id = ''
    permissionForm.permission = 'view'
  } catch (error) {
    console.error('添加权限失败:', error)
    ElMessage.error('添加权限失败')
  }
}

const deleteProjectPermission = async (userId: number) => {
  if (!currentProject.value?.id) return
  
  ElMessageBox.confirm(
    '确定要删除该用户的权限吗？',
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      await projectApi.deletePermission(currentProject.value!.id, userId)
      await loadProjectPermissions()
      ElMessage.success('权限删除成功')
    } catch (error) {
      console.error('删除权限失败:', error)
      ElMessage.error('删除权限失败')
    }
  }).catch(() => {})  // 取消操作
}

// 打开项目权限对话框
const openProjectPermissionsDialog = async () => {
  if (!currentProject.value) {
    ElMessage.warning('请先选择项目')
    return
  }
  
  await loadProjectPermissions()
  await loadSystemUsers()
  showProjectPermissionsDialog.value = true
}

const handleDeleteProject = () => {
  if (!currentProject.value) {
    ElMessage.warning('请先选择项目')
    return
  }
  
  if (!currentProject.value.id) {
    ElMessage.warning('项目ID无效')
    console.error('项目ID无效:', currentProject.value)
    return
  }
  
  ElMessageBox.confirm(
    `确定要删除项目 "${currentProject.value.label}" 吗？删除后将清除该项目的所有数据，此操作不可恢复！`,
    '确认删除项目',
    {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'error',
      confirmButtonClass: 'el-button--danger'
    }
  ).then(async () => {
    try {
      console.log('正在删除项目，ID:', currentProject.value.id, '类型:', typeof currentProject.value.id)
      
      // 调用后端API删除项目
      await projectApi.delete(currentProject.value.id)
      
      const projectIndex = projectList.value.findIndex(p => p.id === currentProject.value?.id)
      if (projectIndex !== -1) {
        projectList.value.splice(projectIndex, 1)
        
        // 重新从后端加载项目列表，确保数据一致性
        await loadProjects()
        
        ElMessage.success('项目已删除')
      }
    } catch (error: any) {
      console.error('删除项目失败:', error)
      ElMessage.error(`删除项目失败: ${error.message || '请重试'}`)
    }
  }).catch(() => {})
}

const addSettlementLevel = () => {
  settlementLevels.value.push({
    project_id: currentProject.value?.id || 0,
    name: '',
    priceWithTax: 0,
    priceWithoutTax: 0
  })
}

const removeSettlementLevel = async (index: number) => {
  // 找到过滤后的索引对应的实际索引
  const levelToDelete = filteredSettlementLevels.value[index]
  const actualIndex = settlementLevels.value.findIndex(l => 
    l.name === levelToDelete.name && l.project_id === levelToDelete.project_id
  )
  if (actualIndex !== -1) {
    try {
      // 如果有ID，调用后端API删除
      if (levelToDelete.id) {
        await dataApi.deleteSettlementLevel(levelToDelete.id)
      }
      // 从本地数组中删除
      settlementLevels.value.splice(actualIndex, 1)
      // 更新本地存储
      localStorage.setItem('settlement_levels', JSON.stringify(settlementLevels.value))
      ElMessage.success('结算等级删除成功')
    } catch (error) {
      console.error('删除结算等级失败:', error)
      ElMessage.error('删除失败，请重试')
    }
  }
}

const saveSettlementConfig = async () => {
  try {
    // 验证是否有结算等级配置
    if (filteredSettlementLevels.value.length === 0) {
      ElMessage.warning('请先添加结算等级配置')
      return
    }
    
    // 验证结算等级配置是否完整
    for (const level of filteredSettlementLevels.value) {
      if (!level.name) {
        ElMessage.warning('请填写结算等级名称')
        return
      }
    }
    
    // 保存结算等级配置到后端
    for (const level of filteredSettlementLevels.value) {
      const levelData = {
        name: level.name,
        price_with_tax: Number(level.priceWithTax) || 0,
        price_without_tax: Number(level.priceWithoutTax) || 0,
        project_id: currentProject.value?.id
      }
      
      console.log('准备保存结算等级:', level.id ? '更新' : '创建', levelData)
      
      if (level.id) {
        // 更新现有配置
        await dataApi.updateSettlementLevel(level.id, levelData)
      } else {
        // 检查是否已经存在相同名称的等级
        const existingLevel = settlementLevels.value.find(l => 
          l.name === level.name && 
          l.project_id === level.project_id && 
          l.id
        )
        
        if (existingLevel) {
          // 更新现有等级
          await dataApi.updateSettlementLevel(existingLevel.id, levelData)
          // 更新本地数据
          const index = settlementLevels.value.findIndex(l => l.id === existingLevel.id)
          if (index !== -1) {
            settlementLevels.value[index] = {
              ...settlementLevels.value[index],
              priceWithTax: level.priceWithTax,
              priceWithoutTax: level.priceWithoutTax
            }
          }
        } else {
          // 创建新配置
          try {
            const result = await dataApi.createSettlementLevel(levelData)
            console.log('创建结算等级结果:', result)
            // 更新本地数据的 ID
            if (result && result.id) {
              const index = settlementLevels.value.findIndex(l => 
                l.name === level.name && l.project_id === level.project_id && !l.id
              )
              if (index !== -1) {
                settlementLevels.value[index].id = result.id
              }
            }
          } catch (error: any) {
            // 如果是重复创建错误，尝试查找并更新现有等级
            if (error.message && error.message.includes('Duplicate entry')) {
              console.log('检测到重复创建，尝试更新现有等级')
              // 重新获取所有结算等级
              const allLevels = await dataApi.getSettlementLevels()
              const duplicateLevel = allLevels.find(l => 
                l.name === level.name && 
                l.project_id === level.project_id
              )
              if (duplicateLevel && duplicateLevel.id) {
                await dataApi.updateSettlementLevel(duplicateLevel.id, levelData)
                // 更新本地数据
                const index = settlementLevels.value.findIndex(l => 
                  l.name === level.name && l.project_id === level.project_id && !l.id
                )
                if (index !== -1) {
                  settlementLevels.value[index].id = duplicateLevel.id
                }
              }
            } else {
              throw error
            }
          }
        }
      }
    }
    
    // 更新当前项目的人员单价
    persons.value.forEach((person: any) => {
      if (person.project_id !== currentProject.value?.id) {
        return
      }
      if (person.settlementLevel) {
        const levelConfig = filteredSettlementLevels.value.find(level => level.name === person.settlementLevel)
        if (levelConfig) {
          person.priceWithTax = levelConfig.priceWithTax
          person.priceWithoutTax = levelConfig.priceWithoutTax
        }
      }
    })
    
    console.log('保存结算配置:', filteredSettlementLevels.value)
    ElMessage.success('结算配置保存成功，人员单价已更新')
    showSettlementConfigDialog.value = false
  } catch (error: any) {
    console.error('保存结算配置失败:', error)
    const errorMessage = error?.message || error?.error || '保存失败，请重试'
    ElMessage.error(`保存结算配置失败: ${errorMessage}`)
  }
}

const addSettlementPeriod = () => {
  approvalConfigForm.settlementPeriods.push({
    startDate: '',
    endDate: '',
    assessmentDate: '',
    paymentDate: ''
  })
}

const removeSettlementPeriod = (index: number) => {
  approvalConfigForm.settlementPeriods.splice(index, 1)
}

const saveApprovalConfig = async () => {
  try {
    // 保存立项配置到后端
    await dataApi.saveApprovalConfig({
      project_id: currentProject.value?.id,
      amount: approvalConfigForm.amount,
      gross_margin: approvalConfigForm.grossMargin
    })
    
    // 先删除现有的结算周期
    const existingPeriods = await dataApi.getSettlementPeriods()
    for (const period of existingPeriods) {
      if (period.id) {
        await dataApi.deleteSettlementPeriod(period.id)
      }
    }
    
    // 保存新的结算周期
    for (const period of approvalConfigForm.settlementPeriods) {
      if (period.startDate || period.endDate || period.assessmentDate || period.paymentDate) {
        // 将日期格式转换为 YYYY-MM-DD
        const formatDate = (date: string) => {
          if (!date) return null
          // 如果已经是 YYYY-MM-DD 格式，直接返回
          if (typeof date === 'string' && date.match(/^\d{4}-\d{2}-\d{2}$/)) {
            return date
          }
          // 否则转换为 YYYY-MM-DD 格式
          const d = new Date(date)
          return d.toISOString().split('T')[0]
        }
        
        await dataApi.createSettlementPeriod({
          start_date: formatDate(period.startDate),
          end_date: formatDate(period.endDate),
          assessment_date: formatDate(period.assessmentDate),
          payment_date: formatDate(period.paymentDate)
        })
      }
    }
    
    // 查找是否已存在该项目的配置
    const existingIndex = approvalConfigs.value.findIndex(c => c.project_id === currentProject.value?.id)
    
    if (existingIndex !== -1) {
      // 更新现有配置
      approvalConfigs.value[existingIndex] = {
        project_id: currentProject.value?.id || 0,
        amount: approvalConfigForm.amount,
        grossMargin: approvalConfigForm.grossMargin,
        settlementPeriods: [...approvalConfigForm.settlementPeriods]
      }
    } else {
      // 添加新配置
      approvalConfigs.value.push({
        project_id: currentProject.value?.id || 0,
        amount: approvalConfigForm.amount,
        grossMargin: approvalConfigForm.grossMargin,
        settlementPeriods: [...approvalConfigForm.settlementPeriods]
      })
    }
    
    console.log('保存立项配置:', approvalConfigForm)
    
    // 更新当前项目的立项金额和毛利率
    if (currentProject.value) {
      const projectIndex = projectList.value.findIndex(p => p.id === currentProject.value?.id)
      if (projectIndex !== -1) {
        projectList.value[projectIndex] = {
          ...projectList.value[projectIndex],
          approvalAmount: approvalConfigForm.amount,
          grossMargin: approvalConfigForm.grossMargin
        }
        currentProject.value = projectList.value[projectIndex]
      }
    }
    
    ElMessage.success('立项配置保存成功')
    showApprovalConfigDialog.value = false
  } catch (error) {
    console.error('保存立项配置失败:', error)
    ElMessage.error('保存立项配置失败')
  }
}

// 项目重要事项方法
const editImportantItem = (index: number) => {
  const item = importantItems.value[index]
  importantItemForm.title = item.title
  importantItemForm.color = item.color
  isEditingImportantItem.value = true
  currentImportantItemIndex.value = index
  showAddImportantItemDialog.value = true
}

const deleteImportantItem = (index: number) => {
  importantItems.value.splice(index, 1)
  ElMessage.success('重要事项删除成功')
}

const saveImportantItem = () => {
  const today = new Date().toISOString().split('T')[0]
  
  if (isEditingImportantItem.value && currentImportantItemIndex.value !== -1) {
    // 编辑现有事项
    importantItems.value[currentImportantItemIndex.value] = {
      ...importantItems.value[currentImportantItemIndex.value],
      title: importantItemForm.title,
      color: importantItemForm.color
    }
    ElMessage.success('重要事项编辑成功')
  } else {
    // 添加新事项
    importantItems.value.push({
      project_id: currentProject.value?.id,
      title: importantItemForm.title,
      date: today, // 自动记录当前日期
      color: importantItemForm.color
    })
    ElMessage.success('重要事项添加成功')
  }
  
  // 重置表单
  importantItemForm.title = ''
  importantItemForm.color = 'red' // 重置为默认颜色
  isEditingImportantItem.value = false
  currentImportantItemIndex.value = -1
  showAddImportantItemDialog.value = false
}

// 合同管理方法
const handleFileUpload = (event: any) => {
  const file = event.target.files[0]
  if (file && file.type === 'application/pdf') {
    contractForm.attachment = file
  } else {
    ElMessage.error('请上传PDF格式的文件')
  }
}

const saveContract = async () => {
  // 验证表单
  if (!contractForm.name || !contractForm.code || !contractForm.amount || !contractForm.startDate || !contractForm.endDate || !contractForm.customer) {
    ElMessage.error('请填写所有必填字段')
    return
  }
  
  try {
    // 合并开始日期和结束日期为period字段
    const period = `${contractForm.startDate} / ${contractForm.endDate}`
    
    let attachmentPath = contractForm.attachment
    
    // 如果有文件需要上传
    if (contractForm.attachment && contractForm.attachment instanceof File) {
      ElMessage.info('正在上传文件...')
      const uploadResult = await uploadApi.uploadFile(contractForm.attachment)
      attachmentPath = uploadResult.filePath
    }
    
    // 准备后端API需要的数据格式
    const contractData = {
      type: currentContractType.value,
      name: contractForm.name,
      code: contractForm.code,
      amount: contractForm.amount,
      period: period,
      customer: contractForm.customer,
      attachment: attachmentPath
    }
    
    if (isEditingContract.value && currentContractIndex.value !== -1) {
      // 更新现有合同
      const currentContract = contracts.value[currentContractIndex.value]
      if (currentContract.id) {
        await dataApi.updateContract(currentContract.id, contractData)
      }
      contracts.value[currentContractIndex.value] = {
        ...contractData,
        id: currentContract.id,
        project_id: currentProject.value?.id,
        period: period
      }
      ElMessage.success('合同更新成功')
      // 重置编辑状态
      isEditingContract.value = false
      currentContractIndex.value = -1
    } else {
      // 添加新合同
      const createdContract = await dataApi.createContract(contractData)
      // 合并开始日期和结束日期为period字段
      const period = `${contractForm.startDate} / ${contractForm.endDate}`
      contracts.value.push({
        ...contractData,
        id: createdContract.id,
        project_id: currentProject.value?.id,
        period: period
      })
      ElMessage.success('合同添加成功')
    }
    
    // 重置表单
    Object.assign(contractForm, {
      name: '',
      code: '',
      amount: '',
      startDate: '',
      endDate: '',
      customer: '',
      attachment: null
    })
    
    showAddContractDialog.value = false
  } catch (error) {
    console.error('保存合同失败:', error)
    ElMessage.error('保存失败，请重试')
  }
}

const previewAttachment = (attachment: any) => {
  if (!attachment) {
    ElMessage.error('没有附件可预览')
    return
  }
  
  // 构建完整的预览URL
  const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000'
  const previewUrl = `${baseUrl}/uploads/preview/${attachment.split('/').pop()}`
  
  // 打开新窗口预览
  window.open(previewUrl, '_blank')
  console.log('预览附件:', attachment, '预览URL:', previewUrl)
}

const downloadAttachment = (attachment: any) => {
  if (!attachment) {
    ElMessage.error('没有附件可下载')
    return
  }
  
  const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000'
  const filename = attachment.split('/').pop()
  const downloadUrl = `${baseUrl}/uploads/download/${filename}`
  
  // 获取token
  const token = localStorage.getItem('token')
  if (!token) {
    ElMessage.error('请先登录')
    return
  }
  
  // 使用fetch下载文件
  fetch(downloadUrl, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  })
  .then(response => {
    if (!response.ok) {
      throw new Error('下载失败')
    }
    return response.blob()
  })
  .then(blob => {
    // 创建下载链接
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
  })
  .catch(error => {
    console.error('下载失败:', error)
    ElMessage.error('下载失败，请重试')
  })
}

// 编辑合同相关状态
const isEditingContract = ref(false)
const currentContractIndex = ref(-1)

// 打开添加合同对话框
const openAddContractDialog = () => {
  // 重置表单
  contractForm.name = ''
  contractForm.code = ''
  contractForm.amount = ''
  contractForm.startDate = ''
  contractForm.endDate = ''
  contractForm.customer = ''
  contractForm.attachment = null
  
  // 设置为添加模式
  isEditingContract.value = false
  currentContractIndex.value = -1
  
  // 显示对话框
  showAddContractDialog.value = true
}

const editContract = (contract: any) => {
  // 填充表单数据
  contractForm.name = contract.name
  contractForm.code = contract.code
  contractForm.amount = contract.amount
  
  // 解析开始日期和结束日期
  if (contract.period && !contract.period.includes('undefined')) {
    const [startDate, endDate] = contract.period.split(' / ')
    contractForm.startDate = startDate || ''
    contractForm.endDate = endDate || ''
  } else {
    contractForm.startDate = ''
    contractForm.endDate = ''
  }
  
  contractForm.customer = contract.customer || ''
  contractForm.attachment = contract.attachment || null
  
  // 设置编辑状态
  isEditingContract.value = true
  // 找到当前合同在 contracts 数组中的索引
  currentContractIndex.value = contracts.value.findIndex(c => 
    c.type === contract.type && 
    c.name === contract.name && 
    c.code === contract.code
  )
  
  // 显示编辑对话框
  showAddContractDialog.value = true
}

const deleteContract = async (index: number) => {
  // 获取要删除的合同
  const contractToDelete = filteredContracts.value[index]
  
  try {
    // 如果有ID，调用后端API删除
    if (contractToDelete.id) {
      await dataApi.deleteContract(contractToDelete.id)
    }
    
    // 从contracts数组中找到并删除该合同
    const contractIndex = contracts.value.findIndex(c => 
      c.type === contractToDelete.type && 
      c.name === contractToDelete.name && 
      c.code === contractToDelete.code
    )
    
    if (contractIndex !== -1) {
      contracts.value.splice(contractIndex, 1)
      ElMessage.success('合同删除成功')
    }
  } catch (error) {
    console.error('删除合同失败:', error)
    ElMessage.error('删除失败，请重试')
  }
}

// 订单管理方法
const handleOrderFileUpload = (event: any) => {
  const file = event.target.files[0]
  if (file && file.type === 'application/pdf') {
    orderForm.attachment = file
  } else {
    ElMessage.error('请上传PDF格式的文件')
  }
}

const saveOrder = async () => {
  // 验证表单
  if (!orderForm.code || !orderForm.startDate || !orderForm.endDate || !orderForm.orderDate || !orderForm.amount) {
    ElMessage.error('请填写所有必填字段')
    return
  }
  
  try {
    let attachmentPath = orderForm.attachment
    
    // 如果有文件需要上传
    if (orderForm.attachment && orderForm.attachment instanceof File) {
      ElMessage.info('正在上传文件...')
      const uploadResult = await uploadApi.uploadFile(orderForm.attachment)
      attachmentPath = uploadResult.filePath
    }
    
    // 准备后端API需要的数据格式
    const orderData = {
      code: orderForm.code,
      start_date: orderForm.startDate,
      end_date: orderForm.endDate,
      order_date: orderForm.orderDate,
      amount: parseFloat(orderForm.amount) || 0,
      attachment: attachmentPath
    }
    
    console.log('保存订单数据:', orderData)
    
    if (isEditingOrder.value && currentOrderIndex.value !== -1) {
      // 编辑现有订单
      const currentOrder = orders.value[currentOrderIndex.value]
      console.log('编辑订单 - 当前订单:', currentOrder, '索引:', currentOrderIndex.value)
      if (currentOrder.id) {
        console.log('调用更新API，ID:', currentOrder.id)
        await dataApi.updateOrder(currentOrder.id, orderData)
      }
      // 合并开始日期和结束日期为period字段
      const period = `${orderForm.startDate} / ${orderForm.endDate}`
      orders.value[currentOrderIndex.value] = {
        ...orderData,
        id: currentOrder.id,
        project_id: currentProject.value?.id,
        period: period
      }
      ElMessage.success('订单编辑成功')
    } else {
      // 添加新订单
      const createdOrder = await dataApi.createOrder(orderData)
      // 合并开始日期和结束日期为period字段
      const period = `${orderForm.startDate} / ${orderForm.endDate}`
      orders.value.push({
        ...orderData,
        id: createdOrder.id,
        project_id: currentProject.value?.id,
        period: period
      })
      ElMessage.success('订单添加成功')
    }
    
    // 重置表单
    Object.assign(orderForm, {
      code: '',
      startDate: '',
      endDate: '',
      orderDate: '',
      amount: '',
      attachment: null
    })
    
    showAddOrderDialog.value = false
    isEditingOrder.value = false
    currentOrderIndex.value = -1
  } catch (error) {
    console.error('保存订单失败:', error)
    ElMessage.error('保存失败，请重试')
  }
}

const previewOrderAttachment = (attachment: any) => {
  if (!attachment) {
    ElMessage.error('没有附件可预览')
    return
  }
  
  // 构建完整的预览URL
  const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000'
  const previewUrl = `${baseUrl}/uploads/preview/${attachment.split('/').pop()}`
  
  // 打开新窗口预览
  window.open(previewUrl, '_blank')
  console.log('预览订单附件:', attachment, '预览URL:', previewUrl)
}

const downloadOrderAttachment = (attachment: any) => {
  if (!attachment) {
    ElMessage.error('没有附件可下载')
    return
  }
  
  // 构建完整的下载URL
  const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000'
  const downloadUrl = `${baseUrl}/uploads/download/${attachment.split('/').pop()}`
  
  // 触发下载
  window.open(downloadUrl, '_blank')
  console.log('下载订单附件:', attachment, '下载URL:', downloadUrl)
}

const editOrder = (order: any) => {
  console.log('编辑订单 - 传入的订单:', order)
  console.log('当前所有订单:', orders.value)
  
  // 填充表单数据
  orderForm.code = order.code
  
  // 解析开始日期和结束日期
  if (order.period) {
    const [startDate, endDate] = order.period.split(' / ')
    orderForm.startDate = startDate
    orderForm.endDate = endDate
  }
  
  // 确保订单时间是 YYYY-MM-DD 格式
  orderForm.orderDate = formatDate(order.orderDate)
  orderForm.amount = order.amount || ''
  orderForm.attachment = order.attachment
  
  // 显示编辑对话框
  isEditingOrder.value = true
  // 使用 order.id 而不是 indexOf，因为 filteredOrders 是过滤后的数组
  const index = orders.value.findIndex(o => o.id === order.id)
  console.log('找到的订单索引:', index)
  currentOrderIndex.value = index
  showAddOrderDialog.value = true
}

const deleteOrder = async (index: number) => {
  const orderToDelete = filteredOrders.value[index]
  try {
    // 如果有ID，调用后端API删除
    if (orderToDelete.id) {
      await dataApi.deleteOrder(orderToDelete.id)
    }
    const orderIndex = orders.value.findIndex(o => o.code === orderToDelete.code && o.project_id === orderToDelete.project_id)
    if (orderIndex !== -1) {
      orders.value.splice(orderIndex, 1)
      ElMessage.success('订单删除成功')
    }
  } catch (error) {
    console.error('删除订单失败:', error)
    ElMessage.error('删除失败，请重试')
  }
}

// 人员管理方法
const handleSettlementLevelChange = () => {
  if (personForm.settlementLevel) {
    const selectedLevel = filteredSettlementLevels.value.find(level => level.name === personForm.settlementLevel)
    if (selectedLevel) {
      personForm.priceWithTax = selectedLevel.priceWithTax
      personForm.priceWithoutTax = selectedLevel.priceWithoutTax
    }
  } else {
    personForm.priceWithTax = 0
    personForm.priceWithoutTax = 0
  }
}

const savePerson = async () => {
  // 验证表单
  if (!personForm.name || !personForm.team || !personForm.position || !personForm.settlementDept || !personForm.contact || !personForm.entryDate || !personForm.settlementLevel) {
    ElMessage.error('请填写所有必填字段')
    return
  }
  
  try {
    // 准备后端API需要的数据格式
    const personData = {
      name: personForm.name,
      employee_id: personForm.employeeId,
      team: personForm.team,
      position: personForm.position,
      settlement_dept: personForm.settlementDept,
      contact: personForm.contact,
      entry_date: personForm.entryDate,
      exit_date: personForm.exitDate,
      settlement_level: personForm.settlementLevel,
      price_with_tax: personForm.priceWithTax,
      price_without_tax: personForm.priceWithoutTax,
      input_type: personForm.inputType === '真实' ? 'actual' : 'virtual',
      project_id: currentProject.value?.id
    }
    
    if (isEditingPerson.value && currentPersonIndex.value !== -1) {
      // 编辑现有人员
      const currentPerson = persons.value[currentPersonIndex.value]
      if (currentPerson.id) {
        await dataApi.updatePerson(currentPerson.id, personData)
      }
      persons.value[currentPersonIndex.value] = {
        ...personForm,
        project_id: currentProject.value?.id
      }
      ElMessage.success('人员编辑成功')
    } else {
      // 添加新人员
      const createdPerson = await dataApi.createPerson(personData)
      persons.value.push({
        ...personForm,
        id: createdPerson.id,
        project_id: currentProject.value?.id
      })
      ElMessage.success('人员添加成功')
    }
    
    // 重置表单
    Object.assign(personForm, {
      name: '',
      employeeId: '',
      team: '',
      position: '',
      settlementDept: '',
      contact: '',
      entryDate: '',
      exitDate: '',
      settlementLevel: '',
      priceWithTax: 0,
      priceWithoutTax: 0
    })
    
    showAddPersonDialog.value = false
    isEditingPerson.value = false
    currentPersonIndex.value = -1
  } catch (error: any) {
    console.error('保存人员失败:', error)
    const errorMessage = error?.message || error?.error || '保存失败，请重试'
    ElMessage.error(`保存失败: ${errorMessage}`)
  }
}

const editPerson = (person: any) => {
  console.log('编辑人员 - 原始数据:', person)
  
  // 填充表单数据
  let inputTypeValue = person.inputType || person.input_type || '真实'
  // 转换后端返回的值
  if (inputTypeValue === 'actual') {
    inputTypeValue = '真实'
  } else if (inputTypeValue === 'virtual') {
    inputTypeValue = '虚拟'
  }
  
  // 处理日期格式，确保是 YYYY-MM-DD 格式
  let entryDateValue = person.entryDate || person.entry_date || ''
  let exitDateValue = person.exitDate || person.exit_date || ''
  
  // 如果日期是 Date 对象，转换为字符串
  if (entryDateValue instanceof Date) {
    entryDateValue = entryDateValue.toISOString().split('T')[0]
  }
  if (exitDateValue instanceof Date) {
    exitDateValue = exitDateValue.toISOString().split('T')[0]
  }
  
  // 如果日期包含时间部分，只取日期部分
  if (typeof entryDateValue === 'string' && entryDateValue.includes('T')) {
    entryDateValue = entryDateValue.split('T')[0]
  }
  if (typeof exitDateValue === 'string' && exitDateValue.includes('T')) {
    exitDateValue = exitDateValue.split('T')[0]
  }
  
  console.log('处理后的日期 - 入场:', entryDateValue, '离场:', exitDateValue)
  
  Object.assign(personForm, {
    name: person.name || '',
    employeeId: person.employeeId || person.employee_id || '',
    team: person.team || '',
    position: person.position || '',
    settlementDept: person.settlementDept || person.settlement_dept || '',
    contact: person.contact || '',
    entryDate: entryDateValue,
    exitDate: exitDateValue,
    settlementLevel: person.settlementLevel || person.settlement_level || '',
    inputType: inputTypeValue,
    priceWithTax: person.priceWithTax || person.price_with_tax || 0,
    priceWithoutTax: person.priceWithoutTax || person.price_without_tax || 0
  })
  
  console.log('编辑人员 - 表单数据:', personForm)
  
  // 显示编辑对话框
  isEditingPerson.value = true
  currentPersonIndex.value = persons.value.indexOf(person)
  showAddPersonDialog.value = true
}

const deletePerson = async (index: number) => {
  // 从过滤后的人员列表中获取要删除的人员
  const personToDelete = filteredPersons.value[index]
  if (personToDelete) {
    try {
      // 显示确认对话框
      await ElMessageBox.confirm(
        `确定要删除人员 "${personToDelete.name}" 吗？`,
        '确认删除',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      
      // 如果有ID，调用后端API删除
      if (personToDelete.id) {
        await dataApi.deletePerson(personToDelete.id)
      }
      // 在原始人员数组中找到对应的索引
      const originalIndex = persons.value.findIndex(p => 
        p.name === personToDelete.name && 
        p.project_id === personToDelete.project_id
      )
      if (originalIndex !== -1) {
        persons.value.splice(originalIndex, 1)
        ElMessage.success('人员删除成功')
      }
    } catch (error) {
      // 如果是用户取消操作，不显示错误信息
      if (error !== 'cancel') {
        console.error('删除人员失败:', error)
        ElMessage.error('删除失败，请重试')
      }
    }
  }
}

// 确认清空当前项目人员
const confirmClearPersons = async () => {
  const currentProjectId = currentProject.value?.id
  if (!currentProjectId) {
    ElMessage.error('请先选择项目')
    return
  }
  
  const projectPersonCount = filteredPersons.value.length
  if (projectPersonCount === 0) {
    ElMessage.info('当前项目暂无人员')
    return
  }
  
  ElMessageBox.confirm(
    `确定要清空当前项目的所有${projectPersonCount}个人员吗？此操作不可恢复。`,
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      // 调用后端API删除数据库中的人员
      await dataApi.deleteAllPersons()
      // 过滤出非当前项目的人员
      persons.value = persons.value.filter(person => person.project_id !== currentProjectId)
      ElMessage.success(`成功清空${projectPersonCount}个人员`)
    } catch (error) {
      console.error('清空人员失败:', error)
      ElMessage.error('清空人员失败，请重试')
    }
  }).catch(() => {
    // 取消操作
  })
}

// 分页控制函数
const handlePrevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

const handleNextPage = () => {
  if (currentPage.value * pageSize.value < totalPersons.value) {
    currentPage.value++
  }
}

// 切换部门筛选
const toggleDepartmentFilter = (dept: string) => {
  if (selectedDept.value === dept) {
    selectedDept.value = '' // 取消筛选
  } else {
    selectedDept.value = dept // 应用筛选
  }
}

// 处理表格单元格双击事件
const handleCellDblClick = (row: any, column: any, cell: any, event: any) => {
  console.log('Cell double clicked:', column.label)
  // 检查是否是月份列
  const columnLabel = column.label
  const monthMatch = columnLabel.match(/(\d+)月/)
  if (monthMatch) {
    console.log('Month column clicked:', monthMatch[1])
    const month = parseInt(monthMatch[1])
    editWorkDays(row, month)
  }
}

// 显示工时输入框
const showWorkDayInput = (row: any, m: { year: number; month: number; key: string }) => {
  editingCell.value = `${row.name}-${m.key}`
  editValue.value = row.workDays && row.workDays[m.key] ? row.workDays[m.key] : calculateMonthlyWorkDays(row, m)
  // 在下一个DOM更新周期聚焦输入框
  setTimeout(() => {
    if (inputRef.value) {
      inputRef.value.focus()
    }
  }, 0)
}

// 保存工时
const saveWorkDay = (row: any, m: { year: number; month: number; key: string }) => {
  // 验证输入
  const numValue = parseFloat(editValue.value)
  if (!isNaN(numValue) && numValue >= 0) {
    // 找到人员在数组中的索引
    const index = persons.value.findIndex(p => p.name === row.name && p.position === row.position)
    if (index !== -1) {
      // 确保workDays对象存在
      if (!persons.value[index].workDays) {
        persons.value[index].workDays = {}
      }
      // 更新工时（使用 key 作为存储键）
      persons.value[index].workDays[m.key] = numValue.toFixed(3)
      // 强制触发响应式更新
      persons.value = [...persons.value]
      ElMessage.success('工时更新成功')
    }
  } else {
    ElMessage.error('请输入有效的工作天数')
  }
  // 关闭编辑状态
  editingCell.value = ''
}

// 取消编辑
const cancelEdit = () => {
  editingCell.value = ''
}

// 切换全屏（使用CSS伪全屏，避免浏览器全屏API导致下拉菜单无法显示）
const toggleFullscreen = () => {
  isFullscreen.value = !isFullscreen.value
}

// 下载人员列表
const downloadPersonList = () => {
  // 准备CSV数据
  let csvContent = '姓名,小组,部门,岗位,投入类型,对接人,入场日期,离场日期,结算等级,结算单价,'
  
  // 添加月份列
  for (let month = 1; month <= 12; month++) {
    csvContent += `${month}月工作天数,`
  }
  csvContent = csvContent.slice(0, -1) + '\n'
  
  // 添加人员数据
  filteredPersons.value.forEach(person => {
    const row = [
      person.name,
      person.team,
      person.settlementDept,
      person.position,
      person.inputType,
      person.contact,
      person.entryDate,
      person.exitDate || '未离场',
      person.settlementLevel,
      showTaxPrice.value ? person.priceWithTax : person.priceWithoutTax
    ]
    
    // 添加每月工作天数
    for (let month = 1; month <= 12; month++) {
      row.push(person.workDays && person.workDays[month] ? person.workDays[month] : calculateMonthlyWorkDays(person, month))
    }
    
    csvContent += row.join(',') + '\n'
  })
  
  // 创建下载链接
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.setAttribute('href', url)
  link.setAttribute('download', `人员列表_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  
  ElMessage.success('人员列表下载成功')
}

// 编辑工时
const editWorkDays = (row: any, month: number) => {
  // 打开输入对话框
  const currentValue = row.workDays && row.workDays[month] ? row.workDays[month] : calculateMonthlyWorkDays(row, month)
  const newValue = prompt(`请输入${month}月的工作天数：`, currentValue)
  
  if (newValue !== null) {
    // 验证输入
    const numValue = parseFloat(newValue)
    if (!isNaN(numValue) && numValue >= 0) {
      // 找到人员在数组中的索引
      const index = persons.value.findIndex(p => p.name === row.name && p.position === row.position)
      if (index !== -1) {
        // 确保workDays对象存在
        if (!persons.value[index].workDays) {
          persons.value[index].workDays = {}
        }
        // 更新工时
        persons.value[index].workDays[month] = numValue.toFixed(3)
        // 强制触发响应式更新
        persons.value = [...persons.value]
        ElMessage.success('工时更新成功')
      }
    } else {
      ElMessage.error('请输入有效的工作天数')
    }
  }
}

// 按月计算工作天数函数
const calculateMonthlyWorkDays = (person: any, m: { year: number; month: number; key: string }) => {
  // 优先使用手动设置的工时
  if (person.workDays && person.workDays[m.key] !== undefined) {
    return person.workDays[m.key]
  }
  
  // 解析合同周期
  const contractPeriod = currentProject.value?.contractPeriod || '2026-01-01 ~ 2026-12-31'
  const [contractStartStr, contractEndStr] = contractPeriod.split(' ~ ')
  const contractStart = new Date(contractStartStr)
  
  // 确保合同结束日期包含年份
  let contractEndStrFull = contractEndStr
  if (contractEndStr.indexOf('-') === 2) { // 格式为 MM-DD
    const year = contractStart.getFullYear()
    contractEndStrFull = `${year}-${contractEndStr}`
  }
  const contractEnd = new Date(contractEndStrFull)
  
  // 人员入场和离场日期
  const entryDate = new Date(person.entryDate)
  const exitDate = person.exitDate ? new Date(person.exitDate) : contractEnd
  
  // 计算指定月份的开始和结束日期（使用月份对象的年份）
  const monthStart = new Date(m.year, m.month - 1, 1)
  const monthEnd = new Date(m.year, m.month, 0)
  
  // 确保计算范围在合同周期内
  const actualStart = new Date(Math.max(entryDate.getTime(), monthStart.getTime(), contractStart.getTime()))
  const actualEnd = new Date(Math.min(exitDate.getTime(), monthEnd.getTime(), contractEnd.getTime()))
  
  // 计算工作天数
  let workDays = 0
  const currentDate = new Date(actualStart)
  
  while (currentDate <= actualEnd) {
    // 检查是否是周末（周六或周日）
    const dayOfWeek = currentDate.getDay()
    if (dayOfWeek !== 0 && dayOfWeek !== 6) {
      // 检查是否是节假日（这里简化处理，实际应用中需要从配置或API获取节假日列表）
      if (!isHoliday(currentDate)) {
        workDays++
      }
    }
    // 移动到下一天
    currentDate.setDate(currentDate.getDate() + 1)
  }
  
  // 保留小数点后3位
  return workDays.toFixed(3)
}

// 工作天数计算函数（总计）
const calculateWorkDays = (person: any) => {
  let totalDays = 0
  for (let month = 1; month <= 12; month++) {
    totalDays += parseFloat(calculateMonthlyWorkDays(person, month))
  }
  return totalDays.toFixed(3)
}

// 项目结算暂估数据计算（含税）
const departmentSettlementDataWithTax = computed(() => {
  const data: any = {}
  
  // 人员结算计算 - 只计算当前项目的人员
  persons.value?.forEach((person: any) => {
    if (person.project_id !== currentProject.value?.id) {
      return
    }
    
    const dept = person.settlementDept || '未分配'
    const level = person.settlementLevel || '初级'
    
    if (!data[dept]) {
      data[dept] = {
        levels: {},
        levelCount: 0,
        totalCount: 0,
        monthlyTotals: {},
        totalAmount: 0
      }
    }
    
    if (!data[dept].levels[level]) {
      data[dept].levels[level] = {
        count: 0,
        monthlyAmounts: {},
        totalAmount: 0
      }
      data[dept].levelCount++
    }
    
    data[dept].levels[level].count++
    data[dept].totalCount++
    
    months.value.forEach(m => {
      const workDays = parseFloat(calculateMonthlyWorkDays(person, m))
      const unitPrice = parseFloat(person.priceWithTax) || 0
      const monthlyAmount = workDays * unitPrice
      
      data[dept].levels[level].monthlyAmounts[m.key] = ((data[dept].levels[level].monthlyAmounts[m.key] || 0) + monthlyAmount)
      data[dept].monthlyTotals[m.key] = ((data[dept].monthlyTotals[m.key] || 0) + monthlyAmount)
      data[dept].levels[level].totalAmount += monthlyAmount
      data[dept].totalAmount += monthlyAmount
    })
  })
  
  return data
})

// 项目结算暂估数据计算（不含税）
const departmentSettlementDataWithoutTax = computed(() => {
  const data: any = {}
  
  // 人员结算计算 - 只计算当前项目的人员
  persons.value?.forEach((person: any) => {
    if (person.project_id !== currentProject.value?.id) {
      return
    }
    
    const dept = person.settlementDept || '未分配'
    const level = person.settlementLevel || '初级'
    
    if (!data[dept]) {
      data[dept] = {
        levels: {},
        levelCount: 0,
        totalCount: 0,
        monthlyTotals: {},
        totalAmount: 0
      }
    }
    
    if (!data[dept].levels[level]) {
      data[dept].levels[level] = {
        count: 0,
        monthlyAmounts: {},
        totalAmount: 0
      }
      data[dept].levelCount++
    }
    
    data[dept].levels[level].count++
    data[dept].totalCount++
    
    months.value.forEach(m => {
      const workDays = parseFloat(calculateMonthlyWorkDays(person, m))
      const unitPrice = parseFloat(person.priceWithoutTax) || 0
      const monthlyAmount = workDays * unitPrice
      
      data[dept].levels[level].monthlyAmounts[m.key] = ((data[dept].levels[level].monthlyAmounts[m.key] || 0) + monthlyAmount)
      data[dept].monthlyTotals[m.key] = ((data[dept].monthlyTotals[m.key] || 0) + monthlyAmount)
      data[dept].levels[level].totalAmount += monthlyAmount
      data[dept].totalAmount += monthlyAmount
    })
  })
  
  return data
})

// 根据显示类型返回对应数据
const departmentSettlementData = computed(() => {
  return showSettlementTaxPrice.value ? departmentSettlementDataWithTax.value : departmentSettlementDataWithoutTax.value
})

// 项目总计人员数量
const totalPersonCount = computed(() => {
  return persons.value?.filter((person: any) => person.project_id === currentProject.value?.id).length || 0
})

// 项目每月总计金额
const monthlyProjectTotals = computed(() => {
  const totals: any = {}
  months.value.forEach(m => {
    let total = 0
    Object.values(departmentSettlementData.value).forEach((deptData: any) => {
      total += deptData.monthlyTotals[m.key] || 0
    })
    totals[m.key] = total
  })
  return totals
})

// 项目总计金额
const totalProjectAmount = computed(() => {
  let total = 0
  Object.values(departmentSettlementData.value).forEach((deptData: any) => {
    const deptTotal = parseFloat(deptData.totalAmount) || 0
    console.log('项目结算金额计算 - 部门:', deptData, '金额:', deptTotal)
    total += deptTotal
  })
  console.log('项目结算金额计算 - 总计:', total)
  return total
})

// 分部门结算数据转换为数组格式（用于el-table）
const departmentSettlementList = computed(() => {
  const list: any[] = []
  
  Object.entries(departmentSettlementData.value).forEach(([dept, deptData]: [string, any]) => {
    let isFirstRow = true
    const deptLevels = Object.entries(deptData.levels || {})
    
    if (deptLevels.length > 0) {
      deptLevels.forEach(([level, levelData]: [string, any]) => {
        list.push({
          dept: isFirstRow ? dept : '',
          level,
          count: levelData.count,
          monthlyTotals: levelData.monthlyAmounts,
          totalAmount: levelData.totalAmount,
          isDeptTotal: false,
          isTotal: false,
          rowspan: isFirstRow ? deptLevels.length : 1
        })
        isFirstRow = false
      })
    }
    
    list.push({
      dept: '',
      level: '部门小计',
      count: deptData.totalCount,
      monthlyTotals: deptData.monthlyTotals,
      totalAmount: deptData.totalAmount,
      isDeptTotal: true,
      isTotal: false
    })
  })
  
  list.push({
    dept: '项目总计',
    level: '',
    count: totalPersonCount.value,
    monthlyTotals: monthlyProjectTotals.value,
    totalAmount: totalProjectAmount.value,
    isDeptTotal: false,
    isTotal: true
  })
  
  return list
})

// 格式化合同周期显示
const formatContractPeriod = (period: string | undefined) => {
  if (!period) return '未设置'
  
  // 检查是否包含 undefined
  if (period.includes('undefined')) return '未设置'
  
  if (period.includes(' ~ ')) {
    const parts = period.split(' ~ ')
    if (parts.length === 2) {
      const startDate = parts[0]
      let endDate = parts[1]
      
      // 检查日期是否有效
      if (!startDate || !endDate || startDate === 'undefined' || endDate === 'undefined') {
        return '未设置'
      }
      
      // 如果结束日期没有年份，添加开始日期的年份
      if (endDate.indexOf('-') === 2 || endDate.length === 5) {
        const year = startDate.substring(0, 4)
        endDate = `${year}-${endDate}`
      }
      
      return `${startDate} ~ ${endDate}`
    }
  }
  
  return period
}

// 日期格式化函数
const formatDate = (date: string) => {
  if (!date) return ''
  // 如果已经是 YYYY-MM-DD 格式，直接返回
  if (typeof date === 'string' && date.match(/^\d{4}-\d{2}-\d{2}$/)) {
    return date
  }
  // 否则转换为 YYYY-MM-DD 格式
  const d = new Date(date)
  return d.toISOString().split('T')[0]
}

// 数字格式化函数
const formatNumber = (num: number | string | undefined | null) => {
  if (num === null || num === undefined || num === '') return '0.00'
  const n = typeof num === 'string' ? parseFloat(num) : num
  if (isNaN(n)) return '0.00'
  return n.toFixed(2)
}

// 财务数据分析计算
// 当前毛利暂估 = 以成本月为周期：项目暂估不含税结算金额 - 项目累计成本
const currentGrossProfitLatestMonth = computed(() => {
  const costList = filteredMonthlyCostList.value
  if (costList.length === 0) {
    return ''
  }
  let latestMonth = ''
  costList.forEach((item: any) => {
    if (!latestMonth || item.month > latestMonth) {
      latestMonth = item.month
    }
  })
  return latestMonth
})

const currentGrossProfit = computed(() => {
  const costList = filteredMonthlyCostList.value
  if (costList.length === 0) {
    return 0
  }
  const latestMonth = currentGrossProfitLatestMonth.value
  if (!latestMonth) {
    return 0
  }
  const [latestYear, latestMonthNum] = latestMonth.split('-').map(Number)
  const monthList: string[] = []
  months.value.forEach(m => {
    if (m.year < latestYear || (m.year === latestYear && m.month <= latestMonthNum)) {
      monthList.push(m.key)
    }
  })
  let periodSettlement = 0
  Object.values(departmentSettlementDataWithoutTax.value).forEach((deptData: any) => {
    monthList.forEach(key => {
      periodSettlement += deptData.monthlyTotals[key] || 0
    })
  })
  const periodCost = filteredMonthlyCostList.value
    .filter((item: any) => monthList.includes(item.month))
    .reduce((sum: number, item: any) => {
      const directCost = parseFloat(item.directCost) || 0
      const operatingCost = parseFloat(item.operatingCost) || 0
      const sharedCost = parseFloat(item.sharedCost) || 0
      return sum + directCost + operatingCost + sharedCost
    }, 0)
  return periodSettlement - periodCost
})

// 当前毛利率暂估
const currentGrossMarginRate = computed(() => {
  const costList = filteredMonthlyCostList.value
  if (costList.length === 0) return 0
  const latestMonth = currentGrossProfitLatestMonth.value
  if (!latestMonth) return 0
  const [latestYear, latestMonthNum] = latestMonth.split('-').map(Number)
  const monthList: string[] = []
  months.value.forEach(m => {
    if (m.year < latestYear || (m.year === latestYear && m.month <= latestMonthNum)) {
      monthList.push(m.key)
    }
  })
  let periodSettlement = 0
  Object.values(departmentSettlementDataWithoutTax.value).forEach((deptData: any) => {
    monthList.forEach(key => {
      periodSettlement += deptData.monthlyTotals[key] || 0
    })
  })
  if (periodSettlement === 0) return 0
  return (currentGrossProfit.value / periodSettlement) * 100
})

// 实际毛利 = 按项目实际结算周期计算：周期内不含税金额 - 周期内月成本累计
const actualGrossProfit = computed(() => {
  const settlements = filteredActualSettlementList.value
  if (settlements.length === 0) {
    return 0
  }
  
  // 找到最新的结算周期结束日期
  let latestEndDate = new Date(0)
  settlements.forEach((settlement: any) => {
    if (!settlement.period || settlement.period.length !== 2) return
    const endDate = new Date(settlement.period[1])
    if (endDate > latestEndDate) {
      latestEndDate = endDate
    }
  })
  
  // 按周期分组，累加相同周期的实际结算金额
  const periodMap = new Map<string, { amountWithoutTax: number, monthList: string[], endDate: Date }>()
  
  settlements.forEach((settlement: any) => {
    if (!settlement.period || settlement.period.length !== 2) return
    const periodKey = `${settlement.period[0]}_${settlement.period[1]}`
    const amountWithoutTax = parseFloat(settlement.amountWithoutTax) || 0
    
    if (periodMap.has(periodKey)) {
      // 相同周期，累加金额
      const existing = periodMap.get(periodKey)!
      existing.amountWithoutTax += amountWithoutTax
    } else {
      // 新周期，计算月份列表
      const startDate = new Date(settlement.period[0])
      const endDate = new Date(settlement.period[1])
      const monthList: string[] = []
      let currentYear = startDate.getFullYear()
      let currentMonth = startDate.getMonth() + 1
      const endYear = endDate.getFullYear()
      const endMonth = endDate.getMonth() + 1
      while (currentYear < endYear || (currentYear === endYear && currentMonth <= endMonth)) {
        monthList.push(`${currentYear}-${String(currentMonth).padStart(2, '0')}`)
        currentMonth++
        if (currentMonth > 12) {
          currentMonth = 1
          currentYear++
        }
      }
      periodMap.set(periodKey, { amountWithoutTax, monthList, endDate })
    }
  })
  
  // 收集所有涉及的月份（去重）
  const allMonths = new Set<string>()
  let totalAmountWithoutTax = 0
  
  periodMap.forEach((data) => {
    // 只计算最新结算周期及之前的周期
    if (data.endDate <= latestEndDate) {
      data.monthList.forEach(month => allMonths.add(month))
      totalAmountWithoutTax += data.amountWithoutTax
    }
  })
  
  // 计算所有涉及月份的总成本（避免重复计算）
  const totalPeriodCost = filteredMonthlyCostList.value
    .filter((item: any) => allMonths.has(item.month))
    .reduce((sum: number, item: any) => {
      const directCost = parseFloat(item.directCost) || 0
      const operatingCost = parseFloat(item.operatingCost) || 0
      const sharedCost = parseFloat(item.sharedCost) || 0
      return sum + directCost + operatingCost + sharedCost
    }, 0)
  
  const totalGrossProfit = totalAmountWithoutTax - totalPeriodCost
  
  console.log('=== 实际毛利计算详情 ===')
  console.log('结算周期数量:', periodMap.size)
  console.log('所有涉及月份（去重）:', Array.from(allMonths).sort())
  console.log('总不含税金额:', totalAmountWithoutTax)
  console.log('总周期成本（去重后）:', totalPeriodCost)
  console.log('实际毛利:', totalGrossProfit)
  console.log('===================')
  
  return totalGrossProfit
})

// 实际毛利统计到的最新月份
const actualGrossProfitLatestMonth = computed(() => {
  const settlements = filteredActualSettlementList.value
  if (settlements.length === 0) {
    return ''
  }
  let latestMonth = ''
  settlements.forEach((settlement: any) => {
    if (!settlement.period || settlement.period.length !== 2) return
    const endDate = new Date(settlement.period[1])
    const endYear = endDate.getFullYear()
    const endMonth = endDate.getMonth() + 1
    const monthStr = `${endYear}年${endMonth}月`
    if (!latestMonth || monthStr > latestMonth) {
      latestMonth = monthStr
    }
  })
  return latestMonth
})

// 实际毛利率
const actualGrossMarginRate = computed(() => {
  const totalActualSettlement = totalActualSettlementWithoutTax.value
  console.log('实际毛利率计算 - totalActualSettlement:', totalActualSettlement)
  console.log('实际毛利率计算 - actualGrossProfit:', actualGrossProfit.value)
  if (totalActualSettlement === 0) {
    console.log('实际毛利率计算 - 实际结算金额为0，返回0')
    return 0
  }
  const rate = (actualGrossProfit.value / totalActualSettlement) * 100
  console.log('实际毛利率计算 - 结果:', rate)
  return rate
})

// 滚动毛利率暂估（预估计算到项目结束的整体毛利率）
const rollingGrossMarginRate = computed(() => {
  const costList = filteredMonthlyCostList.value
  const projectMonths = months.value
  if (projectMonths.length === 0) return 0
  let totalSettlement = 0
  Object.values(departmentSettlementDataWithoutTax.value).forEach((deptData: any) => {
    projectMonths.forEach(m => {
      totalSettlement += deptData.monthlyTotals[m.key] || 0
    })
  })
  if (totalSettlement === 0) return 0
  let totalCost = 0
  if (costList.length > 0) {
    const existingCostMonths = costList.map((item: any) => item.month)
    const existingCost = costList.reduce((sum: number, item: any) => {
      return sum + (item.directCost || 0) + (item.operatingCost || 0) + (item.sharedCost || 0)
    }, 0)
    totalCost += existingCost
    const avgMonthlyCost = existingCost / costList.length
    const missingMonths = projectMonths.filter((m: any) => !existingCostMonths.includes(m.key))
    totalCost += missingMonths.length * avgMonthlyCost
  }
  return ((totalSettlement - totalCost) / totalSettlement) * 100
})

// 计算日期范围内的工作日天数
const calculateWorkDaysInRange = (startDate: Date, endDate: Date) => {
  let workDays = 0
  const currentDate = new Date(startDate)
  while (currentDate <= endDate) {
    const dayOfWeek = currentDate.getDay()
    if (dayOfWeek !== 0 && dayOfWeek !== 6 && !isHoliday(currentDate)) {
      workDays++
    }
    currentDate.setDate(currentDate.getDate() + 1)
  }
  return workDays
}

// 应结算额（根据当前时间计算应结算周期的暂估金额）
const payableSettlement = computed(() => {
  const approvalAmount = parseFloat(String(currentProject.value?.approvalAmount || '0').replace(/,/g, '')) || 0
  if (approvalAmount === 0) return 0
  const contractPeriod = currentProject.value?.contractPeriod || '2026-01-01 ~ 2026-12-31'
  const [contractStartStr, contractEndStr] = contractPeriod.split(' ~ ')
  const contractStart = new Date(contractStartStr)
  let contractEndStrFull = contractEndStr
  if (contractEndStr.indexOf('-') === 2) {
    const year = contractStart.getFullYear()
    contractEndStrFull = `${year}-${contractEndStr}`
  }
  const contractEnd = new Date(contractEndStrFull)
  const totalWorkDays = calculateWorkDaysInRange(contractStart, contractEnd)
  if (totalWorkDays === 0) return 0
  
  const now = new Date()
  const currentYear = now.getFullYear()
  const currentMonth = now.getMonth() + 1
  const currentQuarter = Math.ceil(currentMonth / 3)
  
  // 计算从项目开始到当前时间应该结算的工作日
  let settlementWorkDays = 0
  const projectStartYear = contractStart.getFullYear()
  const projectStartMonth = contractStart.getMonth() + 1
  const projectStartQuarter = Math.ceil(projectStartMonth / 3)
  
  // 遍历从项目开始到当前的所有季度
  let year = projectStartYear
  let quarter = projectStartQuarter
  
  while (year < currentYear || (year === currentYear && quarter < currentQuarter)) {
    const startMonth = (quarter - 1) * 3 + 1
    const endMonth = quarter * 3
    const periodStart = new Date(year, startMonth - 1, 1)
    const periodEnd = new Date(year, endMonth, 0)
    
    // 计算该季度的工作日，但不能超过项目结束日期
    const actualStart = periodStart < contractStart ? contractStart : periodStart
    const actualEnd = periodEnd > contractEnd ? contractEnd : periodEnd
    
    if (actualStart <= actualEnd) {
      settlementWorkDays += calculateWorkDaysInRange(actualStart, actualEnd)
    }
    
    // 进入下一个季度
    quarter++
    if (quarter > 4) {
      quarter = 1
      year++
    }
  }
  
  return (approvalAmount / totalWorkDays) * settlementWorkDays
})

// 应结算毛利率
const payableSettlementMarginRate = computed(() => {
  const settlementAmount = payableSettlement.value
  if (settlementAmount === 0) return 0
  
  const now = new Date()
  const currentYear = now.getFullYear()
  const currentMonth = now.getMonth() + 1
  const currentQuarter = Math.ceil(currentMonth / 3)
  
  const contractPeriod = currentProject.value?.contractPeriod || '2026-01-01 ~ 2026-12-31'
  const [contractStartStr] = contractPeriod.split(' ~ ')
  const contractStart = new Date(contractStartStr)
  const projectStartYear = contractStart.getFullYear()
  const projectStartMonth = contractStart.getMonth() + 1
  const projectStartQuarter = Math.ceil(projectStartMonth / 3)
  
  const settlementMonths: string[] = []
  
  // 遍历从项目开始到当前的所有季度
  let year = projectStartYear
  let quarter = projectStartQuarter
  
  while (year < currentYear || (year === currentYear && quarter < currentQuarter)) {
    const startMonth = (quarter - 1) * 3 + 1
    const endMonth = quarter * 3
    
    for (let m = startMonth; m <= endMonth; m++) {
      const monthStr = `${year}-${String(m).padStart(2, '0')}`
      settlementMonths.push(monthStr)
    }
    
    // 进入下一个季度
    quarter++
    if (quarter > 4) {
      quarter = 1
      year++
    }
  }
  const periodCost = filteredMonthlyCostList.value
    .filter((item: any) => settlementMonths.includes(item.month))
    .reduce((sum: number, item: any) => {
      return sum + (item.directCost || 0) + (item.operatingCost || 0) + (item.sharedCost || 0)
    }, 0)
  return ((settlementAmount - periodCost) / settlementAmount) * 100
})

// 订单结算（根据当前时间计算应结算周期的订单金额）
const orderSettlement = computed(() => {
  const totalOrderAmount = totalPurchaseSettlementAmount.value
  if (totalOrderAmount === 0) return 0
  const contractPeriod = currentProject.value?.contractPeriod || '2026-01-01 ~ 2026-12-31'
  const [contractStartStr, contractEndStr] = contractPeriod.split(' ~ ')
  const contractStart = new Date(contractStartStr)
  let contractEndStrFull = contractEndStr
  if (contractEndStr.indexOf('-') === 2) {
    const year = contractStart.getFullYear()
    contractEndStrFull = `${year}-${contractEndStr}`
  }
  const contractEnd = new Date(contractEndStrFull)
  const totalWorkDays = calculateWorkDaysInRange(contractStart, contractEnd)
  if (totalWorkDays === 0) return 0
  
  const now = new Date()
  const currentYear = now.getFullYear()
  const currentMonth = now.getMonth() + 1
  const currentQuarter = Math.ceil(currentMonth / 3)
  
  // 计算从项目开始到当前时间应该结算的工作日
  let settlementWorkDays = 0
  const projectStartYear = contractStart.getFullYear()
  const projectStartMonth = contractStart.getMonth() + 1
  const projectStartQuarter = Math.ceil(projectStartMonth / 3)
  
  // 遍历从项目开始到当前的所有季度
  let year = projectStartYear
  let quarter = projectStartQuarter
  
  while (year < currentYear || (year === currentYear && quarter < currentQuarter)) {
    const startMonth = (quarter - 1) * 3 + 1
    const endMonth = quarter * 3
    const periodStart = new Date(year, startMonth - 1, 1)
    const periodEnd = new Date(year, endMonth, 0)
    
    // 计算该季度的工作日，但不能超过项目结束日期
    const actualStart = periodStart < contractStart ? contractStart : periodStart
    const actualEnd = periodEnd > contractEnd ? contractEnd : periodEnd
    
    if (actualStart <= actualEnd) {
      settlementWorkDays += calculateWorkDaysInRange(actualStart, actualEnd)
    }
    
    // 进入下一个季度
    quarter++
    if (quarter > 4) {
      quarter = 1
      year++
    }
  }
  
  return (totalOrderAmount / totalWorkDays) * settlementWorkDays
})

// 应该产生毛利
const grossProfitOutput = computed(() => {
  const grossMargin = parseFloat(String(currentProject.value?.grossMargin || '0')) / 100
  return payableSettlement.value / 1.06 * grossMargin
})

// 毛利率差额
const grossProfitDifference = computed(() => {
  return grossProfitOutput.value - actualGrossProfit.value
})

// 毛利率差额（率差）
const grossMarginDifference = computed(() => {
  const approvalGrossMargin = parseFloat(String(currentProject.value?.grossMargin || '0'))
  return approvalGrossMargin - actualGrossMarginRate.value
})

// 项目结算率
const projectSettlementRate = computed(() => {
  console.log('结算率计算 - currentProject完整对象:', JSON.stringify(currentProject.value))
  console.log('结算率计算 - approvalConfig:', approvalConfig.value)
  
  // 使用立项配置中的金额，而不是项目中的approvalAmount
  const approvalAmount = parseFloat(String(approvalConfig.value?.amount || '0').replace(/,/g, '')) || 0
  console.log('结算率计算 - 立项金额:', approvalAmount)
  if (approvalAmount === 0) return 0
  const totalProjectSettlement = totalProjectAmount.value
  console.log('结算率计算 - 项目结算金额:', totalProjectSettlement)
  const rate = (totalProjectSettlement / approvalAmount) * 100
  console.log('结算率计算 - 结果:', rate)
  return rate
})

// 自由计算函数
const calculateFreeSettlement = () => {
  if (!freeCalcStartMonth.value || !freeCalcEndMonth.value) {
    ElMessage.warning('请选择时间周期')
    return
  }

  const [startYear, startMonth] = freeCalcStartMonth.value.split('-').map(Number)
  const [endYear, endMonth] = freeCalcEndMonth.value.split('-').map(Number)

  if (startYear > endYear || (startYear === endYear && startMonth > endMonth)) {
    ElMessage.warning('开始月份不能晚于结束月份')
    return
  }

  const monthList: { year: number; month: number; key: string }[] = []
  let currentYear = startYear
  let currentMonth = startMonth

  while (currentYear < endYear || (currentYear === endYear && currentMonth <= endMonth)) {
    monthList.push({
      year: currentYear,
      month: currentMonth,
      key: `${currentYear}-${currentMonth}`
    })
    currentMonth++
    if (currentMonth > 12) {
      currentMonth = 1
      currentYear++
    }
  }

  const filteredPersons = persons.value.filter((person: any) => {
    if (person.project_id !== currentProject.value?.id) {
      return false
    }
    if (freeCalcDept.value && person.settlementDept !== freeCalcDept.value) {
      return false
    }
    return true
  })

  const detailMap: Record<string, {
    dept: string
    level: string
    count: number
    withTax: number
    withoutTax: number
    monthlyAmounts: Record<string, number>
  }> = {}

  let totalWithTax = 0
  let totalWithoutTax = 0

  filteredPersons.forEach((person: any) => {
    const dept = person.settlementDept || '未分配'
    const level = person.settlementLevel || '初级'
    const key = `${dept}-${level}`

    if (!detailMap[key]) {
      detailMap[key] = {
        dept,
        level,
        count: 0,
        withTax: 0,
        withoutTax: 0,
        monthlyAmounts: {}
      }
    }

    detailMap[key].count++

    monthList.forEach(m => {
      const workDays = parseFloat(calculateMonthlyWorkDays(person, m))
      const withTaxAmount = workDays * (parseFloat(person.priceWithTax) || 0)
      const withoutTaxAmount = workDays * (parseFloat(person.priceWithoutTax) || 0)

      detailMap[key].withTax += withTaxAmount
      detailMap[key].withoutTax += withoutTaxAmount
      detailMap[key].monthlyAmounts[m.key] = (detailMap[key].monthlyAmounts[m.key] || 0) + withTaxAmount

      totalWithTax += withTaxAmount
      totalWithoutTax += withoutTaxAmount
    })
  })

  const detailList = Object.values(detailMap).sort((a, b) => {
    if (a.dept !== b.dept) return a.dept.localeCompare(b.dept)
    return a.level.localeCompare(b.level)
  })

  freeCalcResult.value = {
    withTax: totalWithTax,
    withoutTax: totalWithoutTax,
    monthCount: monthList.length,
    detailList
  }

  ElMessage.success('计算完成')
}

// 检查是否是节假日（简化实现，实际应用中需要从配置或API获取节假日列表）
const isHoliday = (date: Date) => {
  // 这里只是示例，实际应用中需要从配置或API获取节假日列表
  const holidays = [
    '2026-01-01', // 元旦
    '2026-02-01', // 春节
    '2026-02-02',
    '2026-02-03',
    '2026-04-05', // 清明节
    '2026-05-01', // 劳动节
    '2026-06-25', // 端午节
    '2026-10-01', // 国庆节
    '2026-10-02',
    '2026-10-03',
    '2026-10-04',
    '2026-10-05',
    '2026-10-06',
    '2026-10-07'
  ]
  
  const dateStr = date.toISOString().split('T')[0]
  return holidays.includes(dateStr)
}


</script>

<style scoped>
.home-container {
  display: grid;
  grid-template-columns: 288px 1fr;
  min-height: 100vh;
  width: 100%;
  min-width: 1380px;
  background-color: #f5f7fa;
}

.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  height: 100vh;
  width: 288px;
  border-right: 1px solid rgba(148, 163, 184, 0.2);
  background-color: #ffffff;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.dark .sidebar {
  background-color: #1e293b;
  border-right-color: rgba(51, 65, 85, 0.5);
}

.main-content {
  grid-column: 2;
  padding: 2rem;
  padding-bottom: 5rem;
  overflow-x: auto;
  min-width: 0;
}

/* 增加列表模块之间的间距 */
.main-content > section {
  margin-bottom: 2.5rem;
}

.main-content > section:last-child {
  margin-bottom: 0;
}

/* CSS伪全屏样式 - 简化版 */
.css-fullscreen {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: 100;
  margin: 0;
  border-radius: 0;
}

/* 全屏模式下覆盖所有overflow */
.css-fullscreen,
.css-fullscreen *,
.css-fullscreen *::before,
.css-fullscreen *::after {
  overflow: visible !important;
}

/* 但表格需要保持滚动 */
.css-fullscreen .el-table,
.css-fullscreen .el-table__body-wrapper {
  overflow: auto !important;
  max-height: calc(100vh - 200px);
}

/* 高级筛选下拉框样式 */
.filter-select {
  width: 180px;
}

.filter-select :deep(.el-input__wrapper) {
  height: 32px;
  border-radius: 8px;
  background-color: #ffffff;
}



.filter-select :deep(.el-select__wrapper) {
  min-height: 32px !important;
  height: 32px !important;
}

.filter-select :deep(.el-input__inner) {
  height: 32px !important;
  line-height: 32px !important;
  font-size: 12px !important;
  color: #303133 !important;
}

.filter-select :deep(.el-select__placeholder) {
  color: #909399 !important;
  font-size: 12px !important;
}

/* 悬停状态样式 */
.filter-select:hover :deep(.el-input__wrapper) {
  border-color: #409eff !important;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.1) !important;
  background-color: #ffffff !important;
}

.filter-select:hover :deep(.el-input__inner) {
  color: #303133 !important;
}

.filter-select:hover :deep(.el-select__placeholder) {
  color: #909399 !important;
}

/* 聚焦状态样式 */
.filter-select :deep(.el-input__wrapper.is-focus) {
  border-color: #409eff !important;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2) !important;
  background-color: #ffffff !important;
}

.filter-select :deep(.el-input__wrapper.is-focus) .el-input__inner {
  color: #303133 !important;
}

/* 暗黑模式 */
.dark .filter-select :deep(.el-input__wrapper) {
  background-color: #1e293b !important;
}

.dark .filter-select :deep(.el-input__inner) {
  color: #e4e4e7 !important;
}

.dark .filter-select :deep(.el-select__placeholder) {
  color: #a1a1aa !important;
}

.dark .filter-select:hover :deep(.el-input__wrapper) {
  background-color: #1e293b !important;
}

/* 下拉选项悬停状态 - 关键修复 */
.filter-select :deep(.el-select-dropdown__item:hover) {
  color: #409eff !important;
  background-color: #f5f7fa !important;
}

.filter-select :deep(.el-select-dropdown__item.hover) {
  color: #409eff !important;
  background-color: #f5f7fa !important;
}

.filter-select :deep(.el-select-dropdown__item.selected) {
  color: #409eff !important;
}

.filter-select :deep(.el-select-dropdown__item.is-disabled:hover) {
  color: #909399 !important;
  background-color: transparent !important;
}

/* 暗黑模式下拉选项 */
.dark .filter-select :deep(.el-select-dropdown__item:hover) {
  color: #66b1ff !important;
  background-color: #1e293b !important;
}

.dark .filter-select :deep(.el-select-dropdown__item.hover) {
  color: #66b1ff !important;
  background-color: #1e293b !important;
}

.dark .filter-select :deep(.el-select-dropdown__item.selected) {
  color: #66b1ff !important;
}
</style>

<!-- 下拉选项悬停颜色修复（全局样式，作用于teleport到body的弹窗） -->
<style>
.el-select-dropdown__item:hover,
.el-select-dropdown__item.hover {
  color: #409eff !important;
  background-color: #f5f7fa !important;
}

.el-select-dropdown__item.selected {
  color: #409eff !important;
}

/* 暗黑模式 */
.dark .el-select-dropdown__item:hover,
.dark .el-select-dropdown__item.hover {
  color: #66b1ff !important;
  background-color: #1e293b !important;
}

.dark .el-select-dropdown__item.selected {
  color: #66b1ff !important;
}
</style>
