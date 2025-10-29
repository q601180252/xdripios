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
 * Class Name: TaskBase.swift
 ******************************************************************************/

import Foundation
import os.log
public class TaskBase:NSObject, TaskProtocol
{
    //MARK: Members
    private var _taskTimeoutTimer: Timer?
    private var _taskCompleted: ((TaskProtocol, BleResult)->())?
    
    private let _lockQueue: DispatchQueue?
    private var _lock = DispatchSemaphore(value: 1)
    let log: LogProtocol = LogManager.manager.createLog(name: "\(type(of: self))")
    
    private var startDate : Date?

    //MARK: Protocol
    public let taskTimeout: Double
    
    public override var description: String
    {
        return "\(type(of: self))"
    }
    
    /**
     Init TaskBase
     
     - parameters:
        - timeout: in [ms]
     */
    public init(_ timeout: Int)
    {
        self.taskTimeout = Double(timeout / 1000)
        _lockQueue = DispatchQueue(label: "ch.arendi.bleLibrary.taskBase.lockQueue", attributes: .concurrent)
        
        super.init()
    }
    
    public final func completed(result: BleResult)
    {
        _lock.wait()
            guard self._taskCompleted != nil else
            {
                self.log.error("Unexpected task completed from task \(self.description)" )
                _lock.signal()
                return;
            }
            
            if self._taskTimeoutTimer != nil
            {
                self._taskTimeoutTimer?.invalidate()
                self._taskTimeoutTimer = nil
            }
        
            // call on completed method for task specific task complete action
            self.onCompleted(result: result)
        
            // log compleated task
            self.log.debug("->| Task {\(self.description)} completed (Result:\(result.description))")
        self.log.debug("Time to complete task: \((startDate?.timeIntervalSinceNow)! * -1000) [ms]")
            
            //Cleanup task
            self.cleanup()
            
            //call task completed method
            self._taskCompleted?(self, result)
            self._taskCompleted = nil
        _lock.signal()
    }
    
    public func isParallelExecutionProhibited(task: TaskProtocol) -> Bool {
        return false
    }
    
    public func start(function: @escaping (TaskProtocol, BleResult) -> ()) throws {
        _lock.wait()
            // log started task
            self.log.debug("-> Task started \(self.description)")
            self.startDate = Date()
        
            self._taskCompleted = function
            
            if self.taskTimeout > 0
            {
                if self._taskTimeoutTimer != nil
                {
                    self._taskTimeoutTimer?.invalidate()
                    self._taskTimeoutTimer = nil
                }
                
                DispatchQueue.main.async {
                    self._taskTimeoutTimer = Timer.scheduledTimer(timeInterval: self.taskTimeout, target: self, selector: #selector(self.onTimeout(timer:)), userInfo: nil, repeats: false)
                }                
            }
        _lock.signal()
            
            // start task
            do
            {
                try self.start()
            }
            catch let error
            {
                self.log.debug("Task start failed with exception (\(self.description), Error(\(error.localizedDescription)) ")
                self.completed(result: BleResult.exception)
        }
    }
    
    func start()throws
    {
        //Override this function
    }
    
    func onCompleted(result: BleResult)
    {
        //Override this function
    }
    
    func cleanup()
    {
        //Override this function
    }
    
    //MARK: private func
    @objc private func onTimeout(timer: Timer)
    {
        // log started task
        log.debug("Task timeout \(description)")
        completed(result: BleResult.timeout)
    }
}
