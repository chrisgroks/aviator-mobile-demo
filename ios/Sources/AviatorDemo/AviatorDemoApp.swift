public struct AviatorDemoApp {

    public static let appName = "AviatorDemo"

    public static func greeting() -> String {
        let calc = Calculator()
        return "\(appName) v\(calc.version())"
    }
}
