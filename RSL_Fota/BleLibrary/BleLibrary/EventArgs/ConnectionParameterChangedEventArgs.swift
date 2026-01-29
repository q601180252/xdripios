//
//  ConnectionParameterChangedEventArgs.swift
//  BleLibrary
//
//  Created by Sam Andersson on 21.12.18.
//  Copyright © 2018 Arendi Ag. All rights reserved.
//

import Foundation
public struct ConnectionParameterChangedEventArgs {
    
    public var peripheral: PeripheralBase
    {
        return _peripheral
    }
    
    public var parameter: ConnectionParameterProtocol
    {
        return _parameter
    }
    
    private var _peripheral: PeripheralBase
    private var _parameter: ConnectionParameterProtocol
    
    init(_ peripheral: PeripheralBase, _ parameter: ConnectionParameterProtocol)
    {
        self._peripheral = peripheral
        self._parameter = parameter
    }
}
