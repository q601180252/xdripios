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
 * Class Name: ServiceProtocol.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public protocol ServiceProtocol: DisposableProtocol
{
    /**
     Get the UUID of the service.
     */
    var uuid: CBUUID {get}
    
    /**
     Description of the service
     */
    var description: String {get}
    
    /**
     Get a list with all characteristics of this service.
     */
    var characteristics: [CharacteristicsProtocol] {get}
    
    /**
     Get the characteristic with a given UUID.
     
     - parameters:
        - uuid:    UUID of the characteristic.
     
     - returns:
        The characteristic found characteristic or null if no characteristic with this UUID is found.
     */
    func getCharacteristic(uuid: String) -> CharacteristicsProtocol?
    
    /**
     Get the characteristic with a given UUID.
     
     - parameters:
        - uuid:    UUID of the characteristic.
     
     - returns:
        The characteristic found characteristic or null if no characteristic with this UUID is found.
     */
    func getCharacteristic(uuid: CBUUID) -> CharacteristicsProtocol?
    
    
}
