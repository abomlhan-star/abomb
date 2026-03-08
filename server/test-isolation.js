const http = require('http');

const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiYWNjb3VudCI6ImFkbWluIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzcyOTM1MjU0LCJleHAiOjE3NzM1NDAwNTR9.JDDKsj-sclnP5lSbLkPA06OR8o04gSZnjC1zC2AOFX8';

function makeRequest(path, projectId = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    };
    
    if (projectId) {
      options.headers['X-Project-Id'] = projectId;
    }

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => { body += chunk; });
      res.on('end', () => { resolve(JSON.parse(body)); });
    });

    req.on('error', reject);
    req.end();
  });
}

async function testDataIsolation() {
  console.log('=== 测试多项目数据隔离 ===\n');

  console.log('1. 获取所有项目列表:');
  const projects = await makeRequest('/api/projects');
  console.log(JSON.stringify(projects, null, 2));

  console.log('\n2. 获取项目1的人员数据 (project_id=1):');
  const persons1 = await makeRequest('/api/data/persons', 1);
  console.log(JSON.stringify(persons1, null, 2));

  console.log('\n3. 获取项目2的人员数据 (project_id=2):');
  const persons2 = await makeRequest('/api/data/persons', 2);
  console.log(JSON.stringify(persons2, null, 2));

  console.log('\n=== 数据隔离验证结果 ===');
  console.log(`项目1人员数量: ${persons1.length}`);
  console.log(`项目2人员数量: ${persons2.length}`);
  
  if (persons1.every(p => p.project_id === 1) && persons2.every(p => p.project_id === 2)) {
    console.log('✅ 数据隔离验证成功！各项目数据互不干扰。');
  } else {
    console.log('❌ 数据隔离验证失败！');
  }
}

testDataIsolation().catch(console.error);
