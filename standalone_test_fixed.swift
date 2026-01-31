import Foundation

// MARK: - Libre Pro 完整算法（与 librepro.cpp 对齐）

/// 与 C++ BLEGlucoseValue 对应，用于 trend/history 中间计算
struct LibreProBLEGlucoseValue {
    var temperatureAdjustment: Double = 0
    var temperature: Double = 0
    var value: Double = 0
    var type: Int = 0
    var value2: Int = 0
    var temperatureTemp1: Double = 0
    var calibratinoInfoValue: Double = 0
    var value3: Double = 0
    var t3ddiv1: Double = 0
    var countMath3: Int = 0
    var value4: Double = 0
    var countMath4: Int = 0
    var value5: Double = 0
    var t5ddiv1: Double = 0
    var countMath5: Int = 0
    var value6: Double = 0
    var value6x1: Double = 0
    var value7: Double = 0
    var timeOffset: Double = 0
    var time: Int = 0
    var oopValue: Double = 0
    var dataQuality: Int = 0
}

// MARK: - 常量表（与 librepro.cpp 一致）

private let t1: [Double] = [
    0.75, 0.75, 0.75, 1.75, 0.75, 1.0, 1.25, 1.5, 1.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75,
    0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75,
    0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75,
    0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75,
    0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 2.5, 2.25, 2.0, 1.75, 1.5, 1.5, 1.25, 1.0, 0.75, 2.75,
    2.5, 2.25, 2.0, 1.75, 1.5, 1.25, 1.0, 0.75, 2.75, 2.5, 2.25, 2.0, 1.75, 1.5, 1.5, 1.5, 1.5,
    1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5,
    1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.25, 1.0, 2.75, 2.75, 2.5, 2.0, 1.75, 1.5
]

private let t2: [Double] = [
    0.038121700000000001, 0.0385029, 0.038887900000000003, 0.040871600000000001,
    0.041280299999999999, 0.041693099999999997, 0.042110000000000002, 0.042531100000000002,
    0.042531100000000002, 0.040871600000000001, 0.041280299999999999, 0.042110000000000002,
    0.042531100000000002, 0.042531100000000002, 0.042956500000000002, 0.043386000000000001,
    0.043819900000000002, 0.044258100000000002, 0.044700700000000003, 0.045147699999999999,
    0.046055100000000002, 0.0465157, 0.046980800000000003, 0.047450600000000002,
    0.047925200000000001, 0.0484044, 0.048888399999999999, 0.049377299999999999,
    0.049871100000000002, 0.050369799999999999, 0.050873500000000002, 0.051382299999999999,
    0.051896100000000001, 0.052415000000000003, 0.052939199999999999, 0.054003299999999997,
    0.054543300000000003, 0.055088699999999997, 0.055639599999999997, 0.056196000000000003,
    0.056758000000000003, 0.057325599999999997, 0.0578988, 0.058477800000000003, 0.0590626,
    0.059653200000000003, 0.060249700000000003, 0.060852200000000002, 0.0614607,
    0.062075400000000003, 0.062696100000000005, 0.063323099999999993, 0.063956299999999994,
    0.064595899999999998, 0.065241800000000003, 0.0658942, 0.066553200000000007,
    0.067218700000000006, 0.067890900000000004, 0.0685698, 0.069255499999999998,
    0.069948099999999999, 0.070647500000000002, 0.071354000000000001, 0.072067599999999996,
    0.072067599999999996, 0.072788199999999997, 0.073516100000000001, 0.074251300000000006,
    0.074993799999999999, 0.075743699999999997, 0.075743699999999997, 0.076501200000000005,
    0.077266199999999993, 0.078038800000000005, 0.078038800000000005, 0.078819200000000006,
    0.079607399999999995, 0.080403500000000003, 0.081207500000000002, 0.082019599999999998,
    0.082839800000000005, 0.083668199999999998, 0.084504899999999994, 0.084504899999999994,
    0.085349900000000006, 0.086203399999999999, 0.087065500000000004, 0.087936100000000003,
    0.088815500000000006, 0.089703599999999994, 0.090600700000000006, 0.091506699999999996,
    0.092421699999999996, 0.093345999999999998, 0.094279399999999999, 0.095222200000000007,
    0.096174399999999993, 0.097136200000000006, 0.0981075, 0.099088599999999999, 0.1000795,
    0.1010803, 0.1020911, 0.103112, 0.1041431, 0.1051846, 0.10623639999999999, 0.1072988,
    0.1083718, 0.1094555, 0.11055, 0.1116555, 0.1127721, 0.1138998, 0.1150388,
    0.11618920000000001, 0.1173511, 0.11852459999999999, 0.11970989999999999, 0.120907,
    0.122116, 0.12333719999999999, 0.12333719999999999, 0.1245706, 0.1270744,
    0.12834519999999999, 0.12834519999999999
]

