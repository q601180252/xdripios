# Bundle ID 修改完成总结

## 🎯 修改目标

**从**:
- Team ID: `HHZN32E89C`
- Bundle ID: `com.HHZN32E89C.xdripswiftt1li23`
- App Group: `group.com.HHZN32E89C.loopkit.LoopGroup`

**改为**:
- Team ID: `7RV2Y67HF6`
- Bundle ID: `com.7RV2Y67HF6.xdripswift`
- App Group: `group.com.7RV2Y67HF6.xdripswift`

---

## ✅ 完成的修改 (7 个提交)

### 1. `84e22c5` - 删除 Gemfile.lock 并更新 bundle 流程
- 删除旧的 `Gemfile.lock`
- 使用 `bundle lock --update` 动态生成
- 修复 Ruby 依赖冲突

### 2. `602733e` - 更新 Bundle ID 和 Team ID (基础配置)
- 修改 `.github/workflows/build-ipa-with-match.yml`
  - `DEVELOPER_TEAM_ID`: 7RV2Y67HF6
  - `BUNDLE_IDENTIFIER`: com.7RV2Y67HF6.xdripswift
- 修改 `xdrip.xcodeproj/project.pbxproj`
  - `MAIN_APP_BUNDLE_IDENTIFIER`: com.7RV2Y67HF6.xdripswift

### 3. `e4a74e5` - 更新所有 entitlements 文件中的 App Group
修改的文件 (6 个):
- `xdrip/xdrip.entitlements`
- `xdrip/xdripDebug.entitlements`
- `xDrip Widget Extension.entitlements`
- `xDrip Watch App/xDrip Watch App.entitlements`
- `xDrip Watch Complication Extension.entitlements`
- `xDrip Notification Context Extension/xDrip Notification Context Extension.entitlements`

所有文件都添加了:
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.7RV2Y67HF6.xdripswift</string>
</array>
```

### 4. `54207be` - 修复所有 Fastfile 中的 Bundle ID
- 修改 `.github/workflows/build-ipa-with-match.yml`
  - Match 下载步骤的 app_identifier
- 修改 `fastlane/Fastfile`
  - 所有 `xdripswiftt1li23` → `xdripswift` (23 处)

### 5. `1773b3d` - 修复 Watch App 的 WKCompanionAppBundleIdentifier
- 修改 `xdrip.xcodeproj/project.pbxproj`
  - `INFOPLIST_KEY_WKCompanionAppBundleIdentifier`
  - 从 `com.HHZN32E89C.xdripswiftt1li23`
  - 改为 `com.7RV2Y67HF6.xdripswift`

### 6. `41a494a` - 修复 ExportOptions.plist
- 更新 `teamID`: 7RV2Y67HF6
- 更新所有 5 个 `provisioningProfiles` 配置

### 7. `bab41db` - 修复 xDrip.xcconfig (根本原因!) ⭐️
**最关键的修复!**

`xDrip/xDrip.xcconfig` 是整个项目的配置核心:
```
DEVELOPMENT_TEAM = 7RV2Y67HF6
MAIN_APP_BUNDLE_IDENTIFIER = com.$(DEVELOPMENT_TEAM).xdripswift
GROUP_ID = group.com.$(DEVELOPMENT_TEAM).xdripswift
```

这个文件设置的变量被所有 targets 使用，修复它就修复了所有 Bundle ID！

---

## 📦 修改的文件汇总 (12 个)

### 配置文件
1. `.github/workflows/build-ipa-with-match.yml` - GitHub Actions workflow
2. `xdrip.xcodeproj/project.pbxproj` - Xcode 项目配置
3. `fastlane/Fastfile` - Fastlane 构建脚本
4. `ExportOptions.plist` - IPA 导出配置
5. **`xDrip/xDrip.xcconfig`** - **核心配置文件** ⭐️

### Entitlements 文件 (6 个)
6. `xdrip/xdrip.entitlements`
7. `xdrip/xdripDebug.entitlements`
8. `xDrip Widget Extension.entitlements`
9. `xDrip Watch App/xDrip Watch App.entitlements`
10. `xDrip Watch Complication Extension.entitlements`
11. `xDrip Notification Context Extension/xDrip Notification Context Extension.entitlements`

### 删除的文件
12. `Gemfile.lock` - 已删除，会在 CI 中重新生成

---

## 🆕 新的配置

### Team ID
```
7RV2Y67HF6
```

### Bundle IDs (5 个)
```
com.7RV2Y67HF6.xdripswift
com.7RV2Y67HF6.xdripswift.xDripWidget
com.7RV2Y67HF6.xdripswift.watchkitapp
com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication
com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension
```

### App Group
```
group.com.7RV2Y67HF6.xdripswift
```

---

## 🚀 下一步操作

### 1. 本地编译测试

**在 Xcode 中**:
1. **File → Packages → Resolve Package Versions**
   - 下载所有 Swift Package 依赖
   - 等待 1-2 分钟
2. **Product → Build** (⌘B)
   - 应该编译成功! ✅

### 2. 推送代码到 GitHub

```bash
git push origin main
```

### 3. 在 Apple Developer 创建配置

访问: https://developer.apple.com/account/resources/identifiers/list

**3.1 创建 App Group**:
- Identifier: `group.com.7RV2Y67HF6.xdripswift`
- Description: xDrip Swift App Group

**3.2 创建 5 个 App IDs** (每个都需要启用 App Groups):

#### a) `com.7RV2Y67HF6.xdripswift`
- Platform: iOS
- Capabilities:
  - App Groups → `group.com.7RV2Y67HF6.xdripswift`
  - HealthKit
  - Near Field Communication Tag Reading

#### b) `com.7RV2Y67HF6.xdripswift.xDripWidget`
- Platform: iOS
- Capabilities:
  - App Groups → `group.com.7RV2Y67HF6.xdripswift`

#### c) `com.7RV2Y67HF6.xdripswift.watchkitapp`
- Platform: watchOS
- Capabilities:
  - App Groups → `group.com.7RV2Y67HF6.xdripswift`

#### d) `com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication`
- Platform: watchOS
- Capabilities:
  - App Groups → `group.com.7RV2Y67HF6.xdripswift`

#### e) `com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension`
- Platform: iOS
- Capabilities:
  - App Groups → `group.com.7RV2Y67HF6.xdripswift`

### 4. 使用 Match 创建证书和 Profiles

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 设置环境变量
export MATCH_PASSWORD="你的 Match 仓库密码"
export MATCH_GIT_BASIC_AUTHORIZATION=$(echo -n "q601180252:你的GitHub_PAT" | base64)
export FASTLANE_USER="你的新 Apple ID"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="应用专用密码"

# 创建证书和 Profiles (不使用 --readonly)
bundle exec fastlane match appstore \
  --git_url "https://github.com/q601180252/xDrip-Match-Secrets.git" \
  --git_basic_authorization "$MATCH_GIT_BASIC_AUTHORIZATION" \
  --app_identifier "com.7RV2Y67HF6.xdripswift,com.7RV2Y67HF6.xdripswift.xDripWidget,com.7RV2Y67HF6.xdripswift.watchkitapp,com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication,com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension" \
  --team_id "7RV2Y67HF6"
```

