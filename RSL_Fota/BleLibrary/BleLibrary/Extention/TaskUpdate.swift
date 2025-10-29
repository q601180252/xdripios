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
 * Class Name: TaskUpdate.swift
 ******************************************************************************/

import Foundation
class TaskUpdate: TaskEnhancedPeripheral
{
    private var _setup: UpdateSetup
    
    override var description: String
    {
        return "Update (Address: \(peripheral.peripheral?.uuid.uuidString ?? " no peripheral set "))"
    }
    
    init(peripheral: EnhancedPeripheral, setup: UpdateSetup)
    {
        _setup = setup
        super.init(peripheral)
    }
    
    override func start()
    {
        do
        {
            // log operation
            log.info("\(description) - Update started")
            
            //execute update
            try _setup.provider.update(periheral: peripheral, source: _setup.source!, options: _setup.options!)
            
            // log done
            log.info("\(description) - Update done")
         
            completed(result: BleResult.success)
        }
        catch
        {
            log.error("\(description) - Update failed: \(error)")
            completed(result: BleResult.failure)
        }
    }
}
