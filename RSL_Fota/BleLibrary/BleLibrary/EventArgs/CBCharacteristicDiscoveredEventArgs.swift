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
 * Class Name: CBCharacteristicDiscoveredEventArgs.swift
 ******************************************************************************/

import Foundation
import CoreBluetooth
public struct CBCharacteristicDiscoveredEventArgs
{
    public var service: CBService
    {
        return _service
    }

    public var error: Error?
    {
        return _error
    }

    private var _service: CBService
    private var _error: Error?

    init(_ service: CBService, _ error: Error?)
    {
        self._service = service
        self._error = error
    }
}
