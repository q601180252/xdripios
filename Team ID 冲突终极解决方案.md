# Team ID 冲突终极解决方案 🎯

## 🔍 问题根源

您的 Apple 账号关联了**两个 Team**：
- `HHZN32E89C`（旧的）
- `7RV2Y67HF6`（新的，正确的）

当您在 Xcode 中设置 Team 时，如果选择了 `HHZN32E89C`，就会导致：
```
Embedded Binary Bundle Identifier: com.HHZN32E89C.xdripswiftt1li23...
Parent App Bundle Identifier:     com.7RV2Y67HF6.xdripswiftt1li23...
```

**Bundle ID 前缀不匹配！**

---

## ✅ 终极解决方案

### 方案 A：在 Xcode 中选择正确的 Team（推荐）

#### 步骤 1: 为每个 Target 设置正确的 Team

在 Xcode 中，为 **5 个 Targets** 逐一设置：

1. 点击左侧项目导航器中的 **"xdrip"** 项目图标
2. 在中间的 **TARGETS** 列表中，选择一个 Target
3. 切换到 **"Signing & Capabilities"** 标签
4. 在 **"Team"** 下拉菜单中，选择：
   ```
   ✅ EDUARDO PEIXOTO VIEIRA (7RV2Y67HF6)
   ```
   **不要选择**包含 `HHZN32E89C` 的任何选项！

5. 勾选 **"Automatically manage signing"**

**重复以上步骤，为所有 5 个 Targets 设置：**
- xdrip
- xDrip Widget Extension
- xDrip Watch App
- xDrip Watch Complication Extension
- xDrip Notification Context Extension

#### 步骤 2: 构建

```
Product → Clean Build Folder (⇧⌘K)
Product → Build (⌘B)
```

---

### 方案 B：使用自动修正脚本（备用）

如果您不小心选择了错误的 Team，运行脚本自动修正：

```bash
./force_correct_team.sh
```

脚本会自动：
- ✅ 检测错误的 Team ID
- ✅ 替换为正确的 Team ID
- ✅ 显示修正结果

然后在 Xcode 中：
```
1. 如果提示文件已修改 → 选择 "Revert"
2. Product → Clean Build Folder (⇧⌘K)
3. Product → Build (⌘B)
```

---

### 方案 C：使用 Git Hook（自动化）

我已经为您安装了 Git Hook，它会在每次 `git checkout` 或 `git pull` 后自动修正 Team ID。

**您不需要做任何事情，它会自动运行！**

---

## 🎯 推荐的工作流程

### 开发流程

```
1. 在 Xcode 中设置 Team 时，选择 7RV2Y67HF6
2. 如果不小心选错了，运行：./force_correct_team.sh
3. 在 Xcode 中选择 "Revert" 重新加载文件
4. Clean + Build
```

### 避免问题

1. **记住正确的 Team**：`7RV2Y67HF6`
2. **在 Xcode 中仔细选择**：看清楚括号中的 Team ID
3. **遇到问题就运行脚本**：`./force_correct_team.sh`

---

## 📊 Team ID 对照表

| Team ID | Team Name | 状态 | Bundle ID 前缀 |
|---------|-----------|------|---------------|
| `HHZN32E89C` | ？ | ❌ 错误 | `com.HHZN32E89C` |
| `7RV2Y67HF6` | EDUARDO PEIXOTO VIEIRA | ✅ 正确 | `com.7RV2Y67HF6` |

**当前项目使用的 Bundle ID 前缀**：`com.7RV2Y67HF6`

**所以必须使用 Team**：`7RV2Y67HF6`

---

## 🔧 自动修正工具

### 1. `force_correct_team.sh`
**用途**：手动运行，立即修正 Team ID

**使用**：
```bash
./force_correct_team.sh
```

**输出**：
```
当前状态：
  旧 Team ID (HHZN32E89C): 10 处
  新 Team ID (7RV2Y67HF6): 2 处

发现 10 处错误的 Team ID，正在修正...
✅ 修正完成！
  旧 Team ID (HHZN32E89C): 0 处
  新 Team ID (7RV2Y67HF6): 12 处
```

### 2. Git Hook（自动）
**用途**：每次 `git checkout` 或 `git pull` 后自动运行

**位置**：`.git/hooks/post-checkout`

**行为**：
- 自动检测错误的 Team ID
- 自动修正为 `7RV2Y67HF6`
- 静默运行，无需手动操作

---

## ⚠️ 为什么会有两个 Team？

可能的原因：
1. 您之前使用过不同的 Apple Developer 账号
2. 您的账号被添加到了两个不同的开发团队
3. 项目从另一个开发者那里转移过来

**不管原因是什么，现在只需要使用 `7RV2Y67HF6` 即可。**

---

## 🎯 当前必须执行的步骤

### 在 Xcode 中：

```
1️⃣  选择模拟器设备
    顶部：xdrip > iPhone 16 Pro（或其他模拟器）

2️⃣  如果提示文件已修改
    选择 "Revert" 或 "Discard and Continue"

3️⃣  解析 Swift Packages
    File → Packages → Resolve Package Versions
    (如果还提示 Missing package product)

4️⃣  清理并构建
    Product → Clean Build Folder (⇧⌘K)
    Product → Build (⌘B)
```

---

## 🎉 成功标志

当您看到：
```
✅ Build Succeeded
```

并且没有 Bundle ID 前缀错误，说明一切正常了！

---

## 💡 未来如何避免

1. **总是选择 `7RV2Y67HF6`**
   - 在 Xcode 的 Team 下拉菜单中
   - 仔细看括号中的 Team ID

2. **遇到问题就运行脚本**
   ```bash
   ./force_correct_team.sh
   ```

3. **Git Hook 会自动保护您**
   - 每次 pull 代码后自动修正
   - 不用担心别人的提交覆盖配置

---

## 📞 如果还有问题

运行诊断脚本：
```bash
./check_all_bundle_ids.sh
```

查看所有 Bundle ID 配置是否正确。

---

**现在请在 Xcode 中执行上面的 4 个步骤！** 🚀

记住：
- ✅ 选择模拟器（不需要 Provisioning Profile）
- ✅ 如果提示文件修改，选择 "Revert"
- ✅ Clean + Build

**然后告诉我结果！** 😊

