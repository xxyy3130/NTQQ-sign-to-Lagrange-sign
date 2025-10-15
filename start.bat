@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ========================================
echo   SignerServer 启动脚本
echo ========================================
echo.

REM 查找 QQ 安装路径（支持多个可能的位置）
set "QQPath="
set "QQDir="

REM 方法1: 从注册表查询（旧版QQ）
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\QQ" /v "UninstallString" 2^>nul') do (
    for %%b in ("%%b") do (
        set "QQDir=%%~dpb"
    )
)

if defined QQDir (
    set "QQPath=!QQDir!QQ.exe"
    echo [找到] 旧版 QQ: !QQPath!
    goto :found_qq
)

REM 方法2: 查找常见安装位置
set "SearchPaths=C:\Users\%USERNAME%\Documents\qqnt C:\Program Files\Tencent\QQNT C:\Program Files (x86)\Tencent\QQ"

for %%p in (%SearchPaths%) do (
    if exist "%%p\QQ.exe" (
        set "QQPath=%%p\QQ.exe"
        set "QQDir=%%p\"
        echo [找到] QQNT: !QQPath!
        goto :found_qq
    )
)

REM 未找到 QQ
echo [错误] 未找到 QQ 安装，请检查以下位置：
echo   - C:\Users\%USERNAME%\Documents\qqnt
echo   - C:\Program Files\Tencent\QQNT
echo   - C:\Program Files (x86)\Tencent\QQ
echo.
echo 或手动指定 QQ 路径：
set /p QQPath="请输入 QQ.exe 完整路径（留空退出）: "
if "!QQPath!"=="" exit /b 1
if not exist "!QQPath!" (
    echo [错误] 文件不存在: !QQPath!
    pause
    exit /b 1
)
for %%a in ("!QQPath!") do set "QQDir=%%~dpa"

:found_qq
echo.

REM 检查 SignerServer.dll
set "DllSource=%~dp0SignerServer.dll"
set "DllTarget=!QQDir!dbghelp.dll"

if not exist "!DllSource!" (
    echo [错误] 未找到 SignerServer.dll
    echo 请先编译项目：
    echo   cmake --preset=msvc-release
    echo   cmake --build --preset=msvc-release
    echo.
    echo 编译后的 DLL 应该在：
    echo   build\msvc-release\SignerServer.dll
    pause
    exit /b 1
)

REM 检查是否需要复制 DLL
if exist "!DllTarget!" (
    echo [检测] dbghelp.dll 已存在
    choice /C YN /M "是否替换现有的 dbghelp.dll"
    if errorlevel 2 goto :launch
)

:copy_dll
echo [复制] 将 SignerServer.dll 复制为 dbghelp.dll...
copy /y "!DllSource!" "!DllTarget!" >nul 2>&1

if errorlevel 1 (
    echo [错误] 复制失败（可能需要管理员权限）
    choice /C YN /M "是否以管理员身份重新运行"
    if errorlevel 2 exit /b 1
    
    echo [提权] 正在以管理员身份重新启动...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

echo [成功] DLL 已复制到: !DllTarget!
echo.

:launch
REM 检查 load.js
set "LoadScript=%~dp0load.js"
if not exist "!LoadScript!" (
    echo [警告] load.js 不存在，使用标准模式启动
    set "LoadScript="
)

REM 设置环境变量
set "ELECTRON_RUN_AS_NODE=1"

echo ========================================
echo [启动] 正在启动 QQ...
echo ========================================
echo QQ 路径: !QQPath!
echo 工作目录: !QQDir!
if defined LoadScript echo 加载脚本: !LoadScript!
echo.

REM 启动 QQ
cd /d "!QQDir!"
if defined LoadScript (
    "!QQPath!" "!LoadScript!" %*
) else (
    "!QQPath!" %*
)

if errorlevel 1 (
    echo.
    echo [错误] QQ 启动失败
    pause
    exit /b 1
)

echo.
echo [提示] QQ 已启动，请检查：
echo   1. 控制台是否显示 "Sign initialized successfully!"
echo   2. 访问 http://localhost:8080/ping 验证服务
echo.
pause