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
 * Class Name: TaskCharacteristicChangeIndication.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
import os.log
class TaskCharacteristicChangeIndication: TaskCharacteristic
{
    //MARK: Property
    var enable: Bool
    
    override var description: String
    {
        return "Change Indication (Device:{\(peripheral.uuid.uuidString)} UUID:{\(characteristic.uuid.uuidString)} Enable:{\(enable)})"
    }
    
    //MARRK: Members
    private var _cbPeripheral: CBPeripheral?
    private var _cbCharacteristic: CBCharacteristic?
    
    //MARK: eventhandlers
    private var _myDisconnectedPeripheralHandler: EventHandlerProtocol?
    private var _onUpdateNotificationStateHandler: EventHandlerProtocol?
    
    init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol, _ characteristic: Characteristic, _ enable: Bool, _ timeout: Int)
    {
        self.enable = enable
        super.init(peripheral, manager, characteristic, timeout)
    }
    
    override func start()
    {
        // peripheral not connected ?
        guard peripheral.isConnected else
        {
            completed(result: BleResult.notConnected)
            return
        }
        
        // set peripheral and characteristic to use for this task
        _cbPeripheral = peripheral.cbPeripheral
        _cbCharacteristic = characteristic.cbCharacteristic
        
        // attach delegates
        registerEvents()
       
        // start operation
        peripheral.cbPeripheral?.setNotifyValue(enable, for: _cbCharacteristic!)
    }
    
    //MARK: PeripheralDelegate
    func onUpdateNotificationState(args: CBCharacteristicEventArgs) {
        // characteristic mismatch?
        guard args.characteristic == _cbCharacteristic else {
            return
        }
        
        guard args.error == nil else {
            log.error("Failed to change indication status (\(args.error.debugDescription))")
            completed(result: BleResult.failure)
            return
        }
                
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
    
    override func cleanup() {
        // detach result delegates
        deregisterEvents()
        
        super.cleanup()
    }
    
    //MARK: Private functions
    private func registerEvents()
    {
        _myDisconnectedPeripheralHandler = manager.eventMyDisconnectedPeripheral.addHandler(self, TaskCharacteristicChangeIndication.onDisconnectedPeripheral)
        _onUpdateNotificationStateHandler = peripheral.eventUpdatedNotificationState.addHandler(self, TaskCharacteristicChangeIndication.onUpdateNotificationState)
    
    }
    
    private func deregisterEvents()
    {
        _myDisconnectedPeripheralHandler?.dispose()
        _onUpdateNotificationStateHandler?.dispose()
    }
    
    
}
