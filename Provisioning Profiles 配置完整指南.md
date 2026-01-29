# Provisioning Profiles 配置完整指南 🔐

## 🎯 目标

为 GitHub Actions 配置 Provisioning Profiles，使其能够自动构建和上传 IPA。

**需要创建**: 5 个 App Store Provisioning Profiles（对应 5 个 Bundle IDs）

---

## 📋 前提条件检查

在开始之前，确认：
- [ ] 有 Apple Developer Program 会员资格（$99/年）
- [ ] 可以登录 https://developer.apple.com/account
- [ ] 已在 Developer Portal 创建了 5 个 Bundle IDs
- [ ] 已创建了 App Group

---

## 🚀 完整步骤（分为 4 个阶段）

### ═══════════════════════════════════════════════════════════════════
### 阶段 1️⃣: 检查并清理证书（重要！）
### ═══════════════════════════════════════════════════════════════════

#### 步骤 1.1: 登录 Apple Developer Portal

访问：https://developer.apple.com/account/resources/certificates/list

#### 步骤 1.2: 查看当前证书

点击左侧 **"Certificates"**，查看证书列表。

**重要**: Apple 限制每个账号最多只能有 **2 个 iOS Distribution 证书**！

#### 步骤 1.3: 删除旧证书（如果已有 2 个）

如果您已经有 2 个 **iOS Distribution** 证书：

1. **识别要删除的证书**：
   - 查看证书的 "Expiration Date"（过期日期）
   - 查看证书的 "Name"（名称）
   - 选择**过期的**或**不使用的**证书

2. **删除证书**：
   ```
   点击证书名称 → 点击 "Revoke" 按钮 → 确认删除
   ```

**建议**: 删除 1 个旧证书，保留 1 个，这样可以创建 1 个新的。

---

### ═══════════════════════════════════════════════════════════════════
### 阶段 2️⃣: 创建 iOS Distribution 证书
### ═══════════════════════════════════════════════════════════════════

#### 步骤 2.1: 在 Mac 上生成证书请求（CSR）

**打开钥匙串访问**:
```
启动台 → 其他 → 钥匙串访问
或者
应用程序 → 实用工具 → 钥匙串访问
```

**创建证书请求**:
```
菜单栏: 钥匙串访问 → 证书助理 → 从证书颁发机构请求证书...
```

**填写信息**:
```
用户电子邮件地址: 您的 Apple ID 邮箱（例如: your@email.com）
常用名称: Yang Li iOS Distribution
CA 电子邮件地址: 留空（不填）

请求是:
  ✅ 存储到磁盘

☑️ 让我指定密钥对信息（勾选这个）

点击 "继续"
```

**密钥设置**:
```
密钥大小: 2048 位
算法: RSA

点击 "继续"
```

**保存文件**:
```
保存为: CertificateSigningRequest.certSigningRequest
保存位置: 桌面

点击 "存储"
```

✅ **现在桌面上应该有一个 CertificateSigningRequest.certSigningRequest 文件**

#### 步骤 2.2: 在 Apple Developer Portal 创建证书

**访问**: https://developer.apple.com/account/resources/certificates/list

**创建证书**:
```
1. 点击左上角的 "+" 按钮

2. 选择证书类型:
   找到 "Software" 部分
   ✅ 选择 "Apple Distribution"
   
   点击 "Continue"

3. 上传 CSR 文件:
   点击 "Choose File"
   选择刚才保存的 CertificateSigningRequest.certSigningRequest
   
   点击 "Continue"

4. 下载证书:
   证书创建完成
   点击 "Download"
   保存为: ios_distribution.cer
   
   ✅ 证书已下载
```

#### 步骤 2.3: 安装证书到 Mac

```
1. 在 Finder 中找到下载的 ios_distribution.cer
2. 双击文件
3. 证书会自动导入到 "钥匙串访问" → "登录" → "我的证书"

✅ 现在您应该能在钥匙串中看到:
   "Apple Distribution: Yang Li (HHZN32E89C)"
```

---

### ═══════════════════════════════════════════════════════════════════
### 阶段 3️⃣: 创建 5 个 Provisioning Profiles
### ═══════════════════════════════════════════════════════════════════

**访问**: https://developer.apple.com/account/resources/profiles/list

需要创建 **5 个 App Store Provisioning Profiles**：

---

#### Profile 1: 主应用 Profile

