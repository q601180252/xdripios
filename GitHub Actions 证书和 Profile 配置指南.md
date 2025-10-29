# GitHub Actions 证书和 Provisioning Profile 配置指南 🔐

## 🔍 当前错误分析

GitHub Actions 构建失败，出现两个错误：

### 错误 1: 证书数量已达上限
```
Choose a certificate to revoke. Your account has reached the maximum number of certificates.
```

**原因**: Apple 限制每个账号最多只能有 **2 个 iOS Distribution 证书**

### 错误 2: 缺少 Provisioning Profiles
```
No profiles for 'com.HHZN32E89C.xdripswiftt1li23' were found
```

**原因**: Apple Developer Portal 中还没有为新的 Bundle IDs 创建 Provisioning Profiles

---

## ✅ 解决方案（分步执行）

### 步骤 1️⃣: 清理旧证书（解决证书数量上限）

#### 1.1 登录 Apple Developer Portal
```
https://developer.apple.com/account/resources/certificates/list
```

#### 1.2 查看现有证书
点击左侧 **"Certificates"**，查看您当前的证书：
- iOS Development 证书
- iOS Distribution 证书（App Store 和 Ad Hoc）

#### 1.3 删除不需要的证书
**重要提示**: 只删除您确认不再使用的证书！

找到**过期的**或**不使用的** iOS Distribution 证书：
1. 点击证书
2. 点击 "Revoke" 按钮
3. 确认删除

**建议**: 
- 保留最新的 1-2 个证书
- 删除过期的或旧项目的证书

---

### 步骤 2️⃣: 创建新的 iOS Distribution 证书

#### 2.1 在 Mac 上生成证书请求

**打开钥匙串访问** (Keychain Access):
```
应用程序 → 实用工具 → 钥匙串访问
```

**创建证书请求**:
```
钥匙串访问 → 证书助理 → 从证书颁发机构请求证书...

用户电子邮件地址: 您的 Apple ID 邮箱
常用名称: Yang Li iOS Distribution
CA 电子邮件地址: 留空
请求是: ✅ 存储到磁盘
✅ 让我指定密钥对信息

点击 "继续"

密钥大小: 2048 位
算法: RSA

点击 "继续"

保存为: YangLi_Distribution.certSigningRequest
保存位置: 桌面

点击 "存储"
```

#### 2.2 在 Apple Developer Portal 创建证书

**路径**: Certificates, Identifiers & Profiles → Certificates

```
1. 点击 "+" 按钮
2. 选择类型: "Apple Distribution"
3. 点击 "Continue"
4. 点击 "Choose File"
5. 选择刚才保存的 YangLi_Distribution.certSigningRequest
6. 点击 "Continue"
7. 点击 "Download" 下载证书（ios_distribution.cer）
```

#### 2.3 安装证书到 Mac

```
双击下载的 ios_distribution.cer 文件
证书会自动导入到钥匙串
```

---

### 步骤 3️⃣: 创建 Provisioning Profiles

**需要为 5 个 Bundle IDs 各创建 1 个 App Store Profile**

#### 3.1 主应用 Profile

**路径**: Certificates, Identifiers & Profiles → Profiles

```
1. 点击 "+" 按钮
2. 选择类型: "App Store"
3. 点击 "Continue"

4. 选择 App ID: com.HHZN32E89C.xdripswiftt1li23
5. 点击 "Continue"

6. 选择证书: 选择刚才创建的 Distribution 证书
7. 点击 "Continue"

8. Profile Name: xDrip App Store
9. 点击 "Generate"

10. 点击 "Download" 下载 Profile
    保存为: xDrip_AppStore.mobileprovision
```

#### 3.2 Widget Profile

重复上面的步骤，但修改为：
```
App ID: com.HHZN32E89C.xdripswiftt1li23.xDripWidget
Profile Name: xDrip Widget AppStore
下载为: xDrip_Widget_AppStore.mobileprovision
```

#### 3.3 Watch App Profile

```
App ID: com.HHZN32E89C.xdripswiftt1li23.watchkitapp
Profile Name: xDrip Watch App AppStore
下载为: xDrip_WatchApp_AppStore.mobileprovision
```

#### 3.4 Watch Complication Profile

```
App ID: com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication
Profile Name: xDrip Watch Complication AppStore
下载为: xDrip_WatchComplication_AppStore.mobileprovision
```

#### 3.5 Notification Extension Profile

```
App ID: com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension
Profile Name: xDrip Notification AppStore
下载为: xDrip_Notification_AppStore.mobileprovision
```

---

### 步骤 4️⃣: 导出证书和 Profiles 为 Base64

#### 4.1 导出证书

**在钥匙串访问中**:
```
1. 打开钥匙串访问
2. 左侧选择 "登录" → "我的证书"
3. 找到刚才导入的 "Apple Distribution: Yang Li (HHZN32E89C)"
4. 右键点击 → "导出..."
5. 文件格式: 个人信息交换 (.p12)
6. 保存为: YangLi_Distribution.p12
7. 设置密码（记住这个密码，后面需要用）
8. 点击 "存储"
```

**转换为 Base64**:
```bash
# 在终端执行
cd ~/Desktop  # 或您保存证书的目录

# 转换证书
base64 -i YangLi_Distribution.p12 | tr -d '\n' > YangLi_Distribution_base64.txt

# 查看内容（复制这个内容）
cat YangLi_Distribution_base64.txt
```

