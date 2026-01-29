# 禁用 Watch App 构建 - 详细步骤 📱

## 🎯 目标

暂时禁用 Watch App 和 Watch Complication 的构建，专注于构建主应用和其他扩展。

---

## 📋 在 Xcode 中的详细操作步骤

### 步骤 1：打开 Scheme 编辑器

```
1. 打开 Xcode
2. 确保已打开 xdrip.xcworkspace
3. 在 Xcode 顶部工具栏，找到设备选择器旁边的 "xdrip" 文字
4. 点击 "xdrip" 旁边的下拉箭头 ▼
5. 在下拉菜单中选择 "Edit Scheme..."
```

**截图提示**：顶部工具栏应该显示类似 `xdrip > iPhone 15 Pro`

---

### 步骤 2：修改 Build 设置

```
1. 在弹出的窗口左侧，选择 "Build"
2. 右侧会显示所有 Targets 的列表，每个都有复选框
3. 找到以下两项并取消勾选：
   
   当前状态 → 修改后状态
   ✅ xDrip Watch App  →  ❌ xDrip Watch App
   ✅ xDrip Watch Complication Extension  →  ❌ xDrip Watch Complication Extension
   
4. 保持其他所有项目的勾选状态：
   ✅ xdrip (保持勾选)
   ✅ xDrip Widget Extension (保持勾选)
   ✅ xDrip Notification Context Extension (保持勾选)
   ✅ FotaLibrary (保持勾选)
   ✅ BleLibrary (保持勾选)
   ✅ 所有 Swift Package (保持勾选)

5. 点击 "Close" 按钮
```

---

### 步骤 3：清理并重新构建

```
1. Product → Clean Build Folder (快捷键: ⇧⌘K)
   • 等待显示 "Clean Finished"
   
2. Product → Build (快捷键: ⌘B)
   • 等待构建完成
   • 查看构建结果
```

---

## ✅ 预期结果

### 构建成功
```
✅ Build Succeeded
✅ 0 errors, 0 warnings (或只有少量警告)
```

### 构建范围
```
已构建：
✅ xdrip (主应用)
✅ xDrip Widget Extension (小组件)
✅ xDrip Notification Context Extension (通知扩展)

未构建（已禁用）：
❌ xDrip Watch App
❌ xDrip Watch Complication Extension
```

---

## 🎯 如果仍然有错误

### 如果还是 Bundle ID 前缀错误

说明错误来自 **Widget** 或 **Notification Extension**，请告诉我具体是哪个。

### 如果是 Provisioning Profile 错误

```
在 Xcode 中：
1. 选择 Target (xdrip, Widget, 或 Notification)
2. Signing & Capabilities 标签
3. 勾选 "Automatically manage signing"
4. Team: EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
5. 等待 Xcode 自动处理
```

### 如果是编译错误

请告诉我具体的错误信息。

---

## 📊 构建架构对比

### 完整构建（之前）
```
xdrip.app
├── Frameworks
├── xDrip Widget.appex ✅
├── xDrip Notification.appex ✅
└── Watch/
    └── xDrip Watch App.app ❌ (Bundle ID 前缀错误)
        └── PlugIns/
            └── xDrip Watch Complication.appex ❌
```

### 部分构建（现在）
```
xdrip.app
├── Frameworks
├── xDrip Widget.appex ✅
└── xDrip Notification.appex ✅
```

**没有 Watch App，但主应用完全可用！**

---

## 💡 这样做的好处

### 1. 问题隔离
- ✅ Watch App 的问题不影响主应用
- ✅ 可以先发布 iOS 版本
- ✅ Watch App 可以稍后添加

### 2. 快速验证
- ✅ 立即知道主应用是否能构建
- ✅ 可以测试主要功能
- ✅ 不被 Watch App 阻塞

### 3. 降低复杂度
- ✅ 一次只处理一个问题
- ✅ 更容易找到问题根源
- ✅ 更容易解决

---

## 🔄 稍后重新启用 Watch App

当主应用成功后，想要重新启用 Watch App：

```
1. Edit Scheme...
2. Build
3. 重新勾选：
   ✅ xDrip Watch App
   ✅ xDrip Watch Complication Extension
4. Close
5. 再次尝试构建
```

---

## 🆘 视觉指南

### Scheme 编辑器位置
```
Xcode 顶部工具栏：
┌─────────────────────────────────────────┐
│ ▶ ⏸ ⏹   xdrip ▼   iPhone 15 Pro ▼    │
│            ↑                             │
│        点击这里                          │
└─────────────────────────────────────────┘
```

### Build Targets 列表
```
Edit Scheme → Build:
┌──────────────────────────────────────────┐
│ Build  Run  Test  Profile  Analyze       │
├──────────────────────────────────────────┤
│ Targets:                                 │
│ ✅ xdrip                                 │
│ ✅ xDrip Widget Extension               │
│ ❌ xDrip Watch App           ← 取消这个 │
│ ❌ xDrip Watch Complication  ← 取消这个 │
│ ✅ xDrip Notification Extension         │
│ ✅ FotaLibrary                          │
│ ✅ BleLibrary                           │
└──────────────────────────────────────────┘
```

---

## 🎯 现在请执行

**在 Xcode 中：**

1. ✅ Edit Scheme
2. ✅ 取消勾选 Watch App 和 Watch Complication
3. ✅ Close
4. ✅ Clean Build Folder
5. ✅ Build

**然后告诉我结果！** 🚀

如果还有错误，请告诉我**完整的错误信息**和**是哪个 Target 的错误**。

