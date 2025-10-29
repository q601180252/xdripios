//
//  CGMBubble2BDataPackage.swift
//  xdrip
//
//  Created by Dongdong Gao on 8/8/24.
//  Copyright © 2024 Johan Degraeve. All rights reserved.
//

import Foundation
import LibOutshine
import os

class CADataCollector {
    
    private lazy var outshine: DBOutshine = {
        DBOutshine()
    }()
    
    func isSupported(_ patchInfo: String) -> Bool {
        //TODO
        return DBOutshine.isSupported(patchInfo)
//        return true
    }
        
    var writeFunc : ((String) -> Void)?
    
    var patchUid: String? {
        didSet {
            reset()
        }
    }
    
    var patchInfo: String? {
        didSet {
            reset()
        }
    }
    
    var libreDataCallback: ((String) -> Void)?
    
    private var caches = Array(repeating: Data(), count: 27)
    
    func reset() {
        caches = Array(repeating: Data(), count: 27)
        isWaiting = false
        caP1 = nil
    }
    
    private var isWaiting = false
    func append(data: Data) {
        guard data.count > 4 else { return }
        
        guard data[0] == 0x8a else { return }
        
        let index = indexOfData(data: data)
        caches[index] = data
        
        if !caches[0].isEmpty && !caches[1].isEmpty && !isWaiting {
            sendAuthData()
        }
        
        let fullData = (3..<27).reduce(true) { $0 && !caches[$1].isEmpty }
        if fullData {
            sendAuth2Data()
        }
    }
    
    private var caP1: String?
    private func sendAuthData() {
        guard let patchUid = patchUid, let patchInfo = patchInfo else { return }
        
        isWaiting = true
        
        trace("    before encodeAuth:  %{public}@", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .error, "data: \(caData1), patchUid: \(patchUid)")

        do {
            try outshine.encodeAuth(caData1, patchUid: patchUid, patchInfo: patchInfo, type: 0) { [weak self] caP1, data in
                guard let self else { return }
                trace("    after encodeAuth:  %{public}@", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .error, "p1: \(caP1), data: \(data)")

                self.caP1 = caP1
                self.writeFunc?(data)
            }

        } catch {
            
            trace("    encodeAuth error:  %{public}@", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .error, "error: \(error.localizedDescription)")
        }
    }
    
    private let log = OSLog(subsystem: ConstantsLog.subSystem, category: ConstantsLog.categoryCGMBubble)

    private func sendAuth2Data() {
        guard let patchUid = patchUid, let patchInfo = patchInfo else { return }

        trace("    before libreCAParsing:  %{public}@", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .error, "caP1: \(caP1), data: \(caData1), data2: \(caData2), data344: \(caData344), patchInfo: \(patchInfo), patchUid: \(patchUid)")

        do {
            try outshine.libreCAParsing(caP1 ?? "", data: caData1, data2: caData2, data344: caData344, patchInfo: patchInfo, patchUid: patchUid) { [weak self] result  in
                guard let self else { return }
                
                trace("    after libreCAParsing:  %{public}@", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .error, "result: \(result)")

                if let r = result as? String {
                    self.isWaiting = false
                    self.libreDataCallback?(r)
                }
            }

        } catch {
            trace("    libreCAParsing error:  %{public}@", log: self.log, category: ConstantsLog.categoryCGMBubble, type: .error, "error: \(error.localizedDescription)")
        }
    }
    
    private var caData1: String {
        let a = caches[0].subdata(in: 5..<caches[0].count) + caches[1].subdata(in: 4..<caches[1].count)
        return a.subdata(in: 0..<25).hexEncodedString()
    }
    
    private var caData2: String {
        let a = caches[2].subdata(in: 4..<caches[2].count)
        + caches[3].subdata(in: 4..<caches[3].count)
        + caches[4].subdata(in: 4..<caches[4].count)
        
        return a.hexEncodedString()
    }
    
    private var caData344: String {
        var a = Data()
        (5..<27).forEach { index in
            a += caches[index].subdata(in: 4..<caches[index].count)
        }
                
        return a.hexEncodedString()
    }
    
    private func indexOfData(data: Data) -> Int {
        if data[2] == 0x00 && data[3] == 0x00 && data[4] == 0x00 {
            return 0
        } else if data[2] == 0x00 && data[3] == 0x01 {
            return 1
        } else if data[2] == 0xff {
            return Int(data[3] / 0x10 + 2)
        } else {
            let pid = Int(data[2]) << 8 + Int(data[3])
            return Int(pid / 0x10 + 5)
        }
    }
    
}
