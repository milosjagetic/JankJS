/**
 * File: Reference.swift
 * File Created: Saturday, 11th December 2021 4:58:44 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */

public class Reference: BridgedType, Executable
{
    public static let this = Reference(name: "this")
    public static let null = Reference(name: "null")
    public static let document = Reference(name: "document")
    public static let window = Reference(name: "window")
    public static let math = Reference(name: "Math")

    public var name: String

    private var previous: Reference?

    // TODO: Probably should validate name to exclude "." for example
    public init(name: String)
    {
        self.name = name
    }

    /**
        Constructs a chain of `Reference` instances from the given `names`. Returns the last element of the chain.
    */
    public static func chain(_ names: [String]) -> Reference?
    {
        names.reduce(nil)
        {
            let reference = Reference(name: $1)
            reference.previous = $0
            return reference
        }
    }

    @discardableResult
    public func execute(_ arguments: [BridgedType]) -> Executed
    {
        Executed(base: self, arguments: arguments) 
    }

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        var string: String = name
        var current: Reference? = self
        while let previous = current?.previous
        {
            string = previous.name + "." + string
            current = previous
        }

        return code.appending(string: string)
    }
}
