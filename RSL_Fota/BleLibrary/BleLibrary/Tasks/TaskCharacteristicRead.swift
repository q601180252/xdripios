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
 * Class Name: TaskCharacteristicRead.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
class TaskCharacteristicRead: TaskCharacteristic, CBPeripheralDelegate
{
   
    //MARK: properties
    var value: Data
    {
        return _value ?? Data()
    }
    
    override var description: String
    {
        return "Read characteristic (Device:\(peripheral.uuid.uuidString), UUID:\(characteristic.uuid.uuidString)"
    }
    
    //MARK: members
    private var _cbPeripheral: CBPeripheral?
    private var _cbCharacteristic: CBCharacteristic?
    
    private var _value: Data?
    
    //MARK: eventhandlers
    private var _myDisconnectedPeripheralHandler: EventHandlerProtocol?
    private var _updatedCharacteristicValueHandler: EventHandlerProtocol?
    
    override init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol, _ characteristic: Characteristic, _ timeout: Int)
    {
        super.init(peripheral, manager, characteristic, timeout)
    }
    
    //MARK: override
    override func start() {
        
        //peripheral not connected?
        guard peripheral.isConnected else {
            completed(result: BleResult.notConnected)
            return;
        }
        
        //set peripheral and characteristic to use for this task
        _cbPeripheral = peripheral.cbPeripheral
        _cbCharacteristic = characteristic.cbCharacteristic
        
        //attach result event
        registerEvents()
        
        // initiate read operation
        peripheral.cbPeripheral!.readValue(for: _cbCharacteristic!)
    }
    
    //MARK: Events
    func onUpdatedCharacterteristicValue(args: CBCharacteristicEventArgs)
    {
        // characteristic mismatch?
        guard args.characteristic == self._cbCharacteristic else {
            return
        }
        
        //failur
        guard args.error == nil else {
            log.error("Failed to read characteristic \(args.error.debugDescription)")
            completed(result: BleResult.failure)
            return
        }
        
        //get value
        if(args.characteristic.value != nil && (args.characteristic.value?.count)! > 0)
        {
            _value = args.characteristic.value
        }
        else
        {
            _value = Data()
        }
    
        //success
        completed(result: BleResult.success)
    }
    
    
    func onDisconnectedPeripheral(args: CBPeripheralErrorEventArgs)
    {
        // peripheral mismatch ?
        guard args.peripheral == _cbPeripheral else {
            return
        }
        
        // connection lost
        completed(result: BleResult.connectionLost)
    }
    
    override func cleanup() {
        //detach resutl events
        deregisterEvents()
    }
    
    //MARK: Private functions
    private func registerEvents()
    {
        _myDisconnectedPeripheralHandler = manager.eventMyDisconnectedPeripheral.addHandler(self, TaskCharacteristicRead.onDisconnectedPeripheral)
        _updatedCharacteristicValueHandler = peripheral.eventUpdatedCharacterteristicValue.addHandler(self, TaskCharacteristicRead.onUpdatedCharacterteristicValue)
    }
    
    private func deregisterEvents()
    {
        _myDisconnectedPeripheralHandler?.dispose()
        _updatedCharacteristicValueHandler?.dispose()
    }
}
