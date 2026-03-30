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

    Write-Host "=== sites-enabled ==="
    $result = $session.ExecuteCommand("ls -la /etc/nginx/sites-enabled/")
    Write-Host $result.Output

    Write-Host "=== nginx.conf ==="
    $result = $session.ExecuteCommand("cat /etc/nginx/nginx.conf")
    Write-Host $result.Output

    Write-Host "=== conf.d ==="
    $result = $session.ExecuteCommand("ls -la /etc/nginx/conf.d/")
    Write-Host $result.Output

    Write "=== conf.d default ==="
    $result = $session.ExecuteCommand("cat /etc/nginx/conf.d/default.conf")
    Write-Host $result.Output

    Write-Host "=== /usr/share/nginx/html ==="
    $result = $session.ExecuteCommand("ls -la /usr/share/nginx/html/")
    Write-Host $result.Output
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
