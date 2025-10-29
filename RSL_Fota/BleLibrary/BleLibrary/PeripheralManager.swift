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
 * Class Name: PeripheralManager.swift
 ******************************************************************************/

import CoreBluetooth
import Foundation

public class PeripheralManage<TPeripheral: PeripheralProtocol>: NSObject, PeripheralManagerProtocol, CBCentralManagerDelegate
{
    public weak var delegate: PeripheralManagerBaseDelegate?
    
    //MARK: events
    public var eventPeripheralListUpdated = Event<EmptyEventArgs>()
    public var eventBluetoothDisabled = Event<EmptyEventArgs>()
    public var eventBluetoothEnabled = Event<EmptyEventArgs>()
    public var eventPeripheralDiscovered = Event<PeripheralDiscoveredEventArgs>()
    public var eventBluetoothStateChanged = Event<BluetoothStateChangedEventArgs>()
    public var eventSystemInformationUpdated = Event<EmptyEventArgs>()
    public var eventFatalError = Event<FatalErrorEventArgs>()
    public var eventMyConnetedPeripheral = Event<CBPeripheralEventArgs>()
    public var eventMyDisconnectedPeripheral = Event<CBPeripheralErrorEventArgs>()
    public var eventMyFailedToConnectPeripheral = Event<CBPeripheralErrorEventArgs>()
    public var eventIsBusyChanged = Event<IsBusyEventArgs>()
    
    //MARK members
    private var _manager: CBCentralManager?
    private var _scanStarted: Bool = false
    private var _lastBtState: CBManagerState = CBManagerState.unknown
    private var _bluetoothState: BluetoothState = BluetoothState.Unknown
    private var _peripherals: [String: TPeripheral] = [String: TPeripheral]()
    private var _updatePeripheralTimer: Timer?
    private var _scanIntervalTime: TimeInterval = 10.0
    private var _timeoutTimer: Timer?
    private var _isBluetoothDisabled: Bool = false
    private var _isBluetoothEnabled: Bool = false
    
    private var _isDisposed: Bool = false
    
    private var _peripheralsLock = DispatchQueue(label: "ch.arendi.bleLibrary.ExtendedPeripheralManager.peripheralsLock")
    private var _lockQueue = DispatchQueue(label: "ch.arendi.bleLibrary.ExtendedPeripheralManager.lockQueue")
    
    private let log: LogProtocol = LogManager.manager.createLog(name: "ExtendedPeripheralManager")
    
    //MARK: propertiees
    public var manager: CBCentralManager? { return _manager }
    
    public var isScanning: Bool { return _scanStarted }
    
    public var uuidFilter: [CBUUID]?
    
    public var peripherals: [TPeripheral] { return _peripherals.values.lazy.toArray() }
    
    public var peripheralInvisibleTimeout: Int = 10
    
    public var disposePeripheralOnRemove: Bool = true
    
    public var updateNameByAdvertisedData: Bool = true
    
    public var bluetoothState: BluetoothState { return _bluetoothState }
    
    public var isDisposed: Bool { return _isDisposed }

    /**
     Initialzer an instance of the peripheral manager
     
     - parameters:
        - checkBtEnabled: True if should show power alert
     */
    public init(_ checkBtEnabled: Bool)
    {
        super.init()
        
        // create own dispatch queue for better performance
        let dispatchQueue = DispatchQueue(label: "ch.arendi.bleLibrary.PeripheralManager.queue")
        
        if #available(iOS 7.0, *)
        {
            // create options dictionary
            var options = [String : Any]()
            options[CBCentralManagerOptionShowPowerAlertKey] = NSNumber.init(value: checkBtEnabled)
            
            // create CBCentralManager
            _manager = CBCentralManager(delegate: self, queue: dispatchQueue, options: options)
        }
        else
        {
            _manager = CBCentralManager(delegate: self, queue: dispatchQueue)
        }
        
        if _manager == nil
        {
            log.error("Not able to instantiate CBCentralManager");
            return;
        }
        
        _lastBtState = (_manager?.state)!
    }
    
