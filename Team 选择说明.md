# Team 选择说明 🎯

## 🔍 问题分析

您有一个 Apple 开发者账号 **Yang Li**，对应的 Team ID 是 `HHZN32E89C`。

但是当前项目配置使用的是另一个 Team ID：`7RV2Y67HF6`（EDUARDO PEIXOTO VIEIRA）

这导致了 Bundle ID 前缀不匹配：
```
❌ Embedded Binary Bundle Identifier: com.HHZN32E89C.xdripswiftt1li23...
❌ Parent App Bundle Identifier:     com.7RV2Y67HF6.xdripswiftt1li23...
```

---

## ✅ 解决方案：统一使用 Yang Li Team

既然您的开发者账号是 **Yang Li** (`HHZN32E89C`)，我们应该把整个项目切换到使用您的 Team。

### 方案 A：一键切换到 Yang Li Team（推荐）

运行自动切换脚本：

```bash
./switch_to_yangli_team.sh
```

这个脚本会自动：
1. ✅ 修改所有 `DEVELOPMENT_TEAM` 为 `HHZN32E89C`
2. ✅ 修改所有 Bundle ID 前缀为 `com.HHZN32E89C`
3. ✅ 备份原文件

---

## 📋 切换后的配置

### Bundle IDs（新的）
```
主应用:
  com.HHZN32E89C.xdripswiftt1li23

Widget:
  com.HHZN32E89C.xdripswiftt1li23.xDripWidget

Watch App:
  com.HHZN32E89C.xdripswiftt1li23.watchkitapp

Watch Complication:
  com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication

Notification Extension:
  com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension
```

### Team
```
所有 5 个 Targets:
  Yang Li (HHZN32E89C)
```

---

## 🎯 切换步骤

### 1. 运行切换脚本

```bash
./switch_to_yangli_team.sh
```

输入 `y` 确认执行。

### 2. 在 Xcode 中操作

1. **如果 Xcode 提示文件已修改**：
   - 选择 **"Revert"** 或 **"Discard and Continue"**

2. **为所有 5 个 Targets 设置 Team**：
   - 点击项目图标 → 选择 Target
   - Signing & Capabilities → Team → 选择 **Yang Li (HHZN32E89C)**
   - 勾选 **"Automatically manage signing"**
   - 重复此步骤为所有 5 个 Targets 设置

3. **清理并构建**：
   ```
   Product → Clean Build Folder (⇧⌘K)
   Product → Build (⌘B)
   ```

---

## 🏪 Apple Developer Portal 配置

切换 Team 后，需要在 Apple Developer Portal 创建新的配置：

### 1. 创建 Bundle IDs

登录 [Apple Developer](https://developer.apple.com/account) → Certificates, Identifiers & Profiles → Identifiers

创建以下 5 个 App IDs：

#### 主应用
- **Identifier**: `com.HHZN32E89C.xdripswiftt1li23`
- **Capabilities**: 
  - App Groups
  - HealthKit
  - Near Field Communication Tag Reading

#### Widget Extension
- **Identifier**: `com.HHZN32E89C.xdripswiftt1li23.xDripWidget`
- **Capabilities**: App Groups

#### Watch App
- **Identifier**: `com.HHZN32E89C.xdripswiftt1li23.watchkitapp`
- **Capabilities**: App Groups

#### Watch Complication
- **Identifier**: `com.HHZN32E89C.xdripswiftt1li23.watchkitapp.xDripWatchComplication`
- **Capabilities**: App Groups

#### Notification Extension
- **Identifier**: `com.HHZN32E89C.xdripswiftt1li23.xDripNotificationContextExtension`
- **Capabilities**: App Groups

### 2. 创建 App Group

- **Identifier**: `group.com.HHZN32E89C.loopkit.LoopGroup`
- **Description**: xDrip App Group

### 3. 关联 App Group 到所有 Bundle IDs

为上面创建的 5 个 Bundle IDs，每个都关联到 App Group：
1. 编辑 Bundle ID
2. App Groups → Configure
3. 选择 `group.com.HHZN32E89C.loopkit.LoopGroup`
4. Save

### 4. 创建 Provisioning Profiles

为每个 Bundle ID 创建：
- **Development Profile**（用于本地测试）
- **App Store Profile**（用于发布）

---

## 🎉 优势

使用您自己的 Team (Yang Li) 的好处：

1. ✅ **本地开发更简单**
   - 不需要其他人的证书
   - 可以直接在您的设备上测试
   
2. ✅ **完全控制**
   - 您拥有所有配置
   - 不依赖其他开发者
   
3. ✅ **发布到 App Store**
   - 使用您自己的开发者账号
   - 完全自主管理

---

## ⚠️ 注意事项

### 模拟器测试（不需要 Provisioning Profile）

如果您只是想在模拟器上测试：
1. 运行切换脚本
2. 在 Xcode 中设置 Team 为 Yang Li
3. 选择模拟器设备
4. 直接构建

**模拟器不需要配置 Apple Developer Portal！**

### 真机测试或发布

如果要在真机上测试或发布到 App Store：
1. 运行切换脚本
2. 按照上面的步骤配置 Apple Developer Portal
3. 在 Xcode 中设置 Team 为 Yang Li
4. Xcode 会自动下载 Provisioning Profiles

---

## 🚀 现在就切换吗？

如果您确定要使用 Yang Li Team，执行：

```bash
./switch_to_yangli_team.sh
```

然后按照上面的步骤操作。

---

## 💡 备选方案：保持使用 7RV2Y67HF6

如果您想继续使用 `7RV2Y67HF6`（EDUARDO PEIXOTO VIEIRA）：

1. 需要获取该 Team 的访问权限
2. 在 Xcode 中添加该 Apple ID
3. 下载对应的 Provisioning Profiles

但这需要该 Team 的所有者授权您访问。

---

**推荐：使用您自己的 Team (Yang Li - HHZN32E89C)，更简单、更可控！** 🎯

