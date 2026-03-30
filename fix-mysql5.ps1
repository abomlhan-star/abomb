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

    Write "=== Current .env ==="
    $result = $session.ExecuteCommand("cat /var/www/chengyan-operation/server/.env")
    Write-Host $result.Output

    Write "=== MySQL users ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -h localhost -e ""SELECT user,host,plugin FROM mysql.user WHERE user='root';"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Node.js test 127.0.0.1 ==="
    $result = $session.ExecuteCommand("cd /var/www/chengyan-operation/server ; DB_HOST=127.0.0.1 DB_PASSWORD='Richinfo@123' node -e ""const mysql = require('mysql2/promise'); mysql.createConnection({host:'127.0.0.1',user:'root',password:'Richinfo@123'}).then(c=>{console.log('OK');c.end()}).catch(e=>console.log('ERR:',e.message))"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Delete and recreate PM2 process ==="
    $result = $session.ExecuteCommand("pm2 delete chengyan-api 2>&1")
    Write-Host $result.Output

    Write "=== Start fresh ==="
    $result = $session.ExecuteCommand("cd /var/www/chengyan-operation/server ; pm2 start dist/index.js --name chengyan-api 2>&1")
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
    $result = $session.ExecuteCommand("pm2 logs chengyan-api --lines 15 --nostream 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