private let tX: [Double] = [14.77, 15.46, 16.67, 18.93, 20.33, 20.74, 22.39, 23.08, 23.57, 23.34, 23.99, 23.34, 22.11, 23.51, 25.06]
private let tY: [Double] = [-3.24, -3.37, -4.01, -5.83, -6.44, -6.08, -7.38, -7.47, -7.64, -6.9, -6.52, -5.67, -3.82, -4.63, -5.73]
private let tA: [Double] = [-0.324, -0.337, -0.401, -0.583, -0.644, -0.608, -0.738, -0.747, -0.764, -0.69, -0.652, -0.567, -0.382, -0.463, -0.573]
private let tB: [Double] = [1.477, 1.546, 1.667, 1.893, 2.033, 2.074, 2.239, 2.308, 2.357, 2.334, 2.399, 2.334, 2.211, 2.351, 2.506]
private let tC: [Double] = [92.0, 91.0, 91.0, 90.0, 89.0, 88.0, 88.0, 87.0, 86.0, 86.0, 85.0, 83.0, 83.0, 82.0, 82.0]

// MARK: - 位读取与校准

private func readBits(_ buffer: [UInt8], byteOffset: Int, bitOffset: Int, bitCount: Int) -> Int {
    if bitCount == 0 { return 0 }
    var res = 0
    for i in 0..<bitCount {
        let totalBitOffset = byteOffset * 8 + bitOffset + i
        let byteIndex = totalBitOffset / 8  // ✅ 修复：totalBitOffset 已包含 byteOffset
        let bit = totalBitOffset % 8
        if totalBitOffset >= 0, byteIndex < buffer.count, (Int(buffer[byteIndex]) >> bit) & 1 == 1 {
            res |= (1 << i)
        }
    }
    return res
}

private func sub_78A14(_ buffer: [UInt8], byteOffset: Int, a3: Int) -> Bool {
    let iOffset = a3 >> 3
    let byteIndex = byteOffset + iOffset
    guard byteIndex < buffer.count else { return false }
    let bUse = Int(buffer[byteIndex])
    let iTemp1 = a3 & 7
    let iTemp2 = 1 << iTemp1
    return (bUse & iTemp2) != 0
}

/// 从 trend/FRAM 前 76 字节解析校准信息 [i1,i2,i3,i4,i5,i6]
private func readCalibrationInfo(_ data: [UInt8]) -> [Int] {
    let i1index = 64
    let i3index = 56
    let i1 = readBits(data, byteOffset: i1index, bitOffset: 0, bitCount: 3)
    let i2 = readBits(data, byteOffset: i1index, bitOffset: 3, bitCount: 10)
    var i3 = readBits(data, byteOffset: i3index, bitOffset: 0, bitCount: 8)
    let i4 = readBits(data, byteOffset: i3index, bitOffset: 8, bitCount: 14)
    let negativei3 = readBits(data, byteOffset: i3index, bitOffset: 0x21, bitCount: 1)
    if negativei3 != 0 { i3 = -i3 }
    let i5 = readBits(data, byteOffset: i3index, bitOffset: 0x28, bitCount: 12) << 2
    let i6 = readBits(data, byteOffset: i3index, bitOffset: 0x34, bitCount: 12) << 2
    return [i1, i2, i3, i4, i5, i6]
}

private func glucoseTemperatureTempFromRaw(_ raw: LibreProBLEGlucoseValue, calibrationInfo: [Int]) -> Double {
    if raw.temperature == 128 { return 0.0 }
    let ca = 0.0009180023, cb = 0.0001964561, cc = 0.0000007061775, cd = 0.00000005283566
    let divisor = raw.temperatureAdjustment + Double(calibrationInfo[5])
    let R = (raw.temperature * Double(1000 + 71500)) / divisor - Double(1000)
    guard R >= 0 else { return 0.0 }
    let logR = log(R)
    let d = pow(logR, 3) * cd + pow(logR, 2) * cc + logR * cb + ca
    let result = 1.0 / d - 273.15
    return result
}

private func getTemperatureTempValue(i: Int, count: Int, idSum: Double, idPowSum: Double, valueSum: Double, idMultiplyValueSum: Double, values: inout [LibreProBLEGlucoseValue]) -> Double {
    let dm1 = idPowSum * Double(count) - idSum * idSum
    let dm2 = idMultiplyValueSum * Double(count) - valueSum * idSum
    var ddiv1 = 0.0
    if abs(dm1) > 0.000001 { ddiv1 = dm2 / dm1 }
    values[i].t5ddiv1 = ddiv1
    var d0 = 0.0, d3 = 0.0, d2 = 0.0
    if abs(Double(count)) > 0.000001 {
        d0 = (idSum * ddiv1) / Double(count)
        d3 = valueSum / Double(count)
        d2 = d3 - d0
    }
    var res2 = d2 + ddiv1 * Double(values[i].time)
    if count == 1 { res2 = 0.0 }
    return res2
}

