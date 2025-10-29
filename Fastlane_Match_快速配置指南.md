# Fastlane Match 快速配置指南 🚀

## 🎯 目标

使用 Fastlane Match 简化 GitHub Actions 配置,只需 **2 个新 Secrets**!

---

## ✅ 前提确认

- ✅ Match-Secrets 仓库已存在: https://github.com/q601180252/Match-Secrets
- ✅ 项目已有 Fastlane Match 配置
- ✅ 本地 Xcode 编译和 TestFlight 上传成功

---

## 📋 需要配置的 GitHub Secrets

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

### 新增 2 个 Secrets:

#### 1️⃣ MATCH_PASSWORD

```
Secret Name: MATCH_PASSWORD

作用:
  用于加密/解密 Match-Secrets 仓库中的证书和 Profiles

Value 来源:
  • 如果您之前已使用 Match,应该已经有这个密码
  • 这是您在第一次运行 fastlane match 时设置的密码
  • 如果忘记了,可以重新运行 match 并设置新密码

如何获取:
  • 查看您的笔记或密码管理器
  • 或者重新初始化 Match (会设置新密码)
```

#### 2️⃣ GH_PAT (GitHub Personal Access Token)

```
Secret Name: GH_PAT

作用:
  用于让 GitHub Actions 访问您的私有 Match-Secrets 仓库

如何创建:
  1. 访问: https://github.com/settings/tokens/new
  
  2. 填写信息:
     Note: xDrip Match Access
     Expiration: No expiration (或选择 1 year)
     
  3. 选择权限:
     ✅ repo (Full control of private repositories)
        ✅ repo:status
        ✅ repo_deployment
        ✅ public_repo
        ✅ repo:invite
        ✅ security_events
     
  4. 点击 "Generate token"
  
  5. 复制 token (只显示一次!)
     格式: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     
  6. 保存这个 token!

Value:
  ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  (您刚才复制的 token)
```

### 已有的 Secrets (保留):

```
3. APPSTORE_API_KEY_ID
4. APPSTORE_ISSUER_ID
5. APPSTORE_API_PRIVATE_KEY
```

**总共**: 5 个 Secrets (不是 7 个!)

---

## 🚀 配置步骤

### 步骤 1: 创建 GitHub Personal Access Token

```
1. 访问: https://github.com/settings/tokens/new

2. 配置:
   Note: xDrip Match Access
   Expiration: No expiration
   
3. 权限:
   ✅ repo (勾选这一项即可,会自动勾选所有子项)

4. Generate token

5. 复制并保存 token (只显示一次!)
```

### 步骤 2: 配置 GitHub Secrets

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

#### 添加 Secret 1: MATCH_PASSWORD

```
1. 点击 "New repository secret"

2. 填写:
   Name: MATCH_PASSWORD
   Value: 您的 Match 密码
   
3. Add secret
```

#### 添加 Secret 2: GH_PAT

```
1. 点击 "New repository secret"

2. 填写:
   Name: GH_PAT
   Value: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
          (您刚才创建的 GitHub PAT)
   
3. Add secret
```

### 步骤 3: 验证 Secrets 配置

在 GitHub Secrets 页面应该看到:

```
Repository secrets (5)

APPSTORE_API_KEY_ID              Updated earlier
APPSTORE_ISSUER_ID               Updated earlier
APPSTORE_API_PRIVATE_KEY         Updated earlier
GH_PAT                          Updated now
MATCH_PASSWORD                   Updated now
```

✅ **5 个 Secrets 都配置完成!**

---

## 🔄 更新 Match-Secrets 仓库(重要!)

### 为什么需要更新?

Match-Secrets 仓库中可能存储的是旧 Bundle IDs (`xdripswift`),需要更新为新的 (`xdripswiftt1li23`)。

### 本地更新步骤

**在您的 Mac 上执行**:

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 设置环境变量
export MATCH_PASSWORD="your-match-password"    # 您的 Match 密码
export GH_PAT="ghp_xxxxx"                      # 您刚创建的 GitHub PAT
export GITHUB_REPOSITORY_OWNER="q601180252"
export TEAMID="HHZN32E89C"
export GITHUB_WORKSPACE=$(pwd)

# 设置 Fastlane API Key 环境变量
export FASTLANE_KEY_ID="您的 API Key ID"
export FASTLANE_ISSUER_ID="您的 Issuer ID"
export FASTLANE_KEY="您的 API Private Key (完整的 p8 文件内容)"

