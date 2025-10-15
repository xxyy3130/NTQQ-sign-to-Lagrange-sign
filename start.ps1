# SignerServer 启动脚本 (PowerShell 版本)
# 推荐使用此脚本，更稳定可靠

param(
    [string]$QQPath = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SignerServer 启动脚本 (PowerShell)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 查找 QQ 安装路径
function Find-QQPath {
    Write-Host "[查找] 正在搜索 QQ 安装位置..." -ForegroundColor Yellow
    
    # 方法1: 从注册表查询（旧版QQ）
    try {
        $regPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\QQ"
        if (Test-Path $regPath) {
            $uninstallString = (Get-ItemProperty -Path $regPath).UninstallString
            if ($uninstallString) {
                $qqDir = Split-Path $uninstallString -Parent
                $qqExe = Join-Path $qqDir "QQ.exe"
                if (Test-Path $qqExe) {
                    Write-Host "[找到] 旧版 QQ: $qqExe" -ForegroundColor Green
                    return $qqExe
                }
            }
        }
    } catch {
        # 忽略注册表查询错误
    }
    
    # 方法2: 搜索常见安装位置
    $searchPaths = @(
        "$env:USERPROFILE\Documents\qqnt",
        "C:\Users\$env:USERNAME\Documents\qqnt",
        "C:\Program Files\Tencent\QQNT",
        "C:\Program Files (x86)\Tencent\QQ",
        "D:\Program Files\Tencent\QQNT",
        "D:\Tencent\QQNT"
    )
    
    foreach ($path in $searchPaths) {
        # 查找所有可能的版本目录
        if (Test-Path $path) {
            # 直接在根目录查找
            $qqExe = Join-Path $path "QQ.exe"
            if (Test-Path $qqExe) {
                Write-Host "[找到] QQNT: $qqExe" -ForegroundColor Green
                return $qqExe
            }
            
            # 在版本子目录中查找
            $versionDirs = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | 
                           Where-Object { $_.Name -match '^\d+' }
            
            foreach ($vDir in $versionDirs) {
                $qqExe = Join-Path $vDir.FullName "QQ.exe"
                if (Test-Path $qqExe) {
                    Write-Host "[找到] QQNT: $qqExe" -ForegroundColor Green
                    return $qqExe
                }
            }
        }
    }
    
    return $null
}

# 查找或使用指定的 QQ 路径
if ($QQPath) {
    if (-not (Test-Path $QQPath)) {
        Write-Host "[错误] 指定的 QQ 路径不存在: $QQPath" -ForegroundColor Red
        exit 1
    }
    Write-Host "[使用] 指定的 QQ: $QQPath" -ForegroundColor Green
} else {
    $QQPath = Find-QQPath
    
    if (-not $QQPath) {
        Write-Host "[错误] 未找到 QQ 安装" -ForegroundColor Red
        Write-Host ""
        Write-Host "请检查以下位置或手动指定：" -ForegroundColor Yellow
        Write-Host "  - $env:USERPROFILE\Documents\qqnt"
        Write-Host "  - C:\Program Files\Tencent\QQNT"
        Write-Host "  - C:\Program Files (x86)\Tencent\QQ"
        Write-Host ""
        Write-Host "使用方法: .\start.ps1 -QQPath 'C:\Path\To\QQ.exe'" -ForegroundColor Cyan
        Read-Host "按回车键退出"
        exit 1
    }
}

$QQDir = Split-Path $QQPath -Parent

Write-Host ""

# 查找 SignerServer.dll
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$dllSource = Join-Path $scriptDir "SignerServer.dll"

# 尝试在 build 目录中查找
if (-not (Test-Path $dllSource)) {
    $buildDll = Join-Path $scriptDir "build\msvc-release\SignerServer.dll"
    if (Test-Path $buildDll) {
        $dllSource = $buildDll
    }
}

if (-not (Test-Path $dllSource)) {
    Write-Host "[错误] 未找到 SignerServer.dll" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先编译项目：" -ForegroundColor Yellow
    Write-Host "  cmake --preset=msvc-release"
    Write-Host "  cmake --build --preset=msvc-release"
    Write-Host ""
    Write-Host "编译后的 DLL 应该在：" -ForegroundColor Yellow
    Write-Host "  build\msvc-release\SignerServer.dll"
    Read-Host "按回车键退出"
    exit 1
}

$dllTarget = Join-Path $QQDir "dbghelp.dll"

# 检查是否需要复制 DLL
$needCopy = $true
if ((Test-Path $dllTarget) -and -not $Force) {
    Write-Host "[检测] dbghelp.dll 已存在" -ForegroundColor Yellow
    $choice = Read-Host "是否替换现有的 dbghelp.dll? (Y/N)"
    if ($choice -notmatch '^[Yy]') {
        $needCopy = $false
        Write-Host "[跳过] 保留现有 DLL" -ForegroundColor Cyan
    }
}

if ($needCopy) {
    try {
        Write-Host "[复制] 将 SignerServer.dll 复制为 dbghelp.dll..." -ForegroundColor Yellow
        Copy-Item -Path $dllSource -Destination $dllTarget -Force
        Write-Host "[成功] DLL 已复制到: $dllTarget" -ForegroundColor Green
    } catch {
        Write-Host "[错误] 复制失败（可能需要管理员权限）" -ForegroundColor Red
        Write-Host "错误信息: $($_.Exception.Message)" -ForegroundColor Red
        
        # 尝试以管理员身份重新运行
        $choice = Read-Host "是否以管理员身份重新运行? (Y/N)"
        if ($choice -match '^[Yy]') {
            Write-Host "[提权] 正在以管理员身份重新启动..." -ForegroundColor Yellow
            $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
            if ($QQPath) { $arguments += " -QQPath `"$QQPath`"" }
            if ($Force) { $arguments += " -Force" }
            
            Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs
            exit 0
        }
        exit 1
    }
}

Write-Host ""

# 检查 load.js
$loadScript = Join-Path $scriptDir "load.js"
$useLoadScript = Test-Path $loadScript

if (-not $useLoadScript) {
    Write-Host "[警告] load.js 不存在，使用标准模式启动" -ForegroundColor Yellow
}

# 设置环境变量
$env:ELECTRON_RUN_AS_NODE = "1"

# 启动 QQ
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[启动] 正在启动 QQ..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QQ 路径: $QQPath" -ForegroundColor White
Write-Host "工作目录: $QQDir" -ForegroundColor White
if ($useLoadScript) {
    Write-Host "加载脚本: $loadScript" -ForegroundColor White
}
Write-Host ""

try {
    Set-Location $QQDir
    
    if ($useLoadScript) {
        & $QQPath $loadScript $args
    } else {
        & $QQPath $args
    }
    
    if ($LASTEXITCODE -ne 0) {
        throw "QQ 启动失败，退出代码: $LASTEXITCODE"
    }
    
    Write-Host ""
    Write-Host "[提示] QQ 已启动，请检查：" -ForegroundColor Green
    Write-Host "  1. 控制台是否显示 'Sign initialized successfully!'" -ForegroundColor White
    Write-Host "  2. 访问 http://localhost:8080/ping 验证服务" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "[错误] QQ 启动失败" -ForegroundColor Red
    Write-Host "错误信息: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

Read-Host "按回车键退出"
