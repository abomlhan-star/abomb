$server = "47.108.184.131"
$username = "root"
$password = "Richinfo@123"

Add-Type -Path "C:\WinSCP\WinSCPnet.dll"

$sessionOptions = New-Object WinSCP.SessionOptions
$sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
$sessionOptions.HostName = $server
$sessionOptions.UserName = $username
$sessionOptions.Password = $password
$sessionOptions.GiveUpSecurityAndAcceptAnySshHostKey = $true

$session = New-Object WinSCP.Session

try {
    $session.Open($sessionOptions)
    Write-Host "Connected!"

    Write "=== Create dedicated MySQL user ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -h localhost -e ""CREATE USER IF NOT EXISTS 'chengyan'@'%' IDENTIFIED BY 'Richinfo@123'; GRANT ALL PRIVILEGES ON chengyan_operation.* TO 'chengyan'@'%'; FLUSH PRIVILEGES;"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Update .env with new user ==="
    $result = $session.ExecuteCommand("sed -i 's/DB_USER=root/DB_USER=chengyan/' /var/www/chengyan-operation/server/.env ; sed -i 's/DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/' /var/www/chengyan-operation/server/.env ; cat /var/www/chengyan-operation/server/.env")
    Write-Host $result.Output

    Write "=== Test with new user ==="
    $result = $session.ExecuteCommand("cd /var/www/chengyan-operation/server ; node -e ""const mysql=require('mysql2/promise');mysql.createConnection({host:'127.0.0.1',user:'chengyan',password:'Richinfo@123',database:'chengyan_operation'}).then(c=>{console.log('CONNECTION OK');c.end()}).catch(e=>console.log('ERR:',e.code,e.message))"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Delete and restart PM2 ==="
    $result = $session.ExecuteCommand("pm2 delete chengyan-api ; cd /var/www/chengyan-operation/server ; pm2 start dist/index.js --name chengyan-api 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Wait 5s ==="
    $result = $session.ExecuteCommand("sleep 5")

    Write "=== PM2 status ==="
    $result = $session.ExecuteCommand("pm2 status 2>&1")
    Write-Host $result.Output

    Write "=== Health check ==="
    $result = $session.ExecuteCommand("curl -s http://localhost:3000/api/health 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== PM2 logs ==="
    $result = $session.ExecuteCommand("pm2 logs chengyan-api --lines 10 --nostream 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
