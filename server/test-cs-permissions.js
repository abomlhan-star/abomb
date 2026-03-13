const axios = require('axios');

// 测试cs用户的权限API访问
async function testCsPermissions() {
  try {
    console.log('=== 测试cs用户的权限API访问 ===');

    // 首先登录cs用户获取token
    console.log('1. 登录cs用户...');
    const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
      username: 'cs',
      password: '123456'
    });
    
    const token = loginResponse.data.token;
    console.log('登录成功，获取到token:', token.substring(0, 20) + '...');

    // 测试获取项目列表
    console.log('\n2. 获取项目列表...');
    const projectsResponse = await axios.get('http://localhost:3000/api/projects', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log('项目列表:', projectsResponse.data);

    // 测试获取测试项目（ID: 7）的权限
    console.log('\n3. 获取测试项目（ID: 7）的权限...');
    const permissionsResponse = await axios.get('http://localhost:3000/api/projects/7/permissions', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log('项目权限:', permissionsResponse.data);

    // 测试获取咪咕音乐用户运营项目（ID: 6）的权限（应该失败，因为cs用户没有该项目的权限）
    console.log('\n4. 尝试获取咪咕音乐用户运营项目（ID: 6）的权限...');
    try {
      const permissionsResponse2 = await axios.get('http://localhost:3000/api/projects/6/permissions', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      console.log('项目权限:', permissionsResponse2.data);
    } catch (error) {
      console.log('获取权限失败（预期行为）:', error.response?.data?.error || error.message);
    }

  } catch (error) {
    console.error('测试过程中出错:', error.response?.data?.error || error.message);
  }
}

testCsPermissions();