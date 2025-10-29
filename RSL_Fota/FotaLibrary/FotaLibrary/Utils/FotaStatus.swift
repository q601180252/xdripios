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
 * Class Name: FotaStatus.swift
 ******************************************************************************/

import Foundation
public enum FotaStatus: UInt8
{
    /**
     Update finished with success
     */
    case success = 0x00
    /**
     The device id is not compatible
     */
    case incompatibleDeviceId = 0x01
    /**
     The build id is not compatible
     */
    case incompatibleBuildId = 0x02
    /**
     The image size is not valid
     */
    case wrongImageSize = 0x03
    /**
     The signature is not valid
     */
    case flashStorageError = 0x04
    /**
     The image start address is not valid
     */
    case invalidSignature = 0x05
    /**
     The image start address is nt valid
     */
    case invalidStartAddress = 0x06
    /**
     The device id of the selected device dose not match with the device id
     */
    case deviceIdMismatch = 0xff
    /**
     Unspecifiec error
     */
    case genaralError = 0xfe
    
    public var description: String
    {
        switch self {
            
        case .success:
            return "success"
        case .incompatibleDeviceId:
            return "incompatibleDeviceId"
        case .incompatibleBuildId:
            return "incompatibleBuildId"
        case .wrongImageSize:
            return "wrongImageSize"
        case .flashStorageError:
            return "flashStorageError"
        case .invalidSignature:
            return "invalidSignature"
        case .invalidStartAddress:
            return "invalidStartAddress"
        case .deviceIdMismatch:
            return "deviceIdMismatch"
        case .genaralError:
            return "generalError"
        }
    }
}
