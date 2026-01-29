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
 * Class Name: LogLevel.swift
 ******************************************************************************/

import Foundation

public enum LogLevel
{
    /**
     Level used to disallow any log messages to pass a logger filter
     */
    case Off
    
    /**
     Level for FAULT issues
     */
    case Fault
    
    /**
     Level for ERROR issues
     */
    case Error
    
    /**
     Level for DEBUG issues
     */
    case Debug
    
    /**
     Level for INFO issues
     */
    case Info
    
    /**
     Level used to allow all log messages to pass a logger filter
     */
    case All
}
