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
 * Class Name: FotaFrameHandler.swift
 ******************************************************************************/

import BleLibrary
import Foundation
import os.log
class FotaFrameHandler: DataExchangeProtocol {
    
    //MARK: events
    var eventDataRecived = Event<DataReceivedEventArgs>()
    var eventProgressChanged = Event<ProgressChangedEventArgs>()
    
    //MARK: eventhandlers
    private var _dataRecivedHandler: EventHandlerProtocol?
    
    //MARK: properties
    var maxDataLength: Int
    {
        return 10 * 1024 * 1024
    }
    
    //MARK: members
    private var _lowerDataExchange: DataExchangeProtocol
    private let _downloadImageCmd: UInt8 = 0x01
    private var _cancelRequest: Bool = false
    private let log: LogProtocol = LogManager.manager.createLog(name: "FotaFrameHandler")
    
    //MARK: Initializ
    init(dataExchange: DataExchangeProtocol)
    {
        _lowerDataExchange = dataExchange
        registerEvent()
    }
    
    //MARK: Public functions
    public func initializeDataExchange() {
        
    }
    
    public func imageDownload(imageData: Data)throws
    {
        var header = [UInt8]([_downloadImageCmd, 0, 0, 0, 0, 0, 0, 0])
        try BufferAccess.WriteUInt32LittleEndian(data: UInt32(imageData.count), buffer: &header, offset: 4)
        try transmit(data: Data(header), offset: 0, length: header.count)
        try transmit(data: imageData, offset: 0, length: imageData.count)
    }
    
    public func transmit(buffer: Data) throws {
        try transmit(data: buffer, offset: 0, length: buffer.count)
    }
    
    
    private func transmit(data: Data, offset: Int, length: Int)throws
    {
        _cancelRequest = false
        var myOffset = offset
        
        do{
            guard !_cancelRequest else
            {
                throw FotaError.Cancelled(message: "ForaFrameHandler transmit cancelled")
            }
            repeat
            {
                let size: Int
                if(_lowerDataExchange.maxDataLength < (length - myOffset))
                {
                    size = _lowerDataExchange.maxDataLength
                }
                else
                {
                    size = length - myOffset
                }
                var toSend = Data()
                toSend.insertRangeAt(source: data, sourceIndex: myOffset, destinationIndex: 0, length: size)
                try _lowerDataExchange.transmit(buffer: toSend)
                myOffset += size
                eventProgressChanged.raise(data: ProgressChangedEventArgs(current: myOffset, total: length))
            }while myOffset < length
        }
        catch
        {
            log.error("Failed to transmit \(error)")
        }
    }
    
    private func DataReceived(args: DataReceivedEventArgs)
    {
//        print("TempPrint: DR FotaHandler.DataReceived 0x\(BinaryString.toString(buffer: args.data.toArray()))")
        eventDataRecived.raise(data: args)
    }
    
    private func registerEvent()
    {
        _dataRecivedHandler = _lowerDataExchange.eventDataRecived.addHandler(self, FotaFrameHandler.DataReceived)
    }
    
    private func deregisterEvent()
    {
        _dataRecivedHandler?.dispose()
    }
    
    func dispose() {
        deregisterEvent()
        
    }
    
    
}
