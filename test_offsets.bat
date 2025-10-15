@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ========================================
echo   偏移值自动测试脚本
echo ========================================
echo.
echo 此脚本将自动测试多个可能的偏移值
echo.

set "offsets=0xA9CE90 0xA996E0 0xA84980 0xAB5510 0xAA1A20"
set count=0

for %%o in (%offsets%) do (
    set /a count+=1
    echo.
    echo ========================================
    echo [测试 !count!/5] 偏移值: %%o
    echo ========================================
    
    REM 创建配置文件
    (
        echo {
        echo   "ip": "0.0.0.0",
        echo   "port": 8080,
        echo   "version": "9.9.21-38711",
        echo   "offset": "%%o"
        echo }
    ) > sign.json
    
    echo.
    echo [配置] 已更新 sign.json，偏移值: %%o
    echo.
    echo [操作步骤]
    echo   1. 关闭当前的 QQ
    echo   2. 运行 start.bat 或 快速启动.bat
    echo   3. 观察控制台输出
    echo   4. 访问 http://localhost:8080/ping
    echo.
    echo [成功标志]
    echo   ✓ 控制台显示 "Sign initialized successfully!"
    echo   ✓ 浏览器返回 {"code":0}
    echo.
    
    choice /C YN /M "此偏移值测试成功了吗"
    if errorlevel 2 (
        echo [失败] 偏移值 %%o 不可用
    ) else (
        echo.
        echo ========================================
        echo [成功] 找到正确的偏移值: %%o
        echo ========================================
        echo.
        echo 配置已保存到 sign.json
        echo 你可以继续使用此配置
        pause
        exit /b 0
    )
)

echo.
echo ========================================
echo [完成] 所有偏移值测试完毕
echo ========================================
echo.
echo 如果都失败，可能需要手动查找偏移值
echo 请参考: x64dbg查找地址实战指南.md
echo.
pause
