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
 * Class Name: CobsFraming.swift
 ******************************************************************************/

import BleLibrary
import Foundation
import os.log
class CobsFraming: DataExchangeProtocol
{
    //MARK: Members
    
    private var _lowerDataExchange: DataExchangeProtocol
    
    private var _sendBuffer: BlockingCollection<UInt8>
    
    private var _maxDatalength: Int
    {
        return maxDataLength + 2 + _crcProvider.crcLength
    }
    
    private var _sendTask: TaskBase? //Remove ? when implemented
    private var _exit: Bool = false
    private var _lockQueue = DispatchQueue(label: "com.outshine.fota.CobsFraming.lockQueue"/*, attributes: .concurrent*/)
    private let log: LogProtocol = LogManager.manager.createLog(name: "CobsFraming")
    
    /**
     * Buffer for received RX data
     */
    private var _frameRxBuffer: Data?
    
    /**
     * Number of RX datdatain buffer
     */
    private var _frameRxCount: Int
    
    private var _crcProvider: CrcProviderProtocol
    
    //MARK: Properties
    var eventDataRecived = Event<DataReceivedEventArgs>()
    var maxDataLength: Int = 250
    
    //MARK: EventHandlers
    private var _lowerDataExchangeOnDataReceivedHandler: EventHandlerProtocol?
    
    private var _cobsFramingWorkItem: DispatchWorkItem?
    private var _cobsFramingQueue = DispatchQueue(label: "com.outshine.fota.cobsFramingQueue", attributes: .concurrent)
    
    //MARK: Initialize
    init(dataExchange: DataExchangeProtocol, crcProvider: CrcProviderProtocol)
    {
        //reset receive buffer
        _frameRxCount = 0
        _frameRxBuffer = nil
        _sendBuffer = BlockingCollection<UInt8>()
        _lowerDataExchange = dataExchange
        _crcProvider = crcProvider
        //Add sendTask
        
        _cobsFramingWorkItem = DispatchWorkItem(block: executeSend)
        
        _cobsFramingQueue.async(execute: _cobsFramingWorkItem!)
        
        //Registrate event
        registerEvents()
    }
    
    func onLowerDataExchangeOnDataReceived(args: DataReceivedEventArgs)
    {
        log.debug("Data received")
//        print("TempPrint: DR CobsFraming.dataReceived 0x\(BinaryString.toString(buffer: args.data.toArray()))")
        processData(buffer: args.data)
    }
    
    private func registerEvents()
    {
        _lowerDataExchangeOnDataReceivedHandler = _lowerDataExchange.eventDataRecived.addHandler(self, CobsFraming.onLowerDataExchangeOnDataReceived)
    }
    
    private func deregisterEvents()
    {
        _lowerDataExchangeOnDataReceivedHandler?.dispose()
    }
    
    func initializeDataExchange()throws
    {
        _frameRxCount = 0
        _frameRxBuffer = nil
    }
    
    func transmit(buffer: Data)throws
    {
        try _lockQueue.sync{
            //encode frame
            var data: Data = Data()//Data(capacity: buffer.count + _crcProvider.crcLength)
            data.insertRangeAt(source: buffer, sourceIndex: 0, destinationIndex: 0, length: buffer.count)
        
            let crc = try _crcProvider.calculate(data: buffer, offset: 0, length: buffer.count)
            data.insertRangeAt(source: crc, sourceIndex: 0, destinationIndex: buffer.count, length: _crcProvider.crcLength)
//            print("TempPrint: buffer: 0x\(BinaryString.toString(buffer: data.toArray()))")
            
            //COBS encoding
            let encoded = try Cobs.encode(src: data)
//            print("----- encoded cobs: 0x\(BinaryString.toString(buffer: encoded.toArray()))")
//            log.debug("Add header 0x00")
            _sendBuffer.append(newElement: 0x00)
            for b in encoded
            {
//                log.debug("Add encoded data 0x\(BinaryString.toString(buffer: [b]))")
                _sendBuffer.append(newElement: b)
            }
//            log.debug("Add footer 0x00")
            _sendBuffer.append(newElement: 0x00)
        }
    }
    
