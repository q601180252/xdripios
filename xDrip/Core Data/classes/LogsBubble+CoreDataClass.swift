//
//  Sensor+CoreDataClass.swift
//  DiaBox
//
//  Created by yan on 2021/5/12.
//  Copyright © 2021 Johan Degraeve. All rights reserved.
//
//

import Foundation
import CoreData

public struct LogsBubbleItem {
    public var logs: LogsBubble
    public var list: [LogsBubble]
}


public class LogsBubble: NSManagedObject {
    
    init(nsManagedObjectContext:NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "LogsBubble", in: nsManagedObjectContext)!
        super.init(entity: entity, insertInto: nsManagedObjectContext)
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
    }
    
    //电池电量更新
    public func updateBattery100(_ battery: Int) {
        
    }
    
    //当天电池电量值更新
    public func updateBattery(_ battery: Int) {
        
    }
    
    //读取次数更新
    public func updateCount() {
        
    }
    
    //bf次数更新
    public func updateCountBf() {
        
    }
    
    //发送init次数更新
    public func updateCountSendInit() {
        
    }
}

extension LogsBubble {
    
}
