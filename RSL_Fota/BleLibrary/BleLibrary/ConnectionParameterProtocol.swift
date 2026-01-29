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
 * Class Name: ConnectionParameterProtocol.swift
 ******************************************************************************/

import Foundation
public protocol ConnectionParameterProtocol {
    /**
     Connection interval in 1.25 ms units
     */
    var interval: UInt16 {get}
    
    /**
     Slave latency in number of connection events
     */
    var slaveLatency: UInt16 {get}
    
    /**
     Connection supervision Timeout in 10 ms units
     */
    var supervisionTimeout: UInt16{get}
}
