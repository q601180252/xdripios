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
 * Class Name: HdlcConfiguration.swift
 ******************************************************************************/

import Foundation
struct HdlcConfiguration
{
    public var sequenceNumberCount: UInt8 = 8
    
    public var transmitWindowSize: UInt8 = 4
    
    public var transmitAcknowledgeTimeout: Int = 500
    public var transmitMaxRetryCount: Int = 2
    
    public var maxDataLength: Int = 250
}
