#!/bin/bash

# Fastlane Match - 创建 Provisioning Profiles 脚本
# 用途：在本地 Mac 上运行，创建 xDrip 应用所需的所有 provisioning profiles

set -e

echo "=================================="
echo "  Fastlane Match 配置工具"
echo "=================================="
echo ""

# 检查是否在正确的目录
if [ ! -f "fastlane/Fastfile" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 检查必需的环境变量
echo "📋 检查环境变量..."
echo ""

MISSING_VARS=0

if [ -z "$MATCH_PASSWORD" ]; then
    echo "❌ 缺少 MATCH_PASSWORD"
    echo "   这是用于加密/解密 Match 仓库的密码"
    MISSING_VARS=1
fi

if [ -z "$GH_PAT" ]; then
    echo "❌ 缺少 GH_PAT"
    echo "   这是你的 GitHub Personal Access Token"
    MISSING_VARS=1
fi

if [ -z "$FASTLANE_KEY_ID" ]; then
    echo "❌ 缺少 FASTLANE_KEY_ID"
    echo "   这是 Apple API Key 的 ID"
    MISSING_VARS=1
fi

if [ -z "$FASTLANE_ISSUER_ID" ]; then
    echo "❌ 缺少 FASTLANE_ISSUER_ID"
    echo "   这是 Apple Issuer ID"
    MISSING_VARS=1
fi

if [ -z "$FASTLANE_KEY" ]; then
    echo "❌ 缺少 FASTLANE_KEY"
    echo "   这是 Apple API Key 的内容（Base64 编码）"
    MISSING_VARS=1
fi

if [ -z "$TEAMID" ]; then
    echo "⚠️  缺少 TEAMID，使用默认值: 7RV2Y67HF6"
    echo "     (这是项目配置文件中使用的 Team ID)"
    export TEAMID="7RV2Y67HF6"
fi

if [ -z "$GITHUB_REPOSITORY_OWNER" ]; then
    echo "⚠️  缺少 GITHUB_REPOSITORY_OWNER，使用默认值: q601180252"
    export GITHUB_REPOSITORY_OWNER="q601180252"
fi

if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "⚠️  缺少 GITHUB_WORKSPACE，使用当前目录"
    export GITHUB_WORKSPACE="$(pwd)"
fi

echo ""

if [ $MISSING_VARS -eq 1 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  如何设置环境变量"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "在运行此脚本前，请先设置必需的环境变量："
    echo ""
    echo "export MATCH_PASSWORD=\"你的 Match 密码\""
    echo "export GH_PAT=\"你的 GitHub PAT\""
    echo "export FASTLANE_KEY_ID=\"你的 Apple Key ID\""
    echo "export FASTLANE_ISSUER_ID=\"你的 Apple Issuer ID\""
    echo "export FASTLANE_KEY=\"你的 Apple Key 内容（Base64）\""
    echo ""
    echo "然后重新运行此脚本："
    echo "./setup_match_profiles.sh"
    echo ""
    exit 1
fi

echo "✅ 所有必需的环境变量已设置"
echo ""

# 显示配置信息
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  当前配置"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Team ID: $TEAMID"
echo "GitHub Owner: $GITHUB_REPOSITORY_OWNER"
echo "Match 仓库: https://github.com/$GITHUB_REPOSITORY_OWNER/Match-Secrets.git"
echo ""
echo "将创建以下 Bundle IDs 的 provisioning profiles:"
echo "  1. com.$TEAMID.xdripswift"
echo "  2. com.$TEAMID.xdripswift.xDripWidget"
echo "  3. com.$TEAMID.xdripswift.watchkitapp"
echo "  4. com.$TEAMID.xdripswift.watchkitapp.xDripWatchComplication"
echo "  5. com.$TEAMID.xdripswift.xDripNotificationContextExtension"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 确认继续
read -p "确认要继续吗？(y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

echo ""
echo "🚀 开始运行 Fastlane Match..."
echo ""

# 运行 Fastlane certs lane
bundle exec fastlane certs

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ 完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Provisioning profiles 已创建并上传到 Match-Secrets 仓库"
echo ""
echo "📝 下一步："
echo "  1. 前往 GitHub Actions 页面"
echo "  2. 重新运行构建工作流"
echo "  3. 这次应该能成功获取 provisioning profiles"
echo ""
echo "查看 Match 仓库："
echo "https://github.com/$GITHUB_REPOSITORY_OWNER/Match-Secrets"
echo ""
