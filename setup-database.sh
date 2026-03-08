#!/bin/bash

echo "========================================"
echo " Database Setup Script"
echo "========================================"
echo

cd server

echo "[1/3] Installing dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "Failed to install dependencies"
    exit 1
fi

echo
echo "[2/3] Running database migrations..."
npm run migrate
if [ $? -ne 0 ]; then
    echo "Failed to run migrations"
    exit 1
fi

echo
echo "[3/3] Seeding initial data..."
npm run seed
if [ $? -ne 0 ]; then
    echo "Failed to seed data"
    exit 1
fi

echo
echo "========================================"
echo " Database setup completed!"
echo "========================================"
echo
echo "Next steps:"
echo "1. Configure your MySQL connection in server/.env"
echo "2. Run 'npm run dev' in server folder to start the API server"
echo "3. Run 'npm run dev' in root folder to start the frontend"
echo
