# 🎯 Xcode 中正确设置 Team 的详细指南

## ⚠️ 问题根源

您在 Xcode 中选择了**错误的 Team**，导致：
```
Embedded Binary Bundle Identifier: com.HHZN32E89C.xdripswiftt1li23...
Parent App Bundle Identifier:     com.7RV2Y67HF6.xdripswiftt1li23...
```

**Bundle ID 前缀不匹配！**

---

## ✅ 正确的 Team 设置步骤

### 步骤 1: 打开项目设置

1. 在 Xcode 中，点击左侧项目导航器中的 **"xdrip"** 项目图标（蓝色图标）
2. 确保中间面板显示 **"PROJECT"** 和 **"TARGETS"** 列表

### 步骤 2: 为每个 Target 设置正确的 Team

**需要设置 5 个 Targets：**

#### Target 1: xdrip（主应用）
1. 在 **TARGETS** 列表中，点击 **"xdrip"**
2. 切换到 **"Signing & Capabilities"** 标签
3. 在 **"Team"** 下拉菜单中，选择：
   ```
   ✅ EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
   ```
4. 确保勾选了 **"Automatically manage signing"**

#### Target 2: xDrip Widget Extension
1. 在 **TARGETS** 列表中，点击 **"xDrip Widget Extension"**
2. 切换到 **"Signing & Capabilities"** 标签
3. 在 **"Team"** 下拉菜单中，选择：
   ```
   ✅ EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
   ```
4. 确保勾选了 **"Automatically manage signing"**

#### Target 3: xDrip Watch App
1. 在 **TARGETS** 列表中，点击 **"xDrip Watch App"**
2. 切换到 **"Signing & Capabilities"** 标签
3. 在 **"Team"** 下拉菜单中，选择：
   ```
   ✅ EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
   ```
4. 确保勾选了 **"Automatically manage signing"**

#### Target 4: xDrip Watch Complication Extension
1. 在 **TARGETS** 列表中，点击 **"xDrip Watch Complication Extension"**
2. 切换到 **"Signing & Capabilities"** 标签
3. 在 **"Team"** 下拉菜单中，选择：
   ```
   ✅ EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
   ```
4. 确保勾选了 **"Automatically manage signing"**

#### Target 5: xDrip Notification Context Extension
1. 在 **TARGETS** 列表中，点击 **"xDrip Notification Context Extension"**
2. 切换到 **"Signing & Capabilities"** 标签
3. 在 **"Team"** 下拉菜单中，选择：
   ```
   ✅ EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
   ```
4. 确保勾选了 **"Automatically manage signing"**

---

## 🔍 如何识别正确的 Team

### ✅ 正确的 Team（选择这个）
```
EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
```

### ❌ 错误的 Team（不要选择）
```
任何包含 HHZN32E89C 的选项
例如：
- Some Team Name (HHZN32E89C)
- Personal Team (HHZN32E89C)
```

---

## 🚨 如果下拉菜单中没有 7RV2Y67HF6

### 方案 1: 添加 Apple ID
1. 打开 **Xcode → Settings**（⌘,）
2. 切换到 **"Accounts"** 标签
3. 点击左下角的 **"+"** 按钮
4. 选择 **"Apple ID"**
5. 输入您的 Apple ID 和密码
6. 登录后，应该能看到 **7RV2Y67HF6** Team

### 方案 2: 使用模拟器（推荐）
如果您只是想本地编译测试，可以：
1. **不设置 Team**（让脚本自动处理）
2. 选择模拟器设备
3. 直接构建

---

## 📋 设置完成后的操作

### 1. 如果 Xcode 提示文件已修改
```
选择 "Revert" 或 "Discard and Continue"
❌ 不要选择 "Keep Mine"
```

### 2. 清理并构建
```
Product → Clean Build Folder (⇧⌘K)
等待清理完成
Product → Build (⌘B)
```

---

## 🎯 验证设置是否正确

构建成功后，检查构建日志中是否还有：
```
❌ Embedded Binary Bundle Identifier: com.HHZN32E89C...
❌ Parent App Bundle Identifier: com.7RV2Y67HF6...
```

如果还有这个错误，说明某个 Target 的 Team 设置不正确。

---

## 💡 预防措施

### 使用自动修正脚本
每次在 Xcode 中设置 Team 后，运行：
```bash
./check_and_fix_team.sh
```

这个脚本会：
- ✅ 检测错误的 Team ID
- ✅ 自动修正为正确的 Team ID
- ✅ 显示详细的状态信息

### Git Hook（已安装）
每次 `git pull` 或 `git checkout` 后，会自动修正 Team ID。

---

## 🎉 成功标志

当您看到：
```
✅ Build Succeeded
```

并且构建日志中没有 Bundle ID 前缀错误，说明设置正确！

---

## 📞 如果还有问题

1. 运行检测脚本：
   ```bash
   ./check_and_fix_team.sh
   ```

2. 查看详细状态：
   ```bash
   ./check_all_bundle_ids.sh
   ```

3. 强制修正：
   ```bash
   ./force_correct_team.sh
   ```

---

**记住：所有 5 个 Targets 都必须使用 Team `7RV2Y67HF6`！** 🎯

