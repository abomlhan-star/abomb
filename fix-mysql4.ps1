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

    Write "=== Update .env DB_HOST to 127.0.0.1 ==="
    $result = $session.ExecuteCommand("sed -i 's/DB_HOST=localhost/DB_HOST=127.0.0.1/' /var/www/chengyan-operation/server/.env")
    Write-Host $result.Output

    Write "=== Verify .env ==="
    $result = $session.ExecuteCommand("cat /var/www/chengyan-operation/server/.env")
    Write-Host $result.Output

    Write "=== Test Node.js connection to 127.0.0.1 ==="
    $result = $session.ExecuteCommand("cd /var/www/chengyan-operation/server ; node -e ""const mysql = require('mysql2/promise'); mysql.createConnection({host:'127.0.0.1',user:'root',password:'Richinfo@123'}).then(c=>{console.log('OK');c.end()}).catch(e=>console.log('ERR:',e.message))"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Restart PM2 ==="
    $result = $session.ExecuteCommand("pm2 restart chengyan-api 2>&1")
    Write-Host $result.Output

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
