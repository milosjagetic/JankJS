/**
 * File: Base.swift
 * File Created: Sunday, 5th December 2021 10:11:45 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */



//==//===============================================================\\
//  Base -
//==\\===============================================================//
public protocol Base
{
    func rawJS(code: Generator.Code) -> Generator.Code
}

extension Base
{
    public var prettyPrinted: String 
    {
        generate(with: .init(configuration: .init(prettyPrinting: true))).rawCode
    }

    public var minimized: String 
    {
        generate(with: .init(configuration: .init(prettyPrinting: false))).rawCode
    }
}


//==//===============================================================\\
//  Executed -
//==\\===============================================================//
public struct Executed: BridgedType
{
    public let base: Base
    public let arguments: [BridgedType]


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Lifecycle -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    init(base: Base)
    {
        self.base = base
        arguments = []
    }

    init(base: Base, argument: BridgedType)
    {
        self.base = base
        arguments = [argument]
    }

    init(base: Base, arguments: BridgedType ...)
    {
        self.base = base
        self.arguments = arguments
    }

    init(base: Base, arguments: [BridgedType])
    {
        self.base = base
        self.arguments = arguments
    }

    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  BridgedType protocol implementation -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public var codeValue: String { rawJS(code: .init(configuration: .init(), rawCode: "")).rawCode }

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        let argumentsString = arguments.map({ $0.rawJS(code: code.subcode()).rawCode }).joined(separator: ", ")
        return code.appending(string: base.rawJS(code: code.subcode()).rawCode)
                    .appending(string: "(\(argumentsString))")
    }
}


public protocol Executable
{
    func execute(_ arguments: [BridgedType]) -> Executed
}

public extension Executable
{
    @discardableResult
    func callAsFunction(_ arguments: BridgedType ...) -> Executed
    {
        execute(arguments)
    }
    
    @discardableResult
    func execute(_ arguments: BridgedType ...) -> Executed
    {
        execute(arguments)
    }
}

