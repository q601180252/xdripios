# GitHub Actions IPA 构建配置清单 ✅

## 🎯 目标
让 GitHub Actions 自动构建 IPA 文件

## ⏱️ 预计时间
**40-50 分钟**

---

## 第一步：创建 Bundle IDs（10 分钟）

### 访问链接
https://developer.apple.com/account/resources/identifiers/list

### 操作步骤

点击左上角 **"+"** 按钮，选择 **"App IDs"**，然后：

#### 1️⃣ 主应用
```
Description: xDrip Main App
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23
Capabilities:
  ✅ App Groups → 配置 → 选择或创建 group.com.7RV2Y67HF6.loopkit.LoopGroup
  ✅ HealthKit → 启用
  ✅ NFC Tag Reading → 启用
```
**点击 "Continue" → "Register"**

#### 2️⃣ Widget 扩展
```
Description: xDrip Widget
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget
Capabilities:
  ✅ App Groups → 配置 → 选择 group.com.7RV2Y67HF6.loopkit.LoopGroup
```
**点击 "Continue" → "Register"**

#### 3️⃣ Watch App
```
Description: xDrip Watch App
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp
Capabilities:
  ✅ App Groups → 配置 → 选择 group.com.7RV2Y67HF6.loopkit.LoopGroup
```
**点击 "Continue" → "Register"**

#### 4️⃣ Watch Complication
```
Description: xDrip Watch Complication
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication
Capabilities:
  ✅ App Groups → 配置 → 选择 group.com.7RV2Y67HF6.loopkit.LoopGroup
```
**点击 "Continue" → "Register"**

#### 5️⃣ 通知扩展
```
Description: xDrip Notification Extension
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension
Capabilities:
  ✅ App Groups → 配置 → 选择 group.com.7RV2Y67HF6.loopkit.LoopGroup
```
**点击 "Continue" → "Register"**

---

## 第二步：确认 App Group（2 分钟）

### 访问链接
https://developer.apple.com/account/resources/identifiers/list/applicationGroup

### 检查
- ✅ 如果已存在 `group.com.7RV2Y67HF6.loopkit.LoopGroup`，跳过
- ❌ 如果不存在，点击 "+" 创建：
  - **Description**: xDrip App Group
  - **Identifier**: group.com.7RV2Y67HF6.loopkit.LoopGroup

---

## 第三步：创建 Provisioning Profiles（30 分钟）

### 访问链接
https://developer.apple.com/account/resources/profiles/list

### 需要创建 10 个 Profiles（每个 Bundle ID 各需要 2 个）

#### 类型说明
1. **iOS App Development** = 开发环境（用于测试）
2. **App Store** = 生产环境（用于发布）

---

### 📱 主应用 Profiles

#### 开发版
1. 点击 **"+"**
2. 选择 **"iOS App Development"** → Continue
3. **App ID**: 选择 `com.7RV2Y67HF6.xdripswiftt1li23`
4. **Select Certificates**: 选择您的证书
5. **Select Devices**: 全选（或选择测试设备）
6. **Provisioning Profile Name**: `xDrip Main App Development`
7. **Generate** → **Download**

#### 生产版
1. 点击 **"+"**
2. 选择 **"App Store"** → Continue
3. **App ID**: 选择 `com.7RV2Y67HF6.xdripswiftt1li23`
4. **Select Certificates**: 选择您的分发证书
5. **Provisioning Profile Name**: `xDrip Main App App Store`
6. **Generate** → **Download**

---

### 🎨 Widget Profiles

#### 开发版
- **Type**: iOS App Development
- **App ID**: `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
- **Name**: `xDrip Widget Development`

#### 生产版
- **Type**: App Store
- **App ID**: `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
- **Name**: `xDrip Widget App Store`

---

### ⌚ Watch App Profiles

#### 开发版
- **Type**: iOS App Development
- **App ID**: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
- **Name**: `xDrip Watch App Development`

#### 生产版
- **Type**: App Store
- **App ID**: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
- **Name**: `xDrip Watch App App Store`

---

### 🧩 Watch Complication Profiles

#### 开发版
- **Type**: iOS App Development
- **App ID**: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`
- **Name**: `xDrip Watch Complication Development`

#### 生产版
- **Type**: App Store
- **App ID**: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`
- **Name**: `xDrip Watch Complication App Store`

---

### 🔔 Notification Extension Profiles

#### 开发版
- **Type**: iOS App Development
- **App ID**: `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`
- **Name**: `xDrip Notification Extension Development`

