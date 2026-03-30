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

    Write-Host "=== PM2 Status ==="
    $result = $session.ExecuteCommand("pm2 status")
    Write-Host $result.Output

    Write-Host "=== PM2 Logs ==="
    $result = $session.ExecuteCommand("pm2 logs chengyan-api --lines 30 --nostream")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write-Host "=== API Health Check ==="
    $result = $session.ExecuteCommand("curl -s http://localhost:3000/api/health")
    Write-Host $result.Output

    Write-Host "=== API Login Test ==="
    $result = $session.ExecuteCommand("curl -s -X POST http://localhost:3000/api/auth/login -H 'Content-Type: application/json' -d '{""username"":""admin"",""password"":""richinfo@123""}'")
    Write-Host $result.Output

    Write-Host "=== Nginx Error Log (last 10) ==="
    $result = $session.ExecuteCommand("tail -10 /var/log/nginx/error.log")
    Write-Host $result.Output

    Write-Host "=== Nginx Access Log (last 10) ==="
    $result = $session.ExecuteCommand("tail -10 /var/log/nginx/access.log")
    Write-Host $result.Output

    Write-Host "=== Port 3000 ==="
    $result = $session.ExecuteCommand("ss -tlnp | grep 3000")
    Write-Host $result.Output
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
