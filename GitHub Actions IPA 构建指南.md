# xDrip iOS GitHub Actions IPA 构建指南

## 概述

本项目已配置 GitHub Actions 工作流，可以自动构建 xDrip iOS 应用的 IPA 文件。支持多种触发方式和构建配置。

## 功能特性

- ✅ 自动构建 IPA 文件
- ✅ 支持 Debug 和 Release 配置
- ✅ 自动上传到 TestFlight
- ✅ 自动创建 GitHub Release
- ✅ 支持手动触发构建
- ✅ 本地构建脚本支持

## GitHub Actions 工作流

### 触发条件

1. **推送触发**：
   - 推送到 `main` 或 `develop` 分支
   - 推送标签（格式：`v*`，如 `v1.0.0`）

2. **Pull Request**：
   - 向 `main` 分支提交 PR

3. **手动触发**：
   - 在 GitHub Actions 页面手动运行
   - 可选择构建配置（Debug/Release）
   - 可选择是否上传到 TestFlight

### 工作流文件

工作流配置文件位于：`.github/workflows/build-ipa.yml`

## 配置要求

### GitHub Secrets

需要在 GitHub 仓库中配置以下 Secrets：

#### 代码签名证书
```
CERTIFICATES_P12          # P12 证书文件的 Base64 编码
CERTIFICATES_P12_PASSWORD # P12 证书密码
```

#### App Store Connect API
```
APPSTORE_ISSUER_ID       # App Store Connect API Issuer ID
APPSTORE_API_KEY_ID      # API Key ID
APPSTORE_API_PRIVATE_KEY # API Private Key
```

#### 配置文件
```
PROVISIONING_PROFILE_NAME # 配置文件名称
```

### 如何获取这些信息

#### 1. 创建 P12 证书
```bash
# 在 Keychain Access 中导出证书
# 选择证书 -> 右键 -> Export -> 保存为 .p12 格式
# 转换为 Base64：
base64 -i certificate.p12 -o certificate_base64.txt
```

#### 2. 创建 App Store Connect API Key
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 Users and Access -> Keys
3. 创建新的 API Key
4. 下载 .p8 文件
5. 记录 Issuer ID 和 Key ID

#### 3. 创建配置文件
1. 在 [Apple Developer Portal](https://developer.apple.com) 创建配置文件
2. 记录配置文件名称

## 使用方法

### 1. 自动构建

#### 推送代码触发
```bash
# 推送到主分支会自动触发构建
git push origin main

# 创建标签会自动创建 Release
git tag v1.0.0
git push origin v1.0.0
```

#### Pull Request 触发
```bash
# 创建 PR 会自动触发构建测试
git checkout -b feature/new-feature
git push origin feature/new-feature
# 在 GitHub 上创建 Pull Request
```

### 2. 手动构建

1. 进入 GitHub 仓库的 Actions 页面
2. 选择 "Build xDrip iOS IPA" 工作流
3. 点击 "Run workflow"
4. 选择构建配置和选项
5. 点击 "Run workflow" 开始构建

### 3. 本地构建

#### macOS/Linux 环境
```bash
# 使用构建脚本
./build_ipa.sh

# 指定构建配置
./build_ipa.sh --config Debug

# 查看帮助
./build_ipa.sh --help
```

#### Windows 环境
```cmd
# 使用批处理脚本（需要 WSL）
build_ipa.bat
```

## 构建输出

### Artifacts
- 构建完成后，IPA 文件会作为 Artifact 上传
- 保留 30 天
- 可在 Actions 页面下载

### TestFlight 上传
- 如果启用 TestFlight 上传选项
- 构建完成后会自动上传到 TestFlight
- 可在 App Store Connect 中查看

### GitHub Release
- 当推送标签时，会自动创建 GitHub Release
- IPA 文件会作为 Release Asset 上传
- 可在 Releases 页面下载

## 故障排除

### 常见问题

#### 1. 代码签名失败
```
错误: Code signing failed
```
**解决方案**：
- 检查证书和配置文件是否正确
- 确保 Bundle ID 匹配
- 验证开发团队 ID

#### 2. 依赖解析失败
```
错误: Could not resolve package dependencies
```
**解决方案**：
- 检查网络连接
- 验证 Swift Package Manager 依赖配置
- 尝试手动运行依赖解析

#### 3. 构建超时
```
错误: Build timeout
```
**解决方案**：
- 检查构建配置
- 减少并行构建任务
- 优化构建脚本

### 调试技巧

#### 1. 查看构建日志
- 在 GitHub Actions 页面查看详细日志
- 关注错误和警告信息

#### 2. 本地测试
- 先在本地环境测试构建
- 使用相同的构建配置

#### 3. 分步调试
- 可以注释掉部分步骤进行调试
- 逐步启用功能

## 高级配置

### 自定义构建配置

可以修改 `.github/workflows/build-ipa.yml` 文件来自定义：

1. **构建环境**：
   ```yaml
   runs-on: macos-latest  # 或 macos-12, macos-13
   ```

2. **Xcode 版本**：
   ```yaml
   xcode-version: latest-stable  # 或具体版本号
   ```

3. **构建参数**：
   ```yaml
   -configuration $BUILD_CONFIG
   -destination "generic/platform=iOS"
   ```

### 多环境支持

可以创建多个工作流文件支持不同环境：

- `build-ipa-dev.yml` - 开发环境
- `build-ipa-staging.yml` - 测试环境  
- `build-ipa-prod.yml` - 生产环境

## 最佳实践

1. **版本管理**：
   - 使用语义化版本号
   - 为重要版本创建标签

2. **分支策略**：
   - `main` 分支用于生产构建
   - `develop` 分支用于开发构建
   - 功能分支用于 PR 测试

3. **安全考虑**：
   - 定期轮换 API Key
   - 使用最小权限原则
   - 保护敏感信息

4. **监控和通知**：
   - 设置构建失败通知
   - 监控构建性能
   - 定期检查依赖更新

## 相关文件

- `.github/workflows/build-ipa.yml` - GitHub Actions 工作流
- `ExportOptions.plist` - IPA 导出配置
- `build_ipa.sh` - macOS/Linux 构建脚本
- `build_ipa.bat` - Windows 构建脚本
- `项目初始化指南.md` - 项目初始化文档

## 支持

如果遇到问题，请：

1. 查看 GitHub Actions 构建日志
2. 检查本文档的故障排除部分
3. 在项目 Issues 中报告问题
4. 联系开发团队

---

**注意**：确保在配置 GitHub Secrets 时遵循安全最佳实践，不要在代码中硬编码敏感信息。
