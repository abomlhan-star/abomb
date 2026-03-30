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

    Write "=== Fix MySQL root auth for localhost ==="
    $result = $session.ExecuteCommand("mysql -uroot -e ""ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'Richinfo@123'; FLUSH PRIVILEGES;"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Verify auth change ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -e 'SELECT 1;' 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Create database ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -e ""CREATE DATABASE IF NOT EXISTS chengyan_operation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Import init SQL ==="
    $result = $session.ExecuteCommand("ls /var/www/chengyan-operation/database/ 2>/dev/null || echo 'No database dir'")
    Write-Host $result.Output

    Write "=== Restart PM2 ==="
    $result = $session.ExecuteCommand("pm2 restart chengyan-api 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Wait and check ==="
    $result = $session.ExecuteCommand("sleep 3 ; pm2 status 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Health check ==="
    $result = $session.ExecuteCommand("curl -s http://localhost:3000/api/health 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== PM2 logs ==="
    $result = $session.ExecuteCommand("pm2 logs chengyan-api --lines 20 --nostream 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
