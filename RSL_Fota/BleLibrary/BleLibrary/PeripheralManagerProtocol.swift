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
 * Class Name: PeripheralManagerProtocol.swift
 ******************************************************************************/

import CoreBluetooth
import Foundation

public protocol PeripheralManagerProtocol: PeripheralManagerBaseProtocol{
   
    associatedtype TPeripheral: PeripheralProtocol
    
    /**
     A list of visible Bluetooth LE peripherals. The list is updated when a new peripheral is found or when a peripheral is not seen until the InvisibleTimout
     */
    var peripherals: [TPeripheral] { get }
    
    /**
     Checks if the peripheral can be safely removed from the {@link #peripherals() peripherals} list.
     
     - parameters:
     - peripheral: The peripheral to remove
     
     - returns:
     True when a peripheral can be removed from the {@link #peripherals() peripherals} list, false otherwise
     */
    func canRemove(peripheral: TPeripheral) -> Bool
    
    /**
     Find if peripehral exists in the peripehral list
     
     - parameters:
     - uuid: UUID of the new peripheral
     
     - returns:
     TPeripheral if found else nil
     */
    func find(uuid: UUID)throws -> TPeripheral?
}
