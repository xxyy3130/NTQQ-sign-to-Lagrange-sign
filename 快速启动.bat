@echo off
chcp 65001 >nul
echo ========================================
echo   SignerServer 快速启动
echo ========================================
echo.
echo 正在启动 PowerShell 脚本...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start.ps1"
if errorlevel 1 (
    echo.
    echo [失败] PowerShell 脚本执行失败
    echo 请尝试直接运行: start.bat
    pause
)
