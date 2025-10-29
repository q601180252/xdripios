/*
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
 * Class Name: FotaPeripheralManager.swift
 */

import BleLibrary
import Foundation
import CoreBluetooth

class FotaPeripheralManager: ExtendedPeripheralManager<FotaPeripheral>
{
    //MARK: events
    public var eventBleProductListChanged = Event<EmptyEventArgs>()
    
    //MARK: eventhandlers
    private var _peripheralAddedHandler: EventHandlerProtocol?
    private var _peripheralRemovedHandler: EventHandlerProtocol?
    
    //MARK: properties
    public var bleProductList: [FotaPeripheral] { return peripherals }
    public var selected: FotaPeripheral?
    {
        get { return _selected }
        set
        {
                _selected = newValue
                log.debug("Selected peripheral: \(selected?.description)")
        }
    }
    
    var _selected: FotaPeripheral?
    
    public init(_ checkBtEnabled: Bool)
    {
        _selected = nil
        
        super.init(checkBtEnabled, createPeripheralFunction: {p,r  in return try FotaPeripheral(peripheral: p)})
        registerEvents()
    }
    
    //MARK: override functions
    override open func canRemove(peripheral: FotaPeripheral) -> Bool {
        return !(peripheral.uuid.uuidString == selected?.uuid.uuidString)
    }
    
    override open func invokePeripheralDiscovered(peripheral: PeripheralBase, connectable: Bool) {
        peripheral.peripheralManager = self
        
        eventBleProductListChanged.raise(data: EmptyEventArgs())
        
        super.invokePeripheralDiscovered(peripheral: peripheral, connectable: connectable)
    }
    
    override open func invokePeripheralConnected(peripheral: CBPeripheral)
    {

        do
        {
//            if let p = try  find(uuid: peripheral.identifier)
//            {
//                if (selected?.uuid.uuidString ?? "") != p.uuid.uuidString{
//                    selected = p
//                }
//            }

            super.invokePeripheralConnected(peripheral: peripheral)
        }
        catch
        {
            log.error("Error \(error)")
            return
        }
    }
    
    override open func dispose() {
        deregisterEvents()
        super.dispose()
    }
    
    //MARK: private functions
    private func registerEvents()
    {
        _peripheralAddedHandler = super.eventPeripheralAdded.addHandler(self, FotaPeripheralManager.onPeripheralAdded)
        _peripheralRemovedHandler = super.eventPeripheralRemoved.addHandler(self, FotaPeripheralManager.onPeripheralRemoved)
    }
    
    private func deregisterEvents()
    {
        _peripheralAddedHandler?.dispose()
        _peripheralRemovedHandler?.dispose()
    }
    
    private func onPeripheralAdded(args: PeripheralAddedEventArgs<FotaPeripheral>)
    {
        eventBleProductListChanged.raise(data: EmptyEventArgs())
    }
    
    private func onPeripheralRemoved(args: PeripheralRemovedEventArgs<FotaPeripheral>)
    {
        eventBleProductListChanged.raise(data: EmptyEventArgs())
    }
    
    
}
