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
 * Class Name: Log.swift
 ******************************************************************************/

import Foundation
import os.log

public class Log: LogProtocol
{
    public var name: String { return _name }
    private var _name: String
    
    public var level: LogLevel
    
    public init( name: String, level: LogLevel)
    {
        _name = name
        self.level = level
    }
    
    public convenience init(name: String)
    {
        self.init(name: name, level: LogLevel.All)
    }
    
    public convenience init()
    { 
        self.init(name: "-", level: LogLevel.All)
    }
    
    
    public func info(_ message: String)
    {
        if (level == LogLevel.All || level == LogLevel.Info)
        {
            os_log("%@", log: .default, type: .info, "\(name): \(message)")
        }
    }
    
    public func debug(_ message: String)
    {
        if (level == LogLevel.All || level == LogLevel.Debug)
        {
            os_log("%@", log: .default, type: .debug, "\(name): \(message)")
        }
    }
    
    public func fault(_ message: String)
    {
        if (level == LogLevel.All || level == LogLevel.Fault)
        {
            os_log("%@", log: .default, type: .fault, "\(name): \(message)")
        }
    }
    
    public func error(_ message: String)
    {
        if (level == LogLevel.All || level == LogLevel.Error)
        {
            os_log("%@", log: .default, type: .error, "\(name): \(message)")
        }
    }
}
