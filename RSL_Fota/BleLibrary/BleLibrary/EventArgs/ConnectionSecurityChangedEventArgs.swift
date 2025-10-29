//
//  ConnectionSecurityChangedEventArgs.swift
//  BleLibrary
//
//  Created by Sam Andersson on 21.12.18.
//  Copyright © 2018 Arendi Ag. All rights reserved.
//

import Foundation
public struct ConnectionSecurityChangedEventArgs {
    
    public var peripheral: PeripheralBase
    {
        return _peripheral
    }
    
    public var security: ConnectionSecurityProtocol
    {
        return _security
    }
    
    private var _peripheral: PeripheralBase
    private var _security: ConnectionSecurityProtocol
    
    init(_ peripheral: PeripheralBase,_ security: ConnectionSecurityProtocol)
    {
        self._peripheral = peripheral
        self._security = security
    }
}
