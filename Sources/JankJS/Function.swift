/**
 * File: Function.swift
 * File Created: Thursday, 9th December 2021 10:06:11 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */

open class BaseFunction: Base, BridgedType
{
    public let name: String?
    public let scope: Scope


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Lifecycle -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public init(scope: Scope, name: String? = nil)
    {
        self.name =  name
        self.scope = scope
    }


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Base protocol implementation -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        let firstPart = ["function ", name, "(\(scope.arguments?.rawJS(code: code.subcode()).rawCode ?? ""))"]
                        .compactMap({ $0 })
                        .joined()
        return code.appending(string: firstPart, suppressNewline: false)
                    .appending(string: scope.rawJS(code: code.subcode()).rawCode)
    }

    public var codeValue: String { rawJS(code: .init(configuration: .init(), rawCode: "")).rawCode }
}

open class Function: BaseFunction, Executable
{
    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Lifecycle -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public init(untyped: (Scope) -> Void, parentScope: Scope? = nil)
    {
        super.init(scope: UntypedScope.new(parent: parentScope, untyped), name: nil)
    }

    public init<T: BridgedType>(typed: (Scope) -> T, parentScope: Scope? = nil)
    {
        super.init(scope: TypedScope.new(parent: parentScope, typed), name: nil)
    }

    public init(untyped: (Scope) -> Void, name: String?, parentScope: Scope? = nil)
    {
        super.init(scope: UntypedScope.new(parent: parentScope, untyped), name: name ?? parentScope?.nameGenerator.next())
    }

    public init<T: BridgedType>(typed: (Scope) -> T, name: String?, parentScope: Scope? = nil)
    {
        super.init(scope: TypedScope.new(parent: parentScope, typed), name: name ?? parentScope?.nameGenerator.next())
    }


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Public -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public func execute(_ arguments: [BridgedType]) -> Executed 
    {
        Executed(base: name != nil ? Reference(name: name!) : self)
    }
}

open class ArgumentedFunction: BaseFunction, Executable
{
    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Lifecycle -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public init(untyped: (Scope) -> Void, name: String? = nil, parentScope: Scope? = nil)
    {
        super.init(scope: UntypedScope.new(parent: parentScope, 
        {
            $0.attachArguments()
            untyped($0)
        }), name: name)
    }

    public init<T: BridgedType>(typed: (Scope) -> T, name: String? = nil, parentScope: Scope? = nil)
    {
        super.init(scope: TypedScope.new(parent: parentScope,
        { scope -> T in
            scope.attachArguments()
            return typed(scope)
        }), name: name)
    }


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Public -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public func execute(_ arguments: [BridgedType]) -> Executed 
    {
        Executed(base: name != nil ? Reference(name: name!) : self)
    }
}

