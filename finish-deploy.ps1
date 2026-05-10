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

    # Check current state
    Write-Host "`n=== Current State ===" -ForegroundColor Cyan
    
    $images = $session.ExecuteCommand("docker images")
    Write-Host "Images:"
    Write-Host $images.Output
    
    $containers = $session.ExecuteCommand("docker ps -a")
    Write-Host "`nContainers:"
    Write-Host $containers.Output

    # Start Backend API
    Write-Host "`n=== Starting Backend ===" -ForegroundColor Cyan
    $apiStart = $session.ExecuteCommand("docker run -d --name chengyan-api --network host -e NODE_ENV=production -e PORT=3000 -e DB_HOST=127.0.0.1 -e DB_PORT=3307 -e DB_USER=root -e DB_PASSWORD=123456 -e DB_NAME=chengyan_operation -p 3001:3000 chengyan-api:latest 2>&1")
    Write-Host $apiStart.Output.Trim()

    Start-Sleep -Seconds 5

    # Build and start Frontend
    Write-Host "`n=== Building Frontend ===" -ForegroundColor Cyan
    $frontBuild = $session.ExecuteCommand("cd /opt/chengyan-operation && docker build --no-cache -t chengyan-frontend . 2>&1 | tail -15")
    
    if ($frontBuild.ExitCode -eq 0) {
        Write-Host "Frontend built!" -ForegroundColor Green
        
        Write-Host "`nStarting Frontend..." -ForegroundColor Yellow
        $frontStart = $session.ExecuteCommand("docker run -d --name chengyan-frontend -p 8080:80 chengyan-frontend:latest 2>&1")
        Write-Host $frontStart.Output.Trim()
    } else {
        Write-Host "Frontend build failed:" -ForegroundColor Red
        Write-Host $frontBuild.Output.Substring(0, [Math]::Min(400, $frontBuild.Output.Length))
    }

    # Wait for services
    Write-Host "`nWaiting for services (20s)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20

    # Final verification
    Write-Host "`n=== Final Verification ===" -ForegroundColor Cyan
    
    $psResult = $session.ExecuteCommand("docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'")
    Write-Host $psResult.Output

    # Test endpoints
    Write-Host "`nEndpoint tests:"
    
    $frontTest = $session.ExecuteCommand("curl -s http://localhost:8080/health 2>&1 || echo 'fail'")
    Write-Host "  Frontend(8080): $($frontTest.Output.Trim())"
    
    $backTest = $session.ExecuteCommand("curl -s http://localhost:3001/ 2>&1 || echo 'fail'")
    Write-Host "  Backend(3001): $($backTest.Output.Trim())"

    # Restore database
    Write-Host "`n=== Restore Database ===" -ForegroundColor Cyan
    for ($i = 1; $i -le 10; $i++) {
        $ping = $session.ExecuteCommand("docker exec chengyan-mysql mysqladmin ping -u root -p123456 2>&1")
        if ($ping.Output -match "alive") {
            $backupFind = $session.ExecuteCommand("ls -t /root/docker-data/backups/*.sql 2>/dev/null | head -1")
            if ($backupFind.Output.Length -gt 5) {
                Write-Host "Restoring database..."
                $restoreCmd = "cat $($backupFind.Output.Trim()) | docker exec -i chengyan-mysql mysql -u root -p123456 2>&1"
                $session.ExecuteCommand($restoreCmd)
                Write-Host "Database restored!" -ForegroundColor Green
            }
            break
        }
        Start-Sleep -Seconds 3
    }

    Write-Host "`n=========================================" -ForegroundColor Green
    Write-Host "  Docker Deployment Complete!" -ForegroundColor Green
    Write-Host "=========================================`n" -ForegroundColor Green

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
