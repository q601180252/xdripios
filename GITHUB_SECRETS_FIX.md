# 🔧 GitHub Secrets 配置修复指南

## 问题诊断

GitHub Actions 构建失败的**根本原因**：

**GitHub Secrets 中的 TEAMID 设置错误！**

- ❌ **当前设置**: `TEAMID = HHZN32E89C`
- ✅ **应该设置**: `TEAMID = 7RV2Y67HF6`

这导致 GitHub Actions 尝试使用错误的 Team ID 和 Bundle ID，无法找到对应的 Provisioning Profiles。

---

## 正确的配置

### 你的项目使用的配置：

```
Team ID: 7RV2Y67HF6
Bundle ID 前缀: com.7RV2Y67HF6.xdripswift
```

### 需要的 Bundle IDs：

1. `com.7RV2Y67HF6.xdripswift` (主应用)
2. `com.7RV2Y67HF6.xdripswift.xDripWidget` (Widget)
3. `com.7RV2Y67HF6.xdripswift.watchkitapp` (Watch App)
4. `com.7RV2Y67HF6.xdripswift.watchkitapp.xDripWatchComplication` (Watch Complication)
5. `com.7RV2Y67HF6.xdripswift.xDripNotificationContextExtension` (Notification Extension)

---

## 🛠️ 修复步骤

### 步骤 1：更新 GitHub Secrets

访问：**https://github.com/q601180252/xdripios/settings/secrets/actions**

找到并更新以下 Secret：

```
Secret 名称: TEAMID
当前值: HHZN32E89C ❌
新值: 7RV2Y67HF6 ✅
```

**如何更新：**
1. 点击 `TEAMID` 右侧的铅笔图标（编辑）
2. 在 "Value" 字段中删除 `HHZN32E89C`
3. 输入 `7RV2Y67HF6`
4. 点击 "Update secret" 保存

---

### 步骤 2：验证其他 Secrets

确保以下 Secrets 都已正确设置：

| Secret 名称 | 说明 | 如何获取 |
|------------|------|---------|
| `TEAMID` | **7RV2Y67HF6** | Apple Developer 账户的 Team ID |
| `MATCH_PASSWORD` | Match 仓库加密密码 | 你创建 Match 时设置的密码 |
| `GH_PAT` | GitHub Personal Access Token | GitHub Settings → Developer settings → PAT |
| `FASTLANE_KEY_ID` | Apple API Key ID | App Store Connect → Users and Access → Keys |
| `FASTLANE_ISSUER_ID` | Apple Issuer ID | App Store Connect → Keys 页面顶部 |
| `FASTLANE_KEY` | Apple API Key 内容（Base64） | 下载的 `.p8` 文件内容 Base64 编码 |

---

### 步骤 3：在本地创建 Provisioning Profiles

**重要**：Match 仓库需要包含 Team ID `7RV2Y67HF6` 的 provisioning profiles。

在你的 Mac 上运行：

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 设置环境变量（使用正确的 Team ID）
export MATCH_PASSWORD="你的Match密码"
export GH_PAT="你的GitHub_PAT"
export FASTLANE_KEY_ID="你的Apple_Key_ID"
export FASTLANE_ISSUER_ID="你的Apple_Issuer_ID"
export FASTLANE_KEY="你的Apple_Key_Base64"
export TEAMID="7RV2Y67HF6"
export GITHUB_REPOSITORY_OWNER="q601180252"
export GITHUB_WORKSPACE="$(pwd)"

# 创建 Bundle IDs（如果还未创建）
bundle exec fastlane identifiers

# 创建 Provisioning Profiles
bundle exec fastlane certs
```

---

### 步骤 4：重新运行 GitHub Actions

修复 Secrets 并创建 Provisioning Profiles 后：

1. 访问：https://github.com/q601180252/xdripios/actions
2. 选择最新的 workflow run
3. 点击 "Re-run jobs" → "Re-run all jobs"

或者推送一个新的提交来触发构建。

---

## 为什么会出现这个问题？

可能的原因：

1. **复制了其他人的配置**：`HHZN32E89C` 可能来自其他项目或示例配置
2. **使用了多个 Apple Developer 账户**：混淆了不同账户的 Team ID
3. **参考了错误的文档**：文档中使用的示例 Team ID

---

## 验证修复

修复后，GitHub Actions 构建日志应该显示：

```
✅ DEVELOPMENT_TEAM = 7RV2Y67HF6
✅ PRODUCT_BUNDLE_IDENTIFIER = com.7RV2Y67HF6.xdripswift
✅ Installing provisioning profile...
✅ Provisioning profile installed successfully
```

而不是：

```
❌ No matching provisioning profiles found for 'AppStore_com.HHZN32E89C.xdripswift...'
```

---

## 常见问题

### Q1: 我的 Match 仓库中已经有 HHZN32E89C 的证书，怎么办？

**答**：如果 Match 仓库中有错误的证书，你有两个选择：

**选项 A（推荐）**：清空并重新创建
```bash
bundle exec fastlane nuke_certs  # 删除旧证书
bundle exec fastlane certs       # 创建新证书（使用 7RV2Y67HF6）
```

**选项 B**：手动清理 Match 仓库
1. Clone Match-Secrets 仓库
2. 删除错误的证书和 profiles
3. 运行 `bundle exec fastlane certs` 重新创建

### Q2: 如何确认我的 Team ID 是什么？

**答**：访问 https://developer.apple.com/account/

在页面顶部，你会看到：
```
Apple Developer Program
Team Name | Team ID: 7RV2Y67HF6
```

### Q3: 项目代码需要修改吗？

**答**：**不需要！** 项目代码中的配置是正确的（`7RV2Y67HF6`），只需要修改 GitHub Secrets。

---

## 相关文档

- `MATCH_FIX.md` - Match Provisioning Profiles 快速修复
- `MATCH_SETUP_GUIDE.md` - 完整的 Match 设置指南
- `setup_match_profiles.sh` - 自动化设置脚本

---

## 总结

**问题根源**：GitHub Secrets 中的 `TEAMID` 设置为错误的值 `HHZN32E89C`

**解决方案**：
1. ✅ 更新 GitHub Secret `TEAMID` 为 `7RV2Y67HF6`
2. ✅ 在本地运行 `bundle exec fastlane certs` 创建正确的 provisioning profiles
3. ✅ 重新运行 GitHub Actions 构建

**项目代码无需修改！** 🎉
