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
 * Class Name: Event.swift
 ******************************************************************************/

import Foundation

public class Event<T> {
    
    public typealias EventHandler = (T) -> ()
    
    private let eventQueueLock = DispatchSemaphore.init(value: 1)
    
    private var eventHandlers = [Invocable]()
    
    /**
     Call all eventhadlers that are registerd to this event
     
     - parameters:
        - data: Data that shall be send to the eventhandlers. Preferable an EventArgs object
     */
    public func raise(data: T) {
        
        eventQueueLock.wait()
            let handler = self.eventHandlers
        eventQueueLock.signal()
        
        if self.eventHandlers.count > 0{
            for handler in self.eventHandlers
            {
                handler.invoke(data)
            }
        }        
    }
    
    /**
     Add a new eventHandler to the event.
     
     - parameters:
        - target: The class where the event handler is located
     - handler: Escaping clouser that hadle the event call
     
     - returns:
        The eventhandler as EventHandlerProtocol
     */
    public func addHandler<U: AnyObject>(_ target: U, _ handler: @escaping (U) -> EventHandler) -> EventHandlerProtocol {
        let wrapper = EventHandlerWrapper(target: target, handler: handler, event: self)
        eventQueueLock.wait()
            self.eventHandlers.append(wrapper)
        eventQueueLock.signal()
        return wrapper
    }
    
    /**
     Remove the handler from the array
     
     - parameters:
        - handler: to be removed
     */
    public func removeHandler(_ handler: Invocable)
    {
        eventQueueLock.wait()
            self.eventHandlers = self.eventHandlers.filter { $0 !== handler }
        eventQueueLock.signal()
    }
    
    public init()
    {
        
    }
}







