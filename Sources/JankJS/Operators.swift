/**
 * File: Operators.swift
 * File Created: Friday, 10th December 2021 11:56:01 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */


// TODO: Probably shouldn't be `BridgedType` but has to be because of operators...
public enum Parenthesis: Base,  BridgedType
{
    static let defaultOpening: String = "("
    static let defaultClosing: String = ")"
    static let squareOpening: String = "["
    static let squareClosing: String = "]"
    static let curlyOpening: String = "{"
    static let curlyClosing: String = "}"

    case square(Base)
    case curly(Base)
    case `default`(Base)

    private var openingToken: String
    {
        let token: String
        switch self
        {
            case .square(_): token = Self.squareOpening
            case .curly(_): token = Self.curlyOpening
            case .default(_): token = Self.defaultOpening
        }

        return token
    }

    private var closingToken: String
    {
        let token: String
        switch self {
        case .square(_): token = Self.squareClosing
        case .curly(_): token = Self.curlyClosing
        case .default(_): token = Self.defaultClosing
        }

        return token
    }

    private var value: Base
    {
        let value: Base
        switch self {
        case .square(let wrapped): value = wrapped
        case .curly(let wrapped): value = wrapped
        case .default(let wrapped): value = wrapped
        }

        return value
    }

    public func rawJS(code: Generator.Code) -> Generator.Code 
    {
        code.appending(string: openingToken)
            .appending(string: value.rawJS(code: code).rawCode)
            .appending(string: closingToken)
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
        case assignment = "="
        case modulo = "%"
        case ternaryThen = "?"
        case ternaryElse = ":"
        case greaterThan = ">"
        case greaterThanOrEqual = ">="
        case lessThan = "<"
        case lessThanOrEqual = "<="

        var precedence: Int
        {
            switch self
            {
            case .ternaryElse, .ternaryThen, .greaterThan, .greaterThanOrEqual, 
                    .lessThan, .lessThanOrEqual, .assignment: 
                return -1
            case .logicalOr: return 0
            case .logicalAnd: return 1
            case .comparison, .superComparison: return 2
            case .plus, .minus: return 3
            case .divide, .multiply, .modulo: return 4
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
        code.appending(expresion: [left as Base, symbol, right])
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
public func +/<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .divide)
}
infix operator +%: MultiplicationPrecedence
public func +%<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .modulo)
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

infix operator +=+: AssignmentPrecedence
public func +=+<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .assignment)
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

infix operator +? : TernaryPrecedence
public func +?<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .ternaryThen)
} 

infix operator +?! : TernaryPrecedence
public func +?!<T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .ternaryElse)
} 

infix operator +< : ComparisonPrecedence
public func +< <T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .lessThan)
} 

infix operator +<=: ComparisonPrecedence
public func +<= <T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .lessThanOrEqual)
} 

infix operator +>: ComparisonPrecedence
public func +> <T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .greaterThan)
} 

infix operator +>=: ComparisonPrecedence
public func +>= <T: BridgedType, V: BridgedType>(left: T, right: V) -> Operator
{
    return Operator(left: left, right: right, symbol: .greaterThanOrEqual)
} 