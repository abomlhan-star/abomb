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

    # Step 1: Check OS and network
    Write-Host "`n=== Checking System ===" -ForegroundColor Cyan
    $osResult = $session.ExecuteCommand("cat /etc/os-release | head -3")
    Write-Host $osResult.Output

    # Step 2: Configure Docker with best available mirrors
    Write-Host "`n=== Configuring Docker Mirrors ===" -ForegroundColor Cyan
    
    # Use here-string for the JSON config
    $daemonJson = @"
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerpull.org",
    "https://docker.1panel.live"
  ]
}
"@
    
    # Write daemon.json
    $writeCmd = "echo '$daemonJson' > /etc/docker/daemon.json"
    # Actually use a different approach to avoid escaping issues
    
    $result = $session.ExecuteCommand("cat > /etc/docker/daemon.json << 'JSONEOF'
{
  `"registry-mirrors`": [
    `"https://docker.m.daocloud.io`",
    `"https://dockerpull.org`",
    `"https://docker.1panel.live`"
  ]
}
JSONEOF")
    
    Write-Host "Docker mirror config written"
    
    # Restart Docker
    Write-Host "Restarting Docker..."
    $result = $session.ExecuteCommand("systemctl restart docker && sleep 5")
    Write-Host "Docker restarted"

    # Verify mirrors are active
    $mirrorCheck = $session.ExecuteCommand("docker info 2>&1 | grep -i mirror")
    Write-Host "Mirror status: $($mirrorCheck.Output)"

    # Step 3: Test pulling images
    Write-Host "`n=== Testing Image Pull ===" -ForegroundColor Cyan
    
    $imagesToPull = @("mysql:8.0", "node:18-alpine", "nginx:alpine")
    $successCount = 0
    
    foreach ($image in $imagesToPull) {
        Write-Host "Pulling $image..." -ForegroundColor Yellow
        
        for ($retry = 1; $retry -le 3; $retry++) {
            $pullResult = $session.ExecuteCommand("docker pull $image 2>&1 | tail -3")
            
            if ($pullResult.ExitCode -eq 0) {
                Write-Host "  SUCCESS: $image" -ForegroundColor Green
                $successCount++
                break
            } else {
                if ($retry -lt 3) {
                    Write-Host "  Retry $retry/3..."
                    Start-Sleep -Seconds 5
                } else {
                    Write-Host "  FAILED: $image" -ForegroundColor Red
                }
            }
        }
    }

    # Show final image list
    Write-Host "`n=== Final Image List ===" -ForegroundColor Cyan
    $imagesResult = $session.ExecuteCommand("docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'")
    Write-Host $imagesResult.Output

    if ($successCount -eq 3) {
        Write-Host "`nAll images ready! You can now deploy containers." -ForegroundColor Green
        Write-Host "Run: powershell -ExecutionPolicy Bypass -File deploy-docker-final-v3.ps1" -ForegroundColor Cyan
    } elseif ($successCount -gt 0) {
        Write-Host "`nSome images pulled ($successCount/3). Network still unstable." -ForegroundColor Yellow
    } else {
        Write-Host "`nAll pulls failed. VPN or proxy may be needed." -ForegroundColor Red
        
        Write-Host `
"
SOLUTION OPTIONS:

Option 1: Install OpenVPN on server (if you have .ovpn file):
  yum install openvpn -y
  cp your-config.ovpn /etc/openvpn/client.conf
  systemctl start openvpn@client
  systemctl enable openvpn@client

Option 2: Use SSH SOCKS proxy:
  On your local machine, run:
    ssh -D 1080 -N user@proxy-server
  
  Then configure Docker to use it:
    mkdir -p /etc/systemd/system/docker.service.d
    cat > /etc/systemd/system/docker.service.d/proxy.conf << EOF
[Service]
Environment=`"SOCKS_PROXY=socks5://127.0.0.1:1080`"
EOF
    systemctl daemon-reload && systemctl restart docker

Option 3: Download images locally and transfer:
  On your Windows machine:
    docker pull mysql:8.0
    docker save mysql:8.0 | gzip > mysql.tar.gz
    scp mysql.tar.gz root@47.108.184.131:/root/
  
  On server:
    docker load < mysql.tar.gz
" -ForegroundColor Cyan
    }

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
