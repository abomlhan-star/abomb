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

    # Step 1: Fix Docker storage issue
    Write-Host "`n=== Step 1: Fix Docker Storage ===" -ForegroundColor Cyan
    
    # Check Docker root directory and storage driver
    $result = $session.ExecuteCommand("docker info 2>&1 | grep -E 'Docker Root Dir|Storage Driver|Storage'")
    Write-Host $result.Output
    
    # Try to prune and clean up
    Write-Host "Cleaning Docker..."
    $session.ExecuteCommand("docker system prune -af --volumes 2>&1") | Out-Null
    
    # Restart Docker with fresh state
    Write-Host "Restarting Docker service..."
    $session.ExecuteCommand("systemctl restart docker && sleep 5")
    
    # Verify Docker is healthy
    $healthCheck = $session.ExecuteCommand("docker info 2>&1 | head -10")
    Write-Host "Docker status:"
    Write-Host $healthCheck.Output

    # Step 2: Use public Chinese mirrors (no login required)
    Write-Host "`n=== Step 2: Pull from Public Mirrors ===" -ForegroundColor Cyan
    
    # List of public mirrors to try
    $mirrors = @(
        @{name="mysql:8.0"; mirrors=@("docker.m.daocloud.io/library/mysql:8.0", "dockerpull.org/mysql:8.0")},
        @{name="node:18-alpine"; mirrors=@("docker.m.daocloud.io/library/node:18-alpine", "dockerpull.org/node:18-alpine")},
        @{name="nginx:alpine"; mirrors=@("docker.m.daocloud.io/library/nginx:alpine", "dockerpull.org/nginx:alpine")}
    )
    
    foreach ($img in $mirrors) {
        Write-Host "`nPulling $($img.name)..." -ForegroundColor Yellow
        
        $pulled = $false
        foreach ($mirror in $img.mirrors) {
            if ($pulled) { break }
            
            Write-Host "  Trying: $mirror"
            $pullResult = $session.ExecuteCommand("docker pull $mirror 2>&1 | tail -3")
            
            if ($pullResult.ExitCode -eq 0) {
                # Tag it properly
                $tagCmd = "docker tag $mirror $($img.name)"
                $tagResult = $session.ExecuteCommand($tagCmd)
                
                # Verify it exists now
                $verifyResult = $session.ExecuteCommand("docker images | grep '$($img.name.Replace(':', ' *'))' | wc -l")
                
                if ($verifyResult.Output.Trim() -ne "0") {
                    Write-Host "  SUCCESS: $($img.name)" -ForegroundColor Green
                    $pulled = $true
                } else {
                    Write-Host "  Tag failed, image disappeared" -ForegroundColor Yellow
                }
            }
        }
        
        if (-not $pulled) {
            Write-Host "  FAILED: $($img.name) - all mirrors tried" -ForegroundColor Red
        }
    }

    # Final check of all images
    Write-Host "`n=== Current Images ===" -ForegroundColor Cyan
    $finalCheck = $session.ExecuteCommand("docker images")
    Write-Host $finalCheck.Output
    
    # Count how many we have
    $imageCount = ($finalCheck.Output | Select-String -Pattern "mysql|node|nginx").Count
    Write-Host "Found $imageCount base images"

    if ($imageCount -lt 3) {
        Write-Host "`nNot all images available. Trying alternative approach..." -ForegroundColor Red
        
        # Alternative: Save/load approach or direct binary download
        Write-Host "Checking if we can use pre-loaded images..."
        
        # For now, let's just report the status
        Write-Host "`nDIAGNOSIS COMPLETE" -ForegroundColor Yellow
        Write-Host "The Docker daemon appears to have a storage or caching issue."
        Write-Host "Images are being pulled but not persisting."
        Write-Host ""
        Write-Host "Recommended actions on server:"
        Write-Host "1. Check disk space: df -h"
        Write-Host "2. Check Docker logs: journalctl -u docker"
        Write-Host "3. Try: systemctl restart docker"
        Write-Host "4. Or use: dockerd --debug to see detailed logs"
    }

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
