/**
 * File: Base.swift
 * File Created: Sunday, 5th December 2021 10:11:45 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */


public protocol Base
{
    func rawJS(code: Generator.Code) -> Generator.Code
}

extension Base
{
    public static var null: Reference { .null }
    public static var this: Reference { .this }
}

extension RawRepresentable
where RawValue == String, Self: Base
{
    public func rawJS(code: Generator.Code) -> Generator.Code
    {
        var code = code
        code.append(string: rawValue)

        return code
    }
}


public struct Executed: BridgedType
{
    public let base: Base
    public let arguments: BridgedType?

    public var codeValue: String { rawJS(code: .init(configuration: .init(), rawCode: "")).rawCode }

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        return code.appending(string: base.rawJS(code: code.subcode()).rawCode)
                .appending(string: "(\(arguments?.rawJS(code: code.subcode()).rawCode ?? ""))")
    }
}
