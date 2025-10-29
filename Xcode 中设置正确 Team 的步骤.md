# Xcode 中设置正确 Team 的详细步骤 🎯

## 🔍 问题分析

当您在 Xcode 中设置 Team 时，Xcode 会自动修改 `project.pbxproj` 文件中的 `DEVELOPMENT_TEAM`。

**关键**：您的账号可能关联了**两个** Team：
- ❌ `HHZN32E89C`（旧的，错误的）
- ✅ `7RV2Y67HF6`（新的，正确的）

如果选择了错误的 Team，就会导致 Bundle ID 前缀错误。

---

## ✅ 正确的设置方法

### 步骤 1：打开项目设置

1. 在 Xcode 左侧的 **Project Navigator** 中，点击最顶部的蓝色项目图标 **"xdrip"**
2. 确保选中的是 **项目**（xdrip），而不是 Target

### 步骤 2：为每个 Target 设置正确的 Team

您需要为 **5 个 Targets** 设置 Team：

#### Target 1: xdrip（主应用）

1. 在中间栏的 **TARGETS** 列表中，点击 **"xdrip"**
2. 切换到 **"Signing & Capabilities"** 标签
3. 找到 **"Team"** 下拉菜单
4. **重要**：选择包含 `7RV2Y67HF6` 的 Team
   ```
   ✅ 正确: EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
   ❌ 错误: 任何包含 HHZN32E89C 的选项
   ```
5. 勾选 **"Automatically manage signing"**

#### Target 2: xDrip Widget Extension

1. 在 **TARGETS** 列表中，点击 **"xDrip Widget Extension"**
2. **Signing & Capabilities** 标签
3. **Team**：选择 `7RV2Y67HF6`
4. 勾选 **"Automatically manage signing"**

#### Target 3: xDrip Watch App

1. 在 **TARGETS** 列表中，点击 **"xDrip Watch App"**
2. **Signing & Capabilities** 标签
3. **Team**：选择 `7RV2Y67HF6`
4. 勾选 **"Automatically manage signing"**

#### Target 4: xDrip Watch Complication Extension

1. 在 **TARGETS** 列表中，点击 **"xDrip Watch Complication Extension"**
2. **Signing & Capabilities** 标签
3. **Team**：选择 `7RV2Y67HF6`
4. 勾选 **"Automatically manage signing"**

#### Target 5: xDrip Notification Context Extension

1. 在 **TARGETS** 列表中，点击 **"xDrip Notification Context Extension"**
2. **Signing & Capabilities** 标签
3. **Team**：选择 `7RV2Y67HF6`
4. 勾选 **"Automatically manage signing"**

---

## 🎯 如何识别正确的 Team

在 Team 下拉菜单中，您会看到类似：

```
✅ 正确的选择:
   EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
   或
   Your Name (7RV2Y67HF6)

❌ 错误的选择:
   任何显示 (HHZN32E89C) 的选项
```

**关键**：找到括号中是 `7RV2Y67HF6` 的那个！

---

## 📋 完整检查清单

设置完所有 5 个 Targets 后，逐一检查：

- [ ] ✅ xdrip → Team = 7RV2Y67HF6
- [ ] ✅ xDrip Widget Extension → Team = 7RV2Y67HF6
- [ ] ✅ xDrip Watch App → Team = 7RV2Y67HF6
- [ ] ✅ xDrip Watch Complication Extension → Team = 7RV2Y67HF6
- [ ] ✅ xDrip Notification Context Extension → Team = 7RV2Y67HF6

**所有 5 个 Targets 都必须使用同一个 Team：7RV2Y67HF6**

---

## 🔧 设置后的操作

### 1️⃣ 清理并构建

```
Product → Clean Build Folder (⇧⌘K)
Product → Build (⌘B)
```

### 2️⃣ 如果提示 Provisioning Profile 错误

**模拟器构建**：
- 不需要 Provisioning Profile
- 直接选择模拟器设备（例如：iPhone 16 Pro）
- 再次构建

**真机构建**：
- 需要 Provisioning Profile
- Xcode 会尝试自动创建
- 或者需要在 Apple Developer Portal 手动创建

---

## ⚠️ 常见问题

### Q1: 下拉菜单中只有一个 Team，就是 HHZN32E89C，怎么办？

**A**: 您需要在 Xcode 中添加正确的 Apple ID 账号：

1. **Xcode → Settings (⌘,)**
2. **Accounts** 标签
3. 检查是否有您的 Apple ID
4. 如果有，点击它，查看 **"Team"** 列表，应该能看到 `7RV2Y67HF6`
5. 如果没有 `7RV2Y67HF6`，说明您的 Apple ID 没有关联到这个 Team

### Q2: 我有两个 Team，应该选哪个？

**A**: 选择 Team ID 为 `7RV2Y67HF6` 的那个。这是您当前使用的正确 Team。

### Q3: 设置 Team 后，Xcode 提示需要 Provisioning Profile？

**A**: 这是正常的。您有两个选择：

**选项 A：使用模拟器**（推荐，无需 Profile）
```
1. 在 Xcode 顶部，选择一个模拟器设备
   例如：iPhone 16 Pro
2. Product → Build (⌘B)
3. 构建成功后，可以在模拟器上运行
```

**选项 B：使用真机**（需要 Profile）
```
1. 需要在 Apple Developer Portal 创建 Provisioning Profiles
2. 参考文档：如何创建 Provisioning Profiles 详细教程.md
```

### Q4: 能不能不设置 Team？

**A**: 不能。iOS 应用必须有 Team 才能构建和签名。但您可以：
- ✅ 使用正确的 Team (`7RV2Y67HF6`)
- ✅ 在模拟器上构建（不需要 Provisioning Profile）

---

## 🎯 推荐方案：先用模拟器

### 步骤 1: 设置所有 Targets 的 Team 为 `7RV2Y67HF6`

按照上面的步骤，逐个设置 5 个 Targets。

### 步骤 2: 选择模拟器

在 Xcode 顶部，点击设备选择器，选择一个模拟器：
```
xdrip > iPhone 16 Pro
```

### 步骤 3: 构建

```
Product → Clean Build Folder (⇧⌘K)
Product → Build (⌘B)
```

### 步骤 4: 运行

```
Product → Run (⌘R)
```

应用会在模拟器上启动！

---

## 📊 Team ID 对照表

| Team ID | 状态 | 说明 |
|---------|------|------|
| `HHZN32E89C` | ❌ 错误 | 旧的 Team，会导致 Bundle ID 前缀错误 |
| `7RV2Y67HF6` | ✅ 正确 | 当前使用的 Team，与 Bundle ID 前缀一致 |

---

## 🎉 成功标志

当您在 Xcode 中看到：

```
Build Succeeded
```

并且没有 Bundle ID 前缀错误，说明设置正确了！

---

## 🚀 设置完成后

### 本地开发（模拟器）
- ✅ 已可用
- ✅ 无需 Provisioning Profile

### GitHub Actions 构建（真机 IPA）
- ❌ 仍需配置 Provisioning Profiles
- 📖 参考：`如何创建 Provisioning Profiles 详细教程.md`

---

**现在请在 Xcode 中：**
1. **设置所有 Targets 的 Team 为 `7RV2Y67HF6`**
2. **选择模拟器设备**
3. **Clean + Build**

**然后告诉我结果！** 😊

