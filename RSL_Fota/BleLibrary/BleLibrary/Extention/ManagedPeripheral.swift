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
 * Class Name: ManagerPeripheral.swift
 ******************************************************************************/

import Foundation
import os.log
import CoreBluetooth
open class ManagedPeripheral : ManagedPeripheralProtocol
{
    
    //MARK: Constants
    
    /**
     * RSSI vaue that indicates, that no value is known
     */
    public var rssiNotAvailable = Int.min
    
    /**
     * This text is used as object disposed exception messaged
     */
    public let peripheralDisposedErrorText = "The peripheral was already disposed by the peripheral manager. \nOverride the method \"bool CheckRemove()\" to prevent that a peripheral in use is removed by the peripheral manager";
    
    //MARK: Members
    private var _peripheral: PeripheralProtocol?
    private var _name: String
    private var _rssi: Int
    private var _isConnectable: Bool
    private var _uuid: UUID
    
    /**
     * Indicates if the object is already disposed or not
     */
    var _isDisposed = false

    //MARK: Properties
    public var peripheral: PeripheralProtocol?
    {
        get { return _peripheral }
    }
    
    public var uuid: UUID
    {
        get { return _uuid }
    }
    
    public var name: String
    {
        get { return _name }
    }
    
    public var rssi: Int
    {
        get { return _rssi }
    }
    
    public var isConnectable: Bool
    {
        get { return _isConnectable }
    }
    
    public var lastSeen: Date
    
    public var isDisposed: Bool { return _isDisposed }
    
    public var description: String
    {
        return "ManagedPeripheral: - "
    }
    
    //MARK: Events
    public var eventPeripheralUpdated = Event<EmptyEventArgs>()
    
    public var eventNameUpdated = Event<NameUpdatedEventArgs>()
    
    public var eventRssiUpdated = Event<RssiUpdatedEventArgs>()
    
    public var eventIsConnectableUpdated = Event<IsConnectableUpdatedEventArgs>()
    
    //MARK: Initializer
    /**
     Create a virtual managed peripheral with a specific UUID if the real peripheral is not know. A connection to this peripheral can not be established until the peripheral is found by the (see PeripheralManager<TPeripheral>)
     
     - parameters:
        - UUID: The UUID of the virtual peripheral
     */
    public init(uuid: UUID)
    {
        // set information
        _name = "?"
        _uuid = uuid
        
        // reset information
        _rssi = rssiNotAvailable
        _isConnectable = false
        lastSeen = Date.init(timeIntervalSince1970: 0)
    }
    
    /**
     Create a managed peripheral with a peripheral object
     
     - parameters:
        - peripheral: An instance to a real peripheral
     */
    init(peripheral: PeripheralProtocol)throws
    {
        // get periipheral information
        _uuid = peripheral.uuid
        if peripheral.name == nil
        {
            _name = "?"
        }
        else
        {
            _name = peripheral.name!
        }
        
        // set peripheral (this also starts the peripheral thread)
        self._peripheral = peripheral
        
        // reset information
        _rssi = rssiNotAvailable
        _isConnectable = false
        lastSeen = Date.init(timeIntervalSince1970: 0)
    }
    
    //MARK: Methods
    public func setPeripheral(peripheral: PeripheralProtocol)throws
    {
        // check if peripheral is not yet disposed
        try checkDisposed()
        
        if _peripheral != nil {
            // set the equal peripheral ?
            if _peripheral!.equal(other: peripheral) { return }
            
            // check if already a peripheral was set
            if _peripheral != nil { throw BleLibraryError.illegalArgument(message: "Peripheral object may not be changed if onec defined") }
        }
        
        // log the assigned peripheral object
        os_log("ManagedPeripheral: %@", log: .default, type: .debug, "\(description) - Peripheral object assigned" )
        
        //set peripheral
        _peripheral = peripheral
        
        // triger peripehral update
        eventPeripheralUpdated.raise(data: EmptyEventArgs())
    }
    
    public func setName(name: String)throws
    {
        // Check if peripheral is not yet disposed
        try checkDisposed()
        
        if _name != name
        {
            _name = name
            eventNameUpdated.raise(data: NameUpdatedEventArgs(name: _name))
        }
    }
    
    public func setRssi(rssi: Int)throws
    {
        // check if peripheral is not yet disposed
        try checkDisposed()
        
        if _rssi != rssi
        {
            _rssi = rssi
            eventRssiUpdated.raise(data: RssiUpdatedEventArgs(rssi: _rssi))
        }
    }
    
    public func setIsConnectable(isConnectable: Bool) throws {
        // Check if peripheral is not yet disposed
        try checkDisposed()
        
        if _isConnectable != isConnectable
        {
            _isConnectable = isConnectable
            eventIsConnectableUpdated.raise(data: IsConnectableUpdatedEventArgs(isConnectable: _isConnectable))
        }
    }
    
    public func dispose() {
        
        // mark object as disposed
        _isDisposed = true
        
        if _peripheral != nil
        {
            // dipose peripheral object
            _peripheral!.dispose()
            _peripheral = nil
        }
    }
    
    private func checkDisposed()throws
    {
        if isDisposed
        {
            throw BleLibraryError.objectDisposedError(objectName: peripheralDisposedErrorText)
        }
    }
}
