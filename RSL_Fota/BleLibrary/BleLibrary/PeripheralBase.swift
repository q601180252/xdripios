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
 * Class Name: PeripheralBase.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public class PeripheralBase:NSObject, PeripheralProtocol, CBPeripheralDelegate
{
    //MARK: events
    public var eventStateChange = Event<CBStateChangedEventArgs>()
    public var eventConnected = Event<EmptyEventArgs>()
    public var eventDisconnected = Event<DisconnectedEventArgs>()
    
    // events calld on interactions
    public var eventUpdatedCharacterteristicValue = Event<CBCharacteristicEventArgs>()
    public var eventWroteCharacteristicValue = Event<CBCharacteristicEventArgs>()
    public var eventIsReadyToSendWriteWithoutResponse = Event<EmptyEventArgs>()
    public var eventUpdatedNotificationState = Event<CBCharacteristicEventArgs>()
    public var eventServiceDiscovered = Event<CBServiceDiscoveredEventArgs>()
    public var eventCharacteristicDiscovered = Event<CBCharacteristicDiscoveredEventArgs>()
    public var eventRssiRead = Event<CBRssiEventArgs>()
    public var eventNameUpdated = Event<NameUpdatedEventArgs>()
    
    //MARK: properties
    public var uuid: UUID { return _uuid }
    
    public var rssi: Int
    {
        get { return _rssi }
        set { _rssi = newValue; _lastUpdate = Date() }
    }
    
    public var name: String?
    {
        get { return _name }
        set { _name = newValue; _lastUpdate = Date() }
    }
    
    public var manufacturerData: Data { return _manufacturerData }
    
    public var state: PeripheralState { return _state }
    
    public var cbState: CBPeripheralState { return _cbPeripheral?.state ?? CBPeripheralState.disconnected }
    
    public var peripheralManager: PeripheralManagerBaseProtocol?
    {
        get { return _peripheralManager }
        set { _peripheralManager = newValue }
    }
    
    public var lastUpdate: Date { return _lastUpdate }
    
    public var maxWriteLength: Int
    {
        return cbPeripheral?.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse) ?? 20
    }
    
    public override var description: String { return "\(uuid.uuidString)"}
    
    public var isConnected: Bool {
        return (_cbPeripheral?.state == CBPeripheralState.connected)
        
    }
    
    public var cbPeripheral: CBPeripheral? { return _cbPeripheral }
    
    public var taskController: TaskControllerSequential { return _taskController }
    
    public var serviceList: [ServiceProtocol]
    {
        return _serviceAccessLock.sync {
            return _services
        }
    }
    
    public weak var delegate: PeripheralDelegate?
    
    //MARK: memebers
    private var _cbPeripheral: CBPeripheral?
    private var _uuid: UUID
    private var _rssi: Int
    private var _name: String?
    private var _manufacturerData: Data
    private var _state: PeripheralState
    private var _cbState: CBPeripheralState
    private var _peripheralManager: PeripheralManagerBaseProtocol?
    private var _lastUpdate: Date
    private var _taskController: TaskControllerSequential
    
    var _services: [ServiceProtocol]
    var _serviceAccessLock = DispatchQueue(label: "ch.arendi.bleLibrary.PeripehralBase.serviceAccessLock")
    
    //MARK: eventHandlers
    private var _taskStartedHandler: EventHandlerProtocol?
    private var _taskCompletedHandler: EventHandlerProtocol?
    private var _onBluetootStateChangedHandler: EventHandlerProtocol?
    private var _onDisconnectedHandler: EventHandlerProtocol?
    
    private let log: LogProtocol = LogManager.manager.createLog(name: "PeripheralBase")
    
    /**
     Initializer of the class
     
     - parameters:
        - peripheral: A CBPeripheral that is the main
     */
    public required init(peripheral: CBPeripheral, rssi: Int, name: String?, manufacturerData: Data?) {
        
        _cbPeripheral = peripheral
        _uuid = peripheral.identifier
        _name = name
        _manufacturerData = manufacturerData ?? Data()
        _state = PeripheralState.idle
        _cbState = peripheral.state
        _peripheralManager = nil
        _lastUpdate = Date()
        _taskController = TaskControllerSequential()
        _services = [ServiceProtocol]()
        _rssi = rssi
        
        super.init()
        
        // register event handler
        registerEvents()
    }
    
    public func findService(uuid: String) -> ServiceProtocol? {
        return findService(uuid: CBUUID(string: uuid))
    }
    
    public func findService(uuid: CBUUID) -> ServiceProtocol? {
        return _serviceAccessLock.sync {
            
            let item = _services.first(where: {$0.uuid == uuid})
            
            guard item != nil else
            {
                log.info("Service with UUID \(uuid.uuidString) not found")
                return nil
            }
            
            log.info("Service found: \(item?.characteristics)")
            return item
        }
    }
    
    public func findCharacteristic(uuid: String) -> CharacteristicsProtocol? {
        return findCharacteristic(uuid: CBUUID(string: uuid))
    }
    
    public func findCharacteristic(uuid: CBUUID) -> CharacteristicsProtocol? {
                
        return _serviceAccessLock.sync {
            for service in _services
            {
                let item = service.getCharacteristic(uuid: uuid)
                
                // if characteristic found
                if item != nil
                {
                    return item
                }
            }            
            log.info("Characteristic with UUID \(uuid.uuidString) not found")
            return nil
        }
    }
    
    public func discoverServices(timeout: Int)throws -> [ServiceProtocol]
    {
        // not connected
        guard isConnected else
        {
            log.error("Failed to discover services, peripheral is not connected")
            throw BleLibraryError.notConnectedError(message: "Discover services only possible if peripheral is connected", result: BleResult.notConnected)
        }
        
        // log operation
        log.info("Discover services...")
        
        //call implementation
        do
        {
            let res = try discoverServicesImpl(timeout)
            for service in res
            {
                log.info("  Service \(service.description)")
                for c in service.characteristics
                {
                    log.info("  - \(c.description)")
                }
            }
            return _services
        }
        catch
        {
            log.error("Unabled to discover services from peripheral \(error)")
            throw error
        }
        
    }
    
    public func connect(timeout: Int) throws {
        // already connected
        guard cbState != CBPeripheralState.connected else
        {
            log.info("The peripheral is already connected")
            return 
        }
        
        // log operation
        log.info("Connect...")
        
        // call implementation
        do
        {
           try connectImpl(timeout)
           cbPeripheral?.delegate = self
        }
        catch
        {
            log.error("Unabled to connect peripheral, \(error)")
            throw error
        }
    }
    
    public func disconnect(timeout: Int) throws  {
        // log operation
        log.info("Disconnect...")
        
        // call implementation
        do
        {
            try disconnectImpl(timeout)
        }
        catch
        {
            log.error("Unable to disconnect peripheral \(error)")
            throw error
        }
    }
    
    public func readRssi(timeout: Int) throws -> Int {
        // not connected
        guard  isConnected else {
            log.error("Failed to read RSSI, peripheral is not connected")
            throw BleLibraryError.notConnectedError(message: "Read RSSI only possible if peripheral is connected", result: BleResult.notConnected)
        }
        
        // call implementation
        do
        {
            return try readRssiImpl(timeout)
        }
        catch
        {
            log.error("Unabled to read RSSI from peripheral \(error)")
            throw error
        }
    }
    
    public func equal(other: PeripheralProtocol) -> Bool {
        return uuid == other.uuid
    }
    
    //MARK: protected functions
    /**
     * Called to add services to the service list properly
     */
    func serviceListAdd(services: [ServiceProtocol])
    {
        _serviceAccessLock.sync {
            _services.append(contentsOf: services)
        }
    }
    
    /**
     * Called to clear the serivce list properly
     */
    func serviceListClear()
    {
        _serviceAccessLock.sync {
            //Dispose serivces
            for s in _services
            {
                s.dispose()
            }
            _services.removeAll()
        }
    }
    
    /**
     * Reset this peripheral to disconnected
     */
    func resetPeripheralToDisconnected()
    {
        // deregister event handlers
        deregisterManagerEvents()
        
        // remove serivces
        serviceListClear()
        
        // remove peripheral reference
        _cbPeripheral = nil
        
        // set state to disconnected
        setState(CBPeripheralState.disconnected)
    }
    
    //MARK: private functions
    private func connectImpl(_ timeout: Int)throws
    {
        //Create and run task
        let task = TaskConnect(self, _peripheralManager!, timeout)
        try _taskController.run(task: task)
    }
    
    private func disconnectImpl(_ timeout: Int)throws
    {
        //Create and run task
        let task = TaskDisconnect(self, _peripheralManager!, timeout)
        try _taskController.run(task: task)
    }
    
    private func discoverServicesImpl(_ timeout: Int)throws -> [ServiceProtocol]
    {
        //Create and run task
        let task = TaskDiscoverServices(self, _peripheralManager!, timeout)
        try _taskController.run(task: task)
        
        return task.services
    }
    
    private func readRssiImpl(_ timeout: Int)throws -> Int
    {
        //Create and run task
        let task = TaskReadRemoteRssi(self, _peripheralManager!, timeout)
        try _taskController.run(task: task)

        return task.rssi
    }
    
    private func onTaskStarted(args: TaskStartedEventArgs)
    {
        // Connect started
        let taskConnect = args.task as? TaskConnect
        if taskConnect != nil
        {
            // register manager event handler
            registerManagerEvents()
            
            // setState to connecting
            setState(CBPeripheralState.connecting)
        }
        
        // disconnect started
        let taskDisconnect = args.task as? TaskDisconnect
        if taskDisconnect != nil
        {
            // set disconnecting state and disconnect reason if not yet disconnected
            // NOTE: This is required as the disconnect operation may alse occur when already disconnected (tear down)
            if _cbState != CBPeripheralState.disconnecting
            {
                setState(CBPeripheralState.disconnecting)
            }
        }
        
        // service discovery started
        let taskDiscoverServices = args.task as? TaskDiscoverServices
        if taskDiscoverServices != nil
        {
            // do nothing
        }
        
        // read remote RSSI started
        let taskReadRssi = args.task as? TaskReadRemoteRssi
        if taskReadRssi != nil
        {
            //do nothing
        }
    }
    
    private func onTaskCompleted(args: TaskCompletedEventArgs)
    {
        // Connect started
        let taskConnect = args.task as? TaskConnect
        if taskConnect != nil
        {
            // success
            if args.result == BleResult.success
            {
                // set new native peripheral object
                _cbPeripheral = taskConnect?.cbPeripheral
                
                // connected
                setState(CBPeripheralState.connected)
            }
            else if (args.result == BleResult.connectionAlreadyEstablished)
            {
                log.info("The peripheral is already connected")
                // connected
                setState(CBPeripheralState.connected)
            }
            else
            {
                log.error("Connect failed (Result\(args.error.debugDescription)")
                resetPeripheralToDisconnected()
            }
            
            //trigger event
            if args.result == BleResult.success
            {
                eventConnected.raise(data: EmptyEventArgs())
            }
        }
        
        // disconnect started
        let taskDisconnect = args.task as? TaskDisconnect
        if taskDisconnect != nil
        {
            if args.result != BleResult.success
            {
                log.error("Disconnect faild (Result:\(args.result)")
            }
        }
        
        // service discovery started
        let taskDiscoverServices = args.task as? TaskDiscoverServices
        if taskDiscoverServices != nil
        {
            // success
            if args.result == BleResult.success
            {
                // remove old services
                serviceListClear()
                
                // add new services
                serviceListAdd(services: taskDiscoverServices?.services ?? [ServiceProtocol]())
            }
        }
        
        // read remote RSSI started
        let taskReadRssi = args.task as? TaskReadRemoteRssi
        if taskReadRssi != nil
        {
            //do nothing
        }
        
    }
    
    private func onBluetoothStateChanged(args: BluetoothStateChangedEventArgs)
    {
        // Peripheral is disconnected if BT state changed from On to other state and not yet disconnected
        if args.oldState == BluetoothState.On && args.newState != BluetoothState.On && cbState != CBPeripheralState.disconnected
        {
            resetPeripheralToDisconnected()
            
            // trigger disconnected event
            eventDisconnected.raise(data: DisconnectedEventArgs(reason: DisconnectReason.bluetoothDisabled))
        }
    }
    
    private func onDisconnectedPeripheral(args: CBPeripheralErrorEventArgs)
    {
        // state
        let disconnectedState = cbState
        
        if(args.peripheral.identifier == _cbPeripheral?.identifier)
        {
            resetPeripheralToDisconnected()
            
            // trigger disconnected event
            eventDisconnected.raise(data: DisconnectedEventArgs(reason: (disconnectedState != CBPeripheralState.disconnecting ? DisconnectReason.remoteUserTerminatedConnection : DisconnectReason.localHostTerminatedConnection)))
        }
    }
    
    private func setState(_ newState: CBPeripheralState)
    {
        guard _cbState != newState else {
            return
        }
        
        let previousState = _cbState
        _cbState = newState
        
        // Trigger state changed event
        eventStateChange.raise(data: CBStateChangedEventArgs(self, previousState, _cbState))
        
        // handle new state
        switch newState {
        case .connecting:
            log.info("Connecting... (Device:\(_uuid.uuidString)")
            break
        case .connected:
            log.info("Connected (Device:\(_uuid.uuidString)")
            break
        case .disconnecting:
            log.info("Disconnecting... (Device:\(_uuid.uuidString)")
            break
        case .disconnected:
            // dispose services
            serviceListClear()
            log.info("Disconnected (Device:\(_uuid.uuidString)")
            break
        }
    }
    
    private func registerEvents()
    {
        _taskStartedHandler = _taskController.eventTaskStarted.addHandler(self, PeripheralBase.onTaskStarted)
        _taskCompletedHandler = _taskController.eventTaskCompleted.addHandler(self, PeripheralBase.onTaskCompleted)
    }
    
    private func registerManagerEvents()
    {
        _onDisconnectedHandler = peripheralManager?.eventMyDisconnectedPeripheral.addHandler(self, PeripheralBase.onDisconnectedPeripheral)
        _onBluetootStateChangedHandler = peripheralManager?.eventBluetoothStateChanged.addHandler(self, PeripheralBase.onBluetoothStateChanged)
    }
    
    private func deregisterEvents()
    {
        _taskStartedHandler?.dispose()
        _taskCompletedHandler?.dispose()
        
        cbPeripheral?.delegate = nil
    }
    
    private func deregisterManagerEvents()
    {
        _onDisconnectedHandler?.dispose()
        _onDisconnectedHandler?.dispose()
    }
    
    //MARK: CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        eventServiceDiscovered.raise(data: CBServiceDiscoveredEventArgs(peripheral, error))
        if delegate != nil{
            delegate?.peripheral(self, didServiceDiscovered: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        eventCharacteristicDiscovered.raise(data: CBCharacteristicDiscoveredEventArgs(service, error))
        if delegate != nil{
            delegate?.peripheral(self, didCharacteristicDiscovered: service, error: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        eventUpdatedCharacterteristicValue.raise(data: CBCharacteristicEventArgs(characteristic, error))
        if delegate != nil{
            delegate?.peripheral(self, didUpdateCharacteristicValue: characteristic, error: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        eventWroteCharacteristicValue.raise(data: CBCharacteristicEventArgs(characteristic, error))
        if delegate != nil{
                delegate?.peripheral(self, didWriteCharacteristicValue: characteristic, error: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        eventUpdatedNotificationState.raise(data: CBCharacteristicEventArgs(characteristic, error))
        if delegate != nil{
            delegate?.peripheral(self, didUpdateNotificationState: characteristic, error: error)
        }
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        eventIsReadyToSendWriteWithoutResponse.raise(data: EmptyEventArgs())
        if delegate != nil{
            delegate?.peripheralIsReadyToSendWriteWithoutResponse(self)
        }
    }
    
    // RSSI callback from IOS8 -> the result is given by the RSSI property of the event args (the deprecated RSSI property of the peripheral must not be used)
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        eventRssiRead.raise(data: CBRssiEventArgs(Int(truncating: RSSI), error))
        if delegate != nil{
            delegate?.peripheral(self, didReadRssi: Int(truncating: RSSI), error: error)
        }
    }
    
    // RSSI callback up to IOS7 -> the result is given by the RSSI property of the peripheral
    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        eventRssiRead.raise(data: CBRssiEventArgs(Int(truncating: peripheral.rssi ?? 0), error))
        if delegate != nil{
            delegate?.peripheral(self, didReadRssi: Int(truncating: peripheral.rssi ?? 0), error: error)
        }
    }
    
    //MARK: dispose
    public func dispose() {
        do
        {
            if isConnected
            {
                try disconnectImpl(100)
            }
        }
        catch
        {
            //Ignore
        }
        
        deregisterEvents()
        deregisterManagerEvents()
        
        serviceListClear()
    }
}
