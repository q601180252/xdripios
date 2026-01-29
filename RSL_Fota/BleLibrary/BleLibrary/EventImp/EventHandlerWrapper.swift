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
 * Class Name: EventHandlerWrapper.swift
 ******************************************************************************/

import Foundation
class EventHandlerWrapper<T: AnyObject, U>: Invocable, EventHandlerProtocol {
    var description: String
    {
        return "EventHandler for \(U.self)"
    }
    
    weak var target: T?
    let handler: (T) -> (U) -> ()
    let event: Event<U>
    
    init(target: T?, handler: @escaping (T) -> (U) -> (), event: Event<U>) {
        self.target = target
        self.handler = handler
        self.event = event;
    }
    
    func invoke(_ data: Any) -> () {
        if let t = target { handler(t)(data as! U) }
    }
    
    /**
     * @function dispose
     *
     * @abstract
     * remove this handler form the event
     */
    func dispose() {
        event.removeHandler(self)
    }
}
