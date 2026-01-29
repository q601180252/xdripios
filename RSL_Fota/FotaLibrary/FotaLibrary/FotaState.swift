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
 * Class Name: FotaState.swift
 ******************************************************************************/

import Foundation
public enum FotaState
{
    /**
     Peripheral is not used
     */
    case Idle
    /**
     Attempt to establish a link to the peripheral
     */
    case EstablishLink
    /**
     Periipheral is connected and the services are going to be discovered
     */
    case DiscoveringServices
    /**
     The initial checks and readings from the peripherals are down now
     */
    case Initialize
    /**
     Firmware update is in progress
     */
    case Update
    /**
     The initial checks and readings from the peripherals are done now
     */
    case Ready
    /**
     Tear down the peripheral link
     */
    case TearDownLink
}
