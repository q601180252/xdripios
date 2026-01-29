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
 * Class Name: CBRssiEventArgs.swift
 ******************************************************************************/

import Foundation
public struct CBRssiEventArgs
{
    public var rssi: Int
    {
        return _rssi
    }
    
    public var error: Error?
    {
        return _error
    }
    
    private var _rssi: Int
    private var _error: Error?
    
    init(_ rssi: Int, _ error: Error?)
    {
        self._rssi = rssi
        self._error = error
    }
}
