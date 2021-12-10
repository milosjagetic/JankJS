/**
 * File: Declaration.swift
 * File Created: Sunday, 5th December 2021 1:15:19 am
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */

public protocol BridgedType: Base
{
}

extension String: BridgedType
{
    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        var code = code
        code.append(string: "\"\(self)\"")

        return code
     }
}

extension Int: BridgedType
{
    public func rawJS(code: Generator.Code) -> Generator.Code  { code.appending(string: description) }
}

public struct Reference: BridgedType
{
    var name: String

    public static var type: BaseType { .reference }

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        var code = code
        code.append(string: name)

        return code
    }
}

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

    // public static func new(value: Reference? = nil, scope: Scope) -> Reference
    // {
    //     let varName = scope.nameGenerator.next()
        
    //     let declaration = Declaration<String>(name: varName, value: value?.name)

    //     scope.add(declaration)
    //     return Reference(name: varName)
    // }

    internal init(name: String, value: T?)
    {        
        self.name = name
        self.value = value
    }


    public func rawJS(code: Generator.Code) -> Generator.Code
    {
        let valueRaw = value?.rawJS(code: .init(configuration: code.configuration,
                                                      rawCode: "")).rawCode ?? Self.null
        return code.appending(string: "var \(name) = \(valueRaw)")
    }
}

