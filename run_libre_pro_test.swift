#!/usr/bin/env swift
import Foundation

// 将 LibreProAlgorithm.swift 和测试代码合并到一个独立脚本中
// 这样可以直接运行而不依赖 Xcode 项目

print("正在加载 LibreProAlgorithm.swift 和测试代码...")

// 测试数据
let trendHex = "a0370020050004c04e0000000000000000000000000000004a454d573136382d5430323638335f23463410002d09c04e140396805a00eda608701a9b049cbb6b3b03c81b000000006cfdc04e0f003f0558049b081a0157049b00da004c049b081a0146049b001a014a049b041a0150049b041a0153049b041a0156049b001a0156049b041a0150049b001a0158049bf019015c04880a1a0158049b141a014c049b201a014c049b241a0154049bf01901"
let historyHex = "190160069b781901dd069b80190167079b641901eb069b8419017d069ba819013f069bc41901fc059bd019010c069bcc1901f9059b981901a2059b5c19017c059b9458017d059bac570168059b245701f6049b00570142059be417013e059b985801c6049b1c1901b2049bcc1901c0049be419010e059b1c1a01fd049b1c1a01f9049bf819016d059b20da000c069b0c1a01b3069be8190140079be41901f9079b181a01fc089b4000000000000000004a454d573136382d5430323638335f23463410002d09c04e"

func hexToBytes(_ hex: String) -> [UInt8] {
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

print("转换 hex 数据...")
let trendData = hexToBytes(trendHex)
let historyData = hexToBytes(historyHex)

print("trend 数据: \(trendData.count) 字节")
print("history 数据: \(historyData.count) 字节")

// 解析基本信息
let sensorTime = (Int(trendData[74]) & 0xFF) + ((Int(trendData[75]) & 0xFF) << 8)
let trendIndex = (Int(trendData[76]) & 0xFF) + ((Int(trendData[77]) & 0xFF) << 8)

print("\n基本信息:")
print("  sensorTime: \(sensorTime) 分钟")
print("  trendIndex: \(trendIndex)")

print("\n由于 LibreProAlgorithm 代码较大，需要从源文件导入...")
print("正在读取 LibreProAlgorithm.swift...")

