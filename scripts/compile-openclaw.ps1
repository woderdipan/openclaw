#!/usr/bin/env pwsh
# OpenClaw 源码编译脚本
# 此脚本用于快速编译和部署 OpenClaw 源码

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "OpenClaw 源码编译脚本" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否在正确目录
if ($PWD.Path -ne "F:\openclaw\workspace\aigit\openclaw") {
    Write-Host "错误：请在 F:\openclaw\workspace\aigit\openclaw 目录下运行此脚本" -ForegroundColor Red
    Write-Host "当前目录：$PWD.Path" -ForegroundColor Yellow
    exit 1
}

Write-Host "开始编译 OpenClaw..." -ForegroundColor Green
Write-Host ""

# 步骤 1: 检查 pnpm 版本
Write-Host "步骤 1/4: 检查 pnpm 版本..." -ForegroundColor Yellow
try {
    $pnpmVersion = pnpm --version
    Write-Host "pnpm 版本：$pnpmVersion ✓" -ForegroundColor Green
} catch {
    Write-Host "错误：pnpm 未安装！" -ForegroundColor Red
    Write-Host "请先运行：corepack enable 和 corepack prepare pnpm@10.23.0 --activate" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# 步骤 2: 安装依赖
Write-Host "步骤 2/4: 安装依赖..." -ForegroundColor Yellow
Write-Host "正在执行：pnpm install" -ForegroundColor Gray

try {
    pnpm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "依赖安装失败！请检查网络连接。" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "依赖安装完成 ✓" -ForegroundColor Green
} catch {
    Write-Host "安装过程中出错：$_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 步骤 3: 编译源码
Write-Host "步骤 3/4: 编译源码..." -ForegroundColor Yellow
Write-Host "正在执行：pnpm build" -ForegroundColor Gray

try {
    pnpm build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "编译失败！请查看错误信息。" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "编译完成 ✓" -ForegroundColor Green
} catch {
    Write-Host "编译过程中出错：$_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 步骤 4: 验证编译结果
Write-Host "步骤 4/4: 验证编译结果..." -ForegroundColor Yellow

# 检查是否生成了 dist 目录
if (Test-Path "dist") {
    Write-Host "dist 目录已生成 ✓" -ForegroundColor Green
    
    # 检查是否有可执行文件
    if (Test-Path "openclaw.mjs") {
        Write-Host "openclaw.mjs 已生成 ✓" -ForegroundColor Green
    }
} else {
    Write-Host "警告：未找到 dist 目录" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "编译完成！" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 显示下一步操作
Write-Host "下一步操作:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 启动网关服务:" -ForegroundColor White
Write-Host "   pnpm gateway:dev" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 生产环境启动:" -ForegroundColor White
Write-Host "   pnpm openclaw" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 查看帮助:" -ForegroundColor White
Write-Host "   pnpm --help" -ForegroundColor Gray
Write-Host ""

Write-Host "按任意键继续..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")