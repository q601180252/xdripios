# Apple Developer Portal 快速配置清单 ✅

## 🎯 目标
为 xDrip iOS 应用配置 Apple Developer Portal，解决 Provisioning Profile 错误。

---

## 📋 配置清单

### 准备工作
- [ ] 登录 [Apple Developer Portal](https://developer.apple.com/account)
- [ ] 确认您的 Apple ID 有 Developer 权限
- [ ] Team ID 确认：`7RV2Y67HF6`

---

## 第 1 步：创建 App Group（约 2 分钟）

### 1.1 进入 App Groups 页面
```
Apple Developer Portal → Certificates, Identifiers & Profiles 
→ Identifiers → 点击 "+" → 选择 "App Groups"
```

### 1.2 填写信息
```
Description: xDrip Shared Data Group
Identifier: group.com.7RV2Y67HF6.loopkit.LoopGroup
```

### 1.3 点击 "Continue" → "Register"

✅ **完成标记**：App Group 已创建

---

## 第 2 步：创建主应用 Bundle ID（约 3 分钟）

### 2.1 创建 Bundle ID
```
Identifiers → 点击 "+" → 选择 "App IDs" → 选择 "App"
```

### 2.2 填写基本信息
```
Description: xDrip Main App
Bundle ID: Explicit
Bundle ID 值: com.7RV2Y67HF6.xdripswiftt1li23
```

### 2.3 启用功能（Capabilities）
勾选以下 3 项：
- [ ] ✅ **App Groups**
- [ ] ✅ **HealthKit**
- [ ] ✅ **Near Field Communication Tag Reading**

### 2.4 配置 App Groups
点击 "App Groups" 右侧的 "Configure"：
- [ ] 选择 `group.com.7RV2Y67HF6.loopkit.LoopGroup`
- [ ] 点击 "Continue" → "Save"

### 2.5 完成创建
点击 "Continue" → "Register"

✅ **完成标记**：主应用 Bundle ID 已创建

---

## 第 3 步：创建 Widget Extension Bundle ID（约 2 分钟）

### 3.1 创建 Bundle ID
```
Identifiers → 点击 "+" → 选择 "App IDs" → 选择 "App"
```

### 3.2 填写信息
```
Description: xDrip Widget Extension
Bundle ID: Explicit
Bundle ID 值: com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget
```

### 3.3 启用功能
- [ ] ✅ **App Groups**
  - 配置：选择 `group.com.7RV2Y67HF6.loopkit.LoopGroup`

### 3.4 完成创建
点击 "Continue" → "Register"

✅ **完成标记**：Widget Bundle ID 已创建

---

## 第 4 步：创建 Watch App Bundle ID（约 2 分钟）

### 4.1 创建 Bundle ID
```
Identifiers → 点击 "+" → 选择 "App IDs" → 选择 "App"
```

### 4.2 填写信息
```
Description: xDrip Watch App
Bundle ID: Explicit
Bundle ID 值: com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp
```

### 4.3 启用功能
- [ ] ✅ **App Groups**
  - 配置：选择 `group.com.7RV2Y67HF6.loopkit.LoopGroup`

### 4.4 完成创建
点击 "Continue" → "Register"

✅ **完成标记**：Watch App Bundle ID 已创建

---

## 第 5 步：创建 Watch Complication Bundle ID（约 2 分钟）

### 5.1 创建 Bundle ID
```
Identifiers → 点击 "+" → 选择 "App IDs" → 选择 "App"
```

### 5.2 填写信息
```
Description: xDrip Watch Complication
Bundle ID: Explicit
Bundle ID 值: com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication
```

### 5.3 启用功能
- [ ] ✅ **App Groups**
  - 配置：选择 `group.com.7RV2Y67HF6.loopkit.LoopGroup`

### 5.4 完成创建
点击 "Continue" → "Register"

✅ **完成标记**：Watch Complication Bundle ID 已创建

---

## 第 6 步：创建 Notification Extension Bundle ID（约 2 分钟）

### 6.1 创建 Bundle ID
```
Identifiers → 点击 "+" → 选择 "App IDs" → 选择 "App"
```

### 6.2 填写信息
```
Description: xDrip Notification Extension
Bundle ID: Explicit
Bundle ID 值: com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension
```

### 6.3 启用功能
- [ ] ✅ **App Groups**
  - 配置：选择 `group.com.7RV2Y67HF6.loopkit.LoopGroup`

### 6.4 完成创建
点击 "Continue" → "Register"

✅ **完成标记**：Notification Extension Bundle ID 已创建

---

## 第 7 步：创建 Provisioning Profiles（约 10 分钟）

### 为什么需要？
GitHub Actions 需要这些 Profile 来签名应用。

### 7.1 为主应用创建 Profile

#### 开发 Profile（Development）
```
Profiles → 点击 "+" → 选择 "iOS App Development"
```

1. **App ID**: 选择 `xDrip Main App (com.7RV2Y67HF6.xdripswiftt1li23)`
2. **Certificates**: 选择您的开发证书（如果没有，先创建一个）
3. **Devices**: 选择测试设备（如果需要）
4. **Profile Name**: `xDrip Main App Development`
5. 点击 "Generate" → 下载（可选，GitHub Actions 会自动下载）

#### 分发 Profile（App Store）
```
Profiles → 点击 "+" → 选择 "App Store"
```

1. **App ID**: 选择 `xDrip Main App (com.7RV2Y67HF6.xdripswiftt1li23)`
2. **Certificates**: 选择您的分发证书（如果没有，先创建一个）
3. **Profile Name**: `xDrip Main App AppStore`
4. 点击 "Generate" → 下载（可选）

✅ **完成标记**：主应用 Profiles 已创建

---

### 7.2 为 Widget 创建 Profile

重复上述步骤，但使用：
- **App ID**: `xDrip Widget Extension (com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget)`
- **Profile Name Development**: `xDrip Widget Development`
- **Profile Name App Store**: `xDrip Widget AppStore`

✅ **完成标记**：Widget Profiles 已创建

---

### 7.3 为 Watch App 创建 Profile

重复上述步骤，但使用：
- **App ID**: `xDrip Watch App (com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp)`
- **Profile Name Development**: `xDrip Watch App Development`
- **Profile Name App Store**: `xDrip Watch App AppStore`

✅ **完成标记**：Watch App Profiles 已创建

---

### 7.4 为 Watch Complication 创建 Profile

重复上述步骤，但使用：
- **App ID**: `xDrip Watch Complication (com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication)`
- **Profile Name Development**: `xDrip Watch Complication Development`
- **Profile Name App Store**: `xDrip Watch Complication AppStore`

✅ **完成标记**：Watch Complication Profiles 已创建

---

### 7.5 为 Notification Extension 创建 Profile

重复上述步骤，但使用：
- **App ID**: `xDrip Notification Extension (com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension)`
- **Profile Name Development**: `xDrip Notification Development`
- **Profile Name App Store**: `xDrip Notification AppStore`

✅ **完成标记**：Notification Extension Profiles 已创建

---

## 🎉 配置完成！

### 最终检查清单

- [ ] ✅ 1 个 App Group 已创建
- [ ] ✅ 5 个 Bundle ID 已创建
  - [ ] 主应用（带 App Groups, HealthKit, NFC）
  - [ ] Widget Extension（带 App Groups）
  - [ ] Watch App（带 App Groups）
  - [ ] Watch Complication（带 App Groups）
  - [ ] Notification Extension（带 App Groups）
- [ ] ✅ 10 个 Provisioning Profiles 已创建
  - [ ] 每个 Bundle ID 各 2 个（Development + App Store）

---

## 🚀 下一步

### 1. 推送代码到 GitHub
```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios
git push origin main
```

### 2. 运行验证 Action（确认配置）
```
GitHub → Actions → Verify Apple Developer Configuration → Run workflow
选择 check_type: all
```

### 3. 查看验证结果
如果所有检查都通过，说明配置正确！

### 4. 运行构建 Action
```
GitHub → Actions → Build and Upload IPA → Run workflow
```

---

## ⚠️ 常见问题

### Q1: 没有开发证书怎么办？
**A**: 
```
Certificates → 点击 "+" → 选择 "iOS Development" 
→ 按照向导创建 → 下载并安装到 Keychain
```

### Q2: 没有分发证书怎么办？
**A**: 
```
Certificates → 点击 "+" → 选择 "iOS Distribution" 
→ 按照向导创建 → 下载并安装到 Keychain
```

### Q3: 我的账户类型不支持某些功能？
**A**: 确认您的 Apple Developer Program 账户类型：
- **个人/公司账户** - 支持所有功能 ✅
- **免费账户** - 功能受限，可能无法创建某些 Profile ❌

### Q4: 创建 Profile 时提示需要设备？
**A**: 
- **Development Profile** - 需要选择测试设备
- **App Store Profile** - 不需要设备
- 如果是测试，至少添加一个设备到账户中

### Q5: 配置完成后还是失败？
**A**: 运行验证 Action 查看详细错误：
```bash
gh workflow run verify-apple-config.yml -f check_type=all
```

---

## 📞 需要帮助？

如果配置过程中遇到问题：

1. **运行验证 Action** - 获取详细的错误信息
2. **查看日志** - GitHub Actions 日志中有详细错误
3. **检查文档** - `APPLE_CONFIG_README.md` 有完整说明

---

## 💡 提示

### 加速配置的技巧
1. **准备好证书** - 提前创建开发和分发证书
2. **批量操作** - 连续创建所有 Bundle ID，再统一创建 Profiles
3. **记录信息** - 记下每个 Bundle ID 和 Profile 的名称

### 建议的操作顺序
```
1. 创建证书（如果还没有）
2. 创建 App Group
3. 批量创建 5 个 Bundle ID
4. 批量创建 10 个 Provisioning Profiles
5. 推送代码
6. 运行验证
7. 运行构建
```

---

## 🎯 预计时间

- **首次配置**: 30-45 分钟
- **有经验**: 15-20 分钟
- **批量操作**: 10-15 分钟

---

**准备好了吗？开始配置吧！** 🚀

每完成一个步骤，就勾选对应的复选框。祝您配置顺利！✨

