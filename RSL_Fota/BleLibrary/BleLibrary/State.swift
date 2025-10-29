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
 * Class Name: State.swift
 ******************************************************************************/

import Foundation
enum State {
    
    /**
     Peripheral is disconnected.
     */
    case Disconected
    
    /**
     The library is trying to establish a connection to the peripheral.
     */
    case Connecting
    
    /**
     The peripheral is connected.
     */
    case Connected
    
    /**
     The library is disconnecting the peripheral.
     */
    case Disconnecting
}
