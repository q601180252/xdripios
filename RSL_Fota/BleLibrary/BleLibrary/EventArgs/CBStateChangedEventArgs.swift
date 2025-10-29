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
 * Class Name: CBStateChangedEventArgs.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public struct CBStateChangedEventArgs{
    
    public var oldState: CBPeripheralState
    {
        return _oldState
    }

    public var newState: CBPeripheralState
    {
        return _newState
    }

    public var peripheral: PeripheralBase
    {
        return _peripheral
    }

    private var _oldState: CBPeripheralState
    private var _newState: CBPeripheralState
    private var _peripheral: PeripheralBase

    init( _ peripheral: PeripheralBase, _ oldState: CBPeripheralState, _ newState: CBPeripheralState)
    {
        self._oldState = oldState
        self._newState = newState
        self._peripheral = peripheral
    }
}
