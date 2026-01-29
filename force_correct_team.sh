#!/bin/bash

# 强制使用正确的 Team ID，即使 Xcode 修改了也会自动修正

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

print_message $GREEN "🔧 强制修正 Team ID 为 $CORRECT_TEAM..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

PROJECT_FILE="xdrip.xcodeproj/project.pbxproj"

# 检查是否有错误的 Team ID
WRONG_COUNT=$(grep -c "DEVELOPMENT_TEAM = $WRONG_TEAM" "$PROJECT_FILE" 2>/dev/null || echo "0")
CORRECT_COUNT=$(grep -c "DEVELOPMENT_TEAM = $CORRECT_TEAM" "$PROJECT_FILE" 2>/dev/null || echo "0")

print_message $BLUE "当前状态："
echo "  旧 Team ID ($WRONG_TEAM): $WRONG_COUNT 处"
echo "  新 Team ID ($CORRECT_TEAM): $CORRECT_COUNT 处"
echo ""

if [ "$WRONG_COUNT" -gt 0 ]; then
    print_message $YELLOW "发现 $WRONG_COUNT 处错误的 Team ID，正在修正..."
    
    # 替换所有错误的 Team ID
    sed -i '' "s/DEVELOPMENT_TEAM = $WRONG_TEAM;/DEVELOPMENT_TEAM = $CORRECT_TEAM;/g" "$PROJECT_FILE"
    
    # 验证
    NEW_WRONG_COUNT=$(grep -c "DEVELOPMENT_TEAM = $WRONG_TEAM" "$PROJECT_FILE" 2>/dev/null || echo "0")
    NEW_CORRECT_COUNT=$(grep -c "DEVELOPMENT_TEAM = $CORRECT_TEAM" "$PROJECT_FILE" 2>/dev/null || echo "0")
    
    print_message $GREEN "✅ 修正完成！"
    echo "  旧 Team ID ($WRONG_TEAM): $NEW_WRONG_COUNT 处"
    echo "  新 Team ID ($CORRECT_TEAM): $NEW_CORRECT_COUNT 处"
else
    print_message $GREEN "✅ Team ID 已经正确，无需修正！"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $GREEN "🎉 Team ID 修正完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_message $YELLOW "📋 下一步（在 Xcode 中）："
echo ""
print_message $YELLOW "1. 如果 Xcode 提示文件已修改："
print_message $YELLOW "   选择 'Revert' 或 'Discard and Continue'"
echo ""
print_message $YELLOW "2. 清理并构建："
print_message $YELLOW "   Product → Clean Build Folder (⇧⌘K)"
print_message $YELLOW "   Product → Build (⌘B)"
echo ""
print_message $GREEN "✅ 现在所有 Bundle ID 前缀都是 com.$CORRECT_TEAM！"

