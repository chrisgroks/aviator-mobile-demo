import XCTest
@testable import AviatorDemo

final class CalculatorTests: XCTestCase {

    let calculator = Calculator()

    func testAdd() {
        XCTAssertEqual(calculator.add(2.0, 3.0), 5.0, accuracy: 0.001)
    }

    func testSubtract() {
        XCTAssertEqual(calculator.subtract(3.0, 2.0), 1.0, accuracy: 0.001)
    }

    func testMultiply() {
        XCTAssertEqual(calculator.multiply(2.0, 3.0), 6.0, accuracy: 0.001)
    }

    func testDivide() throws {
        XCTAssertEqual(try calculator.divide(6.0, 3.0), 2.0, accuracy: 0.001)
    }

    func testDivideByZero() {
        XCTAssertThrowsError(try calculator.divide(1.0, 0.0)) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }

    func testVersion() {
        XCTAssertFalse(calculator.version().isEmpty)
    }

    func testAppGreeting() {
        let greeting = AviatorDemoApp.greeting()
        XCTAssertTrue(greeting.contains("AviatorDemo"))
    }
}
