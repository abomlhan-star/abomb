# 简单更新 Nginx 配置
$server = "47.108.184.131"
$username = "root"
$password = "Richinfo@123"

# 创建 WinSCP 会话对象
Add-Type -Path "C:\WinSCP\WinSCPnet.dll"

# 设置会话选项
$sessionOptions = New-Object WinSCP.SessionOptions
$sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
$sessionOptions.HostName = $server
$sessionOptions.UserName = $username
$sessionOptions.Password = $password
$sessionOptions.GiveUpSecurityAndAcceptAnySshHostKey = $true

$session = New-Object WinSCP.Session

try {
    # 连接
    $session.Open($sessionOptions)
    Write-Host "连接成功!"
    
    # 直接修改配置文件
    $session.ExecuteCommand("sed -i 's/root \/var\/www\/html;/root \/var\/www\/cheng-yan-operation;/' /etc/nginx/sites-available/default")
    
    # 重启 Nginx
    $session.ExecuteCommand("systemctl restart nginx")
    
    Write-Host "Nginx 配置已更新并重启!"
}
catch {
    Write-Host "错误: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
