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

    Write "=== Save PM2 ==="
    $result = $session.ExecuteCommand("pm2 save 2>&1")
    Write-Host $result.Output

    Write "=== PM2 startup ==="
    $result = $session.ExecuteCommand("pm2 startup systemd -u root --hp /root 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Test login API ==="
    $result = $session.ExecuteCommand("curl -s -X POST http://localhost:3000/api/auth/login -H 'Content-Type: application/json' -d '{""username"":""admin"",""password"":""richinfo@123""}' 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
