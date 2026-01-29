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
 * Class Name: TaskControllerSequential.swift
 ******************************************************************************/

import Foundation
import os.log
public class TaskControllerSequential
{
    //MARK: Members
    var taskThreadAbort: Bool
    
    var taskThreadWakeupEvent: DispatchSemaphore?
    
    var taskQueue: Queue<TaskProtocol>
    
    var dispatchTaskQueue: DispatchQueue?
    var taskComplete: DispatchSemaphore?
    
    var workItem: DispatchWorkItem?
    
    var taskPending: TaskProtocol?
    {
        get { return _taskPending }
        set {
//            print("TP: TaskPending is set[\(_taskPending?.description) >>> \(newValue?.description)]")
            _taskPending = newValue
        }
    }
    
    var _taskPending: TaskProtocol?
    
    var runningTask: TaskProtocol?
    
    var _lockQueue = DispatchQueue(label: "ch.arendi.bleLibrary.TaskControllerSequential.lockQueue"/*, attributes: .concurrent*/)
    
    var log: LogProtocol = LogManager.manager.createLog(name: "TaskControllerSequential")
    
    var taskCompletedEventArgs: TaskCompletedEventArgs?
    
//    weak var delegate: TaskControllerSequentialDelegate?
    
    let eventTaskStarted = Event<(TaskStartedEventArgs)>()
    let eventTaskCompleted = Event<(TaskCompletedEventArgs)>()
    
    //MARK: initialiser
    init()
    {
        self.taskThreadAbort = false
        self.taskQueue = Queue<TaskProtocol>()
    }
    
    //MARK: Functions
    func enqueue(task: TaskProtocol)
    {
        _lockQueue.sync
        {
            // instantiate the members only if the taskcontroller is really used
            InstantiateMemmbers()
            taskQueue.enqueue(element: task)
        }
        
        taskThreadWakeupEvent?.signal();
    }
    
    
    func run(task: TaskProtocol)throws
    {
        taskComplete = DispatchSemaphore(value: 0)
        runningTask = task
        
        // Register for event
        let handler = eventTaskCompleted.addHandler(self, TaskControllerSequential.onTaskCompleted)
                                 
        // Enqueue the task
        enqueue(task: task)
                
        // Wait for task to complete
        taskComplete?.wait()
            
        handler.dispose()
        taskComplete = nil
        runningTask = nil
        // Check for result of the operation and throw error if operation faild
        if taskCompletedEventArgs?.result != BleResult.success
        {
            throw BleLibraryError.taskNotSuccessful(result: (taskCompletedEventArgs?.result)!, error: taskCompletedEventArgs?.error)
        }
    }
    
    func onTaskCompleted(args: TaskCompletedEventArgs)
    {
        if runningTask === args.task
        {
            taskCompletedEventArgs = args
            taskComplete?.signal()
        }
    }
    
    func taskControllerSequential(_ taskControllerSequential: TaskControllerSequential, taskCompleted task: TaskProtocol, result: BleResult) {
        taskCompletedEventArgs = TaskCompletedEventArgs.init(task: task, result: result)
        taskComplete?.signal()
    }
    
    func dispose()
    {
        
    }
    
    private func taskThread()
    {
        repeat
        {
            taskThreadWakeupEvent?.wait()

            if taskPending == nil
            {
                _lockQueue.sync
                {
                    if taskQueue.count() > 0
                    {
                        taskPending = taskQueue.dequeue();
//                        print("TP: taskThread -> get task from queue: \(taskPending?.description)")
                    }
                }
                
                // new task to start?
                if taskPending != nil
                {
                    //trigger task start  delegate
                    eventTaskStarted.raise(data: TaskStartedEventArgs(task: taskPending!))
                    do
                    {
//                       print("TP: taskThread --> Task started: \(taskPending)")
                       try taskPending?.start(function: self.onTaskCompleat)
                    }
                    catch
                    {
                        log.error("Starting task \(taskPending.debugDescription) failed with exception \(error)")
                        taskPending = nil
                    
                        // set event handler new task
                        taskThreadWakeupEvent?.signal()
                    }
                    
                }
                
            }
            
        }while !taskThreadAbort
        log.info("task thread finnished")
    }
    
    func onTaskCompleat(task: TaskProtocol, result: BleResult)
    {
//        print("TP: onTaskCompleat --->: \(task.description)")
        
        //Check if compleated matches pending task
        if taskPending != nil && task !== taskPending!
        {
            log.error("Unexpected task completed event")
            return;
        }
        
        // task compleated
        let compleatedTask = task
        taskPending = nil
        
        //Trigger task completed delegate
        eventTaskCompleted.raise(data: TaskCompletedEventArgs(task: compleatedTask, result: result))
        
        //set event to handle new task
        taskThreadWakeupEvent?.signal();
    }
    
    private func InstantiateMemmbers()
    {
        if(dispatchTaskQueue == nil)
        {
            taskThreadWakeupEvent = DispatchSemaphore(value: 0)
            dispatchTaskQueue = DispatchQueue(label: "ch.arendi.taskControllerSequential", qos: .userInitiated/*, attributes: .concurrent*/)
            dispatchTaskQueue?.async {
                self.taskThread()
            }
        }
    }
    
    private func stopTaskThread()
    {
        log.info("Stop task thread")
        taskThreadAbort = true
        if taskThreadWakeupEvent != nil
        {
            taskThreadWakeupEvent?.signal()
        }
    }
}
