/**
 * File: Declaration.swift
 * File Created: Sunday, 5th December 2021 1:15:19 am
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */

public protocol BridgedType: Base
{
    associatedtype ValueType


}

public struct Declaration<T: BridgedType>: Base
{
    public let type: T
    public let name: String
    public let value: T.ValueType?

    init(name: inout String, type: T,value: T.ValueType?)
    {
        self.type = type
        
        let varName = NameGenerator().next()
        self.name = NameGenerator().next()
        self.value = value

        name = self.name
    }

    public func rawJS(code: Generator.Code)  
    {
        code.append(string: "var \(name)")
    }
}

