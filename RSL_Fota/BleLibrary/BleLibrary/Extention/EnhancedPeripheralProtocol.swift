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
 * Class Name: EnhancedPeripheralProtocol.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public protocol EnhancedPeripheralProtocol: ManagedPeripheralProtocol
{
        
    //MARK: Properties
    /**
     Get the state of the peripheral
     */
    var state: PeripheralState { get }
    
    /**
     Set the state of the peripheral
     */
    func setState(newState: PeripheralState)throws
    
    /**
     Get / set the connect timeout [ms]. By default the value is set to (see Constants.connectTimeout)
     */
    var connectTimeout: Int { get set }
    
    /**
     Get / set the discover service timeout [ms]. By default the value is set to (see Constants.discoverServiceTimeout)
     */
    var discoverServiceTimeout: Int { get set }
    
    /**
     Get/ set the disconnect timeout [ms]. By default the value is set to (see Constants.disconnectTimeout)
     */
    var disconnectTimeout: Int { get set }
    
    /**
     Set the connection parameter that should be set in establish process (if supported by the adapter).
     If set to null (=> default) no connection parameter update is initiated in establish process.
     */
    var establishParameter: ParameterSet? { get set }
    
    //MARK: event
    /**
     State of the peripheral changed
     */
    var eventStateChanged: Event<StateChangedEventArgs> { get }
    
    /**
     Standard peripheral object of the peripheral has been set
     
     This may only occur if the peripheral was created as virtual peripheral. This event is triggered, when the peripheral is set later and the peripheral becomes a real peripheral behind.
     */
    var eventPeripheralUpdated: Event<EmptyEventArgs> { get }
    
    /**
     Name of the peripheral has changed
     */
    var eventNameUpdated: Event<NameUpdatedEventArgs> { get }
    
    /**
     RSSI level of the peripheral has changed
     */
    var eventRssiUpdated: Event<RssiUpdatedEventArgs> { get }
    
    /**
     Property if the peripheral may be connected has been updated
     */
    var eventIsConnectableUpdated: Event<IsConnectableUpdatedEventArgs> { get }
    
    /**
     Get the discription of the object
     */
    var description: String { get }
    
    /**
     Get / set the delegate of the object
     */
    var delegate: EnhancedPeripheralDelegate? { get set }
    
    
    //MARK: Methods
    
    /**
     Initiate the establishment of a connection. This is not allowed if peripiheral mode is set to (see PeripheralMode.inactive). This call is blocking
     */
    func establish()throws
    
    /**
     Initiate the teardown of a connection. This is not allowed if peripiheral mode is set to (see PeripheralMode.inactive). This call is blocking
     */
    func teardown()throws
    
    /**
     Start an update process. When the enchanged peripheral is in a stable state as (se PeripheralState.idle) or (see PeripheralState.ready) the update will be initiated immediately. In transition states the update will be initiated after completion of the state. This call is blocking
     
     - parameters:
        - updateSetup: Upadte setup to be used for the update
     */
    func update(updateSetup: UpdateSetup)throws
}


public protocol EnhancedPeripheralDelegate: AnyObject
{
    /**
     State of the peripheral changed
     */
    func enhancedPeripheral(_ peripheral: PeripheralBase, didChangeState oldState: PeripheralState, newState: PeripheralState )
    
    /**
     Standard peripheral object of the peripheral has been set.
     
     This may only occur if the peripheral was created as virtual peripheral. This event is triggered, when the peripheral is set later and the peripheral becomes a real peripheral behind.
     */
    func didUpdatePeripheral()
    
    /**
     Name of the peripheral has changed
     */
    func enhancedPeripiheral(_ peripheral: PeripheralBase, didUpdateName name: String)
    
    /**
     RSSI level of the peripheral has changed
     */
    func enhancedPeripiheral(_ peripheral: PeripheralBase, didUpdateRssi rssi: Int)
    
    /**
     Property if the peripheral may be connected has been updated
     */
    func didChangeIsConnectable(_ peripheral: PeripheralBase, didChangeIsConnectable isConnectable: Bool)
}

extension EnhancedPeripheralDelegate
{
    func enhancedPeripheral(_ peripheral: PeripheralBase, didChangeState oldState: PeripheralState, newState: PeripheralState ) {}
    func didUpdatePeripheral(){}
    func enhancedPeripiheral(_ peripheral: PeripheralBase, didUpdateName name: String){}
    func enhancedPeripiheral(_ peripheral: PeripheralBase, didUpdateRssi rssi: Int){}
    func didChangeIsConnectable(_ peripheral: PeripheralBase, didChangeIsConnectable isConnectable: Bool){}
}
