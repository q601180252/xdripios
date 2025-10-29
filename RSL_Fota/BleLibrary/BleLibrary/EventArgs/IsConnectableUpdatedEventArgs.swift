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
 * Class Name: IsConnectableUpdatedEventArgs.swift
 ******************************************************************************/

import Foundation
public struct IsConnectableUpdatedEventArgs {
    
    /**
     * New value
     */
    public var isConnectable: Bool { return _isConnectable }
    private var _isConnectable: Bool
    
    /**
     * Create the event argsuments
     */
    init(isConnectable: Bool)
    {
        _isConnectable = isConnectable
    }
}
