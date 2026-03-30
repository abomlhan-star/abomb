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
    $session.Open($sessionOptions)
    Write-Host "Connected!"

    Write "=== Test MySQL with no password ==="
    $result = $session.ExecuteCommand("mysql -uroot -e 'SELECT 1;' 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Test MySQL with Richinfo@123 ==="
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -e 'SELECT 1;' 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== MySQL users ==="
    $result = $session.ExecuteCommand("mysql -uroot -e 'SELECT user,host,plugin FROM mysql.user;' 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write "=== Check MySQL auth plugin ==="
    $result = $session.ExecuteCommand("mysql -uroot -e ""SELECT user,host,plugin,authentication_string FROM mysql.user WHERE user='root';"" 2>&1")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
