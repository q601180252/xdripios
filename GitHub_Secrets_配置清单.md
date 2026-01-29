# GitHub Secrets 配置清单 - 完整对应关系 🔐

## 📍 配置位置

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

点击 **"New repository secret"** 逐个添加以下 7 个 Secrets

---

## 📋 必须配置的 7 个 Secrets

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 1️⃣ IOS_DISTRIBUTION_CERTIFICATE_BASE64
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Secret Name** (完全一致,包括大小写):
```
IOS_DISTRIBUTION_CERTIFICATE_BASE64
```

**Value 来源**:
```
1. 从钥匙串导出的证书文件: Distribution_Certificate.p12
2. 转换为 base64: base64 -i Distribution_Certificate.p12 | tr -d '\n'
3. 或使用脚本: ./convert_profiles_to_base64.sh
   输出文件: ~/Desktop/xdrip_profiles_base64/cert_base64.txt
```

**获取 Value 的命令**:
```bash
# 方式 1: 如果已运行脚本
cat ~/Desktop/xdrip_profiles_base64/cert_base64.txt | pbcopy
# 内容已复制到剪贴板,直接粘贴到 GitHub

# 方式 2: 手动转换(证书在桌面)
cd ~/Desktop
base64 -i Distribution_Certificate.p12 | tr -d '\n' | pbcopy
# 内容已复制到剪贴板
```

**Value 特征**:
- 长度: 几千个字符(很长)
- 格式: 只包含 A-Z, a-z, 0-9, +, /, = 字符
- 无空格,无换行

**示例** (实际会更长):
```
MIIJqQIBAzCCCW8GCSqGSIb3DQEHAaCCCWAEgglcMIIJWDCCA...
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 2️⃣ IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Secret Name**:
```
IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
```

**Value 来源**:
```
您在钥匙串访问中导出证书为 .p12 时设置的密码
```

**Value 就是**:
```
您自己设置的密码(例如: MySecurePassword123)
```

**重要**:
- ⚠️ 这是您在导出证书时输入的密码
- ⚠️ 必须完全一致,否则无法解密证书
- ⚠️ 如果忘记密码,需要重新导出证书

**示例**:
```
MySecurePassword123
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 3️⃣ IOS_PROVISIONING_PROFILE_MAIN_BASE64
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Secret Name**:
```
IOS_PROVISIONING_PROFILE_MAIN_BASE64
```

**对应的 Bundle ID**:
```
com.HHZN32E89C.xdripswiftt1li23
```

**对应的 Profile 名称** (在 Apple Developer Portal 创建时的名称):
```
xDrip Main App Store
```

**Value 来源**:
```
1. Apple Developer Portal 下载的文件:
   xDrip_Main_AppStore.mobileprovision (或您命名的任何 .mobileprovision 文件)
   
2. 转换为 base64:
   base64 -i xDrip_Main_AppStore.mobileprovision | tr -d '\n'
   
3. 或使用脚本输出:
   ~/Desktop/xdrip_profiles_base64/profile_main.txt
```

**获取 Value 的命令**:
```bash
# 方式 1: 如果已运行脚本
cat ~/Desktop/xdrip_profiles_base64/profile_main.txt | pbcopy

# 方式 2: 手动转换(文件在下载文件夹)
cd ~/Downloads
base64 -i xDrip_Main_AppStore.mobileprovision | tr -d '\n' | pbcopy
```

**Value 特征**:
- 长度: 几千个字符
- 格式: base64 字符
- 单行,无换行

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 4️⃣ IOS_PROVISIONING_PROFILE_WIDGET_BASE64
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Secret Name**:
```
IOS_PROVISIONING_PROFILE_WIDGET_BASE64
```

**对应的 Bundle ID**:
```
com.HHZN32E89C.xdripswiftt1li23.xDripWidget
```

**对应的 Profile 名称**:
```
xDrip Widget App Store
```

**Value 来源**:
```
1. 下载的文件: xDrip_Widget_AppStore.mobileprovision
2. 或脚本输出: ~/Desktop/xdrip_profiles_base64/profile_widget.txt
```

**获取 Value 的命令**:
```bash
# 使用脚本输出
cat ~/Desktop/xdrip_profiles_base64/profile_widget.txt | pbcopy

# 或手动转换
base64 -i ~/Downloads/xDrip_Widget_AppStore.mobileprovision | tr -d '\n' | pbcopy
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 5️⃣ IOS_PROVISIONING_PROFILE_WATCH_BASE64
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Secret Name**:
```
IOS_PROVISIONING_PROFILE_WATCH_BASE64
```

**对应的 Bundle ID**:
```
com.HHZN32E89C.xdripswiftt1li23.watchkitapp
```

**对应的 Profile 名称**:
```
xDrip Watch App Store
```

**Value 来源**:
```
1. 下载的文件: xDrip_WatchApp_AppStore.mobileprovision
2. 或脚本输出: ~/Desktop/xdrip_profiles_base64/profile_watch.txt
```

**获取 Value 的命令**:
```bash
# 使用脚本输出
cat ~/Desktop/xdrip_profiles_base64/profile_watch.txt | pbcopy

# 或手动转换
base64 -i ~/Downloads/xDrip_WatchApp_AppStore.mobileprovision | tr -d '\n' | pbcopy
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 6️⃣ IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Secret Name**:
```
IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
```

**对应的 Bundle ID**:
```
com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication
```

**对应的 Profile 名称**:
```
xDrip Watch Complication App Store
```

**Value 来源**:
```
1. 下载的文件: xDrip_WatchComplication_AppStore.mobileprovision
2. 或脚本输出: ~/Desktop/xdrip_profiles_base64/profile_complication.txt
```

