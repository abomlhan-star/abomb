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

    # Step 1: Check current images and containers
    Write-Host "`n=== Current State ===" -ForegroundColor Cyan
    
    Write-Host "All images:"
    $images = $session.ExecuteCommand("docker images")
    Write-Host $images.Output

    Write-Host "`nRunning containers:"
    $ps = $session.ExecuteCommand("docker ps")
    Write-Host $ps.Output

    # Step 2: Re-build backend image with explicit tag
    Write-Host "`n=== Rebuild Backend ===" -ForegroundColor Cyan
    $projectDir = "/opt/chengyan-operation"
    
    # Build backend with explicit output
    $buildResult = $session.ExecuteCommand("cd ${projectDir}/server && docker build --no-cache -t chengyan-api:latest . 2>&1 | tail -20")
    Write-Host "Build output:"
    Write-Host $buildResult.Output

    # Verify the image exists now
    $verifyImg = $session.ExecuteCommand("docker images | grep chengyan-api")
    Write-Host "`nBackend image check:"
    Write-Host $verifyImg.Output

    if ($verifyImg.Output -match "chengyan-api") {
        # Step 3: Start backend container using the local image directly
        Write-Host "`n=== Starting Backend Container ===" -ForegroundColor Cyan
        
        # Remove if exists
        $session.ExecuteCommand("docker rm -f chengyan-api 2>/dev/null || true") | Out-Null
        
        # Run with explicit reference to avoid registry lookup
        $runCmd = 'docker run -d --name chengyan-api --network host -e NODE_ENV=production -e PORT=3000 -e DB_HOST=127.0.0.1 -e DB_PORT=3307 -e DB_USER=root -e DB_PASSWORD=123456 -e DB_NAME=chengyan_operation chengyan-api:latest'
        
        $runResult = $session.ExecuteCommand($runCmd)
        Write-Host "Backend start result:"
        Write-Host $runResult.Output

        # Wait for startup
        Start-Sleep -Seconds 10

        # Step 4: Final verification
        Write-Host "`n=== Final Verification ===" -ForegroundColor Cyan
        
        $finalPs = $session.ExecuteCommand("docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'")
        Write-Host $finalPs.Output

        # Test endpoints
        Write-Host "`nEndpoint tests:"
        
        $frontTest = $session.ExecuteCommand("curl -s http://localhost:8080/health 2>&1 || echo 'not ready'")
        Write-Host "  Frontend(8080): $($frontTest.Output.Trim())"
        
        $backTest = $session.ExecuteCommand("curl -s http://localhost:3001/ 2>&1 || echo 'not ready')")
        Write-Host "  Backend(3001): $($backTest.Output.Trim())"

        # Show logs for any failing containers
        foreach ($container in @("chengyan-mysql", "chengyan-api", "chengyan-frontend")) {
            $checkRun = $session.ExecuteCommand("docker ps | grep $container")
            if ($checkRun.Output -notmatch $container) {
                Write-Host "`n--- $container logs ---" -ForegroundColor Red
                $logOut = $session.ExecuteCommand("docker logs $container 2>&1 | tail -10")
                Write-Host $logOut.Output
            }
        }

        Write-Host "`n=========================================" -ForegroundColor Green
        Write-Host "  Deployment Status Complete!" -ForegroundColor Green
        Write-Host "=========================================`n" -ForegroundColor Green
    } else {
        Write-Host "Backend image still not found after rebuild." -ForegroundColor Red
        Write-Host "Trying alternative approach..." -ForegroundColor Yellow
        
        # Show all images including intermediate
        $allImages = $session.ExecuteCommand("docker images -a")
        Write-Host "All images (including intermediates):"
        Write-Host $allImages.Output
    }

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
