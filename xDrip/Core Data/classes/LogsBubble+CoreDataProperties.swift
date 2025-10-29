//
//  Sensor+CoreDataProperties.swift
//  DiaBox
//
//  Created by yan on 2021/5/12.
//  Copyright © 2021 Johan Degraeve. All rights reserved.
//
//

import Foundation
import CoreData


extension LogsBubble {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogsBubble> {
        return NSFetchRequest<LogsBubble>(entityName: "LogsBubble")
    }
    
    @NSManaged public var batteryEnd: NSNumber? // 结束电量
    @NSManaged public var batteryStart: NSNumber? // 开始电量
    @NSManaged public var count: NSNumber? //读取次数
    @NSManaged public var countBf: NSNumber? //无探头次数
    @NSManaged public var db: NSNumber? //读取的db数据
    @NSManaged public var logType: NSNumber? // 数据类型 0 记录当天读取情况 1 记录电池100-0 读取情况
    @NSManaged public var sendInit: NSNumber? //发送init次数
    @NSManaged public var timestamp: Date? // 时间戳
    @NSManaged public var timeStr: String? // 时间字符串
    @NSManaged public var timestampEnd: Date? // 结束时间
}
