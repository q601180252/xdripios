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
 * Class Name: Cobs.swift
 ******************************************************************************/

import Foundation
public struct Cobs
{
    public init(){}
    
    /**
     Returns the encoded representation of the given bytes     Inefficient method, but easy to use an understand
    
     - parameters:
        - src: the bytes to encode
     
     - returns:
        The encoded bytes
     */
    public static func encode(src: Data)throws -> Data
    {
        var dest = [Data](repeating: Data(), count: maxEncodedSize(size: src.count))
        try encode(src: src, from: 0, to: src.count, dest: &dest)
        return Data(dest.flatMap{return $0})
    }
    
    /**
     * Adds (appends) the encoded representation of the range &lt;code&gt;src[from..to)&lt;/code&gt; to the given destination list.
     
     - parameters:
        - src: the bytes to encode
        - from: the first byte to encode (inclusive)
        - to: the last byte to encode (exlusive)
        - dest: the destination list to append to
     
     - trows:
        - BleError.generalError
     
     */
    public static func encode(src: Data, from: Int, to: Int, dest: inout [Data] )throws
    {
        try checkRange(from: from, to: to, arr: src)
        
        var _from = from
        
        var code: Int = 1 // can't use unsigned byte arithmetic...
        var blockStart = -1
        
        // find zero bytes
        while _from < to
        {
            if src[_from] == 0
            {
                finishBlock(code: code, src: src, blockStart: blockStart, dest: &dest, length: (_from - blockStart))
                code = 1
                blockStart = -1
            }
            else
            {
                if blockStart < 0
                {
                    blockStart = _from
                }
                code += 1
                if code == 0xFF
                {
                    finishBlock(code: code, src: src, blockStart: blockStart, dest: &dest, length: (_from - blockStart) + 1)
                    code = 1
                    blockStart = -1
                }
            }
            _from += 1
        }
        finishBlock(code: code, src: src, blockStart: blockStart, dest: &dest, length: (_from - blockStart))
    }
    
    private static func finishBlock(code: Int, src: Data, blockStart: Int, dest: inout [Data], length: Int )
    {
        var codeByteArray = Data(count: 1)
        codeByteArray[0] = UInt8(code)
        
        dest.append(codeByteArray) //code is the count to next 00 so add one byte array to list with code in
        
        if blockStart >= 0
        {
            var myByteArray = Data(count: length)
            
            for i in 0 ..< length
            {
                myByteArray[i] = src[blockStart + i]
            }
            dest.append(myByteArray)
        }
    }
    
    /**
     Returns the maximum amount of bytes an encoding of &lt;code&gt;size&lt;/code&gt; bytes takes in the worst case.
     */
    public static func maxEncodedSize(size: Int) -> Int
    {
        return size + 1 + size / 254
    }
    
    /**
     Returns the decoded representation of the given bytes.      Inefficient method, but easy to use and understand.
     
     - parameters:
        - src: the bytes to decode
     
     - returns:
        The decoded bytes.
     */
    public static func decode(src: Data)throws -> Data
    {
        var dest = [Data]()
        try decode(src: src, from: 0, to: src.count, dest: &dest)
        return Data(dest.flatMap{return $0})
    }
    
    /**
     Adds (appends) the decoded representation of the range &lt;code&gt;src[from..to)&lt;/code&gt; to the given destination list.
     
     - parameters:
        - src: the bytes to decode
        - from: the first byte to decode (inclusive)
        - to: the last byte to decode (exclusive)
        - dest: the destination list to append to
     
     - throws:
        - BleError.generalError
     */
    public static func decode(src: Data, from: Int, to: Int, dest: inout [Data])throws
    {
        try checkRange(from: from, to: to, arr: src)
        
        var _from = from
        
        while _from < to
        {
            
            let code = Int(src[_from] & 0xFF)
            let len = code - 1
            
            _from += 1
            
            if(code == 0 || _from + len > to)
            {
                throw BleLibraryError.generalError(message: "Corrupt COBS encoded data - bug in remote encoder?")
            }
            
            var myByteArray = Data(count: len)
            
            for i in 0..<len
            {
                myByteArray[i] = src[_from + i]
            }
            dest.append(myByteArray)
            
            _from += len
            if (code < 0xFF && _from < to)
            {
                // unnecessary to write last zero(is implicit anyway)
                var zero = Data(count: 1)
                zero[0] = 0x00
                dest.append(zero)
            }
        }
    }
    
    /**
     * Checks if the given range is within the contained array's bounds
     */
    private static func checkRange(from: Int, to: Int, arr: Data)throws
    {
        if(from < 0 || from > to || to > arr.count)
        {
            throw BleLibraryError.generalError(message: "from: \(from), to: \(to), size: \(arr.count)")
        }
    }
}
