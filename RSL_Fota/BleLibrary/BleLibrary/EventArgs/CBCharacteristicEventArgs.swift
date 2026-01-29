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
 * Class Name: CBCharacteristicEventArgs.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public struct CBCharacteristicEventArgs
{
    public var characteristic: CBCharacteristic
    {
        return _characteristic
    }
    
    public var error: Error?
    {
        return _error
    }
    
    private var _characteristic: CBCharacteristic
    private var _error: Error?
    
    init(_ characteristic: CBCharacteristic, _ error: Error?)
    {
        self._characteristic = characteristic
        self._error = error
    }
}