**获取 Value 的命令**:
```bash
# 使用脚本输出
cat ~/Desktop/xdrip_profiles_base64/profile_complication.txt | pbcopy

# 或手动转换
base64 -i ~/Downloads/xDrip_WatchComplication_AppStore.mobileprovision | tr -d '\n' | pbcopy
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### 7️⃣ IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Secret Name**:
```
IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64
```

**对应的 Bundle ID**:
```
com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension
```

**对应的 Profile 名称**:
```
xDrip Notification App Store
```

**Value 来源**:
```
1. 下载的文件: xDrip_Notification_AppStore.mobileprovision
2. 或脚本输出: ~/Desktop/xdrip_profiles_base64/profile_notification.txt
```

**获取 Value 的命令**:
```bash
# 使用脚本输出
cat ~/Desktop/xdrip_profiles_base64/profile_notification.txt | pbcopy

# 或手动转换
base64 -i ~/Downloads/xDrip_Notification_AppStore.mobileprovision | tr -d '\n' | pbcopy
```

---

## 📊 完整对照表

| # | Secret Name | 对应内容 | 来源文件 |
|---|------------|---------|----------|
| 1 | `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Distribution 证书 | `Distribution_Certificate.p12` |
| 2 | `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | 证书密码 | 您设置的密码 |
| 3 | `IOS_PROVISIONING_PROFILE_MAIN_BASE64` | 主应用 Profile | `xDrip_Main_AppStore.mobileprovision` |
| 4 | `IOS_PROVISIONING_PROFILE_WIDGET_BASE64` | Widget Profile | `xDrip_Widget_AppStore.mobileprovision` |
| 5 | `IOS_PROVISIONING_PROFILE_WATCH_BASE64` | Watch App Profile | `xDrip_WatchApp_AppStore.mobileprovision` |
| 6 | `IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64` | Watch Complication Profile | `xDrip_WatchComplication_AppStore.mobileprovision` |
| 7 | `IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64` | Notification Profile | `xDrip_Notification_AppStore.mobileprovision` |

---

## 🚀 快速配置流程

### 步骤 1: 确保文件已准备好

**需要的文件**:
```
✅ ~/Desktop/Distribution_Certificate.p12 (证书)
✅ ~/Downloads/xDrip_Main_AppStore.mobileprovision
✅ ~/Downloads/xDrip_Widget_AppStore.mobileprovision
✅ ~/Downloads/xDrip_WatchApp_AppStore.mobileprovision
✅ ~/Downloads/xDrip_WatchComplication_AppStore.mobileprovision
✅ ~/Downloads/xDrip_Notification_AppStore.mobileprovision
```

### 步骤 2: 运行转换脚本(推荐)

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios
./convert_profiles_to_base64.sh
```

所有 base64 文件会生成到:
```
~/Desktop/xdrip_profiles_base64/
  - cert_base64.txt
  - profile_main.txt
  - profile_widget.txt
  - profile_watch.txt
  - profile_complication.txt
  - profile_notification.txt
```

### 步骤 3: 逐个配置 GitHub Secrets

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

**对于每个 Secret**:

1. 点击 **"New repository secret"**

2. **Name**: 输入 Secret 名称(完全一致)
   ```
   例如: IOS_DISTRIBUTION_CERTIFICATE_BASE64
   ```

3. **Value**: 复制对应的 base64 内容
   ```bash
   # 例如,对于证书:
   cat ~/Desktop/xdrip_profiles_base64/cert_base64.txt | pbcopy
   # 然后在 GitHub 粘贴 (Command + V)
   ```

4. 点击 **"Add secret"**

5. 重复 1-4 步骤,直到添加完所有 7 个 Secrets

---

## ✅ 验证配置

配置完成后,在 Secrets 页面应该看到:

```
Repository secrets (7)

IOS_DISTRIBUTION_CERTIFICATE_BASE64              Updated now
IOS_DISTRIBUTION_CERTIFICATE_PASSWORD            Updated now
IOS_PROVISIONING_PROFILE_MAIN_BASE64            Updated now
IOS_PROVISIONING_PROFILE_WIDGET_BASE64          Updated now
IOS_PROVISIONING_PROFILE_WATCH_BASE64           Updated now
IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64  Updated now
IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64    Updated now
```

✅ **全部 7 个都显示 = 配置完成!**

---

## ⚠️ 常见错误

### 错误 1: Secret 名称不对
```
❌ ios_distribution_certificate_base64  (全小写)
❌ IOS_DIST_CERT_BASE64                  (缩写)
✅ IOS_DISTRIBUTION_CERTIFICATE_BASE64   (完全一致)
```

### 错误 2: Base64 有换行
```
❌ MIIJqQIBAzCC
   CW8GCSqGSI
   (多行)

✅ MIIJqQIBAzCCCW8GCSqGSI... (单行)
```

解决: 使用 `| tr -d '\n'` 或脚本生成的文件

### 错误 3: 密码错误
```
❌ 输入了错误的密码
✅ 必须是导出 .p12 时设置的密码
```

如果忘记密码: 需要重新导出证书

---

## 📞 配置完成后

1. **推送代码**: `git push origin main`
2. **观察构建**: https://github.com/q601180252/xdripios/actions
3. **等待成功**: 看到 "** ARCHIVE SUCCEEDED **"

如果失败,查看日志并告诉我! 😊

---

## 🎯 关键提醒

1. ⚠️ **Secret 名称必须完全一致** (大小写敏感)
2. ⚠️ **Base64 内容必须单行** (无换行符)
3. ⚠️ **证书密码必须正确**
4. ⚠️ **所有 7 个都必须配置**

**缺少任何一个 = 构建失败!**

---

**现在可以开始配置了!** 🚀

