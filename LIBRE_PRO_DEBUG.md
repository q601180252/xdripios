# Libre Pro 数据存储调试指南

## 新增详细日志

已添加详细的 print 日志，用于追踪数据存储流程：

### 1. 数据解析阶段
```
[LibreDataParser] libreProDataProcessor 开始处理，sensorState=XXX, sensorTime=XXX 分钟
[LibreDataParser] 当前血糖值: XXX mg/dL, raw=XXX, dataQuality=0, trendArrow=3, 转换后=XXX mg/dL
[LibreDataParser] 处理历史值: XX 个
[LibreDataParser] 有效历史值: XX/XX
[LibreDataParser] 总计 glucoseData 数量: XX
```

### 2. 数据存储阶段
```
[LibreDataParser] 调用 handleGlucoseData 存储到数据库...
[LibreDataParser] handleGlucoseData 被调用，glucoseData 数量: XX, sensorState: ready
[LibreDataParser] ✅ 调用 cgmTransmitterInfoReceived 存储数据，glucoseData 数量: XX, sensorAge: XXX 分钟
[LibreDataParser] 数据样例（前 3 个）:
  [0] 时间: 2026-01-30 ..., 血糖: XX mg/dL
  [1] 时间: 2026-01-30 ..., 血糖: XX mg/dL
  [2] 时间: 2026-01-30 ..., 血糖: XX mg/dL
[LibreDataParser] ✅ 数据已传递给委托，存储流程完成
[LibreDataParser] handleGlucoseData 调用完成
```

## 查看日志步骤

### 在 Xcode 中
1. 运行应用（⌘ + R）
2. 连接 Libre Pro 传感器
3. 打开 Xcode 控制台（⌘ + Shift + Y）
4. 搜索关键词：
   - `[LibreDataParser]` - 查看数据处理日志
   - `[LibreProAlgorithm]` - 查看算法计算日志
   - `[Bubble BLE]` - 查看 BLE 通信日志

### 完整日志示例
```
[Bubble BLE] 收到 176 字节 trend
[LibreProAlgorithm] readProGlucoseValue 完成，当前血糖: 88 mg/dL, 趋势箭头: 3
[LibreProAlgorithm] readHistoricalValues 完成，有效历史值: 31/32

[LibreDataParser] libreProDataProcessor 开始处理，sensorState=ready, sensorTime=20160 分钟
[LibreDataParser] 当前血糖值: 88 mg/dL, raw=1108, dataQuality=0, trendArrow=3, 转换后=88.0 mg/dL
[LibreDataParser] 处理历史值: 31 个
[LibreDataParser] 有效历史值: 31/31
[LibreDataParser] 总计 glucoseData 数量: 32
[LibreDataParser] 调用 handleGlucoseData 存储到数据库...
[LibreDataParser] handleGlucoseData 被调用，glucoseData 数量: 32, sensorState: ready
[LibreDataParser] ✅ 调用 cgmTransmitterInfoReceived 存储数据，glucoseData 数量: 32, sensorAge: 20160.0 分钟
[LibreDataParser] 数据样例（前 3 个）:
  [0] 时间: 2026-01-30 17:50:00, 血糖: 88.0 mg/dL
  [1] 时间: 2026-01-30 17:35:00, 血糖: 128.0 mg/dL
  [2] 时间: 2026-01-30 17:50:00, 血糖: 141.0 mg/dL
[LibreDataParser] ✅ 数据已传递给委托，存储流程完成
[LibreDataParser] handleGlucoseData 调用完成
```

## 常见问题诊断

### ❌ 问题 1：看不到 [LibreDataParser] 日志
**原因**：`libreProDataProcessor` 没有被调用

**检查**：
1. 确认传感器类型识别为 Pro：
   ```
   [Bubble BLE] 0xC1 设置 Pro 模式
   ```

2. 确认调用了 Pro 处理函数（搜索 `libreDataParser.libreProDataProcessor`）

**解决**：检查 `CGMBubbleTransmitter.swift` 中的传感器类型判断

---

### ❌ 问题 2：日志显示 "传感器状态不是 ready" 或 "shutdown"
**症状**：
```
[LibreDataParser] sensorState=Sensor is shut down (trend[4]=0x05)
[LibreDataParser] ⚠️ 传感器状态不是 ready 或 expired，跳过数据处理
```

**原因**：传感器接近生命周期末期（14 天）时报告 `shutdown` 状态

**✅ 已修复**：
1. **Libre Pro 与 Libre 1 相同**：`trend[4]` 是 sensor state 字节
2. **iOS 现在接受 shutdown 状态**：跟随 Android 行为，允许 `ready`、`expired` 和 `shutdown` 三种状态
3. **Libre Pro 特性**：传感器在生命周期末期仍能提供有效数据

**修复后日志**：
```
[LibreDataParser] sensorState=Sensor is shut down (trend[4]=0x05)
[LibreDataParser] ℹ️ 传感器状态为 shutdown，但继续处理数据（Libre Pro 特性）
[LibreDataParser] ✅ 调用 cgmTransmitterInfoReceived 存储数据
```

---

### ❌ 问题 3：日志显示 "传感器时间 < 60 分钟"
**症状**：
```
[LibreDataParser] ⚠️ 传感器时间 < 60 分钟，处于启动阶段
```

**原因**：传感器刚激活，还在预热期

**解决**：等待传感器时间超过 60 分钟

---

### ❌ 问题 4：glucoseData 数量为 0
**症状**：
```
[LibreDataParser] 总计 glucoseData 数量: 0
```

**原因**：
1. 所有数据的 `dataQuality != 0`（异常数据）
2. 所有血糖值 <= 0
3. 检测到平坦值（传感器卡住）

**检查**：
- 查看算法日志中的 `dataQuality` 值
- 查看是否有 "detected flat values" 提示
- 确认原始 trend/history 数据不是全 0

---

### ✅ 正常情况：数据成功存储
**日志特征**：
```
[LibreDataParser] ✅ 调用 cgmTransmitterInfoReceived 存储数据，glucoseData 数量: 32
[LibreDataParser] 数据样例（前 3 个）:
  [0] 时间: ..., 血糖: 88.0 mg/dL
  ...
[LibreDataParser] ✅ 数据已传递给委托，存储流程完成
```

**验证**：
1. 在应用主界面查看血糖图表
2. 最新的值应该显示为当前血糖
3. 图表中应该有历史值的点

## 数据库验证

### 方法 1：应用界面
- 打开应用主界面
- 查看血糖图表
- 应该看到最新的血糖值和历史曲线

### 方法 2：Xcode 数据库检查
1. 打开 Xcode → Window → Devices and Simulators
2. 选择设备 → 下载应用容器
3. 使用 SQLite 浏览器查看数据库文件

### 方法 3：代码验证
在 `RootViewController` 或相关处理函数中添加日志：
```swift
func cgmTransmitterInfoReceived(glucoseData: inout [GlucoseData], ...) {
    print("[RootViewController] 收到 glucoseData: \(glucoseData.count) 个")
    // ... 存储逻辑
}
```

## 性能日志

所有关键操作都有耗时记录：
- 算法计算时间
- 数据库存储时间
- 总处理时间

可用于性能优化和问题诊断。

## 移除调试日志

如果需要移除详细的 print 日志（生产环境），搜索并注释掉：
```swift
print("[LibreDataParser] ...
```

保留 trace 日志即可（只在调试模式输出）。

---

**如果问题仍然存在，请提供完整的日志输出以便诊断！**
