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
 * Class Name: LogProtocol.swift
 ******************************************************************************/

import Foundation
public protocol LogProtocol
{
    /**
     Get the name of the logger instance
     */
    var name: String { get }
    
    /**
     Get or sets the level of the actual logger instance while the logger is in use
     */
    var level: LogLevel{ get set }
    
    /**
     Log a INFO message
     */
    func info(_ message: String)
    
    /**
     Log a DEBUG message
     */
    func debug(_ message: String)
    
    /**
     Log a FAULT message
     */
    func fault(_ message: String)
    
    /**
     Log a Error message
     */
    func error(_ message: String)
}
