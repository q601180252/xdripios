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
 * Class Name: CharacteristicPermissions.swift
 ******************************************************************************/

import Foundation
public enum CharacteristicPermissions: UInt
{
    case readable = 0x01
    case writeable = 0x02
    case readEncryptionRequired = 0x04
    case writeEncryptionRequired = 0x08
    
    public var description: String
    {
        switch self {
            
        case .readable:
            return "readable"
        case .writeable:
            return "writable"
        case .readEncryptionRequired:
            return "readEncryptionRequired"
        case .writeEncryptionRequired:
            return "writeEncryptionRequired"
        }
    }
}
