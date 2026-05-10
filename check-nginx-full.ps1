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

    Write-Host "`n=== 检查Nginx完整配置 ==="
    $result = $session.ExecuteCommand("cat /etc/nginx/nginx.conf 2>&1")
    Write-Host $result.Output

    Write-Host "`n=== 检查各目录的index.html ==="
    $result = $session.ExecuteCommand("echo '--- /var/www/cheng-yan-operation/dist/ ---' && ls -la /var/www/cheng-yan-operation/dist/ 2>&1 && echo '--- /var/www/chengyan-operation/dist/ ---' && ls -la /var/www/chengyan-operation/dist/ 2>&1 && echo '--- /usr/share/nginx/html/dist/ ---' && ls -la /usr/share/nginx/html/dist/ 2>&1")
    Write-Host $result.Output

    Write-Host "`n=== 检查符号链接 ==="
    $result = $session.ExecuteCommand("ls -la /usr/share/nginx/html/ 2>&1")
    Write-Host $result.Output
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
