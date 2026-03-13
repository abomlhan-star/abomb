const axios = require('axios');

async function testPermissionsAPI() {
  try {
    // 首先使用cs账号登录
    const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
      username: 'cs',
      password: '123456'
    });
    
    const token = loginResponse.data.token;
    console.log('✅ cs账号登录成功，获取到token');
    
    // 测试获取项目列表
    const projectsResponse = await axios.get('http://localhost:3000/api/projects', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    const projects = projectsResponse.data;
    console.log(`✅ cs账号获取到 ${projects.length} 个项目`);
    console.log('项目列表:', projects.map(p => p.name));
    
    // 测试访问测试项目详情（尝试访问ID为7的测试项目）
    try {
      const projectResponse = await axios.get('http://localhost:3000/api/projects/7', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      console.log('❌ 测试项目详情访问成功，这是错误的！');
    } catch (error) {
      console.log('✅ 测试项目详情访问失败，这是正确的！');
      console.log('错误信息:', error.response?.data);
    }
    
    // 测试访问咪咕音乐项目详情（尝试访问ID为6的项目）
    try {
      const projectResponse = await axios.get('http://localhost:3000/api/projects/6', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      console.log('✅ 咪咕音乐项目详情访问成功，这是正确的！');
    } catch (error) {
      console.log('❌ 咪咕音乐项目详情访问失败，这是错误的！');
      console.log('错误信息:', error.response?.data);
    }
    
    // 测试访问测试项目权限（尝试访问ID为7的测试项目权限）
    try {
      const permissionsResponse = await axios.get('http://localhost:3000/api/projects/7/permissions', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      console.log('✅ 测试项目权限访问成功，这是正确的！');
      console.log('权限数据:', permissionsResponse.data);
    } catch (error) {
      console.log('❌ 测试项目权限访问失败，这是错误的！');
      console.log('错误信息:', error.response?.data);
    }
    
  } catch (error) {
    console.error('测试权限API失败:');
    console.error('错误信息:', error.message);
    console.error('响应数据:', error.response?.data);
    console.error('响应状态:', error.response?.status);
  }
}

testPermissionsAPI();