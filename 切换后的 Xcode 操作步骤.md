# 切换到 Yang Li Team 后的 Xcode 操作步骤 🚀

## ✅ 已完成的操作

- ✅ DEVELOPMENT_TEAM 已更新为: `HHZN32E89C` (12 处)
- ✅ Bundle ID 前缀已更新为: `com.HHZN32E89C`
- ✅ 所有配置文件已备份

---

## 📋 现在需要在 Xcode 中完成的步骤

### 步骤 1️⃣: 重新加载修改后的文件

**如果 Xcode 弹出提示 "文件已在外部修改"：**
- ✅ 选择 **"Revert"** 或 **"Discard and Continue"**
- ❌ **不要**选择 "Keep Mine"

**如果没有弹出提示：**
1. 关闭 Xcode (`⌘Q`)
2. 等待 3 秒
3. 重新打开 Xcode
4. 打开 `xdrip.xcworkspace`

---

### 步骤 2️⃣: 为所有 5 个 Targets 设置 Team

在 Xcode 中：

1. **点击左侧项目导航器中的 "xdrip" 项目图标**（蓝色图标）

2. **在中间的 TARGETS 列表中，逐个设置以下 5 个 Target：**

#### Target 1: xdrip
```
1. 点击 "xdrip"
2. 切换到 "Signing & Capabilities" 标签
3. Team 下拉菜单 → 选择 "Yang Li (HHZN32E89C)"
4. 勾选 "Automatically manage signing"
```

#### Target 2: xDrip Widget Extension
```
1. 点击 "xDrip Widget Extension"
2. 切换到 "Signing & Capabilities" 标签
3. Team 下拉菜单 → 选择 "Yang Li (HHZN32E89C)"
4. 勾选 "Automatically manage signing"
```

#### Target 3: xDrip Watch App
```
1. 点击 "xDrip Watch App"
2. 切换到 "Signing & Capabilities" 标签
3. Team 下拉菜单 → 选择 "Yang Li (HHZN32E89C)"
4. 勾选 "Automatically manage signing"
```

#### Target 4: xDrip Watch Complication Extension
```
1. 点击 "xDrip Watch Complication Extension"
2. 切换到 "Signing & Capabilities" 标签
3. Team 下拉菜单 → 选择 "Yang Li (HHZN32E89C)"
4. 勾选 "Automatically manage signing"
```

#### Target 5: xDrip Notification Context Extension
```
1. 点击 "xDrip Notification Context Extension"
2. 切换到 "Signing & Capabilities" 标签
3. Team 下拉菜单 → 选择 "Yang Li (HHZN32E89C)"
4. 勾选 "Automatically manage signing"
```

⚠️ **重要：所有 5 个 Targets 都必须选择 "Yang Li (HHZN32E89C)"！**

---

### 步骤 3️⃣: 选择模拟器设备

在 Xcode 顶部工具栏：
1. 点击设备选择器（中间位置）
2. 选择任意 iPhone 模拟器
3. 例如: **"iPhone 16 Pro"** 或 **"iPhone SE (3rd generation)"**

⚠️ **必须选择模拟器！真机需要额外配置。**

---

### 步骤 4️⃣: 清理并构建

#### 1. 清理构建文件夹
```
Product → Clean Build Folder (快捷键: ⇧⌘K)
```
等待清理完成（底部状态栏会显示 "Clean Succeeded"）

#### 2. 构建项目
```
Product → Build (快捷键: ⌘B)
```
等待构建完成

---

## 🎉 预期结果

如果一切正常，您将看到：

✅ **Build Succeeded**
✅ 没有 "Embedded binary's bundle identifier is not prefixed" 错误
✅ 所有 Bundle ID 前缀都是 `com.HHZN32E89C`

---

## 💡 构建成功后

可以运行应用：
```
Product → Run (快捷键: ⌘R)
或点击左上角的 ▶️ 播放按钮
```

应用将在模拟器中启动！🎉

---

## ⚠️ 如果还有错误

### 错误 1: Team 设置不正确
**检查所有 5 个 Targets 的 Team 是否都设置为 "Yang Li (HHZN32E89C)"**

### 错误 2: Missing package product
```
File → Packages → Resolve Package Versions
等待 30 秒 - 1 分钟
```

### 错误 3: 其他错误
把完整错误信息发给我，我会帮您解决！

---

## 📖 相关文档

- `Team 选择说明.md` - 为什么切换 Team
- `Xcode Team 设置详细指南.md` - 详细的 Xcode 设置步骤
- `本地编译成功总结.md` - 之前的编译修复总结

---

## 🎯 快速检查清单

构建前请确认：

- [ ] Xcode 已重新加载修改后的文件
- [ ] 所有 5 个 Targets 的 Team 都设置为 "Yang Li (HHZN32E89C)"
- [ ] 所有 5 个 Targets 都勾选了 "Automatically manage signing"
- [ ] 选择了模拟器设备（不是真机）
- [ ] 已执行 Clean Build Folder

全部完成后执行 Build！🚀

---

**现在请按照上面的步骤在 Xcode 中操作，完成后告诉我结果！** 😊