// MARK: - Temp1 ~ Temp7Ex

private func readGlucoseValueTemp1(_ data: [UInt8], offset: Int, i: Int, values: inout [LibreProBLEGlucoseValue], calibrationInfo: [Int]) {
    var temperatureAdjustment = readBits(data, byteOffset: offset, bitOffset: 0x26, bitCount: 9) << 2
    if readBits(data, byteOffset: offset, bitOffset: 0x2f, bitCount: 1) != 0 { temperatureAdjustment = -temperatureAdjustment }
    let value = readBits(data, byteOffset: offset, bitOffset: 0, bitCount: 14)
    let itype = readBits(data, byteOffset: offset, bitOffset: 14, bitCount: 11)
    let temperature = readBits(data, byteOffset: offset, bitOffset: 0x1a, bitCount: 12) << 2

    if sub_78A14(data, byteOffset: offset, a3: 0x19) {
        values[i].type = itype & 0x1FF
    } else {
        values[i].type = 0
    }
    values[i].value = Double(value)
    values[i].temperature = Double(temperature)
    values[i].temperatureAdjustment = Double(temperatureAdjustment)
    values[i].temperatureTemp1 = glucoseTemperatureTempFromRaw(values[i], calibrationInfo: calibrationInfo)
    values[i].dataQuality = 0
    if values[i].temperatureTemp1 < 0.0 || values[i].temperatureTemp1 > 50.0 { values[i].dataQuality |= 0x800 }
    if values[i].temperatureTemp1 < 20.0 { values[i].dataQuality |= 0x4000 }
    if values[i].temperatureTemp1 > 40.0 { values[i].dataQuality |= 0x2000 }
    if values[i].time < 45 { values[i].dataQuality |= 0x8000 }
    if values[i].type == 0x20 { values[i].dataQuality |= 0x8000 }
    if values[i].value <= 0 { values[i].dataQuality |= 0x8000 }
}

private func readGlucoseValueTemp2(i: Int, values: inout [LibreProBLEGlucoseValue], historyDataLen: Int, calibrationInfo: [Int]) {
    let denom = calibrationInfo[3] - calibrationInfo[2]
    let g1 = denom != 0 ? 65.0 * (values[i].value - Double(calibrationInfo[2])) / Double(denom) : 0
    var temperature: Double
    if i == historyDataLen - 1 {
        var valueSum = 0.0, count = 0
        if values[i].type != 0x20 && values[i].dataQuality == 0 { valueSum += values[i].temperatureTemp1; count += 1 }
        if values[i - 1].type != 0x20 && values[i - 1].dataQuality == 0 { valueSum += values[i - 1].temperatureTemp1; count += 1 }
        temperature = count <= 0 ? values[i].temperatureTemp1 : valueSum / Double(count)
    } else {
        var valueSum = 0.0, count = 0
        if values[i + 1].type != 0x20 && values[i + 1].dataQuality == 0 { valueSum += values[i + 1].temperatureTemp1; count += 1 }
        if values[i].type != 0x20 && values[i].dataQuality == 0 { valueSum += values[i].temperatureTemp1; count += 1 }
        if i >= 1 && values[i - 1].type != 0x20 && values[i - 1].dataQuality == 0 { valueSum += values[i - 1].temperatureTemp1; count += 1 }
        temperature = count <= 0 ? values[i].temperatureTemp1 : valueSum / Double(count)
    }
    let g2 = pow(1.045, 32.5 - temperature)
    let g3 = g1 * g2
    var index = calibrationInfo[1] % 128
    if index == 0 { index = 1 }
    let v1 = t1[index - 1], v2 = t2[index - 1]
    values[i].calibratinoInfoValue = (g3 - v1) / v2
}

