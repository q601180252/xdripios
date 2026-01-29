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
 * Class Name: NameUpdatedEventArgs.swift
 ******************************************************************************/

import Foundation
public struct NameUpdatedEventArgs
{
    /**
     * New Name
     */
    public var name: String { return _name }
    private var _name: String
    
    /**
     * Create the event arguments
     */
    init(name: String)
    {
        _name = name
    }
}
