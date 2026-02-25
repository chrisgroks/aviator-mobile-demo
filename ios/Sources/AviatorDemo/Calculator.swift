public struct Calculator {

    public init() {}

    public func add(_ a: Double, _ b: Double) -> Double {
        a + b
    }

    public func subtract(_ a: Double, _ b: Double) -> Double {
        a - b
    }

    public func multiply(_ a: Double, _ b: Double) -> Double {
        a * b
    }

    public func divide(_ a: Double, _ b: Double) throws -> Double {
        guard b != 0 else {
            throw CalculatorError.divisionByZero
        }
        return a / b
    }

    public func version() -> String {
        "1.0.0"
    }
}

public enum CalculatorError: Error, Equatable {
    case divisionByZero
}
