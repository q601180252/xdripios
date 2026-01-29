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
 * Class Name: DataExtension.swift
 ******************************************************************************/

extension Data {
    func subdata(in range: ClosedRange<Index>) -> Data{
        return subdata(in: range.lowerBound..<range.upperBound)
    }
    
    mutating func insertRangeAt(source: Data, sourceIndex: Int, destinationIndex: Int, length: Int)
    {
        for i in 0..<length
        {
            self.insert(source[i + sourceIndex], at: (destinationIndex + i))
        }
    }
    
    func reverse() -> Data{
        return Data(reversed())
    }
    
    func toArray() -> [UInt8]{
        return [UInt8](self)
    }
}
