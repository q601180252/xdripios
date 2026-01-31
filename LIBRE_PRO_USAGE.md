# Libre Pro 使用说明

## 数据存储流程

Libre Pro 传感器的数据存储流程与 Libre 1/2 完全一致，通过以下步骤自动保存到数据库：

### 1. BLE 数据接收
`CGMBubbleTransmitter.swift` 接收到 Libre Pro 的 BLE 数据包（`0x82`）：
- **Trend 数据**：176 字节（16 个 1 分钟间隔的血糖值）
- **History 数据**：200 字节（最多 32 个 15 分钟间隔的历史值）

### 2. 数据解析
`LibreProAlgorithm.swift` 完整实现 Android `librepro.cpp` 算法：
- `readProGlucoseValue(trend)` - 解析当前血糖值和趋势箭头
- `readHistoricalValues(trend, history, ...)` - 解析历史血糖值

### 3. 数据处理
`LibreDataParser.libreProDataProcessor(...)` 处理解析结果：
- 创建 `GlucoseData` 数组（当前值 + 历史值）
- 检测平坦值（传感器卡住）
- 按时间戳排序（最新的在前）
- 存储 `previousRawValues` 用于下次连接填补间隙

### 4. 数据存储
`handleGlucoseData(...)` 调用委托方法存储到数据库：
```swift
cgmTransmitterDelegate?.cgmTransmitterInfoReceived(
    glucoseData: &glucoseData,
    transmitterBatteryInfo: nil,
    sensorAge: TimeInterval(minutes: Double(sensorTimeInMinutes))
)
```

数据自动保存到 Core Data 数据库，可在应用界面查看。

## 数据特点

### Trend 数据（当前值）
- **频率**：每 1 分钟
- **数量**：16 个值
- **计算**：通过完整的 Temp1-7Ex 算法
- **范围**：39-501 mg/dL
- **质量**：dataQuality=0 表示正常

### History 数据（历史值）
- **频率**：每 15 分钟
- **数量**：最多 32 个值
- **时间戳**：相对于传感器启动时间（分钟）
- **过滤**：自动跳过 dataQuality!=0 的异常值

## 平坦值检测

如果连续 5 个值完全相同，认为传感器卡住，不存储数据：
```swift
if first5Values.allSatisfy({ $0 == first5Values[0] }) {
    // 跳过数据，避免误导性读数
}
```

## 间隙填补

应用会存储最近 20 个原始值，用于下次连接时填补间隙：
```swift
previousRawValues = glucoseData.prefix(20).map { $0.glucoseLevelRaw }
```

## 日志追踪

所有关键步骤都有详细日志，可在 Xcode 控制台查看：
- `[LibreDataParser] in libreProDataProcessor, ...`
- `[LibreProAlgorithm] readProGlucoseValue 完成，当前血糖: X mg/dL`
- `[LibreProAlgorithm] readHistoricalValues 完成，有效历史值: X/Y`

## 数据库查看

### 当前血糖
- 显示在主界面血糖图表
- 最新的值作为"当前血糖"

### 历史血糖
- 所有值按时间排序显示在图表中
- 15 分钟间隔的历史值填补连接间隙

### 传感器信息
- **传感器年龄**：`sensorTimeInMinutes` 分钟
- **传感器状态**：从 `trend[4]` 读取（与 Libre 1 相同）
  - `0x03`: ready（正常工作）✅ **只有此状态会存储数据**
  - `0x04`: expired（过期）❌ 不存储数据
  - `0x05`: shutdown（关闭）❌ 不存储数据
- **数据质量**：正常值 dataQuality=0

**重要**：为确保数据质量，**只有 `ready` 状态的数据会被存储**。传感器在生命周期末期（接近 14 天）可能报告 `expired` 或 `shutdown` 状态，此时数据将被忽略。

## 算法验证

### 与 Android 对比
已验证 iOS 算法与 Android `diaboxkotlin` 完全一致：
- ✅ glucose 值完全相同
- ✅ raw 值完全相同
- ✅ dataQuality 完全相同
- ✅ trendArrow 正确计算

### 测试用例
如需手动测试算法，在代码中调用：
```swift
LibreProAlgorithmTests.runAllTests()
```

测试会使用真实的 176 字节 trend 和 200 字节 history 数据，输出 JSON 格式结果便于对比。

## 常见问题

### 1. 数据不显示？
- 检查传感器运行时间是否 >= 60 分钟（预热期不存储数据）
- 查看日志是否有 "detected flat values" 提示
- 确认 `dataQuality=0`（非 0 表示异常数据）
- 确认传感器状态：日志中应显示 "sensorState=ready" 或 "expired"

### 2. 数据有间隙？
- 正常现象，15 分钟历史值之间本身有间隙
- `previousRawValues` 机制会在下次连接时尝试填补

### 3. 血糖值不准确？
- 确认与 Android 对比结果一致
- 检查传感器是否正常工作（非启动或过期状态）
- 查看 `calibrationInfo` 是否正确解析

### 4. 趋势箭头不显示？
- 检查 `bTrendArrow` 条件是否满足
- 确认 `calibratinoInfoValue` 不为 0
- 查看日志中的 `dCurr1` 和 `trendArrow` 值

## 技术细节

### 算法来源
完整移植自 Android `diaboxkotlin` 项目：
- `/app/src/main/cpp/librepro.cpp` - 核心算法
- `/app/src/main/cpp/diaboxXabet.cpp` - JNI 接口

### 关键 Bug 修复
1. **readBits 函数**：字节索引计算错误（第 90 行）
   ```swift
   // 错误：let byteIndex = byteOffset + totalBitOffset / 8
   // 正确：let byteIndex = totalBitOffset / 8
   ```

2. **bTrendArrow 检查**：缺少 Android 的条件逻辑
   - 当 `calibratinoInfoValue` 为 0 时，返回 `trendArrow=0`

### 文件位置
- **算法实现**：`LibreProAlgorithm.swift` (617 行)
- **数据解析**：`LibreDataParser.libreProDataProcessor(...)`
- **BLE 通信**：`CGMBubbleTransmitter.swift`
- **测试用例**：`LibreProAlgorithmTests.swift`

## 更新历史

- **2026-01-30**：完整实现 Libre Pro 算法并验证与 Android 一致
- **2026-01-30**：添加数据存储、平坦值检测、间隙填补
- **2026-01-30**：修复 project.pbxproj 编译错误

---

**状态**：✅ 已完成并验证，可用于生产环境
