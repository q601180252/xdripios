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
 * Class Name: FotaController.swift
 ******************************************************************************/

import BleLibrary
import Foundation
import os.log
import CoreBluetooth
public class FotaController: UpdateProviderProtcol, DataExchangeProtocol
{
    //MARK: constans
    private let _serviceUuidDefault = "b2152466-d600-11e8-9f8b-f2801f1b9fd1";
    private let _dataCharacteristicUuid = "b2152466-d601-11e8-9f8b-f2801f1b9fd1";
    private let _deviceIdCharacteristicUuid = "b2152466-d602-11e8-9f8b-f2801f1b9fd1";
    private let _bootloaderVersionCharacteristicUuid = "b2152466-d603-11e8-9f8b-f2801f1b9fd1";
    private let _bleStackVersionCharacteristicUuid = "b2152466-d604-11e8-9f8b-f2801f1b9fd1";
    private let _applicationVersionCharacteristicUuid = "b2152466-d605-11e8-9f8b-f2801f1b9fd1";
    private let _bleStackBuildIdCharacteristicUuid = "b2152466-d606-11e8-9f8b-f2801f1b9fd1";
    private let _enterFotaCharacteristicUuid = "b2152466-d607-11e8-9f8b-f2801f1b9fd1";
    private let _fotaTimeout: Int = 120 * 1000; // [s]
    
    //MARK: Events
    /**
     Event triggered to indicate the progress of the Fota
     */
    public var eventProgress = Event<FotaProgressEventArgs>()
    
    /**
     Event triggered to indicate the end of the Fota
     */
    public var eventCompleted = Event<FotaCompletedEventArgs>()
    
    /**
     Event triggered when data received
     */
    var eventDataRecived = Event<DataReceivedEventArgs>()
    
    internal var eventFrameDataReceived = Event<DataReceivedEventArgs>()
    
    //MARK: EventHandler
    private var _onDataReceivedHandler: EventHandlerProtocol?
    private var _onProgressChangedHandler: EventHandlerProtocol?
    private var _onNotificationReceivedHandler: EventHandlerProtocol?
    
    //MARK: Properties
    /**
     The device id of the connected device
     */
    public var deviceId: Data? { return _deviceId }
    
    /**
     The bootloader version of the connected device
     */
    public var bootloaderVersion: FotaFirmwareVersion? { return _bootloaderVersion }
    
    /**
     The ble stack version of the connected device
     */
    public var bleStackVersion: FotaFirmwareVersion? { return _bleStackVersion }
    
    /**
     The application version of the connected device
     */
    public var applicationVersion: FotaFirmwareVersion? { return _applicationVersion }
    
    /**
     The FOTA buildid of the connected device
     */
    public var FotaBuildId: Data? { return _fotaBuildId }
    
    //MARK: Members
    private var _deviceId: Data?
    private var _bootloaderVersion: FotaFirmwareVersion?
    private var _bleStackVersion: FotaFirmwareVersion?
    private var _applicationVersion: FotaFirmwareVersion?
    private var _fotaBuildId:Data?
    
