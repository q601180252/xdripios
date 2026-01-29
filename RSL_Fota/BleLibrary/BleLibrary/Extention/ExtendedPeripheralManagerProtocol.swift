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
 * Class Name: ExtendedPeripheralManagerProtocol.swift
 ******************************************************************************/

import Foundation
protocol ExtendedPeripheralManagerProtocol: PeripheralManagerBaseProtocol, DisposableProtocol {
    
    associatedtype TPeripheral: ManagedPeripheralProtocol
    
    //MARK: Properties
    /**
     A list of visible Bluetooth LE peripherals. The list is updated when a new peripheral is found or when a peripheral is not seen until the InvisibleTimout. Register for an update event with
     */
    var peripherals: [TPeripheral] { get }
    
    //MARK: Functions    
    /**
     Try add peripheral to the list, if it don't already exist in the list invoke eventPeripheralAdded
     
     - throws:
        BleLibraryError.objectDisposedError
     */
    func add(peripheral: TPeripheral)throws
    
    /**
     Clear the peripheral list
     
     - throws:
        BleLibraryError.objectDisposedError
     */
    func clear() throws
    
    /**
     Remove a specified peripehral from the peripheral list
     
     - parameters:
        - peripheral: the peripheral to remove of type TPeripheral
     
     - trows:
        BleLibraryError.objectDisposedError
     */
    func remove(peripheral: TPeripheral)throws
    
    /**
     Removes an aray of peripehrals from the peripehral list
     
     - parammeters:
        - peripheralsToRemove: list of peripehrals that shall be removed [TPeripheral]
     
     - throws:
        BleLibraryError.objectDisposedError
     */
    func remove(peripheralsToRemove: [TPeripheral])throws
    
    /**
     Find if peripehral exists in the peripehral list
     
     - parameters:
     - uuid: UUID of the new peripheral
     
     - returns:
     TPeripheral if found else nil
     */
    func find(uuid: UUID)throws -> TPeripheral?
    
    /**
    Control if its posible to remove peripheral
    When not overriden returns allways true
    
    - parameters:
    - peripheral: TPeripheral to remove
    
    - return:
        true if posible
    */
    func canRemove(peripheral: TPeripheral) -> Bool
    
    //MARK: Events
    /**
     Event triggered, when peripheral is added
     */
    var eventPeripheralAdded: Event<PeripheralAddedEventArgs<TPeripheral>> { get }
    /**
     Event triggered, when peripehral is removed
     */
    var eventPeripheralRemoved: Event<PeripheralRemovedEventArgs<TPeripheral>>{ get }
}
