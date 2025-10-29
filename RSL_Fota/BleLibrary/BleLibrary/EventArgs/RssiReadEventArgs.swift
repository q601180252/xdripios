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
 * Class Name: RssiReadEventArgs.swift
 ******************************************************************************/

import Foundation
public struct RssiReadEventArgs
{
    public var rssi: Int
    {
        return _rssi
    }
    
    public var result: BleResult
    {
        return _result
    }
    
    public var peripheral: PeripheralBase
    {
        return _peripheral
    }
    
    private var _rssi: Int
    private var _result: BleResult
    private var _peripheral: PeripheralBase
    
    init(_ peripheral: PeripheralBase, _ rssi: Int, _ result: BleResult)
    {
        self._rssi = rssi
        self._result = result
        self._peripheral = peripheral
    }    
}
