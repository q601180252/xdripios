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
 * Class Name: ExtendedPeripheralManager.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
open class ExtendedPeripheralManager<TPeripheral: EnhancedPeripheral>:  NSObject, ExtendedPeripheralManagerProtocol,  CBCentralManagerDelegate
{
    //MARK: constants
    private let uuidFilterDefault : [CBUUID]? = nil
    private let peripheralInvisibleTimeoutDefault: Int = 10
    private let disposePeripheralOnRemoveDefault: Bool = true
    private let updateNameByAdvertisedDataDefault: Bool  = true
    
    //MARK: members
    private var _createPeripheralFunction: (PeripheralProtocol, Int)throws -> TPeripheral
    private var _scanStarted: Bool
    private var _lastBtState: CBManagerState = CBManagerState.unknown
    private var _bluetoothState: BluetoothState
    private var _peripherals: [String: TPeripheral]
    private var _updatePeripheralsTimer: Timer?
    private var _scanIntervalTime: TimeInterval = 30.0
    private var _timeoutTimer: Timer?
    private var _manager: CBCentralManager?
    private var _isBluetoothDisabled: Bool = false
    private var _isBluetoothEnabled: Bool = false
    
    private var _isDisposed: Bool = false
    private var deviceValue: String!
    let defaults = UserDefaults.standard
    
    private var _peripheralsLock = DispatchQueue(label: "ch.arendi.bleLibrary.ExtendedPeripheralManager.peripheralsLock")
    private var _lockQueue = DispatchQueue(label: "ch.arendi.bleLibrary.ExtendedPeripheralManager.lockQueue")
    
    public let log: LogProtocol = LogManager.manager.createLog(name: "ExtendedPeripheralManager")
    
    //MARK: events
    public var eventPeripheralAdded = Event<PeripheralAddedEventArgs<TPeripheral>>()
    public var eventPeripheralRemoved = Event<PeripheralRemovedEventArgs<TPeripheral>>()
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
    public var eventPeripheralListUpdated = Event<EmptyEventArgs>()
    
    //MARK: properties
    public var manager: CBCentralManager? { return _manager }
    
    public var isScanning: Bool { return _scanStarted }
    
    public var uuidFilter: [CBUUID]?
    
    public var serviceUuidFilter: [CBUUID]?
    
    public var onBluetoothOff: (() -> Void)?
    
    public var onBluetoothOn: (() -> Void)?
    
    public var onPauseScan:(() -> Void)?
    
    public var peripherals: [TPeripheral]
    {
        return _peripheralsLock.sync {
            return _peripherals.values.lazy.toArray()
        }
    }
    
    public var peripheralInvisibleTimeout: Int
    
    public var disposePeripheralOnRemove: Bool
    
    public var updateNameByAdvertisedData: Bool
    
    public var bluetoothState: BluetoothState { return _bluetoothState }
    
    public var isDisposed: Bool { return _isDisposed }
    
    weak open var delegate: PeripheralManagerBaseDelegate?
    
    //MARK: init
    public init(_ checkBtEnabled: Bool, createPeripheralFunction: @escaping (PeripheralProtocol, Int)throws -> TPeripheral) {
        
        _peripherals = [String: TPeripheral]()
        uuidFilter = uuidFilterDefault
        serviceUuidFilter = uuidFilterDefault
        peripheralInvisibleTimeout = peripheralInvisibleTimeoutDefault
        disposePeripheralOnRemove = disposePeripheralOnRemoveDefault
        updateNameByAdvertisedData = updateNameByAdvertisedDataDefault
        
        _createPeripheralFunction = createPeripheralFunction
        
        _scanStarted = false
        
        _bluetoothState = BluetoothState.Off
    
        super.init()
        
        // ----- Init manager -----
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
        
        _manager?.delegate = self
    }
    
