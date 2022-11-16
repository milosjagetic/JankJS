/**
 * File: BridgedType+Function.swift
 * File Created: Sunday, 13th November 2022 8:43:38 pm
 * Author: Miloš Jagetić (milos.jagetic@gmail.com)
 * -----
 * Copyright 2021 - 2022 REGALE DIGITA
 */

import Foundation

extension BridgedType
{
    public subscript(  dynamicMember string: String) -> (_ args: BridgedType ...) -> Executed
    {
        get 
        { 
            { ( _ args: BridgedType ... ) in  
                Executed(base: Reference(name: "\(codeValue).\(string)"), arguments: args)
            }
        }
    }
}
