# Libre Pro 严格模式说明

## 当前实现：严格模式

**只有传感器状态为 `ready` 时才存储数据**

---

## 关键代码

### 1. 读取传感器状态（LibreDataParser.swift:290）
```swift
// Libre Pro 与 Libre 1 相同，trend[4] 是 sensor state 字节
let sensorState = LibreSensorState(stateByte: UInt8(trend[4] & 0xFF))
```

### 2. 严格状态检查（LibreDataParser.swift:496）
```swift
// 严格检查：只允许 ready 状态存储数据
// expired 和 shutdown 状态可能返回不可靠的数据
if sensorState != .ready {
    print("[LibreDataParser] ⚠️ 传感器状态不是 ready (当前: \(sensorState.description))，跳过数据处理")
    return  // ❌ 数据不会被存储
}
```

---

## 传感器状态对照表

| trend[4] | 状态名称 | 说明 | 存储数据 |
|----------|----------|------|---------|
| 0x01 | notYetStarted | 未激活 | ❌ 否 |
| 0x02 | starting | 预热期（< 60 分钟）| ❌ 否 |
| **0x03** | **ready** | **正常工作** | **✅ 是** |
| 0x04 | expired | 已过期（14 天后）| ❌ 否 |
| 0x05 | shutdown | 已关闭（生命周期末期）| ❌ 否 |
| 0x06 | failure | 传感器故障 | ❌ 否 |
| 其他 | unknown | 未知状态 | ❌ 否 |

---

## 运行时日志

### ✅ 正常情况（ready 状态）
```
[Bubble BLE] trend hex: a0370020 03 0004c04e...
                              ^^
                        trend[4] = 0x03 = ready

[LibreDataParser] libreProDataProcessor 开始处理，sensorState=Sensor is ready (trend[4]=0x03)
[LibreDataParser] 当前血糖值: 88 mg/dL, raw=1108, dataQuality=0

[LibreDataParser] ========== 处理历史值: 31 个 ==========
  [ 0] ✅ time=19680分钟 | 血糖=128 mg/dL | raw=1632 | dataQuality=0
  ...

[LibreDataParser] handleGlucoseData 被调用，sensorState: Sensor is ready
[LibreDataParser] ✅ 调用 cgmTransmitterInfoReceived 存储数据，glucoseData 数量: 32
[LibreDataParser] ✅ 数据已传递给委托，存储流程完成
```

### ❌ 异常情况（shutdown 状态）
```
[Bubble BLE] trend hex: a0370020 05 0004c04e...
                              ^^
                        trend[4] = 0x05 = shutdown

[LibreDataParser] libreProDataProcessor 开始处理，sensorState=Sensor is shut down (trend[4]=0x05)
[LibreDataParser] 当前血糖值: 88 mg/dL, raw=1108, dataQuality=0

[LibreDataParser] ========== 处理历史值: 31 个 ==========
  [ 0] ✅ time=19680分钟 | 血糖=128 mg/dL | raw=1632 | dataQuality=0
  ...

[LibreDataParser] handleGlucoseData 被调用，sensorState: Sensor is shut down
[LibreDataParser] ⚠️ 传感器状态不是 ready (当前: Sensor is shut down)，跳过数据处理
❌ 数据不会被存储
```

---

## 为什么传感器是 shutdown 状态？

### 1. 传感器寿命到期
- **Libre Pro 传感器设计寿命：14 天**
- 从你的日志：`sensorTime=20160 分钟 = 14 天`
- 传感器达到或超过 14 天后会自动进入 `expired` 或 `shutdown` 状态
- **解决方案**：激活并使用新的传感器

### 2. 传感器状态字节错误（不太可能）
- `trend[4]` 字节损坏或通信错误
- 可以通过对比多次读取验证

### 3. 传感器提前关闭（异常情况）
- 传感器质量问题
- 佩戴问题导致提前失效
- **解决方案**：联系厂商更换

---

## 如何确认传感器真实状态？

### 方法 1：查看日志中的 trend[4] 值
```
[LibreDataParser] sensorState=Sensor is shut down (trend[4]=0x05)
                                                           ^^^^
                                                      确认是 0x05
```

### 方法 2：查看传感器运行时间
```
[LibreDataParser] sensorTime=20160 分钟
20160 分钟 = 336 小时 = 14 天  ← 已达到生命周期末期
```

### 方法 3：查看原始 trend 数据
```
[Bubble BLE] trend hex: a0370020050004c04e...
位置索引:                 0123456789...
                            ↑
                        trend[4] = 0x05
```

---

## 如果需要强制存储 shutdown 状态的数据

**⚠️ 不推荐：传感器进入 shutdown 状态后数据可能不准确**

如果确实需要（仅用于测试/调试），修改 `LibreDataParser.swift:496`：

```swift
// 修改前（严格模式）
if sensorState != .ready {
    return  // 拒绝所有非 ready 状态
}

// 修改后（宽松模式 - 不推荐）
if sensorState != .ready && sensorState != .shutdown {
    return  // 也接受 shutdown 状态
}
```

---

## 建议

### 当前情况分析
根据日志：
- ✅ 算法计算正确：血糖 88 mg/dL
- ✅ 历史值解析正确：31 个有效值
- ⚠️ 传感器状态：shutdown (0x05)
- ⚠️ 传感器运行时间：14 天（寿命到期）
- ❌ 数据不会被存储（严格模式）

### 推荐操作
1. **更换新传感器**（最佳方案）
   - Libre Pro 传感器已达到 14 天寿命
   - 激活新传感器后状态会是 `ready`
   - 数据将正常存储

2. **验证传感器真实状态**
   - 如果是新传感器但显示 shutdown，可能是传感器质量问题
   - 联系厂商更换

3. **保持当前严格模式**
   - 确保数据质量
   - 避免存储不可靠的数据

---

## 相关文档
- **LIBRE_PRO_USAGE.md** - 使用说明
- **LIBRE_PRO_DEBUG.md** - 调试指南
- **LIBRE_PRO_FIXES.md** - 修复记录

---

**当前实现符合严格模式要求 ✅**
