/**
 * File: Operators.swift
 * File Created: Friday, 10th December 2021 11:56:01 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */


public struct Operator: Base
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

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        return code.appending(string: [left.rawJS(code: code.subcode()).rawCode, 
                                        symbol.rawValue, 
                                        right.rawJS(code: code.subcode()).rawCode]
                                        .joined(separator:" "))
    }
}
infix operator ++
func ++<T: BridgedType>(left: T, right: T) -> Operator
{
    return Operator(left: left, right: right, symbol: .plus)
}
infix operator +-
func +-<T: BridgedType>(left: T, right: T) -> Operator
{
    return Operator(left: left, right: right, symbol: .minus)
}
infix operator +/
func +/<T: BridgedType>(left: T, right: T) -> Operator
{
    return Operator(left: left, right: right, symbol: .divide)
}
infix operator +*
func +*<T: BridgedType>(left: T, right: T) -> Operator
{
    return Operator(left: left, right: right, symbol: .multiply)
}