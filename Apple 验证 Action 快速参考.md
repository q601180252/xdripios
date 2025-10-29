# Apple 验证 Action 快速参考 🚀

## 🎯 一句话说明
**独立的 GitHub Action，快速验证 Apple Developer Portal 配置，无需构建应用**

---

## ⚡ 快速开始

### GitHub 网页操作
```
1. GitHub → Actions → Verify Apple Developer Configuration
2. Run workflow → 选择检查类型 → Run workflow
3. 等待 2-5 分钟
4. 查看结果 + 下载报告
```

### 命令行操作
```bash
# 完整验证（推荐）
gh workflow run verify-apple-config.yml -f check_type=all

# 快速查看结果
gh run list --workflow=verify-apple-config.yml
```

---

## 🔍 检查类型选择

| 类型 | 用途 | 运行时间 | 适用场景 |
|------|------|----------|----------|
| `all` | 完整验证 | 3-5分钟 | 首次配置、构建失败排查 |
| `api_key` | API Key 验证 | 1分钟 | API Key 问题排查 |
| `bundle_ids` | Bundle ID 检查 | 1分钟 | 确认 Bundle ID 配置 |
| `provisioning_profiles` | Profile 测试 | 2分钟 | 配置 Profile 后验证 |
| `capabilities` | 功能权限检查 | 1分钟 | Entitlements 文件验证 |

---

## 📋 验证内容清单

### ✅ API Key 验证
- [x] API Key 文件是否正确创建
- [x] 能否连接 App Store Connect
- [x] 权限是否足够

### ✅ Bundle ID 检查
- [x] 主应用: `com.7RV2Y67HF6.xdripswiftt1li23`
- [x] Widget: `...xDripWidget`
- [x] Watch App: `...watchkitapp`
- [x] Watch Complication: `...xDripWatchComplication`
- [x] Notification Extension: `...xDripNotificationContextExtension`

### ✅ 功能权限验证
- [x] App Groups: `group.com.7RV2Y67HF6.loopkit.LoopGroup`
- [x] HealthKit
- [x] NFC Tag Reading

### ✅ Entitlements 文件
- [x] xdrip.entitlements
- [x] Widget Extension.entitlements
- [x] Watch App.entitlements

---

## 🎯 常见使用场景

### 场景 1: 首次配置 Apple Developer Portal
```bash
# 了解需要配置什么
gh workflow run verify-apple-config.yml -f check_type=all
```
**预期结果**: 显示所有需要配置的 Bundle ID 和功能

---

### 场景 2: 配置 Bundle ID 后验证
```bash
# 验证 Bundle ID 是否正确
gh workflow run verify-apple-config.yml -f check_type=bundle_ids
```
**预期结果**: 确认项目中的 Bundle ID 配置正确

---

### 场景 3: 构建失败后诊断
```bash
# 完整诊断
gh workflow run verify-apple-config.yml -f check_type=all
```
**预期结果**: 找出配置问题，查看详细报告

---

### 场景 4: API Key 问题排查
```bash
# 快速测试 API Key
gh workflow run verify-apple-config.yml -f check_type=api_key
```
**预期结果**: 确认 API Key 是否有效

---

## 📊 输出示例

### ✅ 成功输出
```
🔍 验证 API Key 权限...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ API Key 文件存在
✅ API Key 可以成功连接到 App Store Connect
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🆔 检查 Bundle ID 配置...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. 主应用: com.7RV2Y67HF6.xdripswiftt1li23
   🔧 必需功能: App Groups, HealthKit, NFC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### ❌ 失败输出
```
❌ API Key 文件不存在
⚠️  未找到 MAIN_APP_BUNDLE_IDENTIFIER
⚠️  xdrip.entitlements 不存在
```

---

## 🔗 相关文档链接

| 文档 | 说明 |
|------|------|
| [Apple 配置验证 Action 使用指南.md](./Apple%20配置验证%20Action%20使用指南.md) | 详细使用说明 |
| [App Store Connect 配置指南.md](./App%20Store%20Connect%20配置指南.md) | Portal 配置步骤 |
| [GitHub Actions IPA 构建指南.md](./GitHub%20Actions%20IPA%20构建指南.md) | 构建流程说明 |

---

## 💡 最佳实践

### 1️⃣ 配置前先验证
在 Apple Developer Portal 配置前，运行一次了解需求

### 2️⃣ 配置后再验证
每次修改配置后，运行验证确保正确

### 3️⃣ 构建前快速检查
提交 PR 或开始构建前，快速验证配置

### 4️⃣ 定期验证
每周运行一次，确保配置没有变化

### 5️⃣ 问题排查第一步
构建失败时，先运行验证找出配置问题

---

## ⚠️ 注意事项

| 项目 | 说明 |
|------|------|
| 🔒 需要 Secrets | 必须配置 3 个 GitHub Secrets |
| ⏱️ 运行时间 | 2-5 分钟（不构建应用） |
| 📋 仅验证 | 不会修改任何配置 |
| 💾 报告下载 | 保存 30 天 |
| 🔄 可重复运行 | 随时运行，无副作用 |

---

## 🆘 快速故障排除

### 问题: API Key 验证失败
```bash
1. 检查 GitHub Secrets 是否配置
2. 重新生成 API Key
3. 确认 API Key 权限（需要 Admin 或 Developer）
```

### 问题: Bundle ID 不匹配
```bash
1. 检查 xDrip/xDrip.xcconfig
2. 检查 xdrip.xcodeproj/project.pbxproj
3. 运行: grep -r "xdripswift" . 查找旧的 Bundle ID
```

### 问题: 无法下载报告
```bash
1. 打开 Actions 运行页面
2. 滚动到底部 "Artifacts" 部分
3. 点击 "apple-configuration-verification-report" 下载
```

---

## 📞 获取帮助

1. **查看详细日志**: GitHub Actions → 点击运行 → 查看每个步骤的输出
2. **下载报告**: 包含完整的配置要求和建议
3. **查看文档**: [Apple 配置验证 Action 使用指南.md](./Apple%20配置验证%20Action%20使用指南.md)

---

## 🎯 记住这些

✅ **独立运行** - 不依赖构建流程  
✅ **快速验证** - 2-5 分钟完成  
✅ **详细报告** - 导出完整配置清单  
✅ **无副作用** - 只读操作，不修改配置  
✅ **分段检查** - 可以只检查特定部分  

---

**准备好了吗？运行你的第一次验证！** 🚀

```bash
gh workflow run verify-apple-config.yml -f check_type=all
```

