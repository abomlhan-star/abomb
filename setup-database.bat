@echo off
echo ========================================
echo  Database Setup Script
echo ========================================
echo.

cd server

echo [1/3] Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo Failed to install dependencies
    exit /b 1
)

echo.
echo [2/3] Running database migrations...
call npm run migrate
if %errorlevel% neq 0 (
    echo Failed to run migrations
    exit /b 1
)

echo.
echo [3/3] Seeding initial data...
call npm run seed
if %errorlevel% neq 0 (
    echo Failed to seed data
    exit /b 1
)

echo.
echo ========================================
echo  Database setup completed!
echo ========================================
echo.
echo Next steps:
echo 1. Configure your MySQL connection in server/.env
echo 2. Run 'npm run dev' in server folder to start the API server
echo 3. Run 'npm run dev' in root folder to start the frontend
echo.