```
1. 点击 "+" 按钮

2. 选择类型:
   Distribution 部分
   ✅ 选择 "App Store"
   点击 "Continue"

3. 选择 App ID:
   从下拉菜单选择:
   ✅ com.HHZN32E89C.xdripswiftt1li23
   点击 "Continue"

4. 选择证书:
   ✅ 勾选刚才创建的 Distribution 证书
      (Apple Distribution: Yang Li)
   点击 "Continue"

5. 命名 Profile:
   Provisioning Profile Name: xDrip Main App Store
   
   点击 "Generate"

6. 下载 Profile:
   点击 "Download"
   保存为: xDrip_Main_AppStore.mobileprovision
   
   ✅ Profile 1/5 已创建
```

---

#### Profile 2: Widget Extension Profile

```
1. 点击 "+" 按钮
2. 选择 "App Store"
3. App ID: com.HHZN32E89C.xdripswiftt1li23.xDripWidget
4. 选择证书: Apple Distribution: Yang Li
5. Profile Name: xDrip Widget App Store
6. Download 保存为: xDrip_Widget_AppStore.mobileprovision

✅ Profile 2/5 已创建
```

---

#### Profile 3: Watch App Profile

```
1. 点击 "+" 按钮
2. 选择 "App Store"
3. App ID: com.HHZN32E89C.xdripswiftt1li23.watchkitapp
4. 选择证书: Apple Distribution: Yang Li
5. Profile Name: xDrip Watch App Store
6. Download 保存为: xDrip_WatchApp_AppStore.mobileprovision

✅ Profile 3/5 已创建
```

---

#### Profile 4: Watch Complication Profile

```
1. 点击 "+" 按钮
2. 选择 "App Store"
3. App ID: com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication
4. 选择证书: Apple Distribution: Yang Li
5. Profile Name: xDrip Watch Complication App Store
6. Download 保存为: xDrip_WatchComplication_AppStore.mobileprovision

✅ Profile 4/5 已创建
```

---

#### Profile 5: Notification Extension Profile

```
1. 点击 "+" 按钮
2. 选择 "App Store"
3. App ID: com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension
4. 选择证书: Apple Distribution: Yang Li
5. Profile Name: xDrip Notification App Store
6. Download 保存为: xDrip_Notification_AppStore.mobileprovision

✅ Profile 5/5 已创建！所有 Profiles 已完成！
```

---

### ═══════════════════════════════════════════════════════════════════
### 阶段 4️⃣: 导出证书和 Profiles 为 Base64
### ═══════════════════════════════════════════════════════════════════

#### 步骤 4.1: 导出证书为 .p12 格式

**在钥匙串访问中**:
```
1. 打开 钥匙串访问
2. 左侧选择 "登录"
3. 左侧选择 "我的证书"
4. 找到 "Apple Distribution: Yang Li (HHZN32E89C)"
5. ⚠️ 重要：展开证书（点击左侧三角形），确保同时选中证书和私钥
6. 右键点击证书 → 选择 "导出 2 项..."
   （或者选中后，菜单栏: 文件 → 导出项目...）
7. 文件格式: 个人信息交换 (.p12)
8. 存储为: Distribution_Certificate.p12
9. 位置: 桌面
10. 点击 "存储"

11. 设置密码:
    输入密码: （例如: MySecurePassword123）
    验证: （再次输入相同密码）
    ⚠️ 记住这个密码，后面需要用！
    
    点击 "好"

12. 可能需要输入 Mac 登录密码
    输入后点击 "允许"

✅ 桌面上应该有 Distribution_Certificate.p12 文件
```

#### 步骤 4.2: 转换证书为 Base64

**打开终端**，执行：

```bash
# 进入桌面（假设文件都在桌面）
cd ~/Desktop

# 转换证书为 base64（单行，无换行）
base64 -i Distribution_Certificate.p12 | tr -d '\n' > cert_base64.txt

# 查看内容（这是一长串字符）
cat cert_base64.txt

# 复制内容（自动复制到剪贴板）
cat cert_base64.txt | pbcopy

echo "✅ 证书 base64 已复制到剪贴板！"
```

✅ **证书 base64 已准备好（在剪贴板中）**

#### 步骤 4.3: 转换 5 个 Provisioning Profiles 为 Base64

**确保所有 .mobileprovision 文件都在 ~/Downloads**

在终端执行：

