# xDrip iOS - Apple 配置文档中心 📚

## 🎯 文档导航

本文档中心包含所有关于 Apple Developer Portal 配置和 GitHub Actions 构建的指南。

---

## 📖 文档列表

### 1. 🚀 快速开始

#### [Apple 验证 Action 快速参考.md](./Apple%20验证%20Action%20快速参考.md)
**适合**: 首次使用、快速查阅
- ⚡ 一页纸快速参考
- 🎯 常见场景命令
- 📋 检查清单
- 🆘 快速故障排除

**推荐用途**: 作为第一份文档阅读，了解验证流程

---

### 2. 🔍 详细验证指南

#### [Apple 配置验证 Action 使用指南.md](./Apple%20配置验证%20Action%20使用指南.md)
**适合**: 深入了解验证功能
- 📊 详细的验证检查项
- 🔧 各种使用场景
- ⚠️ 常见问题解答
- 📝 最佳实践

**推荐用途**: 深入了解验证 Action 的功能和用法

---

### 3. 🛠️ Portal 配置指南

#### [App Store Connect 配置指南.md](./App%20Store%20Connect%20配置指南.md)
**适合**: Apple Developer Portal 配置
- 🆔 Bundle ID 创建步骤
- 🔗 App Group 配置
- 📜 Provisioning Profile 创建
- ✅ 配置检查清单

**推荐用途**: 在 Apple Developer Portal 中进行实际配置时参考

---

### 4. 🏗️ 构建流程指南

#### [GitHub Actions IPA 构建指南.md](./GitHub%20Actions%20IPA%20构建指南.md)
**适合**: 了解完整构建流程
- 🔄 CI/CD 工作流程
- 🔐 代码签名配置
- 📦 IPA 导出步骤
- 🚀 TestFlight 上传

**推荐用途**: 了解如何使用 GitHub Actions 构建和发布应用

---

### 5. 📝 其他相关文档

#### [Bundle ID 修改说明.md](./Bundle%20ID%20修改说明.md)
- Bundle ID 变更历史
- 修改影响的文件
- 验证步骤

#### [项目初始化指南.md](./项目初始化指南.md)
- 项目基础配置
- 依赖管理
- 环境设置

---

## 🎯 使用流程推荐

### 对于首次配置用户

```
1. 阅读快速参考 ┐
                ├→ 2. 运行验证 Action ┐
3. 查看验证结果 ┘                    │
                                    ├→ 5. 配置 Apple Portal
4. 阅读 Portal 配置指南 ┘            │
                                    ↓
6. 再次运行验证 Action（确认配置）
                                    ↓
7. 阅读构建指南 → 8. 运行构建 Action
```

### 对于配置故障排查

```
1. 运行验证 Action (check_type=all)
                ↓
2. 查看验证结果和报告
                ↓
3. 根据失败项查阅对应文档
                ↓
4. 修复配置
                ↓
5. 再次运行验证确认
```

---

## 🔧 核心配置要求

### Bundle ID 清单

| Bundle ID | 功能要求 |
|-----------|----------|
| `com.7RV2Y67HF6.xdripswiftt1li23` | App Groups, HealthKit, NFC |
| `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget` | App Groups |
| `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp` | App Groups |
| `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication` | App Groups |
| `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension` | App Groups |

### App Group

```
Identifier: group.com.7RV2Y67HF6.loopkit.LoopGroup
包含: 上述所有 Bundle ID
```

### GitHub Secrets

| Secret | 说明 | 如何获取 |
|--------|------|----------|
| `APPSTORE_API_KEY_ID` | API Key ID | App Store Connect → Users and Access → Keys |
| `APPSTORE_ISSUER_ID` | Issuer ID | 同上页面顶部 |
| `APPSTORE_API_PRIVATE_KEY` | .p8 私钥内容 | 下载 .p8 文件并复制内容 |

---

## 🚀 快速命令参考

### 验证配置
```bash
# 完整验证
gh workflow run verify-apple-config.yml -f check_type=all

# 仅验证 API Key
gh workflow run verify-apple-config.yml -f check_type=api_key

# 查看运行结果
gh run list --workflow=verify-apple-config.yml
```

