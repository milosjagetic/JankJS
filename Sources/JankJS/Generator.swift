/**
 * File: Generator.swift
 * File Created: Sunday, 5th December 2021 10:29:37 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */

public struct Generator
{
    public struct Configuration
    {
        public var prettyPrinting = false
        public var baseIndent = "    "
        public var newlineToken = "\n"
        public var statementDelimiter = ";"


        var nonPrettyPrinted: Configuration
        {
            var conf = self
            conf.prettyPrinting = false

            return conf
        }
    }    

    public struct Code
    {
        public let configuration: Configuration

        public var rawCode: String

        public mutating func append(string: String, indentLevel: UInt = 0)
        {
            if configuration.prettyPrinting 
            {
                rawCode.append(Array(0..<indentLevel).map({ _ = $0; return configuration.baseIndent; }).joined()) 
            }
            rawCode.append(string)
            if configuration.prettyPrinting { rawCode.append(configuration.newlineToken) }
        }

        public mutating func append(statement: Base, indentLevel: UInt = 0)
        {
            let code = Code(configuration: configuration.nonPrettyPrinted, rawCode: "")
            append(string: statement.rawJS(code: code).rawCode.appending(configuration.statementDelimiter), 
                    indentLevel: indentLevel)
        }

        public mutating func append(statements: [Base], indentLevel: UInt = 0)
        {
            statements.forEach({ append(statement: $0, indentLevel: indentLevel) })
        }

        public func appending(string: String, indentLevel: UInt = 0) -> Code
        {
            var code = Code(configuration: configuration, rawCode: rawCode)

            code.append(string: string, indentLevel: indentLevel)
            return code
        }

        public func appending(statement: Base, indentLevel: UInt = 0) -> Code
        {
            var code = Code(configuration: configuration, rawCode: rawCode)

            code.append(statement: statement, indentLevel: indentLevel)
            return code
        }

        public func appending(statements: [Base], indentLevel: UInt = 0) -> Code
        {
            var code = Code(configuration: configuration, rawCode: rawCode)

            code.append(statements: statements, indentLevel: indentLevel)
            return code
        }
    }

    public let configuration: Configuration

    public func generate(@Scope.Builder _ builder: () -> [Base]) -> Generator.Code
    {
        let scope = UntypedScope.new(parent: nil, builder)

        return scope.rawJS(code: .init(configuration: configuration, rawCode: ""))
    }

    public func generate( _ scopeSerializer: @escaping (Scope) -> Void) -> Generator.Code
    {
        let scope = UntypedScope.new(parent: nil, scopeSerializer)

        return scope.rawJS(code: .init(configuration: configuration, rawCode: ""))
    }

    public func generate<T: BridgedType>( _ scopeSerializer: @escaping (Scope) -> T?) -> Generator.Code
    {
        let scope = TypedScope<T>.new(parent: nil, scopeSerializer)

        return scope.rawJS(code: .init(configuration: configuration, rawCode: ""))
    }
}