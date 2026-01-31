import Foundation
import CoreBluetooth
import os

import LibOutshine

class CGMBubbleTransmitter:BluetoothTransmitter, CGMTransmitter {
    var appId:UInt8=0xA0;  // 默认 0xA0，Pro 模式使用 0x03（参考 Android）

    var lastDataTime:Double=0;
    
    var logsBubbleAccessor: LogsBubbleAccessor?
    
    private var lastGlucoseDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "CGMBubbleTransmitterLastGlucoseDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CGMBubbleTransmitterLastGlucoseDate")
        }
    }

    /// service to be discovered
    let CBUUID_Service_Bubble: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    /// receive characteristic
    let CBUUID_ReceiveCharacteristic_Bubble: String = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    /// write characteristic
    let CBUUID_WriteCharacteristic_Bubble: String = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    
    /// expected device name
    let expectedDeviceNameBubble:String = "Bubble"
    
    /// CGMBubbleTransmitterDelegate
    public weak var cGMBubbleTransmitterDelegate: CGMBubbleTransmitterDelegate?

    /// will be used to pass back bluetooth and cgm related events
    private(set) weak var cgmTransmitterDelegate: CGMTransmitterDelegate?
    
    /// for trace
    private let log = OSLog(subsystem: ConstantsLog.subSystem, category: ConstantsLog.categoryCGMBubble)
    
    /// used when processing Bubble data packet
    private var startDate:Date
    // receive buffer for bubble packets
    private var rxBuffer:Data
    // how long to wait for next packet before sending startreadingcommand
    private static let maxWaitForpacketInSeconds = 60.0
    // length of header added by Bubble in front of data dat is received from Libre sensor
    private let bubbleHeaderLength = 8
   
    /// is the transmitter oop web enabled or not
    private var webOOPEnabled: Bool

    /// is nonFixed enabled for the transmitter or not
    private var nonFixedSlopeEnabled: Bool
    
    /// used as parameter in call to cgmTransmitterDelegate.cgmTransmitterInfoReceived, when there's no glucosedata to send
    var emptyArray: [GlucoseData] = []
    
    /// current sensor serial number, if nil then it's not known yet
    private var sensorSerialNumber:String?
    
    /// - sensor serial number stored in type LibreSensorSerialNumber
    /// - this is for temporary storage, when receiving .serialNumber from transmitter
    private var libreSensorSerialNumber:LibreSensorSerialNumber?
    
    /// gives information about type of sensor (Libre1, Libre2, etc..)
    private var patchInfo: String?
    
    /// bubble firmware version
    private var firmware: String?
    
    /// instance of libreDataParser
    private let libreDataParser: LibreDataParser
    
    /// sensor type
    private var libreSensorType: LibreSensorType?
    
    fileprivate var cacheBattery: UInt8 = 0x00

    // MARK: - Libre Pro 状态（与 Android BubbleLibrePro 一致）
    /// 仅当本轮已发送 getProTrend 时为 true；否则 0x82 按 344 字节流处理，避免 0xC1 晚于 0x80 时错用 Pro 分支
    private var expectedProStream = false
    private static let proTrendBytes = 176
    private static let proHistoryBlockBytes = 25 * 8  // 200
    private var proTrendAccumulated = Data()
    private var proHistoryAccumulated = Data()
    private var isProHistory = false
    private var proTrendDataHex: String?
    private var proHistroyStart = 0
    private var proHistoryCount = 0
    
    private func resetProState() {
        proTrendAccumulated = Data()
        proHistoryAccumulated = Data()
        isProHistory = false
        proTrendDataHex = nil
        proHistroyStart = 0
        proHistoryCount = 0
    }
    
    /// 与 Android BubbleLibrePro.getProHistroyEnd(start) 一致：发送读 Pro history 命令
    private func getProHistoryEndCommand(start: Int) -> Data {
        // Pro 模式，参考 Android: 020003ED0019
        // 格式: [0x02, 0x00, start_high, start_low, 0x00, count]
        Data([0x02, 0x00, UInt8(start >> 8), UInt8(start & 0xFF), 0x00, 25])
    }

    /// 发送普通读 344 字节命令（非 Pro 或 Nano 固件逻辑）
    private func sendNormalReadCommand(appId: UInt8, firmware: String?, deviceName: String?) {
        expectedProStream = false
        if deviceName != "Bubble Nano" {
            _ = writeToPeripheralAndLog(data: Data([0x08, appId, 0x00, 0x00, 0x00, 0x2B]), type: .withoutResponse)
        } else {
            if (firmware?.toDouble() ?? 0) >= 8.1 && libreSensorType == .libre1 {
                _ = writeToPeripheralAndLog(data: Data([0x0C, appId, 0x00, 0x00, 0x00, 0x2B]), type: .withoutResponse)
            } else if (firmware?.toDouble() ?? 0) >= 2.6 && libreSensorType != nil {
                _ = writeToPeripheralAndLog(data: Data([0x08, appId, 0x00, 0x00, 0x00, 0x2B]), type: .withoutResponse)
            } else {
                _ = writeToPeripheralAndLog(data: Data([0x02, appId, 0x00, 0x00, 0x00, 0x2B]), type: .withoutResponse)
            }
            if (firmware?.toDouble() ?? 0) >= 8.1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                    guard let self else { return }
                    _ = self.writeToPeripheralAndLog(data: Data([0x7A, self.appId, 0x04]), type: .withoutResponse)
                }
            }
        }
    }

    // MARK: - Initialization
    
    /// - parameters:
    ///     - address: if already connected before, then give here the address that was received during previous connect, if not give nil
    ///     - name : if already connected before, then give here the name that was received during previous connect, if not give nil
    ///     - delegate : CGMTransmitterDelegate intance
    ///     - webOOPEnabled : enabled or not, if nil then default false
    ///     - bluetoothTransmitterDelegate : a BluetoothTransmitterDelegate
    ///     - cGMTransmitterDelegate : a CGMTransmitterDelegate
    ///     - cGMBubbleTransmitterDelegate : a CGMBubbleTransmitterDelegate
    init(address:String?, name: String?, bluetoothTransmitterDelegate: BluetoothTransmitterDelegate, cGMBubbleTransmitterDelegate: CGMBubbleTransmitterDelegate, cGMTransmitterDelegate:CGMTransmitterDelegate, sensorSerialNumber:String?, webOOPEnabled: Bool?, nonFixedSlopeEnabled: Bool?) {
        
        // assign addressname and name or expected devicename
        var newAddressAndName:BluetoothTransmitter.DeviceAddressAndName = BluetoothTransmitter.DeviceAddressAndName.notYetConnected(expectedName: expectedDeviceNameBubble)
        if let address = address {
            newAddressAndName = BluetoothTransmitter.DeviceAddressAndName.alreadyConnectedBefore(address: address, name: name)
        }
        
        // initialize sensorSerialNumber
        self.sensorSerialNumber = sensorSerialNumber
        
        // assign CGMTransmitterDelegate
        self.cgmTransmitterDelegate = cGMTransmitterDelegate
        
        // assign CGMBubbleTransmitterDelegate
        self.cGMBubbleTransmitterDelegate = cGMBubbleTransmitterDelegate
        
        // initialize rxbuffer
        rxBuffer = Data()
        startDate = Date()
        
        // initialize nonFixedSlopeEnabled
        self.nonFixedSlopeEnabled = nonFixedSlopeEnabled ?? false
        
        // initialize webOOPEnabled
        self.webOOPEnabled = webOOPEnabled ?? false
        
        // initiliaze LibreDataParser
        self.libreDataParser = LibreDataParser()

        super.init(addressAndName: newAddressAndName, CBUUID_Advertisement: nil, servicesCBUUIDs: [CBUUID(string: CBUUID_Service_Bubble)], CBUUID_ReceiveCharacteristic: CBUUID_ReceiveCharacteristic_Bubble, CBUUID_WriteCharacteristic: CBUUID_WriteCharacteristic_Bubble, bluetoothTransmitterDelegate: bluetoothTransmitterDelegate)
        
        package.writeFunc = { [weak self] data in self?.write(data: data) }
        package.libreDataCallback = { [weak self] result in
            guard let self else { return }
            print("[Bubble BLE] libreDataCallback 收到 result 长度=\(result.count)")
            // logsBubbleAccessor 可能涉及 Core Data，在主线程执行
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.cacheBattery > 0 {
                    self.logsBubbleAccessor?.updateBattery100(Int(self.cacheBattery))
                }
                self.logsBubbleAccessor?.updateCount()
            }

            if var crcData = result.hexadecimal(), let patchUid = patchUid, let patchInfo = patchInfo {
                print("[Bubble BLE] libreDataCallback 解析 hex 成功 crcData.count=\(crcData.count) patchUid=\(patchUid) patchInfo=\(patchInfo)")
                guard BubbleCrc.LibreCrc(data: &crcData, headerOffset: 0, libreSensorType: nil) else {
                    trace("    crc check failed, no further processing", log: log, category: ConstantsLog.categoryBlucon, type: .error)
                    print("[Bubble BLE] libreDataCallback CRC 校验失败，不再处理")
                    // transmitter can go to sleep
                    return
                }
                print("[Bubble BLE] libreDataCallback CRC 通过，进入主线程处理")

                DispatchQueue.main.async {
                    let sensorTime = Int(crcData[317]) << 8 + Int(crcData[316])
                    let sensorMaxTime = Int(crcData[327]) << 8 + Int(crcData[326])
                    print("[Bubble BLE] libreDataCallback sensorTime=\(sensorTime) sensorMaxTime=\(sensorMaxTime) maxAgeInDays=\(Double(sensorMaxTime) / 60.0 / 24.0)")
                
                    self.maxAgeInDays = Double(sensorMaxTime) / 60.0 / 24.0
                    UserDefaults.standard.activeSensorMaxSensorAgeInDays = self.maxAgeInDays
                                            
                    var state = LibreSensorState(stateByte: crcData[4])
                    if state == .ready && sensorTime < 60 {
                        state = .starting
                    }
                    print("[Bubble BLE] libreDataCallback sensorState=\(state) stateByte=\(crcData[4])")
                    
                    if let libreSensorSerialNumber = self.libreSensorSerialNumber {
                        
                        self.cGMBubbleTransmitterDelegate?.received(serialNumber: libreSensorSerialNumber.serialNumber, from: self)

                        // verify serial number and if changed inform delegate
                        if libreSensorSerialNumber.serialNumber != self.sensorSerialNumber {

                            // store self.sensorSerialNumber
                            self.sensorSerialNumber = libreSensorSerialNumber.serialNumber
                            
                            trace("    new sensor detected :  %{public}@", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .info, libreSensorSerialNumber.serialNumber)
                            
                            // inform cgmTransmitterDelegate about new sensor detected
                            // assign sensorStartDate, for this type of transmitter the sensorAge is passed in another call to cgmTransmitterDelegate
                            self.cgmTransmitterDelegate?.newSensorDetected(sensorStartDate: Date(timeInterval: -Double(sensorTime * 60), since: Date()))

                            // inform cGMBubbleTransmitterDelegate about new sensor detected
                            self.cGMBubbleTransmitterDelegate?.received(serialNumber: libreSensorSerialNumber.serialNumber, from: self)
                        }
                    }

                    self.lastDataTime=Date().timeIntervalSince1970
                    print("[Bubble BLE] libreDataCallback 调用 libreDataProcessor serialNumber=\(self.libreSensorSerialNumber?.serialNumber ?? "nil")")
                    self.libreDataParser.libreDataProcessor(libreSensorSerialNumber: self.libreSensorSerialNumber?.serialNumber, patchInfo: patchInfo, webOOPEnabled: self.webOOPEnabled, libreData: crcData, cgmTransmitterDelegate: self.cgmTransmitterDelegate, dataIsDecryptedToLibre1Format: true, testTimeStamp: nil) { (sensorState: LibreSensorState?, xDripError: XdripError?) in
                        print("[Bubble BLE] libreDataCallback libreDataProcessor 完成 sensorState=\(String(describing: sensorState)) xDripError=\(String(describing: xDripError))")
                        let state = sensorState
                        let bubbleDelegate = self.cGMBubbleTransmitterDelegate
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            self.lastGlucoseDate = Date()
                            self.resetRxBuffer()
                            if let sensorState = state {
                                bubbleDelegate?.received(sensorStatus: sensorState, from: self)
                            }
                            if self.readTimeInterval != 0x05 {
                                _ = self.sendStartReadingCommmand()
                            }
                        }
                    }
                }
            } else {
                print("[Bubble BLE] libreDataCallback 跳过: result.hexadecimal() 失败或 patchUid/patchInfo 为 nil, patchUid=\(self.patchUid ?? "nil") patchInfo=\(self.patchInfo ?? "nil")")
            }

        }
    }
    
    func getDeviceName() -> String? {
        return deviceName
    }
    
    func getSensorName() -> String? {
        return libreSensorType?.description
    }
    
    func nextReadTimeinterval() -> UInt8 {
        
        guard let last = lastGlucoseDate else {
            return 0x05
        }
        
        let interval = Date().timeIntervalSince(last) / 60.0
        
        if interval > 5.0 || interval < 1.0 {
            return 0x05
        }

        return UInt8(interval)
    }

    // MARK: - public functions
    private var readTimeInterval: UInt8 = 0x05
    func sendStartReadingCommmand() -> Bool {
        readTimeInterval = nextReadTimeinterval()
        
        // Pro 模式检查：如果上次是 Pro，使用 appId=0x03（整个会话一致，参考 Android）
        if libreSensorType == nil, let savedPatchInfo = UserDefaults.standard.string(forKey: "CGMBubbleTransmitterLastPatchInfo") {
            let savedType = LibreSensorType.type(patchInfo: savedPatchInfo)
            if savedType == .libreProH {
                appId = 0x03  // Android 使用 0x03，不是 0x00！
                libreSensorType = .libreProH
                readTimeInterval = 0x05
                print("[Bubble BLE] 初始化前恢复 Pro 模式, appId=0x03, readTimeInterval=0x05")
            }
        }

        logsBubbleAccessor?.updateCountSendInit()
        if writeToPeripheralAndLog(data: Data([0x00, appId, readTimeInterval]), type: .withoutResponse) {
            return true
        } else {
            trace("in sendStartReadingCommand, write failed", log: log, category: ConstantsLog.categoryCGMBubble, type: .error)
            return false
        }
    }
    
    func startOTA() {
        if deviceName?.lowercased().contains("nano") == true {
            _ = writeToPeripheralAndLog(data: Data([0x7b, 0x03, 0x00]), type: .withoutResponse)
        }
    }
    
    // MARK: - overriden  BluetoothTransmitter functions
    
    override func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        super.peripheral(peripheral, didUpdateNotificationStateFor: characteristic, error: error)
        
        if error == nil && characteristic.isNotifying {
            // BLE 回调线程，sendStartReadingCommmand 内会调 logsBubbleAccessor，放到主线程
            DispatchQueue.main.async { [weak self] in
                _ = self?.sendStartReadingCommmand()
            }
        }
        
    }
   
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        
        if let value = characteristic.value {
            // 蓝牙回调：完整打印原始数据（长度 + 十六进制）
            print("[Bubble BLE] 收到数据 length=\(value.count) hex=\(value.toHexString())")
            if let first = value.first, let type = BubbleResponseType(rawValue: first) {
                print("[Bubble BLE] 类型=\(type) firstByte=0x\(String(format: "%02X", first))")
            }
            
            //check if buffer needs to be reset
            if (Date() > startDate.addingTimeInterval(CGMBubbleTransmitter.maxWaitForpacketInSeconds - 1)) {
                trace("in peripheral didUpdateValueFor, more than %{public}@ seconds since last update - or first update since app launch, resetting buffer", log: log, category: ConstantsLog.categoryCGMBubble, type: .info, CGMBubbleTransmitter.maxWaitForpacketInSeconds.description)
                resetRxBuffer()
            }
            
            if let firstByte = value.first {
                if let bubbleResponseState = BubbleResponseType(rawValue: firstByte) {
                    switch bubbleResponseState {
                        
                    case .bubbleDb:
                        print("[Bubble BLE] .bubbleDb count=\(value.count)")
                        func setBubbleDb(value: Data) {
                            guard value.count > 2 else { return }
                            let db = value[2]
                            UserDefaults.standard.bubbleDb = Int(db)
                        }

                    case .dataInfo:
                        // dataInfo 至少需要 5 字节: [2],[3] 固件, [4] 电量, [count-2],[count-1] 硬件
                        guard value.count >= 5 else {
                            print("[Bubble BLE] .dataInfo 长度不足 count=\(value.count)")
                            return
                        }
                        
                        // byte[1] 可能是状态标志（Android=0x03, iOS 有时=0x00）
                        let statusByte = value.count > 1 ? value[1] : 0
                        
                        // get hardware, firmware and batteryPercentage
                        let hardware = value[value.count-2].description + "." + value[value.count-1].description
                        let firmware = value[2].description + "." + value[3].description
                        let batteryPercentage = Int(value[4])
                        print("[Bubble BLE] .dataInfo firmware=\(firmware) hardware=\(hardware) battery=\(batteryPercentage)% statusByte=0x\(String(format: "%02X", statusByte))")
                        
                        // delegate 可能涉及 UI/Core Data，统一在主线程回调避免 EXC_BREAKPOINT
                        let delegate = cGMBubbleTransmitterDelegate
                        let cgmDelegate = cgmTransmitterDelegate
                        let battery = batteryPercentage
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            delegate?.received(firmware: firmware, from: self)
                            delegate?.received(hardware: hardware, from: self)
                            delegate?.received(batteryLevel: battery, from: self)
                            var empty = self.emptyArray
                            cgmDelegate?.cgmTransmitterInfoReceived(glucoseData: &empty, transmitterBatteryInfo: TransmitterBatteryInfo.percentage(percentage: battery), sensorAge: nil)
                            if battery > 0 {
                                self.logsBubbleAccessor?.updateBattery(battery)
                                self.logsBubbleAccessor?.updateBattery100(battery)
                            }
                        }
                        
                        // store received firmware local
                        self.firmware = firmware

                        lastDataTime=0
                        
                        // 临时注释限流检查，测试 Pro 模式（生产环境恢复）
                        /*
                        if let last = lastGlucoseDate {
                            if Date().timeIntervalSince(last) < 4 * 60 {
                                print("[Bubble BLE] 0x80 → 距上次读取不足4分钟，跳过")
                                return
                            }
                        }
                        */

                        // 0x80 后发送读数据命令，Bubble 会自动返回 0xC0/0xC1/0x82
                        // 策略：只有当 libreSensorType 已确认为 .libreProH 时才发 Pro 命令
                        // 首次连接或类型未知时，发送普通读以获取 0xC1（patchInfo）
                        
                        // 如果 libreSensorType 未知，尝试从 UserDefaults 恢复上次的类型
                        if libreSensorType == nil, let savedPatchInfo = UserDefaults.standard.string(forKey: "CGMBubbleTransmitterLastPatchInfo") {
                            libreSensorType = LibreSensorType.type(patchInfo: savedPatchInfo)
                            // Pro 模式需要使用 appId=0x03（整个会话一致）
                            if libreSensorType == .libreProH {
                                appId = 0x03
                            }
                            print("[Bubble BLE] 0x80 从缓存恢复类型: \(libreSensorType?.description ?? "nil"), appId=0x\(String(format: "%02X", appId))")
                        }
                        
                        if libreSensorType == .libreProH {
                            expectedProStream = true
                            resetProState()
                            // Pro 模式使用 appId=0x03（参考 Android）
                            // Android 命令: 020000000016（注意 0x16 在最后）
                            let cmd = Data([0x02, 0x00, 0x00, 0x00, 0x00, 0x16])
                            _ = writeToPeripheralAndLog(data: cmd, type: .withoutResponse)
                            print("[Bubble BLE] 0x80 → 类型已确认 Pro，发送 getProTrend hex=\(cmd.hexEncodedString())")
                        } else {
                            expectedProStream = false
                            sendNormalReadCommand(appId: appId, firmware: firmware, deviceName: deviceName)
                            let reason = libreSensorType == nil ? "类型未知" : "非 Pro 类型"
                            print("[Bubble BLE] 0x80 → \(reason)，发送普通读")
                        }
                        
                        // confirm receipt
                        // if firmware >= 2.6, write [0x08, 0x01, 0x00, 0x00, 0x00, 0x2B]
                        // bubble will decrypt the libre2 data and return it
//                        if firmware.toDouble() ?? 0 >= 2.6 {
//                            _ = writeDataToPeripheral(data: Data([0x02, 0x01, 0x00, 0x00, 0x00, 0x2B]), type: .withoutResponse)
//                        } else {
//                            _ = writeDataToPeripheral(data: Data([0x02, 0x00, 0x00, 0x00, 0x00, 0x2B]), type: .withoutResponse)
//                        }
                        
                    case .serialNumber:
                        
                        guard value.count >= 10 else {
                            print("[Bubble BLE] .serialNumber 长度不足 count=\(value.count)")
                            return
                        }
                        
                        // as serialNumber is always the first packet being sent, resetRxBuffer (just in case it wasn't done yet
                        resetRxBuffer()
                        
                        // this is actually the sensor serial number, adding it to rxBuffer (we could also not add it and set bubbleHeaderLength to 0 - this is historic
                        rxBuffer.append(value.subdata(in: 2..<10))
                        
                        patchUid = value.subdata(in: 2..<10).hexEncodedString().uppercased()
                        print("[Bubble BLE] .serialNumber patchUid=\(patchUid)")
                        
                        package.patchUid = patchUid
                        
                        // 0xC0 是 Bubble 在读数据命令后自动返回的，不需要主动请求
                        // patchInfo 会紧随其后（0xC1），此处先跳过 serialNumber 计算，等 0xC1 时再计算
                        print("[Bubble BLE] 0xC0 收到，等待 0xC1 补充 patchInfo")
                        // 不再 return，继续处理后续逻辑（但 guard 会拦截）
                        
                        // get libreSensorSerialNumber, if this fails, then self.libreSensorSerialNumber will keep it's current value
                        // Bubble sends the patchInfo only in a second step, which means patchInfo is nil here, as a result, the sensorSerialNumber will maybe not be correct (eg for Libre 2), because the function LibreSensorType.type uses the patchInfo
                        // libreSensorSerialNumber will be recalculated when receiving the patchInfo
                        guard let patchInfo, let libreSensorSerialNumber = LibreSensorSerialNumber(withUID: Data(rxBuffer.subdata(in: 0..<8)), with: LibreSensorType.type(patchInfo: patchInfo)) else {
                            trace("    could not create libreSensorSerialNumber", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .info)
                            return
                        }
                        
                        // assign self.libreSensorSerialNumber to received libreSensorSerialNumber
                        self.libreSensorSerialNumber = libreSensorSerialNumber
                        
                        self.callbackStates()

                    case .dataPacket84:
                        // Android 0x84: libreData 重置，Libre Pro 发 getProTrend，否则发 getBubbleByte07
                        if libreSensorType == .libreProH {
                            expectedProStream = true
                            resetProState()
                            // Pro 模式
                            let cmd = Data([0x02, 0x00, 0x00, 0x00, 0x00, 0x16])
                            _ = writeToPeripheralAndLog(data: cmd, type: .withoutResponse)
                            print("[Bubble BLE] 0x84 → 发送 getProTrend hex=\(cmd.hexEncodedString())")
                        } else {
                            expectedProStream = false
                            _ = writeToPeripheralAndLog(data: Data([0x08, appId, 0x00, 0x00, 0x00, 0x2B]), type: .withoutResponse)
                        }

                    case .dataPacket, .dataPacket87, .decryptedDataPacket, .dataPacket2:
                        //no different processing for decryptedDataPacket, we look at the firmware version of the bubble and sensortype to determine if data is decrypted or not
                        guard value.count > 4 else {
                            print("[Bubble BLE] .dataPacket 长度不足 count=\(value.count)")
                            return
                        }
                        // Android: 0x87 且 buffer[3] 为 0x03 或 0x27 时忽略
                        if value[0] == 0x87 && (value[3] == 0x03 || value[3] == 0x27) {
                            return
                        }
                        // Libre Pro: 仅当本轮已发送 getProTrend 时才走 176+200；否则按 344 字节流（避免 0xC1 晚于 0x80 时错用 Pro 分支）
                        if expectedProStream && libreSensorType == .libreProH {
                            if isProHistory {
                                proHistoryAccumulated.append(value.suffix(from: 4))
                                if proHistoryAccumulated.count >= CGMBubbleTransmitter.proHistoryBlockBytes {
                                    let historyData = proHistoryAccumulated
                                    print("[Bubble BLE] ========== Pro History 完整数据 (200字节) ==========")
                                    print("[Bubble BLE] history hex: \(historyData.hexEncodedString())")
                                    print("[Bubble BLE] ================================================")
                                    let bstart = proHistroyStart
                                    let hcount = proHistoryCount
                                    let trendDataForParser: Data
                                    if let hex = proTrendDataHex, let data = Data(hexadecimalString: hex), data.count >= CGMBubbleTransmitter.proTrendBytes {
                                        trendDataForParser = data
                                    } else {
                                        trendDataForParser = proTrendAccumulated
                                    }
                                    resetProState()
                                    lastDataTime = Date().timeIntervalSince1970
                                    if trendDataForParser.count >= CGMBubbleTransmitter.proTrendBytes {
                                        // Libre Pro 数据格式可能不需要标准 CRC 校验（临时跳过）
                                        print("[Bubble BLE] Libre Pro trend 数据 \(trendDataForParser.count) 字节，跳过 CRC 校验")
                                        let bubbleDelegate = cGMBubbleTransmitterDelegate
                                        let cgmDelegate = cgmTransmitterDelegate
                                        // 与 Android getLibreProGlucose(trend, history, bstart, start, count) 对齐的解析
                                        libreDataParser.libreProDataProcessor(trend: trendDataForParser, history: historyData, bstart: bstart, historyCount: hcount, cgmTransmitterDelegate: cgmDelegate) { [weak self] (sensorState: LibreSensorState?, xDripError: XdripError?) in
                                            guard let self else { return }
                                            let state = sensorState
                                            DispatchQueue.main.async { [weak self] in
                                                guard let self else { return }
                                                self.lastGlucoseDate = Date()
                                                if self.cacheBattery > 0 {
                                                    self.logsBubbleAccessor?.updateBattery100(Int(self.cacheBattery))
                                                }
                                                self.logsBubbleAccessor?.updateCount()
                                                if let sensorState = state {
                                                    bubbleDelegate?.received(sensorStatus: sensorState, from: self)
                                                }
                                            }
                                        }
                                    }
                                    return
                                }
                            } else {
                                proTrendAccumulated.append(value.suffix(from: 4))
                                if proTrendAccumulated.count >= CGMBubbleTransmitter.proTrendBytes {
                                    let trend = proTrendAccumulated
                                    print("[Bubble BLE] ========== Pro Trend 完整数据 (176字节) ==========")
                                    print("[Bubble BLE] trend hex: \(trend.hexEncodedString())")
                                    print("[Bubble BLE] ===============================================")
                                    guard trend.count >= 80 else { return }
                                    let historyCount = Int(trend[78]) & 0xFF + (Int(trend[79]) & 0xFF) << 8
                                    let sensorTime = Int(trend[74]) & 0xFF + (Int(trend[75]) & 0xFF) << 8
                                    let histroyByteLen = (historyCount - 32) * 6 + CGMBubbleTransmitter.proTrendBytes
                                    proHistroyStart = histroyByteLen % 8
                                    proHistoryCount = historyCount
                                    proTrendDataHex = trend.hexEncodedString()
                                    let start: Int
                                    if historyCount <= 32 {
                                        start = 22
                                    } else {
                                        start = histroyByteLen / 8
                                    }
                                    let histCmd = getProHistoryEndCommand(start: start)
                                    _ = writeToPeripheralAndLog(data: histCmd, type: .withoutResponse)
                                    print("[Bubble BLE] 收到 176 字节 trend，发送 history 命令 hex=\(histCmd.hexEncodedString()) start=\(start) count=25")
                                    isProHistory = true
                                    proTrendAccumulated = Data()
                                }
                            }
                            return
                        }
                        
                        rxBuffer.append(value.suffix(from: 4))
                        print("[Bubble BLE] .dataPacket 追加 \(value.count - 4) 字节, rxBuffer.count=\(rxBuffer.count)")
                        
                        if rxBuffer.count >= 352 {
                            
                            print("[Bubble BLE] rxBuffer 完整(352) hex=\(rxBuffer.toHexString())")
                            var dataIsDecryptedToLibre1Format = false
                            
                            // for libre2 and libreUS we will do decryption
                            if let libreSensorType = LibreSensorType.type(patchInfo: patchInfo) {

                                self.libreSensorType = libreSensorType
                                
                                // if firmware < 2.6, libre2 and libreUS will decrypt fram local
                                // after decryptFRAM, the libre2 and libreUS 344 will be libre1 344 data format
                                // firmware >= 2.6, then bubble already decrypted the data, no need for decryption we already have the 344 bytes
                                if libreSensorType == .libre2 || libreSensorType == .libre2CA || libreSensorType == .libre2US || libreSensorType == .libreUS14day || libreSensorType == .libre2RU {
                                    
                                    if let firmware = firmware?.toDouble(), firmware < 2.6 {
                                        //TODO2
//                                        dataIsDecryptedToLibre1Format = libreSensorType.decryptIfPossibleAndNeeded(rxBuffer: &rxBuffer, headerLength: bubbleHeaderLength, log: log, patchInfo: patchInfo, uid: rxBuffer[0..<bubbleHeaderLength].bytes)
                                        let uidBytes = [UInt8](rxBuffer.subdata(in: 0..<bubbleHeaderLength))
                                        dataIsDecryptedToLibre1Format = libreSensorType.decryptIfPossibleAndNeeded(
                                            rxBuffer: &rxBuffer,
                                            headerLength: bubbleHeaderLength,
                                            log: log,
                                            patchInfo: patchInfo,
                                            uid: uidBytes
                                        )

                                    } else {
                                        
                                        trace("    firmware version >= 2.6, libre data should be decrypted already", log: log, category: ConstantsLog.categoryCGMBubble, type: .info)

                                    }
                                    
                                    dataIsDecryptedToLibre1Format = true
                                    
                                }
                                
                                // now except libreProH, all libres' 344 data is libre1 format
                                // should crc check
                                guard libreSensorType.crcIsOk(rxBuffer: &self.rxBuffer, headerLength: bubbleHeaderLength, log: log) else {
                                    return
                                }

                            }
                            
                            // did we receive a serialNumber ? delegate 涉及 UI/Core Data，在主线程回调
                            if let libreSensorSerialNumber = libreSensorSerialNumber {
                                let serial = libreSensorSerialNumber.serialNumber
                                let bubbleDelegate = cGMBubbleTransmitterDelegate
                                let cgmDelegate = cgmTransmitterDelegate
                                let currentSerial = sensorSerialNumber
                                DispatchQueue.main.async { [weak self] in
                                    guard let self else { return }
                                    bubbleDelegate?.received(serialNumber: serial, from: self)
                                    if serial != currentSerial {
                                        self.sensorSerialNumber = serial
                                        trace("    new sensor detected :  %{public}@", log: self.log, category: ConstantsLog.categoryCGMBubble, type: OSLogType.info, serial)
                                        cgmDelegate?.newSensorDetected(sensorStartDate: nil)
                                        bubbleDelegate?.received(serialNumber: serial, from: self)
                                    }
                                }
                            }

                            libreDataParser.libreDataProcessor(libreSensorSerialNumber: libreSensorSerialNumber?.serialNumber, patchInfo: patchInfo, webOOPEnabled: webOOPEnabled, libreData:  (rxBuffer.subdata(in: bubbleHeaderLength..<(344 + bubbleHeaderLength))), cgmTransmitterDelegate: cgmTransmitterDelegate, dataIsDecryptedToLibre1Format: dataIsDecryptedToLibre1Format, testTimeStamp: nil) { [weak self] (sensorState: LibreSensorState?, xDripError: XdripError?) in
                                guard let self = self else { return }
                                let state = sensorState
                                let bubbleDelegate = self.cGMBubbleTransmitterDelegate
                                DispatchQueue.main.async { [weak self] in
                                    guard let self else { return }
                                    self.lastGlucoseDate = Date()
                                    if self.cacheBattery > 0 {
                                        self.logsBubbleAccessor?.updateBattery100(Int(self.cacheBattery))
                                    }
                                    self.logsBubbleAccessor?.updateCount()
                                    if let sensorState = state {
                                        bubbleDelegate?.received(sensorStatus: sensorState, from: self)
                                    }
                                }
                            }

                            lastDataTime=Date().timeIntervalSince1970

                            //reset the buffer
                            resetRxBuffer()
                        }
                        
                    case .noSensor:
                        print("[Bubble BLE] .noSensor")
                        if Date().timeIntervalSince1970 - lastDataTime > 10000 {
                            let cgmDelegate = cgmTransmitterDelegate
                            DispatchQueue.main.async { [weak self] in
                                guard let self else { return }
                                cgmDelegate?.sensorNotDetected()
                                self.logsBubbleAccessor?.updateCountBf()
                            }
                        }

                    case .patchInfo:
                        if value.count >= 11 {
                            patchInfo = value.subdata(in: 5 ..< 11).hexEncodedString().uppercased()
                            print("[Bubble BLE] .patchInfo patchInfo222=\(patchInfo ?? "")")
                            
                            package.patchInfo = patchInfo

                            if let patchInfo = patchInfo {
                                trace("    received patchInfo %{public}@ ", log: log, category: ConstantsLog.categoryCGMBubble, type: .info, patchInfo)
                                UserDefaults.standard.set(patchInfo, forKey: "CGMBubbleTransmitterLastPatchInfo")
                            }

                            // send libreSensorType to delegate
                            if var libreSensorType = LibreSensorType.type(patchInfo: patchInfo) {

                                if let p = patchInfo?.lowercased() {
                                    if p.hasPrefix("76") || p.hasPrefix("2b") || p.hasPrefix("2c") {
                                        //TODO
                                        if !DBOutshine.isSupported(patchInfo ?? "") {
                                            print("[Bubble BLE] isSupported no")
                                            libreSensorType = .unsupported
                                            trace("    unsupported patchInfo %{public}@ ", log: log, category: ConstantsLog.categoryCGMBubble, type: .info, patchInfo ?? "")
                                        }
                                    }
                                }
                                
                                self.libreSensorType = libreSensorType
                                // Pro 模式需要使用 appId=0x03（下次连接生效）
                                if libreSensorType == .libreProH {
                                    self.appId = 0x03
                                    print("[Bubble BLE] 0xC1 设置 Pro 模式，appId → 0x03（下次连接生效）")
                                }
                                // delegate 涉及 UI/Core Data，在主线程回调
                                let bubbleDelegate = cGMBubbleTransmitterDelegate
                                let cgmDelegate = cgmTransmitterDelegate
                                let sensorType = libreSensorType
                                DispatchQueue.main.async { [weak self] in
                                    guard let self else { return }
                                    bubbleDelegate?.received(libreSensorType: sensorType, from: self)
                                    cgmDelegate?.infoUpdate()
                                }
                            }
                            
                            // we have the patchInfo now, so recalculate the sensorSerialNumber
                            guard let libreSensorSerialNumber = LibreSensorSerialNumber(withUID: Data(rxBuffer.subdata(in: 0..<8)), with: LibreSensorType.type(patchInfo: patchInfo)) else {
                                trace("    could not create libreSensorSerialNumber", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .info)
                                return
                            }
                            
                            // assign self.libreSensorSerialNumber to received libreSensorSerialNumber
                            self.libreSensorSerialNumber = libreSensorSerialNumber
                            
                            // callbackStates 内部会调 delegate，在主线程执行
                            DispatchQueue.main.async { [weak self] in
                                self?.callbackStates()
                            }
                            
                            // 0xC1 收到后，读数据命令已在 0x80 时发送，无需补发
                        }
                        
                    case .authData:
                        print("[Bubble BLE] .authData count=\(value.count) hex=\(value.toHexString())")
                        receiveAuthData(data: value)
                    case .bubbleAck7A:
                        break  // Bubble 对 0x7A 的应答，静默忽略
                    }
                } else {
                    print("[Bubble BLE] 未识别类型 firstByte=0x\(String(format: "%02X", value.first ?? 0))")
                }
            }
        } else {
            print("[Bubble BLE] characteristic.value 为 nil")
            trace("in peripheral didUpdateValueFor, value is nil, no further processing", log: log, category: ConstantsLog.categoryCGMBubble, type: .error)
        }
        
    }
    
    private func callbackStates() {
        if let libreSensorSerialNumber = self.libreSensorSerialNumber {

            // verify serial number and if changed inform delegate
            if libreSensorSerialNumber.serialNumber != self.sensorSerialNumber {

                // store self.sensorSerialNumber
                self.sensorSerialNumber = libreSensorSerialNumber.serialNumber
                                            
                
                DispatchQueue.main.async {
                    // inform cgmTransmitterDelegate about new sensor detected
                    // assign sensorStartDate, for this type of transmitter the sensorAge is passed in another call to cgmTransmitterDelegate
                    self.cgmTransmitterDelegate?.newSensorDetected(sensorStartDate: nil)

                    // inform cGMBubbleTransmitterDelegate about new sensor detected
                    self.cGMBubbleTransmitterDelegate?.received(serialNumber: libreSensorSerialNumber.serialNumber, from: self)

                }
                
            }

        }

    }
    
    private var maxAgeInDays: Double?
    
    private var caFirstNet = false
    private var caP1: String?

    private var caData1 = Data()
    private var caData2 = Data()
    private var caData344 = Data()

    private func write(data: String) {
        guard let value = data.hexadecimal(), value.count > 3 else { return }
        let sub = value[3...]
        var bytes: [UInt8] = [0x0A, appId, UInt8(sub.count)]
        bytes += sub
        _ = writeToPeripheralAndLog(data: Data(bytes), type: .withResponse)
    }
    
    private var patchUid: String?

    private let package = CADataCollector()

    private func receiveAuthData(data: Data) {
        guard data[1] == appId else { return }
        
        package.append(data: data)
    }
    
    // MARK: CGMTransmitter protocol functions
    
    func setNonFixedSlopeEnabled(enabled: Bool) {
        
        if nonFixedSlopeEnabled != enabled {
            
            nonFixedSlopeEnabled = enabled
            
        }
    }
    
    /// set webOOPEnabled value
    func setWebOOPEnabled(enabled: Bool) {
        
        if webOOPEnabled != enabled {
            
            webOOPEnabled = enabled
            
        }
        
    }
    
    func cgmTransmitterType() -> CGMTransmitterType {
        return .Bubble
    }

    func isNonFixedSlopeEnabled() -> Bool {
        return nonFixedSlopeEnabled
    }

    func isWebOOPEnabled() -> Bool {
        return webOOPEnabled
    }

    func requestNewReading() {
        
        _ = sendStartReadingCommmand()
        
    }
    
    func maxSensorAgeInDays() -> Double? {
        return libreSensorType?.maxSensorAgeInDays() ?? maxAgeInDays
//        return maxAgeInDays
//        return libreSensorType?.maxSensorAgeInDays()
        
    }

    func getCBUUID_Service() -> String {
        return CBUUID_Service_Bubble
    }
    
    func getCBUUID_Receive() -> String {
        return CBUUID_ReceiveCharacteristic_Bubble
    }


    // MARK: - helpers
    
    /// 写蓝牙数据并打印命令（便于调试）
    private func writeToPeripheralAndLog(data: Data, type: CBCharacteristicWriteType) -> Bool {
        print("[Bubble BLE] 发送 length=\(data.count) hex=\(data.toHexString())")
        return writeDataToPeripheral(data: data, type: type)
    }
    
    /// reset rxBuffer, reset startDate, stop packetRxMonitorTimer, set resendPacketCounter to 0
    private func resetRxBuffer() {
        rxBuffer = Data()
        startDate = Date()
    }
    
}

