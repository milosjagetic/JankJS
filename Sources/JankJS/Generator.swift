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
    }    

    public class Code
    {
        public let configuration: Configuration

        public var code: String = ""

        public func append(string: String, indentLevel: UInt = 0)
        {
            if configuration.prettyPrinting { code.append(configuration.baseIndent) }
            code.append(string)
            if configuration.prettyPrinting { code.append(configuration.newlineToken) }
        }

        public func append(statement: Base, indentLevel: UInt = 0)
        {
            append(string: statement.rawJS(code: self), indentLevel: indentLevel)
        }

        public func append(statements: [Base], indentLevel: UInt = 0)
        {
            statements.forEach({ append(statement: $0, indentLevel: indentLevel) })
        }
    }

    public let configuration: Configuration

    public func generate(@Scope.Builder _ builder: () -> [Base])
    {
        let scope = Scope(parent: nil)

        scope.add(builder)
    }
}