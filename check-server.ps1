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

    Write-Host "`n=== Checking deployment directory ==="
    $result = $session.ExecuteCommand("ls -la /var/www/chengyanoperation/ 2>&1")
    Write-Host $result.Output

    Write-Host "`n=== Checking package.json version ==="
    $result = $session.ExecuteCommand("cat /var/www/chengyanoperation/package.json 2>&1 | Select-String 'version'")
    Write-Host $result.Output

    Write-Host "`n=== Checking dist folder date ==="
    $result = $session.ExecuteCommand("ls -la /var/www/chengyanoperation/dist/ 2>&1 | head -20")
    Write-Host $result.Output

    Write-Host "`n=== Checking git log (if exists) ==="
    $result = $session.ExecuteCommand("cd /var/www/chengyanoperation && git log -1 --format='Commit: %H%nDate: %ai%nMessage: %s' 2>&1")
    Write-Host $result.Output
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
