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
 * Class Name: DataExchangeProtocol.swift
 ******************************************************************************/

import BleLibrary
import Foundation
protocol DataExchangeProtocol: DisposableProtocol {
    
    /**
     Is invoked when new data was received
     */
    var eventDataRecived: Event<DataReceivedEventArgs> {get}
    
    /**
     The maximum length of the transmitted data
     */
    var maxDataLength: Int {get}
    
    /**
     Initialize the module. Has to be called before "Transmit" the first time
     */
    func initializeDataExchange()throws
    
    /**
     Transmits data. This call is blocking
    
     - parameters:
        - data: The data to transmit
     */
    func transmit(buffer: Data)throws
    
}
