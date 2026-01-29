# 在 GitHub Actions 上初始化 Match 仓库 🚀

## 🎯 目标

直接在 GitHub Actions 上初始化 Match 仓库,无需本地操作!

---

## ✅ 优势

在 GitHub Actions 上操作的好处:
- ✅ 无需本地配置环境变量
- ✅ 无需本地安装 Fastlane
- ✅ 自动化执行
- ✅ 有完整日志可查看

---

## 📋 完整配置步骤

### ═══════════════════════════════════════════════════════════════════
### 步骤 1: 创建 xDrip-Match-Secrets 仓库 (2 分钟)
### ═══════════════════════════════════════════════════════════════════

#### 访问 GitHub 创建仓库页面

https://github.com/new

#### 填写信息

```
Repository name: xDrip-Match-Secrets

Description: Encrypted certificates and provisioning profiles for xDrip iOS app

Owner: q601180252

Visibility: 
  ✅ Private (必须选择 Private!)
  
⚠️ 非常重要: 必须是 Private,不能是 Public!

Initialize this repository with:
  □ Add a README file (不勾选)
  □ Add .gitignore (不勾选)
  □ Choose a license (不勾选)
  
  ⚠️ 保持空仓库,不要勾选任何选项!
```

#### 点击 "Create repository"

✅ **仓库创建完成!**

仓库地址: https://github.com/q601180252/xDrip-Match-Secrets

---

### ═══════════════════════════════════════════════════════════════════
### 步骤 2: 验证 GitHub Secrets 配置 (1 分钟)
### ═══════════════════════════════════════════════════════════════════

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

#### 确认必需的 5 个 Secrets 都已配置:

```
✅ MATCH_PASSWORD (xDrip 专用密码)
✅ GH_PAT (GitHub Personal Access Token - 必须有 repo 权限)
✅ APPSTORE_API_KEY_ID
✅ APPSTORE_ISSUER_ID
✅ APPSTORE_API_PRIVATE_KEY
```

**如果缺少任何一个**: 先配置完整再继续

---

### ═══════════════════════════════════════════════════════════════════
### 步骤 3: 推送代码到 GitHub (1 分钟)
### ═══════════════════════════════════════════════════════════════════

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios

git push origin main
```

这会推送包含新 workflow 的代码。

---

### ═══════════════════════════════════════════════════════════════════
### 步骤 4: 在 GitHub Actions 上初始化 Match (5-10 分钟)
### ═══════════════════════════════════════════════════════════════════

#### 访问 GitHub Actions 页面

https://github.com/q601180252/xdripios/actions

#### 运行初始化 Workflow

```
1. 左侧找到: "Initialize Fastlane Match Repository"
   
2. 点击这个 workflow
   
3. 点击右侧的 "Run workflow" 按钮
   
4. 确认分支: main
   
5. 点击绿色的 "Run workflow" 按钮
```

#### 观察执行过程

workflow 会自动执行以下步骤:

```
✅ Checkout repository
✅ Setup Xcode
✅ Setup Ruby
✅ Install dependencies
✅ Check if xDrip-Match-Secrets repository exists
✅ Initialize Match and Upload Certificates
   ├── 连接到 Apple Developer Portal
   ├── 使用现有的 Distribution 证书
   ├── 为 5 个 Bundle IDs 创建 Provisioning Profiles
   └── 加密并推送到 xDrip-Match-Secrets 仓库
✅ Verify Match Repository
✅ Summary
```

#### 执行成功的标志

在 workflow 日志中看到:

```
✅ Match 初始化完成!

Match-Secrets 仓库已更新,包含:
  ✅ Distribution 证书
  ✅ 5 个 Provisioning Profiles

🎉 现在可以自动构建和上传 TestFlight 了!
```

---

### ═══════════════════════════════════════════════════════════════════
### 步骤 5: 验证 Match 仓库内容 (1 分钟)
### ═══════════════════════════════════════════════════════════════════

访问: https://github.com/q601180252/xDrip-Match-Secrets

应该看到仓库结构:

```
xDrip-Match-Secrets/
  ├── README.md
  ├── certs/
  │   └── distribution/
  │       ├── HHZN32E89C.cer (证书)
  │       └── HHZN32E89C.p12 (加密的私钥)
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

