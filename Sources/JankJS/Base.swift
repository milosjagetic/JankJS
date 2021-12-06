/**
 * File: Base.swift
 * File Created: Sunday, 5th December 2021 10:11:45 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2021 REGALE DIGITA
 */


public protocol Base
{
    func rawJS(code: Generator.Code)
}

extension RawRepresentable
where RawValue == String, Self: Base
{
    public func rawJS(code: Generator.Code)
    {
        code.append(string: rawValue)
    }
}

public enum BaseType: String, Base
{
    case string
    case number
    case bool
}

public enum Keywords
{
    case const
    case `var`
    case function
    case `return`
}

