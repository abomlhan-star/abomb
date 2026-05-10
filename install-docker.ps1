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

    Write-Host "`n=== Step 1: Check if Docker is installed ==="
    $result = $session.ExecuteCommand("which docker")
    Write-Host $result.Output

    if ($result.Output -match "docker") {
        Write-Host "Docker is already installed" -ForegroundColor Green
    } else {
        Write-Host "`n=== Step 2: Install Docker ===" -ForegroundColor Cyan

        Write-Host "Updating system packages..."
        $result = $session.ExecuteCommand("yum update -y")
        Write-Host "Update completed"

        Write-Host "Installing required tools..."
        $result = $session.ExecuteCommand("yum install -y yum-utils device-mapper-persistent-data lvm2")
        Write-Host "Tools installed"

        Write-Host "Adding Docker repository..."
        $result = $session.ExecuteCommand("yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo")
        Write-Host "Repository added"

        Write-Host "Installing Docker CE..."
        $result = $session.ExecuteCommand("yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin")
        Write-Host "Docker installed"

        Write-Host "Starting Docker service..."
        $result = $session.ExecuteCommand("systemctl start docker")
        Write-Host "Docker started"

        Write-Host "Enabling Docker at boot..."
        $result = $session.ExecuteCommand("systemctl enable docker")
        Write-Host "Enabled"
    }

    Write-Host "`n=== Step 3: Install Docker Compose ===" -ForegroundColor Cyan
    $result = $session.ExecuteCommand("which docker-compose")

    if ($result.Output -match "docker-compose") {
        Write-Host "Docker Compose is already installed" -ForegroundColor Green
    } else {
        Write-Host "Installing Docker Compose..."

        Write-Host "Downloading Docker Compose..."
        $result = $session.ExecuteCommand("curl -L https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose")

        Write-Host "Setting executable permission..."
        $result = $session.ExecuteCommand("chmod +x /usr/local/bin/docker-compose")

        Write-Host "Creating symlink..."
        $result = $session.ExecuteCommand("ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose")
    }

    Write-Host "`n=== Step 4: Verify Installation ===" -ForegroundColor Cyan
    Write-Host "Docker version:"
    $result = $session.ExecuteCommand("docker --version")
    Write-Host $result.Output

    Write-Host "`nDocker Compose version:"
    $result = $session.ExecuteCommand("docker-compose --version")
    Write-Host $result.Output

    Write-Host "`nDocker service status:"
    $result = $session.ExecuteCommand("systemctl status docker | head -10")
    Write-Host $result.Output

    Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
