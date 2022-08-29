/**
 * File: Declaration.swift
 * File Created: Sunday, 5th December 2021 1:15:19 am
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */

public struct Declaration<T: BridgedType>: Base
{
    public let name: String
    public let value: T?

    public static func new(value: T? = nil, scope: Scope) -> Reference
    {
        let varName = scope.nameGenerator.next()
        let declaration = Declaration(name: varName, value: value)

        scope.add(declaration)
        return Reference(name: varName)
    }

    public init(name: String, value: T?)
    {        
        self.name = name
        self.value = value
    }

    public func rawJS(code: Generator.Code) -> Generator.Code
    {
        let valueRaw = (value as BridgedType? ?? Self.null).rawJS(code: code.subcode()).rawCode
        return code.appending(string: "var \(name) = \(valueRaw)")
    }
}

