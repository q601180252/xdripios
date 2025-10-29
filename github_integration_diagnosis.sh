#!/bin/bash

# GitHub 集成诊断脚本
echo "🔍 GitHub & Xcode Cloud 集成诊断"
echo "================================"

# 1. 检查Git配置
echo "📊 Git配置:"
echo "   远程仓库: $(git remote get-url origin 2>/dev/null || echo '未配置')"
echo "   当前分支: $(git branch --show-current 2>/dev/null || echo '无法获取')"
echo "   工作目录状态: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') 个文件待提交"

# 2. 检查GitHub连接
echo ""
echo "🌐 GitHub连接测试:"
if curl -s https://api.github.com/repos/bubbledevteam/xdrip_ios > /dev/null; then
    echo "   ✅ GitHub API连接成功"
    
    # 检查仓库信息
    REPO_INFO=$(curl -s https://api.github.com/repos/bubbledevteam/xdrip_ios)
    REPO_NAME=$(echo "$REPO_INFO" | grep -o '"name": "[^"]*"' | head -1 | cut -d'"' -f4)
    REPO_PRIVATE=$(echo "$REPO_INFO" | grep -o '"private": [^,]*' | cut -d' ' -f3)
    REPO_DEFAULT_BRANCH=$(echo "$REPO_INFO" | grep -o '"default_branch": "[^"]*"' | cut -d'"' -f4)
    
    echo "   📦 仓库名称: $REPO_NAME"
    echo "   🔒 仓库类型: $([ "$REPO_PRIVATE" = "true" ] && echo '私有' || echo '公开')"
    echo "   🌿 默认分支: $REPO_DEFAULT_BRANCH"
else
    echo "   ❌ GitHub API连接失败"
fi

# 3. 检查认证状态
echo ""
echo "🔑 认证状态检查:"
if gh auth status 2>/dev/null; then
    echo "   ✅ GitHub CLI认证成功"
    echo "   当前用户: $(gh api user 2>/dev/null | grep -o '"login": "[^"]*"' | cut -d'"' -f4)"
else
    echo "   ⚠️  GitHub CLI未认证或未安装"
fi

# 4. 检查Xcode Cloud相关配置
echo ""
echo "☁️  Xcode Cloud配置检查:"
echo "   项目文件: $(ls -la xdrip.xcworkspace 2>/dev/null > /dev/null && echo '✅ 存在' || echo '❌ 缺失')"
echo "   工作空间: $(ls -la xdrip.xcworkspace 2>/dev/null > /dev/null && echo '✅ 正常' || echo '❌ 异常')"

# 5. 检查可能的GitHub集成问题
echo ""
echo "🔍 常见GitHub集成问题检查:"

# 检查.gitattributes文件
if [ -f .gitattributes ]; then
    echo "   ⚠️  发现.gitattributes文件，可能影响Git LFS"
    cat .gitattributes
else
    echo "   ✅ 无.gitattributes文件"
fi

# 检查大文件
echo ""
echo "📏 大文件检查:"
LFS_FILES=$(find . -name "*.psd" -o -name "*.zip" -o -name "*.a" -o -name "*.framework" | head -5)
if [ -n "$LFS_FILES" ]; then
    echo "   ⚠️  发现可能需要Git LFS的大文件:"
    echo "$LFS_FILES" | sed 's/^/      /'
else
    echo "   ✅ 无明显大文件问题"
fi

# 6. 检查分支保护
echo ""
echo "🔒 分支保护检查:"
if gh api repos/bubbledevteam/xdrip_ios/branches/main 2>/dev/null | grep -q '"protected": true'; then
    echo "   ⚠️  main分支受保护，可能需要特殊权限"
else
    echo "   ✅ main分支未受保护"
fi

# 7. 解决方案建议
echo ""
echo "💡 GitHub集成问题解决方案:"
echo "==========================="
echo "1. 确保在GitHub中授权Xcode Cloud访问权限"
echo "2. 检查GitHub仓库设置中的Integrations权限"
echo "3. 确保开发者账号有仓库写入权限"
echo "4. 如果仓库是私有的，确保Xcode Cloud有访问权限"
echo "5. 尝试在App Store Connect中手动配置仓库"
echo "6. 清除Xcode缓存并重新尝试"

echo ""
echo "🔧 具体操作步骤:"
echo "1. 访问: https://github.com/bubbledevteam/xdrip_ios/settings/installations"
echo "2. 确保Xcode Cloud有访问权限"
echo "3. 在App Store Connect中选择正确的仓库和分支"
echo "4. 如果问题持续，尝试重新授权GitHub"