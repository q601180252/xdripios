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
 * Class Name: DisconnectedEventArgs.swift
 ******************************************************************************/

import Foundation
public struct DisconnectedEventArgs {
    /**
     * Get the reason for the disconnect
     */
    public var reason: DisconnectReason { return _reason }
    private var _reason: DisconnectReason
    
    init(reason: DisconnectReason)
    {
        _reason = reason
    }    
}
