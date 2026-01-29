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
 * Class Name: ConnectionSecurityProtocol.swift
 ******************************************************************************/

import Foundation
public protocol ConnectionSecurityProtocol {
    /**
     LE security Mode
     */
    var mode: UInt8{get}
    
    /**
     LE security level
     */
    var level: UInt8 {get}
    
    /**
     Get a description of the security
     */
    var description: String {get}

}
