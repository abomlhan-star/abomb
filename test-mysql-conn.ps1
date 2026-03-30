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

    Write "=== Verify MySQL user ==="
    $result = $session.ExecuteCommand("mysql -uroot -e ""SELECT user,host,plugin FROM mysql.user WHERE user='root';"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Test TCP connection with password ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -h 127.0.0.1 -e 'SELECT 1;' 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Test TCP connection with password via localhost ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -h localhost -e 'SELECT 1;' 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Node.js test connection ==="
    $result = $session.ExecuteCommand("cd /var/www/chengyan-operation/server ; node -e ""const mysql = require('mysql2/promise'); mysql.createConnection({host:'127.0.0.1',user:'root',password:'Richinfo@123'}).then(c=>{console.log('OK');c.end()}).catch(e=>console.log('ERR:',e.message))"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Node.js test via localhost ==="
    $result = $session.ExecuteCommand("cd /var/www/chengyan-operation/server ; node -e ""const mysql = require('mysql2/promise'); mysql.createConnection({host:'localhost',user:'root',password:'Richinfo@123'}).then(c=>{console.log('OK');c.end()}).catch(e=>console.log('ERR:',e.message))"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
