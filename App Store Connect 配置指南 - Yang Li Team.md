# App Store Connect 配置指南 - Yang Li Team 🚀

## ⚠️ 重要说明

您刚刚切换到了新的 Team: **Yang Li (HHZN32E89C)**

新的 Bundle ID 前缀: **com.HHZN32E89C**

要上传到 TestFlight，需要先在 **Apple Developer Portal** 和 **App Store Connect** 中创建相应的配置。

---

## 📋 需要创建的配置

### 1️⃣ Apple Developer Portal 配置

登录 [Apple Developer](https://developer.apple.com/account)

#### A. 创建 App Group

**路径**: Certificates, Identifiers & Profiles → Identifiers → App Groups

```
Identifier: group.com.HHZN32E89C.loopkit.LoopGroup
Description: xDrip App Group
```

#### B. 创建 5 个 App IDs

**路径**: Certificates, Identifiers & Profiles → Identifiers → App IDs

##### 1. 主应用 App ID
```
Bundle ID: com.HHZN32E89C.xdripswiftt1li23
Description: xDrip Main App
Platform: iOS
Capabilities:
  ✅ App Groups
  ✅ HealthKit
  ✅ Near Field Communication Tag Reading
```

**配置 App Groups**:
- Edit → App Groups → Configure
- 选择 `group.com.HHZN32E89C.loopkit.LoopGroup`
- Save

##### 2. Widget Extension App ID
```
Bundle ID: com.HHZN32E89C.xdripswiftt1li23.xDripWidget
Description: xDrip Widget Extension
Platform: iOS
Capabilities:
  ✅ App Groups
```

**配置 App Groups**:
- Edit → App Groups → Configure
- 选择 `group.com.HHZN32E89C.loopkit.LoopGroup`
- Save

##### 3. Watch App ID
```
Bundle ID: com.HHZN32E89C.xdripswiftt1li23.watchkitapp
Description: xDrip Watch App
Platform: watchOS
Capabilities:
  ✅ App Groups
```

**配置 App Groups**:
- Edit → App Groups → Configure
- 选择 `group.com.HHZN32E89C.loopkit.LoopGroup`
- Save

##### 4. Watch Complication App ID
```
Bundle ID: com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication
Description: xDrip Watch Complication
Platform: watchOS
Capabilities:
  ✅ App Groups
```

**配置 App Groups**:
- Edit → App Groups → Configure
- 选择 `group.com.HHZN32E89C.loopkit.LoopGroup`
- Save

##### 5. Notification Extension App ID
```
Bundle ID: com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension
Description: xDrip Notification Extension
Platform: iOS
Capabilities:
  ✅ App Groups
```

**配置 App Groups**:
- Edit → App Groups → Configure
- 选择 `group.com.HHZN32E89C.loopkit.LoopGroup`
- Save

---

### 2️⃣ App Store Connect 配置

登录 [App Store Connect](https://appstoreconnect.apple.com)

#### A. 创建新的 App

**路径**: My Apps → "+" 按钮 → New App

```
Platforms: ✅ iOS

Name: xDrip
  (或您喜欢的名字，这是在 App Store 上显示的名字)

Primary Language: English (U.S.)
  (或您的主要语言)

Bundle ID: com.HHZN32E89C.xdripswiftt1li23
  (从下拉菜单中选择，如果没有，说明 Developer Portal 中还没创建)

SKU: xdrip-yangli
  (唯一标识符，可以自定义)

User Access: Full Access
```

点击 **Create**

#### B. 填写 App 信息

创建 App 后，需要填写以下信息才能上传构建版本：

##### 1. App Information
```
Name: xDrip
Subtitle: (可选) 血糖监测应用
Primary Category: Medical
Secondary Category: (可选) Health & Fitness
```

##### 2. Pricing and Availability
```
Price: Free (或您设定的价格)
Availability: 选择发布的国家/地区
```

##### 3. App Privacy (隐私政策)
```
Privacy Policy URL: (必填，如果发布需要)
例如: https://yourdomain.com/privacy

或者先设置为: https://github.com/yourusername/xdrip/blob/main/PRIVACY.md
```

##### 4. Build (上传后自动出现)
上传构建版本后，在这里选择要提交审核的版本

---

## 🔑 创建 Provisioning Profiles（可选，用于 GitHub Actions）

### 方法 A: 自动签名（推荐用于本地开发）

在 Xcode 中：
- 选择 Target
- Signing & Capabilities
- Team: Yang Li (HHZN32E89C)
- ✅ Automatically manage signing

Xcode 会自动创建和管理 Provisioning Profiles

### 方法 B: 手动签名（推荐用于 CI/CD）

**路径**: Apple Developer → Certificates, Identifiers & Profiles → Profiles

为每个 Bundle ID 创建两种 Profile：

#### 1. iOS App Development Profile
```
Type: iOS App Development
App ID: 选择对应的 Bundle ID
Certificates: 选择您的开发证书
Devices: 选择测试设备
Name: xDrip Dev (或相应的 Extension Dev)
```

#### 2. App Store Profile
```
Type: App Store
App ID: 选择对应的 Bundle ID
Certificates: 选择您的分发证书
Name: xDrip AppStore (或相应的 Extension AppStore)
```

**需要创建的 Profiles (每个都需要 Dev 和 AppStore 两个版本)**:
1. com.HHZN32E89C.xdripswiftt1li23
2. com.HHZN32E89C.xdripswiftt1li23.xDripWidget
3. com.HHZN32E89C.xdripswiftt1li23.watchkitapp
4. com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication
5. com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension

总共: **10 个 Profiles** (5 个 Dev + 5 个 AppStore)

---

## 🚀 上传到 TestFlight 的步骤

### 前提条件检查

确认以下都已完成：

- [ ] 在 Apple Developer Portal 创建了 App Group
- [ ] 在 Apple Developer Portal 创建了 5 个 App IDs
- [ ] 为所有 App IDs 配置了 App Groups
- [ ] 在 App Store Connect 创建了 App 记录
- [ ] 填写了基本的 App 信息（Name, Category, Privacy Policy 等）

### 在 Xcode 中上传

1. **选择 Generic iOS Device**
   ```
   顶部工具栏 → 选择 "Any iOS Device (arm64)"
   ```

2. **Archive**
   ```
   Product → Archive
   等待 Archive 完成
   ```

3. **Organizer 窗口会自动打开**
   ```
   选择刚创建的 Archive
   点击 "Distribute App"
   ```

4. **Distribution 方法**
   ```
   选择: App Store Connect
   点击 "Next"
   ```

5. **Destination**
   ```
   选择: Upload
   点击 "Next"
   ```

6. **Distribution options**
   ```
   ✅ Upload your app's symbols
   ✅ Manage Version and Build Number
   点击 "Next"
   ```

7. **Signing**
   ```
   选择: Automatically manage signing
   或者: Manually manage signing (如果您手动创建了 Profiles)
   点击 "Next"
   ```

8. **Review**
   ```
   检查所有信息
   点击 "Upload"
   ```

9. **等待上传完成**
   ```
   上传完成后，会显示 "Upload Successful"
   ```

### 在 App Store Connect 中验证

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. My Apps → xDrip
3. TestFlight 标签
4. 等待 5-15 分钟，新的构建版本会出现在列表中
5. 填写 "What to Test" 信息
6. 可以邀请内部测试员或外部测试员

---

## ⚠️ 常见问题

### Q1: 下拉菜单中找不到 Bundle ID
**A**: 需要先在 Apple Developer Portal 创建对应的 App ID

### Q2: Upload 时提示权限错误
**A**: 
- 检查您的 Apple Developer 账号角色（需要是 Admin 或 App Manager）
- 确认您的开发者计划（Apple Developer Program）是有效的
- 需要支付年费：$99/年

### Q3: 上传成功但在 TestFlight 中看不到
**A**: 
- 等待 5-15 分钟，Apple 需要处理您的构建
- 检查邮件，看是否有任何问题通知
- 刷新 App Store Connect 页面

### Q4: Missing Compliance 错误
**A**: 
- 在 App Store Connect 中选择构建版本
- 回答加密相关问题
- 通常选择 "No" 如果您没有使用自定义加密

---

## 💡 推荐的工作流程

### 本地开发测试
```
1. Xcode → 选择模拟器或真机
2. Automatically manage signing
3. Product → Run (⌘R)
```

### 上传到 TestFlight
```
1. 完成 Apple Developer Portal 配置
2. 完成 App Store Connect 配置
3. Xcode → Generic iOS Device
4. Product → Archive
5. Distribute → App Store Connect → Upload
```

### GitHub Actions CI/CD（高级）
```
1. 手动创建所有 Provisioning Profiles
2. 导出所有证书和 Profiles
3. 配置 GitHub Secrets
4. 创建 GitHub Actions workflow
5. 自动构建和上传
```

---

## 📞 需要帮助？

如果遇到任何问题：

1. **检查 Apple Developer 账号状态**
   - 登录 [Apple Developer](https://developer.apple.com/account)
   - 检查会员资格是否有效

2. **查看详细错误信息**
   - Xcode → Window → Organizer
   - 查看 Archive 日志

3. **Apple 支持文档**
   - [Distributing Your App](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
   - [TestFlight](https://developer.apple.com/testflight/)

---

## 🎯 快速检查清单

上传 TestFlight 前确认：

- [ ] Apple Developer Program 会员资格有效（$99/年）
- [ ] 创建了 App Group: `group.com.HHZN32E89C.loopkit.LoopGroup`
- [ ] 创建了 5 个 App IDs（主应用 + 4 个扩展）
- [ ] 为所有 App IDs 配置了 App Groups
- [ ] 在 App Store Connect 创建了 App 记录
- [ ] 填写了 App 基本信息（Name, Category）
- [ ] Xcode 中 Team 设置为 Yang Li (HHZN32E89C)
- [ ] 选择了 Generic iOS Device (arm64)
- [ ] Archive 成功创建

全部完成后，即可上传到 TestFlight！🎉

---

**如果您还没有 Apple Developer Program 会员资格，需要先注册并支付 $99/年的费用。** 💳

**有任何问题请告诉我！** 😊

