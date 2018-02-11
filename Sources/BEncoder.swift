//
//  BEncoder.swift
//  BitTorrent
//
//  Created by Ben Davis on 02/01/2016.
//  Copyright © 2016 Ben Davis. All rights reserved.
//

import Foundation

enum BEncoderException: Error {
    case invalidAscii
    case invalidBEncode
    case unrepresentableObject
}

public class BEncoder {
    
    static let ascii_i:      Byte = 105
    static let ascii_l:      Byte = 108
    static let ascii_d:      Byte = 100
    static let ascii_e:      Byte = 101
    static let ascii_colon:  Byte = 58
    
    static let IntergerStartToken       = try! Character("i").asciiValue()
    static let ListStartToken           = try! Character("l").asciiValue()
    static let DictinaryStartToken      = try! Character("d").asciiValue()
    static let StructureEndToken        = try! Character("e").asciiValue()
    static let StringSizeDelimiterToken = try! Character(":").asciiValue()
    
    /**
     Creates a NSData object containing the BEncoded representation of the object passed.
     
     - parameter object: Object to be encoded
     
     - throws: BEncoderException if the object cannot be represented in BEncode
     */
    public class func encode(_ object: Any) throws -> Data {
        if object is Int {
            return encodeInteger(object as! Int)
        } else if object is String {
            return try encodeString(object as! String)
        } else if object is Data {
            return encodeByteString(object as! Data)
        } else if object is [Any] {
            return try encodeList(object as! [Any])
        } else if object is [String: Any] {
            return try encodeDictionary(object as! [String: Any])
        } else if object is [Data: Any] {
            return try encodeByteStringKeyedDictionary(object as! [Data: Any])
        }
        throw BEncoderException.unrepresentableObject
    }

    /**
     Creates BEncoded integer
     */
    public class func encodeInteger(_ integer: Int) -> Data {
        return IntergerStartToken + integer.digitsInAscii() + StructureEndToken
    }
    
    /**
     Creates a BEncoded byte string
     */
    public class func encodeByteString(_ byteString: Data) -> Data {
        let numberOfBytes = byteString.count
        return numberOfBytes.digitsInAscii() + StringSizeDelimiterToken + byteString
    }
    
    /**
     Creates a BEncoded byte string with the ascii representation of the string
     
     - throws: BEncoderException.InvalidAscii if the string cannot be represented in ASCII
     */
    public class func encodeString(_ string: String) throws -> Data {
        let asciiString = try asciiValue(string)
        return asciiString.count.digitsInAscii() + StringSizeDelimiterToken + asciiString
    }
    
    /**
     Creates a BEncoded list and BEncodes each object in the list
     
     - parameter list: Array of items to be BEncoded and added to the resulting BEncode list
     
     - throws: Exception if any of the objects are not BEncode-able
     
     */
    public class func encodeList(_ list: [Any]) throws -> Data {
        let innerData = try encodeListInnerValues(list)
        return ListStartToken + innerData + StructureEndToken
    }
    
    private class func encodeListInnerValues(_ list: [Any]) throws -> Data {
        return try list.reduce(Data()) { (result: Data, item: Any) throws -> Data in
            let encodedItem = try encode(item)
            return result + encodedItem
        }
    }
    
    /**
     Creates a BEncoded dictionary and BEncodes each value.
     The keys are BEncoded as byte strings
     
     - parameter list: Dictionary of items to be BEncoded and added to the resulting BEncode
     dictionary. Keys should be data which will be BEncoded as a byte string.
     
     - throws: BEncoderException if any of the objects are not BEncode-able
     
     */
    public class func encodeByteStringKeyedDictionary(_ dictionary: [Data: Any]) throws -> Data {
        let innerData = try encodeDictionaryInnerValues(dictionary)
        return DictinaryStartToken + innerData + StructureEndToken
    }
    
    private class func encodeDictionaryInnerValues(_ dictionary: [Data: Any]) throws -> Data {
        return try dictionary.reduce(Data(), appendKeyValuePairToDictionaryData)
    }
    
    private class func appendKeyValuePairToDictionaryData(_ data: Data,
                                                          pair: (key: Data, value: Any)) throws -> Data {
        let encodedValue = try encode(pair.value)
        return data + encodeByteString(pair.key) + encodedValue
    }
    
    /**
     Creates a BEncoded dictionary and BEncodes each value.
     The keys are BEncoded as strings
     
     - parameter list: Dictionary of items to be BEncoded and added to the resulting BEncode 
                       dictionary. Keys should be ASCII encodeable strings.
     
     - throws: BEncoderException if any of the objects are not BEncode-able.
     BEncoderException.InvalidAscii is thrown if the keys cannot be encoded in ASCII

     */
    public class func encodeDictionary(_ dictionary: [String: Any]) throws -> Data {
        let dictionaryWithEncodedKeys = try createDictionaryWithEncodedKeys(dictionary)
        let innerData = try encodeDictionaryInnerValues(dictionaryWithEncodedKeys)
        return DictinaryStartToken + innerData + StructureEndToken
    }
    
    private class func createDictionaryWithEncodedKeys(_ dictionary: [String: Any]) throws -> [Data: Any] {
        var dictionaryWithEncodedKeys: [Data: Any] = [:]
        for (key, value) in dictionary {
            let asciiKey = try asciiValue(key)
            dictionaryWithEncodedKeys[asciiKey] = value
        }
        return dictionaryWithEncodedKeys
    }
    
    // MARK: -
    
    private class func asciiValue(_ string: String) throws -> Data {
        do {
            let asciiString = try string.asciiValue()
            return asciiString as Data
        } catch _ {
            throw BEncoderException.invalidAscii
        }
    }
}
