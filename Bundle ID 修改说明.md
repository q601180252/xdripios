# Bundle ID 修改说明

## 修改内容

Bundle ID 已从 `com.7RV2Y67HF6.xdripswift` 修改为 `com.7RV2Y67HF6.xdripswiftt1li23`

## 已更新的文件

### 1. GitHub Actions 工作流
- ✅ `.github/workflows/build-ipa.yml`
  - 更新了 `BUNDLE_IDENTIFIER` 环境变量

### 2. 导出配置
- ✅ `ExportOptions.plist`
  - 添加了 `bundleIdentifier` 配置

### 3. Xcode 配置
- ✅ `xDrip/xDrip.xcconfig`
  - 更新了 `MAIN_APP_BUNDLE_IDENTIFIER`

## 新的 Bundle ID 结构

### 主应用
```
com.7RV2Y67HF6.xdripswiftt1li23
```

### 扩展应用（自动派生）

基于主 Bundle ID，扩展应用的 Bundle ID 将是：

1. **Widget 扩展**
   ```
   com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget
   ```

2. **通知扩展**
   ```
   com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension
   ```

3. **Watch App**
   ```
   com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp
   ```

4. **Watch Complication**
   ```
   com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication
   ```

## ⚠️ 重要：在 Apple Developer Portal 中注册

您需要在 Apple Developer Portal 中注册所有新的 Bundle ID：

### 步骤

1. **访问 Apple Developer Portal**
   - 登录 [https://developer.apple.com/account](https://developer.apple.com/account)

2. **进入 Identifiers**
   - 点击 **Certificates, Identifiers & Profiles**
   - 选择 **Identifiers**

3. **注册主应用 Bundle ID**
   - 点击 **"+"** 按钮
   - 选择 **App IDs**
   - Platform: **iOS, tvOS, watchOS**
   - Description: `xDrip4iOS Main App`
   - Bundle ID: **Explicit** → `com.7RV2Y67HF6.xdripswiftt1li23`
   - Capabilities: 勾选需要的功能
     - ✅ App Groups
     - ✅ HealthKit
     - ✅ Push Notifications
     - ✅ Background Modes
     - ✅ Associated Domains
   - 点击 **Continue** → **Register**

4. **注册 Widget 扩展 Bundle ID**
   - 重复步骤 3
   - Description: `xDrip4iOS Widget Extension`
   - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
   - Capabilities:
     - ✅ App Groups (使用相同的 group ID)

5. **注册通知扩展 Bundle ID**
   - Description: `xDrip4iOS Notification Extension`
   - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`
   - Capabilities:
     - ✅ App Groups

6. **注册 Watch App Bundle ID**
   - Description: `xDrip4iOS Watch App`
   - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
   - Capabilities:
     - ✅ App Groups

7. **注册 Watch Complication Bundle ID**
   - Description: `xDrip4iOS Watch Complication`
   - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`
   - Capabilities:
     - ✅ App Groups

## App Group ID

确保使用相同的 App Group ID：
```
group.com.7RV2Y67HF6.loopkit.LoopGroup
```

如果 App Group 不存在，需要创建：
1. 在 Identifiers 页面选择 **App Groups**
2. 点击 **"+"**
3. Description: `xDrip Loop Group`
4. Identifier: `group.com.7RV2Y67HF6.loopkit.LoopGroup`
5. 点击 **Continue** → **Register**

然后在每个 App ID 的 Capabilities 中启用并选择这个 App Group。

## 配置文件更新

Bundle ID 修改后，需要重新创建配置文件（Provisioning Profiles）：

### 方案 A: 自动创建（推荐）
使用 GitHub Actions 自动创建：
- 推送代码后，工作流会使用 App Store Connect API 自动创建配置文件
- 需要确保所有 Bundle ID 已在 Apple Developer Portal 注册

### 方案 B: 手动创建
1. 访问 [Provisioning Profiles](https://developer.apple.com/account/resources/profiles)
2. 为每个 Bundle ID 创建对应的配置文件
3. 选择 **App Store** 类型
4. 选择对应的 App ID
5. 选择 Distribution 证书
6. 下载并保存

## 证书更新

现有的证书可以继续使用，无需重新创建，因为：
- ✅ 证书绑定的是 Team ID，不是 Bundle ID
- ✅ 一个证书可以为多个 Bundle ID 签名

## GitHub Secrets 更新

不需要更新 GitHub Secrets，因为：
- ✅ `DEVELOPER_TEAM_ID` 保持不变
- ✅ `BUNDLE_IDENTIFIER` 在工作流文件中已更新
- ✅ 证书和 API Key 保持不变

## 验证修改

### 1. 本地验证
```bash
# 查看 Xcode 项目配置
grep -r "com.7RV2Y67HF6.xdripswiftt1li23" xDrip/xDrip.xcconfig

# 预期输出：
# MAIN_APP_BUNDLE_IDENTIFIER = com.$(DEVELOPMENT_TEAM).xdripswiftt1li23
```

### 2. Xcode 验证
1. 在 Xcode 中打开项目
2. 选择 **xdrip** target
3. 在 **General** 标签页查看 Bundle Identifier
4. 应该显示: `com.7RV2Y67HF6.xdripswiftt1li23`

### 3. 构建验证
```bash
# 清理并构建
xcodebuild clean -workspace xdrip.xcworkspace -scheme xdrip
xcodebuild build -workspace xdrip.xcworkspace -scheme xdrip -configuration Debug
```

## 完整的 Bundle ID 清单

确保在 Apple Developer Portal 注册以下所有 Bundle ID：

- [ ] `com.7RV2Y67HF6.xdripswiftt1li23`
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
- [ ] `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`

确保创建对应的 App Group：

- [ ] `group.com.7RV2Y67HF6.loopkit.LoopGroup`

## 下一步

1. ✅ 在 Apple Developer Portal 注册所有新的 Bundle ID
2. ✅ 为每个 Bundle ID 启用 App Group 并关联
3. ✅ （可选）手动创建配置文件，或让 GitHub Actions 自动创建
4. ✅ 提交代码并推送到 GitHub
5. ✅ 查看 GitHub Actions 构建日志
6. ✅ 验证 IPA 文件生成成功

## 注意事项

⚠️ **重要**：
- 修改 Bundle ID 后，这将被视为一个新的应用
- 如果之前有发布到 App Store，这是一个独立的新应用
- 用户数据不会自动迁移
- TestFlight 测试人员需要重新邀请

✅ **建议**：
- 在 App Store Connect 中创建新的应用记录
- 使用新的 Bundle ID 作为应用标识符
- 保持相同的 Team ID 和证书

