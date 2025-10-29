#!/bin/bash

# 更新 Match-Secrets 仓库,为新 Bundle IDs 创建 Provisioning Profiles

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

print_message $GREEN "╔══════════════════════════════════════════════════════════════════════════╗"
print_message $GREEN "║         更新 Fastlane Match - 为新 Bundle IDs 创建 Profiles           ║"
print_message $GREEN "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# 检查环境变量
print_message $YELLOW "🔍 检查必需的环境变量..."
echo ""

if [ -z "$MATCH_PASSWORD" ]; then
    print_message $RED "❌ 错误: MATCH_PASSWORD 环境变量未设置"
    echo ""
    print_message $YELLOW "请先设置:"
    echo "export MATCH_PASSWORD=\"your-match-password\""
    exit 1
fi

if [ -z "$GH_PAT" ]; then
    print_message $RED "❌ 错误: GH_PAT 环境变量未设置"
    echo ""
    print_message $YELLOW "请先设置:"
    echo "export GH_PAT=\"ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\""
    exit 1
fi

# 设置其他必需的环境变量
export GITHUB_REPOSITORY_OWNER="q601180252"
export TEAMID="HHZN32E89C"
export GITHUB_WORKSPACE=$(pwd)

print_message $GREEN "✅ 环境变量检查通过"
echo ""
echo "MATCH_PASSWORD: ********** (已设置)"
echo "GH_PAT: ghp_********** (已设置)"
echo "GITHUB_REPOSITORY_OWNER: $GITHUB_REPOSITORY_OWNER"
echo "TEAMID: $TEAMID"
echo "GITHUB_WORKSPACE: $GITHUB_WORKSPACE"
echo ""

print_message $YELLOW "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $YELLOW "⚠️  重要说明"
print_message $YELLOW "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_message $YELLOW "此脚本将:"
echo "  1. 连接到 Apple Developer Portal"
echo "  2. 为新的 5 个 Bundle IDs 创建 Provisioning Profiles:"
echo "     • com.HHZN32E89C.xdripswiftt1li23"
echo "     • com.HHZN32E89C.xdripswiftt1li23.xDripWidget"
echo "     • com.HHZN32E89C.xdripswiftt1li23.watchkitapp"
echo "     • com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication"
echo "     • com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension"
echo "  3. 加密并推送到 Match-Secrets 仓库"
echo ""
print_message $YELLOW "这可能需要 5-10 分钟"
echo ""

# 询问是否继续
print_message $BLUE "是否继续? (y/n): "
read -r response
echo ""

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    print_message $YELLOW "已取消"
    exit 0
fi

print_message $GREEN "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $GREEN "🚀 开始执行 Fastlane Match..."
print_message $GREEN "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 运行 Fastlane Match
print_message $BLUE "📦 运行 bundle exec fastlane certs..."
echo ""

bundle exec fastlane certs

echo ""
print_message $GREEN "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $GREEN "✅ Fastlane Match 执行完成!"
print_message $GREEN "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_message $GREEN "Match-Secrets 仓库已更新,包含:"
echo "  ✅ Distribution 证书"
echo "  ✅ 5 个 Provisioning Profiles (新 Bundle IDs)"
echo ""

print_message $YELLOW "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $YELLOW "📋 下一步操作"
print_message $YELLOW "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_message $YELLOW "1. 推送代码到 GitHub:"
echo "   git push origin main"
echo ""
print_message $YELLOW "2. 观察 GitHub Actions 构建:"
echo "   https://github.com/q601180252/xdripios/actions"
echo ""
print_message $YELLOW "3. 等待构建成功并上传到 TestFlight"
echo ""

print_message $GREEN "🎉 配置完成! 🎉"

