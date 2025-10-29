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
 * Class Name: PeripheralManagerBaseProtocol.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public protocol PeripheralManagerBaseProtocol {
   
    /**
     Get the current bluetoothState
     */
    var bluetoothState: BluetoothState { get }
    
    /**
     Get the centralManager
     */
    var manager: CBCentralManager? { get }
    
    /**
     Get/Set if peripherals shall be disposted on removal. Default: false
     */
    var disposePeripheralOnRemove: Bool { get set }
    
    /**
     Get/Set the uuidFilter list
     */
    var uuidFilter: [CBUUID]? { get set }
    
    /**
     This class delegate
     */
    var delegate: PeripheralManagerBaseDelegate? { get set }
    
    //MARK functions
    /**
     Scans for advertising packagets from all devices. Default allows duplicates
     */
    func startScan()
    
    /**
     Scans for advertising packets from devices specified by there UUID.
     
     - parameters:
        - allowDuplicatesKey: Set true to allow duplicates
     */
    func startScan(allowDuplicatesKey: Bool)
    
    /**
     Scans for advertising packets from devices specified by there UUID. Default allows duplicates
     
     - parameters:
        - uuids: List of UUID's to accept in service list
     */
    func startScan(uuids: [CBUUID])
    
    /**
     Scans for advertising packets from devices specified by there UUID.
     
     - parameters:
        - uuids: List of UUID's to accept in service list
        - allowDuplicatesKey: Set true to allow duplicates
     */
    func startScan(uuids: [CBUUID], allowDuplicatesKey: Bool)
    
    /**
     Stops the scan for advertising packets
     */
    func stopScan()
    
    /**
     Checks if the bluetooth hardware is enabled
     
     - returns:
        True if enabled, otherwise false
     */
    func isBluetoothEnabled() -> Bool
    
    /**
     Clears the list of peripherals if {@link #canRemove(Object)} returns true
     */
    func clear()throws
    
    /**
     Method that check if a discovered peripheral is valid or should be ignored. If this method is not overwritten any peripheral is valid. Note, should add Advertising info list class add more info to contoll if it is the peripheral you are looking for
     */
    func checkDiscovered(peripheral: PeripheralProtocol, rssi: Int) -> Bool
    
    //MARK: Events
    /**
     Occers when peripheral is discovered
     */
    var eventPeripheralDiscovered: Event<PeripheralDiscoveredEventArgs> { get }
    
    /**
     Occers when bluetooth state change
     */
    var eventBluetoothStateChanged: Event<BluetoothStateChangedEventArgs> { get }
    
    /**
     Occcers when sytem information updated
     */
    var eventSystemInformationUpdated: Event<EmptyEventArgs> { get}
    
    /**
     Occoers when fatal error
     */
    var eventFatalError: Event<FatalErrorEventArgs> { get }
    
    /**
     Occers when peripheral is connected
     */
    var eventMyConnetedPeripheral: Event<CBPeripheralEventArgs> { get }
    
    /**
     Occers when peripheral is disconnected
     */
    var eventMyDisconnectedPeripheral: Event<CBPeripheralErrorEventArgs> { get }
    
    /**
     Occers when faild to connect to peripheral
     */
    var eventMyFailedToConnectPeripheral: Event<CBPeripheralErrorEventArgs> { get }
    
    /**
     Occers when is busy changed
     */
    var eventIsBusyChanged: Event<IsBusyEventArgs>{ get }
    
    /**
     Occers when peripheral list changes
     */
    var eventPeripheralListUpdated: Event<EmptyEventArgs>{ get }
}

public protocol PeripheralManagerBaseDelegate: AnyObject {
    func peripheralManager(_ peripheralManager: PeripheralManagerBaseProtocol, didDiscover peripheral: BasePeripheralProtocol)
    func peripheralManager(_ peripheralManager: PeripheralManagerBaseProtocol, didChangeBluetoothState oldState: BluetoothState, newState: BluetoothState)
    func peripheralManager(_ peripheralManager: PeripheralManagerBaseProtocol, didConnect cbPeripheral: CBPeripheral)
    func peripheralManager(_ peripheralManager: PeripheralManagerBaseProtocol, didDisconnet cbPeripheral: CBPeripheral, error: Error?)
    func peripheralManager(_ peripheralManager: PeripheralManagerBaseProtocol, didFailedToConnect cbPeripheral: CBPeripheral, error: Error?)
    func peripheralManager(_ peripheralManager: PeripheralManagerBaseProtocol, didChange isBusy: Bool)
    func peripheralManagerDidUpdatePeripheralList(_ peripheralManager: PeripheralManagerBaseProtocol)
    func peripheralManagerFatalError(_ peripheralManager: PeripheralManagerBaseProtocol)
}

extension PeripheralManagerBaseDelegate {
    func peripheralManager(_ manager: PeripheralManagerBaseProtocol, didDiscover peripheral: BasePeripheralProtocol){}
    func peripheralManager(_ manager: PeripheralManagerBaseProtocol, didChangeBluetoothState oldState: BluetoothState, newState: BluetoothState){}
    func peripheralManager(_ manager: PeripheralManagerBaseProtocol, didConnect cbPeripheral: CBPeripheral){}
    func peripheralManager(_ manager: PeripheralManagerBaseProtocol, didDisconnet cbPeripheral: CBPeripheral, error: Error?){}
    func peripheralManager(_ manager: PeripheralManagerBaseProtocol, didFailedToConnect cbPeripheral: CBPeripheral, error: Error?){}
    func peripheralManager(_ manager: PeripheralManagerBaseProtocol, didChange isBusy: Bool){}
    func peripheralManagerDidUpdatePeripheralList(_ peripheralManager: PeripheralManagerBaseProtocol){}
    func peripheralManagerFatalError(_ peripheralManager: PeripheralManagerBaseProtocol){}
}
