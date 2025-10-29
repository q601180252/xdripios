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
 * Class Name: UpdateSetup.swift
 ******************************************************************************/

import Foundation
public struct UpdateSetup
{
    /**
     * The update provider is a instance of the class that implements the update procedure
     */
    public var provider: UpdateProviderProtcol { return _provider }
    private var _provider: UpdateProviderProtcol

    /**
     * The source object may be used to define the source information of the update. The usage in detail
     * depends on the used update provider
     */
    public var source: Any? { return _source }
    private var _source: Any?

    /**
     * The options object may be used to define the options information of the update. The usage in detail
     * depends on the used update provider
     */
    public var options: Any? { return _options }
    private var _options: Any?
    
    /**
     * Create an update setup instance
     */
    public init(provider: UpdateProviderProtcol, source: Any? = nil, options: Any? = nil)
    {
        _provider = provider
        _source = source
        _options = options
    }
}


