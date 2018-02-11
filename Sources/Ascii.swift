//
//  Ascii.swift
//  BitTorrent
//
//  Created by Ben Davis on 02/01/2016.
//  Copyright © 2016 Ben Davis. All rights reserved.
//

import Foundation

public enum AsciiError: Error {
    case invalid
}

public extension UInt8 {
    
    func asciiValue() throws -> Byte {
        if self >= 10 {
            throw AsciiError.invalid
        }
        return self + 48 // 48 is ascii for 0
    }
    
    func fromAsciiValue() throws -> UInt8 {
        if self > 57 || self < 48 {
            throw AsciiError.invalid
        }
        return self - 48 // 48 is ascii for 0
    }
}

public extension Int {
    
    func digitsInAscii() -> Data {
        let (head, tailByte) = self.splitAndAsciiEncodeLastDigit()
        if head > 0 {
            return head.digitsInAscii() + tailByte
        }
        return tailByte
    }
    
    private func splitAndAsciiEncodeLastDigit() -> (head: Int, tail: Data) {
        let (head, tail) = splitDigitsOnLast()
        return (head, try! tail.digitAsAsciiByte())
    }
    
    private func digitAsAsciiByte() throws -> Data {
        return try UInt8(self).asciiValue().toData()
    }
    
    private func splitDigitsOnLast() -> (head: Int, tail: Int) {
        return (self / 10, self % 10)
    }
    
    init(asciiData data: Data) throws {
        guard data.count > 0 else {
            self = 0
            return
        }
        let (headOfData, decodedLastByte) = try Int.splitDataAndDecodeLastByte(data)
        let resultOfDecodingTheHead = try Int(asciiData: headOfData)
        self = decodedLastByte + ( 10 * resultOfDecodingTheHead )
    }
    
    private static func splitDataAndDecodeLastByte(_ data: Data) throws -> (Data, Int) {
        let (headOfData, lastByte) = splitDataBeforeLastByte(data)
        let decodedLastByte = try lastByte.fromAsciiValue()
        return (headOfData, Int(decodedLastByte))
    }
    
    private static func splitDataBeforeLastByte(_ data: Data) -> (Data, UInt8) {
        let headOfData = data[ 0 ..< data.endIndex-1 ]
        let lastByte = data.last!
        return (headOfData, lastByte)
    }
}

public extension Int {
    
    func appendAsciiDigit(_ asciiDigit: Byte) throws -> Int {
        let digit = Int(try asciiDigit.fromAsciiValue())
        return self*10 + digit
    }
}

public extension Character {
    
    func asciiValue() throws -> Data {
        let unicodeScalarCodePoint = self.unicodeScalarCodePoint()
        if !unicodeScalarCodePoint.isASCII {
            throw AsciiError.invalid
        }
        return UInt8(ascii: unicodeScalarCodePoint).toData()
    }
    
    func unicodeScalarCodePoint() -> UnicodeScalar {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        return scalars[scalars.startIndex]
    }
}

public extension String {
    
    init?(asciiData: Data?) {
        if asciiData == nil { return nil }
        self.init(data: asciiData!, encoding: .ascii)
    }
    
    func asciiValue() throws -> Data {
        guard let result = self.data(using: .ascii) else {
            throw AsciiError.invalid
        }
        return result
    }
}