private func readGlucoseValueTemp3Ex(i: Int, values: inout [LibreProBLEGlucoseValue]) {
    var idSum = 0.0, idPowSum = 0.0, valueSum = 0.0, idMultiplyValueSum = 0.0, count = 0
    if values[i].type != 0x20 && values[i].dataQuality == 0 && values[i].calibratinoInfoValue != -1 {
        idSum += Double(values[i].time); count += 1
        idPowSum += Double(values[i].time * values[i].time)
        valueSum += values[i].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i].time) * values[i].calibratinoInfoValue
    }
    if i >= 1 && values[i - 1].type != 0x20 && values[i - 1].dataQuality == 0 && values[i - 1].calibratinoInfoValue != -1 {
        idSum += Double(values[i - 1].time); count += 1
        idPowSum += Double(values[i - 1].time * values[i - 1].time)
        valueSum += values[i - 1].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i - 1].time) * values[i - 1].calibratinoInfoValue
    }
    if i >= 2 && values[i - 2].type != 0x20 && values[i - 2].dataQuality == 0 && values[i - 2].calibratinoInfoValue != -1 {
        idSum += Double(values[i - 2].time); count += 1
        idPowSum += Double(values[i - 2].time * values[i - 2].time)
        valueSum += values[i - 2].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i - 2].time) * values[i - 2].calibratinoInfoValue
    }
    values[i].countMath3 = count
    let dm1 = idPowSum * Double(count) - idSum * idSum
    let dm2 = idMultiplyValueSum * Double(count) - valueSum * idSum
    var ddiv1 = 0.0
    if abs(dm1) > 0.000001 { ddiv1 = dm2 / dm1 }
    values[i].t3ddiv1 = ddiv1
    values[i].value3 = getTemperatureTempValue(i: i, count: count, idSum: idSum, idPowSum: idPowSum, valueSum: valueSum, idMultiplyValueSum: idMultiplyValueSum, values: &values)
}

private func readGlucoseValueTemp4Ex(i: Int, values: inout [LibreProBLEGlucoseValue], historyDataLen: Int) {
    var idSum = 0.0, idPowSum = 0.0, valueSum = 0.0, idMultiplyValueSum = 0.0, count = 0
    if i < historyDataLen - 1 && values[i + 1].type != 0x20 && values[i + 1].dataQuality == 0 && values[i + 1].calibratinoInfoValue != -1 {
        idSum += Double(values[i + 1].time); count += 1
        idPowSum += Double(values[i + 1].time * values[i + 1].time)
        valueSum += values[i + 1].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i + 1].time) * values[i + 1].calibratinoInfoValue
    }
    if values[i].type != 0x20 && values[i].dataQuality == 0 && values[i].calibratinoInfoValue != -1 {
        idSum += Double(values[i].time); count += 1
        idPowSum += Double(values[i].time * values[i].time)
        valueSum += values[i].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i].time) * values[i].calibratinoInfoValue
    }
    if i >= 1 && values[i - 1].type != 0x20 && values[i - 1].dataQuality == 0 && values[i - 1].calibratinoInfoValue != -1 {
        idSum += Double(values[i - 1].time); count += 1
        idPowSum += Double(values[i - 1].time * values[i - 1].time)
        valueSum += values[i - 1].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i - 1].time) * values[i - 1].calibratinoInfoValue
    }
    values[i].countMath4 = count
    values[i].value4 = getTemperatureTempValue(i: i, count: count, idSum: idSum, idPowSum: idPowSum, valueSum: valueSum, idMultiplyValueSum: idMultiplyValueSum, values: &values)
}

private func readGlucoseValueTemp5Ex(i: Int, values: inout [LibreProBLEGlucoseValue], historyDataLen: Int) {
    var idSum = 0.0, idPowSum = 0.0, valueSum = 0.0, idMultiplyValueSum = 0.0, count = 0
    if i < historyDataLen - 2 && values[i + 2].type != 0x20 && values[i + 2].dataQuality == 0 && values[i + 2].calibratinoInfoValue != -1 {
        idSum += Double(values[i + 2].time); count += 1
        idPowSum += Double(values[i + 2].time * values[i + 2].time)
        valueSum += values[i + 2].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i + 2].time) * values[i + 2].calibratinoInfoValue
    }
    if i < historyDataLen - 1 && values[i + 1].type != 0x20 && values[i + 1].dataQuality == 0 && values[i + 1].calibratinoInfoValue != -1 {
        idSum += Double(values[i + 1].time); count += 1
        idPowSum += Double(values[i + 1].time * values[i + 1].time)
        valueSum += values[i + 1].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i + 1].time) * values[i + 1].calibratinoInfoValue
    }
    if values[i].type != 0x20 && values[i].dataQuality == 0 && values[i].calibratinoInfoValue != -1 {
        idSum += Double(values[i].time); count += 1
        idPowSum += Double(values[i].time * values[i].time)
        valueSum += values[i].calibratinoInfoValue
        idMultiplyValueSum += Double(values[i].time) * values[i].calibratinoInfoValue
    }
    values[i].countMath5 = count
    let dm1 = idPowSum * Double(count) - idSum * idSum
    let dm2 = idMultiplyValueSum * Double(count) - valueSum * idSum
    var ddiv1 = 0.0
    if abs(dm1) > 0.000001 { ddiv1 = dm2 / dm1 }
    values[i].t5ddiv1 = ddiv1
    values[i].value5 = getTemperatureTempValue(i: i, count: count, idSum: idSum, idPowSum: idPowSum, valueSum: valueSum, idMultiplyValueSum: idMultiplyValueSum, values: &values)
    if count == 1 { values[i].dataQuality = values[i].dataQuality | values[i].type }
}

