//
//  DetailCell.swift
//  DiaBox
//
//  Created by Dongdong Gao on 11/28/24.
//  Copyright © 2024 Johan Degraeve. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var cumulativePowerConsumptionLabel: UILabel!
    @IBOutlet weak var currentBatteryLabel: UILabel!
    @IBOutlet weak var dailyConsumptionLabel: UILabel!
    @IBOutlet weak var persistedLabel: UILabel!
    
    @IBOutlet weak var currentLabel: UILabel!
    
    func update(_ data: LogsBubble, showCurrent: Bool = false) {

        startTimeLabel.text = data.timestamp?.localString() ?? "-"

        guard let batteryEnd = data.batteryEnd?.intValue, let batteryStart = data.batteryStart?.intValue, batteryStart - batteryEnd >= 0 else {
            cumulativePowerConsumptionLabel.text = "-"
            currentBatteryLabel.text = "-"
            dailyConsumptionLabel.text = "-"
            persistedLabel.text = "-"
            return
        }
        
        let all = batteryStart - batteryEnd
        currentBatteryLabel.text = "\(batteryEnd)"
        cumulativePowerConsumptionLabel.text = "\(all)"
        
        guard let timestampEnd = data.timestampEnd, let timestamp = data.timestamp else {
            dailyConsumptionLabel.text = "-"
            persistedLabel.text = "-"
            return
        }
        
        let timeInterval = timestampEnd.timeIntervalSince(timestamp)
        guard timeInterval >= 0 else {
            dailyConsumptionLabel.text = "-"
            persistedLabel.text = "-"
            return
        }
        
        let day = calculateDaysBetween(startDate:timestamp, endDate: timestampEnd)
        persistedLabel.text = String(format: "%d", day)
        if day == 0 {
            dailyConsumptionLabel.text = "0%"
        } else {
            dailyConsumptionLabel.text = String(format: "%d%%", all / day)
        }
        
        currentLabel.isHidden = !showCurrent
    }
}

func calculateDaysBetween(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    
    // 标准化日期为当天的 0 点
    let startOfDay = calendar.startOfDay(for: startDate)
    let endOfDay = calendar.startOfDay(for: endDate)
    
    // 计算时间差（以秒为单位），再转为天数
    let timeInterval = endOfDay.timeIntervalSince(startOfDay)
    let daysBetween = timeInterval / (24 * 3600)
    return Int(daysBetween)
}

extension Date {
    func localString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
