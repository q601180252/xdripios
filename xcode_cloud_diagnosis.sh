#!/bin/bash

# Xcode Cloud 诊断脚本
echo "🔍 Xcode Cloud 诊断报告"
echo "========================"

# 1. 检查项目基本信息
echo "📱 项目信息:"
echo "   工作空间: $(ls -la xdrip.xcworkspace 2>/dev/null && echo '✅ 存在' || echo '❌ 不存在')"
echo "   项目文件: $(ls -la xdrip.xcodeproj 2>/dev/null && echo '✅ 存在' || echo '❌ 不存在')"

# 2. 检查构建配置
echo ""
echo "🔧 构建配置:"
BUILD_INFO=$(xcodebuild -workspace xdrip.xcworkspace -scheme xdrip -showBuildSettings 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "   ✅ 工作空间可以正常加载"
    BUNDLE_ID=$(echo "$BUILD_INFO" | grep "PRODUCT_BUNDLE_IDENTIFIER" | head -1 | cut -d'=' -f2 | xargs)
    TEAM_ID=$(echo "$BUILD_INFO" | grep "DEVELOPMENT_TEAM" | head -1 | cut -d'=' -f2 | xargs)
    echo "   📦 Bundle ID: $BUNDLE_ID"
    echo "   👥 Team ID: $TEAM_ID"
else
    echo "   ❌ 工作空间加载失败"
fi

# 3. 检查方案
echo ""
echo "🎯 可用方案:"
xcodebuild -workspace xdrip.xcworkspace -list 2>/dev/null | grep -A 20 "Schemes:" | tail -n +2

# 4. 检查依赖项
echo ""
echo "📦 包依赖项:"
xcodebuild -workspace xdrip.xcworkspace -resolvePackageDependencies 2>/dev/null > /dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ 包依赖项解析成功"
else
    echo "   ❌ 包依赖项解析失败"
fi

# 5. 检查构建能力
echo ""
echo "🏗️  构建测试:"
xcodebuild -workspace xdrip.xcworkspace -scheme xdrip -configuration Debug -destination generic/platform=iOS CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO build > /tmp/build_test.log 2>&1
if [ $? -eq 0 ]; then
    echo "   ✅ 无签名构建成功"
else
    echo "   ❌ 无签名构建失败"
    echo "   错误详情:"
    tail -5 /tmp/build_test.log
fi

# 6. 检查Git状态
echo ""
echo "📊 Git状态:"
if [ -d .git ]; then
    echo "   ✅ Git仓库存在"
    echo "   当前分支: $(git branch --show-current 2>/dev/null || echo '无法获取')"
    echo "   远程仓库: $(git remote get-url origin 2>/dev/null || echo '未配置')"
else
    echo "   ❌ 不是Git仓库"
fi

# 7. 诊断建议
echo ""
echo "💡 Xcode Cloud 故障排除建议:"
echo "=============================="
echo "1. 确保在App Store Connect中创建了应用"
echo "2. 确保Bundle ID '$BUNDLE_ID' 已在App Store Connect中注册"
echo "3. 确保开发者账号 'EDUARDO PEIXOTO VIEIRA' 有Xcode Cloud访问权限"
echo "4. 确保项目已推送到远程Git仓库"
echo "5. 尝试在Xcode中重新登录开发者账号"
echo "6. 检查网络连接和防火墙设置"

echo ""
echo "🔧 如果问题仍然存在，请尝试："
echo "1. 在App Store Connect中手动创建Xcode Cloud工作流"
echo "2. 删除现有的Xcode Cloud配置并重新设置"
echo "3. 检查Xcode偏好设置中的Accounts配置"