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
 * Class Name: PeripheralProtocol.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public protocol  PeripheralProtocol: BasePeripheralProtocol {
    
    /**
     Standard initalition
     */
    init(peripheral: CBPeripheral, rssi: Int, name: String?, manufacturerData: Data?)
    
    /**
     The Bluetooths uuid
     */
    var uuid: UUID {get}
    
    /**
     The last received RSSI value.
     */
    var rssi: Int {get set}
    
    /**
     The name of the peripheral
     */
    var name: String? {get set}
    
    /**
     The manufacturerData
     */
    var manufacturerData: Data {get}
    
    /**
     The state of the peripheral. Add a {@link PeripheralChangedListener PeripheralChangedListener} for state changed updates.
     */
    var state: PeripheralState {get}
    
    /**
     The CBPeripheralState
     */
    var cbState: CBPeripheralState {get}
    
    /**
     The peripheralManager
     */
    var peripheralManager: PeripheralManagerBaseProtocol? {get set}
    
    /**
     The timestamp of the last advertising data update.
     */
    var lastUpdate: Date {get}
    
    /**
     Returns the maximum write length for this peripheral.
     */
    var maxWriteLength: Int {get}
    
    /**
     Returns a description of the peripheral
     */
    var description: String {get}
    
    /**
     Returns if peripheral is connected
     */
    var isConnected: Bool {get}
    
    /**
     Get the service list of the peripheral
     */
    var serviceList: [ServiceProtocol] {get}
    
    //MARK: Events
    /**
     Event triggered, when the state of the peripheral changed
     */
    var eventStateChange: Event<CBStateChangedEventArgs> {get}
    
    /**
     Event triggered, when the peripehral is connected
     */
    var eventConnected: Event<EmptyEventArgs>{get}
    
    /**
    Event triggered, when the peripheral is disconnected
     */
    var eventDisconnected: Event<DisconnectedEventArgs>{get}
    /**
     Event triggered, when a service is discovered
     */
    var eventServiceDiscovered: Event<CBServiceDiscoveredEventArgs> {get}
    /**
     Event triggered, when a characteristic is discovered
     */
    var eventCharacteristicDiscovered: Event<CBCharacteristicDiscoveredEventArgs>{get}
    /**
     Event triggered, when the name is updated
     */
    var eventNameUpdated: Event<NameUpdatedEventArgs>{get}
    /**
     Event triggered, when a characteristic value is updated
     */
    var eventUpdatedCharacterteristicValue: Event<CBCharacteristicEventArgs>{get}
    /**
     Event triggered, when characteristic value was wirtten
     */
    var eventWroteCharacteristicValue: Event<CBCharacteristicEventArgs>{get}
    /**
     Event triggered, when the peripehral is ready to send without response
     */
    var eventIsReadyToSendWriteWithoutResponse: Event<EmptyEventArgs>{get}
    /**
     Event triggered, when notification state changed
     */
    var eventUpdatedNotificationState: Event<CBCharacteristicEventArgs>{get}
    /**
     Event triggered, when the Rssi value was read
     */
    var eventRssiRead: Event<CBRssiEventArgs>{get}
    
    //MARK: functions
    /**
     Discover all services of the peripheral
     
     - parameters:
        - timeout: Timeout [ms]
     
     - returns:
        Array of ServiceProtocol
     */
    func discoverServices(timeout: Int)throws -> [ServiceProtocol]
    
    /**
     Find a service in the service list.
     The service list is available after completing the service discovery.
     
     - parameters:
        - uuid: The UUID of the service to search for.
     
     - returns:
        The service object found, or null if no service has been found.
     */
    func findService(uuid: CBUUID) -> ServiceProtocol?
    
    /**
     Find a service in the service list. The service list is available after completing the service discovery.
    
     - parameters:
        - uuid: The UUID of the service to search for.
     
     - returns:
        The service object found, or null if no service has been found.
     */
    func findService(uuid: String) -> ServiceProtocol?
    
    /**
     Find a characteristic in the service list. The service list is available after completing the service discoverty
     
     - parameters:
        - uuid: The UUID of the characteristic to search for
     
     - returns:
        CharacteristicProtocol
     */
    func findCharacteristic(uuid: CBUUID) -> CharacteristicsProtocol?
    
    /**
     Find a characteristic in the service list. The service list is available after completing the service discoverty
     
     - parameters:
        - uuid: The UUID of the characteristic to search for
     
     - returns:
        CharacteristicProtocol
     */
    func findCharacteristic(uuid: String) -> CharacteristicsProtocol?
    
    /**
     Establishes a connection to the peripheral. This is a blocking operation and it returns when ever the connection is established successful or not.
     */
    func connect(timeout: Int) throws
    
    /**
     Tear down the connection to the peripheral.
     */
    func disconnect(timeout: Int) throws
    
    /**
     Retrives the current RSSI value for the peripheral while it is connected
     - parameters:
        - timeout: timeout [ms]
     
     - returns:
        Returns the RSSI value
     */
    func readRssi(timeout: Int)throws -> Int
    
    /**
     Method to compaire two PeripheralProtcol
     
     - parameters:
        - other: Peripheral to compare with
     
     - returns:
        Ture if equal.
     */
    func equal(other: PeripheralProtocol) -> Bool
}

