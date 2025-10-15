@echo off
setlocal enabledelayedexpansion
echo ========================================
echo QQ 9.9.20-37051 偏移值自动测试
echo ========================================
echo.

set "offsets=0xA9CE90 0xA996E0 0xA84980 0xAB5510 0xAA1A20"
set count=0

for %%o in (%offsets%) do (
    set /a count+=1
    echo.
    echo [测试 !count!/5] 偏移值: %%o
    echo ----------------------------------------
    
    REM 创建配置文件
    (
        echo {
        echo   "ip": "0.0.0.0",
        echo   "port": 8080,
        echo   "version": "9.9.20-37051",
        echo   "offset": "%%o"
        echo }
    ) > sign.json
    
    echo 配置文件已更新: %%o
    echo.
    echo 请执行以下操作：
    echo 1. 关闭当前的 QQ
    echo 2. 运行 start.bat
    echo 3. 观察控制台输出
    echo 4. 访问 http://localhost:8080/ping
    echo.
    echo 成功标志:
    echo   - 控制台显示 "Sign initialized successfully!"
    echo   - 浏览器返回 {"code":0}
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
        pause
        exit /b 0
    )
)

echo.
echo ========================================
echo 所有偏移值测试完毕
echo 如果都失败，可能需要手动查找偏移值
echo ========================================
pause
