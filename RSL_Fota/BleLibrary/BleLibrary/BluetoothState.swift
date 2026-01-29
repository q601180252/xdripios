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
 * Class Name: BluetoothState.swift
 ******************************************************************************/

import Foundation
public enum BluetoothState
{
    case Off
    case TurningOn
    case On
    case TurningOff
    case NotSupported
    case Unknown
    case Unauthorized
    case Resetting
    
    public var description: String
    {
        switch self {
        case .Off:
            return "Off"
        case .TurningOn:
            return "TurningOn"
        case .On:
            return "On"
        case .TurningOff:
            return "TurningOff"
        case .NotSupported:
            return "NotSupported"
        case .Unknown:
            return "Unknown"
        case .Unauthorized:
            return "Unauthorized"
        case .Resetting:
            return "Resetting"
        }
    }
}

