# 使用 Fastlane Match 简化配置 🎯

## 🎉 好消息!

您说的对!项目已经配置了 **Fastlane Match**,这样可以**大大简化** GitHub Actions 的配置!

---

## 📊 两种方式对比

### 方式 1: 手动管理证书和 Profiles (我刚才的方案)

**需要的 GitHub Secrets**: 7 个
```
1. IOS_DISTRIBUTION_CERTIFICATE_BASE64
2. IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
3. IOS_PROVISIONING_PROFILE_MAIN_BASE64
4. IOS_PROVISIONING_PROFILE_WIDGET_BASE64
5. IOS_PROVISIONING_PROFILE_WATCH_BASE64
6. IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
7. IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64
```

**配置复杂度**: ⭐⭐⭐⭐☆

---

### 方式 2: Fastlane Match (更简单!) ✅

**需要的 GitHub Secrets**: 只需 **3-4 个**!
```
1. MATCH_PASSWORD (Match 仓库密码)
2. GH_PAT (GitHub Personal Access Token)
3. APPSTORE_API_KEY_ID (已有)
4. APPSTORE_ISSUER_ID (已有)
5. APPSTORE_API_PRIVATE_KEY (已有)
```

**配置复杂度**: ⭐⭐☆☆☆ (简单很多!)

---

## 🔍 Fastlane Match 是什么?

### 核心概念

**Fastlane Match** 是一个自动管理证书和 Provisioning Profiles 的工具:

```
工作原理:
  1. 在 GitHub 创建一个私有仓库 (Match-Secrets)
  2. 把证书和 Profiles 加密后存储在这个仓库
  3. GitHub Actions 运行时:
     - 克隆 Match-Secrets 仓库
     - 解密证书和 Profiles
     - 自动安装到系统
     - 开始构建
```

### 优势

✅ **简化配置**:
- 不需要手动配置 7 个 base64 Secrets
- 只需要配置 Match 密码和 GitHub PAT

✅ **团队协作**:
- 所有团队成员使用相同的证书
- 证书存储在加密的 Git 仓库

✅ **自动管理**:
- 自动下载证书和 Profiles
- 自动安装
- 自动更新

---

## 🎯 使用 Fastlane Match 的配置步骤

### 前提条件

需要有一个私有的 **Match-Secrets** GitHub 仓库。

#### 检查是否已存在

访问: https://github.com/q601180252/Match-Secrets

- ✅ 如果存在,说明已经配置过 Match
- ❌ 如果不存在,需要创建

---

### 步骤 1: 创建 Match-Secrets 仓库(如果不存在)

```
访问: https://github.com/new

Repository name: Match-Secrets
Description: Encrypted certificates and profiles for xDrip
Visibility: ✅ Private (必须是私有!)

点击 "Create repository"
```

---

### 步骤 2: 初始化 Match 并上传证书(本地操作)

**在本地项目目录执行**:

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

# 设置环境变量
export MATCH_PASSWORD="your-secure-password"  # 设置一个强密码
export GH_PAT="your-github-pat"               # GitHub Personal Access Token
export GITHUB_REPOSITORY_OWNER="q601180252"   # 您的 GitHub 用户名
export TEAMID="HHZN32E89C"                    # Team ID

# 运行 Match 初始化(会上传证书和 Profiles 到 Match-Secrets 仓库)
bundle exec fastlane match appstore \
  --git_basic_authorization $(echo -n "$GITHUB_REPOSITORY_OWNER:$GH_PAT" | base64) \
  --app_identifier "com.HHZN32E89C.xdripswiftt1li23,com.HHZN32E89C.xdripswiftt1li23.xDripWidget,com.HHZN32E89C.xdripswiftt1li23.watchkitapp,com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication,com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension"
```

**Match 会**:
1. 检测您钥匙串中的证书
2. 检测系统中的 Provisioning Profiles
3. 加密所有证书和 Profiles
4. 推送到 Match-Secrets 仓库

---

### 步骤 3: 配置 GitHub Secrets(只需 3 个!)

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

#### Secret 1: MATCH_PASSWORD
```
Name: MATCH_PASSWORD
Value: 您在步骤 2 设置的密码
```

#### Secret 2: GH_PAT (GitHub Personal Access Token)
```
Name: GH_PAT
Value: 您的 GitHub Personal Access Token

如何创建 PAT:
  1. https://github.com/settings/tokens/new
  2. Note: xDrip Match Access
  3. Expiration: No expiration (或选择时间)
  4. Scopes:
     ✅ repo (Full control of private repositories)
  5. Generate token
  6. 复制 token (只显示一次!)
```

#### Secret 3: MATCH_GIT_BASIC_AUTHORIZATION (可选,自动生成)
```
Name: MATCH_GIT_BASIC_AUTHORIZATION
Value: echo -n "q601180252:YOUR_GH_PAT" | base64

