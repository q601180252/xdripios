# 创建 xDrip 专用 Match 仓库 🔐

## 🎯 为什么需要独立仓库?

您的 `Match-Secrets` 仓库已经在为其他项目服务,为了避免冲突,我们为 xDrip 创建一个**独立的 Match 仓库**。

---

## ✅ 已完成的更新

我已经将 Matchfile 更新为使用新仓库:
```
旧: Match-Secrets
新: xDrip-Match-Secrets
```

---

## 📋 配置步骤

### 步骤 1: 创建新的 GitHub 仓库 (2 分钟)

#### 访问 GitHub 创建仓库页面

https://github.com/new

#### 填写信息

```
Repository name: xDrip-Match-Secrets

Description: Encrypted certificates and provisioning profiles for xDrip iOS app

Visibility: 
  ✅ Private (必须是私有仓库!)
  
⚠️ 不要选择 Public!证书和 Profiles 必须保密!

Initialize this repository with:
  □ Add a README file (不勾选)
  □ Add .gitignore (不勾选)
  □ Choose a license (不勾选)
```

#### 点击 "Create repository"

✅ **仓库创建完成!**

仓库地址: https://github.com/q601180252/xDrip-Match-Secrets

---

### 步骤 2: 初始化 Match 并上传证书和 Profiles (5-10 分钟)

#### 在终端执行

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 设置环境变量
export MATCH_PASSWORD="your-new-match-password"  # 为 xDrip 设置一个新密码
export GH_PAT="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # 您刚创建的 GitHub PAT
export GITHUB_REPOSITORY_OWNER="q601180252"
export TEAMID="HHZN32E89C"
export GITHUB_WORKSPACE=$(pwd)

# 初始化 Match 并上传证书和 Profiles
bundle exec fastlane match appstore \
  --git_basic_authorization $(echo -n "$GITHUB_REPOSITORY_OWNER:$GH_PAT" | base64) \
  --app_identifier "com.HHZN32E89C.xdripswiftt1li23,com.HHZN32E89C.xdripswiftt1li23.xDripWidget,com.HHZN32E89C.xdripswiftt1li23.watchkitapp,com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication,com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension"
```

#### 执行过程中会提示

```
Passphrase for Match storage:
```

**输入您刚才设置的 MATCH_PASSWORD**

#### Match 会自动完成

1. ✅ 检测您钥匙串中的证书
2. ✅ 从 Apple Developer Portal 下载/创建 5 个 Provisioning Profiles
3. ✅ 加密所有证书和 Profiles
4. ✅ 推送到 xDrip-Match-Secrets 仓库

#### 执行成功的标志

```
[✔] Cloning remote git repo...
[✔] Installing certificate...
[✔] Installing provisioning profile...
[✔] Installing provisioning profile...
[✔] Installing provisioning profile...
[✔] Installing provisioning profile...
[✔] Installing provisioning profile...
[✔] All required keys, certificates and provisioning profiles are installed
[✔] Pushing changes to remote git repo...
```

✅ **Match 仓库初始化完成!**

---

### 步骤 3: 更新 GitHub Secrets 中的 MATCH_PASSWORD (1 分钟)

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

#### 更新 MATCH_PASSWORD

```
1. 找到 MATCH_PASSWORD Secret
2. 点击 "Update"
3. Value: 输入您在步骤 2 设置的新密码
4. Update secret
```

⚠️ **重要**: 这个密码必须与您在步骤 2 中输入的密码**完全一致**!

---

### 步骤 4: 验证 xDrip-Match-Secrets 仓库 (1 分钟)

访问: https://github.com/q601180252/xDrip-Match-Secrets

应该看到:
```
xDrip-Match-Secrets/
  ├── README.md
  ├── certs/
  │   └── distribution/
  │       └── HHZN32E89C.cer
  │       └── HHZN32E89C.p12
  └── profiles/
      └── appstore/
          ├── AppStore_com.HHZN32E89C.xdripswiftt1li23.mobileprovision
          ├── AppStore_com.HHZN32E89C.xdripswiftt1li23.xDripWidget.mobileprovision
          ├── AppStore_com.HHZN32E89C.xdripswiftt1li23.watchkitapp.mobileprovision
          ├── AppStore_com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication.mobileprovision
          └── AppStore_com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension.mobileprovision
