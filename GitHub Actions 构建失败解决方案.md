# GitHub Actions 构建失败解决方案 🚀

## 📊 当前状态

- ✅ **本地构建**：成功
- ❌ **GitHub Actions 构建**：失败
- **失败原因**：缺少 Provisioning Profiles

---

## 🎯 必须完成的配置

### 第一步：在 Apple Developer Portal 创建 Bundle IDs

访问：https://developer.apple.com/account/resources/identifiers/list

需要创建 **5 个** Bundle ID：

#### 1. 主应用
```
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23
描述: xDrip Main App
功能:
  ✅ App Groups (group.com.7RV2Y67HF6.loopkit.LoopGroup)
  ✅ HealthKit
  ✅ NFC Tag Reading
```

#### 2. Widget 扩展
```
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget
描述: xDrip Widget Extension
功能:
  ✅ App Groups (group.com.7RV2Y67HF6.loopkit.LoopGroup)
```

#### 3. Watch App
```
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp
描述: xDrip Watch App
功能:
  ✅ App Groups (group.com.7RV2Y67HF6.loopkit.LoopGroup)
```

#### 4. Watch Complication
```
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication
描述: xDrip Watch Complication
功能:
  ✅ App Groups (group.com.7RV2Y67HF6.loopkit.LoopGroup)
```

#### 5. 通知扩展
```
Bundle ID: com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension
描述: xDrip Notification Extension
功能:
  ✅ App Groups (group.com.7RV2Y67HF6.loopkit.LoopGroup)
```

---

### 第二步：创建 App Group

访问：https://developer.apple.com/account/resources/identifiers/list/applicationGroup

```
App Group ID: group.com.7RV2Y67HF6.loopkit.LoopGroup
描述: xDrip App Group for data sharing
```

⚠️ **重要**：创建后，回到每个 Bundle ID，在 App Groups 功能中选择这个 App Group。

---

### 第三步：创建 Provisioning Profiles

访问：https://developer.apple.com/account/resources/profiles/list

需要为**每个 Bundle ID** 创建 **2 种** Provisioning Profile：

#### 开发环境（Development）
用于测试和调试

#### 生产环境（App Store）
用于发布到 App Store

#### 创建步骤（以主应用为例）

1. **点击 "+"**
2. **选择类型**：
   - Development → iOS App Development
   - 或 Distribution → App Store
3. **选择 App ID**：
   - com.7RV2Y67HF6.xdripswiftt1li23
4. **选择证书**：
   - 选择您的开发者证书
5. **选择设备**（仅 Development）：
   - 选择测试设备（可选所有）
6. **命名**：
   - `xDrip Main App Development`
   - 或 `xDrip Main App App Store`
7. **生成并下载**

#### 需要创建的所有 Profiles

##### Development Profiles（开发）
1. ✅ xDrip Main App Development
2. ✅ xDrip Widget Development
3. ✅ xDrip Watch App Development
4. ✅ xDrip Watch Complication Development
5. ✅ xDrip Notification Extension Development

##### App Store Profiles（生产）
1. ✅ xDrip Main App App Store
2. ✅ xDrip Widget App Store
3. ✅ xDrip Watch App App Store
4. ✅ xDrip Watch Complication App Store
5. ✅ xDrip Notification Extension App Store

**总共：10 个 Provisioning Profiles**

---

### 第四步：验证 API Key 权限

您的 App Store Connect API Key 需要以下权限：

- ✅ **Admin** 或 **App Manager** 角色
- ✅ 可以访问 Provisioning Profiles
- ✅ 可以访问 Certificates

#### 验证方法

使用 GitHub Actions 验证工具：

1. 访问：`https://github.com/YOUR_USERNAME/xdripios/actions/workflows/verify-apple-config.yml`
2. 点击 **Run workflow**
3. 选择检查类型：
   - `api_key`：验证 API Key 权限
   - `bundle_ids`：验证 Bundle ID 是否创建
   - `provisioning_profiles`：验证 Provisioning Profiles
   - `all`：验证所有配置

