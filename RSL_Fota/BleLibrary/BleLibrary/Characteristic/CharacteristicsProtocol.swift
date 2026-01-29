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
 * Class Name: CharacteristicsProtocol.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
//import AsyncTask

public protocol CharacteristicsProtocol: DisposableProtocol
{
    //MARK: Events
    /**
     Event triggered, when a notification has been received
     */
    var eventNotificationReceived: Event<NotificationReceivedEventArgs> { get }
    
    /**
     Event triggered, when a indication has been recieved
     */
    var eventIndicationRecieved: Event<IndicationReceivedEventArgs>{ get }
    
    //MARK: Propertis
    /**
     Get the UUID identifying the characteristic
     */
    var uuid: CBUUID { get }
    
    /**
     Get the local value of the characteristic. The local value is not valid on all implementations.
     */
    var value: Data {get}
    
    /**
     Get the permissions associated with the characteristic
     */
    var permission: UInt {get}
    
    /**
     Get the properties associated with the characteristic
     */
    var property: UInt {get}
    
    /**
     Get the description of the characteristic
     */
    var description: String {get}
    
    //MARK: functions
    /**
     Retrives the data of a specified characteristic from peripheral (EAP)
     
     - parameters:
        - timeout: timeout in [ms]
     
     - returns:
        - Result of the initiation of the operation. If the result is BleResult.Pending or BleResult.Success the end of the operation is signalized by the delegate dataReadDelegate
     
     -throws:
        - BleLibraryError.notConnectedError
        - BleLibraryError.notSupportedError
     */
    func readData(_ timeout: Int)throws -> Data
    
    /**
     Write the data to a characteristic of the peripheral (EAP)
     
     - parameters:
        - timeout: timeout in [ms]
     
     - returns:
        Result of the initiation of the operation. If the result is BleResult.Pending or BleResult.Success the end of the operation is signalized by the delegate dataReadDelegate
     
     - throws:
        - BleLibraryError.notConnectedError
        - BleLibraryError.notSupportedError
     */
    func writeData(_ data: Data, _ writeType: WriteType, _ timeout: Int)throws
    
    /**
     Changes the indication for the value of a specified characteristic (EAP)
     - parameters:
        - enabled: enable or disable the notification
        - timeout: timeout in [ms]
     
     - returns:
        Result of the initiation of the operation. If the result is BleResult.Pending or BleResult.Success the end of the operation is signalized by the delegate dataReadDelegate
     
     - throws:
        - BleLibraryError.notConnectedError
        - BleLibraryError.notSupportedError
     */
    func changeNotification(_ enable: Bool, _ timeout: Int)throws
    
    /**
     Change the indication for the value of a specified characteristic (EAP)
     
     - prarameters:
        - enabled: enable or disable the notification
        - timeout: timeout in [ms]
     
     - retrns:
        Result of the initiation of the operation. If the result is BleResult.Pending or BleResult.Success the end of the operation is signalized by the delegate dataReadDelegate
     
     - throws:
        - BleLibraryError.notConnectedError
        - BleLibraryError.notSupportedError
     */
    func changeIndication(_ enable: Bool, _ timeout: Int)throws
}
