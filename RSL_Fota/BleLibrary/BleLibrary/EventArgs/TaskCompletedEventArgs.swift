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
 * Class Name: TaskCompletedEventArgs.swift
 ******************************************************************************/

import Foundation
public struct TaskCompletedEventArgs {
    
    //MARK: Properties
    var task: TaskProtocol{ return _task }
    var result: BleResult { return _result }
    var error: Error? { return _error }
    
    //MARK: Memebers
    private var _task: TaskProtocol
    private var _result: BleResult
    private var _error: Error?
    
    init(task: TaskProtocol, result: BleResult, error: Error?)
    {
        self._task = task
        self._result = result
        self._error = error
    }
    
    init(task: TaskProtocol, result: BleResult)
    {
        self.init(task: task, result: result, error: nil)
    }
}
