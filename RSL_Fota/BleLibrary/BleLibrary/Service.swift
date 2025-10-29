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
 * Class Name: Service.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
import os.log
public class Service: ServiceProtocol {

    
    
    //MARK: properties
    public var uuid: CBUUID
    
    /**
     List with all characteristics of the service.
     */
    public var characteristics: [CharacteristicsProtocol]
    {
        return _characteristics
    }
    
    @objc public var description: String
    {
        return "UUID:\(uuid)"
    }
    
    //MARK: members
    private let log: LogProtocol = LogManager.manager.createLog(name: "Serive")
    
    private var _characteristics: [CharacteristicsProtocol]
    
    //MARK: functions
    
    init(peripheral: PeripheralBase, service: CBService)
    {
        // no characteristics for this service
        if service.characteristics == nil {
            log.error("The service \(service.uuid.uuidString) has no characteristics")
        }
        
        do{
            log.info("Service UUID: \(service.uuid.uuidString) = \(try BinaryString.getBytes(hexString: service.uuid.uuidString))")
        }
        catch{
            
        }
        
        self.uuid = service.uuid
        self._characteristics = [CharacteristicsProtocol]()
        for c in (service.characteristics)!
        {
            addCharacteristic(characteristic: Characteristic(peripheral: peripheral, characteristic: c))
        }
    }
    
    /**
     Add a characteristic to the service
     
     - parameters:
        - characteristic: Characteristic to add
     */
    public func addCharacteristic(characteristic: CharacteristicsProtocol)
    {
        self._characteristics.append(characteristic)
    }
    
    /**
     Clear list with characteristics
     */
    func clear(){
        for c in _characteristics
        {
            c.dispose();
        }
        _characteristics.removeAll()
    }
    
    //MARK: ServiceProtocol
    
    /**
     Get the characteristic with a given UUID
     - parameters:
        - uuid: uuid string for characteristic
     
     - returns:
        The characteristic or nil if no characteristic found
     */
    public func getCharacteristic(uuid: String) -> CharacteristicsProtocol? {
        
        log.debug("avalible characteristics: \(_characteristics.description)")
        
        if let item = _characteristics.first(where: {$0.uuid == CBUUID(string: uuid)} ) {
            return item
        }
        else
        {
            return nil
        }
    }
    
    /**
     Get the characteristic with a given UUID
     - parameters:
        - uuid: uuid for characteristic
     
     - returns:
        The characteristic or nil if no characteristic found
     */
    public func getCharacteristic(uuid: CBUUID) -> CharacteristicsProtocol? {
        
        log.debug("avalible characteristics\(_characteristics.description)")
        if let item = _characteristics.first(where: {$0.uuid == uuid}) {
            return item
        }
        else
        {
            return nil
        }
    }
    
    /**
     Perform application-defined tasks associated with freeinf, releasing or resetting unmanged resources
     */
    public func dispose() {
        for c in characteristics
        {
            c.dispose()
        }
    }
    
}
