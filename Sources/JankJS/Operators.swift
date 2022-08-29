/**
 * File: Operators.swift
 * File Created: Friday, 10th December 2021 11:56:01 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */


public enum Parenthesis: String, Base
{
    case open = "("
    case closed = ")"

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        return code.appending(string: rawValue)
    }

    static func parenthesize(_ base: BridgedType) -> Reference
    {
        Reference(name: "\(Parenthesis.open.rawValue)\(base.codeValue)\(Parenthesis.closed.rawValue)")
    }

    static func parenthesize(_ base: BridgedType) -> [Base]
    {
        [Parenthesis.open, base, Parenthesis.closed]
    }
}

public struct Operator: BridgedType
{
    public enum Symbol: String, Base
    {
        case plus = "+"
        case minus = "-"
        case divide = "/"
        case multiply = "*"
        case logicalOr = "||"
        case logicalAnd = "&&"
        case comparison = "=="
        case superComparison = "==="

        var precedence: Int
        {
            switch self
            {
            case .logicalOr: return 0
            case .logicalAnd: return 1
            case .comparison, .superComparison: return 2
            case .plus, .minus: return 3
            case .divide, .multiply: return 4                
            }
        }

        public func rawJS(code: Generator.Code) -> Generator.Code 
        {
            return code.appending(string: rawValue)
        }
    }

    let left: BridgedType
    let right: BridgedType
    let symbol: Symbol

    public var codeValue: String { rawJS(code: .init(configuration: .init(), rawCode: "")).rawCode }

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        var expr: [Base] = []

        if let left = left as? Operator
        {
            expr.append(contentsOf: symbol.precedence > left.symbol.precedence ? Parenthesis.parenthesize(left)
                                                                                : [left])
        }
        else
        {
            expr.append(left)
        }

        expr.append(symbol)

        if let right = right as? Operator
        {
            expr.append(contentsOf: symbol.precedence > right.symbol.precedence ? Parenthesis.parenthesize(right)
                                                                                : [right])
        }
        else
        {
            expr.append(right)
        }
        return code.appending(expresion: expr)
    }
}
infix operator ++: AdditionPrecedence
public func ++<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .plus)
}
infix operator +-: AdditionPrecedence
public func +-<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .minus)
}
infix operator +/: MultiplicationPrecedence
func +/<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .divide)
}
infix operator +*: MultiplicationPrecedence
public func +*<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .multiply)
}
infix operator +||: LogicalDisjunctionPrecedence
public func +||<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .logicalOr)
} 

infix operator +==: ComparisonPrecedence
public func +==<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .comparison)
} 

infix operator +===: ComparisonPrecedence
public func +===<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .superComparison)
} 