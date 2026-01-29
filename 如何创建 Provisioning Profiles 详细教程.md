# 如何创建 Provisioning Profiles - 详细图文教程 📱

## 🎯 什么是 Provisioning Profile？

Provisioning Profile（配置描述文件）是一个文件，它将以下内容绑定在一起：
- **App ID**（Bundle ID）
- **开发者证书**（Certificates）
- **设备**（仅开发环境需要）
- **权限**（Capabilities，如 App Groups、HealthKit）

没有它，您的应用无法在设备上运行或发布到 App Store。

---

## 📋 前提条件

在创建 Provisioning Profiles 之前，您需要：

### 1️⃣ 已创建 Bundle IDs
- ✅ com.7RV2Y67HF6.xdripswiftt1li23
- ✅ com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget
- ✅ com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp
- ✅ com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication
- ✅ com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension

### 2️⃣ 已有开发者证书
- **Development Certificate**（开发证书）
- **Distribution Certificate**（分发证书）

如果没有证书，需要先创建证书。

---

## 🔧 创建证书（如果还没有）

### 访问证书页面
https://developer.apple.com/account/resources/certificates/list

### 创建开发证书（Development）

1. **点击左上角 "+" 按钮**

2. **选择证书类型**
   ```
   ✅ Apple Development
   (用于开发和测试)
   ```

3. **点击 "Continue"**

4. **上传 CSR 文件**
   
   如果您没有 CSR 文件，需要在 Mac 上创建：
   
   #### 创建 CSR 的步骤：
   
   a. 打开 **"钥匙串访问"** 应用（Keychain Access）
   
   b. 菜单栏：**钥匙串访问 → 证书助理 → 从证书颁发机构请求证书...**
   
   c. 填写信息：
   ```
   用户电子邮件地址: 您的 Apple ID 邮箱
   常用名称: 您的名字
   CA 电子邮件地址: 留空
   请求是: ✅ 存储到磁盘
   ```
   
   d. 点击 **"继续"**，保存 CSR 文件到桌面

5. **上传刚才创建的 CSR 文件**

6. **点击 "Continue"**

7. **下载证书**，双击安装到钥匙串

### 创建分发证书（Distribution）

1. **点击 "+"**

2. **选择证书类型**
   ```
   ✅ Apple Distribution
   (用于发布到 App Store)
   ```

3. **重复上面的步骤**（上传 CSR → 下载 → 安装）

---

## 🎯 创建 Provisioning Profiles

### 访问 Profiles 页面
https://developer.apple.com/account/resources/profiles/list

---

## 📱 示例：为主应用创建 Profile

我以**主应用**为例，详细说明每一步。其他 4 个扩展的步骤完全相同。

### 🔹 第一个：主应用开发环境

#### 步骤 1: 点击 "+"
在 Profiles 页面左上角，点击蓝色的 **"+"** 按钮。

#### 步骤 2: 选择 Profile 类型
```
Distribution
  ✅ iOS App Development
```
选择 **"iOS App Development"**（用于开发和测试）

点击 **"Continue"**

#### 步骤 3: 选择 App ID
```
搜索或选择: com.7RV2Y67HF6.xdripswiftt1li23
```
在下拉列表中找到并选择您的主应用 Bundle ID。

点击 **"Continue"**

#### 步骤 4: 选择证书
```
✅ 勾选您的开发证书
   (显示为 "Apple Development: 您的名字")
```
至少选择一个证书。

点击 **"Continue"**

#### 步骤 5: 选择设备（仅开发环境）
```
✅ Select All（全选）
```
或者只选择您想测试的设备。

点击 **"Continue"**

#### 步骤 6: 命名 Profile
```
Provisioning Profile Name: xDrip Main App Development
```
使用一个清晰、容易识别的名称。

点击 **"Generate"**

#### 步骤 7: 下载
点击 **"Download"** 下载 Profile。

**注意**：GitHub Actions 会自动获取 Profile，您不需要手动上传。

---

### 🔹 第二个：主应用生产环境

#### 步骤 1-2: 选择类型
```
Distribution
  ✅ App Store
```
选择 **"App Store"**（用于发布）

点击 **"Continue"**

#### 步骤 3: 选择 App ID
```
com.7RV2Y67HF6.xdripswiftt1li23
```

点击 **"Continue"**

#### 步骤 4: 选择证书
```
✅ 勾选您的分发证书
   (显示为 "Apple Distribution: 您的团队名")
```

点击 **"Continue"**

#### 步骤 5: ⚠️ 注意！App Store 类型不需要选择设备

