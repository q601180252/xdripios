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
 * Class Name: TaskCharacteristicWrite.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
import UIKit
import os.log
class TaskCharacteristicWrite: TaskCharacteristic, CBPeripheralDelegate
{
    //MARK: Properties
    var value: Data
    var _writeWithoutResponse: Bool
    
    override var description: String
    {
        return "Write characteristic (Device:\(peripheral.uuid.uuidString) UUID:{\(characteristic.uuid.uuidString)} Value:{0x\(BinaryString.toString(buffer: value.toArray()))}"
    }
    
    //MARK: members
    private var _cbPeripheral: CBPeripheral?
    private var _cbCharacteristic: CBCharacteristic?
    private var _useiOS11Features: Bool
    private var _propertCompletedLock = DispatchQueue(label: "ch.arendi.bleLibrary.TaskCharacteristicWrite.lock")
    private var _propertyCompleted: Bool
    
//    private let log: LogProtocol = LogManager.manager.getLog(name: "TaskCharacteristicWrite")
    
    //MARK: eventhandlers
    private var _myDisconnectedPeripheralHandler: EventHandlerProtocol?
    private var _isReadyToSendWriteWithoutResponseHandler: EventHandlerProtocol?
    private var _wroteCharacteristicValueHandler: EventHandlerProtocol?
    
    
    init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol, _ characteristic: Characteristic, _ data: Data, _ writeWithoutResponse: Bool, _ timeout: Int)
    {
        self._propertyCompleted = false
        self.value = data
        self._writeWithoutResponse = writeWithoutResponse
        self._useiOS11Features = UIDevice.current.systemVersion.compare("11.0", options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
        super.init(peripheral, manager, characteristic, timeout)
    }
    
    override func start() {
        
        // peripheral not connected?
        guard  peripheral.isConnected else {
            completed(result: BleResult.notConnected)
            return;
        }
        
        // set peripheral and characteristic to use for this task
        _cbPeripheral = peripheral.cbPeripheral
        _cbCharacteristic = characteristic.cbCharacteristic
        
        //attach result event
        registerEvents()
        
        // determine write type
        let writeType = (_writeWithoutResponse) ? CBCharacteristicWriteType.withoutResponse : CBCharacteristicWriteType.withResponse
        
        //write data to the peripheral
        var writeCompleted = writeType == CBCharacteristicWriteType.withoutResponse
        
        if #available(iOS 11.0, *)
        {
            // CanSendWriteWithoutResponse returns sometimes false for a fresh connected peripheral.
            // Because the task manager executes one task after another,
            // it's save to call cbPeripheral.WriteValue even if CanSendWithoutResponse is false the first time
            writeCompleted = writeCompleted && (_cbPeripheral?.canSendWriteWithoutResponse)!
            
        }
        
        // Execute write
        peripheral.cbPeripheral?.writeValue(value, for: _cbCharacteristic!, type: writeType)
        

        // write without response completed?
        if(writeCompleted)
        {
            var finished = true
            _propertCompletedLock.sync {
                if _propertyCompleted
                {
                    finished = false
                }
                _propertyCompleted = true
            }
            if finished{
                completed(result: BleResult.success)
            }
        }
    }
    
    //MARK: CBPeripheralDelegates
    func onIsReadyToSendWriteWithoutResponse(args: EmptyEventArgs) {
        var finished = true
        _propertCompletedLock.sync {
            if _propertyCompleted
            {
                finished = false
            }
            _propertyCompleted = true
        }
        if finished{
            completed(result: BleResult.success)
        }
    }
    
    func onWroteCharacteristicValue(args: CBCharacteristicEventArgs) {
        
        // characteristic mismatch
        guard args.characteristic == _cbCharacteristic else {
            return
        }

        //failure
        guard args.error == nil else {
            log.error("Failed to write characteristic (\(args.error!.localizedDescription))")
            return
        }
        
        // success
        completed(result: BleResult.success)
    }
    
    //MARK: Events
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
        //detach result events
        deregisterEvents()
        
        super.cleanup()
    }
    
    //MARK: Private functions
    private func registerEvents()
    {
        //Central events
        _myDisconnectedPeripheralHandler = manager.eventMyDisconnectedPeripheral.addHandler(self, TaskCharacteristicWrite.onDisconnectedPeripheral)
        _wroteCharacteristicValueHandler = peripheral.eventWroteCharacteristicValue.addHandler(self, TaskCharacteristicWrite.onWroteCharacteristicValue)
        
        if #available(iOS 11.0, *){
            _isReadyToSendWriteWithoutResponseHandler = peripheral.eventIsReadyToSendWriteWithoutResponse.addHandler(self, TaskCharacteristicWrite.onIsReadyToSendWriteWithoutResponse)
        }
        
    }
    
    private func deregisterEvents()
    {
        _myDisconnectedPeripheralHandler?.dispose()
        _wroteCharacteristicValueHandler?.dispose()
        _isReadyToSendWriteWithoutResponseHandler?.dispose()
    }
}
