/**
 * File: BridgedType.swift
 * File Created: Saturday, 11th December 2021 11:46:06 am
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */

import Foundation


//  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
//  BridgedType -
//  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
/**
    Protocol all `Types` conform to. Ie. Strings, Numbers, Booleans etc
*/
@dynamicMemberLookup
public protocol BridgedType: Base
{
    /// TODO: 
    /// There was something here but was removed but was removed beceause it was stupid. But there has to be something 
    /// that fits here
}

extension BridgedType
{
    public subscript(dynamicMember string: String) -> Reference
    {
        get 
        { 
            (self is Operator) ? .chain([Parenthesis.default(self).minimized, string])!
                                : .chain([minimized, string])!
        }
    }
}


//  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
//  Basic types conformances -
//  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
extension String: BridgedType
{
    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        var code = code

        code.append(string: code.configuration.stringLiteralQuote)
        code.append(string: self)
        code.append(string: code.configuration.stringLiteralQuote)

        return code
    }
}

extension Int: BridgedType
{
    public func rawJS(code: Generator.Code) -> Generator.Code  { code.appending(string: description) }
}

extension Double: BridgedType
{
    public func rawJS(code: Generator.Code) -> Generator.Code  
    { 
        code.appending(string: JankNumberFormatter.string(from: NSNumber(value: self)) ?? description) 
    }
}

extension Bool: BridgedType
{
    public func rawJS(code: Generator.Code) -> Generator.Code  { code.appending(string: self ? "true" : "false") }
}

public struct BridgedArray<T: Hashable & BridgedType>: BridgedType, ExpressibleByArrayLiteral
{
    public var value: Array<T>


   //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
   //  ExpressibleByArrayLiteral protocol implementation -
   //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public typealias ArrayLiteralElement = T

    public init(arrayLiteral elements: T...) 
    where T: Hashable
    {
       value = Array(elements)
    }


   //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
   //  BridgedType protocol implementation -
   //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public func rawJS(code: Generator.Code) -> Generator.Code  
    { 
        code.appending(
            string: (
                [Parenthesis.squareOpening] 
                    + value.map { $0.rawJS(code: .new(code.configuration)).rawCode } 
                    + [Parenthesis.squareClosing]
            ).joined()
        ) 
    }
}

public struct BridgedObject: BridgedType, ExpressibleByDictionaryLiteral
{
    public let value: [Key : Value]


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  ExpressibleByDictionaryLiteral protocol implementation -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public typealias Key = String
    public typealias Value = BridgedType

    public init(dictionaryLiteral elements: (Key, Value)...) 
    {
        self.value = Dictionary(uniqueKeysWithValues: elements)
    }
    

    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  BridgedType protocol implementation -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        var code = code
        
        code.append(string: Parenthesis.curlyOpening, suppressNewline: false)

        let valueMap = value.map { $0 }
        valueMap.forEach
        {
            code.append(string: $0.key.rawJS(code: .new(code.configuration)).rawCode + 
                                (code.configuration.prettyPrinting ? " : " : ":") + 
                                $0.value.rawJS(code: .new(code.configuration)).rawCode +
                                ($0.key != valueMap.last?.key ? "," : ""), 
                        indentLevel: 1, 
                        suppressNewline: false)
        }

        code.append(string: Parenthesis.curlyClosing)
        return code
    }
}


//  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
//  Helpers -
//  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
private let JankNumberFormatter: NumberFormatter = 
{
    let nf = NumberFormatter()
    nf.locale = Locale(identifier: "en_US")
    nf.maximumFractionDigits = 999
    nf.maximumIntegerDigits = 999
    return nf
}()
