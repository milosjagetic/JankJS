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
@dynamicMemberLookup
public protocol BridgedType: Base
{
    var codeValue: String { get }
}

extension BridgedType
{
    public subscript(dynamicMember string: String) -> Reference
    {
        get { Reference(name: "\(codeValue).\(string)") }
    }

}


//  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
//  Basci types conformances -
//  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
extension String: BridgedType
{
    public var codeValue: String { "'\(self)'" }
    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        var code = code
        code.append(string: codeValue)

        return code
    }
}

extension Int: BridgedType
{
    public var codeValue: String { description }
    public func rawJS(code: Generator.Code) -> Generator.Code  { code.appending(string: codeValue) }
}

extension Double: BridgedType
{
    public var codeValue: String { JankNumberFormatter.string(from: NSNumber(value: self)) ?? description }
    public func rawJS(code: Generator.Code) -> Generator.Code  { code.appending(string: codeValue) }
}

extension Bool: BridgedType
{
    public var codeValue: String { self ? "true" : "false" }
    public func rawJS(code: Generator.Code) -> Generator.Code  { code.appending(string: codeValue) }
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
