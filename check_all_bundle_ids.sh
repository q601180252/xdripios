#!/bin/bash

echo "🔍 检查所有 Targets 的 Bundle ID 配置"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查主应用
echo "1️⃣  主应用 (xdrip):"
xcodebuild -showBuildSettings -workspace xdrip.xcworkspace -scheme xdrip -configuration Release 2>/dev/null | grep "PRODUCT_BUNDLE_IDENTIFIER = " | grep -v DERIVE | head -1

# 使用 grep 从 project.pbxproj 中提取所有硬编码的 Bundle ID
echo ""
echo "2️⃣  从 project.pbxproj 提取的所有 Bundle ID:"
echo ""
grep -o 'com\.7RV2Y67HF6\.xdripswift[^"]*' xdrip.xcodeproj/project.pbxproj | sort -u | while read bid; do
  echo "   ❌ 旧 ID: $bid"
done

grep -o 'com\.7RV2Y67HF6\.xdripswiftt1li23[^"]*' xdrip.xcodeproj/project.pbxproj | sort -u | while read bid; do
  echo "   ✅ 新 ID: $bid"
done

echo ""
echo "3️⃣  从 Info.plist 文件中查找硬编码的 Bundle ID:"
echo ""

find . -name "Info.plist" -type f ! -path "*/Frameworks/*" ! -path "*/LibOutshine/*" ! -path "*/build/*" 2>/dev/null | while read plist; do
  if grep -q "xdripswift" "$plist" 2>/dev/null; then
    echo "   ⚠️  $plist 中包含旧 Bundle ID:"
    grep -n "xdripswift" "$plist" | head -5
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

