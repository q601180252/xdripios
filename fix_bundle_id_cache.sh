#!/bin/bash

# 彻底清理 Xcode 缓存脚本
# 解决 Bundle ID 前缀错误

set -e

echo "🧹 开始彻底清理 Xcode 缓存..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 清理 DerivedData
echo "1️⃣  清理 DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "   ✅ DerivedData 已清理"

# 2. 清理项目构建目录
echo "2️⃣  清理项目构建目录..."
rm -rf build/
rm -rf .build/
echo "   ✅ 项目构建目录已清理"

# 3. 清理 workspace 用户数据
echo "3️⃣  清理 workspace 用户数据..."
rm -rf xdrip.xcworkspace/xcuserdata
rm -rf xdrip.xcodeproj/xcuserdata
rm -rf xdrip.xcodeproj/project.xcworkspace
echo "   ✅ 用户数据已清理"

# 4. 清理 Swift Package Manager 缓存
echo "4️⃣  清理 Swift Package Manager 缓存..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData/*/SourcePackages
echo "   ✅ SPM 缓存已清理"

# 5. 清理模块缓存
echo "5️⃣  清理模块缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
echo "   ✅ 模块缓存已清理"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 所有缓存已清理完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 下一步操作："
echo ""
echo "1. 如果 Xcode 正在运行："
echo "   • 完全退出 Xcode (⌘Q)"
echo "   • 等待 3 秒"
echo ""
echo "2. 重新打开 Xcode："
echo "   • 打开 Xcode"
echo "   • File → Open → 选择 xdrip.xcworkspace"
echo "   • 等待索引完成"
echo ""
echo "3. 重新构建："
echo "   • Product → Clean Build Folder (⇧⌘K)"
echo "   • Product → Build (⌘B)"
echo ""
echo "🎉 应该不再出现 Bundle ID 前缀错误了！"
echo ""

