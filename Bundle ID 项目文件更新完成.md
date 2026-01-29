# ✅ Bundle ID 项目文件更新完成

## 更新摘要

已成功将 Xcode 项目文件中的所有 Bundle ID 从 `com.7RV2Y67HF6.xdripswift` 更新为 `com.7RV2Y67HF6.xdripswiftt1li23`。

## 更新的文件

### 1. Xcode 项目文件
**文件**: `xdrip.xcodeproj/project.pbxproj`

更新了以下 Bundle ID 配置：

#### 主应用
- ✅ `com.7RV2Y67HF6.xdripswift` → `com.7RV2Y67HF6.xdripswiftt1li23`

#### Widget 扩展
- ✅ `com.7RV2Y67HF6.xdripswift.xDripWidget` → `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`

#### 通知扩展
- ✅ `com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension` → `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`

#### Watch App
- ✅ `com.7RV2Y67HF6.xdripswift.watchkitapp` → `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`

#### Watch Complication
- ✅ `com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication` → `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`

### 2. 配置文件
之前已更新：
- ✅ `.github/workflows/build-ipa.yml`
- ✅ `ExportOptions.plist`
- ✅ `xDrip/xDrip.xcconfig`

## 修改详情

在 `project.pbxproj` 中更新了以下配置项（Debug 和 Release 各一次，共 10 处）：

```
"PRODUCT_BUNDLE_IDENTIFIER[sdk=iphoneos*]" = com.7RV2Y67HF6.xdripswiftt1li23;
"PRODUCT_BUNDLE_IDENTIFIER[sdk=iphoneos*]" = com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget;
"PRODUCT_BUNDLE_IDENTIFIER[sdk=iphoneos*]" = com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension;
"PRODUCT_BUNDLE_IDENTIFIER[sdk=watchos*]" = com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp;
"PRODUCT_BUNDLE_IDENTIFIER[sdk=watchos*]" = com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication;
```

## 验证

### 本地验证
```bash
# 检查项目文件中的新 Bundle ID
grep -c "com.7RV2Y67HF6.xdripswiftt1li23" xdrip.xcodeproj/project.pbxproj
# 应该显示: 10

# 确认旧 Bundle ID 已全部替换
grep "com.7RV2Y67HF6.xdripswift[^t]" xdrip.xcodeproj/project.pbxproj
# 应该没有结果
```

### Xcode 验证
在 Xcode 中打开项目后，每个 target 的 Bundle Identifier 应该显示为：

- **xdrip**: `com.7RV2Y67HF6.xdripswiftt1li23`
- **xDrip Widget Extension**: `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
- **xDrip Notification Context Extension**: `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`
- **xDrip Watch App**: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
- **xDrip Watch Complication Extension**: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`

## 下一步

### 1. 在 Apple Developer Portal 注册 Bundle ID

**重要**：必须在 Apple Developer Portal 注册所有新的 Bundle ID，否则构建会失败。

访问：[Apple Developer - Identifiers](https://developer.apple.com/account/resources/identifiers)

需要注册的 Bundle ID：
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23`
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`

每个 Bundle ID 需要：
- ✅ 启用 App Groups
- ✅ 关联到 `group.com.7RV2Y67HF6.loopkit.LoopGroup`
- ✅ 主应用额外启用：HealthKit, Push Notifications, Background Modes

### 2. 配置 GitHub Secrets

确保以下 Secrets 已配置：
- [ ] `APPSTORE_API_KEY_ID`
- [ ] `APPSTORE_ISSUER_ID`
- [ ] `APPSTORE_API_PRIVATE_KEY`
- [ ] `CERTIFICATES_P12`
- [ ] `CERTIFICATES_P12_PASSWORD`

### 3. 推送代码触发构建

```bash
# 提交所有更改
git add .
git commit -m "Update all Bundle IDs to com.7RV2Y67HF6.xdripswiftt1li23"
git push origin main
```

### 4. 查看构建日志

- 进入 GitHub Actions 页面
- 查看最新的工作流运行
- 确认没有 Bundle ID 相关错误

## 常见问题

### Q: 为什么还是显示旧的 Bundle ID 错误？
**A**: 确保：
1. 已提交并推送所有更改
2. 在 Apple Developer Portal 注册了所有新的 Bundle ID
3. GitHub Secrets 已正确配置

### Q: 如何在 App Store Connect 中配置？
**A**: 
1. 访问 [App Store Connect](https://appstoreconnect.apple.com)
2. 点击 "My Apps" → "+"
3. 选择 "New App"
4. Bundle ID 选择 `com.7RV2Y67HF6.xdripswiftt1li23`

### Q: 旧版本的数据怎么办？
**A**: 
- 新的 Bundle ID 被视为全新的应用
- 用户数据不会自动迁移
- 这是两个独立的应用

## 技术说明

### SDK 特定的 Bundle ID

项目文件中使用了 SDK 特定的 Bundle ID 配置：
- `PRODUCT_BUNDLE_IDENTIFIER[sdk=iphoneos*]` - 用于 iOS 设备
- `PRODUCT_BUNDLE_IDENTIFIER[sdk=watchos*]` - 用于 watchOS 设备

这种配置方式允许在不同 SDK 上使用不同的 Bundle ID，但在本项目中，我们为所有 SDK 使用相同的 Bundle ID 模式。

### 动态 Bundle ID

主 Bundle ID 通过 `xDrip.xcconfig` 中的变量定义：
```
MAIN_APP_BUNDLE_IDENTIFIER = com.$(DEVELOPMENT_TEAM).xdripswiftt1li23
```

扩展的 Bundle ID 通过在主 ID 后附加后缀派生：
```
$(MAIN_APP_BUNDLE_IDENTIFIER).xDripWidget
$(MAIN_APP_BUNDLE_IDENTIFIER).watchkitapp
```

SDK 特定的配置作为覆盖值，确保在实际构建时使用完整的 Bundle ID。

## 总结

✅ 所有文件已更新  
✅ 旧 Bundle ID 已完全替换  
✅ 新 Bundle ID 配置正确  
⏳ 等待在 Apple Developer Portal 注册  
⏳ 等待 GitHub Actions 构建验证

完成 Apple Developer Portal 注册后，GitHub Actions 构建应该能够成功！