# 使用 Fastlane 重新生成证书和 Profiles
# 这会为新的 Bundle IDs 创建 Provisioning Profiles
bundle exec fastlane certs
```

**这个命令会**:
1. 连接到 Apple Developer Portal
2. 为新的 5 个 Bundle IDs 创建 Provisioning Profiles
3. 加密并推送到 Match-Secrets 仓库

**或者,如果想重新开始**:

```bash
# 清理旧证书和 Profiles (谨慎!)
bundle exec fastlane nuke_certs

# 重新创建所有证书和 Profiles
bundle exec fastlane certs
```

---

## 📝 配置完成后

### 步骤 4: 推送代码到 GitHub

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 查看更改
git status

# 提交更改
git add -A
git commit -m "Update Fastfile Bundle IDs and add Match workflow"

# 推送到 GitHub
git push origin main
```

### 步骤 5: 触发 GitHub Actions

#### 方式 1: 自动触发
推送代码后会自动触发 `build-ipa-with-match.yml`

#### 方式 2: 手动触发
```
1. 访问: https://github.com/q601180252/xdripios/actions
2. 点击 "Build xDrip iOS IPA (with Fastlane Match)"
3. 点击 "Run workflow"
4. 点击绿色 "Run workflow" 按钮
```

### 步骤 6: 观察构建日志

应该看到:
```
✅ 配置 Fastlane Match...
✅ 使用 Fastlane Match 下载证书和 Provisioning Profiles...
✅ 证书和 Provisioning Profiles 已下载
✅ 使用 Fastlane 构建 IPA...
✅ IPA 构建完成
✅ 已上传到 TestFlight
```

---

## ⚠️ 常见问题

### Q1: 忘记了 MATCH_PASSWORD 怎么办?

**方案 1**: 查找密码
- 检查您的笔记
- 检查密码管理器
- 检查之前项目的配置

**方案 2**: 重新初始化 Match
```bash
# 清理旧的
fastlane match nuke

# 重新初始化(会要求设置新密码)
fastlane match appstore
```

### Q2: GitHub PAT 的权限不够?

**症状**: Match 无法克隆 Match-Secrets 仓库

**解决**:
- 确保 PAT 有 `repo` 权限
- 重新创建 PAT 并更新 GitHub Secret

### Q3: Bundle IDs 不匹配?

**症状**: Match 找不到 Provisioning Profiles

**解决**:
```bash
# 运行 certs lane 为新 Bundle IDs 创建 Profiles
bundle exec fastlane certs
```

---

## 📊 配置清单

### 本地配置 (一次性):

```
□ 更新 Fastfile Bundle IDs (✅ 已完成)
□ 运行 fastlane certs 创建新 Profiles
□ 确认 Match-Secrets 仓库已更新
```

### GitHub Secrets 配置:

```
□ MATCH_PASSWORD (新增)
□ GH_PAT (新增)
□ APPSTORE_API_KEY_ID (已有)
□ APPSTORE_ISSUER_ID (已有)
□ APPSTORE_API_PRIVATE_KEY (已有)
```

### 推送和测试:

```
□ 提交并推送代码
□ 触发 GitHub Actions
□ 观察构建日志
□ 确认构建成功
```

---

## 🎉 完成后的优势

### 与手动方式对比

| 项目 | 手动方式 | Match 方式 |
|------|---------|-----------|
| **GitHub Secrets** | 7 个 | 5 个 |
| **配置复杂度** | ⭐⭐⭐⭐☆ | ⭐⭐☆☆☆ |
| **证书更新** | 重新转换 base64 | `fastlane match` |
| **Profile 更新** | 重新转换 base64 | 自动更新 |
| **团队协作** | 困难 | 简单 |
| **维护难度** | 较高 | 较低 |

---

## 💡 最佳实践

### 推荐工作流程

```
1. 本地开发:
   • Xcode 开发和测试
   • 需要更新证书时: fastlane match appstore

2. 发布到 TestFlight:
   
   方式 A: 本地发布 (快速)
     • Xcode → Product → Archive
     • Distribute App → Upload
   
   方式 B: GitHub Actions (自动)
     • 推送代码到 main 分支
     • GitHub Actions 自动构建和上传
```

---

## 📞 下一步

### 现在需要做的:

1. **创建 GitHub PAT**
   - https://github.com/settings/tokens/new
   - 权限: repo

2. **配置 2 个 GitHub Secrets**
   - MATCH_PASSWORD
   - GH_PAT

3. **本地更新 Match-Secrets 仓库**
   ```bash
   bundle exec fastlane certs
   ```

4. **推送代码并测试**
   ```bash
   git push origin main
   ```

---

**准备好了吗?按照步骤操作,很快就能完成!** 🚀

告诉我执行到哪一步,遇到任何问题随时告诉我! 😊

