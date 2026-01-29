# Apple 配置验证 Action 使用指南

## 🎯 目的

这个独立的 GitHub Action 用于验证 Apple Developer Portal 的配置是否正确，无需实际构建应用。可以快速检查：
- API Key 是否有效
- Bundle ID 配置是否正确
- App Group 配置是否完整
- Provisioning Profile 是否可访问
- Entitlements 文件是否存在

## 🚀 如何运行

### 方式 1: GitHub 网页界面

1. 打开项目的 GitHub 页面
2. 点击 **Actions** 标签
3. 在左侧选择 **Verify Apple Developer Configuration**
4. 点击右侧的 **Run workflow** 按钮
5. 选择检查类型：
   - `all` - 执行所有检查（推荐）
   - `api_key` - 仅验证 API Key
   - `bundle_ids` - 仅检查 Bundle ID 配置
   - `provisioning_profiles` - 仅测试 Provisioning Profile 访问
   - `capabilities` - 仅检查功能和权限
6. 点击 **Run workflow** 开始验证

### 方式 2: GitHub CLI

```bash
# 运行所有检查
gh workflow run verify-apple-config.yml -f check_type=all

# 仅验证 API Key
gh workflow run verify-apple-config.yml -f check_type=api_key

# 仅检查 Bundle ID
gh workflow run verify-apple-config.yml -f check_type=bundle_ids

# 仅测试 Provisioning Profile
gh workflow run verify-apple-config.yml -f check_type=provisioning_profiles

# 仅检查功能权限
gh workflow run verify-apple-config.yml -f check_type=capabilities
```

## 📊 验证检查项

### 1. API Key 权限验证 (`api_key`)

验证内容：
- ✅ API Key 文件是否正确创建
- ✅ API Key 是否可以连接到 App Store Connect
- ✅ API Key 权限是否足够

预期结果：
```
✅ API Key 文件存在
✅ API Key 可以成功连接到 App Store Connect
```

### 2. Bundle ID 配置检查 (`bundle_ids`)

验证内容：
- ✅ 列出所有需要配置的 Bundle ID
- ✅ 显示每个 Bundle ID 需要的功能
- ✅ 检查项目中实际配置的 Bundle ID

显示信息：
```
主应用: com.7RV2Y67HF6.xdripswiftt1li23
  功能: App Groups, HealthKit, NFC Tag Reading

Widget: com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget
  功能: App Groups

Watch App: com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp
  功能: App Groups

...
```

### 3. App Group 配置检查 (`capabilities`)

验证内容：
- ✅ 显示需要的 App Group ID
- ✅ 列出需要加入 App Group 的所有 Bundle ID
- ✅ 检查 Entitlements 文件是否存在
- ✅ 检查 Entitlements 文件中的功能配置

检查的文件：
- `xDrip/xdrip.entitlements`
- `xDrip Widget Extension.entitlements`
- `xDrip Watch App/xDrip Watch App.entitlements`

### 4. Provisioning Profile 访问测试 (`provisioning_profiles`)

验证内容：
- ✅ 测试是否可以使用 API Key 访问 Provisioning Profile
- ✅ 显示当前的代码签名配置
- ✅ 显示 Team ID 和 Bundle ID 设置

### 5. 完整验证 (`all`)

执行上述所有检查，并生成完整的配置报告。

## 📋 输出报告

每次运行后，都会生成一个详细的验证报告：

### 在线查看
在 GitHub Actions 的日志中查看实时输出

### 下载报告
1. 打开 Actions 运行结果页面
2. 向下滚动到 **Artifacts** 部分
3. 下载 `apple-configuration-verification-report`
4. 解压查看 `apple-config-report.txt`

报告内容包括：
- 所有需要配置的 Bundle ID
- 每个 Bundle ID 需要的功能
- App Group 配置要求
- 下一步操作建议

## 🔧 使用场景

### 场景 1: 首次配置
在开始配置 Apple Developer Portal 之前，运行验证以了解需要配置什么：
```bash
gh workflow run verify-apple-config.yml -f check_type=all
```

### 场景 2: 配置过程中验证
在配置 Bundle ID 后，验证项目中的配置是否正确：
```bash
gh workflow run verify-apple-config.yml -f check_type=bundle_ids
```

### 场景 3: 构建失败后诊断
如果构建失败，运行完整验证找出问题：
```bash
gh workflow run verify-apple-config.yml -f check_type=all
```

### 场景 4: API Key 问题排查
如果怀疑 API Key 有问题：
```bash
gh workflow run verify-apple-config.yml -f check_type=api_key
```

## ⚠️ 常见问题

### Q1: API Key 验证失败
**可能原因：**
- API Key 权限不足
- API Key 已过期
- GitHub Secrets 配置错误

**解决方案：**
1. 检查 API Key 是否有正确的权限（Admin 或 Developer）
2. 重新生成 API Key
3. 确认 GitHub Secrets 正确配置

### Q2: Bundle ID 不匹配
**可能原因：**
- 项目中的 Bundle ID 与 Apple Developer Portal 不一致
- xcconfig 文件配置错误

**解决方案：**
1. 检查 `xDrip/xDrip.xcconfig` 文件
2. 检查 `xdrip.xcodeproj/project.pbxproj` 文件
3. 确保 Bundle ID 前缀正确（com.7RV2Y67HF6）

### Q3: Entitlements 文件未找到
**可能原因：**
- Entitlements 文件路径不正确
- 文件未提交到 Git

**解决方案：**
1. 确认文件存在于正确的路径
2. 检查 `.gitignore` 是否排除了这些文件
3. 使用 `git add` 添加文件

## 🔗 相关文档

- [App Store Connect 配置指南.md](./App%20Store%20Connect%20配置指南.md)
- [GitHub Actions IPA 构建指南.md](./GitHub%20Actions%20IPA%20构建指南.md)
- [Apple Developer Portal](https://developer.apple.com/account)

## 📝 注意事项

1. **不会修改任何配置** - 此 Action 仅用于验证，不会修改项目或 Apple Developer Portal 的配置
2. **需要 Secrets** - 必须配置 GitHub Secrets（APPSTORE_API_KEY_ID, APPSTORE_ISSUER_ID, APPSTORE_API_PRIVATE_KEY）
3. **运行时间** - 通常需要 2-5 分钟
4. **无需构建** - 不会进行实际的编译，速度快，节省资源

## 🎯 最佳实践

1. **首次配置前** - 运行一次了解需要配置什么
2. **配置完成后** - 运行验证确保配置正确
3. **构建前** - 快速验证配置没有问题
4. **问题排查** - 构建失败时用于诊断配置问题
5. **定期检查** - 定期运行确保配置保持同步

## 📊 验证流程图

```
开始
 ↓
运行验证 Action
 ↓
检查 API Key → ❌ 失败 → 修复 API Key
 ↓ ✅
检查 Bundle ID → ❌ 失败 → 配置 Bundle ID
 ↓ ✅
检查 App Group → ❌ 失败 → 配置 App Group
 ↓ ✅
检查 Provisioning → ❌ 失败 → 创建 Profile
 ↓ ✅
生成报告
 ↓
下载/查看报告
 ↓
完成 ✅
```

## 🚀 快速开始

```bash
# 1. 确保已配置 GitHub Secrets
# 2. 运行完整验证
gh workflow run verify-apple-config.yml -f check_type=all

# 3. 查看结果
gh run list --workflow=verify-apple-config.yml

# 4. 下载报告
gh run download <run-id>
```

