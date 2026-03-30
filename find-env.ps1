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

    Write-Host "=== .env content ==="
    $result = $session.ExecuteCommand("cat /var/www/chengyan-operation/server/.env")
    Write-Host $result.Output

    Write "=== Check for other .env files ==="
    $result = $session.ExecuteCommand("find /var/www -name '.env' 2>/dev/null")
    Write-Host $result.Output

    Write "=== Check home dir .env ==="
    $result = $session.ExecuteCommand("cat /root/.env 2>/dev/null || echo 'No .env in /root'")
    Write-Host $result.Output

    Write "=== Check project root .env ==="
    $result = $session.ExecuteCommand("cat /var/www/chengyan-operation/.env 2>/dev/null || echo 'No .env in project root'")
    Write-Host $result.Output
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
