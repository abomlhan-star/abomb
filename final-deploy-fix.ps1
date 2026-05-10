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

    # Step 1: Check all images including dangling
    Write-Host "`n=== All Images ===" -ForegroundColor Cyan
    $allImages = $session.ExecuteCommand("docker images -a")
    Write-Host $allImages.Output

    # Step 2: Rebuild backend with explicit output name
    Write-Host "`n=== Rebuild Backend ===" -ForegroundColor Cyan
    
    # Clean any failed builds first
    $session.ExecuteCommand("docker builder prune -f") | Out-Null
    
    $buildCmd = "cd /opt/chengyan-operation/server && docker build --no-cache -t chengyan-api:latest . 2>&1"
    $buildResult = $session.ExecuteCommand($buildCmd)
    
    Write-Host "Build result (last 30 lines):"
    $lines = $buildResult.Output -split "`n"
    if ($lines.Count -gt 30) {
        ($lines[-30..-1] -join "`n")
    } else {
        $buildResult.Output
    }

    # Verify image exists now
    $verifyImg = $session.ExecuteCommand("docker images | grep -E 'chengyan|REPOSITORY'")
    Write-Host "`nImages after build:"
    Write-Host $verifyImg.Output

    if ($verifyImg.Output -match "chengyan-api") {
        # Get the actual image ID
        $imgId = $session.ExecuteCommand("docker images -q chengyan-api:latest")
        $imageId = $imgId.Output.Trim()
        
        Write-Host "`nImage ID: $imageId" -ForegroundColor Green
        
        # Start backend using image ID directly to avoid registry lookup
        Write-Host "`n=== Starting Backend Container ===" -ForegroundColor Cyan
        
        # Remove old container if exists
        $session.ExecuteCommand("docker rm -f chengyan-api 2>/dev/null || true") | Out-Null
        
        $runCmd = "docker run -d --name chengyan-api --network host -e NODE_ENV=production -e PORT=3000 -e DB_HOST=127.0.0.1 -e DB_PORT=3307 -e DB_USER=root -e DB_PASSWORD=123456 -e DB_NAME=chengyan_operation -p 3001:3000 ${imageId}"
        $runResult = $session.ExecuteCommand($runCmd)
        Write-Host "Backend start: $($runResult.Output.Trim())"

        # Also start/restart frontend
        Write-Host "`nStarting/Restarting Frontend..." -ForegroundColor Yellow
        $session.ExecuteCommand("docker rm -f chengyan-frontend 2>/dev/null || true") | Out-Null
        $frontStart = $session.ExecuteCommand("docker run -d --name chengyan-frontend -p 8080:80 chengyan-frontend:latest 2>&1")
        Write-Host "Frontend start: $($frontStart.Output.Trim())"

        # Wait for services
        Write-Host "`nWaiting for services..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15

        # Final verification
        Write-Host "`n=== Final Status ===" -ForegroundColor Green
        
        $psResult = $session.ExecuteCommand("docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'")
        Write-Host $psResult.Output

        # Test endpoints
        Write-Host "`nEndpoint tests:"
        
        $frontTest = $session.ExecuteCommand("curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/health 2>/dev/null || echo '000')")
        Write-Host "  Frontend(8080): HTTP $($frontTest.Output.Trim())"
        
        $backTest = $session.ExecuteCommand("curl -s -o /dev/null -w '%{http_code}' http://localhost:3001/ 2>/dev/null || echo '000')")
        Write-Host "  Backend(3001): HTTP $($backTest.Output.Trim())"

        Write-Host "`n=========================================" -ForegroundColor Green
        Write-Host "  Deployment Complete!" -ForegroundColor Green
        Write-Host "=========================================`n" -ForegroundColor Green
        Write-Host "Access:" -ForegroundColor Cyan
        Write-Host "  http://47.108.184.131:8080 (Frontend)" -ForegroundColor White
        Write-Host "  http://47.108.184.131:3001 (API)" -ForegroundColor White
    } else {
        Write-Host "`nBackend image still not found!" -ForegroundColor Red
        Write-Host "Checking build cache..."
        $cacheCheck = $session.ExecuteCommand("docker builder ls 2>&1 | head -10")
        Write-Host $cacheCheck.Output
    }

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
