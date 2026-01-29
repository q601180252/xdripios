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
 * Class Name: FotaOptions.swift
 ******************************************************************************/

import BleLibrary
import Foundation
public struct FotaOptions
{
    /**
     Function to reboot the peripheral into the bootloader. The FOTA characteristic is used to reboot into the bootloader, if no function is provided. This function must have a (see PeripheralProtocol)
     
     The return value is the (see PeripheralProtocol)
     This can be:
     1. The same peripheral if the bluetooth address is still the same after reboot
     2. A new peripheral if the bluetooth adress is no longer the same.
     3. Nil if this library should search for a peripheral in dfu mode.
     */
    public var rebootToBootloaderFunc: ((PeripheralProtocol) -> PeripheralProtocol)?
    
    /**
     Force the update of the bootloader, even id the fota build ids are equal
     */
    public var forceUpdate: Bool?
    
    /**
     Delay after disconnect connect [ms]
     This delay may be added to ensure that the ble stack had enought time to
     change the connection state to disconnected.
     */
    public var delayAfterDisconnect: Int?
    
    public init()
    {
        rebootToBootloaderFunc = nil
        forceUpdate = false
        delayAfterDisconnect = 0
    }
}
