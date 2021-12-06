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
    }    

    public struct Code
    {
        public let configuration: Configuration

        public var code: String

        public mutating func append(string: String, indentLevel: UInt = 0)
        {
            if configuration.prettyPrinting 
            {
                code.append(Array(0..<indentLevel).map({ _ = $0; return configuration.baseIndent; }).joined()) 
            }
            code.append(string)
            if configuration.prettyPrinting { code.append(configuration.newlineToken) }
        }

        public mutating func append(statement: Base, indentLevel: UInt = 0)
        {
            let code = Code(configuration: configuration, code: "")
            append(string: statement.rawJS(code: code).code, indentLevel: indentLevel)

            self.code.append(configuration.statementDelimiter)
        }

        public mutating func append(statements: [Base], indentLevel: UInt = 0)
        {
            statements.forEach({ append(statement: $0, indentLevel: indentLevel) })
        }
    }

    public let configuration: Configuration

    public func generate(@Scope.Builder _ builder: () -> [Base]) -> Generator.Code
    {
        let scope = Scope(parent: nil)

        scope.add(builder)

        return scope.rawJS(code: .init(configuration: configuration, code: ""))
    }

    public func generate( _ scopeSerializer: @escaping (Scope) -> Void) -> Generator.Code
    {
        let scope = Scope(parent: nil)

        scopeSerializer(scope)

        return scope.rawJS(code: .init(configuration: configuration, code: ""))
    }
}