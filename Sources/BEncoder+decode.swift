//
//  BEncoder+decode.swift
//  BitTorrent
//
//  Created by Ben Davis on 09/01/2016.
//  Copyright © 2016 Ben Davis. All rights reserved.
//

import Foundation

public extension BEncoder {
    
    /**
     Decodes BEncoded data to swift objects
     
     - parameter byteStream: Any class implementing the ByteStream protocol that will feed the
     decoder sequential bytes from BEncoded data.
     
     - throws: BEncoderException.InvalidBEncode if unable to decode the data
     
     - returns: An Int, String, Data, Array or Dictionary depending on the type of the
     BEncoded data
     */
    public class func decode(_ byteStream: ByteStream) throws -> Any {
        return try decode(byteStream, decodeDictionariesWithStringKeys: false)
    }
    
    public class func decode(_ byteStream: ByteStream, decodeDictionariesWithStringKeys: Bool) throws -> Any {
        let firstByte = byteStream.nextByte()
        byteStream.advanceBy(-1)
        
        if firstByte == ascii_i {
            return try decodeInteger(byteStream)
        } else if firstByte == ascii_l {
            return try decodeList(byteStream, decodeDictionariesWithStringKeys: decodeDictionariesWithStringKeys)
        } else if firstByte == ascii_d {
            if decodeDictionariesWithStringKeys {
                return try decodeStringKeyedDictionary(byteStream)
            } else {
                return try decodeDictionary(byteStream)
            }
        } else {
            return try decodeByteString(byteStream)
        }
    }
    
    /**
     Convenience method to decode NSData.
     */
    public class func decode(_ data: Data) throws -> Any {
        return try decode(DataByteStream(data: data))
    }
    
    public class func decode(_ data: Data, decodeDictionariesWithStringKeys stringKeys: Bool) throws -> Any {
        return try decode(DataByteStream(data: data), decodeDictionariesWithStringKeys: stringKeys)
    }
    
    // MARK: -
    
    public class func decodeInteger(_ data: Data) throws -> Int {
        return try decodeInteger(DataByteStream(data: data))
    }
    
    public class func decodeInteger(_ byteStream: ByteStream) throws -> Int {
        
        try testFirstByte(byteStream, expectedFirstByte: ascii_i)

        return try buildAsciiIntegerFromStream(byteStream, terminator: ascii_e)
    }
    
    fileprivate class func testFirstByte(_ byteStream: ByteStream, expectedFirstByte: Byte) throws {
        let firstByte = byteStream.nextByte()
        if firstByte != expectedFirstByte {
            throw BEncoderException.invalidBEncode
        }
    }
    
    fileprivate class func buildAsciiIntegerFromStream(_ byteStream: ByteStream, terminator: Byte) throws -> Int {
        var currentDigit = byteStream.nextByte()
        var result: Int = 0
        while currentDigit != terminator {
            result = try appendNextDigitIfNotNil(result, currentDigit: currentDigit)
            currentDigit = byteStream.nextByte()
        }
        return result
    }
    
    fileprivate class func appendNextDigitIfNotNil(_ integer: Int, currentDigit: Byte?) throws -> Int {
        if let digit = currentDigit {
            return try appendAsciiDigitToInteger(integer, digit: digit)
        } else {
            throw BEncoderException.invalidBEncode
        }
    }
    
    fileprivate class func appendAsciiDigitToInteger(_ integer: Int, digit: UInt8) throws -> Int {
        do {
            return try integer.appendAsciiDigit(digit)
        } catch let e as AsciiError where e == AsciiError.invalid {
            throw BEncoderException.invalidBEncode
        }
    }
    
    public class func decodeByteString(_ data: Data) throws -> Data {
        return try decodeByteString(DataByteStream(data: data))
    }
    
    public class func decodeByteString(_ byteStream: ByteStream) throws -> Data {
        let numberOfBytes = try buildAsciiIntegerFromStream(byteStream, terminator: ascii_colon)
        guard let result = byteStream.nextBytes(numberOfBytes) else {
            throw BEncoderException.invalidBEncode
        }
        return result
    }

