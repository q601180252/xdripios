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
 * Class Name: PeripheralMode.swift
 ******************************************************************************/

import Foundation
enum PeripheralMode
{
    /**
     The peripheral is not active and remains disconnected at all time
     */
    case inactive
    
    /**
     * The peripheral should be connected whenever it's possible. If the peripheral gets disconnected a reconnect will be attempted after (see "EchangedPeripheral.reconnectAfterDisconnectTimeout")
     */
    case active
    
    /**
     The peripheral gets connected on request. There is no automatic connect or disconnect
     */
    case manual
    
    var description: String
    {
        switch self {
        case .inactive:
            return "incative"
        case .active:
            return "active"
        case .manual:
            return "manual"
        }
    }
}