```

✅ **所有文件都已加密存储!**

---

### 步骤 5: 推送代码并测试 (1 分钟)

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 推送代码
git push origin main
```

GitHub Actions 会自动触发,使用新的 `xDrip-Match-Secrets` 仓库!

---

## 📊 完整的 GitHub Secrets 列表

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

应该有 **5 个 Secrets**:

```
1. MATCH_PASSWORD (xDrip 专用密码)
2. GH_PAT (GitHub Personal Access Token)
3. APPSTORE_API_KEY_ID
4. APPSTORE_ISSUER_ID
5. APPSTORE_API_PRIVATE_KEY
```

---

## 🔍 两个 Match 仓库对比

### Match-Secrets (旧,给其他项目用)
```
https://github.com/q601180252/Match-Secrets

用途: 其他项目的证书和 Profiles
状态: 保持不变,继续为其他项目服务
```

### xDrip-Match-Secrets (新,专门给 xDrip)
```
https://github.com/q601180252/xDrip-Match-Secrets

用途: xDrip 项目的证书和 Profiles
状态: 新创建,独立管理
```

**优势**:
- ✅ 互不干扰
- ✅ 证书和 Profiles 独立管理
- ✅ 更清晰、更安全

---

## ⚠️ 常见问题

### Q1: 如果 fastlane match 失败怎么办?

**错误: "Repository not found"**
```
原因: xDrip-Match-Secrets 仓库不存在或无法访问

解决:
  1. 确认仓库已创建: https://github.com/q601180252/xDrip-Match-Secrets
  2. 确认仓库是 Private
  3. 确认 GH_PAT 有 repo 权限
```

**错误: "Invalid passphrase"**
```
原因: 输入的密码不正确

解决:
  1. 重新输入正确的密码
  2. 或者使用 match nuke 清理后重新初始化
```

**错误: "Certificate limit reached"**
```
原因: Apple 账号已有 2 个证书

解决:
  1. Match 会使用现有证书(不创建新的)
  2. 如果提示选择证书,选择最新的那个
  3. 或者删除 1 个旧证书后重试
```

### Q2: 需要删除旧的 Match-Secrets 仓库吗?

**不需要!** 保留它给其他项目用。

---

## 📝 快速命令总结

### 完整执行流程

```bash
# 1. 创建仓库
# 访问: https://github.com/new
# 仓库名: xDrip-Match-Secrets
# Visibility: Private

# 2. 初始化 Match
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

export MATCH_PASSWORD="your-new-xdrip-match-password"
export GH_PAT="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export GITHUB_REPOSITORY_OWNER="q601180252"
export TEAMID="HHZN32E89C"
export GITHUB_WORKSPACE=$(pwd)

bundle exec fastlane match appstore \
  --git_basic_authorization $(echo -n "$GITHUB_REPOSITORY_OWNER:$GH_PAT" | base64) \
  --app_identifier "com.HHZN32E89C.xdripswiftt1li23,com.HHZN32E89C.xdripswiftt1li23.xDripWidget,com.HHZN32E89C.xdripswiftt1li23.watchkitapp,com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication,com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension"

# 3. 更新 GitHub Secret
# MATCH_PASSWORD → 输入新密码

# 4. 推送代码
git push origin main

# 5. 观察构建
# https://github.com/q601180252/xdripios/actions
```

---

## 🎉 优势

使用独立的 `xDrip-Match-Secrets` 仓库:

✅ **隔离性**: 与其他项目完全隔离  
✅ **安全性**: 各项目独立管理证书  
✅ **清晰性**: 一目了然  
✅ **灵活性**: 可以使用不同的 Team ID  

---

**现在开始配置!** 🚀

1. 创建 `xDrip-Match-Secrets` 仓库 (Private)
2. 运行上面的 `fastlane match` 命令
3. 完成后告诉我!

