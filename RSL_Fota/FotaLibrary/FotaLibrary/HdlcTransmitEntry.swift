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
 * Class Name: HdlcTransmitEntry.swift
 ******************************************************************************/

import Foundation
class HdlcTransmitEntry
{
    //MARK: Properties
    public var sendCount: Int
    public var sendTime: Date? //Control if C# DateTime?
    public var data: Data { return _data }
    public var sequenceNumber: UInt8 { return _sequenceNumber }
    
    private var _data: Data
    private var _sequenceNumber: UInt8
    
    init(data: Data, sequenceNumber: UInt8)
    {
        sendCount = 0
        _data = data
        _sequenceNumber = sequenceNumber
    }
}
