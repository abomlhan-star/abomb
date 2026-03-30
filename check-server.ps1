# 检查服务器状态
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

# 安全改进：生产环境请使用指定主机密钥而非接受任意密钥
# 示例：$sessionOptions.SshHostKeyFingerprint = "ssh-rsa 2048 AA:BB:CC:DD:EE:FF:GG:HH:II:JJ:KK:LL:MM:NN:OO:PP:QQ"
$sessionOptions.GiveUpSecurityAndAcceptAnySshHostKey = $true

$session = New-Object WinSCP.Session

try {
    # 连接
    $session.Open($sessionOptions)
    Write-Host "连接成功!"
    
    # 检查文件列表
    Write-Host "=== 文件列表 ==="
    $result = $session.ExecuteCommand("ls -la /var/www/cheng-yan-operation/")
    Write-Host $result.Output
    
    # 检查 Nginx 配置
    Write-Host "=== Nginx 配置 ==="
    $result = $session.ExecuteCommand("cat /etc/nginx/sites-available/default")
    Write-Host $result.Output
    
    # 检查 Nginx 状态
    Write-Host "=== Nginx 状态 ==="
    $result = $session.ExecuteCommand("systemctl status nginx")
    Write-Host $result.Output
    
    # 检查 Nginx 日志
    Write-Host "=== Nginx 错误日志 ==="
    $result = $session.ExecuteCommand("tail -20 /var/log/nginx/error.log")
    Write-Host $result.Output
    
    # 检查防火墙状态
    Write-Host "=== 防火墙状态 ==="
    $result = $session.ExecuteCommand("ufw status")
    Write-Host $result.Output
}
catch {
    Write-Host "错误: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
