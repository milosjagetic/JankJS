import XCTest
@testable import JankJS

class JankJSTests: XCTestCase 
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
        prettyAssert(generator.generate({ _ in [] }).rawCode, "{}", "Basic scope failed.")
        
        prettyAssert(prettyGenerator.generate({ _ in [] }).rawCode, "{\n}", "Basic pretty printed scope failed.")
    }

    func testBasicDeclaration()
    {
        prettyAssert(generator.generate(
            { _ in
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
                    "Assignment operator generation failed")

        prettyAssert(("a" +=+ "b" +>= 3 +? true +?! false).generate(with: prettyGenerator).rawCode,
                    "\"a\" = \"b\" >= 3 ? true : false", 
                    "Assignment operator generation failed")

        prettyAssert(("a" +< "b").generate(with: prettyGenerator).rawCode,
                    "\"a\" < \"b\"", 
                    "Comparison less than generation failed")
        prettyAssert(("a" +<= "b").generate(with: prettyGenerator).rawCode,
                    "\"a\" <= \"b\"", 
                    "Comparison less than or equal generation failed")

        prettyAssert(("a" +> "b").generate(with: prettyGenerator).rawCode,
                    "\"a\" > \"b\"", 
                    "Comparison greater than generation failed")
        prettyAssert(("a" +>= "b").generate(with: prettyGenerator).rawCode,
                    "\"a\" >= \"b\"", 
                    "Comparison greater than or equal generation failed")

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
        [
            """
            {"a":"b","c":"d"}
            """,
            """
            {"c":"d","a":"b"}
            """
        ], 
        "Basic object test failed")

        prettyAssert((["a" : "b", "c" : "d"] as BridgedObject).generate(with: prettyGenerator).rawCode, 
        [
            """
            {
                "a" : "b",
                "c" : "d"
            }
            """,
            """
            {
                "c" : "d",
                "a" : "b"
            }
            """
        ], 
        "Basic pretty object test failed")
    }

    func prettyAssert<T: Equatable>(_ specimen: T, _ expected: T, _ message: String)
    {
        XCTAssert(specimen == expected, "🔴 \(message) 🔴\nGot:\n\(specimen)\nExpected:\n\(expected)")
    }

    func prettyAssert<T: Equatable>(_ specimen: T, _ expected: [T], _ message: String)
    {
        XCTAssert(expected.contains(specimen), "🔴 \(message) 🔴\nGot:\n\(specimen)\nExpected on of:\n\(expected)")
    }
}


