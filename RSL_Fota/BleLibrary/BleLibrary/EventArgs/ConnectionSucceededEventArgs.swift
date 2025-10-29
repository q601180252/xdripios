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
 * Class Name: ConnectionSucceededEventArgs.swift
 ******************************************************************************/

import Foundation
public struct ConnectionSucceededEventArgs {
    
    public var peripheral: PeripheralBase
    {
        return _peripheral
    }
    
    private var _peripheral: PeripheralBase
    
    init(_ peripheral: PeripheralBase)
    {
     self._peripheral = peripheral
    }
}
