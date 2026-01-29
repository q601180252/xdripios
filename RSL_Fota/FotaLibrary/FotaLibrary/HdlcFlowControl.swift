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
 * Class Name: HdlcFlowControl.swift
 ******************************************************************************/

import BleLibrary
import Foundation
import os.log
class HdlcFlowControl : DataExchangeProtocol
{
   
    //MARK: Events
    public var eventDataRecived = Event<DataReceivedEventArgs>()
    public var connectionError = Event<EmptyEventArgs>()
    
    //MARK: Eventhanders
    private var _dataReceivedHandler: EventHandlerProtocol?
    
    public var maxDataLength: Int
    {
        return _config.maxDataLength
    }
    
    /**
     * Expected frame sequence
     */
    private var _expectedSequenceNumber: UInt8
    
    /**
     * Transmit frame sequence
     */
    private var _transmitSequenceNumber: UInt8
    
    /**
     * Queue with pending transmit frame
     */
    private var _sendQueue = Queue<HdlcTransmitEntry>()
    private let _sendQueueLock = DispatchQueue(label: "com.outshine.fota.HdlcFlowControl.sendQueuelock", attributes:  .concurrent)
    
    private var _toSend: HdlcTransmitEntry?
    
    /**
     * Queue with frames that have benn sent but not yet acknowledged
     */
    private var _acknowledgeQueue = Queue<HdlcTransmitEntry>()
    private var _acknowledgeQueueLock = DispatchQueue(label: "com.outshine.fota.HdlcFlowControl.acknowledgeQueueLock", attributes:  .concurrent)
    
    private var _receiveQueue = Queue<Data>()
    private var _receiveQueueLock = DispatchQueue(label: "com.outshine.fota.HdlcFlowControl.receiveQueueLock", attributes:  .concurrent)

    private var _uFrameRecivedEvent = DispatchSemaphore(value: 0)
    
    /**
     * Task to control the HDLC framing
     */
    private var _hdlcControlWorkItem: DispatchWorkItem?
    private var _hdlcControlQueue = DispatchQueue(label: "com.outshine.fota.hdlcControlQueue", attributes: .concurrent)
    
    private var _exit: Bool = false
    
    private var _checkQueuesAutoResetEvent = DispatchSemaphore(value: 0)
    private var _dataPendingResetEvent = DispatchSemaphore(value: 1)
    
    private var _hdlcFrameTypeSABM = 0x07
    
    private var _lowerDataExcange: DataExchangeProtocol
    
    private var _config: HdlcConfiguration
    
    private var log: LogProtocol = LogManager.manager.createLog(name: "HdlcFlowControl")
    
    init(dataExchange: DataExchangeProtocol, configuration: HdlcConfiguration)
    {
        _lowerDataExcange = dataExchange        
        _config = configuration
        
        _expectedSequenceNumber = 0
        _transmitSequenceNumber = 0
        
        _hdlcControlWorkItem = DispatchWorkItem(block: hdlcControlTask)
                
        _hdlcControlQueue.async(execute: _hdlcControlWorkItem!)
        registerEvents();
    }
    
    private func hdlcControlTask()
    {
        while !_exit
        {
            if !receivQueueHasItem()
            {
                let timeout = getNextFrameTimeout()
                self._checkQueuesAutoResetEvent.wait(timeout: (.now() + .milliseconds(timeout)))
            }
            do
            {
                if(self._exit)
                {
                    return
                }
                processReceivedData()
                processSendQueue()
                checkFrameTimeout()
            }
            catch
            {
                log.error("Exception while processing: \(error)")
            }
            
        }
    }
    
    private func receivQueueHasItem() -> Bool
    {
        var res = false
        
        _receiveQueueLock.sync {
            if _receiveQueue.count() > 0
            {
                res = true
            }
        }
        
        return res
    }
    
    private func getNextFrameTimeout() -> Int
    {
        var timeout = 0
        
        _acknowledgeQueueLock.sync {
            if _acknowledgeQueue.count() == 0
            {
                // no entries in the acknowledge queue
                return timeout = 1000
            }
            
            do{
                let entry = try _acknowledgeQueue.peek()
                if entry != nil{
                    let time = Int(Date().millisecondsSince1970 - (entry.sendTime?.millisecondsSince1970)!)
                    if time < _config.transmitAcknowledgeTimeout
                    {
                        timeout = time
                    }
                }
            }
                catch
            {
                log.error(error.localizedDescription)
            }
        }
        return timeout
    }
    
