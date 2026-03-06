<template>
  <div class="flex min-h-screen home-container">
    <!-- 左侧边栏 -->
    <aside class="w-72 border-r border-slate-200 dark:border-slate-800 bg-card-light dark:bg-card-dark flex flex-col fixed h-full z-20">
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
        <a 
          v-for="project in filteredProjects" 
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
    <main class="ml-72 flex-1 p-8 pb-20 space-y-8 max-w-full overflow-x-hidden">
      <header class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div class="flex items-center gap-3">
          <h2 class="text-2xl font-bold tracking-tight">{{ currentProject?.label || '请选择项目' }}</h2>
          <span class="px-3 py-1 text-xs font-medium bg-blue-50 dark:bg-blue-900/30 text-primary rounded-full border border-blue-100 dark:border-blue-800">
            {{ currentProject?.status || '进行中' }}
          </span>
        </div>
        <div class="flex items-center gap-2 flex-wrap">
          <button class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm"
            @click="showSettlementConfigDialog = true">
            <el-icon class="text-slate-400"><Setting /></el-icon> 结算配置
          </button>
          <button class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm"
            @click="showApprovalConfigDialog = true">
            <el-icon class="text-slate-400"><Document /></el-icon> 立项配置
          </button>
          <button class="px-4 py-2 text-sm font-medium bg-white dark:bg-card-dark border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center gap-2 shadow-sm"
            @click="handleEditProject">
            <el-icon class="text-slate-400"><Edit /></el-icon> 编辑
          </button>
          <button class="px-4 py-2 text-sm font-medium bg-orange-500 hover:bg-orange-600 text-white rounded-lg transition-all flex items-center gap-2 shadow-sm">
            <el-icon><Check /></el-icon> 结束项目
          </button>
          <button class="px-4 py-2 text-sm font-medium border border-red-200 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-all flex items-center gap-2">
            <el-icon><Delete /></el-icon> 删除
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

      <!-- 项目重要事项 -->
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><Warning /></el-icon> 项目重要事项
          </h3>
          <button class="text-xs font-medium text-primary hover:underline" @click="showAddImportantItemDialog = true">添加</button>
        </div>
        <div class="divide-y divide-slate-100 dark:divide-slate-800">
          <div 
            v-for="(item, index) in importantItems" 
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
              <button class="text-primary hover:text-blue-700 transition-colors" @click="editImportantItem(index)">
                <el-icon class="text-sm"><Edit /></el-icon>
              </button>
              <button class="text-slate-400 hover:text-red-500 transition-colors" @click="deleteImportantItem(index)">
                <el-icon class="text-sm"><Delete /></el-icon>
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- 财务数据分析 -->
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><DataAnalysis /></el-icon> 财务数据分析
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
      </section>

      <!-- 合同管理 -->
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden">
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
            class="px-3 py-1.5 text-xs font-medium bg-primary text-white rounded-lg flex items-center gap-1 shadow-sm"
            @click="showAddContractDialog = true"
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
                <th class="px-6 py-3 text-right">合同金额</th>
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
                <td class="px-6 py-4 text-red-500 font-semibold text-right">{{ contract.amount }}</td>
                <td class="px-6 py-4 text-xs">{{ contract.period }}</td>
                <td class="px-6 py-4">{{ contract.customer }}</td>
                <td class="px-6 py-4">
                  <button 
                    v-if="contract.attachment"
                    class="text-primary hover:text-blue-700 transition-colors flex items-center gap-1"
                    @click="previewAttachment(contract.attachment)"
                  >
                    <el-icon class="text-sm"><Document /></el-icon>
                    <span class="text-xs">预览</span>
                  </button>
                  <span v-else class="text-slate-400 text-xs">无附件</span>
                </td>
                <td class="px-6 py-4">
                  <div class="flex items-center justify-center gap-4">
                    <button class="text-primary hover:text-blue-700 transition-colors" @click="editContract(contract)">
                      <el-icon><Edit /></el-icon>
                    </button>
                    <button class="text-slate-400 hover:text-red-500 transition-colors" @click="deleteContract(index)">
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
      <section class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/20">
          <h3 class="font-bold flex items-center gap-2">
            <el-icon class="text-primary"><Document /></el-icon> 订单管理
          </h3>
          <button 
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
                <th class="px-6 py-3">附件</th>
                <th class="px-6 py-3 text-center">操作</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
              <tr v-for="(order, index) in orders" :key="index">
                <td class="px-6 py-4 text-slate-500 uppercase text-xs">{{ order.code }}</td>
                <td class="px-6 py-4 text-xs">{{ order.period }}</td>
                <td class="px-6 py-4 text-xs">{{ order.orderDate }}</td>
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
                    <button class="text-primary hover:text-blue-700 transition-colors" @click="editOrder(order)">
                      <el-icon><Edit /></el-icon>
                    </button>
                    <button class="text-slate-400 hover:text-red-500 transition-colors" @click="deleteOrder(index)">
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
        class="bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-slate-200/60 dark:border-slate-800 overflow-hidden" 
        style="width: 1280px;"
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
            <div class="flex flex-wrap gap-2">
              <button 
                v-for="stat in departmentStats" 
                :key="stat.dept"
                class="px-3 py-1.5 text-[11px] border border-slate-200 dark:border-slate-700 rounded-lg transition-colors flex items-center gap-2"
                :class="selectedDept === stat.dept ? 'bg-primary text-white' : 'hover:bg-slate-100 dark:hover:bg-slate-700'"
                @click="toggleDepartmentFilter(stat.dept)"
              >
                {{ stat.dept }}
                <div class="flex items-center gap-1">
                  <span class="text-xs font-medium" :class="selectedDept === stat.dept ? 'opacity-100' : 'opacity-70'">
                    在职: <span class="text-green-500 dark:text-green-400">{{ stat.activeCount }}</span>
                  </span>
                  <span class="text-xs font-medium" :class="selectedDept === stat.dept ? 'opacity-100' : 'opacity-70'">
                    全部: <span class="text-blue-500 dark:text-blue-400">{{ stat.allCount }}</span>
                  </span>
                </div>
              </button>
            </div>
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
              class="border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-700 dark:text-slate-300 px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
              @click="downloadPersonList"
            >
              <el-icon class="text-[16px]"><Download /></el-icon> 下载
            </button>
            <button 
              class="bg-primary hover:bg-blue-600 text-white px-3 py-1.5 rounded-lg text-xs font-medium flex items-center gap-1"
              @click="showAddPersonDialog = true"
            >
              <el-icon class="text-[16px]"><Plus /></el-icon> 添加人员
            </button>
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
              width="100"
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
                  'text-green-500 dark:text-green-400': row.inputType === '实际',
                  'text-gray-500 dark:text-gray-400': row.inputType === '虚拟'
                }">
                  {{ row.inputType }}
                </span>
              </template>
            </el-table-column>
            <el-table-column
              prop="contact"
              label="对接人"
              width="90"
            />
            <el-table-column
              prop="entryDate"
              label="入场日期"
              width="100"
            />
            <el-table-column
              prop="exitDate"
              label="离场日期"
              width="100"
            >
              <template #default="{ row }">
                <span>{{ row.exitDate || '未离场' }}</span>
              </template>
            </el-table-column>
            <el-table-column
              prop="settlementLevel"
              label="级别"
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
              v-for="month in months"
              :key="month"
              :label="month + '月'"
              width="75"
              align="right"
            >
              <template #default="{ row }">
                <div class="relative">
                  <span 
                    class="font-semibold cursor-pointer hover:text-primary transition-colors"
                    @click="showWorkDayInput(row, month)"
                  >
                    {{ row.workDays && row.workDays[month] ? row.workDays[month] : calculateMonthlyWorkDays(row, month) }}
                  </span>
                  <el-input
                    v-if="editingCell === `${row.name}-${month}`"
                    v-model="editValue"
                    size="small"
                    @blur="saveWorkDay(row, month)"
                    @keyup.enter="saveWorkDay(row, month)"
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
                  <el-button link type="primary" size="small" @click="editPerson(row)">编辑</el-button>
                  <el-button link type="danger" size="small" @click="deletePerson($index)">删除</el-button>
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
                v-for="(level, index) in settlementLevels" 
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
            <input 
              v-model="editProject.contractPeriod"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="YYYY-MM-DD ~ YYYY-MM-DD"
              type="text"
            />
            <p v-if="editErrors.contractPeriod" class="text-xs text-red-500 mt-1">{{ editErrors.contractPeriod }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">客户名称</label>
            <input 
              v-model="editProject.customer"
              class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              placeholder="请输入客户名称"
              type="text"
            />
            <p v-if="editErrors.customer" class="text-xs text-red-500 mt-1">{{ editErrors.customer }}</p>
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
                v-model="approvalConfig.amount"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入立项金额"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">立项毛利率</label>
              <input 
                v-model="approvalConfig.grossMargin"
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
                v-for="(period, index) in approvalConfig.settlementPeriods" 
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
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">小组</label>
              <input 
                v-model="personForm.team"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入小组"
                type="text"
              />
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">岗位</label>
              <input 
                v-model="personForm.position"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入岗位"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结算部门</label>
              <input 
                v-model="personForm.settlementDept"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入结算部门"
                type="text"
              />
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">对接人</label>
              <input 
                v-model="personForm.contact"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                placeholder="请输入对接人"
                type="text"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">结算等级</label>
              <select 
                v-model="personForm.settlementLevel"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                @change="handleSettlementLevelChange"
              >
                <option value="">请选择结算等级</option>
                <option v-for="level in settlementLevels" :key="level.name" :value="level.name">
                  {{ level.name }}
                </option>
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
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">投入类型</label>
              <select 
                v-model="personForm.inputType"
                class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
              >
                <option value="实际">实际</option>
                <option value="虚拟">虚拟</option>
              </select>
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
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const username = ref('')
const userDisplayName = ref('')
const userEmail = ref('')
const userRole = ref('')
const searchQuery = ref('')

// 计算属性：是否为系统管理员
const isAdmin = computed(() => {
  return userRole.value === 'admin'
})
const showCreateProjectDialog = ref(false)
const showSettlementConfigDialog = ref(false)
const showEditProjectDialog = ref(false)
const showApprovalConfigDialog = ref(false)
const showAddImportantItemDialog = ref(false)
const showAddContractDialog = ref(false)
const currentContractType = ref('main')

// 订单管理相关
const showAddOrderDialog = ref(false)
const isEditingOrder = ref(false)
const currentOrderIndex = ref(-1)

// 人员管理相关
const showAddPersonDialog = ref(false)
const isEditingPerson = ref(false)
const currentPersonIndex = ref(-1)
const showTaxPrice = ref(true)
const personSearchQuery = ref('')
const selectedDept = ref('')

// 计算所有唯一的部门
const departments = computed(() => {
  const depts = new Set(persons.value.map(person => person.settlementDept))
  return Array.from(depts).filter(dept => dept)
})

// 统计部门人员数量
const departmentStats = computed(() => {
  return departments.value.map(dept => {
    const allCount = persons.value.filter(person => person.settlementDept === dept).length
    const activeCount = persons.value.filter(person => person.settlementDept === dept && !person.exitDate).length
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

// 月份数组（1-12月）
const months = ref([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])

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

// 过滤后的项目列表
const filteredProjects = computed(() => {
  if (!searchQuery.value) {
    return projectList.value
  }
  const query = searchQuery.value.toLowerCase()
  return projectList.value.filter(project => 
    project.label.toLowerCase().includes(query) || 
    project.customer.toLowerCase().includes(query)
  )
})

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

// 合同数据
const contracts = ref([
  {
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
  return contracts.value.filter(contract => contract.type === currentContractType.value)
})

// 主合同是否存在
const mainContractExists = computed(() => {
  return contracts.value.some(contract => contract.type === 'main')
})

// 订单数据
const orders = ref([
  {
    code: 'ORD2026001',
    period: '2026-01-01 / 01-31',
    orderDate: '2026-01-01',
    attachment: null
  }
])

// 订单表单
const orderForm = reactive({
  code: '',
  startDate: '',
  endDate: '',
  orderDate: '',
  attachment: null
})

// 人员数据
const persons = ref([
  {
    name: '张三',
    team: '开发组',
    position: '前端工程师',
    settlementDept: '技术部',
    contact: '李四',
    entryDate: '2026-01-01',
    exitDate: '',
    settlementLevel: '高级',
    priceWithTax: 1000,
    priceWithoutTax: 943.4,
    inputType: '实际' // 投入类型：实际或虚拟
  }
])

// 人员表单
const personForm = reactive({
  name: '',
  team: '',
  position: '',
  settlementDept: '',
  contact: '',
  entryDate: '',
  exitDate: '',
  settlementLevel: '',
  inputType: '实际', // 投入类型：实际或虚拟
  priceWithTax: 0,
  priceWithoutTax: 0
})

// 过滤后的人员列表
const filteredPersons = computed(() => {
  let result = [...persons.value]
  
  // 按部门筛选
  if (selectedDept.value) {
    result = result.filter(person => person.settlementDept === selectedDept.value)
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
watch([personSearchQuery, selectedDept], () => {
  currentPage.value = 1
})

// 结算等级配置
const settlementLevels = ref([
  {
    name: '高级',
    priceWithTax: 1000,
    priceWithoutTax: 943.4
  },
  {
    name: '中级',
    priceWithTax: 800,
    priceWithoutTax: 754.72
  },
  {
    name: '初级',
    priceWithTax: 600,
    priceWithoutTax: 566.04
  }
])

// 立项配置
const approvalConfig = reactive({
  amount: '',
  grossMargin: '',
  settlementPeriods: [
    {
      startDate: '',
      endDate: '',
      assessmentDate: '',
      paymentDate: ''
    }
  ]
})

// 项目重要事项
const importantItems = ref([
  {
    title: '项目启动会议',
    date: '2026-01-05',
    color: 'red'
  },
  {
    title: '需求评审完成',
    date: '2026-01-20',
    color: 'red'
  }
])

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
  contractPeriod: '',
  customer: '',
  type: '运营类',
  amount: '',
  approvalAmount: '',
  grossMargin: ''
})

const editErrors = reactive({
  name: '',
  contractPeriod: '',
  customer: ''
})

onMounted(() => {
  // 从localStorage获取用户信息
  const userStr = localStorage.getItem('user')
  let loginAccount = ''
  if (userStr) {
    const user = JSON.parse(userStr)
    loginAccount = user.username || ''
    username.value = user.username || 'Admin User'
    userEmail.value = user.email || 'admin@chengyan.com'
    userRole.value = user.role || 'admin'
  } else {
    username.value = 'Admin User'
    userEmail.value = 'admin@chengyan.com'
    userRole.value = 'admin'
  }
  
  // 从系统用户数据中查找用户的显示姓名、邮箱和角色
  const systemUsers = localStorage.getItem('system_users')
  if (systemUsers) {
    const users = JSON.parse(systemUsers)
    const currentUser = users.find((u: any) => u.account === loginAccount || u.account === username.value)
    if (currentUser) {
      // 显示后台管理系统中配置的姓名
      userDisplayName.value = currentUser.name || currentUser.account
      if (currentUser.email) {
        userEmail.value = currentUser.email
      }
      if (currentUser.role) {
        userRole.value = currentUser.role
      }
    } else {
      userDisplayName.value = username.value
    }
  } else {
    userDisplayName.value = username.value
  }
})

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

const handleProjectClick = (project: any) => {
  currentProject.value = project
}

const handleEditProject = () => {
  if (currentProject.value) {
    // 填充编辑表单
    editProject.name = currentProject.value.label || ''
    editProject.contractPeriod = currentProject.value.contractPeriod || ''
    editProject.customer = currentProject.value.customer || ''
    editProject.type = currentProject.value.type || '运营类'
    editProject.amount = currentProject.value.amount || ''
    editProject.approvalAmount = currentProject.value.approvalAmount || ''
    editProject.grossMargin = currentProject.value.grossMargin || ''
    
    // 重置错误信息
    Object.assign(editErrors, {
      name: '',
      contractPeriod: '',
      customer: ''
    })
    
    // 显示编辑对话框
    showEditProjectDialog.value = true
  }
}

const updateProject = () => {
  // 表单验证
  let isValid = true
  
  if (!editProject.name) {
    editErrors.name = '请输入项目名称'
    isValid = false
  } else {
    editErrors.name = ''
  }
  
  if (!editProject.contractPeriod) {
    editErrors.contractPeriod = '请输入合同周期'
    isValid = false
  } else {
    editErrors.contractPeriod = ''
  }
  
  if (!editProject.customer) {
    editErrors.customer = '请输入客户名称'
    isValid = false
  } else {
    editErrors.customer = ''
  }
  
  if (!isValid) return
  
  // 找到并更新项目
  const projectIndex = projectList.value.findIndex(p => p.id === currentProject.value?.id)
  if (projectIndex !== -1) {
    projectList.value[projectIndex] = {
      ...projectList.value[projectIndex],
      label: editProject.name,
      type: editProject.type,
      amount: editProject.amount,
      contractPeriod: editProject.contractPeriod,
      customer: editProject.customer
    }
    
    // 更新当前项目
    currentProject.value = projectList.value[projectIndex]
    
    showEditProjectDialog.value = false
    ElMessage.success('项目更新成功')
  }
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

// 结算配置方法
const addSettlementLevel = () => {
  settlementLevels.value.push({
    name: '',
    priceWithTax: 0,
    priceWithoutTax: 0
  })
}

const removeSettlementLevel = (index: number) => {
  settlementLevels.value.splice(index, 1)
}

const saveSettlementConfig = () => {
  // 这里可以添加保存逻辑，例如发送API请求或保存到localStorage
  console.log('保存结算配置:', settlementLevels.value)
  ElMessage.success('结算配置保存成功')
  showSettlementConfigDialog.value = false
}

// 立项配置方法
const addSettlementPeriod = () => {
  approvalConfig.settlementPeriods.push({
    startDate: '',
    endDate: '',
    assessmentDate: '',
    paymentDate: ''
  })
}

const removeSettlementPeriod = (index: number) => {
  approvalConfig.settlementPeriods.splice(index, 1)
}

const saveApprovalConfig = () => {
  // 这里可以添加保存逻辑，例如发送API请求或保存到localStorage
  console.log('保存立项配置:', approvalConfig)
  
  // 更新当前项目的立项金额和毛利率
  if (currentProject.value) {
    const projectIndex = projectList.value.findIndex(p => p.id === currentProject.value?.id)
    if (projectIndex !== -1) {
      projectList.value[projectIndex] = {
        ...projectList.value[projectIndex],
        approvalAmount: approvalConfig.amount,
        grossMargin: approvalConfig.grossMargin
      }
      currentProject.value = projectList.value[projectIndex]
    }
  }
  
  ElMessage.success('立项配置保存成功')
  showApprovalConfigDialog.value = false
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
      title: importantItemForm.title,
      date: importantItems.value[currentImportantItemIndex.value].date, // 保持原有日期
      color: importantItemForm.color
    }
    ElMessage.success('重要事项编辑成功')
  } else {
    // 添加新事项
    importantItems.value.push({
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

const saveContract = () => {
  // 验证表单
  if (!contractForm.name || !contractForm.code || !contractForm.amount || !contractForm.startDate || !contractForm.endDate || !contractForm.customer) {
    ElMessage.error('请填写所有必填字段')
    return
  }
  
  // 合并开始日期和结束日期为period字段
  const period = `${contractForm.startDate} / ${contractForm.endDate}`
  
  // 添加合同
  contracts.value.push({
    type: currentContractType.value,
    name: contractForm.name,
    code: contractForm.code,
    amount: contractForm.amount,
    period: period,
    customer: contractForm.customer,
    attachment: contractForm.attachment
  })
  
  ElMessage.success('合同添加成功')
  
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
}

const previewAttachment = (attachment: any) => {
  // 在实际应用中，这里应该打开PDF预览
  ElMessage.info('PDF预览功能已触发')
  console.log('预览附件:', attachment)
}

const editContract = (contract: any) => {
  // 填充表单数据
  contractForm.name = contract.name
  contractForm.code = contract.code
  contractForm.amount = contract.amount
  
  // 解析开始日期和结束日期
  if (contract.period) {
    const [startDate, endDate] = contract.period.split(' / ')
    contractForm.startDate = startDate
    contractForm.endDate = endDate
  }
  
  contractForm.customer = contract.customer
  contractForm.attachment = contract.attachment
  
  // 显示编辑对话框
  showAddContractDialog.value = true
}

const deleteContract = (index: number) => {
  // 获取要删除的合同
  const contractToDelete = filteredContracts.value[index]
  
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

const saveOrder = () => {
  // 验证表单
  if (!orderForm.code || !orderForm.startDate || !orderForm.endDate || !orderForm.orderDate) {
    ElMessage.error('请填写所有必填字段')
    return
  }
  
  // 合并开始日期和结束日期为period字段
  const period = `${orderForm.startDate} / ${orderForm.endDate}`
  
  if (isEditingOrder.value && currentOrderIndex.value !== -1) {
    // 编辑现有订单
    orders.value[currentOrderIndex.value] = {
      code: orderForm.code,
      period: period,
      orderDate: orderForm.orderDate,
      attachment: orderForm.attachment
    }
    ElMessage.success('订单编辑成功')
  } else {
    // 添加新订单
    orders.value.push({
      code: orderForm.code,
      period: period,
      orderDate: orderForm.orderDate,
      attachment: orderForm.attachment
    })
    ElMessage.success('订单添加成功')
  }
  
  // 重置表单
  Object.assign(orderForm, {
    code: '',
    startDate: '',
    endDate: '',
    orderDate: '',
    attachment: null
  })
  
  showAddOrderDialog.value = false
  isEditingOrder.value = false
  currentOrderIndex.value = -1
}

const previewOrderAttachment = (attachment: any) => {
  // 在实际应用中，这里应该打开PDF预览
  ElMessage.info('PDF预览功能已触发')
  console.log('预览订单附件:', attachment)
}

const downloadOrderAttachment = (attachment: any) => {
  // 在实际应用中，这里应该触发文件下载
  ElMessage.info('PDF下载功能已触发')
  console.log('下载订单附件:', attachment)
}

const editOrder = (order: any) => {
  // 填充表单数据
  orderForm.code = order.code
  
  // 解析开始日期和结束日期
  if (order.period) {
    const [startDate, endDate] = order.period.split(' / ')
    orderForm.startDate = startDate
    orderForm.endDate = endDate
  }
  
  orderForm.orderDate = order.orderDate
  orderForm.attachment = order.attachment
  
  // 显示编辑对话框
  isEditingOrder.value = true
  currentOrderIndex.value = orders.value.indexOf(order)
  showAddOrderDialog.value = true
}

const deleteOrder = (index: number) => {
  orders.value.splice(index, 1)
  ElMessage.success('订单删除成功')
}

// 人员管理方法
const handleSettlementLevelChange = () => {
  if (personForm.settlementLevel) {
    const selectedLevel = settlementLevels.value.find(level => level.name === personForm.settlementLevel)
    if (selectedLevel) {
      personForm.priceWithTax = selectedLevel.priceWithTax
      personForm.priceWithoutTax = selectedLevel.priceWithoutTax
    }
  } else {
    personForm.priceWithTax = 0
    personForm.priceWithoutTax = 0
  }
}

const savePerson = () => {
  // 验证表单
  if (!personForm.name || !personForm.team || !personForm.position || !personForm.settlementDept || !personForm.contact || !personForm.entryDate || !personForm.settlementLevel) {
    ElMessage.error('请填写所有必填字段')
    return
  }
  
  if (isEditingPerson.value && currentPersonIndex.value !== -1) {
    // 编辑现有人员
    persons.value[currentPersonIndex.value] = {
      ...personForm
    }
    ElMessage.success('人员编辑成功')
  } else {
    // 添加新人员
    persons.value.push({
      ...personForm
    })
    ElMessage.success('人员添加成功')
  }
  
  // 重置表单
  Object.assign(personForm, {
    name: '',
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
}

const editPerson = (person: any) => {
  // 填充表单数据
  Object.assign(personForm, person)
  
  // 显示编辑对话框
  isEditingPerson.value = true
  currentPersonIndex.value = persons.value.indexOf(person)
  showAddPersonDialog.value = true
}

const deletePerson = (index: number) => {
  persons.value.splice(index, 1)
  ElMessage.success('人员删除成功')
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
const showWorkDayInput = (row: any, month: number) => {
  editingCell.value = `${row.name}-${month}`
  editValue.value = row.workDays && row.workDays[month] ? row.workDays[month] : calculateMonthlyWorkDays(row, month)
  // 在下一个DOM更新周期聚焦输入框
  setTimeout(() => {
    if (inputRef.value) {
      inputRef.value.focus()
    }
  }, 0)
}

// 保存工时
const saveWorkDay = (row: any, month: number) => {
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
      // 更新工时
      persons.value[index].workDays[month] = numValue.toFixed(3)
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

// 切换全屏
const toggleFullscreen = () => {
  if (!fullscreenRef.value) return
  
  if (!isFullscreen.value) {
    // 进入全屏
    if (fullscreenRef.value.requestFullscreen) {
      fullscreenRef.value.requestFullscreen()
    } else if (fullscreenRef.value.mozRequestFullScreen) {
      fullscreenRef.value.mozRequestFullScreen()
    } else if (fullscreenRef.value.webkitRequestFullscreen) {
      fullscreenRef.value.webkitRequestFullscreen()
    } else if (fullscreenRef.value.msRequestFullscreen) {
      fullscreenRef.value.msRequestFullscreen()
    }
  } else {
    // 退出全屏
    if (document.exitFullscreen) {
      document.exitFullscreen()
    } else if (document.mozCancelFullScreen) {
      document.mozCancelFullScreen()
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen()
    } else if (document.msExitFullscreen) {
      document.msExitFullscreen()
    }
  }
  
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
const calculateMonthlyWorkDays = (person: any, month: number) => {
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
  
  // 计算指定月份的开始和结束日期
  const year = contractStart.getFullYear() // 使用合同开始年份
  const monthStart = new Date(year, month - 1, 1)
  const monthEnd = new Date(year, month, 0)
  
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
  background-color: #f5f7fa;
}
</style>
