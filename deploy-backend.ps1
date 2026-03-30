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

    $remoteBackendPath = "/var/www/chengyan-operation/server"

    $session.ExecuteCommand("mkdir -p $remoteBackendPath/dist/database $remoteBackendPath/dist/middleware $remoteBackendPath/dist/routes $remoteBackendPath/dist/types")

    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

$projectRoot = "d:\trea\cheng-yan-operation"
$serverBackendPath = "$projectRoot\server"

    Write-Host "Uploading dist..."
    $session.PutFiles("$serverBackendPath\dist\*", "$remoteBackendPath/dist/", $false, $transferOptions).Check()

    Write-Host "Uploading package.json..."
    $session.PutFiles("$serverBackendPath\package.json", "$remoteBackendPath/", $false, $transferOptions).Check()

    Write-Host "Uploading package-lock.json..."
    $session.PutFiles("$serverBackendPath\package-lock.json", "$remoteBackendPath/", $false, $transferOptions).Check()

    Write-Host "Creating .env file..."
    $envContent = "NODE_ENV=production`nPORT=3000`nDB_HOST=localhost`nDB_PORT=3306`nDB_USER=root`nDB_PASSWORD=Richinfo@123`nDB_NAME=chengyan_operation`nJWT_SECRET=chengyan_operation_jwt_secret_2024`nJWT_EXPIRES_IN=7d`n"
    $envFile = "$projectRoot\server-env.tmp"
    Set-Content -Path $envFile -Value $envContent
    $session.PutFiles($envFile, "$remoteBackendPath/.env", $false, $transferOptions).Check()
    Remove-Item $envFile -Force

    Write-Host "Installing dependencies..."
    $result = $session.ExecuteCommand("cd $remoteBackendPath ; npm install --production")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write-Host "Installing PM2..."
    $result = $session.ExecuteCommand("npm install -g pm2")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    Write-Host "Checking database..."
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -e ""SHOW DATABASES LIKE 'chengyan_operation';""")
    Write-Host $result.Output

    Write-Host "Initializing database..."
    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 -e ""CREATE DATABASE IF NOT EXISTS chengyan_operation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;""")
    Write-Host $result.Output

    $result = $session.ExecuteCommand("mysql -uroot -pRichinfo@123 chengyan_operation < /var/www/chengyan-operation/database/init-database.sql 2>/dev/null || echo 'SQL file not found, skipping'")
    Write-Host $result.Output

    Write-Host "Starting PM2 service..."
    $result = $session.ExecuteCommand("cd $remoteBackendPath ; pm2 delete chengyan-api 2>/dev/null ; pm2 start dist/index.js --name chengyan-api")
    Write-Host $result.Output
    Write-Host $result.ErrorOutput

    $result = $session.ExecuteCommand("pm2 save")
    Write-Host $result.Output

    $result = $session.ExecuteCommand("pm2 startup systemd -u root --hp /root 2>/dev/null || echo 'Startup config skipped'")
    Write-Host $result.Output

    Write-Host "Verifying..."
    $result = $session.ExecuteCommand("pm2 status")
    Write-Host $result.Output

    $result = $session.ExecuteCommand("curl -s http://localhost:3000/api/health")
    Write-Host $result.Output

    Write-Host "Deployment complete!"
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
