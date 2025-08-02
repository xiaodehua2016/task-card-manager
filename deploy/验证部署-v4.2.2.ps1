# 小久任务管理系统 v4.2.2 部署验证脚本
# 作者: CodeBuddy
# 版本: v4.2.2
# 描述: 此脚本用于验证小久任务管理系统的部署是否成功

# 配置参数
$version = "v4.2.2"
$serverIP = "115.159.5.111"
$serverPath = "/www/wwwroot/task-manager/"

# 显示标题
function Show-Title {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "   小久任务管理系统 $version 部署验证"
    Write-Host "========================================"
    Write-Host ""
}

# 验证服务器连接
function Test-ServerConnection {
    Write-Host "🔍 验证服务器连接..." -ForegroundColor Cyan
    
    try {
        $result = Test-Connection -ComputerName $serverIP -Count 1 -Quiet
        if ($result) {
            Write-Host "✅ 服务器连接正常" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ 无法连接到服务器" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ 服务器连接测试失败: $_" -ForegroundColor Red
        return $false
    }
}

# 验证网站可访问性
function Test-WebsiteAccess {
    Write-Host "🔍 验证网站可访问性..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "http://$serverIP/" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ 网站可以访问" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ 网站返回错误状态码: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ 网站访问测试失败: $_" -ForegroundColor Red
        return $false
    }
}

# 验证同步测试页面
function Test-SyncTestPage {
    Write-Host "🔍 验证同步测试页面..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "http://$serverIP/sync-test.html" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ 同步测试页面可以访问" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ 同步测试页面返回错误状态码: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ 同步测试页面访问失败: $_" -ForegroundColor Red
        return $false
    }
}

# 验证API可用性
function Test-ApiAvailability {
    Write-Host "🔍 验证API可用性..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "http://$serverIP/api/data-sync.php" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            $content = $response.Content
            if ($content -match '"success"') {
                Write-Host "✅ API可以访问并返回正确格式" -ForegroundColor Green
                return $true
            } else {
                Write-Host "⚠️ API可以访问但返回格式可能不正确" -ForegroundColor Yellow
                return $false
            }
        } else {
            Write-Host "❌ API返回错误状态码: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ API访问测试失败: $_" -ForegroundColor Red
        return $false
    }
}

# 验证版本号
function Test-VersionNumber {
    Write-Host "🔍 验证版本号..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "http://$serverIP/" -UseBasicParsing
        if ($response.Content -match "$version") {
            Write-Host "✅ 版本号正确: $version" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ 未找到正确的版本号" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ 版本号验证失败: $_" -ForegroundColor Red
        return $false
    }
}

# 显示验证结果
function Show-ValidationResults {
    param (
        [int]$passedTests,
        [int]$totalTests
    )
    
    Write-Host ""
    Write-Host "📊 验证结果摘要" -ForegroundColor Cyan
    Write-Host "------------------------"
    Write-Host "通过测试: $passedTests/$totalTests" -ForegroundColor Yellow
    
    $passRate = [math]::Round(($passedTests / $totalTests) * 100)
    
    if ($passRate -eq 100) {
        Write-Host "✅ 所有测试通过！部署成功！" -ForegroundColor Green
    } elseif ($passRate -ge 80) {
        Write-Host "⚠️ 大部分测试通过，但有一些问题需要注意。" -ForegroundColor Yellow
    } else {
        Write-Host "❌ 测试通过率较低，部署可能存在严重问题。" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "🔍 下一步建议:" -ForegroundColor Cyan
    
    if ($passRate -eq 100) {
        Write-Host "1. 进行手动测试，确认跨浏览器同步功能" -ForegroundColor White
        Write-Host "2. 访问同步测试页面 (http://$serverIP/sync-test.html) 运行诊断" -ForegroundColor White
        Write-Host "3. 在不同设备上测试系统功能" -ForegroundColor White
    } else {
        Write-Host "1. 检查失败的测试项" -ForegroundColor White
        Write-Host "2. 重新部署或修复问题" -ForegroundColor White
        Write-Host "3. 再次运行验证脚本" -ForegroundColor White
    }
}

# 主函数
function Main {
    Show-Title
    
    $passedTests = 0
    $totalTests = 4
    
    # 测试服务器连接
    if (Test-ServerConnection) {
        $passedTests++
    }
    
    # 测试网站可访问性
    if (Test-WebsiteAccess) {
        $passedTests++
    }
    
    # 测试同步测试页面
    if (Test-SyncTestPage) {
        $passedTests++
    }
    
    # 测试API可用性
    if (Test-ApiAvailability) {
        $passedTests++
    }
    
    # 显示验证结果
    Show-ValidationResults -passedTests $passedTests -totalTests $totalTests
}

# 执行主函数
Main