    private func processReceivedData()
    {
        var data: Data?
        _receiveQueueLock.sync{
            if _receiveQueue.count() == 0
            {
                data = nil
            }
            else
            {
                data = _receiveQueue.dequeue()!
            }
        }
        
        guard data != nil else {
            return
        }
        
        let _isIFrame = isIFrame(data: data!)
        let reciveSequenceNumber = getReceiveSequenceNumber(data: data!)
        
        if _isIFrame
        {
//            print("----- IFrame recived")
            handleIFrame(data: data!)
        }
        else if isSFrame(data: data!)
        {
//            print("----- SFrame recived")
            handleSFrame(data: data!)
        }
        else
        {
//            print("----- UFrame recived")
            handleUFrame(data: data!)
        }
        
        _acknowledgeQueueLock.sync {
            //check receive sequence number and remove sent frames from queue
            while((_acknowledgeQueue.count() > 0) && (try! _acknowledgeQueue.peek().sequenceNumber != reciveSequenceNumber))
            {
                //remove element from queue
                _acknowledgeQueue.dequeue()
            }
        }
        
        //check transmit window
        if (!processSendQueue() && _isIFrame)
        {
            sendSFrame()
        }
    }
    
    private func processSendQueue() -> Bool
    {
        return _acknowledgeQueueLock.sync( execute: {
            
            if(_acknowledgeQueue.count() >= _config.transmitWindowSize)
            {
                return false
            }
            
            var transmitEntry: HdlcTransmitEntry?
                
            guard _toSend != nil else
            {
                return false
            }
                //get entry from queue
                transmitEntry = _toSend
                _toSend = nil
                _dataPendingResetEvent.signal()
            
                //send frame
                sendIFrame(data: transmitEntry!)
                transmitEntry?.sendCount = 1
                transmitEntry?.sendTime = Date()
                        
                // add to acknowledge queue
                _acknowledgeQueue.enqueue(element: transmitEntry!)
            
            return true
        })
    }
    
    private func checkFrameTimeout()
    {
        _acknowledgeQueueLock.sync {
            // check if timeout expired
            if(_acknowledgeQueue.count() == 0)
            {
                return
            }
            do
            {
                var t = Double(try (_acknowledgeQueue.peek().sendTime?.millisecondsSince1970)! + Double(_config.transmitAcknowledgeTimeout))
                var timeout = t < Date().millisecondsSince1970
                if timeout
                {
                    // check if number of retries is reached
                    if try _acknowledgeQueue.peek().sendCount > _config.transmitMaxRetryCount
                    {
                        log.error("Acknowledge timeout -> terminate sesion")
                        
                        // terminate session
                        reset()
                        connectionError.raise(data: EmptyEventArgs())
                    }
                    else
                    {
                        log.debug("Acknowledge timeout -> resend not acknowledged frames")
                        // resend all frames
                        for var transmitEntry in _acknowledgeQueue.items
                        {
                            sendIFrame(data: transmitEntry)
                            transmitEntry.sendTime = Date()
                            transmitEntry.sendCount += 1
                        }
                    }
                }
            }
            catch
            {
                log.error("\(error)")
            }
        }
    }
    
    
    func initializeDataExchange()throws {
        reset()
        // send reset command
        sendUFrame(uFrameType: UInt8(_hdlcFrameTypeSABM))
//        do
//        {
//            if(_uFrameRecivedEvent.wait(timeout: (.now() + .milliseconds(1000))) == DispatchTimeoutResult.timedOut)
//            {
//                throw BleError.timeoutError(message: "Faild to reset HDLC link: Timeout", result: nil)
//            }
//        }
//        catch
//        {
//            log.error("\(error)")
//            throw error
//       }
    }
    
    func transmit(buffer: Data) throws {
        
        guard buffer.count <= maxDataLength else
        {
            throw BleLibraryError.illegalArgument(message: "Too many data bytes for sending over HDLC")
        }
        
        _dataPendingResetEvent.wait()
        
        _toSend = HdlcTransmitEntry(data: buffer, sequenceNumber: _transmitSequenceNumber)
        _transmitSequenceNumber = UInt8((_transmitSequenceNumber + 1) % _config.sequenceNumberCount)
        
        _checkQueuesAutoResetEvent.signal()
    }
    
    func dispose() {
        _exit = true
        _checkQueuesAutoResetEvent.suspend()
        reset()
    }
    
    func reset()
    {
        _sendQueueLock.sync {
            _sendQueue.clear()
        }
        _acknowledgeQueueLock.sync {
            _acknowledgeQueue.clear()
        }
        _expectedSequenceNumber = 0
        _transmitSequenceNumber = 0
    }
    
