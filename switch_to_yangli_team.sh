#!/bin/bash

# 切换项目到 Yang Li 的 Team (HHZN32E89C)
# 这会修改所有 Bundle ID 前缀和 Team ID

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message $GREEN "🔄 切换项目到 Yang Li Team (HHZN32E89C)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

OLD_TEAM="7RV2Y67HF6"
NEW_TEAM="HHZN32E89C"

print_message $YELLOW "这将执行以下操作："
echo "  1. 修改 DEVELOPMENT_TEAM: $OLD_TEAM → $NEW_TEAM"
echo "  2. 修改所有 Bundle ID 前缀: com.$OLD_TEAM → com.$NEW_TEAM"
echo "  3. 修改 MAIN_APP_BUNDLE_IDENTIFIER 配置"
echo ""

read -p "确认执行？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_message $RED "❌ 操作已取消"
    exit 1
fi

print_message $BLUE "📝 备份原文件..."
cp xdrip.xcodeproj/project.pbxproj xdrip.xcodeproj/project.pbxproj.backup.$(date +%Y%m%d_%H%M%S)
cp xDrip/xDrip.xcconfig xDrip/xDrip.xcconfig.backup.$(date +%Y%m%d_%H%M%S)

print_message $BLUE "1️⃣  修改 DEVELOPMENT_TEAM..."
sed -i '' "s/DEVELOPMENT_TEAM = $OLD_TEAM;/DEVELOPMENT_TEAM = $NEW_TEAM;/g" xdrip.xcodeproj/project.pbxproj
print_message $GREEN "   ✅ DEVELOPMENT_TEAM 已更新"

print_message $BLUE "2️⃣  修改 xDrip.xcconfig 中的 MAIN_APP_BUNDLE_IDENTIFIER..."
sed -i '' "s/MAIN_APP_BUNDLE_IDENTIFIER = com.$OLD_TEAM.xdripswiftt1li23/MAIN_APP_BUNDLE_IDENTIFIER = com.$NEW_TEAM.xdripswiftt1li23/g" xDrip/xDrip.xcconfig
print_message $GREEN "   ✅ Bundle ID 前缀已更新"

print_message $BLUE "3️⃣  验证修改..."
echo ""
echo "DEVELOPMENT_TEAM 统计："
echo "  旧 Team ($OLD_TEAM): $(grep -c "DEVELOPMENT_TEAM = $OLD_TEAM" xdrip.xcodeproj/project.pbxproj 2>/dev/null || echo 0) 处"
echo "  新 Team ($NEW_TEAM): $(grep -c "DEVELOPMENT_TEAM = $NEW_TEAM" xdrip.xcodeproj/project.pbxproj 2>/dev/null || echo 0) 处"
echo ""
echo "Bundle ID 前缀："
grep "MAIN_APP_BUNDLE_IDENTIFIER" xDrip/xDrip.xcconfig || echo "  未找到配置"
echo ""

print_message $GREEN "✅ 切换完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $YELLOW "📋 下一步操作："
echo ""
print_message $YELLOW "1. 在 Xcode 中："
print_message $YELLOW "   • 如果提示文件已修改 → 选择 'Revert'"
print_message $YELLOW "   • 为所有 5 个 Targets 设置 Team 为 'Yang Li (HHZN32E89C)'"
print_message $YELLOW "   • Product → Clean Build Folder (⇧⌘K)"
print_message $YELLOW "   • Product → Build (⌘B)"
echo ""
print_message $YELLOW "2. 更新 Apple Developer Portal 配置："
print_message $YELLOW "   需要在 Apple Developer Portal 创建新的 Bundle IDs："
echo "   • com.HHZN32E89C.xdripswiftt1li23"
echo "   • com.HHZN32E89C.xdripswiftt1li23.xDripWidget"
echo "   • com.HHZN32E89C.xdripswiftt1li23.watchkitapp"
echo "   • com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication"
echo "   • com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension"
echo ""
print_message $GREEN "🎉 现在 Bundle ID 前缀将匹配您的 Team (HHZN32E89C)！"