    /**
     Initialzer an instance of the peripheral manager, with default "checkBtEnabled" = false
     */
    convenience override init()
    {
        self.init(false)
    }
    
    /**
     Start scaning for peripherals with default allowDuplicates true
     */
    public func startScan() {
        startScan(allowDuplicatesKey: true)
    }
    
    /**
     Start scaning for peripherals
     
     - parameters:
        - allowDuplicatesKey: True, will discover peripheral wiht same identifier more than one time, false only once
     */
    public func startScan(allowDuplicatesKey: Bool) {
        
        do{
            //Check if object is not yet disposed
            try checkDisposed()
            
            guard isBluetoothEnabled() else{
                log.info("Bluetooth is not enabled")
                return;
            }
            
            if !_scanStarted
            {
                _scanStarted = true;
                
                log.info("Scan for peripheral started")
                
                var options = [String: Any]()
                options[CBCentralManagerScanOptionAllowDuplicatesKey] = allowDuplicatesKey
                
                manager?.scanForPeripherals(withServices: nil, options: options)
                
                eventIsBusyChanged.raise(data: IsBusyEventArgs(true))
                
                //Timer
                DispatchQueue.main.async {
                    //                    print("-- DispatchQueue.main.async: Set timer for scan timeout")
                    self._timeoutTimer = Timer.scheduledTimer(timeInterval: self._scanIntervalTime, target: self, selector: #selector(self.pauseScan), userInfo: nil, repeats: false)
                }
            }
        }
        catch
        {
            log.error("Error \(error)")
            return
        }
    }
    
    public func startScan(uuids: [CBUUID]) {
        startScan(uuids: uuids, allowDuplicatesKey: true)
    }
    
    public func startScan(uuids: [CBUUID], allowDuplicatesKey: Bool) {
        do{
            //Check if object is not yet disposed
            try checkDisposed()
            
            guard isBluetoothEnabled() else{
                log.info("Bluetooth is not enabled")
                return;
            }
            
            
            if !_scanStarted
            {
                _scanStarted = true;
                
                log.info("Scan for peripheral started uuid filter: \(uuids)")
                
                var options = [String: Any]()
                options[CBCentralManagerScanOptionAllowDuplicatesKey] = allowDuplicatesKey
                
                manager?.scanForPeripherals(withServices: uuids, options: options)
                
                //Timer
                DispatchQueue.main.async {
                    //                    print("-- DispatchQueue.main.async: Set timer for scan timeout (CBUUID)")
                    self._timeoutTimer = Timer.scheduledTimer(timeInterval: self._scanIntervalTime, target: self, selector: #selector(self.pauseScan), userInfo: nil, repeats: false)
                }
            }
        }
        catch
        {
            log.error("Error \(error)")
            return
        }
    }
    
    public func stopScan() {
        
        guard isBluetoothEnabled() else{
            print("Bluetooth is not enabled")
            return;
        }
        
        print("Scan for peripheral stopped")
        _manager?.stopScan()
        _scanStarted = false
    }
    
    //MARK CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // ignore if disposed
        guard !_isDisposed else {
            return
        }
        
        _lockQueue.sync {
            //enabled bluetooth
            if (_lastBtState != CBManagerState.poweredOn && central.state == CBManagerState.poweredOn)
            {
                if !_scanStarted
                {
                    if uuidFilter != nil
                    {
                        startScan(uuids: uuidFilter!)
                    }
                    else
                    {
                        startScan()
                    }
                }
            }
            
            // disable bluetooth
            if(_lastBtState == CBManagerState.poweredOn && central.state != CBManagerState.poweredOff)
            {
                if _scanStarted
                {
                    stopScan()
                }
            }
        }
        
        log.info ("BT Adapter state changed from \(cbStateToBluetoothState(state: _lastBtState)) to \(cbStateToBluetoothState(state: central.state))")

        eventBluetoothStateChanged.raise(data: BluetoothStateChangedEventArgs(cbStateToBluetoothState(state: _lastBtState), cbStateToBluetoothState(state: central.state)))
        
        delegate?.peripheralManager(self, didChangeBluetoothState: cbStateToBluetoothState(state: _lastBtState), newState: cbStateToBluetoothState(state: central.state))
        
        _lastBtState = central.state
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("=== peripheralmanager: \(peripheral.name)")
        
        var connectable: Bool = true
        var uuid: String = ""
        let name: String = peripheral.name ?? "N/A"
        var manufacturerData: Data?
        
        if #available(iOS 7.0, *){
            if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSData{
                manufacturerData = data.base64EncodedData()
            }
            
            // get is connectable
            if let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber
            {
                connectable = isConnectable.int16Value > 0
            }
            uuid = peripheral.identifier.uuidString
        }
        invokePeripheralDiscovered(peripheral: PeripheralBase(peripheral: peripheral, rssi: Int(truncating: RSSI), name: name, manufacturerData: manufacturerData), connectable: connectable)
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        invokePeripheralConnected(peripheral: peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        invokePeripheralDisconencted(peripheral: peripheral, error: error)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        invokePeripheralFaildToConnect(peripheral: peripheral, error: error)
    }
    
    public func invokePeripheralDiscovered(peripheral: PeripheralBase, connectable: Bool)
    {
        
        //ignore if disposed
        guard !_isDisposed else {
            return
        }
        
        //cheack peripheral filter
        if (!checkDiscovered(peripheral: peripheral, rssi: peripheral.rssi))
        {
            log.info("Discovered invalid peripheral ignored \(peripheral.name)")
            return
        }
        
        do
        {
            // see if we can find a peripheral in our list
            var p: TPeripheral? = try find(uuid: peripheral.uuid)
            
            // peripheral not found
            if p == nil
            {
                do
                {
                    var name = peripheral.name
                    if name?.count == 0
                    {
                        name = "(no name)"
                    }
                    log.info("New peripheral found \(name)")
                    
                    var nP = TPeripheral.init(peripheral: peripheral.cbPeripheral!, rssi: peripheral.rssi, name: peripheral.name, manufacturerData: peripheral.manufacturerData)
                    nP.peripheralManager = self
                    
                    try add(peripheral: nP)
                    
                    eventPeripheralDiscovered.raise(data: PeripheralDiscoveredEventArgs(nP));
                    delegate?.peripheralManager(self, didDiscover: nP)
                }
                catch
                {
                    log.error("Faild to create and add new peripheral, \(error)" )
                }
            }
            else
            {
                //Update rssi if bigger als -105
                if peripheral.rssi > -105
                {
                    p?.rssi = peripheral.rssi
                }
                
                //Update name if changed
                if p?.name != peripheral.name
                {
                    p?.name = peripheral.name!
                }
            }
        }
        catch
        {
            log.error("Error \(error)")
            return
        }
    }
    
    public func invokePeripheralConnected(peripheral: CBPeripheral)    {
        log.info("Peripheral connected: \(peripheral.identifier.uuidString)")
        eventMyConnetedPeripheral.raise(data: CBPeripheralEventArgs(peripheral))
        delegate?.peripheralManager(self, didConnect: peripheral)
    }
    
    public func invokePeripheralDisconencted(peripheral: CBPeripheral, error: Error?)    {
        log.info("Peripheral disconnected: \(peripheral.identifier.uuidString)")
        eventMyDisconnectedPeripheral.raise(data: CBPeripheralErrorEventArgs(peripheral, error))
        delegate?.peripheralManager(self, didDisconnet: peripheral, error: error)
    }
    
    public func invokePeripheralFaildToConnect(peripheral: CBPeripheral, error: Error?){
        log.info("Peripheral faild to connect: (\(peripheral.identifier.uuidString)) Error: (\(error.debugDescription)) ")
        eventMyFailedToConnectPeripheral.raise(data: CBPeripheralErrorEventArgs(peripheral, error))
        delegate?.peripheralManager(self, didFailedToConnect: peripheral, error: error)
    }
    
    public func isBluetoothEnabled()-> Bool
    {
        return _manager?.state == CBManagerState.poweredOn
    }
    
    /**
     Control if its posible to remove peripheral. When not overriden returns allways true
     
     - parameters:
        - peripheral: TPeripheral to remove
     
     - returns:
        True if posible
     */
    public func canRemove(peripheral: TPeripheral) -> Bool {
        return true
    }
    
    /**
     Clear the peripheral list
     */
    public func clear()throws
    {
        // Check if object is not yet disposed
        try checkDisposed()
        
        var toRemove = [TPeripheral]()
        
        _peripheralsLock.sync
            {
                toRemove = peripherals;
        }
        
        //remove all peripherals
        try remove(peripheralsToRemove: toRemove)
    }
    
    public func remove(peripheral: TPeripheral)throws
    {
        //Check if object is not yet disposed
        try checkDisposed()
        
        //Call remove
        try remove(peripheralsToRemove: [peripheral])
    }
    
    public func remove(peripheralsToRemove: [TPeripheral])throws
    {
        //Check if object is not yet disposed
        try checkDisposed()
        
        for peripheral in peripheralsToRemove
        {
            //Check if peripheral can pe removed
            _peripheralsLock.sync {
                //try to remove peripheral from the peripheral list
                _peripherals.remove(at: _peripherals.index(forKey: peripheral.uuid.uuidString)!)
            }
            
            // dispose peripheral?
            if disposePeripheralOnRemove
            {
                peripheral.dispose()
            }
            
            //Trigger event
            eventPeripheralListUpdated.raise(data: EmptyEventArgs())
            delegate?.peripheralManagerDidUpdatePeripheralList(self);
        }
    }
    
    /**
     Try add peripheral to the list, if it don't already exist in the list invoke eventPeripheralAdded
     */
    public func add(peripheral: TPeripheral)throws
    {
        // Check if object is not yet disposed
        try checkDisposed()
        
        // already a peripheral with this UUID in the list?
        if (try find(uuid: peripheral.uuid)) != nil
        {
            return
        }
        
        // add peripheral to list
        _peripheralsLock.sync {
            _peripherals[peripheral.uuid.uuidString] = peripheral
        }
        
        //Trigger event
        eventPeripheralListUpdated.raise(data: EmptyEventArgs())
        delegate?.peripheralManagerDidUpdatePeripheralList(self);
    }
    
    //MARK: Object functions
    @objc private func pauseScan()
    {
        log.info("stop scaning")
        stopScan()
    }
    
    /**
     Check if the manager has been disposted
     */
    private func checkDisposed()throws
    {
        guard !_isDisposed else {
            throw BleLibraryError.objectDisposedError(objectName: "PeripheralManager is disposed")
        }
    }
    
    public func checkDiscovered(peripheral: PeripheralProtocol, rssi: Int) -> Bool
    {
        return true
    }
        
    public func find(uuid: UUID)throws -> TPeripheral?
    {
        // check if object is not yet disposed
        try checkDisposed()
        return _peripheralsLock.sync {
            if let p = _peripherals[uuid.uuidString]
            {
                return p;
            }
            return nil
        }
    }
    
    private func cbStateToBluetoothState(state: CBManagerState) -> BluetoothState{
        switch(state)
        {
        case CBManagerState.poweredOff:
            return BluetoothState.Off
        case CBManagerState.poweredOn:
            return BluetoothState.On
        case CBManagerState.unauthorized:
            return BluetoothState.Unauthorized
        case CBManagerState.unknown:
            return BluetoothState.Unknown
        case CBManagerState.unsupported:
            return BluetoothState.NotSupported
        case .resetting:
            return BluetoothState.Resetting
        }
    }
    

}