    private var _serviceUuid: String?
    private var _hdlcFlowControl: HdlcFlowControl?
    private var _lowerCobs: CobsFraming?
    private var _dataCharacteristic: CharacteristicsProtocol?
    private var _deviceIdCharacteristic: CharacteristicsProtocol?
    private var _bootloaderVersionCharacteristic: CharacteristicsProtocol?
    private var _bleStackVersionCharacteristic: CharacteristicsProtocol?
    private var _applicationVersionCharacteristic: CharacteristicsProtocol?
    private var _bleStackBuildIdCharacteristic: CharacteristicsProtocol?
    private var _enterFotaCharacteristic: CharacteristicsProtocol?
    private var _fotaFrameHandler: FotaFrameHandler?
    private var _selected: PeripheralProtocol?
    private var _fotaOptions: FotaOptions?
    private var _updateStep: FotaUpdateStep?
    var maxDataLength: Int
    {
//        log.info("Max data length: \(_selected?.maxWriteLength ?? 20)")
        return _selected?.maxWriteLength ?? 20
    }
    private let log: LogProtocol = LogManager.manager.createLog(name: "FotaController")
    
    
    //MARK: Init
    public init()
    {
        if _lowerCobs == nil
        {
            _lowerCobs = CobsFraming(dataExchange: self, crcProvider: CcittCrcProvider())
            _lowerCobs?.maxDataLength = 258
        }
        
        if _hdlcFlowControl == nil
        {
            var _hdlcConfig = HdlcConfiguration()
            _hdlcConfig.maxDataLength = 160
            _hdlcConfig.transmitWindowSize = 4
            _hdlcConfig.transmitMaxRetryCount = 2
            _hdlcConfig.transmitAcknowledgeTimeout = 500
            
            _hdlcFlowControl = HdlcFlowControl(dataExchange: _lowerCobs!, configuration: _hdlcConfig)
        }
        
        
        if _fotaFrameHandler == nil
        {
            _fotaFrameHandler = FotaFrameHandler(dataExchange: _hdlcFlowControl!)
            
            _onDataReceivedHandler = _fotaFrameHandler!.eventDataRecived.addHandler(self, FotaController.fotaFrameHandlerOnDataRecived)
            _onProgressChangedHandler = _fotaFrameHandler!.eventProgressChanged.addHandler(self, FotaController.fotaFrameHandlerOnProgressChanged)
        }
        
        _serviceUuid = _serviceUuidDefault
        
    }
    
    /**
     Summary: Blocking update method
     
     - parameters: 
        - peripheral: Peripheral that gets updated
        - source: Source for the update process. See implementation update precess for details
        - options: Options for the update process. See implementation update process for details.
     */
    public func update(periheral: EnhancedPeripheralProtocol, source: Any, options: Any)throws {
        do
        {
            guard let fotafile = source as? FotaFile else {
                throw FotaError.General(message: "Invalid source. The source has be from type FotaFile", status: FotaStatus.genaralError)
            }
            
            var fotaOptions = options as? FotaOptions
            if fotaOptions == nil
            {
                fotaOptions = FotaOptions()
            }
            
            if fotafile.fotaImage.fotaServiceUuid != nil
            {
                _serviceUuid = fotafile.fotaImage.fotaServiceUuid.uuidString
            }
            
            try update(peripheral: periheral, source: fotafile, options: fotaOptions!)
            onCompleted(status: FotaStatus.success)

        }
        catch FotaError.General(let message, let status)
        {
           onCompleted(status: status)
           throw FotaError.General(message: message, status: status)
        }
        catch
        {
            log.error("Exception in FotaController.Completed handler: \(error)")
            onCompleted(status: FotaStatus.genaralError)
            throw error
        }
    }
    
    private func onCompleted(status: FotaStatus)
    {
        do
        {
            eventCompleted.raise(data: FotaCompletedEventArgs(status: status))
            dispose()
        }
        catch
        {
            log.error("\(error)")
        }
    }
    
    private func setUpdateStep(step: FotaUpdateStep)
    {
        _updateStep = step;
        onProgress(current: 0, total: 0)
    }
    
