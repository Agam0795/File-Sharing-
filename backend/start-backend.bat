@echo off
echo ========================================
echo DecentraShare Backend Server
echo ========================================
echo.

cd /d "%~dp0"

if not exist "venv\Scripts\python.exe" (
    echo ERROR: Virtual environment not found!
    echo Please run: python -m venv venv
    echo Then: .\venv\Scripts\pip.exe install -r requirements.txt
    pause
    exit /b 1
)

echo Starting backend server...
echo Backend will be available at: http://localhost:8000
echo.
echo Press Ctrl+C to stop the server
echo.

venv\Scripts\python.exe main.py

pause