private func readGlucoseValueTemp6Ex(i: Int, values: inout [LibreProBLEGlucoseValue], historyDataLen: Int) {
    if i == historyDataLen - 1 {
        if values[i].calibratinoInfoValue == -1 || values[i].value3 == 0.0 {
            values[i].value6 = values[i].value3
        } else {
            values[i].value6 = (values[i].value3 + values[i].calibratinoInfoValue * 3) / 4
        }
    } else {
        var weight3 = 1.0, weight4 = 4.0, weight5 = 1.0, weight3_5 = 4.0
        if values[i].countMath3 < 3 { weight3 = 0.5; if values[i].countMath3 < 2 { weight3 = 0.0 } }
        if values[i].countMath5 < 3 { weight5 = 0.5; if values[i].countMath5 < 2 { weight5 = 0.0 } }
        if values[i].countMath4 < 3 { weight4 = 3.0; if values[i].countMath4 < 2 { weight4 = 0.0 } }
        if values[i].countMath3 < 2 || values[i].countMath5 < 2 { weight3_5 = 0.0 }
        let value3 = values[i].value3 * weight3
        let value5 = values[i].value5 * weight5
        let value4 = values[i].value4 * weight4
        let value3_5 = (values[i].value5 + values[i].value3) * 0.5 * weight3_5
        let valueSum = value3 + value4 + value5 + value3_5
        let weightSum = weight3 + weight5 + weight4 + weight3_5
        values[i].value6 = valueSum / weightSum
    }
}

private func getIdOffset(i: Int, historyDataLen: Int) -> Double {
    if i == historyDataLen - 1 { return 94.00 + 75 }
    if i == historyDataLen - 2 { return 94.00 + 94 + 75 }
    if i == 1 { return 94.00 + 92 + 75 }
    if i == 0 { return 92.00 + 75 }
    return 94.00 * 2 + 92 + 75
}

private func getiStep1A(i: Int, values: [LibreProBLEGlucoseValue], historyDataLen: Int) -> Double {
    var d1 = 0.0
    if i < historyDataLen - 1 { d1 = values[i + 1].value6 - values[i].value6 }
    let d2 = d1 * 14.33
    var d3 = 0.0
    if i >= 1 { d3 = values[i - 1].value6 - values[i].value6 }
    let d4 = d3 * 0.53
    let d5 = d4 / 15.0
    let d6 = d2 / -15
    return d5 + d6
}

private func getiStep2A(i: Int, values: [LibreProBLEGlucoseValue]) -> Double {
    var d1 = 0.0
    if i >= 2 { d1 = values[i - 2].value6 - values[i].value6 }
    let d2 = d1 * -1.210
    let d6 = d2 / 30.0
    var d3 = 0.0
    if i >= 1 { d3 = values[i - 1].value6 - values[i].value6 }
    let d4 = d3 * 15.890
    let d5 = d4 / 15.0
    return d5 + d6
}

private func getiStep3(i: Int, iStep3X: Double, values: [LibreProBLEGlucoseValue]) -> Double {
    let v6 = values[i].value6
    if v6 > 95.00 {
        if v6 > 160 {
            if v6 > 500 { return 0.0 }
            return ((v6 - 160.00) / -340.00 + 1) * iStep3X
        }
        return iStep3X
    }
    return ((v6 - 55.00) / 40.00) * iStep3X
}

private func getiStep4A(i: Int, values: [LibreProBLEGlucoseValue], historyDataLen: Int) -> Double {
    var d1 = 0.0
    if i < historyDataLen - 1 { d1 = values[i + 1].value6 - values[i].value6 }
    let d2 = d1 * 14.77
    let d6 = d2 / -15
    var d18 = 0.0
    if i < historyDataLen - 2 { d18 = values[i + 2].value6 - values[i].value6 }
    let d19 = d18 * -3.24
    let d20 = d19 / -30.0
    return d20 + d6
}

