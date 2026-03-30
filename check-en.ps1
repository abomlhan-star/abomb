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

    Write-Host "=== File List ==="
    $result = $session.ExecuteCommand("ls -la /var/www/cheng-yan-operation/")
    Write-Host $result.Output

    Write-Host "=== Nginx Config ==="
    $result = $session.ExecuteCommand("cat /etc/nginx/sites-available/default")
    Write-Host $result.Output

    Write-Host "=== Nginx Status ==="
    $result = $session.ExecuteCommand("systemctl status nginx")
    Write-Host $result.Output

    Write-Host "=== Nginx Error Log ==="
    $result = $session.ExecuteCommand("tail -20 /var/log/nginx/error.log")
    Write-Host $result.Output
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