fileprivate enum BubbleResponseType: UInt8 {
    case dataPacket = 130 //0x82
    case dataPacket87 = 0x87  // 与 0x82/0x8C 同为数据包
    case dataPacket2 = 0x8C
    case dataInfo = 128 //0x80
    case dataPacket84 = 0x84  // Android: 同 0x80 后发 getProTrend 或 getBubbleByte07
    case noSensor = 191 //0xBF
    case serialNumber = 192 //0xC0
    case patchInfo = 193 //0xC1
    /// bubble firmware 2.6 support decrypt libre2 344 to libre1 344
    /// if firmware >= 2.6, write [0x08, 0x01, 0x00, 0x00, 0x00, 0x2B]
    /// bubble will decrypt the libre2 data and return it
    case decryptedDataPacket = 136 // 0x88
    
    case authData = 0x8A
    case bubbleDb = 0xB9
    /// Bubble 对 0x7A (update db) 的应答，静默忽略
    case bubbleAck7A = 0xBA
}

extension BubbleResponseType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dataPacket, .dataPacket87, .decryptedDataPacket, .dataPacket2:
            return "Data packet received"
        case .dataPacket84:
            return "Data packet 0x84"
        case .noSensor:
            return "No sensor detected"
        case .dataInfo:
            return "Data info received"
        case .serialNumber:
            return "Serial number received"
        case .patchInfo:
            return "Patch info received"
        case .authData:
            return "Auth data"
        case .bubbleDb:
            return "Bubble DB"
        case .bubbleAck7A:
            return "Bubble ACK 0x7A"
        }
    }
}