```bash
# 进入下载目录
cd ~/Downloads

# 创建一个目录存放所有 base64 文件
mkdir -p ~/Desktop/profiles_base64
cd ~/Desktop/profiles_base64

# 转换 Profile 1: 主应用
base64 -i ~/Downloads/xDrip_Main_AppStore.mobileprovision | tr -d '\n' > profile_main.txt

# 转换 Profile 2: Widget
base64 -i ~/Downloads/xDrip_Widget_AppStore.mobileprovision | tr -d '\n' > profile_widget.txt

# 转换 Profile 3: Watch App
base64 -i ~/Downloads/xDrip_WatchApp_AppStore.mobileprovision | tr -d '\n' > profile_watch.txt

# 转换 Profile 4: Watch Complication
base64 -i ~/Downloads/xDrip_WatchComplication_AppStore.mobileprovision | tr -d '\n' > profile_complication.txt

# 转换 Profile 5: Notification
base64 -i ~/Downloads/xDrip_Notification_AppStore.mobileprovision | tr -d '\n' > profile_notification.txt

echo "✅ 所有 Profiles 已转换为 base64！"
echo "文件位置: ~/Desktop/profiles_base64/"
ls -lh
```

✅ **现在 ~/Desktop/profiles_base64/ 目录下有 5 个 .txt 文件**

---

### ═══════════════════════════════════════════════════════════════════
### 阶段 5️⃣: 配置 GitHub Secrets
### ═══════════════════════════════════════════════════════════════════

#### 步骤 5.1: 访问 GitHub Secrets 设置

```
https://github.com/q601180252/xdripios/settings/secrets/actions
```

#### 步骤 5.2: 添加证书相关 Secrets

需要添加 **7 个 Secrets**：

---

**Secret 1: 证书文件（Base64）**
```
1. 点击 "New repository secret"

2. 填写:
   Name: IOS_DISTRIBUTION_CERTIFICATE_BASE64
   
   Value: （粘贴 cert_base64.txt 的内容）
   
   如何获取内容:
   - 终端执行: cat ~/Desktop/cert_base64.txt | pbcopy
   - 或者用文本编辑器打开 cert_base64.txt，复制全部内容
   
3. 点击 "Add secret"

✅ Secret 1/7 已添加
```

---

**Secret 2: 证书密码**
```
1. 点击 "New repository secret"

2. 填写:
   Name: IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
   
   Value: （您在步骤 4.1 设置的密码，例如: MySecurePassword123）
   
3. 点击 "Add secret"

✅ Secret 2/7 已添加
```

---

**Secret 3: 主应用 Profile**
```
1. 点击 "New repository secret"

2. 填写:
   Name: IOS_PROVISIONING_PROFILE_MAIN_BASE64
   
   Value: 
   - 终端执行: cat ~/Desktop/profiles_base64/profile_main.txt | pbcopy
   - 粘贴到 Value 框
   
3. 点击 "Add secret"

✅ Secret 3/7 已添加
```

---

**Secret 4: Widget Profile**
```
1. 点击 "New repository secret"

2. 填写:
   Name: IOS_PROVISIONING_PROFILE_WIDGET_BASE64
   
   Value:
   - 终端执行: cat ~/Desktop/profiles_base64/profile_widget.txt | pbcopy
   - 粘贴
   
3. 点击 "Add secret"

✅ Secret 4/7 已添加
```

---

**Secret 5: Watch App Profile**
```
1. 点击 "New repository secret"

2. 填写:
   Name: IOS_PROVISIONING_PROFILE_WATCH_BASE64
   
   Value:
   - 终端执行: cat ~/Desktop/profiles_base64/profile_watch.txt | pbcopy
   - 粘贴
   
3. 点击 "Add secret"

✅ Secret 5/7 已添加
```

---

**Secret 6: Watch Complication Profile**
```
1. 点击 "New repository secret"

2. 填写:
   Name: IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
   
   Value:
   - 终端执行: cat ~/Desktop/profiles_base64/profile_complication.txt | pbcopy
   - 粘贴
   
3. 点击 "Add secret"

✅ Secret 6/7 已添加
```

---

**Secret 7: Notification Extension Profile**
```
1. 点击 "New repository secret"

2. 填写:
   Name: IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64
   
   Value:
   - 终端执行: cat ~/Desktop/profiles_base64/profile_notification.txt | pbcopy
   - 粘贴
   
3. 点击 "Add secret"

✅ Secret 7/7 已添加！所有 Secrets 配置完成！
```

---

### ═══════════════════════════════════════════════════════════════════
### 阶段 6️⃣: 更新 GitHub Actions Workflow
### ═══════════════════════════════════════════════════════════════════

我会帮您更新 workflow 文件，添加证书和 Profile 安装步骤。

---

## 📝 快速检查清单

