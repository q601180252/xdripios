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
 * Class Name: Characteristic.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth

public class Characteristic: NSObject, CharacteristicsProtocol, CBPeripheralDelegate
{
    //MARK: Events
    public var eventNotificationReceived =  Event<NotificationReceivedEventArgs>()
    public var eventIndicationRecieved = Event<IndicationReceivedEventArgs>()
    
    //MARK: Properties
    /**
     Get teh UUID identifying the characteristic
     */
    public var uuid: CBUUID
    {
        return _uuid
    }
    
    /**
     Get the local value of the characteristic
     */
    public var value: Data
    {
        if (cbCharacteristic.value != nil) && (cbCharacteristic.value?.count != 0)
        {
            return cbCharacteristic.value!
        }
        return Data()
    }
    
    /**
     Get the permissions associated with the characteristic
     */
    public var permission: UInt
    {
        return _permission
    }
    
    /**
     Get the properties associated with the characteristic
     */
    public var property: UInt
    {
        return _property
    }
    
    /**
     Get the current peripheral
     */
    public var myPeripheral: PeripheralBase
    {
        return _myPeripheral
    }
    
    /**
     Return the description of this characteristic
     */
    public override var description: String
    {
        return "UUID:\(_uuid.uuidString)"
    }
    
    /**
     Get CBCharacteristic
     */
    var cbCharacteristic: CBCharacteristic
    {
        return _cbCharacteristic
    }
    
    //MARK: members
    private var _uuid: CBUUID
    private var _permission: UInt
    private var _property: UInt
    private var _myPeripheral: PeripheralBase
    private var _readTaskStarted: Bool
    private var _cbPeripheral: CBPeripheral?
    private var _cbCharacteristic: CBCharacteristic
    private let log: LogProtocol
    
    //MARK: Eventhandlers
    private var _taskStartedHandler: EventHandlerProtocol?
    private var _taskCompletedHandler: EventHandlerProtocol?
    private var _updatedCharacterteristicValueHandler: EventHandlerProtocol?
    
    init(peripheral: PeripheralBase, characteristic: CBCharacteristic)
    {
        // create log
        log = LogManager.manager.createLog(name: "Arendi.BleLibrary.iOS.Service.Characteristic [\(characteristic.uuid.uuidString)]")
        
        //initialize members
        _readTaskStarted = false
        _myPeripheral = peripheral
        _uuid = characteristic.uuid
        _permission = CharacteristicPermissions.readable.rawValue | CharacteristicPermissions.writeable.rawValue
        _property = CBCharacteristicProperties.read.rawValue | CBCharacteristicProperties.write.rawValue
        
        // store CB objects
        _cbPeripheral = peripheral.cbPeripheral
        _cbCharacteristic = characteristic
        
        super.init()
        
        //Update characteristic properties
        updateProperty(cbProperties: characteristic.properties)
        
        //RegisterCharacteristicEvents
        registerEvents()
    }
    
    /**
     Called by the derived class to trigger the event (NotificationReceived)
     */
    func onNotificationReceived(args: NotificationReceivedEventArgs)
    {
        eventNotificationReceived.raise(data: NotificationReceivedEventArgs(data: args.data))
    }
    
    /**
     Called by the derived class to trigger the event (IndicationRecived)
     */
    func onIndicationReceived(args: IndicationReceivedEventArgs)
    {
        eventIndicationRecieved.raise(data: IndicationReceivedEventArgs(data: args.data))
    }
    
    public func readData(_ timeout: Int) throws -> Data {
        // is the peripheral connected
        guard myPeripheral.isConnected else
        {
            log.error("Read from peripheral failed, not connected")
            throw BleLibraryError.notConnectedError(message: "Read from peripheral failed, not connected", result: BleResult.notConnected)
        }
        
        // read supported by characteristic
        guard _property & CBCharacteristicProperties.read.rawValue != 0 else
        {
            log.error("Read from peripheral failed, not supported by characteristic")
            throw BleLibraryError.notSupportedError(message: "Read from peripheral failed, not supported by characteristic", result: BleResult.notSupported)
        }
        
        do
        {
            // call specific implementation
            let data = try readDataImpl(timeout)
            log.info("Characteristic read (Uuid: \(_uuid.uuidString) Data:0x\(BinaryString.toString(buffer: data.toArray()))")
            return data
        }
        catch
        {
            log.error("Characteristic read failed: (Uuid: \(_uuid.uuidString) \(error)")
            throw error
        }
    }
    