直接跳到命名步骤。

#### 步骤 6: 命名
```
Provisioning Profile Name: xDrip Main App App Store
```

点击 **"Generate"**

#### 步骤 7: 下载
点击 **"Download"**

---

## 📋 完整清单：需要创建的 10 个 Profiles

### 主应用（xdrip）
- [ ] ✅ xDrip Main App Development（iOS App Development）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23`
- [ ] ✅ xDrip Main App App Store（App Store）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23`

### Widget 扩展
- [ ] ✅ xDrip Widget Development（iOS App Development）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`
- [ ] ✅ xDrip Widget App Store（App Store）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.xDripWidget`

### Watch App
- [ ] ✅ xDrip Watch App Development（iOS App Development）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`
- [ ] ✅ xDrip Watch App App Store（App Store）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp`

### Watch Complication
- [ ] ✅ xDrip Watch Complication Development（iOS App Development）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`
- [ ] ✅ xDrip Watch Complication App Store（App Store）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.watchkitapp.xDripWatchComplication`

### 通知扩展
- [ ] ✅ xDrip Notification Extension Development（iOS App Development）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`
- [ ] ✅ xDrip Notification Extension App Store（App Store）
  - Bundle ID: `com.7RV2Y67HF6.xdripswiftt1li23.xDripNotificationContextExtension`

---

## 🎯 快速创建流程

对于剩余的 9 个 Profile，重复以下流程：

### 开发环境 Profile（Development）
```
1. "+" → iOS App Development → Continue
2. 选择 Bundle ID → Continue
3. 选择开发证书 → Continue
4. 选择设备（全选）→ Continue
5. 命名（例如：xDrip Widget Development）→ Generate
6. Download
```

### 生产环境 Profile（App Store）
```
1. "+" → App Store → Continue
2. 选择 Bundle ID → Continue
3. 选择分发证书 → Continue
4. （跳过设备选择）
5. 命名（例如：xDrip Widget App Store）→ Generate
6. Download
```

---

## ⚠️ 常见问题

### Q1: 没有可选的证书怎么办？
**A**: 您需要先创建证书，请参考上面的"创建证书"部分。

### Q2: 提示 "No devices registered"？
**A**: 
1. 访问：https://developer.apple.com/account/resources/devices/list
2. 点击 "+" 添加测试设备
3. 输入设备名称和 UDID
4. 然后再创建 Development Profile

### Q3: 如何找到设备的 UDID？
**A**: 
- **方法 1**：连接设备到 Mac，打开 Finder，点击设备，可以看到 UDID
- **方法 2**：在设备上访问 https://udid.tech/，会自动显示 UDID

### Q4: 需要下载所有 Profiles 吗？
**A**: 不需要！GitHub Actions 会通过 API Key 自动获取。但下载保存一份也可以。

### Q5: Profile 过期了怎么办？
**A**: Development Profiles 有效期 1 年，App Store Profiles 有效期 1 年。过期后需要重新创建。

### Q6: 我没有测试设备，可以跳过 Development Profiles 吗？
**A**: 可以！如果您只需要发布到 App Store，只创建 App Store Profiles（5 个）即可。

---

## 🎉 完成后

创建所有 Profiles 后：

1. **返回 GitHub Actions**
   - 访问：https://github.com/q601180252/xdripios/actions

2. **运行 Build IPA workflow**
   - 点击 "Build IPA"
   - 点击 "Run workflow"

3. **等待构建完成**（约 10-15 分钟）

4. **下载 IPA 文件**

---

## 📊 时间预估

- **创建证书**（如果需要）: 5-10 分钟
- **创建第 1 个 Profile**（学习过程）: 5 分钟
- **创建剩余 9 个 Profiles**（熟练后）: 20-25 分钟
- **总计**: 约 30-40 分钟

---

## 💡 小技巧

1. **命名规范**：使用清晰的命名，方便以后管理
   - 好：`xDrip Widget Development`
   - 坏：`Profile 1`

2. **批量操作**：先创建所有 Development Profiles，再创建所有 App Store Profiles

3. **记录**：创建完成后，在清单上打勾，避免遗漏

4. **不着急**：第一次创建可能需要时间，慢慢来，确保每一步正确

---

## 🆘 需要帮助？

如果在创建过程中遇到问题：
1. 查看屏幕上的错误提示
2. 参考本文档的"常见问题"部分
3. 随时告诉我您遇到的具体问题

---

**现在就开始创建吧！** 🚀

第一步：访问 https://developer.apple.com/account/resources/profiles/list

