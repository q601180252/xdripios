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
 * Class Name: BleResult.swift
 ******************************************************************************/

import Foundation
public enum BleResult{
    
    /**
     Operation succeeded.
     */
    case success
    
    /**
     Operation terminated by a timeout.
     */
    case timeout
    
    /**
     Operation failed because the peripheral is not connected.
     */
    case notConnected
    
    /**
     Operation failed because the peripheral is not connectible.
     */
    case notConnectable
    
    /**
     Operation failed because the peripheral could not be connected.
     */
    case unabledToConnect
    
    /**
     Operation failed because the connection to the peripheral has been lost.
     */
    case connectionLost
    
    /**
     Operation failed because the connection is already established.
     */
    case connectionAlreadyEstablished
    
    /**
     Operation failed because it's not supported
     */
    case notSupported
    
    /**
     Operation failed because the authentication is insufficient.
     */
    case insufficientAuthentication
    
    /**
     Operation failed because the authorization is insufficient.
     */
    case insufficientAuthorization
    
    /**
     Operation failed because the encryption is insufficient.
     */
    case insufficientEncryption
    
    /**
     Operation failed because it's not permitted.
     */
    case notPermitted
    
    /**
     Operation failed because the authentication failed.
     */
    case authenticationFailure
    
    /**
     Operation failed because the authentication key is missing.
     */
    case authenticationKeyMissing
    
    /**
     Operation failed because no response has been received.
     */
    case noResponse
    
    /**
     Searched attribute was not found
     */
    case attributeNotFound
    
    /**
     Link supervision timeout expired.
     */
    case connectionTimeout
    
    /**
     Controller is at limit of connections it can support.
     */
    case connectionLimitExceeded
    
    /**
     User input of passkey failed.
     */
    case PasskeyEntryFailed
    
    /**
     Pairing is not supported by the device.
     */
    case pairingNotSupported
    
    /**
     Operation failed because of an unknown failure.
     */
    case failure
    
    /**
     Operation failed because of a thrown exception.
     */
    case exception
    
    /**
     Operation canceled.
     */
    case canceled
    
    /**
     Bluetooth is disabled.
     */
    case bluetoothDisabled
    
    /**
     Operation is still pending.
     */
    case Pending
    
    public var description: String
    {
        switch self {
        case .success: return "Success"
        case .timeout: return "Timeout"
        case .notConnected: return "NotConnected"
        case .unabledToConnect: return "UnabledToConnect"
        case .connectionLost: return "ConnectionLost"
        case .connectionAlreadyEstablished: return "ConnectionAlreadyEstablished"
        case .notSupported: return "NotSupported"
        case .insufficientAuthentication: return "InsufficientAuthentication"
        case .insufficientAuthorization: return "InsufficientAuthorization"
        case .insufficientEncryption: return "InsufficientEncryption"
        case .notPermitted: return "NotPermitted"
        case .authenticationFailure: return "AutenticationFailuer"
        case .authenticationKeyMissing: return "AuthenticationKeyMissing"
        case .noResponse: return "NoResponse"
        case .attributeNotFound: return "ArributeNotFound"
        case .connectionTimeout: return "ConnectionTimeout"
        case .connectionLimitExceeded: return "ConnectionLimitExceeded"
        case .PasskeyEntryFailed: return "PasskeyEntryFailed"
        case .pairingNotSupported: return "ParingNotSupported"
        case .failure: return "Failure"
        case .exception: return "Exception"
        case .canceled: return "Canceled"
        case .bluetoothDisabled: return "BluetoothDisabled"
        case .Pending: return "Pending"
        case .notConnectable: return "NotConnectable"
        }
    }
}
