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
 * Class Name: BluetoothStateChangedEventArgs.swift
 ******************************************************************************/

import Foundation
public struct BluetoothStateChangedEventArgs {
    
    public var oldState: BluetoothState
    {
        return _oldState
    }
    
    public var newState: BluetoothState
    {
        return _newState
    }
    
    private var _oldState: BluetoothState
    private var _newState: BluetoothState
    
    init( _ oldState: BluetoothState, _ newState: BluetoothState)
    {
        self._oldState = oldState
        self._newState = newState
    }
}
