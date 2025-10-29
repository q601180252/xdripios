# GitHub Secrets 配置验证清单 ✅

## 📋 需要配置的 7 个 Secrets

访问: https://github.com/q601180252/xdripios/settings/secrets/actions

### 必需的 Secrets

#### 1️⃣ IOS_DISTRIBUTION_CERTIFICATE_BASE64
```
内容: 证书的 base64 编码
来源: 从 Distribution_Certificate.p12 转换而来

验证:
- 长度应该很长(几千个字符)
- 只包含字母、数字、+、/、= 字符
- 没有空格和换行
```

#### 2️⃣ IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
```
内容: 导出 .p12 时设置的密码
来源: 您在导出证书时输入的密码

验证:
- 这是一个字符串密码
- 记住这个密码很重要
```

#### 3️⃣ IOS_PROVISIONING_PROFILE_MAIN_BASE64
```
内容: 主应用 Provisioning Profile 的 base64
Bundle ID: com.HHZN32E89C.xdripswiftt1li23
文件名: xDrip_Main_AppStore.mobileprovision

验证:
- 长度应该几千个字符
- 只包含 base64 字符
```

#### 4️⃣ IOS_PROVISIONING_PROFILE_WIDGET_BASE64
```
内容: Widget Extension Profile 的 base64
Bundle ID: com.HHZN32E89C.xdripswiftt1li23.xDripWidget
文件名: xDrip_Widget_AppStore.mobileprovision

验证:
- 长度应该几千个字符
- 只包含 base64 字符
```

#### 5️⃣ IOS_PROVISIONING_PROFILE_WATCH_BASE64
```
内容: Watch App Profile 的 base64
Bundle ID: com.HHZN32E89C.xdripswiftt1li23.watchkitapp
文件名: xDrip_WatchApp_AppStore.mobileprovision

验证:
- 长度应该几千个字符
- 只包含 base64 字符
```

#### 6️⃣ IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
```
内容: Watch Complication Profile 的 base64
Bundle ID: com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication
文件名: xDrip_WatchComplication_AppStore.mobileprovision

验证:
- 长度应该几千个字符
- 只包含 base64 字符
```

#### 7️⃣ IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64
```
内容: Notification Extension Profile 的 base64
Bundle ID: com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension
文件名: xDrip_Notification_AppStore.mobileprovision

验证:
- 长度应该几千个字符
- 只包含 base64 字符
```

---

## ✅ 快速验证检查清单

### 在 GitHub Secrets 页面检查:

```
访问: https://github.com/q601180252/xdripios/settings/secrets/actions

应该看到 7 个 Secrets:

□ IOS_DISTRIBUTION_CERTIFICATE_BASE64
□ IOS_DISTRIBUTION_CERTIFICATE_PASSWORD  
□ IOS_PROVISIONING_PROFILE_MAIN_BASE64
□ IOS_PROVISIONING_PROFILE_WIDGET_BASE64
□ IOS_PROVISIONING_PROFILE_WATCH_BASE64
□ IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64
□ IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64

✅ 全部配置 = 可以构建
❌ 缺少任何一个 = 构建会失败
```

---

## 🔍 常见问题

### Q1: Secret 名称必须完全一致吗?
**A**: 是的!必须**完全一致**,包括大小写。

错误示例:
- ❌ `ios_distribution_certificate_base64` (小写)
- ❌ `IOS_DISTRIBUTION_CERT_BASE64` (缩写)
- ❌ `CERTIFICATE_BASE64` (缺少前缀)

正确示例:
- ✅ `IOS_DISTRIBUTION_CERTIFICATE_BASE64`

### Q2: Base64 内容可以有换行吗?
**A**: 不可以!必须是**单行**,没有任何换行符。

如果使用了我的脚本:
```bash
./convert_profiles_to_base64.sh
```
生成的 base64 文件已经是单行的。

手动转换命令(确保单行):
```bash
base64 -i file.mobileprovision | tr -d '\n'
```

### Q3: 如何验证 base64 是否正确?
**A**: 在终端测试解码:

```bash
# 测试证书
echo "你的base64内容" | base64 --decode > test.p12
file test.p12
# 应该显示: test.p12: data

# 测试 Profile
echo "你的base64内容" | base64 --decode > test.mobileprovision  
file test.mobileprovision
# 应该显示: test.mobileprovision: Apple binary property list
```

### Q4: 密码特殊字符会有问题吗?
**A**: 通常不会,但建议密码:
- 包含大小写字母、数字
- 避免单引号 `'` 和双引号 `"`
- 避免反斜杠 `\`

### Q5: 配置完 Secrets 后需要等待吗?
**A**: 不需要,立即生效。

配置完成后:
1. Push 代码到 GitHub
2. GitHub Actions 会自动触发
3. 或者手动触发 workflow

---

## 🚀 配置完成后的步骤

### 1. 推送更新的代码

```bash
git push origin main
```

### 2. 观察 GitHub Actions 运行

```
访问: https://github.com/q601180252/xdripios/actions

应该看到:
- 新的 workflow run 开始
- 绿色进度条(如果成功)
- 或者红色(如果失败,查看日志)
```

### 3. 如果失败,检查日志

常见错误提示:
```
❌ "Failed to decode certificate"
   → 检查 IOS_DISTRIBUTION_CERTIFICATE_BASE64

❌ "Wrong password for certificate"  
   → 检查 IOS_DISTRIBUTION_CERTIFICATE_PASSWORD

❌ "Profile not found" 或 "No suitable profile"
   → 检查对应的 PROFILE_*_BASE64 Secrets
```

---

## 📞 需要帮助?

如果遇到问题:

1. **检查 Secret 名称**: 完全一致(大小写)
2. **检查 base64 格式**: 单行,无换行
3. **检查文件完整性**: 重新转换 base64
4. **查看 Actions 日志**: 具体错误信息

告诉我错误日志,我会帮您解决! 😊

---

## 🎉 成功的标志

GitHub Actions 日志中应该看到:

```
✅ 主应用 Profile 已安装
✅ Widget Profile 已安装  
✅ Watch App Profile 已安装
✅ Watch Complication Profile 已安装
✅ Notification Profile 已安装
✅ 证书和 Provisioning Profiles 安装完成

...

** ARCHIVE SUCCEEDED **

...

IPA 已上传到 TestFlight!
```

---

**现在可以推送代码并测试构建了!** 🚀

