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
class TaskEstablish: TaskEnhancedPeripheral {
    
    //MARK: members
    
    override var description: String
    {
        return "Establish (Address: \(peripheral.peripheral?.uuid.uuidString ?? " no peripheral set "))"
    }
    
    override init(_ peripheral: EnhancedPeripheral)
    {
        super.init(peripheral)
    }
    
    override func start() throws {
        
        let p = peripheral.peripheral;
        
        var err: Error?
        
        if peripheral.state != PeripheralState.idle
        {
            completed(result: BleResult.connectionAlreadyEstablished)
            return
        }
        
        if p == nil
        {
            throw BleLibraryError.generalError(message: "Peripheral is not set (= nil)")
        }
        
        // log operation
        log.info("\(description) - Establish started")
        
        do
        {
            var requiredUpdateSetup: UpdateSetup? = nil
            
            repeat
            {
                // connect peripheral
                try peripheral.setState(newState: PeripheralState.establishLink)
                try peripheral.peripheral?.connect(timeout: peripheral.connectTimeout)
                
                // discover services
                try peripheral.setState(newState: PeripheralState.discoveringServices)
                try peripheral.peripheral!.discoverServices(timeout: peripheral.discoverServiceTimeout)
                
                // initialize
                try peripheral.setState(newState: PeripheralState.initialize)
                requiredUpdateSetup = try peripheral.doInitialize()
                
                // update required
                if requiredUpdateSetup != nil
                {
                   try requiredUpdateSetup?.provider.update(periheral: peripheral, source: requiredUpdateSetup?.source, options: requiredUpdateSetup?.options)
                }
            }while requiredUpdateSetup != nil
            
            //We are ready
            try peripheral.setState(newState: PeripheralState.ready)
        }
        catch
        {
            err = error
            log.error("Establish failed \(error)")
        }
        
        if err != nil
        {
            completed(result: BleResult.failure)
        }
        else
        {
            completed(result: BleResult.success)
        }
    }
}
