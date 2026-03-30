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

    Write "=== Drop and recreate root@localhost with password ==="
    $result = $session.ExecuteCommand("mysql -uroot -e ""DROP USER IF EXISTS 'root'@'localhost'; CREATE USER 'root'@'localhost' IDENTIFIED BY 'Richinfo@123'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Test new password ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -e 'SELECT user,host,plugin FROM mysql.user WHERE user=""root"";' 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Create database ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -e ""CREATE DATABASE IF NOT EXISTS chengyan_operation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; SHOW DATABASES;"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Stop PM2 first ==="
    $result = $session.ExecuteCommand("pm2 stop chengyan-api 2>&1")
    Write-Host $result.Output

    Write "=== Start PM2 ==="
    $result = $session.ExecuteCommand("pm2 start chengyan-api 2>&1")
    Write-Host $result.Output

    Write "=== Wait 5s ==="
    $result = $session.ExecuteCommand("sleep 5")
    Write-Host $result.Output

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
