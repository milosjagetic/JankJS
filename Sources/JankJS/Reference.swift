/**
 * File: Reference.swift
 * File Created: Saturday, 11th December 2021 4:58:44 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */

public struct Reference: BridgedType
{
    public static let this = Reference(name: "this")
    public static let null = Reference(name: "null")
    public static let document = Reference(name: "document")
    public static let window = Reference(name: "window")
    
    var name: String

    public var codeValue: String { name }

    @discardableResult
    public func execute(_ arguments: BridgedType ...) -> Executed
    {
        return Executed(base: self, arguments: arguments)
    }

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        var code = code
        code.append(string: name)

        return code
    }
}
