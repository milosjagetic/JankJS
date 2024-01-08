import XCTest
@testable import JankJS

class FunctionTests: JankJSTests 
{
    func testTypedFunctionGeneration()
    {
        prettyAssert(
            Function(
                typed: { _ -> String in return "";}, 
                parentScope: nil
            ).generate(with: generator).rawCode,
            "function (){return \"\";}",
            "Typed function generation test failed"
        )
        prettyAssert(
            Function(
                typed: { _ -> String in return "";}, 
                parentScope: nil
            ).generate(with: prettyGenerator).rawCode,
            """
            function ()
            {
                return \"\";
            }
            """,
            "Typed function pretty-print generation test failed"
        )
    }

    func testFunctions()
    {
        prettyAssert(Function(typed: 
                                { scope -> Reference in 
                                    let _ = Declaration.new(value: "+", scope: scope)
                                    let b = Declaration.new(value: Function(untyped: 
                                                    { 
                                                        _ = Declaration.new(value: 1, scope: $0) 
                                                    }, parentScope: scope), 
                                                            scope: scope)
                                    return b;
                                }, 
                                name: "blabla",
                                parentScope: nil)
                        .generate(with: prettyGenerator).rawCode,
            """
            function blabla()
            {
                var a = "+";
                var b = function ()
                {
                    var a = 1;
                };
                return b;
            }
            """,
            "Basic function generation test failed")


        prettyAssert(ArgumentedFunction(typed: 
                                { scope -> Reference in 
                                    let _ = Declaration.new(value: "+", scope: scope)
                                    let b = Declaration.new(value: Function(untyped: 
                                                    { 
                                                        _ = Declaration.new(value: 1, scope: $0) 
                                                    }, parentScope: scope), 
                                                            scope: scope)
                                    return b;
                                }, 
                                name: "blabla",
                                parentScope: nil)
                        .generate(with: prettyGenerator).rawCode,
            """
            function blabla(a)
            {
                var b = "+";
                var c = function ()
                {
                    var a = 1;
                };
                return c;
            }
            """,
            "Basic argumented function generation test failed")

        let executed = ArgumentedFunction(typed: 
                                { scope -> Reference in 
                                    let _ = Declaration.new(value: "+", scope: scope)
                                    let b = Declaration.new(value: Function(untyped: 
                                                    { 
                                                        _ = Declaration.new(value: 1, scope: $0) 
                                                    }, parentScope: scope), 
                                                            scope: scope)
                                    return b;
                                }, 
                                name: nil,
                                parentScope: nil)("a")
        prettyAssert(Declaration(name: "a", value: executed).generate(with: prettyGenerator).rawCode,
                    """
                    var a = function (a)
                    {
                        var b = "+";
                        var c = function ()
                        {
                            var a = 1;
                        };
                        return c;
                    }("a")
                    """,
                    "Basic argumented executed function generation test failed")
    }

}