#### 4.2 转换 Provisioning Profiles 为 Base64

```bash
# 假设 Profiles 下载到 ~/Downloads
cd ~/Downloads

# 主应用
base64 -i xDrip_AppStore.mobileprovision | tr -d '\n' > xDrip_AppStore_base64.txt

# Widget
base64 -i xDrip_Widget_AppStore.mobileprovision | tr -d '\n' > xDrip_Widget_AppStore_base64.txt

# Watch App
base64 -i xDrip_WatchApp_AppStore.mobileprovision | tr -d '\n' > xDrip_WatchApp_AppStore_base64.txt

# Watch Complication
base64 -i xDrip_WatchComplication_AppStore.mobileprovision | tr -d '\n' > xDrip_WatchComplication_AppStore_base64.txt

# Notification
base64 -i xDrip_Notification_AppStore.mobileprovision | tr -d '\n' > xDrip_Notification_AppStore_base64.txt
```

---

### 步骤 5️⃣: 配置 GitHub Secrets

#### 5.1 访问 GitHub Secrets 设置
```
https://github.com/q601180252/xdripios/settings/secrets/actions
```

#### 5.2 添加证书相关 Secrets

点击 "New repository secret"，逐个添加：

##### 1. 证书文件（Base64）
```
Name: IOS_DISTRIBUTION_CERTIFICATE_BASE64
Value: <粘贴 YangLi_Distribution_base64.txt 的内容>
```

##### 2. 证书密码
```
Name: IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
Value: <您设置的 .p12 密码>
```

#### 5.3 添加 Provisioning Profiles Secrets

##### 3. 主应用 Profile
```
Name: IOS_PROVISIONING_PROFILE_MAIN_BASE64
Value: <粘贴 xDrip_AppStore_base64.txt 的内容>
```

##### 4. Widget Profile
```
Name: IOS_PROVISIONING_PROFILE_WIDGET_BASE64
Value: <粘贴 xDrip_Widget_AppStore_base64.txt 的内容>
```

##### 5. Watch App Profile
```
Name: IOS_PROVISIONING_PROFILE_WATCH_BASE64
Value: <粘贴 xDrip_WatchApp_AppStore_base64.txt 的内容>
```

##### 6. Watch Complication Profile
```
Name: IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
Value: <粘贴 xDrip_WatchComplication_AppStore_base64.txt 的内容>
```

##### 7. Notification Profile
```
Name: IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64
Value: <粘贴 xDrip_Notification_AppStore_base64.txt 的内容>
```

---

### 步骤 6️⃣: 更新 GitHub Actions Workflow

我会帮您创建一个新的 workflow，使用这些证书和 Profiles。

---

## ⚠️ 重要注意事项

### 关于证书数量限制

Apple 的证书限制：
- **iOS Development**: 每个账号最多 **10 个**
- **iOS Distribution**: 每个账号最多 **2 个**

如果达到上限：
1. 删除不使用的旧证书
2. 或者使用现有的证书（不创建新的）

### 关于证书密码

- 设置一个安全的密码
- 记录下来，后面配置 GitHub Secrets 需要用
- 不要分享给他人

### 关于 Provisioning Profiles

- **App Store Profiles**: 用于发布到 App Store 和 TestFlight
- **Development Profiles**: 用于开发和真机测试（GitHub Actions 不需要）

---

## 💡 简化方案：只为本地开发

如果您只想本地开发和 TestFlight 上传（不需要 GitHub Actions 自动化）:

**您已经完成了！** ✅

本地 Xcode 已经可以：
- ✅ 编译
- ✅ Archive
- ✅ 上传到 TestFlight

**GitHub Actions 配置是可选的**，只是为了实现自动化构建。

---

## 🎯 您的选择

### 选择 A: 配置 GitHub Actions 自动化（高级）

**优点**:
- ✅ 推送代码自动构建
- ✅ 自动上传到 TestFlight
- ✅ 团队协作更方便

**需要**:
- 清理旧证书（如果达到上限）
- 创建 5 个 Provisioning Profiles
- 配置 GitHub Secrets
- 更新 Workflow 文件

**预计时间**: 30-60 分钟

### 选择 B: 继续使用本地 Xcode（简单）

**优点**:
- ✅ 已经可以正常工作
- ✅ 不需要额外配置
- ✅ 更简单直接

**流程**:
```
修改代码 → Xcode Archive → Upload to TestFlight
```

**适合**: 个人开发者，不需要 CI/CD

---

## 📋 快速检查清单

如果选择配置 GitHub Actions:

- [ ] 登录 Apple Developer Portal
- [ ] 检查并清理旧证书（如果达到上限）
- [ ] 创建新的 iOS Distribution 证书
- [ ] 为 5 个 Bundle IDs 创建 Provisioning Profiles
- [ ] 导出证书为 .p12 并转换为 base64
- [ ] 转换 5 个 Profiles 为 base64
- [ ] 在 GitHub 添加 7 个 Secrets
- [ ] 更新 Workflow 文件
- [ ] 重新运行 GitHub Actions

---

**您想选择哪个方案？**

- **A**: 配置 GitHub Actions 自动化（我会继续指导）
- **B**: 继续使用本地 Xcode（已经成功，无需额外配置）

请告诉我您的选择！😊