private func readGlucoseValueTemp7Ex(i: Int, values: inout [LibreProBLEGlucoseValue], historyDataLen: Int) {
    let dUse1 = values[i].value6
    var dUse2 = 0.0, dUse4 = 0.0, dUse5 = 0.0
    var dDiv = getIdOffset(i: i, historyDataLen: historyDataLen)
    var res = 0.0
    if values[i].value6 < 55 {
        res = values[i].value6
    } else {
        var iStep3X = 40.0
        let iStep1 = getiStep1A(i: i, values: values, historyDataLen: historyDataLen)
        if iStep1 < 0.0 { iStep3X = -20.00 }
        let iStep3 = getiStep3(i: i, iStep3X: iStep3X, values: values)
        if iStep1 < 0.0 {
            dUse2 = iStep3 > iStep1 ? values[i].value6 + iStep3 : values[i].value6 + iStep1
        } else {
            dUse2 = iStep3 < iStep1 ? values[i].value6 + iStep3 : values[i].value6 + iStep1
        }
        if i >= historyDataLen - 1 || i == 0 {
            dUse2 = 0.0
        } else if values[i + 1].dataQuality != 0 || values[i - 1].dataQuality != 0 {
            dUse2 = 0.0
            dDiv = dDiv - 94
        }
        values[i].value6x1 = dUse2

        let iStep2 = getiStep2A(i: i, values: values)
        iStep3X = 40.0
        if iStep2 < 0.0 { iStep3X = -20.00 }
        let iStep3b = getiStep3(i: i, iStep3X: iStep3X, values: values)
        if iStep2 < 0.0 {
            dUse4 = iStep3b > iStep2 ? values[i].value6 + iStep3b : values[i].value6 + iStep2
        } else {
            dUse4 = iStep3b < iStep2 ? values[i].value6 + iStep3b : values[i].value6 + iStep2
        }
        if i <= 1 {
            dUse4 = 0.0
        } else if values[i - 2].dataQuality != 0 || values[i - 1].dataQuality != 0 {
            dUse4 = 0.0
            dDiv = dDiv - 94
        }

        let iStep4 = getiStep4A(i: i, values: values, historyDataLen: historyDataLen)
        iStep3X = 40.0
        if iStep4 < 0.0 { iStep3X = -20.00 }
        let iStep3c = getiStep3(i: i, iStep3X: iStep3X, values: values)
        if iStep4 < 0.0 {
            dUse5 = iStep3c > iStep4 ? values[i].value6 + iStep3c : values[i].value6 + iStep4
        } else {
            dUse5 = iStep3c < iStep4 ? values[i].value6 + iStep3c : values[i].value6 + iStep4
        }
        if i >= historyDataLen - 2 { dUse5 = 0.0 }
        res = (dUse1 * 75.00 + dUse2 * 94.00 + dUse4 * 94 + dUse5 * 92) / dDiv
    }
    values[i].value7 = res
}

private func timeOffset(i: Int, values: inout [LibreProBLEGlucoseValue], historyDataLen: Int, bOffset: Bool) {
    let lastTime = values[historyDataLen - 1].time
    let lastTimeMinus60 = lastTime - 0x3C
    if lastTimeMinus60 > 0xB04 || lastTimeMinus60 < 0 {
        if values[i].time < 0x3840 {
            values[i].timeOffset = 0.0
        } else if values[i].time > 0x6AE0 {
            values[i].timeOffset = 12.00
        } else {
            let iUseTime = values[i].time - 0x3840
            values[i].timeOffset = Double(iUseTime) * 12.00 / 12960.0
        }
    } else {
        let dC1 = 1.00222222, dC2 = 1.00416667
        let d1 = 0.0 - Double(values[i].time)
        let d2 = pow(dC1, d1)
        let d3 = pow(dC2, d1)
        var res = (d2 - d3) * 80.00
        if values[i].calibratinoInfoValue < 120 && values[i].time < 1440 && bOffset {
            let resTemp = 0.3 * (Double(values[i].time) / -1440.0 + 1.0) * (120.0 - values[i].calibratinoInfoValue)
            res = res + resTemp
        }
        values[i].timeOffset = res
    }
}

// MARK: - 对外 API（枚举保证跨文件可见）

enum LibreProAlgorithm {

