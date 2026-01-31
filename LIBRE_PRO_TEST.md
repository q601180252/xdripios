# Libre Pro 算法测试说明

## 测试自动运行

测试会在**首次接收到 Libre Pro 数据时自动运行**（`LibreDataParser.libreProDataProcessor` 被调用时）。

测试结果会输出到 Xcode 控制台，搜索 `[LibreProAlgorithm]` 即可找到。

## 手动运行测试

如果需要手动触发测试，可以在任何地方调用：

```swift
LibreProAlgorithmTests.runAllTests()
```

或在后台线程运行：

```swift
LibreProAlgorithmTests.quickTest()
```

## 测试数据

测试使用真实的 Libre Pro 传感器数据：
- **Trend 数据**：176 字节（2026-01-30 采集）
- **History 数据**：200 字节（start=1005, count=25）

## 输出格式

### Trend 数据测试结果
```
✅ iOS 计算结果:
  glucose: XXX mg/dL
  raw: XXX
  dataQuality: 0
  trendArrow: X
  
📋 JSON 格式:
{
  "glucose": XXX,
  "raw": XXX,
  "dataQuality": 0,
  "trendArrow": X,
  "sensorTime": XXXXX,
  "trendIndex": XX
}
```

### History 数据测试结果
```
✅ iOS 计算结果:
  sensorTime: XXXXX 分钟
  有效历史值数量: XX
  
  前 10 个历史值:
    [0] time=XXXXX, glucose=XXX mg/dL, raw=XXX, dq=0
    [1] time=XXXXX, glucose=XXX mg/dL, raw=XXX, dq=0
    ...
    
📋 JSON 格式（前 5 个值）:
[
  {"time": XXXXX, "glucose": XXX, "raw": XXX, "dq": 0},
  {"time": XXXXX, "glucose": XXX, "raw": XXX, "dq": 0},
  ...
]
```

## 对比 Android 结果

### 1. 获取 Android 输出

在 Android diaboxkotlin 日志中搜索：
- `getLibreProGlucose` - trend 数据结果
- `readHistoricalValues` 或 `pressHistroy2` - history 数据结果

### 2. 对比关键值

**Trend 数据**：
- ✅ `glucose` 值（当前血糖）
- ✅ `trendArrow`（趋势箭头：1=下降快, 2=下降, 3=平稳, 4=上升, 5=上升快）
- ✅ `dataQuality`（应该为 0 表示正常）

**History 数据**：
- ✅ 每个时间点的 `glucose` 值
- ✅ `time` 值（分钟）
- ✅ 有效值数量

### 3. 预期结果

如果算法移植正确，iOS 和 Android 的结果应该**完全一致**：
- 所有葡萄糖值相同（误差 ≤ 1 mg/dL，因为四舍五入）
- 趋势箭头相同
- 有效值数量相同

## 测试数据来源

测试数据来自真实的 Libre Pro 传感器（序列号：215C660000A407E0），通过 Bubble 设备采集：
- Firmware: 8.1
- Hardware: 1.5
- Battery: 100%
- 采集时间：2026-01-30

## 故障排查

如果测试没有自动运行：
1. 确保使用 Libre Pro 传感器（不是 Libre 1/2/H）
2. 确保 Bubble 固件支持 Pro 模式
3. 检查 Xcode 控制台是否有错误信息
4. 手动调用 `LibreProAlgorithmTests.runAllTests()`

如果结果与 Android 不一致：
1. 确认使用的是同一份原始数据（hex 字符串）
2. 检查 `readBits` 函数是否正确（这是之前发现的关键 bug）
3. 检查所有常量表（t1, t2, tX, tY, tA, tB, tC）是否与 C++ 代码一致
4. 检查温度计算公式是否正确

## 相关文件

- `LibreProAlgorithm.swift` - 核心算法实现
- `LibreProAlgorithmTests.swift` - 测试用例
- `LibreDataParser.swift` - 数据处理入口（自动触发测试）
- `CGMBubbleTransmitter.swift` - BLE 通信

## 备注

- 测试仅在首次接收 Pro 数据时运行一次，避免重复输出
- 测试在后台线程运行，不会阻塞主线程
- 测试数据已硬编码在 `LibreProAlgorithmTests.swift` 中
