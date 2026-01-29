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
 * Class Name: TaskDiscoverServices.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
class TaskDiscoverServices: TaskPeripheral
{
    
    //MARK: properties
    var services: [Service]
    {
        return _services
    }
    
    override var description: String
    {
        return "Discover Services (Device:\(peripheral.uuid.uuidString))"
    }
    
    //MARK: members
    private var _currentServiceIndex: Int
    private var _cbPeripheral: CBPeripheral?
    private var _services: [Service]
//    private let log: LogProtocol = LogManager.manager.getLog(name: "TaskDiscoverServices")
    
    //MARK: eventhandlers
    private var _myDisconnectedPeripheralHandler: EventHandlerProtocol?
    private var _discoverServiceHandler: EventHandlerProtocol?
    private var _discoverCharacteristicHandler: EventHandlerProtocol?
    
    //MARK: initialization
    override init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol, _ timeout: Int)
    {
        self._services = [Service]()
        self._currentServiceIndex = 0
        super.init(peripheral, manager, timeout)
    }
    
    //MARK: func
    override func start() {
        guard peripheral.isConnected else {
            completed(result: BleResult.notConnected)
            return
        }
        
        //set peripheral to use for this task
        _cbPeripheral = peripheral.cbPeripheral
        
        // attach result events
        registerEvents()
        
        // start service discovery
        peripheral.cbPeripheral?.discoverServices(nil)
    }
    
    override func cleanup() {
        // detach result event
        deregisterEvents()
        
        super.cleanup()
    }
    
    //MARK: peripheralDelegate
    func onDiscoverServices(args: CBServiceDiscoveredEventArgs) {
        //failed?
        guard args.error == nil else {
            log.error("Faild to discover services \(args.error.debugDescription)")
            completed(result: BleResult.failure)
            return
        }
        
        //prepare characteristic discover
        _currentServiceIndex = 0
        _cbPeripheral?.discoverCharacteristics([CBUUID](), for: (_cbPeripheral?.services![0])!)
    }
    
    func onDiscoverCharacteristics(args: CBCharacteristicDiscoveredEventArgs) {
        //faild?
        guard args.error == nil else
        {
            log.error("Faild to discover characteristics \(args.error.debugDescription)")
            completed(result: BleResult.failure)
            return
        }

        log.debug("Found characteristics: \(args.service.characteristics?.description) for service: \(services.description)")

        // discover all characteristics first
        if discoverNextCharacteristic()
        {
            return;
        }

        // add all CBServices to the internal service list
        _services.removeAll()
        for s in (_cbPeripheral?.services)!
        {
//            log.debug("----- Found characteristics: \(String(describing: s.characteristics?.description)) for service: \(s.description)")
            _services.append(Service(peripheral: self.peripheral,  service: s))
        }

        log.debug(" Found services: \(_services.description)")

        //success
        completed(result: BleResult.success)
    }
    
    //MARK: Events
    func onDisconnectedPeripheral(args: CBPeripheralErrorEventArgs)
    {
        // peripheral mismatch ?
        guard peripheral == _cbPeripheral else {
            return
        }
        
        // connection lost
        completed(result: BleResult.connectionLost)
    }
    
    //MARK: private func
    private func discoverNextCharacteristic() -> Bool
    {
        if (_currentServiceIndex + 1) < (_cbPeripheral?.services?.count)!
        {
            _currentServiceIndex += 1
            _cbPeripheral?.discoverCharacteristics([CBUUID](), for: (_cbPeripheral?.services![_currentServiceIndex])!)
            return true
        }
        
        return false
    }
    
    private func registerEvents()
    {
        _myDisconnectedPeripheralHandler = self.manager.eventMyDisconnectedPeripheral.addHandler(self, TaskDiscoverServices.onDisconnectedPeripheral)
        _discoverServiceHandler = peripheral.eventServiceDiscovered.addHandler(self, TaskDiscoverServices.onDiscoverServices)
        _discoverCharacteristicHandler = peripheral.eventCharacteristicDiscovered.addHandler(self, TaskDiscoverServices.onDiscoverCharacteristics)
    }
    
    private func deregisterEvents()
    {
        _myDisconnectedPeripheralHandler?.dispose()
        _discoverServiceHandler?.dispose()
        _discoverCharacteristicHandler?.dispose()
    }
    
}
