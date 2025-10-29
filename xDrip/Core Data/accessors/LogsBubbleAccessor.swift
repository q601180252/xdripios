//
//  LogsBubbleAccessor.swift
//  DiaBox
//
//  Created by Dongdong Gao on 10/30/24.
//  Copyright © 2024 Johan Degraeve. All rights reserved.
//

import CoreData
import Foundation

public class LogsBubbleAccessor: NSObject {
    private let coreDataManager: CoreDataManager
        
    // MARK: - initializer
    init(coreDataManager:CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init()
    }
    
    lazy private(set) var context: NSManagedObjectContext = {
        let context = coreDataManager.mainManagedObjectContext
        return context
    }()
    
    func clear() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LogsBubble")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("清空 LogsBubble 失败：\(error)")
        }
    }
    
    //查询本地所有数据 显示在ui上
    func findBattery100All() -> [LogsBubble] {
        var result: [LogsBubble] = []

        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logType == %d", 1)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        context.performAndWait {
            do {
                let list = try context.fetch(fetchRequest)
                for (index, item) in list.enumerated() {
                    result.append(item)
                    var endTime = item.timestampEnd
                    var startTime = item.timestamp
                    if endTime == nil {
                        if index < result.count - 1 {
                            startTime = result[index + 1].timestamp
                        } else {
                            startTime = Date()
                        }
                        endTime = item.timestamp
                    }
                    var list2 = findBatteryAllByTime(startTime: startTime!, endTime: endTime!)
                    if (list2.count > 0) {
                        result.append(contentsOf: list2)
                    }
                }

            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }
        
        return result
    }
    
    
    func findBatteryAll() -> [LogsBubble] {
        var result: [LogsBubble] = []
        
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logType == %d", 0)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 14

        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest)
            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }

        return result
    }

    func findBatteryAllByTime(startTime: Date, endTime: Date) -> [LogsBubble] {
        var result: [LogsBubble] = []
        
        let fetchRequest = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@ AND logType == %d", startTime as NSDate, endTime as NSDate, 0)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStr", ascending: false)]

        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest)
            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }

        return result
    }
    
    //电池电量更新
    func updateBattery100(_ battery: Int) {
        var local: LogsBubble?
        
        let date = Date()
        let timeStr = date.yyyy_MM_dd()
        
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logType == %d", 1)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1

        context.performAndWait {
            do {
                local = try context.fetch(fetchRequest).first
                
                if let batteryEnd = local?.batteryEnd?.intValue, batteryEnd >= (battery - 5) {

                    if battery == 100 && local?.batteryStart?.intValue != 100 {
                        local?.timestampEnd = date
                        saveLogsBubble(battery: battery, timeStr: timeStr)
                    } else {
                        local?.batteryEnd = NSNumber(value: battery)
                        local?.count = NSNumber(value: (local?.count?.intValue ?? 0) + 1)
                        local?.timestampEnd = date
                    }
                } else {
                    if let existingLog = local {
                        existingLog.timestampEnd = date
                    }
                    saveLogsBubble(battery: battery, timeStr: timeStr) // Call to save new log
                }
                
                try context.save()
            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }
    }
    
    // New function to save the new log
    private func saveLogsBubble(battery: Int, timeStr: String) {
        let now = Date()
        
        let newLog = LogsBubble(context: context)
        newLog.timestamp = now
        newLog.timestampEnd = now.addingTimeInterval(12)
        newLog.batteryStart = NSNumber(value: battery)
        newLog.batteryEnd = NSNumber(value: battery)
        newLog.timeStr = timeStr
        newLog.count = NSNumber(value: 1)
        newLog.logType = NSNumber(value: 1)
        newLog.db = NSNumber(value: UserDefaults.standard.bubbleDb ?? 0)
    }
    
    //当天电池电量值更新
    func updateBattery(_ battery: Int) {

        let now = Date()
        let timeStr = now.yyyy_MM_dd()
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "timeStr == %@ AND logType == %d", timeStr, 0)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if let existingLog = results.first {
                    existingLog.batteryEnd = NSNumber(value: battery)
                    if existingLog.batteryStart == nil || existingLog.batteryStart?.intValue == 0 {
                        existingLog.batteryStart = NSNumber(value: battery)
                    }
                    existingLog.timestamp = findLastTime()
                    
                    if (existingLog.batteryEnd!.intValue - 2) > existingLog.batteryStart!.intValue {
                        existingLog.batteryStart = NSNumber(value: battery)
                        existingLog.batteryEnd = NSNumber(value: battery)
                        existingLog.timestamp = now
                    }
                } else {

                    let newLog = LogsBubble(context: context)
                    newLog.timestamp = now
                    newLog.batteryStart = NSNumber(value: battery)
                    newLog.batteryEnd = NSNumber(value: battery)
                    newLog.timeStr = timeStr
                    newLog.logType = NSNumber(value: 0)

                    context.insert(newLog)
                }

                try context.save()

            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }
    }

    //读取次数更新
    func updateCount() {
        var local: LogsBubble?
        
        let date = Date()
        let timeStr = date.yyyy_MM_dd()
        
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logType == %d && timeStr == %@", 0, timeStr)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1

        context.performAndWait {
            do {
                local = try context.fetch(fetchRequest).first
                
                if let l = local {
                    l.count = NSNumber(value: (l.count?.intValue ?? 0) + 1)
                    l.timestamp = findLastTime()
                } else {
                    let newLog = LogsBubble(context: context)
                    newLog.timestamp = date
                    newLog.timeStr = timeStr
                    newLog.count = NSNumber(value: 1)
                    newLog.logType = NSNumber(value: 0)
                    newLog.db = NSNumber(value: UserDefaults.standard.bubbleDb ?? 0)
                }
                
                try context.save()
            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }
    }
    
    //bf次数更新
    func updateCountBf() {
        var local: LogsBubble?
        
        let date = Date()
        let timeStr = date.yyyy_MM_dd()
        
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logType == %d && timeStr == %@", 0, timeStr)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1

        context.performAndWait {
            do {
                local = try context.fetch(fetchRequest).first
                
                if let l = local {
                    l.countBf = NSNumber(value: (l.countBf?.intValue ?? 0) + 1)
                    l.timestamp = date
                } else {
                    let newLog = LogsBubble(context: context)
                    newLog.timestamp = date
                    newLog.timeStr = timeStr
                    newLog.countBf = NSNumber(value: 1)
                    newLog.logType = NSNumber(value: 0)
                    newLog.db = NSNumber(value: UserDefaults.standard.bubbleDb ?? 0)
                }
                
                try context.save()
            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }
    }

    //发送init次数更新
    func updateCountSendInit() {
        var local: LogsBubble?
        
        let date = Date()
        let timeStr = date.yyyy_MM_dd()
        
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logType == %d && timeStr == %@", 0, timeStr)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1

        context.performAndWait {
            do {
                local = try context.fetch(fetchRequest).first
                
                if let l = local {
                    l.sendInit = NSNumber(value: (l.sendInit?.intValue ?? 0) + 1)
                    l.timestamp = findLastTime()
                } else {
                    let newLog = LogsBubble(context: context)
                    newLog.timestamp = date
                    newLog.timeStr = timeStr
                    newLog.sendInit = NSNumber(value: 1)
                    newLog.logType = NSNumber(value: 0)
                    newLog.db = NSNumber(value: UserDefaults.standard.bubbleDb ?? 0)
                }
                
                try context.save()
            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }
    }

    func updateDB(db: Int) {
        let now = Date()
        let timeStr = now.yyyy_MM_dd()
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timeStr == %@ AND logType == %d", timeStr, 0)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1

        context.performAndWait {
            do {
                if let existingLog = try context.fetch(fetchRequest).first {
                    // Update existing log
                    existingLog.db = NSNumber(value: db)
                    existingLog.timestamp = findLastTime()
                } else {
                    let newLog = LogsBubble(context: context)
                    newLog.timestamp = now
                    newLog.db = NSNumber(value: db)
                    newLog.timeStr = timeStr
                    newLog.logType = NSNumber(value: 0)
                }
                
                try context.save()
            } catch {
                print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            }
        }
    }

    func findLastTime() -> Date {
        
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logType == %d", 1)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let lastTimestamp = results.first?.timestamp {
                return lastTimestamp.addingTimeInterval(1)
            } else {
                return Date()
            }
        } catch {
            print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            return Date()
        }
    }
    
    func currentLogsBubble() -> LogsBubble? {
        let now = Date()
        let timeStr = now.yyyy_MM_dd()
        
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timeStr == %@ AND logType == %d", timeStr, 0)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("\(#fileID)\n\(#line): \(error.localizedDescription)")
            return nil
        }
    }

    func findBattery100All2() -> [LogsBubbleItem] {
        var result: [LogsBubbleItem] = []
        
        let fetchRequest: NSFetchRequest<LogsBubble> = LogsBubble.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logType == %d", 1)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        context.performAndWait {
            do {
                let logs = try context.fetch(fetchRequest)
                print("findBattery100All2====")
                for (index, log) in logs.enumerated() {
                    var endTime = log.timestampEnd
                    var startTime = log.timestamp
                    
                    if endTime == nil {
                        if index < logs.count - 1 {
                            startTime = logs[index + 1].timestamp
                        } else {
                            startTime = Date()
                        }
                        endTime = log.timestamp
                    }
                    
                    let list2 = findBatteryAllByTime(startTime: startTime!, endTime: endTime!)
                    if list2.count > 0 {
                        result.append(LogsBubbleItem(logs: log, list: list2))
                    }
                }
                print("findBattery100All2 list====\(result.count)")
            } catch {
                print("SQLException: \(error.localizedDescription)")
            }
        }
        
        return result
    }
}

extension Date {
    func yyyy_MM_dd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
