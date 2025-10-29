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
 * Class Name: FotaUpdateStep.swift
 ******************************************************************************/

import Foundation
public enum FotaUpdateStep{
    /**
     Initial state
     */
    case idle
    /**
     Connect the periphheral
     */
    case connect
    /**
     Discover services
     */
    case discoverServices
    /**
     Initialize the peripheral
     */
    case initialize
    /**
     A delay before starting the next step
     */
    case delay
    /**
     ScanForDevice
     */
    case scanForDevice
    /**
     Update FOTA image
     */
    case updateFotaImage
    /**
     Update app image
     */
    case updateAppImage
    /**
     The device is in application mode, reboot into bootloader
     */
    case rebootToBootLoader
    /**
     Update finished
     */
    case finished
    
    public var description: String
    {
        switch self {
            
        case .idle:
            return "Idle"
        case .connect:
            return "Connect"
        case .discoverServices:
            return "DiscoverServices"
        case .initialize:
            return "Initialize"
        case .delay:
            return "Delay"
        case .updateFotaImage:
            return "UpdateFotaImage"
        case .updateAppImage:
            return "UpdateAppImage"
        case .rebootToBootLoader:
            return "RebootToBootLoader"
        case .finished:
            return "Finished"
        case .scanForDevice:
            return "ScanForDevice"
        }
    }
}
