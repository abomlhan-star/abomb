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

    Write-Host "=== Node.js Version ==="
    $result = $session.ExecuteCommand("node -v")
    Write-Host $result.Output

    Write-Host "=== NPM Version ==="
    $result = $session.ExecuteCommand("npm -v")
    Write-Host $result.Output

    Write-Host "=== PM2 Status ==="
    $result = $session.ExecuteCommand("pm2 list 2>/dev/null || echo 'PM2 not installed'")
    Write-Host $result.Output

    Write-Host "=== MySQL Status ==="
    $result = $session.ExecuteCommand("systemctl status mysql 2>/dev/null || systemctl status mysqld 2>/dev/null || echo 'MySQL not found'")
    Write-Host $result.Output

    Write-Host "=== Existing Backend Files ==="
    $result = $session.ExecuteCommand("ls -la /var/www/chengyan-operation/server/ 2>/dev/null || echo 'No backend files found'")
    Write-Host $result.Output

    Write-Host "=== Existing .env ==="
    $result = $session.ExecuteCommand("cat /var/www/chengyan-operation/server/.env 2>/dev/null || echo 'No .env found'")
    Write-Host $result.Output

    Write-Host "=== Port 3000 ==="
    $result = $session.ExecuteCommand("ss -tlnp | grep 3000 || echo 'Port 3000 not in use'")
    Write-Host $result.Output
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