### ═══════════════════════════════════════════════════════════════════
### 步骤 6: 运行正式构建 (自动)
### ═══════════════════════════════════════════════════════════════════

Match 初始化完成后,就可以运行正式构建了!

#### 访问 GitHub Actions

https://github.com/q601180252/xdripios/actions

#### 运行构建 Workflow

```
1. 左侧找到: "Build xDrip iOS IPA (with Fastlane Match)"
   
2. 点击 "Run workflow"
   
3. Build configuration: Release
   
4. 点击 "Run workflow"
```

#### 应该看到成功日志

```
✅ 配置 Fastlane Match...
✅ 使用 Fastlane Match 下载证书和 Provisioning Profiles...
✅ 证书和 Provisioning Profiles 已下载
✅ 使用 Fastlane 构建 IPA...
✅ IPA 构建完成
✅ 已上传到 TestFlight
```

---

## 📊 完整流程图

```
步骤 1: 创建 xDrip-Match-Secrets 仓库 (GitHub 网页)
   ↓
步骤 2: 验证 GitHub Secrets (5 个都配置好)
   ↓
步骤 3: 推送代码 (git push)
   ↓
步骤 4: 运行 "Initialize Fastlane Match Repository" workflow
   ↓
   等待 5-10 分钟...
   ↓
   Match 仓库初始化完成 ✅
   ↓
步骤 5: 验证 Match 仓库内容
   ↓
步骤 6: 运行 "Build xDrip iOS IPA (with Fastlane Match)" workflow
   ↓
   等待构建...
   ↓
   IPA 上传到 TestFlight ✅
   ↓
🎉 完成!
```

---

## ⚠️ 常见问题

### Q1: "xDrip-Match-Secrets repository not found"

**原因**: 仓库不存在或 GH_PAT 无权限访问

**解决**:
1. 确认仓库已创建: https://github.com/q601180252/xDrip-Match-Secrets
2. 确认仓库是 **Private**
3. 确认 GH_PAT 有 **repo** 权限

### Q2: "Authentication failed"

**原因**: GH_PAT 无效或过期

**解决**:
1. 重新创建 GitHub PAT: https://github.com/settings/tokens/new
2. 权限: ✅ repo
3. 更新 GitHub Secret: GH_PAT

### Q3: "Certificate limit reached"

**原因**: Apple 账号已有 2 个 Distribution 证书

**解决**:
- Match 会使用现有证书(不创建新的)
- 应该能正常继续
- 如果还是失败,需要删除 1 个旧证书

### Q4: "Invalid passphrase"

**原因**: MATCH_PASSWORD 不正确

**解决**:
1. 确认 GitHub Secret 中的 MATCH_PASSWORD 正确
2. 重新运行 workflow

---

## 📝 快速操作清单

### 准备阶段:

```
□ 创建 xDrip-Match-Secrets 仓库 (Private)
□ 验证 5 个 GitHub Secrets 都已配置
□ 推送代码到 GitHub
```

### 执行阶段:

```
□ 运行 "Initialize Fastlane Match Repository" workflow
□ 等待 5-10 分钟
□ 检查是否成功
```

### 验证阶段:

```
□ 查看 xDrip-Match-Secrets 仓库内容
□ 确认有证书和 5 个 Profiles
```

### 构建阶段:

```
□ 运行 "Build xDrip iOS IPA (with Fastlane Match)" workflow
□ 等待构建完成
□ 确认上传到 TestFlight
```

---

## 🎉 完成后

Match 初始化完成后:

✅ **自动化构建**: Push 代码自动触发构建  
✅ **自动上传**: 自动上传到 TestFlight  
✅ **简单维护**: 只需 5 个 GitHub Secrets  
✅ **团队协作**: 可以与团队共享证书  

---

## 🚀 现在开始!

### 第 1 步: 创建仓库
https://github.com/new

### 第 2 步: 推送代码
```bash
git push origin main
```

### 第 3 步: 运行初始化
https://github.com/q601180252/xdripios/actions

找到 "Initialize Fastlane Match Repository" → Run workflow

---

**准备好了吗?按照步骤开始配置!** 🚀

**完成每一步后告诉我进度!** 😊

