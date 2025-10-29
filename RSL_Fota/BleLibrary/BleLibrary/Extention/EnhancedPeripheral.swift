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
 * Class Name: EnhancedPeripheral.swift
 ******************************************************************************/

import Foundation
open class EnhancedPeripheral: ManagedPeripheral, EnhancedPeripheralProtocol
{
    
    //MARK: Members
    private var _peripheralTask: DispatchWorkItem?
    private var _peripheralTaskQueue = DispatchQueue(label: "ch.arendi.bleLibrary.EnhancedPeripheral.PeripheralTaskQueue")
    private var _taskController: TaskControllerSequential
    
    private var _state: PeripheralState
    
    private let log: LogProtocol = LogManager.manager.createLog(name: "EnhancedPeripheral")
    private var _lockQueue = DispatchQueue(label: "ch.arendi.bleLibraray.EnhancedPeripheral.lockQueue")
    
    //MARK: Properties
    public var state: PeripheralState { return _state }
    
    public var connectTimeout: Int
    
    public var discoverServiceTimeout: Int
    
    public var disconnectTimeout: Int
    
    public var establishParameter: ParameterSet?
    
    public var establishAttMtu: Int?
    
    public weak var delegate: EnhancedPeripheralDelegate?
    
    override public var description: String
    {
        if name.count == 0 && name.contains("?")
        {
            return "EnhancedPeripheral (UUID=\(uuid.uuidString) Name=\(name)"
        }
        return "EnhancedPeripheral (UUID=\(uuid.uuidString)"
    }
    
    //MARK: Events
    public var eventStateChanged = Event<StateChangedEventArgs>()
    
    //MARK: Eventhandler
    private var _peripheralUpdatedHandler: EventHandlerProtocol?
    private var _peripheralOnDisconnectedHandler: EventHandlerProtocol?
    private var _centralOnBluetoothStateChangedHandler: EventHandlerProtocol?
    
    //MARK: Methods
    public override init(uuid: UUID)
    {
        // reset information
        _state = PeripheralState.idle
        
        // initialize configuration
        connectTimeout = Constants.connectTimeout
        discoverServiceTimeout = Constants.discoverServicesTimeout
        disconnectTimeout = Constants.disconnectTimeout
        
        
        establishParameter = nil
        _taskController = TaskControllerSequential()
        
        super.init(uuid: uuid)
        
        // connect to peripheral updated event
        _peripheralUpdatedHandler = super.eventPeripheralUpdated.addHandler(self, EnhancedPeripheral.onPeripheralUpdated)
    }
    
    public override init(peripheral: PeripheralProtocol) throws
    {
        _state = PeripheralState.idle
        
        // initialize configuration
        connectTimeout = Constants.connectTimeout
        discoverServiceTimeout = Constants.discoverServicesTimeout
        disconnectTimeout = Constants.disconnectTimeout
        
        establishParameter = nil
        _taskController = TaskControllerSequential()
        
        try super.init(peripheral: peripheral)
        
        // connect to peripheral updated event
        _peripheralUpdatedHandler = super.eventPeripheralUpdated.addHandler(self, EnhancedPeripheral.onPeripheralUpdated)
        
        // init real peripheral directly
        initRealPeripheral()
    }
    
    public func  setState(newState: PeripheralState)throws
    {
        try checkDisposed()
        
        if _state == newState { return }
        
        let previousState = _state
        _state = newState
        log.info("\(description) - State: \(previousState) -> \(_state)")
        raiseStateChangedEvent(previousState: previousState, newState: _state)
    }
    
