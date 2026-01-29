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
 * Class Name: PeripheralState.swift
 ******************************************************************************/

import Foundation
public enum PeripheralState
{
    /**
     Peripheral is not used
     */
    case idle
    /**
     Attempt to establish a link to the peripheral
     */
    case establishLink
    /**
     Peripheral is connected and the services are going to be discovered
     */
    case discoveringServices
    /**
     The connection configuration (ATT MTU, Data Length Extention and connection parameters) get coonfigured
     */
    case negotiations
    /**
     The initial checks and readings from the peripherals are done
     */
    case initialize
    /**
     The peripheral is ready to be used
     */
    case ready
    /**
     Firmware update in progress
     */
    case update
    /**
     Tear down the peripheral link
     */
    case tearDownLink
    
    public var description: String
    {
        switch self {
        
        case .idle:
            return "idle"
        case .establishLink:
            return "establish link"
        case .discoveringServices:
            return "discovering services"
        case .negotiations:
            return "negotiations"
        case .initialize:
            return "initialize"
        case .ready:
            return "ready"
        case .update:
            return "update"
        case .tearDownLink:
            return "tear down link"
        }
        
    }
}
