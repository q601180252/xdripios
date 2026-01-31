import Foundation

/// Libre Pro 算法测试：使用真实数据对比 iOS 和 Android 结果
class LibreProAlgorithmTests {
    
    /// 真实 Libre Pro trend 数据 (176 字节)
    static let trendHex = "a0370020050004c04e0000000000000000000000000000004a454d573136382d5430323638335f23463410002d09c04e140396805a00eda608701a9b049cbb6b3b03c81b000000006cfdc04e0f003f0558049b081a0157049b00da004c049b081a0146049b001a014a049b041a0150049b041a0153049b041a0156049b001a0156049b041a0150049b001a0158049bf019015c04880a1a0158049b141a014c049b201a014c049b241a0154049bf01901"
    
    /// 真实 Libre Pro history 数据 (200 字节)
    static let historyHex = "190160069b781901dd069b80190167079b641901eb069b8419017d069ba819013f069bc41901fc059bd019010c069bcc1901f9059b981901a2059b5c19017c059b9458017d059bac570168059b245701f6049b00570142059be417013e059b985801c6049b1c1901b2049bcc1901c0049be419010e059b1c1a01fd049b1c1a01f9049bf819016d059b20da000c069b0c1a01b3069be8190140079be41901f9079b181a01fc089b4000000000000000004a454d573136382d5430323638335f23463410002d09c04e"
    
    /// Hex 转字节数组
    static func hexToBytes(_ hex: String) -> [UInt8] {
        var bytes = [UInt8]()
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            if let byte = UInt8(hex[index..<nextIndex], radix: 16) {
                bytes.append(byte)
            }
            index = nextIndex
        }
        return bytes
    }
    
    /// 测试 readProGlucoseValue (trend 数据)
    static func testReadProGlucoseValue() {
        print("\n========== 测试 Libre Pro Trend 数据 ==========")
        let trendData = hexToBytes(trendHex)
        print("trend 数据长度: \(trendData.count) 字节")
        
        // 解析 sensorTime
        let sensorTime = (Int(trendData[74]) & 0xFF) + ((Int(trendData[75]) & 0xFF) << 8)
        let trend = (Int(trendData[76]) & 0xFF) + ((Int(trendData[77]) & 0xFF) << 8)
        print("sensorTime: \(sensorTime) 分钟")
        print("trend index: \(trend)")
        
        guard let result = LibreProAlgorithm.readProGlucoseValue(trendData) else {
            print("❌ readProGlucoseValue 返回 nil")
            return
        }
        
        print("\n✅ iOS 计算结果:")
        print("  glucose: \(result.value) mg/dL")
        print("  raw: \(result.raw)")
        print("  dataQuality: \(result.dataQuality)")
        print("  trendArrow: \(result.trendArrow)")
        
        print("\n📋 JSON 格式（便于复制对比）:")
        print("""
        {
          "glucose": \(result.value),
          "raw": \(result.raw),
          "dataQuality": \(result.dataQuality),
          "trendArrow": \(result.trendArrow),
          "sensorTime": \(sensorTime),
          "trendIndex": \(trend)
        }
        """)
        
        print("\n💡 对比说明:")
        print("  - 在 Android 日志中搜索 'getLibreProGlucose' 或 'readProGlucoseValue'")
        print("  - 确认 glucose 值、trendArrow 等是否一致")
    }
    
    /// 测试 readHistoricalValues (history 数据)
    static func testReadHistoricalValues() {
        print("\n========== 测试 Libre Pro History 数据 ==========")
        let trendData = hexToBytes(trendHex)
        let historyData = hexToBytes(historyHex)
        print("history 数据长度: \(historyData.count) 字节")
        
        let (sensorTime, historyResults) = LibreProAlgorithm.readHistoricalValues(
            current: trendData,
            data: historyData,
            bstart: 0,
            start: 1005,
            end: 1030
        )
        
        print("\n✅ iOS 计算结果:")
        print("  sensorTime: \(sensorTime) 分钟")
        print("  有效历史值数量: \(historyResults.count)")
        
        if historyResults.count > 0 {
            print("\n  前 10 个历史值:")
            for (index, result) in historyResults.prefix(10).enumerated() {
                print("    [\(index)] time=\(result.time), glucose=\(result.oopValue) mg/dL, raw=\(result.raw), dq=\(result.dataQuality)")
            }
        }
        
        if historyResults.count > 10 {
            print("\n  ... (共 \(historyResults.count) 个历史值)")
            print("\n  最后 5 个历史值:")
            for (index, result) in historyResults.suffix(5).enumerated() {
                let realIndex = historyResults.count - 5 + index
                print("    [\(realIndex)] time=\(result.time), glucose=\(result.oopValue) mg/dL, raw=\(result.raw), dq=\(result.dataQuality)")
            }
        }
        
        print("\n📋 JSON 格式（前 5 个值）:")
        print("[")
        for (index, result) in historyResults.prefix(5).enumerated() {
            let comma = index < min(4, historyResults.count - 1) ? "," : ""
            print("  {\"time\": \(result.time), \"glucose\": \(result.oopValue), \"raw\": \(result.raw), \"dq\": \(result.dataQuality)}\(comma)")
        }
        print("]")
        
        print("\n💡 对比说明:")
        print("  - 在 Android 日志中搜索 'readHistoricalValues' 或 'pressHistroy2'")
        print("  - 确认每个时间点的 glucose 值是否一致")
        print("  - start=1005, end=1030 (count=25)")
    }
    
    /// 运行所有测试
    static func runAllTests() {
        print("\n" + String(repeating: "=", count: 60))
        print("Libre Pro 算法测试 - iOS vs Android")
        print(String(repeating: "=", count: 60))
        
        testReadProGlucoseValue()
        testReadHistoricalValues()
        
        print("\n" + String(repeating: "=", count: 60))
        print("测试完成！请对比 Android 日志验证结果一致性")
        print(String(repeating: "=", count: 60) + "\n")
    }
}

// MARK: - 快速运行测试（可在任何地方调用）
extension LibreProAlgorithmTests {
    /// 在应用启动或任意位置调用此函数运行测试
    static func quickTest() {
        DispatchQueue.global(qos: .utility).async {
            runAllTests()
        }
    }
}