    public func prepare() throws {
        try checkDisposed()
        
        guard peripheral != nil else {
            throw BleLibraryError.generalError(message: "Operation not allowed with virtual peripherals.")
        }
        
        do {
            try _taskController.run(task: TaskPrepare(self))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                try? self.teardown()
            }
            
        } catch {
            do {
                try teardown()
            } catch {
                log.error("Faild to teardown connection after failed establish")
            }
        }
    }
    
    public func connectThenDisconnect() throws {
        try checkDisposed()
        
        guard peripheral != nil else {
            throw BleLibraryError.generalError(message: "Operation not allowed with virtual peripherals.")
        }
        
        do {
            try _taskController.run(task: TaskMagic(self))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                try? self.teardown()
            }
            
        } catch {
            do {
                try teardown()
            } catch {
                log.error("Faild to teardown connection after failed establish")
            }
        }
    }
    
    public func establish()throws {
        // check if peripheral is not yet disposed
        try checkDisposed()
        
        // check if peripheral is real
        guard peripheral != nil else {
            throw BleLibraryError.generalError(message: "Operation not allowed with virtual peripherals.")
        }
        
        do
        {
            try _taskController.run(task: TaskEstablish(self))
        }
        catch
        {
            do
            {
                try teardown()
            }
            catch
            {
                log.error("Faild to teardown connection after failed establish")
            }
        }
    }
    
    public func teardown()throws {
        // check if peripheral is not yet disposed
        try checkDisposed()
        
        // check if peripheral is real
        guard peripheral != nil else
        {
            throw BleLibraryError.generalError(message: "Operation not allowed with virtual peripherals")
        }
        
        // enter disconnecting state
        if state != PeripheralState.idle
        {
           try setState(newState: PeripheralState.tearDownLink)
        }
        
        try _taskController.run(task: TaskTeardown(self));
    }
    
    public func update(updateSetup: UpdateSetup)throws {
        // check if peripheral is not yet disposed
        try checkDisposed()
        
        // check if peripheral is real
        guard peripheral != nil else
        {
            throw BleLibraryError.generalError(message: "Operation not allowed with virtual peripherals")
        }
        
        // store information for the update
        try updatePeripheral(setup: updateSetup)
        
        initRealPeripheral();
    }
    
    public override func dispose() {
        // mark object as disposed
        _isDisposed = true
        
        if peripheral?.isConnected ?? false
        {
            do
            {
                try teardown()
            }
            catch
            {
                //ignore error
            }
        }
        
        // detach from events
        _peripheralUpdatedHandler?.dispose()
        
        // peripherl was defined (no virtual device)?
        if peripheral != nil
        {
            log.info("\(description) - Dispose started")
            
            // detach from events
            _peripheralOnDisconnectedHandler?.dispose()
            _centralOnBluetoothStateChangedHandler?.dispose()
            
            //dispose done
            log.info("\(description) - Dispose done")        }
        
        super.dispose()
    }

    //MARK: private functions
    private func checkDisposed()throws
    {
        if isDisposed
        {
            throw BleLibraryError.objectDisposedError(objectName: peripheralDisposedErrorText)
        }
    }
    
    private func onPeripheralUpdated(args: EmptyEventArgs)
    {
        // detach from peripheral update event
        _peripheralUpdatedHandler?.dispose()
                
        // init real peripheral
        initRealPeripheral()
    }
    
    /**
     Init real peripheral functionality, This method must be called when the peripheral changes from virtual to real or if initialized as real peripheral
     */
    private func initRealPeripheral()
    {
        // attach to events
        _peripheralOnDisconnectedHandler = peripheral?.eventDisconnected.addHandler(self, EnhancedPeripheral.onPeripheralOnDisconnected)
        _centralOnBluetoothStateChangedHandler = peripheral?.peripheralManager?.eventBluetoothStateChanged.addHandler(self, EnhancedPeripheral.onCentralBluetoothStateChanged)
        
        // call activate methode of a derived class
        activate()
    }
    
    /**
     Handle peripheral disconnectedevent
     */
    private func onPeripheralOnDisconnected(args: DisconnectedEventArgs)
    {
        _lockQueue.sync {
            do{
                // ignore if disposed
                guard !isDisposed else
                {
                    return
                }
                
                if (state != PeripheralState.idle && state != PeripheralState.update)
                {
                    try setState(newState: PeripheralState.idle)
                    log.info("\(description) - Disconnected event")
                }
            }
            catch
            {
                // ignore error
            }
        }
    }
    
    /**
     Handle bluetooth state change
     */
    private func onCentralBluetoothStateChanged(args: BluetoothStateChangedEventArgs)
    {
        _lockQueue.sync {
            // ignore if diposed
            guard !isDisposed else
            {
                return
            }
            
            // change from or to On state
            if (args.newState == BluetoothState.On) || (args.oldState == BluetoothState.On)
            {
                do{
                    try setState(newState: PeripheralState.idle)
                }
                catch
                {
                    //igore error
                }
            }
        }
    }
    
    private func readRssi()
    {
        if state == PeripheralState.ready
        {
            //start
            log.debug("\(description) - Read RSSI started")
            
            do
            {
                // read RSSI
                let rssiValue = try peripheral?.readRssi(timeout: Constants.readRssiTimeout)
                
                // done
                log.debug("\(description) - Read RSSI done (\(rssiValue))")
                
                // update value
                try setRssi(rssi: rssiValue!)
                
            }
            catch
            {
                log.error("\(description) - Read RSSI failed \(error)")
            }
        }
    }
    
    private func updatePeripheral(setup: UpdateSetup)throws
    {
        // enter update state
        try setState(newState: PeripheralState.update)
        
        do
        {
            try _taskController.run(task: TaskUpdate(peripheral: self, setup: setup))
            try setState(newState: PeripheralState.idle)
        }
        catch
        {
            do
            {
                try _taskController.run(task: TaskTeardown(self))
            }
            catch
            {
                log.error("Faild to teardown connection after update")
            }
            
            try setState(newState: PeripheralState.idle)
            
            throw error
        }
    }
    
    func raiseStateChangedEvent(previousState: PeripheralState, newState: PeripheralState)
    {
        guard let p = peripheral as? PeripheralBase else { return }
        
        DispatchQueue.main.async {
            self.eventStateChanged.raise(data: StateChangedEventArgs(p, previousState, newState))
        }
    }

    /**
     Check if state of the peripheral is ready. If not in Ready state an <exception cref="PeripheralNotReadyException"></exception> is thrown.
     */
    func checkReady()throws
    {
        // are we ready
        if state != PeripheralState.ready
        {
            throw BleLibraryError.notReadyError(message: "The peripheral is not ready")
        }
    }

    
    public func doInitialize()throws -> UpdateSetup?
    {
        var updateSetup: UpdateSetup? = nil
        
        // try blocking method first
        updateSetup = try initialize()
        
        return updateSetup
    }
    
    public func doPrepare() throws {
        try prepare()
    }
    
    /**
     Empty initialize method that can be overwritten in the derived class. This method is called in Initialize state after detection services of the peripheral. The method may be used to check the detected services and read/write some initial values. If an exception is thrown in this method the peripheral will be disconnected.
     
     - returns:
        May return an "UpdateSetup" instance to force an update as part of the establish operation. The state of the peripheral will change into "PeripheralState.Update" after the return. If the update succeeds the system will continue with "PeripheralState.EstablishLink" and try again to establish. If it fails it will terminate the establish operation with a failure and force a teardown operation. If nil is returned no update is required and the establish operation will be terminated after the return.
     */
    open func initialize()throws -> UpdateSetup?
    {
        return nil
    }
    
    /**
     This method is called after the standard peripheral object for this peripheral is set. If a constructor with the standard peripheral object is called, that method will be called in the constructor. On virtual devices (no standard peripheral object on object creation) the method may be called later, when the virtual device is converted to a real peripheral.
     */
    private func activate()
    {
        // needs to be overriten
    }
}
