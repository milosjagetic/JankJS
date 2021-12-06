import XCTest
@testable import JankJS

final class JankJSTests: XCTestCase 
{
    func testNameGenerator() throws 
    {
        let generator = NameGenerator()

        for i in 0...25
        {
            switch i
            {
                //test first letter (a)
                case 0:
                    let name = generator.next()
                    XCTAssert(name == "a", "First generated variable (\"a\") test failed. Got: \(name)") 
                //test last letter (z)
                case 25:
                    let name = generator.next()
                    XCTAssert(name == "z", "26th generated variable (\"z\") test failed. Got: \(name)")
                //test overflow, because of recursive nature of the method we can assume the rest are valid too
                case 26:
                    let name = generator.next()
                    XCTAssert(name == "ba", "27th generated variable (\"ba\") (overflow) test failed. Got: \(name)") 
                //not testing intermediate letters, just advancing the generator
                default: _ = generator.next()
            }
            print()
        }
    }
}
