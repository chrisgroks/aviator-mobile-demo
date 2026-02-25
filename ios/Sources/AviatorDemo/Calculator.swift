public struct Calculator {

    public init() {}

    public func add(_ lhs: Double, _ rhs: Double) -> Double {
        lhs + rhs
    }

    public func subtract(_ lhs: Double, _ rhs: Double) -> Double {
        lhs - rhs
    }

    public func multiply(_ lhs: Double, _ rhs: Double) -> Double {
        lhs * rhs
    }

    public func divide(_ lhs: Double, _ rhs: Double) throws -> Double {
        guard rhs != 0 else {
            throw CalculatorError.divisionByZero
        }
        return lhs / rhs
    }

    public func percentage(_ value: Double, _ percent: Double) -> Double {
        value * percent / 100.0
    }

    public func percentage(_ value: Double, _ percent: Double) -> Double {
        value * percent / 100.0
    }

    public func version() -> String {
        "1.0.0"
    }
}

public enum CalculatorError: Error, Equatable {
    case divisionByZero
}
