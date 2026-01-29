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
 * Class Name: TaskProtocol.swift
 ******************************************************************************/

import Foundation
public protocol TaskProtocol: class
{    
    var description: String { get }
    
    /**
     Check if the parallel execution of the given task with this task is prohibited or not
     
     - parameters:
        - task: TaskProtocol tas to check for parrallel execution
     
     - returns:
        True id the given task must not be executed in parallel to this one, otherwise false
     */
    func isParallelExecutionProhibited(task: TaskProtocol) -> Bool
    
    /**
     Start the task
     
     - parameters:
        - function: (TaskProtocol, BleResult) that will be executed when finished
     
     - throws:
        
     */
    func start(function: @escaping  (TaskProtocol, BleResult)->())throws
    
    /**
     Function that is call on complete of the task
     
     - parameters:
        - result: The result of the task
     */
    func completed(result: BleResult)
}
