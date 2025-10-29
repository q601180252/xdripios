#!/bin/bash

# 修复模拟器构建问题 - 临时移除不支持模拟器的 Framework

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

print_message $GREEN "🔧 开始修复模拟器构建问题..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 注释掉 Bugly.framework 的链接
PROJECT_FILE="xdrip.xcodeproj/project.pbxproj"

print_message $BLUE "1️⃣  检查 Bugly.framework 链接..."

if grep -q "9423ADB42C8162C900574EB6.*Bugly.framework in Frameworks" "$PROJECT_FILE"; then
    print_message $YELLOW "   找到 Bugly.framework 链接，准备注释..."
    
    # 备份
    cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
    
    # 注释掉 Bugly 的 Frameworks 引用
    sed -i '' 's/\(.*9423ADB42C8162C900574EB6.*Bugly\.framework in Frameworks.*\)/\/\* \1 \*\//' "$PROJECT_FILE"
    
    print_message $GREEN "   ✅ 已注释 Bugly.framework 链接"
else
    print_message $YELLOW "   Bugly.framework 链接已经被注释或不存在"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $GREEN "✅ 修复完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_message $YELLOW "📋 下一步操作："
echo ""
print_message $YELLOW "1. 在 Xcode 中："
print_message $YELLOW "   • Product → Clean Build Folder (⇧⌘K)"
print_message $YELLOW "   • Product → Build (⌘B)"
echo ""
print_message $GREEN "🎉 模拟器构建应该成功了！"
echo ""
print_message $YELLOW "💡 注意："
print_message $YELLOW "   • Bugly 仅用于崩溃报告，不影响核心功能"
print_message $YELLOW "   • 真机构建时可以恢复 Bugly"
print_message $YELLOW "   • 备份文件: $PROJECT_FILE.backup"