    private func update(peripheral: EnhancedPeripheralProtocol, source: FotaFile, options: FotaOptions)throws
    {
        setUpdateStep(step: FotaUpdateStep.idle)
        _selected = peripheral.peripheral
        _fotaOptions = options
        repeat
        {
            if !_selected!.isConnected
            {
                log.info("Peripheral is not connected, connect")
                setUpdateStep(step: FotaUpdateStep.connect)
                try connect(peripheral: _selected!)
            }
            
            try initPripheral(peripheral: _selected!, options: options)
            
            if !isInBootloader()
            {
                log.info("Peripheral is not in bootloader, reboot")
                setUpdateStep(step: FotaUpdateStep.rebootToBootLoader)
                try rebootToBootloader()
                continue;
            }
            
            if bootloaderVersion != nil
            {
                log.info("Bootloaderversion: \(bootloaderVersion?.description)")
            }

            if bleStackVersion != nil
            {
                log.info("BleStackVersion: \(bleStackVersion?.description)")
            }

            if applicationVersion != nil
            {
                log.info("ApplicationVersion: \(applicationVersion?.description)")
            }

            try checkDeviceId(file: source)

            guard _fotaBuildId != nil else
            {
                log.info("FotaBuildId is nil, update not permitted")
                throw FotaError.General(message: "Failed to read FotaBuildId", status: FotaStatus.genaralError)
            }
            
            if options.forceUpdate! && _updateStep != FotaUpdateStep.updateAppImage
            {
                log.info("Update of bootloader forced")
                setUpdateStep(step: FotaUpdateStep.updateFotaImage)
                onProgress(current: 0, total: 0)
            }
                //Fota image update only required if build ids don't match
            else if !_fotaBuildId!.elementsEqual(source.fotaImage.buildId)
            {
                log.info("FotaBuildIds not equal, update fota image first")
                setUpdateStep(step: FotaUpdateStep.updateFotaImage)
                onProgress(current: 0, total: 0)
            }
            else
            {
                log.info("FotaBuildIds are equal, update app image: \(source.AppImage.version.description)")
                setUpdateStep(step: FotaUpdateStep.updateAppImage)
                onProgress(current: 0, total: 0)
            }

            do
            {
                try initializeDataCharacteristic(peripheral: _selected!)

                if _updateStep == FotaUpdateStep.updateFotaImage
                {
                    log.info("Update fota image: \(source.fotaImage.version.description)")
                    try sendFirmware(data: source.fotaImage.imageData)
                    setUpdateStep(step: FotaUpdateStep.updateAppImage)
                    onProgress(current: 0, total: 0)
                }
                else
                {
                    log.info("Update App image: \(source.AppImage.version.description)")
                    try sendFirmware(data: source.AppImage.imageData)
                    setUpdateStep(step: FotaUpdateStep.finished)
                }
            }
            catch
            {
                log.error("\(error)")
                throw error
            }
            
            if _selected!.isConnected
            {
                do
                {
                    Thread.sleep(until: Date().addingTimeInterval(1))
                    try _selected?.disconnect(timeout: Constants.disconnectTimeout)
                }
                catch
                {
                    log.error("Teardown failed")
                }
            }
            
            // give ble stack time to completly disconnect
            Thread.sleep(until: Date().addingTimeInterval(4))
            
            deinitializeDataCharacteristic(peripheral: _selected!)
            
        }while _updateStep != FotaUpdateStep.finished
        
        log.info("Update finished with success")
    }
    
    private func sendFirmwareFinal()
    {
        if _selected!.isConnected
        {
            DispatchQueue.main.asyncAfter(deadline: (.now() + .milliseconds(200)))
            {
                do
                {
                    try self._selected!.disconnect(timeout: Constants.disconnectTimeout)
                }
                catch
                {
                    self.log.error("Teardown failed")
                }
            }
        }
        
        deinitializeDataCharacteristic(peripheral: _selected!)
    }
    