---

## 🛠️ 配置完成后

### 1️⃣ 运行验证 Action

```
GitHub → Actions → Verify Apple Developer Configuration → Run workflow
```

选择 `all` 检查所有配置。

### 2️⃣ 如果验证通过，运行构建 Action

```
GitHub → Actions → Build IPA → Run workflow
```

### 3️⃣ 查看构建结果

- ✅ 成功：下载 IPA 文件
- ❌ 失败：查看日志，根据错误信息调整

---

## 📋 快速配置检查清单

### Apple Developer Portal

- [ ] 创建了 5 个 Bundle ID
- [ ] 所有 Bundle ID 都启用了 App Groups
- [ ] 主应用启用了 HealthKit 和 NFC Tag Reading
- [ ] 创建了 App Group (group.com.7RV2Y67HF6.loopkit.LoopGroup)
- [ ] 所有 Bundle ID 都关联了 App Group
- [ ] 创建了 10 个 Provisioning Profiles（5个开发 + 5个生产）

### GitHub Secrets

- [ ] APPSTORE_API_KEY_ID 已配置
- [ ] APPSTORE_ISSUER_ID 已配置
- [ ] APPSTORE_API_PRIVATE_KEY 已配置（完整私钥内容）

### API Key 权限

- [ ] API Key 有 Admin 或 App Manager 角色
- [ ] API Key 可以访问 Provisioning Profiles
- [ ] API Key 可以访问 Certificates

---

## ⚠️ 常见问题

### Q1: 为什么需要这么多 Provisioning Profiles？

**A**: 因为您的应用包含：
- 1 个主应用
- 1 个 Widget 扩展
- 1 个 Watch App
- 1 个 Watch Complication
- 1 个通知扩展

每个都需要独立的 Provisioning Profile。

### Q2: Development 和 App Store Profiles 有什么区别？

**A**:
- **Development**: 用于开发和测试，需要指定测试设备
- **App Store**: 用于发布到 App Store，不需要指定设备

### Q3: App Group 是什么？为什么需要？

**A**:
- **App Group** 允许主应用和扩展之间共享数据
- xDrip 需要在主应用、Widget、Watch App 之间共享血糖数据
- 所有扩展都必须配置相同的 App Group

### Q4: 为什么自动签名也失败了？

**A**:
- GitHub Actions 环境中没有 Apple ID 账号
- 自动签名需要在 Xcode 中登录 Apple ID
- GitHub Actions 只能使用 API Key，不能使用 Apple ID
- 所以 GitHub Actions 只能使用手动签名 + Provisioning Profiles

### Q5: 配置完成后还是失败怎么办？

**A**:
1. 运行验证 Action 检查配置
2. 检查 API Key 权限
3. 确认所有 Bundle ID 的 capabilities 配置正确
4. 确认所有 Provisioning Profiles 包含了正确的 capabilities

---

## 📚 相关文档

- **`App Store Connect 配置指南.md`**: 详细的配置步骤
- **`Apple Developer Portal 快速配置清单.md`**: 快速参考
- **`配置流程可视化指南.md`**: 可视化流程图
- **`本地编译成功总结.md`**: 本地构建经验总结

---

## 🎯 预计完成时间

- **创建 Bundle IDs**: 10-15 分钟
- **创建 App Group**: 2 分钟
- **创建 Provisioning Profiles**: 20-30 分钟
- **验证配置**: 5 分钟

**总计：约 40-50 分钟**

---

## 🚀 下一步

1. **立即开始配置** Apple Developer Portal
2. **使用检查清单**确保不遗漏任何步骤
3. **运行验证 Action** 确认配置正确
4. **运行构建 Action** 生成 IPA

---

**祝您配置顺利！** 🎉

如果遇到任何问题，请查看详细文档或提问。