    /**
     * Handle incomming data
     * @Parameter buffer: Buffer with incoming data
     */
    private func processData(buffer: Data)
    {
        // handle all incoming octets
        for j in 0..<buffer.count
        {
            // get octet
            let b = buffer[j]
            
            //received protocol start/end flag?
            if b == 0
            {
                // data recived ?
                if (_frameRxBuffer != nil && _frameRxCount > 0)
                {
                    // decode frame
                    var raw = Data()
                    for i in 0..<_frameRxCount
                    {
                        raw.append(_frameRxBuffer![i])
                    }
                    
                    do
                    {
                        var frameData = try Cobs.decode(src: raw)
                        
                        // check frame
                        if frameData.count <= _crcProvider.crcLength
                        {
                            log.error("Received frame is to short")
                        }
                        else
                        {
                            let crc = try _crcProvider.calculate(data: frameData, offset: 0, length: frameData.count - _crcProvider.crcLength)
                            
                            // check CRC
                            if !compare(a1: crc, offset1: 0, a2: frameData, offset2: frameData.count - _crcProvider.crcLength, length: _crcProvider.crcLength)
                            {
                                log.error("Received frame with invalid CRC")
                            }
                            else
                            {
                                    //extract frame
                                    var framePayLoad = Data(count: frameData.count - _crcProvider.crcLength)
                                    framePayLoad.insertRangeAt(source: frameData, sourceIndex: 0, destinationIndex: 0, length: framePayLoad.count)
                                    eventDataRecived.raise(data: DataReceivedEventArgs(data: framePayLoad))
                                    // reset frame
                                    _frameRxBuffer = Data(capacity: maxDataLength)
                                    _frameRxCount = 0
                            }
                            
                        }
                        
                    }
                    catch
                    {
                        log.error("Invalid COBS frame reviced: \(error)")
                    }
                }
                // reset frame
                _frameRxBuffer = Data(capacity: maxDataLength)
                _frameRxCount = 0
            }
            else
            {
                // already a frame started?
                if _frameRxBuffer != nil
                {
                    // add to buffer
                    if _frameRxCount < (maxDataLength)
                    {
                        _frameRxBuffer?.insert(b, at: _frameRxCount)
                        _frameRxCount += 1                        
                    }
                    else
                    {
                        // buffer overrun !
                        log.error("RX buffer overrun: buffer size: \(_frameRxBuffer?.count ?? 0)")
                        // reset RX
                        _frameRxBuffer = nil
                        _frameRxCount = 0
                    }
                }
                else
                {
                    log.error("Received data while not in a frame")
                }
            }
        }
    }
    
    private func executeSend()
    {
        var sendList: Data
        
        while !_exit
        {
            sendList = Data();
            var b: UInt8 = 0x00
            //wait for an entry in queue
            if(!_sendBuffer.tryTake(item: &b, millisecundsTimeout: 1000))
            {
                // queue is empty, contrinue
                continue
            }
            sendList.append(b)
            // take entries from queue until maxDataLength is reached
            
            repeat
            {
                //wait 20ms at max for an entry
                if(!_sendBuffer.tryTake(item: &b, millisecundsTimeout: 20))
                {
                    break
                }
                sendList.append(b)
            }while (sendList.count < _lowerDataExchange.maxDataLength)
            
            do
            {
                try _lowerDataExchange.transmit(buffer: sendList)
            }
            catch
            {
                log.error("Error while sending cobs frame \(error)")
            }
        }
    }
    
    private func compare(a1: Data?, offset1: Int, a2: Data?, offset2: Int, length: Int) -> Bool
    {
        if(a1 == nil||a2 == nil)
        {
            return false
        }
        if(a1!.count - offset1) < length
        {
            return false
        }
        if(a2!.count - offset2) < length
        {
            return false
        }
        for i in 0 ..< length
        {
            if(a1![i + offset1] != a2![i + offset2])
            {
                return false
            }
        }
        return true
    }
    
    func dispose() {
        _exit = true
        _sendBuffer.clear()
        deregisterEvents()
    }
    
    
}
