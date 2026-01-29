//
//  SummaryCell.swift
//  DiaBox
//
//  Created by Dongdong Gao on 11/28/24.
//  Copyright © 2024 Johan Degraeve. All rights reserved.
//

import UIKit

class SummaryCell: UITableViewCell {
    
    @IBOutlet weak var dateInfoLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var powerConsumptionLabel: UILabel!
    @IBOutlet weak var numberOfReadsLabel: UILabel!
    @IBOutlet weak var numberOfDisconnectionsLabel: UILabel!
    @IBOutlet weak var dbLabel: UILabel!
    
    func update(_ data: LogsBubble, isTopOne: Bool = false) {
        
        dateInfoLabel.text = data.timeStr ?? "-"
        
        guard let batteryStart = data.batteryStart?.intValue,
              let batteryEnd = data.batteryEnd?.intValue,
              let count = data.count?.intValue,
              let sendInit = data.sendInit?.intValue,
              let timeStr = data.timeStr,
              let db = data.db?.intValue else {
            dateInfoLabel.text = "-"
            percentLabel.text = "-"
            powerConsumptionLabel.text = "-"
            numberOfReadsLabel.text = "-"
            numberOfDisconnectionsLabel.text = "-"
            dbLabel.text = "-"
            return
        }
        
        powerConsumptionLabel.text = "\(batteryStart - batteryEnd)%"
        numberOfReadsLabel.text = "\(count)"
        numberOfDisconnectionsLabel.text = "\(sendInit)"
        dbLabel.text = "\(db) DB"
        
        let now = Date()
        if isTopOne && now.yyyy_MM_dd() == timeStr {
            let minCount = (calculateMinutesSinceMidnight() + 1) / 5
            numberOfReadsLabel.text = "\(count)/\(minCount)"
            
            if count == 0 || minCount == 0 {
                percentLabel.text = "0%"
            } else {
                percentLabel.text = String(format: "%d%%", ceil(Double(count) / Double(minCount) * 100.0))
            }
        } else {
            numberOfReadsLabel.text = "\(count)/288"
            if count == 0 {
                percentLabel.text = "0%"
            } else {
                percentLabel.text = String(format: "%d%%", Int(ceil(Double(count) / 288.0 * 100.0)))
            }
        }
    }
}

func calculateMinutesSinceMidnight() -> Int {
    let calendar = Calendar.current
    let now = Date()
    
    // 获取今天的 0 点 0 分 0 秒
    let midnight = calendar.startOfDay(for: now)
    // 计算当前时间与今天 0 点之间的时间差（秒）
    let secondsSinceMidnight = now.timeIntervalSince(midnight)
    
    // 转换为分钟
    let minutesSinceMidnight = secondsSinceMidnight / 60
    return Int(minutesSinceMidnight > 0 ? minutesSinceMidnight : 1)
}
