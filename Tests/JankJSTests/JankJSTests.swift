import XCTest
@testable import JankJS

final class JankJSTests: XCTestCase 
{
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
        let prettyGenerator = Generator(configuration: .init(prettyPrinting: true))
        let generator = Generator(configuration: .init(prettyPrinting: false))

        prettyAssert(generator.generate({ }).code, "{}", "Basic scope failed.")
        
        prettyAssert(prettyGenerator.generate({ }).code, "{\n}\n", "Basic pretty printed scope failed.")
    }

    func testBasicDeclaration()
    {
        let generator = Generator(configuration: .init())

        prettyAssert(generator.generate(
            { 
                Declaration(name: "aaa", value: "")
            }).code, "{var aaa = \"\";}", "Basic declaration test failed")

        let block: (Scope) -> Void = 
        { scope in
            let a = Declaration.new(value: "", scope: scope)
            let b = Declaration.new(value: a, scope: scope)
        }
        prettyAssert(generator.generate(block).code, "{var a = \"\";var b = a;}", "Basic declaration with generated vars failed")
    }
}


private func prettyAssert<T: Equatable>(_ specimen: T, _ expected: T, _ message: String)
{
    XCTAssert(specimen == expected, "🔴 \(message) 🔴\nGot:\n\(specimen)\nExpected:\n\(expected)")
}