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
        public var prettyPrinting: Bool
        public var baseIndent: String
        public var newlineToken: String
        public var statementDelimiter : String
        public var stringLiteralQuote: String

        public init(prettyPrinting: Bool = false, 
                    baseIndent: String = "    ", 
                    newlineToken: String = "\n", 
                    statementDelimiter: String = ";",
                    stringLiteralQuote: String = "'")
        {
            self.prettyPrinting = prettyPrinting
            self.baseIndent = baseIndent
            self.newlineToken = newlineToken
            self.statementDelimiter = statementDelimiter
            self.stringLiteralQuote = stringLiteralQuote
        }

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

        public var rawCode: String = ""

        public static func new(_ configuration: Configuration, rawCode: String = "") -> Code
        {
            return Code(configuration: configuration, rawCode: rawCode)
        }

        public mutating func append(string: String, indentLevel: UInt = 0, suppressNewline: Bool = true)
        {
            if configuration.prettyPrinting 
            {
                rawCode.append(Array(0..<indentLevel).map({ _ = $0; return configuration.baseIndent; }).joined()) 
            }

            rawCode.append(string)
            if configuration.prettyPrinting && !suppressNewline { rawCode.append(configuration.newlineToken) }
        }

        public mutating func append(statement: Base, indentLevel: UInt = 0)
        {
            let code = Code(configuration: configuration, rawCode: "")
            append(string: statement.rawJS(code: code).rawCode.appending(configuration.statementDelimiter), 
                    indentLevel: indentLevel, suppressNewline: false)
        }

        public mutating func append(statements: [Base], indentLevel: UInt = 0)
        {
            statements.forEach({ append(statement: $0, indentLevel: indentLevel) })
        }

        public mutating func append(stringLiteral: String, indentLevel: UInt = 0, suppressNewline: Bool = true)
        {
            if configuration.prettyPrinting 
            {
                rawCode.append(Array(0..<indentLevel).map({ _ = $0; return configuration.baseIndent; }).joined()) 
            }

            rawCode.append(configuration.stringLiteralQuote)
            rawCode.append(stringLiteral)
            rawCode.append(configuration.stringLiteralQuote)

            if configuration.prettyPrinting && !suppressNewline { rawCode.append(configuration.newlineToken) }
        }

        public func appending(string: String, indentLevel: UInt = 0, suppressNewline: Bool = true) -> Code
        {
            var code = Code(configuration: configuration, rawCode: rawCode)

            code.append(string: string, indentLevel: indentLevel, suppressNewline: suppressNewline)
            return code
        }

        public func appending(stringLiteral: String, indentLevel: UInt = 0, suppressNewline: Bool = true) -> Code
        {
            var code = Code(configuration: configuration, rawCode: rawCode)

            code.append(stringLiteral: stringLiteral, indentLevel: indentLevel, suppressNewline: suppressNewline)
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

        public func appending(expresion: [Base], indentLevel: UInt = 0) -> Code
        {
            var code = Code(configuration: configuration, rawCode: rawCode)

            code.append(string: expresion   .map { $0.rawJS(code: subcode()).rawCode }
                                            .joined(separator: configuration.prettyPrinting ? " " : ""), 
                        indentLevel: indentLevel)
            return code
        }

        public func subcode() -> Code
        {
            return .init(configuration: configuration, rawCode: "")
        }
    }

    public let configuration: Configuration

    public init(configuration: Configuration)
    {
        self.configuration = configuration
    }

    public func generate(@Scope.Builder _ builder: (Scope) -> [Base]) -> Generator.Code
    { 
        let scope = UntypedScope.new(parent: nil, builder)

        return scope.rawJS(code: .init(configuration: configuration, rawCode: ""))
    }

    public func generate( _ scopeSerializer: @escaping (Scope) -> Void) -> Generator.Code
    {
        let scope = UntypedScope.new(parent: nil, scopeSerializer: scopeSerializer)

        return scope.rawJS(code: .init(configuration: configuration, rawCode: ""))
    }

    public func generate<T: BridgedType>( _ scopeSerializer: @escaping (Scope) -> T?) -> Generator.Code
    {
        let scope = TypedScope<T>.new(parent: nil, scopeSerializer)

        return scope.rawJS(code: .init(configuration: configuration, rawCode: ""))
    }
}

extension Base
{
    public func generate(with generator: Generator) -> Generator.Code
    {
        return rawJS(code: .init(configuration: generator.configuration, rawCode: ""))
    }
}