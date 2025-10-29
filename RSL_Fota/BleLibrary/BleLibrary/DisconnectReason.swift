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
 * Class Name: DisconnectReason.swift
 ******************************************************************************/

import Foundation
public enum DisconnectReason
{
    /**
     The peripheral side has terminated the connection
     */
    case remoteUserTerminatedConnection
    
    /**
     The central side has terminated the connection
     */
    case localHostTerminatedConnection
    
    /**
     The establish attempt ended with a timeout
     */
    case connectTimeout

    /**
     Bluetooth is disabled
     */
    case bluetoothDisabled
    
    /**
     The reason for the disconnect is unknown
     */
    case unknown

    var description: String
    {
        switch self {
            
        case .remoteUserTerminatedConnection:
            return "remoteUserTerminatedConnection"
        case .localHostTerminatedConnection:
            return "localHostTerminatedConnection"
        case .connectTimeout:
            return "connctTimeout"
        case .bluetoothDisabled:
            return "bluetoothDisabled"
        case .unknown:
            return "unknown"
        }
    }
}