public protocol PeripheralDelegate: AnyObject {
    /**
     Did change the state of the peripheral
     
     - parameters:
        - peripheral: PeripheralProtcol
        - oldState: The old CBPeripheralState
        - newState: The new CBPeripheralState
     */
    func peripheral(_ peripheral: PeripheralProtocol, didStateChange oldState: CBPeripheralState, newState: CBPeripheralState)
    
    /**
     Did disconnect to the peripheral
     
     - parameters:
        - peripheral: PeripheralProtocol
        - reason: DisconnectReason
     */
    func peripheral(_ peripheral: PeripheralProtocol, didDisconnected reason: DisconnectReason)
    
    /**
     Did change the connection parameters
    
     - parameters:
        - peripheral: PeripheralProtocol
        - parameter: ConnectionParameterProtocol
     */
    func peripheral(_ peripheral: PeripheralProtocol, didConnectionParameterChanged parameter: ConnectionParameterProtocol)
    
    /**
     Did change the connection security property
     
     - parameters:
        - peripheral: PeripheralProtocol
        - security: ConnectionSecurityProtocol
     */
    func peripheral(_ peripheral: PeripheralProtocol, didConnectionSecurityChanged security: ConnectionSecurityProtocol)
    
    /**
     Did discover services in the peripheral
     
     - parameters:
        - peripheral: PeripheralProtocol
        - error: Error
     */
    func peripheral(_ peripheral: PeripheralProtocol, didServiceDiscovered error: Error?)
    
    /**
     Did discover characteristics in the service
     
     - parameters:
        - peripheral: PeripheralProtocol
        - error: Error
     */
    func peripheral(_ peripheral: PeripheralProtocol, didCharacteristicDiscovered service: CBService, error: Error?)
    
    /**
     The name of the peripheral changed
     
     - parameters:
         - peripheral: PeripheralProtocol
         - name: The new name of the peripheral
     */
    func peripheral(_ peripheral: PeripheralProtocol, didChangeName name: String)
    
    /**
     Did update value on characteristic
     
     - parameters:
        - peripheral: PeripheralProtocol
         - characteristic: CBCharacteristic
         - error: Error
     */
    func peripheral(_ peripheral: PeripheralProtocol, didUpdateCharacteristicValue characteristic: CBCharacteristic, error: Error?)
    
    /**
     Did write value on characteristic
     
     - parameters:
         - peripheral: PeripheralProtocol
         - characteristic: CBCharacteristic
         - error: Error
     */
    func peripheral(_ peripheral: PeripheralProtocol, didWriteCharacteristicValue characteristic: CBCharacteristic, error: Error?)
    
    /**
     Did update notification state on characteristic
     
     - parameters:
         - peripheral: PeripheralProtocol
         - characteristic: CBCharacteristic
         - error: Error
     */
    func peripheral(_ peripheral: PeripheralProtocol, didUpdateNotificationState characteristic: CBCharacteristic, error: Error?)
    
    /**
     Did read rssi value
     
     - parameters:
        - peripheral: PeripheralProtocol
        - rssi: int
        - error: Error
     */
    func peripheral(_ peripheral: PeripheralProtocol, didReadRssi rssi: Int, error: Error?)
    
    /**
     Peripheral is ready to send write without response
     
     - parameters:
        - peripheral: PeripheralProtocol
     */
    func peripheralIsReadyToSendWriteWithoutResponse(_ peripheral: PeripheralProtocol)
    
    /**
     Did connect to peripheral
     
     - parameters:
        - peripheral: PeripheralProtocol
     */
    func peripheralConnected(_ peripheral: PeripheralProtocol)
}

extension PeripheralDelegate {
    func peripheral(_ peripheral: PeripheralProtocol, didStateChange oldState: CBPeripheralState, newState: CBPeripheralState){}
    func peripheral(_ peripheral: PeripheralProtocol, didDisconnected reason: DisconnectReason){}
    func peripheral(_ peripheral: PeripheralProtocol, didConnectionParameterChanged parameter: ConnectionParameterProtocol){}
    func peripheral(_ peripheral: PeripheralProtocol, didConnectionSecurityChanged security: ConnectionSecurityProtocol){}
    func peripheral(_ peripheral: PeripheralProtocol, didServiceDiscovered error: Error?){}
    func peripheral(_ peripheral: PeripheralProtocol, didCharacteristicDiscovered error: Error?){}
    func peripheral(_ peripheral: PeripheralProtocol, didChangeName name: String){}
    func peripheral(_ peripheral: PeripheralProtocol, didUpdateCharacteristicValue characteristic: CBCharacteristic, error: Error?){}
    func peripheral(_ peripheral: PeripheralProtocol, didWriteCharacteristicValue characteristic: CBCharacteristic, error: Error?){}
    func peripheral(_ peripheral: PeripheralProtocol, didUpdateNotificationState characteristic: CBCharacteristic, error: Error?){}
    func peripheral(_ peripheral: PeripheralProtocol, didReadRssi rssi: Int, error: Error?){}
    func peripheralIsReadyToSendWriteWithoutResponse(_ peripheral: PeripheralProtocol){}
    func peripheralConnected(_ peripheral: PeripheralProtocol){}
}


