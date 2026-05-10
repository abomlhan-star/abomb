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
    Write-Host "Connecting to $server..."
    $session.Open($sessionOptions)
    Write-Host "Connected!"

    Write-Host "`n=== 检查Nginx配置 ==="
    $result = $session.ExecuteCommand("cat /etc/nginx/nginx.conf 2>&1 | grep -A 10 'root'")
    Write-Host $result.Output

    Write-Host "`n=== 检查Nginx sites-enabled ==="
    $result = $session.ExecuteCommand("ls -la /etc/nginx/sites-enabled/ 2>&1")
    Write-Host $result.Output

    Write-Host "`n=== 检查default配置 ==="
    $result = $session.ExecuteCommand("cat /etc/nginx/sites-enabled/default 2>&1 | grep -A 5 'root'")
    Write-Host $result.Output

    Write-Host "`n=== 查找项目目录 ==="
    $result = $session.ExecuteCommand("find /var/www -name 'index.html' -type f 2>&1 | head -10")
    Write-Host $result.Output

    Write-Host "`n=== 检查/var/www目录结构 ==="
    $result = $session.ExecuteCommand("ls -la /var/www/ 2>&1")
    Write-Host $result.Output
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