    public func writeData(_ data: Data,_ writeType: WriteType, _ timeout: Int) throws {
        
        var myWriteType = writeType
        
        // is the peripheral connected
        guard myPeripheral.isConnected else
        {
            log.error("Read from peripheral failed, not connected")
            throw BleLibraryError.notConnectedError(message: "Read from peripheral failed, not connected", result: BleResult.notConnected)
        }
        
        //Handle write type
        if (myWriteType == WriteType.general || myWriteType == WriteType.request) && ((_property & CBCharacteristicProperties.write.rawValue) != 0)
        {
            myWriteType = WriteType.request
        }
        else if (myWriteType == WriteType.general || myWriteType == WriteType.command) && ((_property & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0)
        {
            myWriteType = WriteType.command
        }
        else
        {
            log.error("Write to peripheral failed, not supported by characteristic")
            throw BleLibraryError.notSupportedError(message: "Write to peripheral failed, not supported by characteristic", result: BleResult.notSupported)
        }
        
        // call specific implementation
        do
        {
            try writeDataImpl(data, myWriteType, timeout)
            log.info("Characteristic write (Uuid: \(_uuid.uuidString) Data:0x\(BinaryString.toString(buffer: data.toArray()))")
        }
        catch
        {
            log.error("Characteristic write failed (Uuid:\(_uuid.uuidString) Data:0x\(BinaryString.toString(buffer: data.toArray())) \(error)")
            throw error
        }
        
    }
    
    public func changeNotification(_ enable: Bool, _ timeout: Int) throws {
        // is the peripheral connected
        guard myPeripheral.isConnected else
        {
            log.error("Read from peripheral failed, not connected")
            throw BleLibraryError.notConnectedError(message: "Read from peripheral failed, not connected", result: BleResult.notConnected)
        }
        
        // notify supported by characteristic
        guard (_property & CBCharacteristicProperties.notify.rawValue != 0) || (_property & CBCharacteristicProperties.notifyEncryptionRequired.rawValue != 0)
            else {
            log.error("Change of notification failed, not supported by characteristic")
            throw BleLibraryError.notSupportedError(message: "Change of notification failed, not supported by characteristic", result: BleResult.notSupported)
        }
        
        // call specific implementation
        do
        {
            try changeNotificationImpl(enable, timeout)
            log.info("Notification enabled: \(enable) (Uuid:\(_uuid.uuidString)")
        }
        catch
        {
            log.error("Notification enabled: \(enable) failed (Uuid:\(_uuid.uuidString) \(error)")
            throw error
        }
        
    }
    
    public func changeIndication(_ enable: Bool, _ timeout: Int) throws {
        // is the peripheral connected
        guard myPeripheral.isConnected else
        {
            log.error("Read from peripheral failed, not connected")
            throw BleLibraryError.notConnectedError(message: "Read from peripheral failed, not connected", result: BleResult.notConnected)
        }
        
        // notify supported by characteristic
        guard (_property & CBCharacteristicProperties.indicate.rawValue != 0) || (_property & CBCharacteristicProperties.indicateEncryptionRequired.rawValue != 0)
            else {
                log.error("Change of notification failed, not supported by characteristic")
                throw BleLibraryError.notSupportedError(message: "Change of notification failed, not supported by characteristic", result: BleResult.notSupported)
        }
        
        do
        {
            try changeIndicationImpl(enable, timeout)
            log.info("Indication enable: \(enable) (Uuid:\(_uuid.uuidString)")
        }
        catch
        {
            log.info("Indication enable: \(enable) failed (Uuid:\(_uuid.uuidString) \(error)")
            throw error
        }
    }
    
    //MARK: Implementations
    func readDataImpl(_ timeout: Int) throws -> Data
    {
        // create and run task
        let task = TaskCharacteristicRead(myPeripheral, myPeripheral.peripheralManager!, self, timeout)
        try myPeripheral.taskController.run(task: task)
        
        // return data
        return task.value
    }
    
    func writeDataImpl(_ data: Data, _ writeType: WriteType, _ timeout: Int ) throws
    {
        // create and run task
        let task = TaskCharacteristicWrite(myPeripheral, myPeripheral.peripheralManager!, self, data, writeType == WriteType.command , timeout)
        try myPeripheral.taskController.run(task: task)
    }
    
    func changeNotificationImpl(_ enabled: Bool, _ timeout: Int) throws
    {
        // create task and run
        let task = TaskCharacteristicChangeNotification(myPeripheral, myPeripheral.peripheralManager!, self, enabled, timeout)
        try myPeripheral.taskController.run(task: task)
    }
    
    func changeIndicationImpl(_ enabled: Bool, _ timeout: Int) throws
    {
        // create and run task
        let task = TaskCharacteristicChangeIndication(myPeripheral, myPeripheral.peripheralManager!, self, enabled, timeout)
        try myPeripheral.taskController.run(task: task)
    }
    
    private func onUpdatedCharacterteristicValue(args: CBCharacteristicEventArgs)
    {
        // characteristic match?
        guard args.characteristic.uuid == self.uuid else {
            return
        }
        
        // if no read operation is started it is a notify or indication
        if !_readTaskStarted
        {
            if (_property & CBCharacteristicProperties.notify.rawValue) != 0 || (_property & CBCharacteristicProperties.notifyEncryptionRequired.rawValue) != 0
            {
                // received notification
                log.info("Notification received (Uuid:\(_uuid.uuidString) Value:\(BinaryString.toString(buffer: args.characteristic.value?.toArray() ?? [UInt8]()))")
                
                // trigger event
                onNotificationReceived(args: NotificationReceivedEventArgs(data: args.characteristic.value ?? Data()))
            }
            
            if (_property & CBCharacteristicProperties.indicate.rawValue) != 0 || (_property & CBCharacteristicProperties.indicateEncryptionRequired.rawValue) != 0
            {
                // received indication
                log.info("Indication received (Uuid:\(_uuid.uuidString) Value:\(BinaryString.toString(buffer: args.characteristic.value?.toArray() ?? [UInt8]()))")
                
                // triger event
                onIndicationReceived(args: IndicationReceivedEventArgs(data: args.characteristic.value ?? Data()))
            }
        }
    }
    
    //MARK: Private functions
    private func onTaskStarted(args: TaskStartedEventArgs)
    {
        // characteristic read completed
        let taskCharacteristicRead = args.task as? TaskCharacteristicRead
        if taskCharacteristicRead != nil
        {
            // characteristic match
            if taskCharacteristicRead!.characteristic == self
            {
                // read operation started
                _readTaskStarted = true
            }
        }
    }

    private func onTaskCompleted(args: TaskCompletedEventArgs)
    {
        // characteristic read completed
        let taskCharacteristicRead = args.task as? TaskCharacteristicRead
        if taskCharacteristicRead != nil
        {
            // characteristic match
            if taskCharacteristicRead!.characteristic == self
            {
                // read operation completed
                _readTaskStarted = false
                
                // log
                if args.result != BleResult.success
                {
                    log.error("Data read failed for characteristic \(_uuid.uuidString) (Result:\(args.result)")
                }
            }
        }
        
        // characteristic write completed
        let taskCharacteristicWrite = args.task as? TaskCharacteristicWrite
        if taskCharacteristicWrite != nil
        {
            // characteristic match?
            if taskCharacteristicWrite!.characteristic == self
            {
                // log
                if args.result != BleResult.success
                {
                    log.error("Data write failed for characteristic \(_uuid.uuidString) (Result:\(args.result)")
                }
            }
        }
        
        // characteristic change notification completed
        let taskCharacteristicChangeNotification = args.task as? TaskCharacteristicChangeNotification
        if taskCharacteristicChangeNotification != nil
        {
            // characterisc match?
            if taskCharacteristicChangeNotification!.characteristic == self
            {
                // log
                if args.result != BleResult.success
                {
                    log.error("Change notification failed for \(_uuid.uuidString) (Result:\(args.result)")
                }
            }
        }
        
        // characteristic change indication completed
        let taskCharacteristicChangeIndication = args.task as? TaskCharacteristicChangeIndication
        if taskCharacteristicChangeIndication != nil
        {
            // characteristic match?
            if taskCharacteristicChangeIndication == self
            {
                // log
                if args.result != BleResult.success
                {
                    log.error("Change indication failed for characteristic \(_uuid.uuidString) (Result:\(args.result)")
                }
            }
        }
    }
    
    private func updateProperty(cbProperties: CBCharacteristicProperties)
    {
        _property = cbProperties.rawValue
    }
    
    private func registerEvents()
    {
        _taskStartedHandler = myPeripheral.taskController.eventTaskStarted.addHandler(self, Characteristic.onTaskStarted)
        _taskCompletedHandler = myPeripheral.taskController.eventTaskCompleted.addHandler(self, Characteristic.onTaskCompleted)
        _updatedCharacterteristicValueHandler = myPeripheral.eventUpdatedCharacterteristicValue.addHandler(self, Characteristic.onUpdatedCharacterteristicValue)
    }
    
    private func deregisterEvents()
    {
        _taskStartedHandler?.dispose()
        _taskCompletedHandler?.dispose()
        _updatedCharacterteristicValueHandler?.dispose()
    }
    
    //MARK: Dispose
    public func dispose() {
        deregisterEvents()
    }
}
