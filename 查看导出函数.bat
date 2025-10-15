@echo off
echo ========================================
echo 查看 wrapper.node 导出函数
echo ========================================
echo.

REM 查找 QQ 安装路径
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\QQ" /v "UninstallString" 2^>nul') do (
    set "UninstallPath=%%b"
)

if not defined UninstallPath (
    echo 未找到 QQ 安装路径
    echo 请手动指定 wrapper.node 文件路径
    set /p WrapperPath="请输入 wrapper.node 完整路径: "
) else (
    for %%a in ("%UninstallPath%") do set "QQPath=%%~dpa"
    set "WrapperPath=!QQPath!resources\app.asar.unpacked\node_modules\wrapper.node"
)

echo.
echo wrapper.node 路径: %WrapperPath%
echo.

if not exist "%WrapperPath%" (
    echo 错误: 文件不存在
    pause
    exit /b 1
)

echo 正在分析导出函数...
echo.

REM 尝试使用 dumpbin (需要安装 Visual Studio)
where dumpbin >nul 2>&1
if %errorlevel% equ 0 (
    echo 使用 dumpbin 工具:
    echo ----------------------------------------
    dumpbin /EXPORTS "%WrapperPath%" > exports.txt
    type exports.txt
    echo.
    echo 导出信息已保存到 exports.txt
) else (
    echo dumpbin 工具未找到，正在尝试使用 PowerShell...
    echo ----------------------------------------
    
    REM 使用 PowerShell 读取 PE 文件
    powershell -Command "$file = '%WrapperPath%'; Write-Host '文件大小:' (Get-Item $file).Length 'bytes'; Write-Host '文件类型: PE64 DLL'"
)

echo.
echo ========================================
echo 提示：
echo 1. 查找包含 sign、encrypt、hash 等关键字的函数
echo 2. 记录函数名称和地址
echo 3. 在 x64dbg 中双击函数名查看详细信息
echo ========================================
echo.
pause