    /// 返回 (sensorTime, historyArray)，historyArray 仅包含有效索引；每项 time, oopValue, raw, dataQuality
    static func readHistoricalValues(current: [UInt8], data: [UInt8], bstart: Int, start: Int, end: Int) -> (sensorTime: Int, values: [(time: Int, oopValue: Int, raw: Int, dataQuality: Int)]) {
    let sensorTime = (Int(current[74]) & 0xFF) + (Int(current[75]) & 0xFF) << 8
    let calibrationInfo = readCalibrationInfo(current)
    var arr = [LibreProBLEGlucoseValue](repeating: LibreProBLEGlucoseValue(), count: end)
    var historyIndex = 0
    for i in 0..<end {
        let address = i * 6 + bstart
        let time = (start + i + 1) * 15
        if time > sensorTime { break }
        historyIndex += 1
        arr[i].time = time
        guard address + 6 <= data.count else { break }
        let slice = Array(data[address..<(address + 6)])
        readGlucoseValueTemp1(slice, offset: 0, i: i, values: &arr, calibrationInfo: calibrationInfo)
    }
    let historyDataLen = historyIndex
    for index in 0..<historyDataLen {
        readGlucoseValueTemp2(i: index, values: &arr, historyDataLen: historyDataLen, calibrationInfo: calibrationInfo)
    }
    for index in 0..<historyDataLen {
        readGlucoseValueTemp3Ex(i: index, values: &arr)
    }
    for index in 0..<historyDataLen {
        readGlucoseValueTemp4Ex(i: index, values: &arr, historyDataLen: historyDataLen)
    }
    for index in 0..<historyDataLen {
        readGlucoseValueTemp5Ex(i: index, values: &arr, historyDataLen: historyDataLen)
    }
    for index in 0..<historyDataLen {
        readGlucoseValueTemp6Ex(i: index, values: &arr, historyDataLen: historyDataLen)
    }
    for index in 0..<historyDataLen {
        readGlucoseValueTemp7Ex(i: index, values: &arr, historyDataLen: historyDataLen)
    }
    for index in 0..<historyDataLen {
        timeOffset(i: index, values: &arr, historyDataLen: historyDataLen, bOffset: true)
    }
    var result: [(time: Int, oopValue: Int, raw: Int, dataQuality: Int)] = []
    var validCount = 0
    for index in 0..<historyDataLen {
        // 防止 NaN/Inf 导致崩溃
        let value7 = arr[index].value7
        if !value7.isFinite { continue }
        var v1 = Int(round(value7))
        if v1 < 40 { v1 = 39 }
        arr[index].oopValue = Double(v1)
        let time = arr[index].time
        if time < 60 { continue }
        if time >= 20160 { break }
        if time == 20145 { continue }
        if time >= sensorTime - 20 { break }
        
        // 防止 oopValue 和 value 也是 NaN/Inf
        guard arr[index].oopValue.isFinite && arr[index].value.isFinite else { continue }
        var oop = Int(round(arr[index].oopValue))
        let raw = Int(round(arr[index].value))
        let dataQuality = arr[index].dataQuality
        if dataQuality == 0 {
            if oop < 39 { oop = 39 }
            if oop > 501 { oop = 501 }
        } else {
            oop = 0
        }
        result.append((time: time, oopValue: oop, raw: raw, dataQuality: dataQuality == 0 ? 0 : 1))
        validCount += 1
    }
    print("[LibreProAlgorithm] readHistoricalValues 完成，有效历史值: \(validCount)/\(historyDataLen)")
    return (sensorTime, result)
    }

