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
 * Class Name: ParameterSet.swift
 ******************************************************************************/

import Foundation
public struct ParameterSet
{
    /**
     * Connection Interval in 1.25 ms units
     */
    public var interval: Int { return _interval }
    private var _interval: Int

    /**
     * Slave Latency in number of connection events
     */
    public var slaveLatency: Int { return _slaveLatency}
    private var _slaveLatency: Int
    
    /**
     * Connection Supervision timeout in 10 ms units
     */
    public var supervisionTimeout: Int { return _supervisionTimeout }
    private var _supervisionTimeout: Int
    
    public var description: String
    {
        return "Interval:\(1.25 * Double(interval))ms Latency:\(slaveLatency) Timeout\(10 * supervisionTimeout)ms"
    }

    init(interval: Int, slaveLatency: Int, supervisionTimeout: Int)
    {
        _interval = interval
        _slaveLatency = slaveLatency
        _supervisionTimeout = supervisionTimeout
    }
    
    public func isEquals(other: ParameterSet) -> Bool
    {
        if((other.interval != interval) || (other.slaveLatency != slaveLatency) || (other.supervisionTimeout != supervisionTimeout))
        {
            return false
        }
        
        return true
    }
    
    public func getHashCode() -> Int
    {
        var hash = 13
        hash = (hash * 7) + interval
        hash = (hash * 7) + slaveLatency
        hash = (hash * 7) + supervisionTimeout
        
        return hash
    }
}
