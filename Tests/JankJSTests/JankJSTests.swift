import XCTest
@testable import JankJS

final class JankJSTests: XCTestCase 
{
    let prettyGenerator = Generator(configuration: .init(prettyPrinting: true))
    let generator = Generator(configuration: .init(prettyPrinting: false))

    func testNameGenerator() 
    {
        let generator = NameGenerator()

        for i in 0...25
        {
            switch i
            {
                //test first letter (a)
                case 0:
                    let name = generator.next()
                    prettyAssert(name, "a", "First generated variable (\"a\") test failed.") 
                //test last letter (z)
                case 25:
                    let name = generator.next()
                    prettyAssert(name, "z", "26th generated variable (\"z\") test failed.")
                //test overflow, because of recursive nature of the method we can assume the rest are valid too
                case 26:
                    let name = generator.next()
                    prettyAssert(name, "ba", "27th generated variable (\"ba\") (overflow) test failed.") 
                //not testing intermediate letters, just advancing the generator
                default: _ = generator.next()
            }
        }
    }

    func testBasicScope()
    {
        prettyAssert(generator.generate({ }).rawCode, "{}", "Basic scope failed.")
        
        prettyAssert(prettyGenerator.generate({ }).rawCode, "{\n}", "Basic pretty printed scope failed.")
    }

    func testBasicDeclaration()
    {
        prettyAssert(generator.generate(
            { 
                Declaration(name: "aaa", value: "")
            }).rawCode, "{var aaa = \"\";}", "Basic declaration test failed")

        let block: (Scope) -> Void = 
        { scope in
            let a = Declaration.new(value: "", scope: scope)
            let _ = Declaration.new(value: a, scope: scope)
        }
        prettyAssert(generator.generate(block).rawCode, 
                    "{var a = \"\";var b = a;}",
                    "Basic scope with generated vars failed")

        let returnBlock: (Scope) -> Reference =        
        { scope -> Reference in
            let a = Declaration.new(value: "", scope: scope)
            let b = Declaration.new(value: a, scope: scope)
            return b
        }
        prettyAssert(generator.generate(returnBlock).rawCode, 
                    "{var a = \"\";var b = a;return b;}",
                    "Basic scope with generated vars failed and return failed")

        prettyAssert(prettyGenerator.generate(returnBlock).rawCode, 
            """
            {
                var a = \"\";
                var b = a;
                return b;
            }
            """,
            "Basic scope with generated vars failed and return failed")
    }

    func testFunctions()
    {
        prettyAssert(Function(typed: { _ -> String in return "";}, parentScope: nil).generate(with: generator).rawCode,
                     "function (){return \"\";}",
                     "Basic function generation test failed")
        prettyAssert(Function(typed: { _ -> String in return "";}, 
                        parentScope: nil).generate(with: prettyGenerator).rawCode,
                    """
                    function ()
                    {
                        return \"\";
                    }
                    """,
                    "Basic function generation test failed")

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
                                parentScope: nil).executed(arguments: "a")
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


        // let blockExecutionTest: (Scope) -> TypedScope.ExecutedScope =
        // { scope -> TypedScope<String>.ExecutedScope in
        //     let a = Declaration.new(value: TypedScope.new(parent: scope, { scope -> String in "aaa" }).executed(), 
        //                             scope: scope)
        //     return TypedScope.new(parent: scope, { scope -> String in "bbb" }).executed()
        // }

        // prettyAssert(prettyGenerator.generate(blockExecutionTest).rawCode,
        //             """
        //             {
        //                 var a = {return "aaa";}();
        //                 return {return "bbb";}();
        //             }

        //             """,
        //             "Block execution test failed.")

    }

    func testOperators()
    {
        prettyAssert(("a" ++ "b").generate(with: generator).rawCode, "expected: Equatable", "message: ")
    }
}


private func prettyAssert<T: Equatable>(_ specimen: T, _ expected: T, _ message: String)
{
    XCTAssert(specimen == expected, "🔴 \(message) 🔴\nGot:\n\(specimen)\nExpected:\n\(expected)")
}