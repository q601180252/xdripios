# Fastlane Match 设置指南

## 前提条件

你的项目使用以下配置：

```
Team ID: 7RV2Y67HF6
Bundle ID 前缀: com.7RV2Y67HF6.xdripswift
```

**重要**：确保 GitHub Secrets 中的 `TEAMID` 设置为 `7RV2Y67HF6`！

---

## 问题诊断

GitHub Actions 构建失败，错误信息：
```
No matching provisioning profiles found for 'AppStore_com.7RV2Y67HF6.xdripswift.mobileprovision'
A new one cannot be created because you enabled `readonly`
```

### 原因分析

Match-Secrets 仓库中缺少 xDrip 应用的 provisioning profiles，或者使用了错误的 Team ID。

---

## 解决步骤

### 步骤 1：在本地运行 Match 初始化

在你的 **Mac 电脑**上执行以下命令：

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 确保环境变量已设置（使用正确的 Team ID）
export MATCH_PASSWORD="你的 Match 密码"
export MATCH_GIT_BASIC_AUTHORIZATION="你的 GitHub PAT (Base64 编码)"
export APPLE_ISSUER_ID="你的 Apple Issuer ID"
export APPLE_KEY_ID="你的 Apple Key ID"
export APPLE_KEY_CONTENT="你的 Apple API Key (Base64 编码)"
export TEAMID="7RV2Y67HF6"
export GITHUB_REPOSITORY_OWNER="q601180252"
export GITHUB_WORKSPACE="$(pwd)"

# 运行 Match 来创建 provisioning profiles
bundle exec fastlane match appstore --readonly false
```

### 步骤 2：验证创建的 Profiles

成功后，Match 会在 `Match-Secrets` 仓库中创建以下文件：

```
Match-Secrets/
└── profiles/
    └── appstore/
        ├── AppStore_com.7RV2Y67HF6.xdripswift.mobileprovision ✅
        ├── AppStore_com.7RV2Y67HF6.xdripswift.xDripWidget.mobileprovision ✅
        ├── AppStore_com.7RV2Y67HF6.xdripswift.watchkitapp.mobileprovision ✅
        ├── AppStore_com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication.mobileprovision ✅
        └── AppStore_com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension.mobileprovision ✅
```

### 步骤 3：重新运行 GitHub Actions

创建完成后，在 GitHub 上重新触发构建即可。

---

## 方案 2：手动在 Apple Developer Portal 创建

如果本地运行 Match 有问题，可以手动创建：

### 1. 登录 Apple Developer

访问：https://developer.apple.com/account/resources/profiles/list

### 2. 为每个 Bundle ID 创建 Provisioning Profile

对于以下 5 个 Bundle IDs，分别创建 **App Store** 类型的 profile：

- `com.7RV2Y67HF6.xdripswift`
- `com.7RV2Y67HF6.xdripswift.xDripWidget`
- `com.7RV2Y67HF6.xdripswift.watchkitapp`
- `com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication`
- `com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension`

**配置要求：**
- Type: **App Store**
- App ID: 选择对应的 Bundle ID
- Certificate: 选择你的 Distribution 证书
- Name: 格式为 `AppStore_<bundle_id>`

---

## 使用自动化脚本

项目包含一个自动化脚本 `setup_match_profiles.sh`：

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 设置环境变量
export MATCH_PASSWORD="你的Match密码"
export GH_PAT="你的GitHub_PAT"
export FASTLANE_KEY_ID="你的Apple_Key_ID"
export FASTLANE_ISSUER_ID="你的Apple_Issuer_ID"
export FASTLANE_KEY="你的Apple_Key_Base64"

# 运行脚本（会自动使用正确的 Team ID）
./setup_match_profiles.sh
```

---

## 常见问题

### Q: 如何确认我的 Team ID？

A: 访问 https://developer.apple.com/account/，在页面顶部会显示你的 Team ID。

对于这个项目，Team ID 是 `7RV2Y67HF6`（在 `xdrip/xDrip.xcconfig` 中配置）。

### Q: 我需要重新创建证书吗？

A: 通常不需要。只需要创建 provisioning profiles。但如果证书过期或不匹配，Match 会自动处理。

### Q: 如何验证 Match 仓库的内容？

```bash
git clone https://github.com/q601180252/Match-Secrets.git
cd Match-Secrets
ls -la profiles/appstore/
```

### Q: GitHub Secrets 应该设置什么值？

确保 `TEAMID` secret 设置为 `7RV2Y67HF6`（不是其他值！）

---

## 参考资料

- [Fastlane Match 官方文档](https://docs.fastlane.tools/actions/match/)
- [Apple Developer Portal](https://developer.apple.com/account/)
- [Troubleshooting Match](https://docs.fastlane.tools/actions/match/#troubleshooting)

---

## 相关文档

- `GITHUB_SECRETS_FIX.md` - GitHub Secrets 配置修复指南
- `MATCH_FIX.md` - 快速修复指南
- `setup_match_profiles.sh` - 自动化设置脚本
