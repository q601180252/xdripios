#!/bin/bash

# 智能 Team ID 监控和修正脚本
# 检测 Xcode 是否修改了 Team ID，并自动修正

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

CORRECT_TEAM="7RV2Y67HF6"
WRONG_TEAM="HHZN32E89C"
PROJECT_FILE="xdrip.xcodeproj/project.pbxproj"

print_message $BLUE "🔍 检测 Team ID 状态..."

# 检查当前状态
WRONG_COUNT=$(grep -c "DEVELOPMENT_TEAM = $WRONG_TEAM" "$PROJECT_FILE" 2>/dev/null || echo "0")
CORRECT_COUNT=$(grep -c "DEVELOPMENT_TEAM = $CORRECT_TEAM" "$PROJECT_FILE" 2>/dev/null || echo "0")

echo ""
print_message $BLUE "📊 当前状态："
echo "  ❌ 错误 Team ID ($WRONG_TEAM): $WRONG_COUNT 处"
echo "  ✅ 正确 Team ID ($CORRECT_TEAM): $CORRECT_COUNT 处"
echo ""

if [ "$WRONG_COUNT" -gt 0 ]; then
    print_message $RED "⚠️  检测到 $WRONG_COUNT 处错误的 Team ID！"
    echo ""
    print_message $YELLOW "🔧 正在自动修正..."
    
    # 备份原文件
    cp "$PROJECT_FILE" "$PROJECT_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    
    # 替换所有错误的 Team ID
    sed -i '' "s/DEVELOPMENT_TEAM = $WRONG_TEAM;/DEVELOPMENT_TEAM = $CORRECT_TEAM;/g" "$PROJECT_FILE"
    
    # 验证修正结果
    NEW_WRONG_COUNT=$(grep -c "DEVELOPMENT_TEAM = $WRONG_TEAM" "$PROJECT_FILE" 2>/dev/null || echo "0")
    NEW_CORRECT_COUNT=$(grep -c "DEVELOPMENT_TEAM = $CORRECT_TEAM" "$PROJECT_FILE" 2>/dev/null || echo "0")
    
    echo ""
    print_message $GREEN "✅ 修正完成！"
    echo "  ❌ 错误 Team ID ($WRONG_TEAM): $NEW_WRONG_COUNT 处"
    echo "  ✅ 正确 Team ID ($CORRECT_TEAM): $NEW_CORRECT_COUNT 处"
    
    echo ""
    print_message $YELLOW "📋 现在在 Xcode 中执行："
    echo ""
    print_message $YELLOW "1️⃣  如果 Xcode 提示文件已修改："
    print_message $YELLOW "   选择 'Revert' 或 'Discard and Continue'"
    echo ""
    print_message $YELLOW "2️⃣  清理并构建："
    print_message $YELLOW "   Product → Clean Build Folder (⇧⌘K)"
    print_message $YELLOW "   Product → Build (⌘B)"
    echo ""
    
    print_message $RED "⚠️  重要提醒："
    print_message $RED "   下次在 Xcode 中设置 Team 时，请选择："
    print_message $RED "   ✅ EDUARDO PEIXOTO VIEIRA ($CORRECT_TEAM)"
    print_message $RED "   ❌ 不要选择包含 $WRONG_TEAM 的选项！"
    
else
    print_message $GREEN "✅ Team ID 已经正确，无需修正！"
    echo ""
    print_message $BLUE "💡 提示："
    print_message $BLUE "   在 Xcode 中设置 Team 时，请选择："
    print_message $BLUE "   ✅ EDUARDO PEIXOTO VIEIRA ($CORRECT_TEAM)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $GREEN "🎉 Team ID 检查完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

