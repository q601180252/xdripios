# GitHub Actions 代码签名错误修复指南

## 错误信息

```
error: No Account for Team "7RV2Y67HF6"
error: No profiles for 'com.7RV2Y67HF6.xdripswift' were found
```

## 问题原因

GitHub Actions 的 runner 环境中没有登录 Apple 账号，即使使用 App Store Connect API，xcodebuild 的自动代码签名仍然需要以下条件之一：

1. ✅ 已登录的 Apple 账号（GUI 环境）
2. ✅ 手动导入的证书 + 配置文件
3. ✅ 使用 Fastlane Match 管理

## 解决方案

我已更新了 GitHub Actions 工作流，现在需要完整的证书配置。

### 需要配置的 GitHub Secrets

现在需要配置以下所有 Secrets：

#### 1. App Store Connect API（必需）
```
APPSTORE_API_KEY_ID       # API Key ID（10位字符）
APPSTORE_ISSUER_ID        # Issuer ID（UUID格式）
APPSTORE_API_PRIVATE_KEY  # API 私钥内容（.p8文件内容）
```

#### 2. 代码签名证书（必需）
```
CERTIFICATES_P12          # 证书文件的 Base64 编码
CERTIFICATES_P12_PASSWORD # 证书密码
```

---

## 详细配置步骤

### 步骤 1: 获取 App Store Connect API Key

已在之前的文档中说明，这里不再重复。

### 步骤 2: 导出代码签名证书

#### macOS 上导出证书

1. **打开 Keychain Access（钥匙串访问）**

2. **找到 iOS Distribution 证书**
   - 在左侧选择"login"钥匙串
   - 在"Certificates"分类中查找
   - 证书名称类似：`iPhone Distribution: Your Name (TEAM_ID)`

3. **导出证书**
   - 右键点击证书
   - 选择 **"Export"**
   - 文件格式选择 **"Personal Information Exchange (.p12)"**
   - 保存为 `Certificates.p12`
   - 设置密码（记住这个密码）

4. **转换为 Base64**
   ```bash
   # 在终端中运行
   base64 -i Certificates.p12 | pbcopy
   # Base64 编码已复制到剪贴板
   ```

### 步骤 3: 在 GitHub 配置 Secrets

1. 进入 GitHub 仓库
2. **Settings** → **Secrets and variables** → **Actions**
3. 点击 **"New repository secret"**
4. 添加以下 Secrets：

   **CERTIFICATES_P12**:
   ```
   粘贴步骤 2 中复制的 Base64 编码
   ```

   **CERTIFICATES_P12_PASSWORD**:
   ```
   输入步骤 2 中设置的密码
   ```

---

## 创建所需证书和配置文件

### 如果您还没有证书

#### 1. 创建证书请求（CSR）

在 macOS 上：

1. 打开 **Keychain Access**
2. 菜单栏：**Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
3. 填写信息：
   - **User Email Address**: 您的邮箱
   - **Common Name**: 您的名字
   - **Request is**: 选择 **"Saved to disk"**
4. 点击 **Continue** 并保存 `CertificateSigningRequest.certSigningRequest`

#### 2. 在 Apple Developer Portal 创建证书