### 阶段 1: 证书清理
- [ ] 登录 Apple Developer Portal
- [ ] 查看现有证书数量
- [ ] 如果有 2 个 Distribution 证书，删除 1 个旧的

### 阶段 2: 创建证书
- [ ] 在钥匙串访问中生成 CSR 文件
- [ ] 在 Developer Portal 创建 Apple Distribution 证书
- [ ] 下载并安装证书（双击 .cer 文件）
- [ ] 验证证书已导入到钥匙串

### 阶段 3: 创建 Profiles
- [ ] Profile 1: 主应用 (com.HHZN32E89C.xdripswiftt1li23)
- [ ] Profile 2: Widget (com.HHZN32E89C.xdripswiftt1li23.xDripWidget)
- [ ] Profile 3: Watch App (com.HHZN32E89C.xdripswiftt1li23.watchkitapp)
- [ ] Profile 4: Watch Complication (...watchkitapp.xDripWatchComplication)
- [ ] Profile 5: Notification (...xDripNotificationContextExtension)

### 阶段 4: 导出为 Base64
- [ ] 从钥匙串导出证书为 .p12（记住密码！）
- [ ] 转换证书为 base64
- [ ] 转换 5 个 Profiles 为 base64

### 阶段 5: 配置 GitHub Secrets
- [ ] Secret 1: IOS_DISTRIBUTION_CERTIFICATE_BASE64
- [ ] Secret 2: IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
- [ ] Secret 3: IOS_PROVISIONING_PROFILE_MAIN_BASE64
- [ ] Secret 4: IOS_PROVISIONING_PROFILE_WIDGET_BASE64
- [ ] Secret 5: IOS_PROVISIONING_PROFILE_WATCH_BASE64
- [ ] Secret 6: IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
- [ ] Secret 7: IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64

### 阶段 6: 更新 Workflow
- [ ] 等待我更新 workflow 文件
- [ ] 推送更新到 GitHub
- [ ] 重新运行 GitHub Actions

---

## ⚠️ 常见问题

### Q1: 找不到 Bundle ID 怎么办？
**A**: 需要先在 Developer Portal 创建 Bundle IDs
- 访问: https://developer.apple.com/account/resources/identifiers/list
- 查看 `App Store Connect 配置指南 - Yang Li Team.md`

### Q2: 证书导出时没有 "导出 2 项" 选项？
**A**: 说明私钥不在钥匙串中
- 确保展开证书（点击左侧三角形）
- 应该看到证书下面有一个私钥
- 同时选中证书和私钥，然后右键导出

### Q3: 下载的 Profile 文件名不一样？
**A**: 文件名可以自己修改
- 重要的是文件内容，不是文件名
- 转换为 base64 时使用实际的文件名

### Q4: Base64 内容太长，粘贴不了？
**A**: GitHub Secrets 支持很大的内容
- 确保复制了完整内容
- 使用 `| pbcopy` 自动复制到剪贴板
- 直接 ⌘V 粘贴到 GitHub

---

## 💡 提示

### 保存重要信息

创建一个文本文件保存：
```
证书密码: MySecurePassword123
证书文件: Distribution_Certificate.p12
创建日期: 2025-10-29
过期日期: 2026-10-29 (一年后)

Provisioning Profiles:
- xDrip_Main_AppStore.mobileprovision
- xDrip_Widget_AppStore.mobileprovision
- xDrip_WatchApp_AppStore.mobileprovision
- xDrip_WatchComplication_AppStore.mobileprovision
- xDrip_Notification_AppStore.mobileprovision
```

**保存在安全的地方！**

### 证书过期怎么办？

Distribution 证书有效期是 **1 年**。

过期前：
1. 重复阶段 2 创建新证书
2. 重复阶段 3 创建新 Profiles（使用新证书）
3. 更新 GitHub Secrets

---

## 🎯 完成后

当所有 GitHub Secrets 配置完成后：

1. **告诉我** - 我会更新 workflow 文件
2. **推送更新** - 推送 workflow 到 GitHub
3. **运行 Action** - 在 GitHub 重新运行构建
4. **等待成功** - 应该能成功构建并上传到 TestFlight

---

**现在请按照上面的 6 个阶段逐步操作！** 🚀

**每完成一个阶段，告诉我进度，我会继续指导下一步！** 😊

---

## 📞 需要帮助？

如果遇到任何问题：
1. 截图发给我
2. 告诉我具体的错误信息
3. 告诉我当前在哪个步骤

我会立即帮您解决！