    //MARK: Functions
    open func dispose() {
        // mark object as disposed
        _isDisposed = true
        
        _lockQueue.sync {
            
            if _updatePeripheralsTimer != nil
            {
                _updatePeripheralsTimer?.invalidate()
                _updatePeripheralsTimer = nil
            }
            
            if _timeoutTimer != nil
            {
                _timeoutTimer?.invalidate()
                _timeoutTimer = nil
            }
            
            if _scanStarted
            {
                stopScan()
                _scanStarted = false
            }
            
            _manager?.delegate = nil
            
            
            // check if peripheral needs to be disposed
            if disposePeripheralOnRemove
            {
                // disposed all managed peripehrals
                _peripheralsLock.sync {
                    let items : [TPeripheral] = _peripherals.values.lazy.toArray()
                    for p in items
                    {
                        p.dispose()
                    }
                    _peripherals.removeAll()
                }
            }
        }
    }
    
    public func startScan() {
        startScan(allowDuplicatesKey:true)
    }
    
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
        startScan(uuids: uuids, allowDuplicatesKey: false)
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
                serviceUuidFilter = uuids
                
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
            log.info("Bluetooth is not enabled")
            return;
        }
        
        log.info("Scan for peripheral stopped")
        serviceUuidFilter = nil
        manager?.stopScan()
        _scanStarted = false
        eventIsBusyChanged.raise(data: IsBusyEventArgs(false))
    }
    
    public func isBluetoothEnabled() -> Bool {
        return _manager?.state == CBManagerState.poweredOn;
    }
    
    /**
     Try add peripheral to the list, if it don't already exist in the list
     invoke eventPeripheralAdded
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
        
        // trigger events
        eventPeripheralAdded.raise(data: PeripheralAddedEventArgs<TPeripheral>(peripheral))
        eventPeripheralListUpdated.raise(data: EmptyEventArgs());
    }
    
    
    public func clear() throws {
        // check if object is not yet disposed
        try checkDisposed()
        
        // get a list of all peripherals to be removed
        var peripheralsToRemove = [TPeripheral]()
        
        _peripheralsLock.sync {
            peripheralsToRemove = _peripherals.values.lazy.toArray()
        }
        
        // remove all peripherals
        try remove(peripheralsToRemove: peripheralsToRemove)
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
            if canRemove(peripheral: peripheral)
            {
                do{
                try peripheral.teardown()
                }catch{/*ignore error*/}
                
                // dispose peripheral?
                if disposePeripheralOnRemove
                {
                    peripheral.dispose()
                }
                
                //Check if peripheral can pe removed
                _peripheralsLock.sync {
                    //try to remove peripheral from the peripheral list
                    _peripherals.remove(at: _peripherals.index(forKey: peripheral.uuid.uuidString)!)
                }
                
                //Trigger event
                eventPeripheralRemoved.raise(data: PeripheralRemovedEventArgs<TPeripheral>(peripheral))
                eventPeripheralListUpdated.raise(data: EmptyEventArgs());
            }
        }
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
            