#### 生产版
- **Type**: App Store
- **App ID**: `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`
- **Name**: `xDrip Notification Extension App Store`

---

## 第四步：验证 API Key（3 分钟）

### 检查 API Key 是否有正确权限

1. 访问：https://appstoreconnect.apple.com/access/api
2. 找到您的 API Key
3. 确认 **Access** 是 **Admin** 或 **App Manager**

### ⚠️ 如果不是，需要：
1. 点击 API Key
2. 修改 **Access** 为 **App Manager**
3. 保存

---

## 第五步：检查 GitHub Secrets（2 分钟）

### 访问
https://github.com/YOUR_USERNAME/xdripios/settings/secrets/actions

### 确认以下 Secrets 已配置

1. ✅ **APPSTORE_API_KEY_ID**
   - 值：您的 Key ID（例如：ABC123DEFG）

2. ✅ **APPSTORE_ISSUER_ID**
   - 值：您的 Issuer ID（UUID 格式）

3. ✅ **APPSTORE_API_PRIVATE_KEY**
   - 值：完整的私钥内容（包括 BEGIN 和 END 行）
   ```
   -----BEGIN PRIVATE KEY-----
   MIGTAgEAMBMGByqGSM49AgEGCCqGSM49Aw...
   -----END PRIVATE KEY-----
   ```

---

## 第六步：运行 GitHub Actions（5 分钟）

### 步骤 1: 验证配置（可选但推荐）

1. 访问：https://github.com/YOUR_USERNAME/xdripios/actions
2. 选择 **"Verify Apple Developer Configuration"**
3. 点击 **"Run workflow"**
4. **Check type**: 选择 `all`
5. 点击绿色 **"Run workflow"** 按钮
6. 等待完成（约 1-2 分钟）
7. 查看结果，确保所有检查通过 ✅

### 步骤 2: 构建 IPA

1. 访问：https://github.com/YOUR_USERNAME/xdripios/actions
2. 选择 **"Build IPA"**
3. 点击 **"Run workflow"**
4. 点击绿色 **"Run workflow"** 按钮
5. 等待完成（约 10-15 分钟）
6. 构建成功后，下载 IPA 文件

---

## ✅ 完成检查清单

### Apple Developer Portal
- [ ] 创建了 5 个 Bundle ID
- [ ] 所有 Bundle ID 都配置了 App Groups
- [ ] 主应用配置了 HealthKit 和 NFC Tag Reading
- [ ] 确认或创建了 App Group
- [ ] 创建了 10 个 Provisioning Profiles（每个 Bundle ID 各 2 个）
- [ ] 下载了所有 Provisioning Profiles（可选，GitHub Actions 会自动获取）

### API Key
- [ ] API Key 有 Admin 或 App Manager 权限

### GitHub Secrets
- [ ] APPSTORE_API_KEY_ID 已配置
- [ ] APPSTORE_ISSUER_ID 已配置
- [ ] APPSTORE_API_PRIVATE_KEY 已配置（完整私钥）

### GitHub Actions
- [ ] 运行了验证 Action（可选）
- [ ] 运行了构建 Action
- [ ] 构建成功
- [ ] 下载了 IPA 文件

---

## 🎉 成功标志

当您看到：
```
✅ Archive succeeded
✅ Export succeeded
✅ IPA file created: build/xdrip.ipa
```

说明构建成功！

---

## ⚠️ 常见问题

### Q: 创建 Bundle ID 时没有看到 App Groups 选项？
**A**: 向下滚动，在 "Capabilities" 部分可以找到。

### Q: 创建 Provisioning Profile 时提示没有证书？
**A**: 您需要先创建证书：
1. 访问：https://developer.apple.com/account/resources/certificates/list
2. 创建 "iOS Development" 和 "iOS Distribution" 证书

### Q: GitHub Actions 构建失败，提示找不到 Provisioning Profile？
**A**: 
1. 确认所有 10 个 Profiles 都已创建
2. 确认 API Key 有正确权限
3. 重新运行构建

### Q: 构建成功了，但 IPA 无法安装到设备？
**A**: 
- Development Profile：只能安装到添加的测试设备
- App Store Profile：需要通过 TestFlight 或 App Store 分发

---

## 📞 需要帮助？

如果遇到问题：
1. 查看 GitHub Actions 日志中的具体错误信息
2. 运行验证 Action 检查配置
3. 参考详细文档：`GitHub Actions 构建失败解决方案.md`

---

## 🚀 现在开始配置吧！

预计 **40-50 分钟** 即可完成！

**祝您配置顺利！** 🎊

