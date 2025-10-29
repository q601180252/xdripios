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
 * Class Name: CBPeripheralErrorEventArgs.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public struct CBPeripheralErrorEventArgs{
    
    public var error: Error?
    {
        return _error
    }
    
    private var _error: Error?
    
    public var peripheral: CBPeripheral
    {
        return _peripheral
    }
    
    private var _peripheral: CBPeripheral
    
    init(_ peripheral: CBPeripheral, _ error: Error?)
    {
        self._peripheral = peripheral
        self._error = error
    }
}
