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

    # Quick status check
    Write-Host "`n=== Docker Status ===" -ForegroundColor Cyan
    
    $images = $session.ExecuteCommand("docker images")
    Write-Host "Images:"
    Write-Host $images.Output
    
    $ps = $session.ExecuteCommand("docker ps -a")
    Write-Host "`nContainers:"
    Write-Host $ps.Output

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $session.Dispose()
}
