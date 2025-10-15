@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo     地址计算器（十六进制）
echo ========================================
echo.

:menu
echo 请选择计算类型：
echo.
echo 1. 计算内存地址 （已知：模块基址 + 偏移地址）
echo 2. 计算偏移地址 （已知：内存地址 - 模块基址）
echo 3. 计算模块基址 （已知：内存地址 - 偏移地址）
echo 4. 退出
echo.
set /p choice="请输入选项 (1-4): "

if "%choice%"=="1" goto calc_memory
if "%choice%"=="2" goto calc_offset
if "%choice%"=="3" goto calc_base
if "%choice%"=="4" exit /b
goto menu

:calc_memory
echo.
echo ========================================
echo 计算内存地址
echo ========================================
echo.
echo 公式：内存地址 = 模块基址 + 偏移地址
echo.
set /p base="请输入模块基址（十六进制，如 180000000）: "
set /p offset="请输入偏移地址（十六进制，如 A996E0）: "
echo.
echo 请使用 Windows 计算器（程序员模式）计算：
echo.
echo   %base%
echo + %offset%
echo = ???
echo.
echo 或在 x64dbg 中按 Ctrl+G 输入: wrapper+%offset%
echo.
pause
goto menu

:calc_offset
echo.
echo ========================================
echo 计算偏移地址
echo ========================================
echo.
echo 公式：偏移地址 = 内存地址 - 模块基址
echo.
set /p memory="请输入内存地址（十六进制，如 180A996E0）: "
set /p base="请输入模块基址（十六进制，如 180000000）: "
echo.
echo 请使用 Windows 计算器（程序员模式）计算：
echo.
echo   %memory%
echo - %base%
echo = ???
echo.
echo 计算结果就是偏移地址！
echo.
pause
goto menu

:calc_base
echo.
echo ========================================
echo 计算模块基址
echo ========================================
echo.
echo 公式：模块基址 = 内存地址 - 偏移地址
echo.
set /p memory="请输入内存地址（十六进制，如 180A996E0）: "
set /p offset="请输入偏移地址（十六进制，如 A996E0）: "
echo.
echo 请使用 Windows 计算器（程序员模式）计算：
echo.
echo   %memory%
echo - %offset%
echo = ???
echo.
echo 计算结果就是模块基址！
echo.
pause
goto menu
