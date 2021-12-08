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
    @resultBuilder
    public struct Builder
    {
        static func buildBlock(_ components: Base...) -> [Base] 
        {
            return components
        } 
    }

    public let parent: Scope?
    internal let nameGenerator = NameGenerator()

    private var statements: [Base] = []

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

    public init(parent: Scope?)
    {
        self.parent = parent
    }

    public func add(_ x: Base)
    {
        statements.append(x)
    }

    public func add(@Builder _ builder: () -> [Base])
    {
        statements.append(contentsOf: builder())
    }

    public func rawJS(code: Generator.Code) -> Generator.Code
    { 
        var code = code
        code.append(string: "{", indentLevel: depth)
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

    public static func new(parent: Scope?, @Scope.Builder _ builder: () -> [Base] = { [] }) -> Scope
    {
        let scope = Scope(parent: parent)

        scope.add(builder)

        return scope 

    }

    public static func new(parent: Scope?, _ scopeSerializer: (Scope) -> Void) -> Scope
    {
        let scope = Scope(parent: parent)

        scopeSerializer(scope)

        return scope 
    }
}

open class ParameterizedScope: Scope
{
    init(parent: Scope?, parameters: Reference ...)
    {
        super.init(parent: parent)
    }
}

open class TypedScope<T: BridgedType>: Scope
{
    public struct ExecutedScope<T: BridgedType>: BridgedType
    {
        public let scope: TypedScope<T>

        public static var type: BaseType { .reference }

        public func rawJS(code: Generator.Code) -> Generator.Code 
        {
            return code.appending(string: "\(scope.rawJS(code: code).rawCode)()")
        }
    }

    public struct Return<T: BridgedType>: Base
    {
        let value: T?

        public func rawJS(code: Generator.Code) -> Generator.Code 
        {
            let valueRaw = value?.rawJS(code: .init(configuration: code.configuration, rawCode: "")).rawCode
            return code.appending(string: "return \(valueRaw ?? Self.null)")
        }
    }

    private override init(parent: Scope?) 
    {
        super.init(parent: parent)
    }

    public static func new<T: BridgedType>(parent: Scope?, _ scopeSerializer: (Scope) -> T?) -> TypedScope<T>
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
