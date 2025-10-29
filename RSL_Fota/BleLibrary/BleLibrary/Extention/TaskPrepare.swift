/******************************************************************************
 * Copyright © 2021, Semiconductor Components Industries, LLC
 * (d/b/a ON Semiconductor). All rights reserved.
 *
 * This code is the property of ON Semiconductor and may not be redistributed
 * in any form without prior written permission from ON Semiconductor.
 * The terms of use and warranty for this code are covered by contractual
 * agreements between ON Semiconductor and the licensee.
 *
 * This is Reusable Code.
 *
 * Class Name: TaskEstablish.swift
 ******************************************************************************/

import Foundation
import os.log
class TaskPrepare: TaskEnhancedPeripheral {
    
    let serviceUUID: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    let writeCharacteristicUUID: String = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

    //MARK: members
    
    override var description: String {
        return "Prepare (Address: \(peripheral.peripheral?.uuid.uuidString ?? " no peripheral set "))"
    }
    
    override init(_ peripheral: EnhancedPeripheral) {
        super.init(peripheral)
    }
    
    override func start() throws {
        
        let p = peripheral.peripheral;
        
        var err: Error?
        
        if peripheral.state != PeripheralState.idle {
            completed(result: BleResult.connectionAlreadyEstablished)
            return
        }
        
        if p == nil {
            throw BleLibraryError.generalError(message: "Peripheral is not set (= nil)")
        }
        
        // log operation
        log.info("\(description) - Prepare started")
        
        do {
            // connect peripheral
            try peripheral.setState(newState: PeripheralState.establishLink)
            try peripheral.peripheral?.connect(timeout: peripheral.connectTimeout)
            
            // discover services
            try peripheral.setState(newState: PeripheralState.discoveringServices)
            try peripheral.peripheral!.discoverServices(timeout: peripheral.discoverServiceTimeout)
            
            let service = peripheral.peripheral?.findService(uuid: serviceUUID)
            
            if let p = peripheral.peripheral as? PeripheralBase, let c = service?.getCharacteristic(uuid: writeCharacteristicUUID) as? Characteristic {
                p.cbPeripheral?.writeValue(Data([0x7b, 0x03, 0x00]), for: c.cbCharacteristic, type: .withoutResponse)
            }
            
        } catch {
            err = error
            log.error("Prepare failed \(error)")
        }
        
        if err != nil {
            completed(result: BleResult.failure)
        } else {
            completed(result: BleResult.success)
        }
    }
}
