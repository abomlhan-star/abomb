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

    # Step 1: Force configure Docker mirror and restart
    Write-Host "`n=== Step 1: Configure Docker Mirror ===" -ForegroundColor Cyan
    
    # Create daemon.json with mirrors
    $daemonConfig = @"
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.m.daocloud.io"
  ]
}
"@
    
    # Write config file using heredoc
    $result = $session.ExecuteCommand("cat > /etc/docker/daemon.json << 'DAEMONEOF'
$daemonConfig
DAEMONEOF")
    
    # Verify config was written
    $result = $session.ExecuteCommand("cat /etc/docker/daemon.json")
    Write-Host "daemon.json content:"
    Write-Host $result.Output
    
    # Restart Docker service completely
    Write-Host "Restarting Docker service..."
    $result = $session.ExecuteCommand("systemctl stop docker && sleep 2 && systemctl start docker && sleep 3")
    Write-Host "Docker restarted"
    
    # Verify mirror is active
    $result = $session.ExecuteCommand("docker info 2>&1 | grep -A10 'Registry Mirrors' || echo 'No mirror info'")
    Write-Host "Mirror status:"
    Write-Host $result.Output

    # Step 2: Test pulling a small image first
    Write-Host "`n=== Step 2: Test Docker Pull ===" -ForegroundColor Cyan
    Write-Host "Testing with hello-world (small image)..."
    $result = $session.ExecuteCommand("docker pull hello-world 2>&1 | tail -5")
    if ($result.ExitCode -eq 0) {
        Write-Host "Docker pull works! Mirror is configured correctly." -ForegroundColor Green
        $session.ExecuteCommand("docker rmi hello-world") | Out-Null
    } else {
        Write-Host "Pull failed, trying alternative approach..." -ForegroundColor Yellow
        
        # Try direct pull from Chinese mirror
        Write-Host "Trying to pull from Chinese registry directly..."
        $result = $session.ExecuteCommand("docker pull registry.cn-hangzhou.aliyuncs.com/library/mysql:8.0 --platform linux/amd64 2>&1 | tail -5")
        Write-Host "Aliyun MySQL: $($result.Output)"
        
        if ($result.ExitCode -eq 0) {
            # Tag it as mysql:8.0
            $session.ExecuteCommand("docker tag registry.cn-hangzhou.aliyuncs.com/library/mysql:8.0 mysql:8.0")
            Write-Host "MySQL image ready!" -ForegroundColor Green
            
            # Pull other images from Aliyun
            $aliImages = @(
                @{src="registry.cn-hangzhou.aliyuncs.com/library/node:18-alpine"; dst="node:18-alpine"},
                @{src="registry.cn-hangzhou.aliyuncs.com/library/nginx:alpine"; dst="nginx:alpine"}
            )
            
            foreach ($img in $aliImages) {
                Write-Host "Pulling $($img.dst) from Aliyun..."
                $pullResult = $session.ExecuteCommand("docker pull $($img.src) --platform linux/amd64 2>&1 | tail -3")
                if ($pullResult.ExitCode -eq 0) {
                    $session.ExecuteCommand("docker tag $($img.src) $($img.dst)")
                    Write-Host "  OK: $($img.dst)" -ForegroundColor Green
                } else {
                    Write-Host "  FAIL: $($img.dst)" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "Aliyun also failed. Network may be blocked." -ForegroundColor Red
        }
    }

    # Step 3: Check available images now
    Write-Host "`n=== Step 3: Available Images ===" -ForegroundColor Cyan
    $result = $session.ExecuteCommand("docker images")
    Write-Host $result.Output

    # If we have the base images, build custom ones
    $hasNode = ($result.Output -match "node.*18-alpine")
    $hasNginx = ($result.Output -match "nginx.*alpine")
    $hasMysql = ($result.Output -match "mysql.*8.0")

    if ($hasNode -and $hasNginx -and $hasMysql) {
        Write-Host "`n=== Step 4: Build Custom Images ===" -ForegroundColor Cyan
        $projectDir = "/opt/chengyan-operation"
        
        Write-Host "Building backend..."
        $buildResult = $session.ExecuteCommand("cd ${projectDir}/server && docker build -t chengyan-api . 2>&1 | tail -10")
        Write-Host $buildResult.Output
        
        Write-Host "Building frontend..."
        $buildResult = $session.ExecuteCommand("cd ${projectDir} && docker build -t chengyan-frontend . 2>&1 | tail -10")
        Write-Host $buildResult.Output

        # Start containers
        Write-Host "`n=== Step 5: Start Containers ===" -ForegroundColor Cyan
        $startResult = $session.ExecuteCommand("cd ${projectDir} && docker compose up -d 2>&1")
        Write-Host $startResult.Output
        
        Start-Sleep -Seconds 15
        
        # Verify
        Write-Host "`nContainer status:"
        $psResult = $session.ExecuteCommand("docker ps")
        Write-Host $psResult.Output
    } else {
        Write-Host "`nMissing required base images. Cannot proceed with containerization." -ForegroundColor Red
        Write-Host "Please check network connectivity or use VPN/proxy for Docker Hub access."
    }

    Write-Host "`n=== Done ===" -ForegroundColor Cyan
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
