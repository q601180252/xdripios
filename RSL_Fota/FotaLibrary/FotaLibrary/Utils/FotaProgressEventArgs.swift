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
 * Class Name: FotaProgressEventArgs.swift
 ******************************************************************************/

import Foundation
public struct FotaProgressEventArgs {
    
    //MARK: Properties
    /**
     The current progress in byte
     */
    public var current: Int
    {
        return _current
    }
    
    /**
     The total number of bytes
     */
    public var total: Int
    {
        return _total
    }
    
    /**
     The current update step
     */
    public var step: FotaUpdateStep
    {
        return _step
    }
    
    //MARK: Members
    private var _current: Int
    private var _total: Int
    private var _step: FotaUpdateStep
    
    //MARK: initilizer
    init(current: Int, total: Int, step: FotaUpdateStep)
    {
        _current = current
        _total = total
        _step = step
    }
}
