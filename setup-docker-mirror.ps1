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

    # Step 1: Configure Docker mirror (China mirror)
    Write-Host "`n=== Step 1: Configure Docker Mirror ===" -ForegroundColor Cyan
    
    $daemonJson = @"
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
"@
    
    Write-Host "Creating /etc/docker/daemon.json..."
    $result = $session.ExecuteCommand("mkdir -p /etc/docker && cat > /etc/docker/daemon.json << 'EOF'
$daemonJson
EOF")
    
    Write-Host "Restarting Docker to apply mirror config..."
    $result = $session.ExecuteCommand("systemctl daemon-reload && systemctl restart docker")
    Start-Sleep -Seconds 5
    
    # Verify Docker is running
    $result = $session.ExecuteCommand("docker info | grep -A5 'Registry Mirrors'")
    Write-Host "Mirror configured: $($result.Output)"

    # Step 2: Pull images with retry
    Write-Host "`n=== Step 2: Pull Docker Images ===" -ForegroundColor Cyan
    
    # Try pulling MySQL image
    Write-Host "Pulling mysql:8.0..."
    for ($i = 1; $i -le 3; $i++) {
        $result = $session.ExecuteCommand("docker pull mysql:8.0 2>&1")
        if ($result.ExitCode -eq 0) {
            Write-Host "mysql:8.0 pulled successfully!" -ForegroundColor Green
            break
        } else {
            Write-Host "Attempt $i failed: $($result.Output.Substring(0, [Math]::Min(100, $result.Output.Length)))" -ForegroundColor Yellow
            if ($i -lt 3) { Start-Sleep -Seconds 10 }
        }
    }
    
    # Try pulling Node.js image
    Write-Host "Pulling node:18-alpine..."
    for ($i = 1; $i -le 3; $i++) {
        $result = $session.ExecuteCommand("docker pull node:18-alpine 2>&1")
        if ($result.ExitCode -eq 0) {
            Write-Host "node:18-alpine pulled successfully!" -ForegroundColor Green
            break
        } else {
            Write-Host "Attempt $i failed" -ForegroundColor Yellow
            if ($i -lt 3) { Start-Sleep -Seconds 10 }
        }
    }
    
    # Try pulling Nginx image
    Write-Host "Pulling nginx:alpine..."
    for ($i = 1; $i -le 3; $i++) {
        $result = $session.ExecuteCommand("docker pull nginx:alpine 2>&1")
        if ($result.ExitCode -eq 0) {
            Write-Host "nginx:alpine pulled successfully!" -ForegroundColor Green
            break
        } else {
            Write-Host "Attempt $i failed" -ForegroundColor Yellow
            if ($i -lt 3) { Start-Sleep -Seconds 10 }
        }
    }

    # Step 3: Build and start containers
    Write-Host "`n=== Step 3: Build and Start Containers ===" -ForegroundColor Cyan
    $projectDir = "/opt/chengyan-operation"
    
    Write-Host "Building and starting..."
    $result = $session.ExecuteCommand("cd ${projectDir} && docker compose up -d --build 2>&1")
    Write-Host $result.Output

    # Wait for services
    Write-Host "`nWaiting for services..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20

    # Step 4: Verify
    Write-Host "`n=== Step 4: Verify Deployment ===" -ForegroundColor Cyan
    $result = $session.ExecuteCommand("docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'")
    Write-Host $result.Output

    # Test endpoints
    Write-Host "`nTesting endpoints:"
    $result = $session.ExecuteCommand("curl -s http://localhost:8080/health 2>&1 || echo 'Frontend not ready'")
    Write-Host "  Frontend: $($result.Output)"
    
    $result = $session.ExecuteCommand("curl -s http://localhost:3001/api/health 2>&1 || echo 'Backend not ready'")
    Write-Host "  Backend: $($result.Output)"

    Write-Host "`n=== Done ===" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
