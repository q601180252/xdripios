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
 * Class Name: CrcProviderProtocol.swift
 ******************************************************************************/

import Foundation
protocol CrcProviderProtocol {
    
    /**
     The endianess used to convert CRC to byte array
     */
    var endianess: Endianess {get}
    
    /**
     The length of the CRC in bytes
     */
    var crcLength: Int {get}
    
    /**
     Invert the CRC before adding to data array
     */
    var invert: Bool {get}
    
    /**
     Calculates the CRC from offset of data and returns it as byte array in "endianess" byte order
     
     - parameters:
        - data: The data to calculate the CRC
        - offset: The offset of the data in the data array
        - length: The length of the data which the CRC should be calculated for
     */
    func calculate(data: Data, offset: Int, length: Int)throws -> Data
}
