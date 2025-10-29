# ✅ 配置文件问题已修复

## 问题
```
Error: Unable to find 'ACTIVE' profiles for bundleId 'com.7RV2Y67HF6.xdripswift'.
```

## 解决方案

已将 GitHub Actions 工作流从**手动配置文件管理**切换到**自动代码签名**。

### 修改内容

#### 1. 更新了 `.github/workflows/build-ipa.yml`
- ✅ 移除了手动配置文件下载步骤
- ✅ 移除了证书导入步骤  
- ✅ 使用 App Store Connect API 进行自动签名
- ✅ 添加了 `-allowProvisioningUpdates` 参数
- ✅ 使用 `CODE_SIGN_STYLE=Automatic`

#### 2. 更新了 `ExportOptions.plist`
- ✅ 将 `signingStyle` 从 `manual` 改为 `automatic`
- ✅ 移除了手动配置文件配置

### 现在需要的 GitHub Secrets

**只需要 3 个 Secrets**（不再需要证书和配置文件）：

```
APPSTORE_API_KEY_ID       # App Store Connect API Key ID
APPSTORE_ISSUER_ID        # App Store Connect Issuer ID
APPSTORE_API_PRIVATE_KEY  # App Store Connect API 私钥
```

### 不再需要的 Secrets

❌ `CERTIFICATES_P12` - 不再需要  
❌ `CERTIFICATES_P12_PASSWORD` - 不再需要  
❌ `PROVISIONING_PROFILE_NAME` - 不再需要

### 工作原理

使用 App Store Connect API 后：
1. Xcode 会自动从 Apple Developer Portal 下载配置文件
2. 自动选择合适的证书和配置文件
3. 自动处理代码签名
4. 无需手动管理证书和配置文件

### 前提条件

在 Apple Developer Portal 中需要：
1. ✅ 注册 App ID: `com.7RV2Y67HF6.xdripswift`
2. ✅ 有有效的 Distribution 证书（会自动使用）
3. ✅ App Store Connect API Key 有足够权限

### 如何验证

```bash
# 1. 确保已配置 GitHub Secrets
# 进入仓库 Settings > Secrets and variables > Actions
# 确认以下 Secrets 存在：
- APPSTORE_API_KEY_ID
- APPSTORE_ISSUER_ID  
- APPSTORE_API_PRIVATE_KEY

# 2. 提交代码触发构建
git add .
git commit -m "Fix: Switch to automatic code signing"
git push origin main

# 3. 查看 GitHub Actions 日志
# 应该看到：
✅ Automatic provisioning profile selection
✅ Code signing succeeded
✅ Archive created
✅ IPA exported
```

### 如果仍有问题

#### 问题 1: App ID 未注册
```
Error: No profiles for 'com.7RV2Y67HF6.xdripswift' were found
```

**解决**：
1. 访问 [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers)
2. 创建新的 App ID: `com.7RV2Y67HF6.xdripswift`
3. 启用需要的 Capabilities (HealthKit, Push Notifications 等)

#### 问题 2: 证书已过期
```
Error: No signing certificate found
```

**解决**：
1. 访问 [Certificates](https://developer.apple.com/account/resources/certificates)
2. 创建新的 iOS Distribution 证书
3. 下载并安装到 Keychain

#### 问题 3: API Key 权限不足
```
Error: Forbidden
```

**解决**：
确保 API Key 有以下权限之一：
- App Manager ✅ 推荐
- Developer
- Admin

### 优势

使用自动代码签名的优势：

✅ **更简单** - 无需手动管理证书和配置文件  
✅ **更安全** - 不需要在 GitHub Secrets 中存储证书  
✅ **更可靠** - 自动选择有效的证书和配置文件  
✅ **更易维护** - 证书过期时自动使用新证书  
✅ **更少错误** - 减少配置错误的可能性

### 下一步

现在可以：
1. ✅ 推送代码触发自动构建
2. ✅ 手动触发 GitHub Actions 工作流
3. ✅ 构建会自动处理代码签名
4. ✅ IPA 会自动上传为 Artifact

### 相关文档

- [配置文件问题解决方案.md](配置文件问题解决方案.md) - 详细解决方案
- [GitHub Actions IPA 构建指南.md](GitHub%20Actions%20IPA%20构建指南.md) - 完整使用指南

