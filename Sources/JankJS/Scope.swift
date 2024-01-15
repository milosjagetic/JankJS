/**
 * File: Scope.swift
 * File Created: Sunday, 5th December 2021 10:09:46 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */
 
import Foundation

open class Scope: Base
{
    public enum Prefix: Base
    {
        case `if`(Base)
        case `else`

        public func rawJS(code: Generator.Code) -> Generator.Code 
        {
            switch self
            {
                case .if(let condition):
                    return code.appending(expresion:  [Reference(name: "if"),Parenthesis.default(condition)])
                case .else:
                    return code.appending(statement: Reference(name: "else"))
            }
        }
    }
    
    @resultBuilder
    public struct Builder
    {
        public static func buildBlock(_ components: Base...) -> [Base] 
        {
            return components
        } 

        public static func buildBlock(_ components: [Base]...) -> [Base] 
        {
            components.flatMap { $0 }
        }

        public static func buildEither(first component: [Base]) -> [Base] 
        {
            component
        }

        public static func buildEither(second component: [Base]) -> [Base] 
        {
            component
        }

        public static func buildOptional(_ component: [Base]?) -> [Base] 
        {
            component ?? []
        }

        public static func buildExpression(_ expression: Base) -> [Base] 
        {
            [expression]
        }

        public static func buildExpression(_ expression: [Base]) -> [Base] 
        {
            expression
        }

        public static func buildArray(_ components: [[Base]]) -> [Base] 
        {
            components.flatMap { $0 }
        }
    }

    public var prefix: Prefix?
    public let parent: Scope?
    public var arguments: Reference?

    internal let nameGenerator = NameGenerator()

    internal var statements: [Base] = []

    internal var depth: UInt
    {
        var depth: UInt = 0

        var current = parent
        while let x = current
        {
            depth = depth + 1
            current = x.parent
        }

        return depth
    }


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Lifecycle -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public init(parent: Scope?)
    {
        self.parent = parent
        self.arguments = nil
    }


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Adding -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    @discardableResult
    public func add<T: Base>(_ x: T) -> T
    {
        statements.append(x)
        return x
    }

    public func add(@Builder _ builder: () -> [Base])
    {
        statements.append(contentsOf: builder())
    }

    public func add(@Builder _ builder: (Scope) -> [Base])
    {
        statements.append(contentsOf: builder(self))
    }

    @discardableResult
    public func attachArguments() -> Reference
    {
        if let arguments { return arguments }

        let arguments = Reference(name: nameGenerator.next())
        self.arguments = arguments

        return arguments
    }

    public func `if`<T: Scope>(_ condition: Base, then: T, other: T? = nil)
    {
        then.prefix = .if(condition)
        add(then)

        if let other = other
        {
            other.prefix = .else
            add(other)
        }
    }


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Code -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public func rawJS(code: Generator.Code) -> Generator.Code
    { 
        var code = code
        if let prefix = prefix
        {
            code.append(statement: prefix)
        }
        code.append(string: "{", indentLevel: depth, suppressNewline: false)
        code.append(statements: statements, indentLevel: depth + 1)
        code.append(string: "}", indentLevel: depth)

        return code
    }
}

open class UntypedScope: Scope 
{
    private override init(parent: Scope?) 
    {
        super.init(parent: parent)
    }

    public static func new(parent: Scope?, @Scope.Builder _ builder: (Scope) -> [Base] = { _ in [] }) -> Scope
    {
        let scope = Scope(parent: parent)

        scope.add(builder)

        return scope 

    }

    public static func new(parent: Scope?, scopeSerializer: (Scope) -> Void) -> Scope
    {
        let scope = Scope(parent: parent)

        scopeSerializer(scope)

        return scope 
    }
}


open class TypedScope<T: BridgedType>: Scope
{
    public struct Return: Base
    {
        let value: T?

        public func rawJS(code: Generator.Code) -> Generator.Code 
        {
            let valueRaw = (value as BridgedType? ?? Reference.null).rawJS(code: code.subcode()).rawCode
            return code.appending(string: "return \(valueRaw)")
        }
    }

    private override init(parent: Scope?) 
    {
        super.init(parent: parent)
    }

    public static func new(parent: Scope?, _ scopeSerializer: (Scope) -> T?) -> TypedScope<T>
    {
        let scope = TypedScope<T>(parent: parent)

        scope.add(Return(value: scopeSerializer(scope)))

        return scope 
    }
}

internal class NameGenerator
{
    static let unicodeStart: UInt = 0x61 // hex value of lowercase 'A' in unicode

    private var nameValue: Int = -1

    func next() -> String
    {
        nameValue = nameValue + 1
        let digits = convertToBase26(value: UInt(nameValue))
        return digits.map { String(UnicodeScalar($0 + UInt8(Self.unicodeStart))) }.joined()
    }

    // each UInt is a digit of the base26 number, ie. a letter index
    private func convertToBase26(value: UInt) -> [UInt8]
    {
        let numberOfChars: UInt = 26 // alphabet letter count
        let overflow: UInt = UInt(floor(Double(nameValue) /  Double(numberOfChars)))

        let remainder = UInt8(value % numberOfChars)

        return overflow >= numberOfChars
                        ? convertToBase26(value: overflow) + [remainder] 
                        : overflow == 0 ? [remainder] : [UInt8(overflow), remainder]
    }
}
