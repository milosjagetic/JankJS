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

}

open class Function: BaseFunction
{
    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Lifecycle -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    public init(untyped: (Scope) -> Void, name: String? = nil, parentScope: Scope? = nil)
    {
        super.init(scope: UntypedScope.new(parent: parentScope, untyped), name: name)
    }

    public init<T: BridgedType>(typed: (Scope) -> T, name: String? = nil, parentScope: Scope? = nil)
    {
        super.init(scope: TypedScope.new(parent: parentScope, typed), name: name)
    }


    //  //= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\
    //  Public -
    //  \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//
    func executed() -> ExecutedFunction  
    {
        ExecutedFunction(function: self, arguments: nil)
    }
}

open class ArgumentedFunction: BaseFunction
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
    func executed(arguments: BridgedType) -> ExecutedFunction  
    {
        ExecutedFunction(function: self, arguments: arguments)
    }
}

public struct ExecutedFunction: BridgedType
{
    public let function: BaseFunction
    public let arguments: BridgedType?

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        return code.appending(string: function.rawJS(code: code.subcode()).rawCode)
                .appending(string: "(\(arguments?.rawJS(code: code.subcode()).rawCode ?? ""))")
    }
}
