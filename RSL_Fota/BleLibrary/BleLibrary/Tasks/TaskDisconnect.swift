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
 * Class Name: TaskDisconnect.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
import os.log
class TaskDisconnect: TaskPeripheral
{
    //MARK: Properties
    override var description: String
    {
        return "Disconnect (Device:\(peripheral.uuid.uuidString))"
    }
    
    //MARK: eventhandlers
    private var _myDisconnectedPeripheralHandler: EventHandlerProtocol?
    
    //MARK: initialization
    init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol)
    {
        super.init(peripheral, manager, Constants.disconnectTimeout)
    }
    
    override init(_ peripheral: PeripheralBase, _ manager: PeripheralManagerBaseProtocol, _ timeout: Int)
    {
        super.init(peripheral,manager, timeout)
    }
    
    override func start()
    {
        //Already disconnected?
        guard peripheral.isConnected else {
            completed(result: BleResult.notConnected)
            return;
        }
        
        //Attach events
        registerEvents()
        
        manager.manager?.cancelPeripheralConnection(peripheral.cbPeripheral!)
    }
    
    override func cleanup() {
        // detach events
        deregisterEvents()
        
        // cleanup base
        super.cleanup()
    }
    
    //MARK: event
    func onDisconnectedPeripheral(args: CBPeripheralErrorEventArgs){
        
        guard args.peripheral.identifier == peripheral.uuid else
        {
            return
        }
        
        // success
        completed(result: BleResult.success)
    }
    
    //MARK: Private functions
    private func registerEvents()
    {
        //Central events
        _myDisconnectedPeripheralHandler = self.manager.eventMyDisconnectedPeripheral.addHandler(self, TaskDisconnect.onDisconnectedPeripheral)
    }
    
    private func deregisterEvents()
    {
        //Central events
        _myDisconnectedPeripheralHandler?.dispose()
    }
}
