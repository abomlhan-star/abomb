# 部署脚本
$server = "47.108.184.131"
$username = "root"
$password = "Richinfo@123"
$localPath = "dist"
$remotePath = "/usr/share/nginx/html/dist"

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
    
    # 上传文件
    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
    
    $transferResult = $session.PutFiles($localPath + "\*", $remotePath + "/", $false, $transferOptions)
    
    # 检查结果
    $transferResult.Check()
    
    foreach ($transfer in $transferResult.Transfers) {
        Write-Host "上传成功: $($transfer.FileName)"
    }
    
    Write-Host "部署完成!"
}
catch {
    Write-Host "错误: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