这会:
- 创建新的 Distribution 证书
- 为 5 个 Bundle IDs 创建 Provisioning Profiles
- 加密后推送到 Match 仓库

### 5. 测试 GitHub Actions 构建

1. 访问: https://github.com/q601180252/xdripios/actions
2. 选择 "Build xDrip iOS IPA (with Fastlane Match)"
3. 点击 "Run workflow"
4. 选择 Release
5. 运行并验证

---

## ✅ 验证清单

### 代码修改
- ✅ GitHub Actions workflow 已更新
- ✅ Xcode 项目配置已更新
- ✅ **xDrip.xcconfig 已更新** (核心!)
- ✅ Fastfile 已更新
- ✅ ExportOptions.plist 已更新
- ✅ 所有 entitlements 已更新
- ✅ Git 已提交 (7 个提交)

### 待完成
- ⏳ 在 Xcode 中解析 Swift Package 依赖
- ⏳ 本地编译测试
- ⏳ 推送代码到 GitHub
- ⏳ 在 Apple Developer 创建 App Group
- ⏳ 在 Apple Developer 创建 5 个 App IDs
- ⏳ 使用 Match 创建证书和 Profiles
- ⏳ 测试 GitHub Actions 构建

---

## 🎓 关键经验

**xDrip.xcconfig 是配置核心!**

这个文件设置了项目的所有关键变量:
- `DEVELOPMENT_TEAM`
- `MAIN_APP_BUNDLE_IDENTIFIER`
- `GROUP_ID`

所有其他配置文件都引用这些变量，修改这个文件就能影响整个项目！

---

## 📞 如果遇到问题

### Swift Package 依赖无法解析
- 检查网络连接
- File → Packages → Reset Package Caches
- 重新: File → Packages → Resolve Package Versions

### Bundle ID 还是不对
- 完全关闭 Xcode
- 删除 DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
- 重新打开 Xcode

### Match 证书创建失败
- 确保在 Apple Developer 创建了所有 App IDs
- 确保所有 App IDs 都启用了 App Groups
- 确保设置了正确的环境变量

---

## 🎉 完成!

现在所有配置都已正确，准备好:
1. ✅ 本地编译
2. ✅ GitHub Actions 自动构建
3. ✅ 自动上传到 TestFlight

祝编译顺利! 🚀

