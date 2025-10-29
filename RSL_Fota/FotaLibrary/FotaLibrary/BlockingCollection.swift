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
 * Class Name: BlockingCollection.swift
 ******************************************************************************/

import BleLibrary
import Foundation
import os.log
class BlockingCollection<T>: Collection
{
    private var array: [T] = []
    private let queue = DispatchQueue(label: "com.outshine.Fota.BlockingCollection")
    private var semaphore = DispatchSemaphore(value: 0)
    private let log: LogProtocol = LogManager.manager.createLog(name: "BlockingCollection")
    
    /**
     Get the start index of the array
     */
    public var startIndex: Int {
        return queue.sync {
            return array.startIndex
        }
    }
    
    /**
     Get the ende index of the array
     */
    public var endIndex: Int {
        return queue.sync {
            return array.endIndex
        }
    }
    
    /**
     Appen a new element to the end of the array
     
     - parameters:
        - newElement: object of typ T
     */
    public func append(newElement: T) {
        return queue.sync {
            array.append(newElement)
            semaphore.signal()
        }
    }
    
    /**
     Get or set value at a specifict position in the collection
     
     - parameters:
        - index: idex of the parameter
        - newValue: the new object of T to be insearted
     */
    subscript(index: Int) -> T {
        set(newValue) {
            queue.sync {
                array[index] = newValue
            }
        }
        get {
            return queue.sync {
                return array[index]
            }
        }
    }
    
    /**
     Remove all objects int the collection
     */
    public func clear()
    {
        queue.sync {
            array.removeAll()
        }
    }
    
    func index(after i: Int) -> Int {
        return queue.sync {
            return array.index(after: i)
        }
    }
    
    /**
     Try to return an object from the collection in a specified time limit
     
     - parameters:
         - item: object that will contain the retrived object
         - millisecundsTimeout: timeout time in [ms]
     
     - returns:
        True if there were an object to retrive, false if timeouted
     */
    public func tryTake(item: inout T, millisecundsTimeout: Int ) -> Bool
    {
        
        let res = semaphore.wait(timeout: (.now() + .milliseconds(millisecundsTimeout)))
                
        if(res == .success && self.array.count > 0)
        {
            queue.sync
                {
                    item = self.array.removeFirst()
                }
            return true
        }
        
        log.error("TimedOut after: \(millisecundsTimeout)")
        return false
    }
    
}
