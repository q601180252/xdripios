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
 * Class Name: TaskTearDown.swift
 ******************************************************************************/

import Foundation
class TaskTeardown: TaskEnhancedPeripheral
{
    override var description: String
    {
        return "Teardown (Address: \(peripheral.peripheral?.uuid.uuidString ?? " no peripheral set "))"
    }
    
    override init(_ peripheral: EnhancedPeripheral) {
        super.init(peripheral)
    }
    
    override func start() throws {
        
        var err: Error? = nil
        
        // log operation
        log.info("\(description) - Teardown started")
        
        do
        {
            //disconnect peripheral
            try peripheral.peripheral?.disconnect(timeout: peripheral.disconnectTimeout)
            
            // done
            log.info("\(description) - Teardown done")
        }
        catch
        {
            log.info("\(description) - Teardown faild (\(error))")
            err = error
        }
        
        if err != nil
        {
            completed(result: BleResult.failure)
        }
        else
        {
            completed(result: BleResult.success)
        }
        
        try peripheral.setState(newState: PeripheralState.idle)
    }
    
}