    public class func decodeString(_ data: Data) throws -> String {
        return try decodeString(DataByteStream(data: data))
    }

    public class func decodeString(_ byteStream: ByteStream) throws -> String {
        let data = try decodeByteString(byteStream)
        guard let result = String(asciiData: data) else {
            throw BEncoderException.invalidBEncode
        }
        return result
    }
    
    public class func decodeList(_ data: Data) throws -> [Any] {
        return try decodeList(DataByteStream(data: data))
    }
    
    public class func decodeList(_ byteStream: ByteStream) throws -> [Any] {
        return try decodeList(byteStream, decodeDictionariesWithStringKeys: false)
    }
    
    public class func decodeList(_ data: Data, decodeDictionariesWithStringKeys stringKeys: Bool) throws -> [Any] {
        return try decodeList(DataByteStream(data: data), decodeDictionariesWithStringKeys:stringKeys)
    }
    
    public class func decodeList(_ byteStream: ByteStream,
                                 decodeDictionariesWithStringKeys stringKeys: Bool) throws -> [Any] {
        var result: [Any] = []
        try testFirstByte(byteStream, expectedFirstByte: ascii_l)
        
        var currentByte = byteStream.nextByte()
        while currentByte != ascii_e {
            byteStream.advanceBy(-1)
            let object = try decode(byteStream, decodeDictionariesWithStringKeys: stringKeys)
            result.append(object)
            currentByte = byteStream.nextByte()
        }
        return result
    }
    
    public class func decodeDictionary(_ data: Data) throws -> [Data: Any] {
        return try decodeDictionary(DataByteStream(data: data))
    }
    
    public class func decodeDictionary(_ byteStream: ByteStream) throws -> [Data: Any] {
        
        var result: [Data: Any] = [:]
        
        try testFirstByte(byteStream, expectedFirstByte: ascii_d)
        
        var currentByte = byteStream.nextByte()
        while currentByte != ascii_e {
            
            byteStream.advanceBy(-1)
            
            let key = try decodeByteString(byteStream)
            let object = try decode(byteStream)
            
            result[key] = object
            
            currentByte = byteStream.nextByte()
        }
        
        return result
    }
    
    public class func decodeStringKeyedDictionary(_ data: Data) throws -> [String: Any] {
        return try decodeStringKeyedDictionary(DataByteStream(data: data))
    }
    
    public class func decodeStringKeyedDictionary(_ byteStream: ByteStream) throws -> [String: Any] {
        
        var result: [String: Any] = [:]
        
        try testFirstByte(byteStream, expectedFirstByte: ascii_d)
        
        var currentByte = byteStream.nextByte()
        while currentByte != ascii_e {
            
            byteStream.advanceBy(-1)
            
            let key = try decodeString(byteStream)
            let object = try decode(byteStream, decodeDictionariesWithStringKeys: true)
            
            result[key] = object
            
            currentByte = byteStream.nextByte()
        }
        
        return result
    }
    
    public class func decodeDictionaryKeysOnly(_ data: Data) throws -> [String: Data] {
        return try decodeDictionaryKeysOnly(DataByteStream(data: data))
    }
    
    public class func decodeDictionaryKeysOnly(_ byteStream: ByteStream) throws -> [String: Data] {
        
        var result = [String:Data]()
        try testFirstByte(byteStream, expectedFirstByte: ascii_d)
        
        var currentByte = byteStream.nextByte()
        while currentByte != ascii_e {
            
            byteStream.advanceBy(-1)
            
            let key = try decodeString(byteStream)
            
            let startIndex = byteStream.currentIndex
            let _ = try decode(byteStream)
            let numberOfBytesInValue = byteStream.currentIndex - startIndex
            byteStream.advanceBy(-numberOfBytesInValue)
            let value = byteStream.nextBytes(numberOfBytesInValue)
            
            result[key] = value
            
            currentByte = byteStream.nextByte()
        }
        
        return result
    }
}
