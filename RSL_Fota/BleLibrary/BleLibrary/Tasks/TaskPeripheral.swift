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
 * Class Name: TaskPeripheral.swift
 ******************************************************************************/

import Foundation
import os.log
class TaskPeripheral: TaskBase {
    
    //MARK: Properties
    var peripheral: PeripheralBase
    var manager: PeripheralManagerBaseProtocol
    
    //MARK: initialization
    init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol, _ timeout: Int)
    {
        self.peripheral = peripheral
        self.manager = manager
        super.init(timeout)
    }
}