    /// 返回 (glucoseValue, raw, dataQuality, trendArrow)；glucoseValue 已 clamp 39~501
    static func readProGlucoseValue(_ data: [UInt8]) -> (value: Int, raw: Int, dataQuality: Int, trendArrow: Int)? {
    guard data.count >= 0xAA else { return nil }
    let sensorTime = (Int(data[74]) & 0xFF) + (Int(data[75]) & 0xFF) << 8
    let trend = (Int(data[76]) & 0xFF) + (Int(data[77]) & 0xFF) << 8
    let calibrationInfo = readCalibrationInfo(data)
    var glucoseTrendArray = [LibreProBLEGlucoseValue](repeating: LibreProBLEGlucoseValue(), count: 16)
    let indexCurr = trend
    var iCurr = indexCurr * 2 + indexCurr
    iCurr = 0x50 + iCurr * 2
    let iStepRead = (0xAA - iCurr) / 6
    let len = 16
    for index in 0..<len {
        var address = iCurr + index * 6
        if address > 0xA4 { address = 0x50 + (index - iStepRead) * 6 }
        let time = ((sensorTime - indexCurr) / 16) * 16 + indexCurr - 15 + index
        glucoseTrendArray[index].time = time
        guard address + 6 <= data.count else { continue }
        let slice = Array(data[address..<(address + 6)])
        readGlucoseValueTemp1(slice, offset: 0, i: index, values: &glucoseTrendArray, calibrationInfo: calibrationInfo)
    }
    for index in 0..<len {
        readGlucoseValueTemp2(i: index, values: &glucoseTrendArray, historyDataLen: len, calibrationInfo: calibrationInfo)
    }
    for index in 0..<len {
        readGlucoseValueTemp2(i: index, values: &glucoseTrendArray, historyDataLen: len, calibrationInfo: calibrationInfo)
    }
    for index in 0..<len {
        readGlucoseValueTemp3Ex(i: index, values: &glucoseTrendArray)
    }
    for index in 0..<len {
        readGlucoseValueTemp4Ex(i: index, values: &glucoseTrendArray, historyDataLen: len)
    }
    for index in 0..<len {
        readGlucoseValueTemp5Ex(i: index, values: &glucoseTrendArray, historyDataLen: len)
    }
    for index in 0..<len {
        readGlucoseValueTemp6Ex(i: index, values: &glucoseTrendArray, historyDataLen: len)
    }
    for index in 0..<len {
        readGlucoseValueTemp7Ex(i: index, values: &glucoseTrendArray, historyDataLen: len)
    }

    // 检查是否可以计算 trendArrow（与 Android librepro.cpp 一致）
    var bTrendArrow = true
    var dAdd1 = 0.0, dAdd2 = 0.0, dAdd3 = 0.0
    
    if glucoseTrendArray[0].calibratinoInfoValue == 0 || glucoseTrendArray[9].calibratinoInfoValue == 0 {
        dAdd1 = 0
        bTrendArrow = false
    } else {
        let dUse1 = (glucoseTrendArray[9].calibratinoInfoValue - glucoseTrendArray[15].calibratinoInfoValue) * 1.02
        let dUse2 = (glucoseTrendArray[0].calibratinoInfoValue - glucoseTrendArray[15].calibratinoInfoValue) * 0.217
        dAdd1 = dUse1 / -6.00 + dUse2 / -15.00
    }
    
    if glucoseTrendArray[13].calibratinoInfoValue == 0 || glucoseTrendArray[8].calibratinoInfoValue == 0 {
        dAdd2 = 0
        bTrendArrow = false
    } else {
        let dUse1 = (glucoseTrendArray[13].calibratinoInfoValue - glucoseTrendArray[15].calibratinoInfoValue) * 0.169
        let dUse2 = (glucoseTrendArray[8].calibratinoInfoValue - glucoseTrendArray[15].calibratinoInfoValue) * 1.054
        dAdd2 = dUse1 / -2.00 + dUse2 / -7.00
    }
    
    if glucoseTrendArray[11].calibratinoInfoValue == 0 || glucoseTrendArray[3].calibratinoInfoValue == 0 {
        dAdd3 = 0
        bTrendArrow = false
    } else {
        let dUse1 = (glucoseTrendArray[11].calibratinoInfoValue - glucoseTrendArray[15].calibratinoInfoValue) * 0.585
        let dUse2 = (glucoseTrendArray[3].calibratinoInfoValue - glucoseTrendArray[15].calibratinoInfoValue) * 0.634
        dAdd3 = dUse1 / -4.00 + dUse2 / -12.00
    }
    
    var dSumAdd = 0.0, dDivAdd = 0.0
    if dAdd1 != 0.0 { dSumAdd += dAdd1 * 91.00; dDivAdd += 91.00 }
    if dAdd2 != 0.0 { dSumAdd += dAdd2 * 90.0; dDivAdd += 90.0 }
    if dAdd3 != 0.0 { dSumAdd += dAdd3 * 91.00; dDivAdd += 91.00 }
    let dCurr1 = dDivAdd > 0 ? dSumAdd / dDivAdd : 0
    
    var trendArrow = 0
    
    // 如果无法计算有效的 trendArrow，直接返回 0
    if !bTrendArrow {
        trendArrow = 0
    } else {
        // 计算 trendArrow（仅当 bTrendArrow = true 时）
        if dCurr1 < 2.0 {
            if dCurr1 < 1.0 {
                if dCurr1 > -2.0 { trendArrow = dCurr1 > -1.0 ? 3 : 2 }
                else { trendArrow = 1 }
            } else { trendArrow = 4 }
        } else { trendArrow = 5 }
    }

    let trendIndex = min(max(0, trend), 15)
    // 防止 NaN/Inf
    let value7 = glucoseTrendArray[trendIndex].value7
    guard value7.isFinite else {
        print("[LibreProAlgorithm] trend value7 非有限值: \(value7), 返回 nil")
        return nil
    }
    var intValue = Int(round(value7))
    if intValue - 40 > 460 { trendArrow = 0 }
    if intValue < 39 { intValue = 39 }
    if intValue > 501 { intValue = 501 }
    
    let rawValue = glucoseTrendArray[trendIndex].value
    guard rawValue.isFinite else {
        print("[LibreProAlgorithm] trend raw value 非有限值: \(rawValue), 返回 nil")
        return nil
    }
    let raw = Int(round(rawValue))
    let dataQuality = glucoseTrendArray[trendIndex].dataQuality
    print("[LibreProAlgorithm] readProGlucoseValue 完成，当前血糖: \(intValue) mg/dL, 趋势箭头: \(trendArrow), raw: \(raw)")
    return (intValue, raw, dataQuality, trendArrow)
    }
}
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

// 运行测试
print("\n" + String(repeating: "=", count: 70))
print("修复 bTrendArrow 后重新测试")
print(String(repeating: "=", count: 70))
LibreProAlgorithmTests.runAllTests()
