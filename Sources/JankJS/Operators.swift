/**
 * File: Operators.swift
 * File Created: Friday, 10th December 2021 11:56:01 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */


public struct Operator: BridgedType
{
    public enum Symbol: String
    {
        case plus = "+"
        case minus = "-"
        case divide = "/"
        case multiply = "*"
    }

    let left: BridgedType
    let right: BridgedType
    let symbol: Symbol

    public var codeValue: String { rawJS(code: .init(configuration: .init(), rawCode: "")).rawCode }

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        return code.appending(string: [left.rawJS(code: code.subcode()).rawCode, 
                                        symbol.rawValue, 
                                        right.rawJS(code: code.subcode()).rawCode]
                                        .joined(separator:" "))
    }
}
infix operator ++: JankPrecedence
func ++<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .plus)
}
infix operator +-: JankPrecedence
func +-<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .minus)
}
infix operator +/: JankPrecedence
func +/<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .divide)
}
infix operator +*: JankPrecedence
func +*<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .multiply)
}


    precedencegroup JankPrecedence
    {
        higherThan: AdditionPrecedence
        lowerThan: DefaultPrecedence
        associativity: left
        assignment: true
    }
