# 🔧 Match Provisioning Profiles 修复指南

## 问题描述

GitHub Actions 构建失败，错误：
```
No matching provisioning profiles found for 'AppStore_com.7RV2Y67HF6.xdripswift.mobileprovision'
A new one cannot be created because you enabled `readonly`
```

## 原因

Match-Secrets 仓库中缺少 xDrip 应用的 provisioning profiles（只有旧的 Loop 应用的 profiles）。

---

## ✅ 快速修复（推荐）

### 重要：你需要使用的 Team ID 是 `7RV2Y67HF6`

**首先需要更新 GitHub Secrets！**

访问：https://github.com/q601180252/xdripios/settings/secrets/actions

确保以下 Secrets 设置正确：
```
TEAMID = 7RV2Y67HF6（不是 HHZN32E89C！）
```

### 在你的 Mac 上执行：

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 1. 设置环境变量（替换为你的实际值）
export MATCH_PASSWORD="你的Match密码"
export GH_PAT="你的GitHub_PAT"
export FASTLANE_KEY_ID="你的Apple_Key_ID"
export FASTLANE_ISSUER_ID="你的Apple_Issuer_ID"
export FASTLANE_KEY="你的Apple_Key内容(Base64编码)"
export TEAMID="7RV2Y67HF6"
export GITHUB_REPOSITORY_OWNER="q601180252"
export GITHUB_WORKSPACE="$(pwd)"

# 2. 运行设置脚本
./setup_match_profiles.sh
```

### 或者直接运行 Fastlane：

```bash
bundle exec fastlane certs
```

---

## 这个命令会做什么？

1. ✅ 连接到 Apple Developer Portal
2. ✅ 使用你的 Team ID `7RV2Y67HF6` 创建证书
3. ✅ 为以下 5 个 Bundle IDs 创建 provisioning profiles：
   - `com.7RV2Y67HF6.xdripswift`
   - `com.7RV2Y67HF6.xdripswift.xDripWidget`
   - `com.7RV2Y67HF6.xdripswift.watchkitapp`
   - `com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication`
   - `com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension`
4. ✅ 加密并上传到 `Match-Secrets` 仓库
5. ✅ 完成！

---

## 验证修复

### 1. 检查 Match 仓库

访问：https://github.com/q601180252/Match-Secrets

应该能看到新的提交，包含 profiles。

### 2. 重新运行 GitHub Actions

前往：https://github.com/q601180252/xdripios/actions

手动触发 `Build xDrip IPA with Match` 工作流。

### 3. 检查构建日志

应该能看到类似的成功消息：
```
✅ Installing provisioning profile...
✅ AppStore_com.7RV2Y67HF6.xdripswift.mobileprovision
✅ Installed the profile successfully
```

---

## 常见问题

### Q1: 我没有这些环境变量怎么办？

**MATCH_PASSWORD**: 这是你设置 Match 时选择的密码，用于加密证书和 profiles。

**GH_PAT**: 在 GitHub Settings → Developer settings → Personal access tokens 创建，需要 `repo` 和 `workflow` 权限。

**Apple Keys**: 在 https://appstoreconnect.apple.com/access/api 创建 App Store Connect API Key。

### Q2: 本地运行失败怎么办？

检查错误信息：
- 如果是权限问题：确保 Apple API Key 有正确的权限
- 如果是网络问题：确保能访问 GitHub 和 Apple 服务器
- 如果是 Bundle ID 不存在：先运行 `bundle exec fastlane identifiers` 创建 Bundle IDs

### Q3: 我可以手动创建 profiles 吗？

可以，但不推荐。如果必须手动创建：
1. 访问 https://developer.apple.com/account/resources/profiles/list
2. 为每个 Bundle ID 创建 App Store 类型的 profile
3. 使用证书：`Apple Distribution: Yang Li (HHZN32E89C)`
4. 下载并手动添加到 Match 仓库（需要手动加密）

---

## 相关文件

- `setup_match_profiles.sh` - 自动化设置脚本
- `fastlane/Fastfile` - Fastlane 配置（`certs` lane）
- `fastlane/Matchfile` - Match 配置
- `MATCH_SETUP_GUIDE.md` - 详细设置指南

---

## 总结

**最简单的方法**：在 Mac 上运行 `./setup_match_profiles.sh`，让 Fastlane 自动创建所有需要的 provisioning profiles！

完成后，GitHub Actions 构建就能正常工作了。🎉
