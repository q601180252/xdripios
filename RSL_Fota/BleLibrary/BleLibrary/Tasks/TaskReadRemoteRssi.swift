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
 * Class Name: TaskReadRemoteRssi.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
import os.log
class TaskReadRemoteRssi : TaskPeripheral
{
    //MARK: members
    private var _cbPeripheral: CBPeripheral?
    private var _rssi: Int

    //MARK: Property
    var rssi: Int
    {
        return _rssi
    }
    
    override var description: String
    {
        return "Read remote RSSI (Device:{\(peripheral.uuid.uuidString)})"
    }
    
    //MARK: eventhandlers
    private var _myDisconnectedPeripheralHandler: EventHandlerProtocol?
    private var _onRssiReadHandler: EventHandlerProtocol?
    
    override init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol, _ timeout: Int)
    {
        self._rssi = 0
        super.init(peripheral, manager, timeout)
    }
    
    override func start()
    {
        // not connected?
        guard peripheral.isConnected else {
            completed(result: BleResult.notConnected)
            return
        }
        
        // set peripheral to use for this task
        _cbPeripheral = peripheral.cbPeripheral
        
        // attach delegate
        registerEvents()
    
        // start reading of remote RSSI
        _cbPeripheral?.readRSSI()
    }
    
    //MARK: CBPeripheralDelegate
    func onRssiRead(args: CBRssiEventArgs ){
        
        //failure
        guard args.error == nil else {
            log.error("Failed to write characteristic (\(args.error.debugDescription))")
            return
        }
        
        // success
        _rssi = args.rssi
        completed(result: BleResult.success);
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
        // detach delegate
        deregisterEvents()
        
        super.cleanup()
    }
    
    //MARK: Private functions
    private func registerEvents()
    {
        _myDisconnectedPeripheralHandler = manager.eventMyDisconnectedPeripheral.addHandler(self, TaskReadRemoteRssi.onDisconnectedPeripheral)
        _onRssiReadHandler = peripheral.eventRssiRead.addHandler(self, TaskReadRemoteRssi.onRssiRead)
    }
    
    private func deregisterEvents()
    {
        _myDisconnectedPeripheralHandler?.dispose()
        _onRssiReadHandler?.dispose()
    }
    
}
