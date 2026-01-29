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
 * Class Name: TaskConnect.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
import os.log
class TaskConnect: TaskPeripheral {

    //MARK: properties
    var cbPeripheral: CBPeripheral?
    
    //MARK: members
//    private let log: LogProtocol = LogManager.manager.getLog(name: "TaskConnect")
    
    override var description: String
    {
        return "Connect (Device:\(peripheral.uuid.uuidString))"
    }
    
    //MARK: eventhandlers
    private var _myConnectedPeripheralHandler: EventHandlerProtocol?
    private var _myDisconnectPeripheralHandler: EventHandlerProtocol?
    private var _myFailedToConnectPeripheralHandler: EventHandlerProtocol?
    private var _bluetoothStateChanged: EventHandlerProtocol?
    
    //MARK: initialization
    init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol)
    {
        super.init(peripheral, manager, Constants.connectTimeout)
        self.cbPeripheral = nil
    }
    
    override init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol, _ timeout: Int)
    {
       super.init(peripheral, manager, timeout)
       self.cbPeripheral = nil
    }
    
    override func start() {
        
        guard manager.isBluetoothEnabled() else {
            completed(result: BleResult.bluetoothDisabled)
            return
        }
        
        guard !peripheral.isConnected else {
            completed(result: BleResult.connectionAlreadyEstablished)
            return
        }
        
        //attach events
        registerEvents()
        
        // retrive always a frech instance of the perpheral befor connecting
        cbPeripheral = retrievePeripheral(uuid: peripheral.uuid.uuidString)
        
        guard cbPeripheral != nil else{
            log.error("Unable to connect peripheral with UUID: \(peripheral.uuid.uuidString)")
            completed(result: BleResult.unabledToConnect)
            return
        }
        
        // check identifier
        guard cbPeripheral?.identifier != nil else {
            log.error("TaskConnect: Peripherals identifier is NIL!")
            completed(result: BleResult.failure)
            return
        }
        
        //initiate connect
        manager.manager!.connect(cbPeripheral!, options: nil)
    }
    
    override func onCompleted(result: BleResult) {
        // not successfully connected -> cancel connection
        if (cbPeripheral != nil && result != BleResult.success && result != BleResult.connectionAlreadyEstablished)
        {
            manager.manager?.cancelPeripheralConnection(cbPeripheral!)
        }
    }
        
    override func cleanup() {
        // detach events
        deregisterEvents()
        
        // cleanup base
        super.cleanup()
    }
    
    //MARK: Events
    func onBluetoothStateChanged(args: BluetoothStateChangedEventArgs){
        // faild
        completed(result: BleResult.bluetoothDisabled)
    }
    
    func onConnectedPeripheral(args: CBPeripheralEventArgs){
        // peripheral mismatch?
        guard cbPeripheral === args.peripheral else {
            return
        }
        
        guard args.peripheral.state == CBPeripheralState.connected else {
            //Faild to connect
            completed(result: BleResult.unabledToConnect)
            return;
        }
        
        //success
        completed(result: BleResult.success)
    }
    
    func onDisconnectedPeripheral(args: CBPeripheralErrorEventArgs){
        // peripheral mismatch?
        guard cbPeripheral === peripheral else {
            return
        }
        
        //success
        completed(result: BleResult.success)
    }
    
    func onFaildToConnectPeripheral(args: CBPeripheralErrorEventArgs){
        // peripheral mismatch?
        guard cbPeripheral === peripheral else {
            return
        }
        
        //success
        completed(result: BleResult.unabledToConnect)
    }
    
    //MARK private func
    private func retrievePeripheral(uuid: String) -> CBPeripheral?
    {
        let id = UUID(uuidString: uuid)
        var ids = [UUID]()
        ids.append(id!)
        
        var p = manager.manager?.retrievePeripherals(withIdentifiers: ids)
        
        if p!.count > 0
        {
            return p![0]
        }
        
        return nil
    }
    
    private func registerEvents(){
        _myConnectedPeripheralHandler = manager.eventMyConnetedPeripheral.addHandler(self, TaskConnect.onConnectedPeripheral)
        _myDisconnectPeripheralHandler = manager.eventMyDisconnectedPeripheral.addHandler(self, TaskConnect.onDisconnectedPeripheral)
        _myFailedToConnectPeripheralHandler = manager.eventMyFailedToConnectPeripheral.addHandler(self, TaskConnect.onFaildToConnectPeripheral)
        _bluetoothStateChanged = manager.eventBluetoothStateChanged.addHandler(self, TaskConnect.onBluetoothStateChanged)
    }
    
    private func deregisterEvents()
    {
        _myConnectedPeripheralHandler?.dispose()
        _myDisconnectPeripheralHandler?.dispose()
        _myFailedToConnectPeripheralHandler?.dispose()
        _bluetoothStateChanged?.dispose()
    }
}
