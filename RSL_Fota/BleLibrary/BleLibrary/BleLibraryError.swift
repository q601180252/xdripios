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
 * Class Name: BleLibraryError.swift
 ******************************************************************************/

import Foundation
public enum BleLibraryError: Error
{
    case serviceNotFound(message: String, result: BleResult?)
    case illegalArgument(message: String)
    case taskNotSuccessful(result: BleResult, error: Error?)
    case establichError(message: String, result: BleResult, error: Error?)
    case notConnectedError(message: String, result:BleResult?)
    case notConnectableError(message: String, result:BleResult?)
    case timeoutError(message: String, result:BleResult?)
    case notSupportedError(message: String, result:BleResult?)
    case notReadyError(message: String)
    case objectDisposedError(objectName: String)
    case generalError(message: String)
}

extension BleLibraryError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .serviceNotFound:
            return "serviceNotFound"
        case .illegalArgument:
            return "illegalArgument"
        case .taskNotSuccessful:
            return "taskNotSuccessful"
        case .establichError:
            return "establichError"
        case .notConnectedError:
            return "notConnectedError"
        case .notConnectableError:
            return "notConnectableError"
        case .timeoutError:
            return "timeoutError"
        case .notSupportedError:
            return "notSupportedError"
        case .notReadyError:
            return "notReadyError"
        case .objectDisposedError:
            return "objectDisposedError"
        case .generalError:
            return "generalError"
        }
    }
}
