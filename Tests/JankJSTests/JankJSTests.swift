import XCTest
@testable import JankJS

final class JankJSTests: XCTestCase 
{
    let prettyGenerator = Generator(configuration: .init(prettyPrinting: true, stringLiteralQuote: "\""))
    let generator = Generator(configuration: .init(prettyPrinting: false, stringLiteralQuote: "\""))

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
        prettyAssert(generator.generate({ [] }).rawCode, "{}", "Basic scope failed.")
        
        prettyAssert(prettyGenerator.generate({ [] }).rawCode, "{\n}", "Basic pretty printed scope failed.")
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
    }

    func testBridgedTypes()
    {
        prettyAssert("bla".generate(with: generator).rawCode, "\"bla\"", "String bridged type generation failed")
        prettyAssert(123.generate(with: generator).rawCode, "123", "Number bridged type generation failed")
        prettyAssert((-123).generate(with: generator).rawCode, "-123", "Number bridged type generation failed")
        prettyAssert((-123.321).generate(with: generator).rawCode, "-123.321", "Number bridged type generation failed")
        prettyAssert((123.321).generate(with: generator).rawCode, "123.321", "Number bridged type generation failed")
        prettyAssert(true.generate(with: generator).rawCode, "true", "Number bridged type generation failed")
        prettyAssert(false.generate(with: generator).rawCode, "false", "Number bridged type generation failed")
    }

    func testBasicOperators()
    {
        prettyAssert(("a" ++ "b" +- 1 +* 9).generate(with: prettyGenerator).rawCode,
                    "\"a\" + \"b\" - 1 * 9", 
                    "Basic operator generation failed")
    
        prettyAssert(("a" +=+ "b" +- 1 +* 9 +/ 2 +% 3).generate(with: prettyGenerator).rawCode,
                    "\"a\" = \"b\" - 1 * 9 / 2 % 3", 
                    "Basic operator generation failed")
    }

    func testMemberAccess()
    {
        prettyAssert(Reference.this.getElementById.generate(with: generator).rawCode, 
                    "this.getElementById", 
                    "Base member access test failed")

        prettyAssert(Reference.this.getElementById.generate(with: generator).rawCode, 
                    "this.getElementById", 
                    "Base member access test failed")
    }

    func testExecution()
    {
        prettyAssert(Reference.this.replace.execute("a", "b").generate(with: generator).rawCode,
                    "this.replace(\"a\", \"b\")",
                    "This.member execution failed")
        prettyAssert(Reference.this.replace("a", "b").generate(with: generator).rawCode,
                    "this.replace(\"a\", \"b\")",
                    "This.member execution call as function failed")
        prettyAssert(Reference.this.replace().generate(with: generator).rawCode,
                    "this.replace()",
                    "This.member no arguments execution call as function failed")
    }

    func testObjects()
    {
        prettyAssert((["a" : "b", "c" : "d"] as BridgedObject).generate(with: generator).rawCode, 
        """
        {"a":"b","c":"d"}
        """, 
        "Basic object test failed")

        prettyAssert(BridgedObject(dictionaryLiteral: ("a", "b"), ("c", "d")).generate(with: prettyGenerator).rawCode, 
        """
        {
            "a" : "b",
            "c" : "d"
        }
        """, 
        "Basic pretty object test failed")
    }

    func testAaa()
    {
        // prettyAssert(Reference.document.addEventListener.execute("DOMContentLoaded", Function(untyped: 
        //                 {
        //                     let openModal = $0.add(ArgumentedFunction(untyped:
        //                     {
        //                         guard let arg = $0.arguments else { return }

        //                         $0.add(arg.classList.add.execute("Modifiers.isActive"))
        //                     }, name: "openModal", parentScope: $0))

        //                     let closeModal = $0.add(ArgumentedFunction(untyped:
        //                     {
        //                         guard let arg = $0.arguments else { return }

        //                         $0.add(arg.classList.remove.execute("Modifiers.isActive"))
        //                     }, name: "closeModal", parentScope: $0))

        //                     let closeAllModals = $0.add(Function(untyped: 
        //                     {
        //                         $0.add((Reference.document.querySelectorAll.execute(".modal") +|| BridgedArray<Int>())
        //                                 .forEach.execute(ArgumentedFunction(untyped: 
        //                                 {
        //                                     guard let arg = $0.arguments else { return }
        //                                     $0.add(closeModal.executed(arguments: arg))
        //                                 }, parentScope: $0)))
        //                     }, name: "closeAllModals", parentScope: $0))

        //                     $0.add((Reference.document.querySelectorAll.execute(".js-modal-trigger") +|| BridgedArray<Int>())
        //                                 .forEach.execute(ArgumentedFunction(untyped: 
        //                                 {
        //                                     guard let arg = $0.arguments else { return }

        //                                     let modal = Declaration.new(value: arg.dataset.trigger, scope: $0)
        //                                     let target = Declaration.new(value: Reference.document.getElementById.execute(modal), 
        //                                                                             scope: $0)

        //                                     $0.add(arg.addEventListener.execute("click", Function(untyped: 
        //                                     {
        //                                         $0.add(openModal.executed(arguments: target))
        //                                     }, parentScope: $0)))
        //                                 }, parentScope: $0)))
                            
        //                     let args = ".modal-background, .modal-close, .modal-card-head .delete, .modal-card-foot .button"
        //                     $0.add((Reference.document.querySelectorAll.execute(args) +|| BridgedArray<Int>())
        //                                 .forEach.execute(ArgumentedFunction(untyped:
        //                                 {
        //                                     guard let arg = $0.arguments else { return }

        //                                     let target = Declaration.new(value: arg.closest.execute(".modal"),scope: $0)

        //                                     $0.add(arg.addEventListener.execute("click", Function(untyped: 
        //                                     {
        //                                         $0.add(closeModal.executed(arguments: target))
        //                                     }, parentScope: $0)))
        //                                 }, parentScope: $0))
        //                                 )
                            
        //                     $0.add(Reference.document.addEventListener.execute("keydown", ArgumentedFunction(untyped:
        //                     {
        //                         guard let arg = $0.arguments else { return }

        //                         let event = Declaration.new(value: arg +|| Reference.window.event, scope: $0)
        //                         $0.if(event.keyCode +=== 27, then: UntypedScope.new(parent: $0) { closeAllModals.executed() })
        //                     }, parentScope: $0)))
        //                 })).generate(with: prettyGenerator).rawCode
        //             , "", "")
    }
}


private func prettyAssert<T: Equatable>(_ specimen: T, _ expected: T, _ message: String)
{
    XCTAssert(specimen == expected, "🔴 \(message) 🔴\nGot:\n\(specimen)\nExpected:\n\(expected)")
}