1. 访问 [Certificates](https://developer.apple.com/account/resources/certificates)
2. 点击 **"+"** 创建新证书
3. 选择 **"Apple Distribution"** (用于 App Store)
4. 上传刚才创建的 CSR 文件
5. 下载证书（`distribution.cer`）
6. 双击安装到 Keychain

#### 3. 导出为 P12

按照上面"步骤 2: 导出代码签名证书"的说明导出。

---

## 配置文件管理

### 方案 A: 自动创建（推荐）

使用更新后的 GitHub Actions 工作流，配置文件会通过 App Store Connect API 自动创建和下载。

**优点**：
- ✅ 无需手动管理配置文件
- ✅ 自动处理过期问题
- ✅ 支持多个 Bundle ID（Widget、Watch App等）

**前提条件**：
- ✅ Bundle ID 已在 Apple Developer Portal 注册
- ✅ App Store Connect API Key 有足够权限

### 方案 B: 手动创建

如果自动创建失败，可以手动创建所有需要的配置文件：

#### 主应用配置文件

1. 访问 [Profiles](https://developer.apple.com/account/resources/profiles)
2. 点击 **"+"**
3. 选择 **"App Store"**
4. App ID: `com.7RV2Y67HF6.xdripswift`
5. 选择您的 Distribution 证书
6. 命名并下载

#### Widget 扩展配置文件

重复上述步骤，使用：
- App ID: `com.7RV2Y67HF6.xdripswift.xDripWidget`

#### Notification 扩展配置文件

- App ID: `com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension`

#### Watch App 配置文件

- App ID: `com.7RV2Y67HF6.xdripswift.watchkitapp`

#### Watch Complication 配置文件

- App ID: `com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication`

---

## 验证配置

### 本地验证

```bash
# 1. 检查证书
security find-identity -v -p codesigning

# 应该看到类似输出：
# 1) ABC123... "iPhone Distribution: Your Name (7RV2Y67HF6)"

# 2. 检查配置文件目录
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

### GitHub Actions 验证

提交代码后：

1. 进入 **Actions** 页面
2. 查看最新的工作流运行
3. 展开 **"Import Code Signing Certificate"** 步骤
4. 应该看到证书导入成功
5. 展开 **"Build IPA"** 步骤
6. 查看是否有代码签名错误

---

## 常见问题

### 问题 1: 证书导入失败

```
error: The specified item could not be found in the keychain
```

**解决**：
- 检查 `CERTIFICATES_P12` Base64 编码是否正确
- 确认 `CERTIFICATES_P12_PASSWORD` 密码正确
- 重新导出证书

### 问题 2: 证书过期

```
error: The certificate used to sign "xdrip" has either expired or has been revoked
```

**解决**：
1. 在 Apple Developer Portal 撤销旧证书
2. 创建新的 Distribution 证书
3. 导出新证书并更新 GitHub Secrets

### 问题 3: Bundle ID 未注册

```
error: No profiles for 'com.xxx.xxx' were found
```

**解决**：
1. 访问 [Identifiers](https://developer.apple.com/account/resources/identifiers)
2. 为每个扩展创建对应的 App ID
3. 确保启用所需的 Capabilities

### 问题 4: API Key 权限不足

```
error: Forbidden
```

**解决**：
确保 API Key 有以下权限之一：
- **App Manager** ✅ 推荐
- **Developer**
- **Admin**

---

## 需要创建的所有 Bundle ID

确保在 Apple Developer Portal 中注册了以下所有 Bundle ID：

1. ✅ `com.7RV2Y67HF6.xdripswift` - 主应用
2. ✅ `com.7RV2Y67HF6.xdripswift.xDripWidget` - Widget 扩展
3. ✅ `com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension` - 通知扩展
4. ✅ `com.7RV2Y67HF6.xdripswift.watchkitapp` - Watch App
5. ✅ `com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication` - Watch Complication

---

## 完整的 Secrets 清单

配置完成后，您应该有以下 6 个 Secrets：

```
✅ APPSTORE_API_KEY_ID
✅ APPSTORE_ISSUER_ID
✅ APPSTORE_API_PRIVATE_KEY
✅ CERTIFICATES_P12
✅ CERTIFICATES_P12_PASSWORD
✅ (可选) PROVISIONING_PROFILE_NAME
```

---

## 下一步

1. ✅ 配置所有 GitHub Secrets
2. ✅ 确保所有 Bundle ID 已注册
3. ✅ 提交代码触发构建
4. ✅ 查看 Actions 日志验证成功

构建成功后，IPA 文件会作为 Artifact 上传，可在 Actions 页面下载。