### 构建应用
```bash
# 触发构建
gh workflow run build-ipa.yml

# Release 构建
gh workflow run build-ipa.yml -f build_configuration=Release

# 构建并上传到 TestFlight
gh workflow run build-ipa.yml -f upload_to_testflight=true
```

---

## 🆘 常见问题快速索引

### API Key 相关
- **Q**: API Key 验证失败？
- **A**: 查看 [快速参考 - 快速故障排除](./Apple%20验证%20Action%20快速参考.md#-快速故障排除)

### Bundle ID 相关
- **Q**: Bundle ID 不匹配？
- **A**: 查看 [快速参考 - 快速故障排除](./Apple%20验证%20Action%20快速参考.md#-快速故障排除)

### Provisioning Profile 相关
- **Q**: 找不到 Provisioning Profile？
- **A**: 查看 [Portal 配置指南](./App%20Store%20Connect%20配置指南.md#4-创建-provisioning-profiles)

### 构建失败
- **Q**: 构建失败如何排查？
- **A**: 
  1. 运行验证 Action
  2. 查看 [构建指南 - 故障排除](./GitHub%20Actions%20IPA%20构建指南.md)

---

## 📊 配置完成度检查

使用此清单确保所有配置已完成：

### Apple Developer Portal
- [ ] 创建所有 5 个 Bundle ID
- [ ] 为主应用启用 App Groups, HealthKit, NFC
- [ ] 为其他 4 个扩展启用 App Groups
- [ ] 创建 App Group 并包含所有 Bundle ID
- [ ] 为所有 Bundle ID 创建 Development Provisioning Profile
- [ ] 为所有 Bundle ID 创建 Distribution Provisioning Profile

### GitHub Configuration
- [ ] 配置 APPSTORE_API_KEY_ID
- [ ] 配置 APPSTORE_ISSUER_ID
- [ ] 配置 APPSTORE_API_PRIVATE_KEY

### 验证步骤
- [ ] 运行验证 Action (check_type=all)
- [ ] 所有检查项通过
- [ ] 下载并查看验证报告

### 构建测试
- [ ] 运行构建 Action
- [ ] 构建成功
- [ ] IPA 文件生成

---

## 🔗 外部资源

- [Apple Developer Portal](https://developer.apple.com/account)
- [App Store Connect](https://appstoreconnect.apple.com)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Xcode 代码签名文档](https://developer.apple.com/documentation/xcode/code-signing)

---

## 📞 需要帮助？

1. **运行验证 Action** - 获取当前配置状态
2. **查看对应文档** - 根据问题类型选择文档
3. **查看 GitHub Actions 日志** - 详细的错误信息
4. **下载验证报告** - 完整的配置清单

---

## 🎓 学习路径

### 初学者
```
1. 快速参考 (了解概览)
   ↓
2. 验证 Action (实践验证)
   ↓
3. Portal 配置指南 (动手配置)
   ↓
4. 再次验证 (确认配置)
   ↓
5. 构建指南 (运行构建)
```

### 经验用户
```
1. 快速参考 (快速查阅命令)
   ↓
2. 直接配置 Portal
   ↓
3. 运行验证确认
   ↓
4. 运行构建
```

---

## ⭐ 最佳实践

### 配置阶段
1. ✅ 先运行验证了解需求
2. ✅ 配置 Portal 按清单逐项完成
3. ✅ 配置后立即验证
4. ✅ 保存验证报告备查

### 开发阶段
1. ✅ 定期运行验证（每周）
2. ✅ 修改配置后必须验证
3. ✅ 构建前快速检查
4. ✅ 保持文档同步更新

### 问题排查
1. ✅ 验证 Action 是第一步
2. ✅ 查看完整日志
3. ✅ 对照文档逐项检查
4. ✅ 修复后再次验证

---

**祝您配置顺利！** 🚀

如有问题，从 [快速参考](./Apple%20验证%20Action%20快速参考.md) 开始！