这个可以在 workflow 中自动生成,可以不配置
```

**已有的 Secrets** (保留):
- ✅ APPSTORE_API_KEY_ID
- ✅ APPSTORE_ISSUER_ID  
- ✅ APPSTORE_API_PRIVATE_KEY

---

### 步骤 4: 使用新的 Workflow

我已经创建了新的 workflow 文件:
```
.github/workflows/build-ipa-with-match.yml
```

这个 workflow 使用 Fastlane Match 自动下载证书和 Profiles!

---

## 🆚 两种 Workflow 对比

### build-ipa.yml (手动方式)

**需要 Secrets**: 7 个
```
• IOS_DISTRIBUTION_CERTIFICATE_BASE64
• IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
• IOS_PROVISIONING_PROFILE_MAIN_BASE64
• IOS_PROVISIONING_PROFILE_WIDGET_BASE64
• IOS_PROVISIONING_PROFILE_WATCH_BASE64
• IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
• IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64
```

**优点**: 完全控制,不依赖外部仓库  
**缺点**: 配置复杂

---

### build-ipa-with-match.yml (Match 方式) ✅

**需要 Secrets**: 只需 3 个新 Secrets!
```
• MATCH_PASSWORD
• GH_PAT
• (API Key Secrets 已有)
```

**优点**: 
- ✅ 配置简单
- ✅ 自动管理证书和 Profiles
- ✅ 团队协作友好
- ✅ 就像您之前的项目一样简单!

**缺点**: 需要额外的 Match-Secrets 仓库

---

## 📋 完整配置清单

### 需要配置的 GitHub Secrets (Fastlane Match 方式)

#### 新增 Secrets (2 个):

```
1. MATCH_PASSWORD
   • 用于加密/解密 Match 仓库内容
   • 您自己设置的强密码
   • 例如: MyMatchPassword123!@#

2. GH_PAT (GitHub Personal Access Token)
   • 用于访问 Match-Secrets 私有仓库
   • 从 GitHub 创建
   • 权限: repo (完整私有仓库控制)
```

#### 已有 Secrets (保留):

```
3. APPSTORE_API_KEY_ID
4. APPSTORE_ISSUER_ID
5. APPSTORE_API_PRIVATE_KEY
```

**总共**: 5 个 Secrets (而不是 7 个!)

---

## 🚀 使用 Match 的好处

### 1. 更简单的配置

```
手动方式: 7 个 Secrets (证书 + 密码 + 5 个 Profiles)
Match 方式: 5 个 Secrets (Match 密码 + PAT + API Keys)

节省 2 个 Secrets!
```

### 2. 更容易维护

```
手动方式:
  • 证书过期 → 重新转换 base64 → 更新 7 个 Secrets
  • Profile 过期 → 重新转换 → 更新 5 个 Secrets
  
Match 方式:
  • 证书过期 → fastlane match nuke → fastlane match appstore
  • Profile 过期 → fastlane match appstore --force_for_new_devices
  • Match 自动更新仓库,无需更新 Secrets!
```

### 3. 团队协作

```
手动方式:
  • 每个开发者需要配置本地证书
  • 证书可能不一致
  
Match 方式:
  • 所有开发者使用相同的证书
  • 一键同步: fastlane match appstore
```

---

## 📝 推荐方案

### 如果 Match-Secrets 仓库已存在

**推荐使用**: `build-ipa-with-match.yml` ✅

**原因**:
- 更简单
- 更易维护
- 就像您之前的项目一样

**配置步骤**:
1. 创建 GitHub PAT
2. 配置 2 个新 Secrets (MATCH_PASSWORD + GH_PAT)
3. 禁用旧的 `build-ipa.yml`
4. 使用新的 `build-ipa-with-match.yml`

---

### 如果 Match-Secrets 仓库不存在

#### 选项 A: 创建 Match 仓库(推荐)

**步骤**:
1. 创建 Match-Secrets 私有仓库
2. 本地运行 `fastlane match appstore` 初始化
3. 配置 GitHub Secrets
4. 使用 `build-ipa-with-match.yml`

**时间**: 30-40 分钟  
**长期收益**: 更简单的维护

#### 选项 B: 继续手动方式

**步骤**:
1. 配置 7 个 Secrets (证书 + Profiles base64)
2. 使用 `build-ipa.yml`

**时间**: 40-60 分钟  
**适合**: 不想创建额外仓库

---

## 🎯 您应该选择哪个?

### 如果您之前用过 Match

**强烈推荐**: 继续使用 Match! ✅

**原因**:
- 您已经熟悉 Match
- 配置更简单
- 维护更容易
- 就像之前的项目一样

**只需要**:
1. 创建/使用 Match-Secrets 仓库
2. 配置 MATCH_PASSWORD 和 GH_PAT
3. 完成!

---

### 如果您没用过 Match

**两种方式都可以**:

**Match 方式**:
- 优点: 长期维护更简单
- 缺点: 需要额外仓库

**手动方式**:
- 优点: 不需要额外仓库
- 缺点: 配置更复杂(7 个 Secrets)

---

## 📞 下一步

### 如果选择 Match 方式

**告诉我**:
1. Match-Secrets 仓库是否已存在?
2. 是否已有 MATCH_PASSWORD?
3. 是否已有 GitHub PAT?

**我会**:
1. 帮您配置 Match
2. 更新 Bundle IDs (从 xdripswift 改为 xdripswiftt1li23)
3. 简化 GitHub Actions 配置

---

### 如果选择手动方式

**继续使用**:
- `build-ipa.yml` (已更新好)
- 配置 7 个 Secrets
- 按照之前的指南操作

---

## 💡 我的建议

**如果您之前用过 Match** → **强烈推荐使用 Match 方式!**

**原因**:
1. ✅ 配置更简单 (3 个新 Secrets vs 7 个)
2. ✅ 维护更容易
3. ✅ 您已经熟悉
4. ✅ 就像之前的项目一样

**唯一需要注意**:
- Fastfile 中的 Bundle IDs 使用的是 `xdripswift`
- 需要更新为 `xdripswiftt1li23`

---

**告诉我您想用哪种方式!** 😊

A: 使用 Fastlane Match (推荐,更简单)  
B: 使用手动方式 (已配置好)

