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
 * Class Name: ProgressChangedEventArgs.swift
 ******************************************************************************/

import Foundation
struct ProgressChangedEventArgs
{
    public var current: Int
    {
        return _current
    }
    
    private var _current: Int
    
    public var total: Int
    {
        return _total
    }
    
    private var _total: Int
    
    
    init(current: Int, total: Int )
    {
        self._current = current
        self._total = total
    }
}
