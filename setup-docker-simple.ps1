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

    # Step 1: Write daemon.json using simple echo
    Write-Host "`nStep 1: Configure Docker mirrors..." -ForegroundColor Cyan
    
    $result = $session.ExecuteCommand('echo "{\"registry-mirrors\":[\"https://docker.m.daocloud.io\",\"https://dockerpull.org\"]}" > /etc/docker/daemon.json')
    
    # Verify
    $result = $session.ExecuteCommand("cat /etc/docker/daemon.json")
    Write-Host "Config content:"
    Write-Host $result.Output

    # Step 2: Restart Docker
    Write-Host "`nStep 2: Restart Docker..." -ForegroundColor Cyan
    $result = $session.ExecuteCommand("systemctl restart docker && echo 'Docker restarted'")
    Write-Host $result.Output
    
    Start-Sleep -Seconds 5

    # Step 3: Pull images one by one
    Write-Host "`nStep 3: Pull images..." -ForegroundColor Cyan
    
    Write-Host "Pulling mysql:8.0..."
    $r1 = $session.ExecuteCommand("docker pull mysql:8.0 2>&1 | tail -2")
    if ($r1.ExitCode -eq 0) { Write-Host "  OK" -ForegroundColor Green } else { Write-Host "  FAIL" -ForegroundColor Red }
    
    Write-Host "Pulling node:18-alpine..."
    $r2 = $session.ExecuteCommand("docker pull node:18-alpine 2>&1 | tail -2")
    if ($r2.ExitCode -eq 0) { Write-Host "  OK" -ForegroundColor Green } else { Write-Host "  FAIL" -ForegroundColor Red }
    
    Write-Host "Pulling nginx:alpine..."
    $r3 = $session.ExecuteCommand("docker pull nginx:alpine 2>&1 | tail -2")
    if ($r3.ExitCode -eq 0) { Write-Host "  OK" -ForegroundColor Green } else { Write-Host "  FAIL" -ForegroundColor Red }

    # Show images
    Write-Host "`nImages on server:"
    $imgs = $session.ExecuteCommand("docker images")
    Write-Host $imgs.Output

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
