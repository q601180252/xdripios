import Foundation
import os

/// for trace
fileprivate let log = OSLog(subsystem: ConstantsLog.subSystem, category: ConstantsLog.categoryLibreDataParser)

class LibreDataParser {
    
    // MARK: - private properties
    
    /// - per minute readings (trend) will be stored each time, as received rom Libre (meaning not smoothed)
    /// - goal is to reuse them in next reading session, for the smoothing of new values
    private var previousRawValues = UserDefaults.standard.previousRawLibreValues {
        didSet {
            UserDefaults.standard.previousRawLibreValues = previousRawValues
        }
    }

    private var lastLibreProSensorTimeInMinutes: Int {
        get {
            UserDefaults.standard.integer(forKey: "LibreDataParserLastLibreProSensorTimeInMinutes")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LibreDataParserLastLibreProSensorTimeInMinutes")
        }
    }
    
    /// for appending of previously stored values, how many values should match ?
    private let amountOfValuesToCompare = 4
    
    // MARK: - public functions
    
    /// parses libre1 block, with or without oop web, if libre1DerivedAlgorithmParameters is nil, then oop web is not used
    /// - parameters:
    ///     - libreData: the 344 bytes block from Libre
    /// - returns:
    ///     - array of GlucoseData, first is the most recent.
    ///     - sensorState: status of the sensor
    ///     - sensorTimeInMinutes: age of sensor in minutes
    ///     - libre1DerivedAlgorithmParameters : if nil then oop web is not used
    ///     - testTimeStamp : if set, then the most recent reading will get this timestamp
    ///     - libreSensorType. if nil means not known.  For transmitters that don't know the sensorType, this will not work
    private func parseLibre1Data(libreData: Data, libre1DerivedAlgorithmParameters: Libre1DerivedAlgorithmParameters?, testTimeStamp: Date?, libreSensorType: LibreSensorType?) -> (glucoseData:[GlucoseData], sensorState:LibreSensorState, sensorTimeInMinutes:Int) {
        
        let ourTime = testTimeStamp == nil ? Date() : testTimeStamp!
        let indexTrend:Int = libreData.getByteAt(position: (libreSensorType == .libreProH ? 76:26)) & 0xFF
        let indexHistory:Int = (libreSensorType == .libreProH ? 29 :libreData.getByteAt(position: 27) & 0xFF) //If Tomato firmware is modified, we will 168 byte history ..presently this to be ignored..
        let sensorTimeInMinutes:Int = (libreSensorType == .libreProH ? 256 * (libreData.getByteAt(position: 75) & 0xFF) + (libreData.getByteAt(position: 74) & 0xFF) : 256 * (libreData.getByteAt(position: 317) & 0xFF) + (libreData.getByteAt(position: 316) & 0xFF))
        let sensorStartTimeInMilliseconds:Double = ourTime.toMillisecondsAsDouble() - (Double)(sensorTimeInMinutes * 60 * 1000)
        var returnValue:Array<GlucoseData> = []
        let sensorState = LibreSensorState(stateByte: libreData[4])
        
        // rangeProcessor will be used for processing trend or history range, and return trend or history as array of GlucoseData
        let rangeProcessor = { (maxIndex: Int, indexTrendOrHistory: Int, timeInSecondsCalculator: (Int) -> Double, firstByteToAppend: Int ) -> [GlucoseData] in
            
            var result = [GlucoseData]()
            
            for index in 0..<maxIndex {
                var i = indexTrendOrHistory - index - 1
                if i < 0 {i += maxIndex}
                let timeInSeconds = timeInSecondsCalculator(index)
                
                var byte = Data()
                byte.append(libreData[(i * 6 + firstByteToAppend)])
                byte.append(libreData[(i * 6 + firstByteToAppend + 1)])
                byte.append(libreData[(i * 6 + firstByteToAppend + 2)])
                byte.append(libreData[(i * 6 + firstByteToAppend + 3)])
                byte.append(libreData[(i * 6 + firstByteToAppend + 4)])
                byte.append(libreData[(i * 6 + firstByteToAppend + 5)])
                
                let readingTimeStamp = Date(timeIntervalSince1970: sensorStartTimeInMilliseconds/1000 + timeInSeconds)
                
                // only add if readingTimeStamp smaller (ie reading is older) than the readingTimestamp of the last already known reading. This needs to be done because history measurements start with a timestamp somewhere in the middle of the trend measurements
                if let last = returnValue.last {
                    
                    if !(readingTimeStamp < last.timeStamp) {
                        
                        // skip the reading
                        continue
                        
                    }
                    
                }
                
                // do we calibrate with the oop web derived slope and intercep t?
                if let libre1DerivedAlgorithmParameters = libre1DerivedAlgorithmParameters {
                    
                    result.append(GlucoseData(timeStamp: readingTimeStamp, glucoseLevelRaw: LibreMeasurement(bytes: byte, slope: 0.1, offset: 0.0, date: readingTimeStamp, libre1DerivedAlgorithmParameters: libre1DerivedAlgorithmParameters).temperatureAlgorithmGlucose))
                    
                } else {
                    
                    // no calibration to do
                    let glucoseLevelRaw = Double(((256 * (byte.getByteAt(position: 1) & 0xFF) + (byte.getByteAt(position: 0) & 0xFF)) & 0x1FFF))
                    
                    if (glucoseLevelRaw > 0) {
                        
                        result.append(GlucoseData(timeStamp: readingTimeStamp, glucoseLevelRaw: glucoseLevelRaw * ConstantsBloodGlucose.libreMultiplier ))
                    
                    }
                    
                }
                
            }
            
            return result
            
        }
        
        // now use rangeProcessor to get trend measurements as array of GlucoseData
        var trend  = rangeProcessor(16, indexTrend, { index in
            return (max(0, (Double)(sensorTimeInMinutes - index))) * 60.0
        }, (libreSensorType == .libreProH ? 80:28))
        
        // add previously stored values if there are any
        trend = extendWithPreviousRawValues(trend: trend)
        
        // check if the trend and the previous raw values have at least 5 equal values, if so this is an expired sensor that keeps sending the same values, in that case no further processing
        if trend.hasEqualValues(howManyToCheck: 5, otherArray: previousRawValues) {
            
            trace("in libreDataProcessor, did detect flat values, returning empty GlucoseData array", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
            
            return ([GlucoseData](), sensorState, sensorTimeInMinutes)
        }
        
        // now, if previousRawValues was not an empty list, trend is a longer list of values because it's been extended with a subrange of previousRawvalues
        // we re-assign previousRawValues to the current list in trend, for next usage
        // but we restricted it to maximum x most recent values, it makes no sense to store more
        previousRawValues = Array(trend.map({$0.glucoseLevelRaw})[0..<(min(trend.count, ConstantsLibreSmoothing.amountOfPreviousReadingsToStore))])
        
        // smooth, if required
        if UserDefaults.standard.smoothLibreValues {
            
            // apply Libre smoothing
            LibreSmoothing.smooth(trend: &trend, repeatPerMinuteSmoothingSavitzkyGolay: ConstantsLibreSmoothing.libreSmoothingRepeatPerMinuteSmoothing, filterWidthPerMinuteValuesSavitzkyGolay: ConstantsLibreSmoothing.filterWidthPerMinuteValues, filterWidthPer5MinuteValuesSavitzkyGolay: ConstantsLibreSmoothing.filterWidthPer5MinuteValues, repeatPer5MinuteSmoothingSavitzkyGolay: ConstantsLibreSmoothing.repeatPer5MinuteSmoothing)
            
        }
        
        // if trend count would be 0 here then no reason to continue, should normally not be the case
        guard trend.count > 0 else {
            return ([GlucoseData](), sensorState, sensorTimeInMinutes)
        }
        
        // assign returnValue to trend, returnValue is used in rangeProcessor, which is still called to process the history values - just to get the timestamp of the first reading in trend
        returnValue = trend
        
        // timeInSecondsOfMostRecentHistoryValue is needed in timeInSecondsCalculator to get the trend
        let timeInSecondsOfMostRecentHistoryValue = (dateOfMostRecentHistoryValue(sensorTimeInMinutes: sensorTimeInMinutes, nextHistoryBlock: indexHistory, date: ourTime).toMillisecondsAsDouble() - sensorStartTimeInMilliseconds) / 1000

        // now use rangeProcessor to get history measurements as array of GlucoseData
        var history = rangeProcessor((libreSensorType == .libreProH ? 28:32), indexHistory, { index in
            return (max(0, timeInSecondsOfMostRecentHistoryValue - 900.0 * (Double)(index)))
        }, (libreSensorType == .libreProH ? 170:124))
        
        // smooth history one time, if required
        if UserDefaults.standard.smoothLibreValues {
            
            // add the oldest trend value to the history, this will make the smoothing of the history values more correct
            // otherwise we apply linear regression to the first element(s) in the history, which will give a less accurate result
            // trend.last is the oldest measurement more recent than the most recent element in history, so we insert it at index 0
            // and only if (trend.last timestamp + 10 minutes) > history.first timestamp
            var trendAdded = false
            if let firstHistory = history.first, let lastTrend = trend.last, lastTrend.timeStamp.timeIntervalSince(firstHistory.timeStamp) > 10.0 * 60.0  {
                
                history.insert(GlucoseData(timeStamp: lastTrend.timeStamp, glucoseLevelRaw: lastTrend.glucoseLevelRaw), at: 0)
                
                // need to remove it after applying the smoothing
                trendAdded = true

            }
            
            // smooth
            LibreSmoothing.smooth(history: &history, filterWidthPer5MinuteSmoothingSavitzkyGolay: ConstantsLibreSmoothing.libreSmoothingFilterWidthPer15MinutesValues)
            
            // now remove the trend measurement that was inserted
            if trendAdded {
                history.remove(at: 0)
            }
            
        }
        
        // add history to returnvalue
        returnValue = returnValue + history
        
        return (returnValue, sensorState, sensorTimeInMinutes)
        
    }
    
    /// - Process Libre block for all types of Libre sensors, and for both with and without web oop (without only for Libre 1). It checks if webOOP is enabled, if yes tries to use the webOOP, response is processed and delegate is called. If webOOP not enabled, and if Libre1, then local processing is done, in that case glucose values are not calibrated
    /// - if an error occurred, then this function will call cgmTransmitterDelegate.errorOccurred
    /// - parameters:
    ///     - libreSensorSerialNumber : if nil, then webOOP will not be used and local parsing will be done, but only for Libre 1
    ///     - patchInfo : will be used by server to out the glucose data, corresponds to type of sensor. Nil if not known which is used for Bubble or MM older firmware versions 
    ///     - libreData : the 344 bytes from Libre sensor
    ///     - webOOPEnabled : is webOOP enabled or not, if not enabled, local parsing is used. This can only be the case for Libre1
    ///     - cgmTransmitterDelegate : the cgmTransmitterDelegate, will be used to send the resultin glucose data and sensorTime (function cgmTransmitterInfoReceived)
    ///     - testTimeStamp : if set, then the most recent reading will get this timestamp
    ///     - dataIsDecryptedToLibre1Format : example if transmitter is Libre 2, data is already decrypted to Libre 1 format
    ///     - completionHandler : called with sensorState and xDripError
    public func libreDataProcessor(libreSensorSerialNumber: String?, patchInfo: String?, webOOPEnabled: Bool, libreData: Data, cgmTransmitterDelegate : CGMTransmitterDelegate?, dataIsDecryptedToLibre1Format: Bool, testTimeStamp: Date?, completionHandler:@escaping ((_ sensorState: LibreSensorState?, _ xDripError: XdripError?) -> ())) {

        // get libreSensorType, if this fails then it must be an unknown Libre sensor type in which case we don't proceed
        guard let libreSensorType = LibreSensorType.type(patchInfo: patchInfo) else {
            
            // unwrap patchInfo, although it can't be nil here because LibreSensorType.type would have returned .libre1 otherwise
            if let patchInfo = patchInfo {
                
                trace("in libreDataProcessor, failed to create libreSensorType, patchInfo = %{public}@", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info, patchInfo)
                
            }
         
            return
            
        }
        
        trace("in libreDataProcessor, sensortype = %{public}@", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info, libreSensorType.description)
        
        // let's see if we must use webOOP (if webOOPEnabled is true) and if so if we have all required info (libreSensorSerialNumber)
        if let libreSensorSerialNumber = libreSensorSerialNumber, webOOPEnabled {
            
            // if data is already decrypted then process the data as if it were a libre1 sensor type
            if dataIsDecryptedToLibre1Format {
                
                libre1DataProcessor(libreSensorSerialNumber: libreSensorSerialNumber, libreSensorType: libreSensorType, libreData: libreData, cgmTransmitterDelegate: cgmTransmitterDelegate, testTimeStamp: testTimeStamp, completionHandler: completionHandler)
                
                return
                
            }
            
            switch libreSensorType {
                
            case .libre1A2, .libre1, .libreProH:// these types are all Libre 1
                
                libre1DataProcessor(libreSensorSerialNumber: libreSensorSerialNumber, libreSensorType: libreSensorType, libreData: libreData, cgmTransmitterDelegate: cgmTransmitterDelegate, testTimeStamp: testTimeStamp, completionHandler: completionHandler)
                
            case .libreUS, .libreUSE6:// not sure if this works for libreUS
                
                // libreUS isn't working yet, create an error and send to delegate
                // 必须在主线程调用 delegate
                DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
                    cgmTransmitterDelegate?.errorOccurred(xDripError: LibreOOPWebError.libreUSNotSupported)
                }
                
                // should never come here ?
                trace("in libreDataProcessor, is libreUS but data is not decrypted - no further processing", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
                
            case .libre2, .libre2C5, .libre2C6, .libre27F, .libre2RU:
                
                // should never come here ?
                trace("in libreDataProcessor, is libre2 but data is not decrypted - no further processing", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
                
            case .libreUS14day:
                 trace("in libreDataProcessor, is libreUS14day but data is not decrypted - no further processing", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
                
            case .libre2US, .libre2CA:
                trace("in libreDataProcessor, is libre2US/CA but data is not decrypted - no further processing", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
                
            case .libre2Plus, .libreSense, .libre3:
                 trace("in libreDataProcessor, is libre2Plus/Sense/3 but data is not decrypted - no further processing", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
            
            case .unknown, .libre1New, .unsupported:
                 trace("in libreDataProcessor, is unknown/new/unsupported - no further processing", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
            }
            
        } else if (!webOOPEnabled || dataIsDecryptedToLibre1Format) {
            
            // as webOOPEnabled is not enabled it must be a Libre 1 type of sensor that supports "offline" parsing, ie without need for oop web
            // or it's a libre 2 sensor but the data is decrypted
            
            // get readings from buffer using local Libre 1 parser
            let parsedLibre1Data = parseLibre1Data(libreData: libreData, libre1DerivedAlgorithmParameters: nil, testTimeStamp: testTimeStamp, libreSensorType: libreSensorType)
            
            // handle the result
            handleGlucoseData(result: (parsedLibre1Data.glucoseData, parsedLibre1Data.sensorTimeInMinutes, parsedLibre1Data.sensorState, nil), cgmTransmitterDelegate: cgmTransmitterDelegate, completionHandler: completionHandler)
            
        } else {
            
            // it's not a libre 1 and oop web is enabled, so there's nothing we can do
            trace("in libreDataProcessor, can not continue - web oop is enabled, but there's missing info in the request", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
            
        }

    }

    // MARK: - Libre Pro（完整算法与 librepro.cpp readProGlucoseValue / readHistoricalValues / pressHistroy2 一致）

    /// Libre Pro 专用解析：trend 176 字节 + history 200 字节，使用 LibreProAlgorithm 完整校准与平滑管道。
    /// - trend: 176 字节（含校准区）；history: 200 字节；bstart: history 内起始字节；historyCount: 历史条数；start = historyCount - count
    public func libreProDataProcessor(trend: Data, history: Data, bstart: Int, historyCount: Int, cgmTransmitterDelegate: CGMTransmitterDelegate?, completionHandler: @escaping (LibreSensorState?, XdripError?) -> Void) {
        guard trend.count >= 0xAA, history.count >= (bstart + 6) else {
            trace("in libreProDataProcessor, insufficient data length", log: log, category: ConstantsLog.categoryLibreDataParser, type: .error)
            completionHandler(nil, nil)
            return
        }
        
        let trendArray = [UInt8](trend)
        let historyArray = [UInt8](history)
        
        // Libre Pro 与 Libre 1 相同，trend[4] 是 sensor state 字节
        let sensorState = LibreSensorState(stateByte: UInt8(trend[4] & 0xFF))
        let ourTime = Date()
        let sensorTimeInMinutes = (Int(trend[74]) & 0xFF) + (Int(trend[75]) & 0xFF) << 8
        
        trace("in libreProDataProcessor, sensorState = %{public}@ (from trend[4]), sensorTime = %{public}@ minutes", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info, sensorState.description, sensorTimeInMinutes.description)
        print("[LibreDataParser] libreProDataProcessor 开始处理，sensorState=\(sensorState.description) (trend[4]=0x\(String(format: "%02X", trend[4]))), sensorTime=\(sensorTimeInMinutes) 分钟")

        if sensorState == .ready,
           lastLibreProSensorTimeInMinutes > 0,
           sensorTimeInMinutes >= lastLibreProSensorTimeInMinutes,
           sensorTimeInMinutes - lastLibreProSensorTimeInMinutes < 5 {
            trace("in libreProDataProcessor, skipping Libre Pro reading because sensorTime delta is less than 5 minutes", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
            print("[LibreDataParser] Libre Pro 距上次有效数据不足 5 分钟，跳过")
            DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
                var emptyArray = [GlucoseData]()
                cgmTransmitterDelegate?.cgmTransmitterInfoReceived(glucoseData: &emptyArray, transmitterBatteryInfo: nil, sensorAge: TimeInterval(minutes: Double(sensorTimeInMinutes)))
            }
            completionHandler(sensorState, nil)
            return
        }
        
        // 如需测试算法，手动调用: LibreProAlgorithmTests.runAllTests()

        // 实时值（trend）：16 个最近的 1 分钟值
        var glucoseData: [GlucoseData] = []
        var trendValues: [Double] = []
        
        if let (value, raw, dataQuality, trendArrow) = LibreProAlgorithm.readProGlucoseValue(trendArray) {
            let sensorStartTimeInSeconds = ourTime.timeIntervalSince1970 - Double(sensorTimeInMinutes * 60)
            
            // 添加当前值
            let currentTime = sensorStartTimeInSeconds + Double(sensorTimeInMinutes) * 60.0
            let glucoseMgDl = dataQuality == 0 ? Double(value) : 0
            
            print("[LibreDataParser] 当前血糖值: \(value) mg/dL, raw=\(raw), dataQuality=\(dataQuality), trendArrow=\(trendArrow), 转换后=\(glucoseMgDl) mg/dL")
            
            if glucoseMgDl > 0 {
                glucoseData.append(GlucoseData(timeStamp: Date(timeIntervalSince1970: currentTime), glucoseLevelRaw: glucoseMgDl))
                trendValues.append(glucoseMgDl)
                
                trace("in libreProDataProcessor, current glucose = %{public}@ mg/dL, raw = %{public}@, trendArrow = %{public}@", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info, value.description, raw.description, trendArrow.description)
            }
        }

        // 历史值（history）：15 分钟间隔的历史值
        let count = min(32, historyCount, bstart + 6 <= history.count ? max(0, (history.count - bstart) / 6) : 0)
        let start = historyCount - count
        
        if count > 0, start >= 0 {
            let (_, historyResults) = LibreProAlgorithm.readHistoricalValues(current: trendArray, data: historyArray, bstart: bstart, start: start, end: count)
            let sensorStartTimeInSeconds = ourTime.timeIntervalSince1970 - Double(sensorTimeInMinutes * 60)
            
            trace("in libreProDataProcessor, processing %{public}@ history values", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info, historyResults.count.description)
            print("[LibreDataParser] ========== 处理历史值: \(historyResults.count) 个 ==========")
            
            var validHistoryCount = 0
            for (index, item) in historyResults.enumerated() {
                let t = sensorStartTimeInSeconds + Double(item.time) * 60.0
                let glucoseMgDl = item.dataQuality == 0 ? Double(item.oopValue) : 0
                
                // 格式化时间戳
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                let timeString = dateFormatter.string(from: Date(timeIntervalSince1970: t))
                
                // 打印每个历史值的详细信息
                let status = glucoseMgDl > 0 ? "✅" : "❌"
                print("  [\(String(format: "%2d", index))] \(status) time=\(item.time)分钟 (\(timeString)) | 血糖=\(item.oopValue) mg/dL | raw=\(item.raw) | dataQuality=\(item.dataQuality)")
                
                if glucoseMgDl > 0 {
                    glucoseData.append(GlucoseData(timeStamp: Date(timeIntervalSince1970: t), glucoseLevelRaw: glucoseMgDl))
                    validHistoryCount += 1
                }
            }
            print("[LibreDataParser] ========== 有效历史值: \(validHistoryCount)/\(historyResults.count) ==========")
            print("")
        }
        
        // 排序：最新的在前
        glucoseData.sort { $0.timeStamp > $1.timeStamp }
        
        // 检测平坦值（传感器卡住）
        if glucoseData.count >= 5 {
            let first5Values = Array(glucoseData.prefix(5)).map { $0.glucoseLevelRaw }
            if first5Values.allSatisfy({ $0 == first5Values[0] }) {
                trace("in libreProDataProcessor, detected flat values, skipping data", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
                
                // 必须在主线程调用 delegate（CoreData 操作）
                DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
                    var emptyArray = [GlucoseData]()
                    cgmTransmitterDelegate?.cgmTransmitterInfoReceived(glucoseData: &emptyArray, transmitterBatteryInfo: nil, sensorAge: TimeInterval(minutes: Double(sensorTimeInMinutes)))
                }
                
                completionHandler(sensorState, nil)
                return
            }
        }
        
        // 存储当前值用于下次连接时的间隙填补（最多存储 20 个）
        if glucoseData.count > 0 {
            let rawValues = glucoseData.prefix(20).map { $0.glucoseLevelRaw }
            previousRawValues = rawValues
            lastLibreProSensorTimeInMinutes = sensorTimeInMinutes
            trace("in libreProDataProcessor, stored %{public}@ raw values for next connection", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info, rawValues.count.description)
        }
        
        trace("in libreProDataProcessor, total glucose data count = %{public}@", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info, glucoseData.count.description)
        
        // 打印最终数据统计
        print("[LibreDataParser] ========== 数据统计 ==========")
        print("[LibreDataParser] 总计 glucoseData 数量: \(glucoseData.count)")
        
        if glucoseData.count > 0 {
            let values = glucoseData.map { $0.glucoseLevelRaw }
            let minValue = values.min() ?? 0
            let maxValue = values.max() ?? 0
            let avgValue = values.reduce(0.0, +) / Double(values.count)
            
            print("[LibreDataParser] 血糖值范围: \(Int(minValue)) - \(Int(maxValue)) mg/dL")
            print("[LibreDataParser] 平均血糖: \(Int(avgValue)) mg/dL")
            
            // 时间范围
            let sortedByTime = glucoseData.sorted { $0.timeStamp < $1.timeStamp }
            if let oldest = sortedByTime.first, let newest = sortedByTime.last {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                let oldestTime = dateFormatter.string(from: oldest.timeStamp)
                let newestTime = dateFormatter.string(from: newest.timeStamp)
                let span = newest.timeStamp.timeIntervalSince(oldest.timeStamp) / 60.0
                print("[LibreDataParser] 时间跨度: \(oldestTime) → \(newestTime) (约 \(Int(span)) 分钟)")
            }
        }
        print("[LibreDataParser] ================================")
        print("")
        
        // 显示所有要存储的数据点（按时间正序）
        if glucoseData.count > 0 {
            print("[LibreDataParser] ========== 即将存储的所有数据点 ==========")
            let sortedData = glucoseData.sorted { $0.timeStamp < $1.timeStamp }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd HH:mm:ss"
            
            for (index, data) in sortedData.enumerated() {
                let timeString = dateFormatter.string(from: data.timeStamp)
                let value = Int(data.glucoseLevelRaw)
                print("  [\(String(format: "%2d", index + 1))] \(timeString) | \(value) mg/dL")
            }
            print("[LibreDataParser] ===============================================")
            print("")
        }
        
        // 调用通用处理函数存储到数据库
        print("[LibreDataParser] 调用 handleGlucoseData 存储到数据库...")
        handleGlucoseData(result: (glucoseData, sensorTimeInMinutes, sensorState, nil), cgmTransmitterDelegate: cgmTransmitterDelegate, completionHandler: completionHandler)
        print("[LibreDataParser] handleGlucoseData 调用完成")
    }

    // MARK: - private functions
    
    /// processes libre data that is in Libre 1 format, this includes decrypted Libre 2 - this is with oop web
    /// - parameters:
    ///     - libreData : either Libre 1 data or decrypted Libre 2 data
    ///     - testTimeStamp : if set, then the most recent reading will get this timestamp
    private func libre1DataProcessor(libreSensorSerialNumber: String, libreSensorType: LibreSensorType, libreData: Data, cgmTransmitterDelegate: CGMTransmitterDelegate?, testTimeStamp: Date?, completionHandler:@escaping ((_ sensorState: LibreSensorState?, _ xDripError: XdripError?) -> ())) {
        
        // if libre1DerivedAlgorithmParameters not nil, but not matching serial number, then assign to nil
        if let libre1DerivedAlgorithmParameters = UserDefaults.standard.libre1DerivedAlgorithmParameters, libre1DerivedAlgorithmParameters.serialNumber != libreSensorSerialNumber {
            
            UserDefaults.standard.libre1DerivedAlgorithmParameters = nil
            
        }
        
        // if libre1DerivedAlgorithmParameters == nil, then calculate them
        if UserDefaults.standard.libre1DerivedAlgorithmParameters == nil {
            
            UserDefaults.standard.libre1DerivedAlgorithmParameters = Libre1DerivedAlgorithmParameters(bytes: libreData, serialNumber: libreSensorSerialNumber, libreSensorType: libreSensorType)
            
        }
        
        // unwrap libre1DerivedAlgorithmParameters, should be non nil because they've just been calculated
        guard let libre1DerivedAlgorithmParameters = UserDefaults.standard.libre1DerivedAlgorithmParameters else {return}
        
        
        trace("in libreDataProcessor, found libre1DerivedAlgorithmParameters in UserDefaults", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
        
        // if debug level logging enabled, than add full dump of libre1DerivedAlgorithmParameters in the trace (checking here to save some processing time if it's not needed
        if UserDefaults.standard.addDebugLevelLogsInTraceFileAndNSLog {
            trace("in libreDataProcessor, libre1DerivedAlgorithmParameters = %{public}@", log: log, category: ConstantsLog.categoryLibreDataParser, type: .debug, libre1DerivedAlgorithmParameters.description)
        }
        
        let parsedLibre1Data = parseLibre1Data(libreData: libreData, libre1DerivedAlgorithmParameters: libre1DerivedAlgorithmParameters, testTimeStamp: testTimeStamp, libreSensorType: libreSensorType)
        
        // handle the result
        handleGlucoseData(result: (parsedLibre1Data.glucoseData, parsedLibre1Data.sensorTimeInMinutes, parsedLibre1Data.sensorState, nil), cgmTransmitterDelegate: cgmTransmitterDelegate, completionHandler: completionHandler)
        
        return

    }
    
    
    /// calls delegate with parameters from result
    /// - parameters:
    ///     - result
    ///           - glucoseData : array of GlucoseData
    ///           - sensorTimeInMinutes: int
    ///           - error: optional xDripError
    ///           - sensorState: LibreSensorState
    ///     - cgmTransmitterDelegate: instance  of CGMTransmitterDelegate, which will be called with result and/or error if any
    ///     - libreSensorSerialNumber, if available
    ///
    /// if result.errorDescription not nil, then delegate function error will be called
    private func handleGlucoseData(result: (glucoseData:[GlucoseData], sensorTimeInMinutes:Int?, sensorState: LibreSensorState?, xDripError:XdripError?), cgmTransmitterDelegate : CGMTransmitterDelegate?, completionHandler:((_ sensorState: LibreSensorState?, _ xDripError: XdripError?) -> ())) {
        
        print("[LibreDataParser] handleGlucoseData 被调用，glucoseData 数量: \(result.glucoseData.count), sensorState: \(result.sensorState?.description ?? "nil")")
        
        // trace the sensor state
        if let sensorState = result.sensorState {
            trace("in handleGlucoseData, sensor state = %{public}@", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info, sensorState.description)
            
            // 严格检查：只允许 ready 状态存储数据
            // expired 和 shutdown 状态可能返回不可靠的数据
            if sensorState != .ready {
                
                trace("    not processing data as sensor does not have the state ready", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
                print("[LibreDataParser] ⚠️ 传感器状态不是 ready (当前: \(sensorState.description))，跳过数据处理")
                
                // initialize xDripError, to be used in calls to cgmTransmitterDelegate.errorOccurred and completionHandler
                let xDripError = LibreError.sensorNotReady
                
                // call cgmTransmitterDelegate (this is actually the RootViewController passed in via the BluetoothTransmitter
                // 必须在主线程调用 delegate
                DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
                    cgmTransmitterDelegate?.errorOccurred(xDripError: xDripError)
                }
                
                // call completionHandler, to inform caller about sensorState and xDripError
                completionHandler(sensorState, xDripError)
                
                return
                
            }
            
        } else {
            trace("in handleGlucoseData, sensor state is unknown", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
            print("[LibreDataParser] ⚠️ 传感器状态未知")
        }
        
        // if result.error not nil, then send it to the delegate and
        if let xDripError =  result.xDripError {
            
            // 必须在主线程调用 delegate
            DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
                cgmTransmitterDelegate?.errorOccurred(xDripError: xDripError)
            }
            
        }

        // variable to  be used in last call to cgmTransmitterDelegate
        var sensorTimeInResult: TimeInterval?

        // if sensor time < 60, return an empty glucose data array
        // should probably not happen because we only get here if status = .ready or .expired ?
        if let sensorTimeInMinutes = result.sensorTimeInMinutes {
            
            // assign sensorTimeInResult, will be used later
            sensorTimeInResult = TimeInterval(minutes: Double(sensorTimeInMinutes))
            
            guard sensorTimeInMinutes >= 60 else {
                
                trace("in handleGlucoseData, sensorTimeInMinutes < 60 minutes, no further processing", log: log, category: ConstantsLog.categoryLibreDataParser, type: .info)
                print("[LibreDataParser] ⚠️ 传感器时间 < 60 分钟，处于启动阶段")
                
                // 必须在主线程调用 delegate（CoreData 操作）
                DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
                    var emptyArray = [GlucoseData]()
                    cgmTransmitterDelegate?.cgmTransmitterInfoReceived(glucoseData: &emptyArray, transmitterBatteryInfo: nil, sensorAge: TimeInterval(minutes: Double(sensorTimeInMinutes)))
                }
                
                // call completion handler to make sure the sensor state is handled, set state to .starting, because result.sensorState has value .ready here which is not correct
                completionHandler(.starting, result.xDripError)
                
                return
                
            }
            
        }
        
        var result = result

        // call delegate with result
        print("[LibreDataParser] ✅ 调用 cgmTransmitterInfoReceived 存储数据，glucoseData 数量: \(result.glucoseData.count), sensorAge: \(sensorTimeInResult?.minutes ?? 0) 分钟")
        
        // 显示前 3 个值
        if result.glucoseData.count > 0 {
            print("[LibreDataParser] 数据样例（前 3 个）:")
            for (index, data) in result.glucoseData.prefix(3).enumerated() {
                print("  [\(index)] 时间: \(data.timeStamp), 血糖: \(data.glucoseLevelRaw) mg/dL")
            }
        }
        
        // 必须在主线程调用 delegate（CoreData 操作）
        DispatchQueue.main.async { [weak cgmTransmitterDelegate] in
            var glucoseDataCopy = result.glucoseData
            cgmTransmitterDelegate?.cgmTransmitterInfoReceived(glucoseData: &glucoseDataCopy, transmitterBatteryInfo: nil, sensorAge: sensorTimeInResult)
            print("[LibreDataParser] ✅ 数据已传递给委托，存储流程完成")
        }
        
        completionHandler(result.sensorState, result.xDripError)
        
    }


    /// Get date of most recent history value. (source dabear)
    /// History values are updated every 15 minutes. Their corresponding time from start of the sensor in minutes is 15, 30, 45, 60, ..., but the value is delivered three minutes later, i.e. at the minutes 18, 33, 48, 63, ... and so on. So for instance if the current time in minutes (since start of sensor) is 67, the most recent value is 7 minutes old. This can be calculated from the minutes since start. Unfortunately sometimes the history index is incremented earlier than the minutes counter and they are not in sync. This has to be corrected.
    ///
    /// - Returns: the date of the most recent history value and the corresponding minute counter
    private func dateOfMostRecentHistoryValue(sensorTimeInMinutes: Int, nextHistoryBlock: Int, date: Date) -> Date {
        // Calculate correct date for the most recent history value.
        //        date.addingTimeInterval( 60.0 * -Double( (sensorTimeInMinutes - 3) % 15 + 3 ) )
        let nextHistoryIndexCalculatedFromMinutesCounter = ( (sensorTimeInMinutes - 3) / 15 ) % 32
        let delay = (sensorTimeInMinutes - 3) % 15 + 3 // in minutes
        if nextHistoryIndexCalculatedFromMinutesCounter == nextHistoryBlock {
            // Case when history index is incremented togehter with sensorTimeInMinutes (in sync)
            //            print("delay: \(delay), sensorTimeInMinutes: \(sensorTimeInMinutes), result: \(sensorTimeInMinutes-delay)")
            return date.addingTimeInterval( 60.0 * -Double(delay))
        } else {
            // Case when history index is incremented before sensorTimeInMinutes (and they are async)
            //            print("delay: \(delay), sensorTimeInMinutes: \(sensorTimeInMinutes), result: \(sensorTimeInMinutes-delay-15)")
            return date.addingTimeInterval( 60.0 * -Double(delay - 15))
        }
    }
    
    private func recursive(indexInPreviousRawValues: Int, indexInTrend: Int, trendValues: inout [GlucoseData]) -> Bool {
        
        if previousRawValues[indexInPreviousRawValues] == trendValues[indexInTrend].glucoseLevelRaw {
            
            if indexInPreviousRawValues < amountOfValuesToCompare - 1 {
                
                return recursive(indexInPreviousRawValues: indexInPreviousRawValues + 1, indexInTrend: indexInTrend + 1, trendValues: &trendValues)
                
            } else {
                
                return true
                
            }
            
        } else {
            
            return false
            
        }
        
    }

    /// - uses previously stored values and tries to append trend with previous values, based on mathing values (appending meaning, as it's sorted by first the youngest
    /// - we need to find at least 4 matching values (just in case user has perfectly steady values for more than 3 minutes which will probably never happen), but this means maximum gap that we can close is 11 minutes, which is enough
    private func extendWithPreviousRawValues(trend: [GlucoseData]) -> [GlucoseData] {
        
        // previousRawValues length must be at least 16 and trend length must equal to 16 values, should always be the case, just to avoid crashes
        guard previousRawValues.count >= 16 && trend.count == 16 else {return trend}
        
        // create a new array with new GlucoseData instances
        var newTrend = trend.map({GlucoseData(timeStamp: $0.timeStamp, glucoseLevelRaw: $0.glucoseLevelRaw)})
        
        // for each value in trend, we will try to find a series of 4 (defined by amountOfValuesToCompare) matching values in previousRawValues
        // if found then we add the last values of previousRawValues, until we have a new consecutive array of values in newTrend
        for (match, _) in trend.enumerated() {
            
            if recursive(indexInPreviousRawValues: 0, indexInTrend: match, trendValues: &newTrend) {

                // now match indexes the first matching index
                
                // we'll need the timestamp of the current last element
                var lastTimeStamp = trend.last!.timeStamp
                
                // the first element from previousRawValue to append is at index size of trend - index
                // ad we go up to size of previousRawValues - 1 (stride is exclusive the last value)
                for i in stride(from: (16 - match), to: previousRawValues.count, by: 1) {

                    // next element will have a timestamp being previous timestamp - 1 minute
                    lastTimeStamp = lastTimeStamp.addingTimeInterval(-60.0)
                    
                    newTrend.append(GlucoseData(timeStamp: lastTimeStamp, glucoseLevelRaw: previousRawValues[i]))
                   
                }
                
                // found a matching range, now further processing needed
                break
                
            } else {
                
                // didn't find a match
                // if we already reached 16 minutes amount of values to compare then stop
                if match == 16 - amountOfValuesToCompare {
                    
                    break
                    
                }
                
            }
            
        }
        
        return newTrend
        
    }
    
}


