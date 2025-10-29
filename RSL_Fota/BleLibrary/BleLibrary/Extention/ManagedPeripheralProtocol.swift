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
 * Class Name: ManagedPeripheralProtocol.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public protocol  ManagedPeripheralProtocol: BasePeripheralProtocol{

    /**
     Get / set the used standard peripheral object.
     
     The standard peripheral object must only be set to a new instance if not yet set (virtual peripheral)
     If already a peripheral is defined the peripheral object may not be changed
     */
    var peripheral: PeripheralProtocol? { get }
    func setPeripheral(peripheral: PeripheralProtocol)throws

    /**
     Get the UUID uniquely identifying an peripheral
     */
    var uuid: UUID { get }

    /**
     Get the name of the enchanced peripheral
     */
    var name: String { get }

    /**
     Set the name of the enchanged peripheral
     */
    func setName(name: String)throws

    /**
     Get the last set RSSI value. The returned value was update when the peripheral was last seen.
     */
    var rssi: Int { get }

    /**
     Set the last RSSI value
     */
    func setRssi(rssi: Int)throws

    /**
     Is the device is connectable or not
     */
    var isConnectable: Bool { get }

    /**
     Set isConnectable
     */
    func setIsConnectable(isConnectable: Bool)throws

    /**
     Time the peripheral was last seen
     */
    var lastSeen: Date { get set }

    /**
     * Check if the peripheral object is already disposed
     */
    var isDisposed: Bool { get }
    
    //MARK: Events
    
    /**
     Standard peripheral object of the peripheral has been set
     
     This may only occur if the peripheral was created as virtual peripheral. This
     event is triggered, when the peripheral is set later and the peripheral becomes
     a real peripheral behind.
     
     This event will only be triggered once as the standard peripheral may only be set once.
     */
    var eventPeripheralUpdated: Event<EmptyEventArgs>{get}
    
    /**
     Name of the peripheral has changed
     */
    var eventNameUpdated: Event<NameUpdatedEventArgs>{get}
    
    /**
     RSSI level of the peripheral has changed
     */
    var eventRssiUpdated: Event<RssiUpdatedEventArgs>{get}
    
    /**
     Property if the peripheral may be connected has been updated
     */
    var eventIsConnectableUpdated: Event<IsConnectableUpdatedEventArgs>{get}
}
