# App Store Connect 配置指南

## 🎯 目标
为 xDrip iOS 应用配置正确的 App Store Connect 设置，确保所有必要的功能权限都已启用。

## 📱 应用功能要求

### 主应用 (com.7RV2Y67HF6.xdripswiftt1li23)
- ✅ **App Groups** - 用于与扩展共享数据
- ✅ **HealthKit** - 用于血糖数据集成
- ✅ **Near Field Communication Tag Reading** - 用于 NFC 功能

### 扩展应用
- **xDrip Widget Extension** (com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget)
  - ✅ **App Groups** - 与主应用共享数据

- **xDrip Watch App** (com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp)
  - ✅ **App Groups** - 与主应用共享数据

- **xDrip Watch Complication Extension** (com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication)
  - ✅ **App Groups** - 与主应用共享数据

- **xDrip Notification Context Extension** (com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension)
  - ✅ **App Groups** - 与主应用共享数据

## 🔧 配置步骤

### 1. 创建 App Store Connect 应用

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 点击 **"我的 App"** → **"+"** → **"新建 App"**
3. 填写应用信息：
   - **平台**: iOS
   - **名称**: xDrip
   - **主要语言**: 简体中文
   - **Bundle ID**: `com.7RV2Y67HF6.xdripswiftt1li23`
   - **SKU**: `xdripswiftt1li23`

### 2. 配置 Bundle ID 和功能

#### 2.1 主应用 Bundle ID
1. 在 [Apple Developer Portal](https://developer.apple.com/account) 中
2. 进入 **"Certificates, Identifiers & Profiles"**
3. 选择 **"Identifiers"** → **"App IDs"**
4. 找到或创建 `com.7RV2Y67HF6.xdripswiftt1li23`
5. 确保启用以下功能：
   - ✅ **App Groups**
   - ✅ **HealthKit**
   - ✅ **Near Field Communication Tag Reading**

#### 2.2 扩展 Bundle ID
为每个扩展创建对应的 Bundle ID：

1. **Widget Extension**
   - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
   - 功能: **App Groups**

2. **Watch App**
   - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
   - 功能: **App Groups**

3. **Watch Complication Extension**
   - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`
   - 功能: **App Groups**

4. **Notification Context Extension**
   - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`
   - 功能: **App Groups**

### 3. 配置 App Groups

1. 在 **"Identifiers"** 中选择 **"App Groups"**
2. 创建新的 App Group：
   - **Identifier**: `group.com.7RV2Y67HF6.loopkit.LoopGroup`
   - **Description**: xDrip App Group for data sharing

3. 将以下 Bundle ID 添加到这个 App Group：
   - `com.7RV2Y67HF6.xdripswiftt1li23`
   - `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
   - `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
   - `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`
   - `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`

### 4. 创建 Provisioning Profiles

#### 4.1 开发配置文件
为每个 Bundle ID 创建开发配置文件：
- 选择对应的 App ID
- 选择开发证书
- 选择测试设备

#### 4.2 分发配置文件
为每个 Bundle ID 创建分发配置文件：
- 选择对应的 App ID
- 选择分发证书
- 选择 App Store 分发

### 5. 验证配置

运行以下命令验证配置：
```bash
# 检查 Bundle ID 是否存在
xcrun altool --list-apps -u "your-apple-id@example.com" -p "your-app-specific-password"

# 检查 Provisioning Profiles
security find-identity -v -p codesigning
```

## 🚨 常见问题

### 问题 1: "No Account for Team"
**原因**: Xcode 无法找到对应的开发者账户
**解决**: 确保 API Key 有正确的权限，并且 Team ID 正确

### 问题 2: "No profiles found"
**原因**: 没有为 Bundle ID 创建 Provisioning Profile
**解决**: 按照上述步骤创建对应的配置文件

### 问题 3: "requires a provisioning profile with the App Groups feature"
**原因**: Bundle ID 没有启用 App Groups 功能
**解决**: 在 Apple Developer Portal 中为 Bundle ID 启用 App Groups

## 📋 检查清单

- [ ] 主应用 Bundle ID 已创建并启用所有必要功能
- [ ] 所有扩展 Bundle ID 已创建并启用 App Groups
- [ ] App Group 已创建并包含所有 Bundle ID
- [ ] 开发 Provisioning Profiles 已创建
- [ ] 分发 Provisioning Profiles 已创建
- [ ] API Key 有正确的权限
- [ ] GitHub Secrets 已正确配置

## 🔗 相关链接

- [Apple Developer Portal](https://developer.apple.com/account)
- [App Store Connect](https://appstoreconnect.apple.com)
- [App Groups 文档](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
- [HealthKit 文档](https://developer.apple.com/documentation/healthkit)
- [NFC 文档](https://developer.apple.com/documentation/corenfc)
