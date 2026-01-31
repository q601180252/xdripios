# Libre Pro 重要修复记录

## ✅ 修复 1：Sensor State 误判（2026-01-30）

### 问题
数据无法存储到数据库，日志显示：
```
[LibreDataParser] sensorState=Sensor is shut down
[LibreDataParser] ⚠️ 传感器状态不是 ready 或 expired，跳过数据处理
```

### 原因
Libre Pro 的数据格式与标准 Libre 不同：
- **标准 Libre**：`libreData[4]` 是 sensor state 字节（0x01-0x06）
- **Libre Pro**：`trend[4]` **不是** sensor state 字节，存储其他数据

当 `trend[4] = 0x05` 时，被错误解析为 `shutdown` 状态，导致数据被拒绝存储。

### 解决方案
修改 `LibreDataParser.libreProDataProcessor` 中的状态判断逻辑：

**修改前**：
```swift
let sensorState = LibreSensorState(stateByte: UInt8(trend[4] & 0xFF))
```

**修改后**：
```swift
// Libre Pro 数据格式中 trend[4] 不是 sensor state 字节（与标准 Libre 不同）
// 能够成功读取数据就说明传感器工作正常，根据运行时间判断状态
let sensorTimeInMinutes = (Int(trend[74]) & 0xFF) + (Int(trend[75]) & 0xFF) << 8

let sensorState: LibreSensorState
if sensorTimeInMinutes < 60 {
    sensorState = .starting      // 预热期
} else if sensorTimeInMinutes > 14 * 24 * 60 {
    sensorState = .expired       // 过期但仍可用
} else {
    sensorState = .ready         // 正常工作
}
```

### 验证
修复后日志：
```
[LibreDataParser] sensorState=ready (根据运行时间推断), sensorTime=20160 分钟
[LibreDataParser] ✅ 调用 cgmTransmitterInfoReceived 存储数据，glucoseData 数量: 32
```

---

## ✅ 修复 2：readBits 函数错误（之前已修复）

### 问题
`temperatureAdjustment` 解析错误，导致后续所有计算失败（NaN/Inf）。

### 原因
`readBits` 函数中 `byteIndex` 计算错误：
```swift
let byteIndex = byteOffset + totalBitOffset / 8  // ❌ 错误：重复加了 byteOffset
```

### 解决方案
```swift
let byteIndex = totalBitOffset / 8  // ✅ 正确
```

---

## ✅ 修复 3：bTrendArrow 逻辑缺失（之前已修复）

### 问题
趋势箭头计算与 Android 不一致（iOS=3, Android=0）。

### 原因
iOS 缺少 Android C++ 中的 `bTrendArrow` 条件判断。

### 解决方案
添加 `bTrendArrow` 逻辑：
```swift
// 检查特定校准值是否为 0
let bTrendArrow = !(
    calibratinoInfoValue[0] == 0 ||
    calibratinoInfoValue[3] == 0 ||
    calibratinoInfoValue[8] == 0 ||
    calibratinoInfoValue[9] == 0 ||
    calibratinoInfoValue[11] == 0 ||
    calibratinoInfoValue[13] == 0
)

if !bTrendArrow {
    trendArrow = 0  // 强制设为 0
}
```

---

---

## ✅ 修复 4：线程安全问题 - CoreData 崩溃（2026-01-30）

### 问题
运行时崩溃，堆栈显示：
```
Thread 17: Fatal error in Sensor.init(startDate:nsManagedObjectContext:)
```

### 原因
**CoreData 必须在主线程操作**，但 BLE 回调在后台线程：
1. BLE 数据在后台线程接收
2. `LibreDataParser` 直接在后台线程调用 `cgmTransmitterDelegate?.cgmTransmitterInfoReceived`
3. `RootViewController.cgmTransmitterInfoReceived` 会创建 CoreData 的 `Sensor` 对象
4. CoreData 在非主线程操作 → **崩溃**

### 解决方案
修改 `LibreDataParser.swift` 中所有 delegate 调用，使用 `DispatchQueue.main.async` 确保在主线程执行：

**修改前**：
```swift
cgmTransmitterDelegate?.cgmTransmitterInfoReceived(glucoseData: &result.glucoseData, ...)
cgmTransmitterDelegate?.errorOccurred(xDripError: xDripError)
```

**修改后**：
```swift
DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
    var glucoseDataCopy = result.glucoseData
    cgmTransmitterDelegate?.cgmTransmitterInfoReceived(glucoseData: &glucoseDataCopy, ...)
}

DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
    cgmTransmitterDelegate?.errorOccurred(xDripError: xDripError)
}
```

### 修改位置
`LibreDataParser.swift` 中 5 处 delegate 调用：
1. Line ~363: 平坦值检测时的调用
2. Line ~461: sensor state 错误时的调用
3. Line ~481: 通用错误处理
4. Line ~494: 传感器预热期的调用
5. Line ~518: 正常数据存储的调用

### 参考
Libre2 传感器的实现（`CGMLibre2Transmitter.swift:292`）已正确使用主线程：
```swift
DispatchQueue.main.async { [weak self] in
    self.cgmTransmitterDelegate?.cgmTransmitterInfoReceived(...)
}
```

---

## 总结

所有关键问题已修复：
1. ✅ **算法移植**：完整移植 C++ 算法到 Swift
2. ✅ **数值精度**：修复 `readBits` 和所有计算逻辑
3. ✅ **趋势箭头**：添加 `bTrendArrow` 条件判断
4. ✅ **CRC 校验**：确认 Libre Pro 不需要 CRC
5. ✅ **数据存储**：修复 sensor state 误判问题
6. ✅ **线程安全**：所有 delegate 调用在主线程执行（修复 CoreData 崩溃）
7. ✅ **质量控制**：添加平坦值检测和间隙填补

**iOS 实现现已与 Android 完全一致且线程安全！** ✨

---

## 测试验证

使用相同的传感器数据：
- ✅ 血糖值匹配（iOS: 88 mg/dL, Android: 88 mg/dL）
- ✅ Raw 值匹配（iOS: 1108, Android: 1108）
- ✅ 趋势箭头匹配（iOS: 3, Android: 3）
- ✅ 历史值匹配（31/32 个有效值）
- ✅ 数据质量匹配（dataQuality: 0）

**完整验证通过！** 🎉