    private func lowerDataExhangeOnDatareceived(args: DataReceivedEventArgs)
    {
        log.debug("Data received")
//        print("TempPrint: DR HdlcFlowControl.dataReceived: 0x\(BinaryString.toString(buffer: args.data.toArray()))")
        _receiveQueueLock.sync {
            _receiveQueue.enqueue(element: args.data)
        }
        _checkQueuesAutoResetEvent.signal()
    }

    private func sendIFrame(data: HdlcTransmitEntry)
    {
        log.debug("<-- I -frame - N(R):\(_expectedSequenceNumber) N(S):\(data.sequenceNumber)")
        
        var frame = Data()
        frame.append(UInt8(((_expectedSequenceNumber << 5) & 0xE0) | ((data.sequenceNumber << 1) & 0x0E)))
        frame.insertRangeAt(source: data.data, sourceIndex: 0, destinationIndex: 1, length: data.data.count)
        do
        {
//            print("----- sendIFrame: 0x\(BinaryString.toString(buffer: frame.toArray()))")
            try _lowerDataExcange.transmit(buffer: frame)
        }
        catch
        {
            log.error("Failed to transmit I-frame")
        }
    }

    private func sendUFrame(uFrameType: UInt8)
    {
        log.debug("<-- U-frame - Type: \(uFrameType)")
        
        // encode frame
        var frame = Data()
        frame.append(UInt8((UInt8(uFrameType) << 3 & 0xE0) | (UInt8(uFrameType) << 2 & 0x0C) | 0x03))
//        print("TempPrint: frame: \(frame[0])")
        
        do
        {
            try _lowerDataExcange.transmit(buffer: frame)
        }
        catch
        {
            log.error("Failed to transmit U_frame")
        }
    }
    
    private func sendSFrame()
    {
        log.debug("<-- S-frame - N(R):\(_expectedSequenceNumber)")
        var frame = Data()
        frame.append(UInt8(((_expectedSequenceNumber << 5) & 0xE0) | 0x01))
        do
        {
//            print("----- sendSFrame: 0x\(BinaryString.toString(buffer: frame.toArray()))")
            try _lowerDataExcange.transmit(buffer: frame)
        }
        catch
        {
            log.error("Failed to transmit S-frame")
        }
    }
    
    private func handleIFrame(data: Data)
    {
        var sentSequenceNumber: UInt8 = getSentSequenceNumber(data: data)
        var receiveSequenceNumber: UInt8 = getReceiveSequenceNumber(data: data)
        log.debug("--> I-frame - N(R):\(receiveSequenceNumber) N(S):\(sentSequenceNumber)")
        if sentSequenceNumber == _expectedSequenceNumber
        {
            // update expected sequence number
            _expectedSequenceNumber = UInt8(_expectedSequenceNumber + 1) % _config.sequenceNumberCount
            var payload = Data()
            payload.insertRangeAt(source: data, sourceIndex: 1, destinationIndex: 0, length: data.count - 1)
            eventDataRecived.raise(data: DataReceivedEventArgs(data: payload))
        }
        else
        {
            log.error("I-frame with invalid sent sequence number ignored (Received: \(sentSequenceNumber) Expected: \(_expectedSequenceNumber))")
        }
    }
    
    private func handleSFrame(data: Data)
    {
        var receiveSequenceNumber: UInt8 = getReceiveSequenceNumber(data: data)
        log.debug("--> S-frame - N(R):\(receiveSequenceNumber)")
    }
    
    private func handleUFrame(data: Data)
    {
        var receiveSequenceNumber: UInt8 = getReceiveSequenceNumber(data: data)
        log.debug("--> U-frame - N(R):\(receiveSequenceNumber)")
        _uFrameRecivedEvent.signal()
    }
    
    private func isIFrame(data: Data) -> Bool
    {
        return ((data[0] & 0x01) == 0)
    }
    
    private func isSFrame(data: Data) -> Bool
    {
        return ((data[0] & 0x02) == 0)
    }
    
    private func getSentSequenceNumber(data: Data) -> UInt8
    {
        return UInt8((data[0] >> 1) & 0x07)
    }
    
    private func getReceiveSequenceNumber(data: Data) -> UInt8
    {
        return UInt8((data[0] >> 5) & 0x07)
    }

    private func registerEvents()
    {
        _dataReceivedHandler = _lowerDataExcange.eventDataRecived.addHandler(self, HdlcFlowControl.lowerDataExhangeOnDatareceived)
    }
    
    private func deregisterEvents()
    {
        _dataReceivedHandler?.dispose()
    }
}
