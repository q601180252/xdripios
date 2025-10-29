/*
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
 * Class Name: FotaPeripheral.swift
 */

import BleLibrary
import FotaLibrary
import Foundation

class FotaPeripheral: EnhancedPeripheral
{
    // charactersitcs UUID
    let serviceUuidDefault: String =                    "b2152466-d600-11e8-9f8b-f2801f1b9fd1";
    let deviceIdCharacteristicUuid: String =            "b2152466-d602-11e8-9f8b-f2801f1b9fd1";
    let bootloaderVersionCharacteristicUuid: String =   "b2152466-d603-11e8-9f8b-f2801f1b9fd1";
    let bleStackVersionCharacteristicUuid: String =     "b2152466-d604-11e8-9f8b-f2801f1b9fd1";
    let applicationVersionCharacteristicUuid: String =  "b2152466-d605-11e8-9f8b-f2801f1b9fd1";
    let bleStackBuildIdCharacteristicUuid: String =     "b2152466-d606-11e8-9f8b-f2801f1b9fd1";
    let serviceUuid: String
    
    //MARK: properties
    public var deviceId: Data? { return _deviceId }
    public var bootloaderVersion: FotaFirmwareVersion? { return _bootloaderVersion }
    public var bleStackVersion: FotaFirmwareVersion? { return _bleStackVersion }
    public var applicationVersion: FotaFirmwareVersion? { return _applicationVersion }
    public var fotaBuildId: Data? { return _fotaBuildId }
    
    //MARK: members
    private var _deviceId: Data?
    private var _bootloaderVersion: FotaFirmwareVersion?
    private var _bleStackVersion: FotaFirmwareVersion?
    private var _applicationVersion: FotaFirmwareVersion?
    private var _fotaBuildId: Data?
    private let log: LogProtocol = LogManager.manager.createLog(name: "FotaPeripheral")
    
    override public init(uuid: UUID)
    {
        // init values
        _deviceId = nil
        _bootloaderVersion = nil
        _bleStackVersion = nil
        _applicationVersion = nil
        _fotaBuildId = nil
        serviceUuid = serviceUuidDefault
        
        super.init(uuid: uuid)
        
    }
    
    override public init(peripheral: PeripheralProtocol)throws
    {
        // init values
        _deviceId = nil
        _bootloaderVersion = nil
        _bleStackVersion = nil
        _applicationVersion = nil
        _fotaBuildId = nil
        serviceUuid = serviceUuidDefault
        
        try super.init(peripheral: peripheral)
    }
    
    /**
     Initialize the peripheral and try to find the specified service. It alsto try to get the specified characteristeic
     */
    override open func initialize() throws -> UpdateSetup? {
        
        // try to find the default service
        let productService = peripheral?.findService(uuid: serviceUuid)
        guard productService != nil else
        {
            log.error("Ble product service not found!")
            throw BleLibraryError.serviceNotFound(message: "Ble service with uuid (\(serviceUuid)) not found", result: nil)
        }
        
        //try get the specified characteristic from the peripheral
        let deviceIdCharacteristic = productService!.getCharacteristic(uuid: deviceIdCharacteristicUuid);
        let bootloaderVersionCharacteristic = productService!.getCharacteristic(uuid: bootloaderVersionCharacteristicUuid);
        let bleStackVersionCharacteristic = productService!.getCharacteristic(uuid: bleStackVersionCharacteristicUuid);
        let applicationVersionCharacteristic = productService!.getCharacteristic(uuid: applicationVersionCharacteristicUuid);
        let bleStackBuildIdCharacteristic = productService!.getCharacteristic(uuid: bleStackBuildIdCharacteristicUuid);

        // try to read out the data from each characteristic
        do
        {
            if deviceIdCharacteristic != nil
            {
                    _deviceId = try deviceIdCharacteristic?.readData(Constants.readDataTimeout)
            }
        }
        catch
        {
            log.error("\(error)")
        }
        
        do
        {
            if bootloaderVersionCharacteristic != nil
            {
                _bootloaderVersion = FotaFirmwareVersion()
                try _bootloaderVersion?.setVersion(data: (try bootloaderVersionCharacteristic?.readData(Constants.readDataTimeout))!)
            }
        }
        catch
        {
            log.error("\(error)")
        }
        
        do
        {
            if bleStackVersionCharacteristic != nil
            {
                _bleStackVersion = FotaFirmwareVersion()
                try _bleStackVersion?.setVersion(data: (try bleStackVersionCharacteristic?.readData(Constants.readDataTimeout))!)
            }
        }
        
        
        do
        {
            if applicationVersionCharacteristic != nil
            {
                _applicationVersion = FotaFirmwareVersion()
                try _applicationVersion?.setVersion(data: (try applicationVersionCharacteristic?.readData(Constants.readDataTimeout))!)
            }
        }
        catch
        {
            log.error("\(error)")
        }
        
        do
        {
            if bleStackBuildIdCharacteristic != nil
            {
                _fotaBuildId = try bleStackBuildIdCharacteristic?.readData(Constants.readDataTimeout)
            }
        }
        catch
        {
            log.error("\(error)")
        }
        
        return nil
    }
    
}
