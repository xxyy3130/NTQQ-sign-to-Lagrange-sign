# 偏移值自动测试脚本 (PowerShell 版本)

param(
    [string]$Version = "9.9.21-38711"
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  偏移值自动测试脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "QQ 版本: $Version" -ForegroundColor White
Write-Host ""

# 候选偏移值（按优先级排序）
$offsets = @(
    @{ Value = "0xA9CE90"; Source = "9.9.12-25765"; Priority = 1 },
    @{ Value = "0xA996E0"; Source = "9.9.12-25493"; Priority = 2 },
    @{ Value = "0xA84980"; Source = "9.9.12-25234"; Priority = 3 },
    @{ Value = "0xAB5510"; Source = "9.9.11-24815"; Priority = 4 },
    @{ Value = "0xAA1A20"; Source = "9.9.11-24568"; Priority = 5 }
)

$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$configFile = Join-Path $scriptDir "sign.json"

$testCount = 0
$totalTests = $offsets.Count

foreach ($offset in $offsets) {
    $testCount++
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "[测试 $testCount/$totalTests] 偏移值: $($offset.Value)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "来源版本: $($offset.Source)" -ForegroundColor Gray
    Write-Host "优先级: $($offset.Priority)" -ForegroundColor Gray
    Write-Host ""
    
    # 创建配置文件
    $config = @{
        ip = "0.0.0.0"
        port = 8080
        version = $Version
        offset = $offset.Value
    }
    
    try {
        $config | ConvertTo-Json | Set-Content -Path $configFile -Encoding UTF8
        Write-Host "[配置] 已更新 sign.json" -ForegroundColor Green
        Write-Host "  偏移值: $($offset.Value)" -ForegroundColor White
        Write-Host ""
    } catch {
        Write-Host "[错误] 无法写入配置文件: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }
    
    # 显示操作说明
    Write-Host "[操作步骤]" -ForegroundColor Cyan
    Write-Host "  1. 关闭当前的 QQ（如果正在运行）" -ForegroundColor White
    Write-Host "  2. 运行启动脚本（start.bat 或 start.ps1）" -ForegroundColor White
    Write-Host "  3. 观察控制台输出" -ForegroundColor White
    Write-Host "  4. 访问 http://localhost:8080/ping" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[成功标志]" -ForegroundColor Green
    Write-Host "  ✓ 控制台显示 'Sign initialized successfully!'" -ForegroundColor White
    Write-Host "  ✓ /ping 返回 {`"code`":0}" -ForegroundColor White
    Write-Host ""
    
    # 等待用户测试
    do {
        $response = Read-Host "此偏移值测试成功了吗? (Y=成功 / N=失败 / S=跳过剩余测试)"
        $response = $response.ToUpper()
    } while ($response -notmatch '^[YNS]$')
    
    if ($response -eq "Y") {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "[成功] 找到正确的偏移值!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "偏移值: $($offset.Value)" -ForegroundColor White
        Write-Host "来源: $($offset.Source)" -ForegroundColor White
        Write-Host ""
        Write-Host "配置已保存到: $configFile" -ForegroundColor Cyan
        Write-Host "你可以继续使用此配置" -ForegroundColor Cyan
        Write-Host ""
        Read-Host "按回车键退出"
        exit 0
    } elseif ($response -eq "S") {
        Write-Host "[跳过] 停止测试" -ForegroundColor Yellow
        break
    } else {
        Write-Host "[失败] 偏移值 $($offset.Value) 不可用" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[完成] 所有偏移值测试完毕" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($testCount -eq $totalTests) {
    Write-Host "未找到可用的偏移值，可能需要手动查找" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "建议操作：" -ForegroundColor Cyan
    Write-Host "  1. 参考 'x64dbg查找地址实战指南.md'" -ForegroundColor White
    Write-Host "  2. 使用特征码搜索（参考 '特征码提取实战.md'）" -ForegroundColor White
    Write-Host "  3. 查看 GitHub Issues 寻找社区分享" -ForegroundColor White
    Write-Host ""
}

Read-Host "按回车键退出"
