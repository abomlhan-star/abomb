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

    Write-Host "=== PM2 Logs (err only) ==="
    $result = $session.ExecuteCommand("pm2 logs chengyan-api --err --lines 50 --nostream")
    Write-Host "STDOUT:"
    Write-Host $result.Output
    Write-Host "STDERR:"
    Write-Host $result.ErrorOutput

    Write-Host "=== PM2 describe ==="
    $result = $session.ExecuteCommand("pm2 describe chengyan-api")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Try start manually ==="
    $result = $session.ExecuteCommand("cd /var/www/chengyan-operation/server ; node dist/index.js 2>&1 | head -30")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