//            manager?.retrievePeripherals(withIdentifiers: <#T##[UUID]#>)
            return nil
        }
    }
    
    open func canRemove(peripheral: TPeripheral) -> Bool {
        return true
    }
    
    //MARK: CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // ignore if disposed
        guard !_isDisposed else {
            return
        }
        
        _lockQueue.sync {
            //enabled bluetooth
            if (_lastBtState != CBManagerState.poweredOn && central.state == CBManagerState.poweredOn)
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
            
            // disable bluetooth
            if(_lastBtState == CBManagerState.poweredOn && central.state != CBManagerState.poweredOff)
            {
                if _scanStarted
                {
                    stopScan()
                }
            }
        }
        
        if central.state == CBManagerState.poweredOff
        {
            _isBluetoothEnabled = false
            _isBluetoothDisabled = true
            onBluetoothOff?()
        }
        else if central.state == CBManagerState.poweredOn
        {
            _isBluetoothEnabled = true
            _isBluetoothDisabled = false
            onBluetoothOn?()
        }
        else
        {
            _isBluetoothEnabled = false
            _isBluetoothDisabled = false
            onBluetoothOff?()
            
        }
  

        log.info ("BT Adapter state changed from \(cbStateToBluetoothState(state: _lastBtState)) to \(cbStateToBluetoothState(state: central.state))")
        
        eventBluetoothStateChanged.raise(data: BluetoothStateChangedEventArgs(cbStateToBluetoothState(state: _lastBtState), cbStateToBluetoothState(state: central.state)))
        
        _lastBtState = central.state
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name == "B3_OTA") {
            central.connect(peripheral)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                central.cancelPeripheralConnection(peripheral)
            }
            return;
        }

        var connectable: Bool = true
        var uuid: String = ""
        let name: String = peripheral.name ?? "N/A"
        var localName: NSString?
        var manufacturerData: Data?
        
        if #available(iOS 7.0, *){
            if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data{
                manufacturerData = data
            }
            
            // get is connectable
            if let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber
            {
                connectable = isConnectable.int16Value > 0
            }
            uuid = peripheral.identifier.uuidString
            
            // get local name
            localName = advertisementData[CBAdvertisementDataLocalNameKey] as? NSString
                    
        }
        log.info("Peripheral discovered (name: \(name) uuid: \(uuid)")
        
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
    
    //MARK function that can be override
    open func invokePeripheralDiscovered(peripheral: PeripheralBase, connectable: Bool)
    {
        
        //ignore if disposed
        guard !_isDisposed else {
            return
        }
        
        //cheack peripheral filter
        if (!checkDiscovered(peripheral: peripheral, rssi: peripheral.rssi))
        {
            log.info("Discovered invalid peripheral ignored \(peripheral.name ?? "(\(peripheral.uuid.uuidString))")")
            return
        }
        
        let specificDataChecked: Bool = false //defaults.bool(forKey: "manufacturerData")
        if let peripheralName = defaults.string(forKey: "peripheralName"){
            deviceValue = "Bubble Nano, B3_OTA"
        }
        
        do
        {
            // see if we can find a peripheral in our list
            let p: TPeripheral? = try find(uuid: peripheral.uuid)
            
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
                    
                    if name == "Bubble Nano" {
                        print("find bubble nano")
                    }
                    log.info("New peripheral found \(name ?? " - ")")
                    
                    // create manageable object
                    let newPeripheral = try _createPeripheralFunction(peripheral, peripheral.rssi)
 
                    // set initial RSSI value
                    try newPeripheral.setRssi(rssi: peripheral.rssi)
                    
                    // set initial isConnectable
                    try newPeripheral.setIsConnectable(isConnectable: connectable)
                    
                    // set initial last seen
                    newPeripheral.lastSeen = Date()
                    
                    if (matchManufacturerSpecificData(advertisementData: peripheral.manufacturerData, manufacturerSpecificData: specificDataChecked) || serviceUuidFilter != nil){
                        try add(peripheral: newPeripheral)
                        eventPeripheralDiscovered.raise(data: PeripheralDiscoveredEventArgs(newPeripheral))
                        delegate?.peripheralManager(self, didDiscover: newPeripheral)
                    } else if (matchName(advertisementData: peripheral.name, deviceName: deviceValue ?? "") || serviceUuidFilter != nil){
                        try add(peripheral: newPeripheral)
                        eventPeripheralDiscovered.raise(data: PeripheralDiscoveredEventArgs(newPeripheral))
                        delegate?.peripheralManager(self, didDiscover: newPeripheral)
                    } else if (!specificDataChecked && (deviceValue == nil || deviceValue == "")){
                        try add(peripheral: newPeripheral)
                        eventPeripheralDiscovered.raise(data: PeripheralDiscoveredEventArgs(newPeripheral))
                        delegate?.peripheralManager(self, didDiscover: newPeripheral)
                    }
                } catch {
                    log.error("Faild to create and add new peripheral, \(error)" )
                }
            }
            else {
                //Todo for compleat bleLibrary implementation add control if found peripheral is virtual
                //Check if the found peripheral is currently virtual (-> no real peripheral object behind)
                if p?.peripheral == nil {
                    // set peripheral
                    try p?.setPeripheral(peripheral: peripheral)
                } else {
                    // update peripheral info as is connectable and name
                    try p?.setName(name: peripheral.name ?? "-" )
                    try p?.setIsConnectable(isConnectable: connectable)
                }
                
                
                //Update rssi if bigger als -105
                if peripheral.rssi > -105
                {
                    try p?.setRssi(rssi: peripheral.rssi)
                }
                
                //Update name if changed
                if p?.name != peripheral.name
                {
                    try p?.setName(name: peripheral.name!)
                }
                
                p?.lastSeen = Date()
            }
        }
        catch
        {
            log.error("Error \(error)")
            return
        }
    }
    
    open func invokePeripheralConnected(peripheral: CBPeripheral)    {
        log.info("Peripheral connected: \(peripheral.identifier.uuidString)")
        eventMyConnetedPeripheral.raise(data: CBPeripheralEventArgs(peripheral))
        delegate?.peripheralManager(self, didConnect: peripheral)
    }
    
    open func invokePeripheralDisconencted(peripheral: CBPeripheral, error: Error?)    {
        log.info("Peripheral disconnected: \(peripheral.identifier.uuidString)")
        eventMyDisconnectedPeripheral.raise(data: CBPeripheralErrorEventArgs(peripheral, error))
        delegate?.peripheralManager(self, didDisconnet: peripheral, error: error)
    }
    
    open func invokePeripheralFaildToConnect(peripheral: CBPeripheral, error: Error?){
        log.info("Peripheral faild to connect: (\(peripheral.identifier.uuidString)) Error: (\(error.debugDescription)) ")
        eventMyFailedToConnectPeripheral.raise(data: CBPeripheralErrorEventArgs(peripheral, error))
        delegate?.peripheralManager(self, didFailedToConnect: peripheral, error: error)
    }
    
    /**
     Method that check if a discovered peripheral is valid or should be ignored. If this method is
     not overwritten any peripheral is valid
     
     Note, should add Advertising info list class add more info to contoll if it is the peripheral
     you are looking for
     */
    public func checkDiscovered(peripheral: PeripheralProtocol, rssi: Int) -> Bool
    {
        return peripheral.name == "Bubble Nano"
//        return true
    }
    
    
    //MARK: private functions
    /**
     * Timer to update the peripheral list elapsed
     */
    private func onUpdatePeripheralsTimerElapsed()throws
    {
        // ignore if disposed
        guard !isDisposed else {
            return
        }
        
        var itemsToRemove = [TPeripheral]()
        
        _peripheralsLock.sync {
            // find directory keys of the items to be removed
            let items : [TPeripheral] = _peripherals.values.lazy.toArray()
            for item in items
            {
                if item.peripheral != nil
                {
                    // update last activity if device is connected
                    if item.peripheral?.isConnected ?? false
                    {
                        item.lastSeen = Date()
                    }
                }
                
                // check if the device has to be removed
                if peripheralInvisibleTimeout > 0 && (item.lastSeen.addingTimeInterval(Double(peripheralInvisibleTimeout/1000)).compare(Date()) == ComparisonResult.orderedAscending)
                {
                    if canRemove(peripheral: item)
                    {
                        itemsToRemove.append(item)
                    }
                }
            }
        }
        
        // remove peripheral from the list
        try remove(peripheralsToRemove: itemsToRemove)
    }
    
    /**
     * Method called in methods to check if the object is disposed.
     */
    private func checkDisposed()throws
    {
        // ignore if disposed
        if isDisposed
        {
            throw BleLibraryError.objectDisposedError(objectName: "ExtendedPeripheralManager")
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
    
    //MARK: Object functions
    @objc private func pauseScan()
    {
        log.info("stop scaning")
        stopScan()
        onPauseScan?()
    }
    
    //MARK: - Scan Filter Functions
    
    func matchManufacturerSpecificData(advertisementData: Data?, manufacturerSpecificData: Bool) -> Bool{
        if(!manufacturerSpecificData){
            return false
        }
        
        if let data = advertisementData{
            if(data.count >= 2){
                let manufactureID = UInt16(data[0]) + UInt16(data[1]) << 8
                if(manufactureID == 866){
                    return true
                }
            }
        }
        
        return false
    }
    
    func matchName(advertisementData: String?, deviceName: String) -> Bool{
        if(deviceName.contains("")){
            return false
        }
        
        if let device = advertisementData {
            return deviceName.contains(device)
        }
        
        return false
    }
    
    

    
    
}