    private func checkDeviceId(file: FotaFile)throws
    {
        guard file.fotaImage != nil else
        {
            throw FotaError.General(message: "No fota image provided, update not permitted", status: FotaStatus.genaralError)
        }
        
        guard _deviceId != nil || file.fotaImage.deviceId != nil else {
            throw FotaError.General(message: "Device id not set, update not permitted", status: FotaStatus.genaralError)
        }
        
        if _deviceId!.elementsEqual([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        {
            // all images are valid when device id is 0
            log.info("Device id is 0, update permitted")
            return
        }
        
        guard _deviceId!.elementsEqual(file.fotaImage.deviceId) else
        {
            throw FotaError.General(message: "Device ids are not equal, update not permitted", status: FotaStatus.deviceIdMismatch)
        }
        
        if file.AppImage != nil
        {
            guard file.AppImage.deviceId != nil || _deviceId!.elementsEqual(file.AppImage.deviceId) else
            {
                throw FotaError.General(message: "Device ids are not equal, update not permitted", status: FotaStatus.deviceIdMismatch)
            }
        }
        
        log.info("Device ids match update permitted")
    }
    
    var _disconnected: DispatchSemaphore?
    var _dfuPeripheralFound: DispatchSemaphore?
    var _dfuPeripiheral: PeripheralProtocol?
    
    private func onDisconnected(args: DisconnectedEventArgs)
    {
        _disconnected?.signal()
    }
    
    private func onPeripheralDiscovered(args: PeripheralDiscoveredEventArgs)
    {
            if(self._dfuPeripiheral == nil)
            {
                self._dfuPeripiheral = (args.peripheral as! EnhancedPeripheral).peripheral
                self._dfuPeripheralFound?.signal()
            }
    }
    
    private func rebootToBootloader()throws
    {
        //Event handler disconnect
        _disconnected = DispatchSemaphore(value: 0)
        var peripheralOnDisconnectedHandler: EventHandlerProtocol
        
        do
        {
            // register for disconnected to detect entering bootloader
            peripheralOnDisconnectedHandler = _selected!.eventDisconnected.addHandler(self, FotaController.onDisconnected)
            
            
            // enter bootloader
            if _fotaOptions!.rebootToBootloaderFunc != nil
            {
                // enter bootloader and get the dfu peripheral
                _dfuPeripiheral = _fotaOptions!.rebootToBootloaderFunc!(_selected!)
            }
            else
            {
                if _enterFotaCharacteristic == nil
                {
                    throw FotaError.General(message: "Failed to reboot into bootloader, enter fota characteristic not available", status: FotaStatus.genaralError)
                }
                
                do
                {
                    try _enterFotaCharacteristic?.writeData(Data([0x01]), WriteType.general ,Constants.writeDataTimeout)
                }
                catch
                {
                    //TODO Ignor connection lost error
                    log.error("\(error)")
                }
            }
            
            // wait for disconnected
            let success = _disconnected!.wait(timeout: (.now() + .milliseconds(10000)))
            
            // no disconnect detected?
            if success == DispatchTimeoutResult.timedOut
            {
                log.info("Disconnect timeout, force disconnect")
                do
                {
                    try _selected!.disconnect(timeout: Constants.disconnectTimeout)
                }
                catch
                {
                    log.info("Disconnect failed \(error)")
                }
            }
            else
            {
                log.info("Device properly disconnected")
            }
            
            Thread.sleep(until: Date().addingTimeInterval(Double((_fotaOptions?.delayAfterDisconnect)!)/1000))

            peripheralOnDisconnectedHandler.dispose()
        }
        catch
        {
            peripheralOnDisconnectedHandler.dispose()
            log.error("Failed to reboot to bootloader, \(error)")
            throw FotaError.General(message: "Failed to reboot to bootloader", status: FotaStatus.genaralError)
        }
        
        // search for device in DFU mode
        if _dfuPeripiheral == nil
        {
            log.info("Search for device in FOTA mode")
            _dfuPeripheralFound = DispatchSemaphore(value: 0)
            var centralOnPeripheralDiscoveredHandler: EventHandlerProtocol
            
            do
            {
                centralOnPeripheralDiscoveredHandler = (_selected!.peripheralManager?.eventPeripheralDiscovered.addHandler(self, FotaController.onPeripheralDiscovered))!

                try _selected?.peripheralManager?.clear()
                _selected!.peripheralManager?.startScan(uuids: [CBUUID(string: _serviceUuid!)], allowDuplicatesKey: false)
                
                // wait for response
                let found = _dfuPeripheralFound?.wait(timeout: (.now() + .milliseconds(10000)))
                
                if found == DispatchTimeoutResult.timedOut
                {
                    log.error("Device in FOTA mode not found")
                    throw FotaError.General(message: "No device in FOTA mode found", status: FotaStatus.genaralError)
                }
                
                centralOnPeripheralDiscoveredHandler.dispose()
                _selected!.peripheralManager?.stopScan()
                Thread.sleep(until: Date().addingTimeInterval(0.5))
            }
            catch FotaError.General(let message, let status)
            {
                throw FotaError.General(message: message, status: status)
            }
            catch
            {
                log.error("Exception while searching for peripheral: \(error)")
                throw error
            }
            
            //set new peripheral
            _selected = _dfuPeripiheral!
            _dfuPeripiheral = nil
        }
    }
    
    private func connect(peripheral: PeripheralProtocol)throws
    {
        var exception: Error? = nil
        for i in 0..<3
        {
            do
            {
                log.info("Start connecting to peripheral")
                try peripheral.connect(timeout: Constants.connectTimeout)
                log.info("Start discover services")
                setUpdateStep(step: FotaUpdateStep.discoverServices)
                try peripheral.discoverServices(timeout: Constants.discoverServicesTimeout)
                log.info("Peripheral ready")
                return
            }
            catch
            {
                exception = error
            }
            
            log.info("Failed to connect to device")
            if exception != nil
            { throw exception! }
        }
    }
    
    private func onProgress(current: Int, total: Int)
    {
        eventProgress.raise(data: FotaProgressEventArgs(current: current, total: total, step: _updateStep!))
    }
    
    private func isInBootloader() -> Bool
    {
        if _selected!.cbState != CBPeripheralState.connected
        {
            return false
        }
        
        if _selected!.findCharacteristic(uuid: _dataCharacteristicUuid) != nil
        {
            return true
        }
        
        return false
    }
    
    private var disconnectedAutoResetEvent: DispatchSemaphore?
    private var frameRecivedAutoResetEvent: DispatchSemaphore?
    private var waitResponsGroup: DispatchGroup?
    private var frameReceivedHandler: EventHandlerProtocol?
    private var disconnectedHandler: EventHandlerProtocol?
    private var outFrame: Data?
    
    private func onFrameRecived(args: DataReceivedEventArgs)
    {
        outFrame = args.data
        waitResponsGroup?.leave()
    }
    
    private func onDisconnectedOnSendFirmware(args: DisconnectedEventArgs)
    {
        waitResponsGroup?.leave()
    }
    
    private func sendFirmware(data: Data)throws
    {
        waitResponsGroup = DispatchGroup()
        outFrame = Data()
        
        do
        {
            frameReceivedHandler = _fotaFrameHandler?.eventDataRecived.addHandler(self, FotaController.onFrameRecived)
            disconnectedHandler = _selected!.eventDisconnected.addHandler(self, FotaController.onDisconnectedOnSendFirmware)
            waitResponsGroup?.enter()
            try _fotaFrameHandler?.imageDownload(imageData: data)
            
            let r = waitResponsGroup?.wait(timeout: (.now() + .milliseconds(_fotaTimeout)))
            
            if r == DispatchTimeoutResult.timedOut
            {
                throw BleLibraryError.timeoutError(message: "Failed to transmit firmware file", result: nil)
            }
            
            frameReceivedHandler?.dispose()
            disconnectedHandler?.dispose()
        }
        catch
        {
            log.error("\(error)")
            throw error
            frameReceivedHandler?.dispose()
            disconnectedHandler?.dispose()
        }
        
        if(outFrame == nil || outFrame!.count < 6)
        {
            throw FotaError.General(message: "No response received", status: FotaStatus.genaralError)
        }
//        print("TempPrint: DR outFrame data: 0x\(BinaryString.toString(buffer: (outFrame?.toArray())!))")
        let status = FotaStatus.init(rawValue: outFrame![1])
        
        guard status == FotaStatus.success else
        {
            throw FotaError.General(message: "\(status?.description ?? "-")", status: status!)
        }
        
    }
    
    private func initPripheral(peripheral: PeripheralProtocol, options: FotaOptions)throws
    {
        let productService = peripheral.findService(uuid: _serviceUuidDefault)
        guard productService != nil else
        {
            log.error("Update service not found!")
            throw BleLibraryError.serviceNotFound(message: "Service not found", result: nil)
        }
        
        _deviceIdCharacteristic = (productService?.getCharacteristic(uuid: _deviceIdCharacteristicUuid))
        _bootloaderVersionCharacteristic = (productService?.getCharacteristic(uuid: _bootloaderVersionCharacteristicUuid))
        _bleStackVersionCharacteristic = (productService?.getCharacteristic(uuid: _bleStackVersionCharacteristicUuid))
        _applicationVersionCharacteristic = (productService?.getCharacteristic(uuid: _applicationVersionCharacteristicUuid))
        _bleStackBuildIdCharacteristic = (productService?.getCharacteristic(uuid: _bleStackBuildIdCharacteristicUuid))
        _enterFotaCharacteristic = (productService?.getCharacteristic(uuid: _enterFotaCharacteristicUuid))
        
        do
        {
            if _deviceIdCharacteristic != nil
            {
                try _deviceIdCharacteristic!.readData(Constants.readDataTimeout)
                _deviceId = _deviceIdCharacteristic!.value
            }
        }
        catch
        {
            log.error("\(error)")
        }
        
        do
        {
            if _bootloaderVersionCharacteristic != nil
            {
                try _bootloaderVersionCharacteristic!.readData(Constants.readDataTimeout)
                _bootloaderVersion = FotaFirmwareVersion()
                try _bootloaderVersion?.setVersion(data: (_bootloaderVersionCharacteristic?.value)!)
            }
        }
        catch
        {
            log.error("\(error)" )
        }
        
        do
        {
            if _bleStackVersionCharacteristic != nil
            {
                try _bleStackVersionCharacteristic!.readData(Constants.readDataTimeout)
                _bleStackVersion = FotaFirmwareVersion()
                try _bleStackVersion?.setVersion(data: (_bleStackVersionCharacteristic?.value)!)
            }
        }
        catch
        {
            log.error("\(error)" )
        }
        
        do
        {
            if _applicationVersionCharacteristic != nil
            {
                try _applicationVersionCharacteristic!.readData(Constants.readDataTimeout)
                _applicationVersion = FotaFirmwareVersion()
                try _applicationVersion?.setVersion(data: (_applicationVersionCharacteristic?.value)!)
            }
        }
        catch
        {
            log.error("\(error)" )
        }
        
        do
        {
            if _bleStackBuildIdCharacteristic != nil
            {
                _ = try _bleStackBuildIdCharacteristic!.readData(Constants.readDataTimeout)
                _fotaBuildId = _bleStackBuildIdCharacteristic!.value
            }
        }
        catch
        {
            log.error("\(error)" )
        }
    }
    
    private func fotaFrameHandlerOnProgressChanged(args: ProgressChangedEventArgs)
    {
         onProgress(current: args.current, total: args.total)
    }
    
    private func initializeDataCharacteristic(peripheral: PeripheralProtocol)throws
    {
        let productService = peripheral.findService(uuid: _serviceUuidDefault)
        guard productService != nil else
        {
            log.error("update service not found!")
            throw BleLibraryError.serviceNotFound(message: "Service not found", result: nil)
        }
        
        _dataCharacteristic = productService?.getCharacteristic(uuid: _dataCharacteristicUuid)
        
        if ((_dataCharacteristic?.permission)! & CharacteristicPermissions.writeable.rawValue) != CharacteristicPermissions.writeable.rawValue
        {
            log.error("Data characteristic is not writable")
            throw BleLibraryError.notSupportedError(message: "Data characteristic is not writable", result: nil)
        }
        
        _onNotificationReceivedHandler = _dataCharacteristic?.eventNotificationReceived.addHandler(self, FotaController.onDataNotificationReceived )
        try _dataCharacteristic?.changeNotification(true, Constants.writeDataTimeout)
        try _lowerCobs?.initializeDataExchange()
        try _hdlcFlowControl?.initializeDataExchange()
    }
    
    private func deinitializeDataCharacteristic(peripheral: PeripheralProtocol)
    {
        _onNotificationReceivedHandler?.dispose()
    }
    
    //MARK: DataExchangeProtocol
    func initializeDataExchange() {
        // Not in use
    }
    
    func transmit(buffer: Data) throws {
//        print("TempPrint: buffer [0x\(BinaryString.toString(buffer: buffer.toArray()))]")
        log.info("Data to send length: \(buffer.count)")
        try _dataCharacteristic?.writeData(buffer, WriteType.general, Constants.writeDataTimeout)
    }

    private func fotaFrameHandlerOnDataRecived(args: DataReceivedEventArgs)
    {
//        print("FC- fotaFrameHandlerOnReciedData: \(BinaryString.toString(buffer: args.data.toArray()))")
        log.info("Data received")
        eventFrameDataReceived.raise(data: DataReceivedEventArgs(data: args.data))
    }
    
    private func onDataNotificationReceived(args: NotificationReceivedEventArgs)
    {
//        print("FC- onDataNotificationReceived: \(BinaryString.toString(buffer: args.data.toArray()))")
        log.info("Data notification received")
        eventDataRecived.raise(data: DataReceivedEventArgs(data: args.data))
    }
    
    public func dispose()
    {
        _fotaFrameHandler?.dispose()
        _fotaFrameHandler = nil
        _lowerCobs?.dispose()
        _lowerCobs = nil
        _hdlcFlowControl?.dispose()
        _hdlcFlowControl = nil
    }
    
}
    

