import Foundation

public enum PrototypeStyle: String, CaseIterable {
    case inline
    case labeled
}

extension PrototypeStyle {
    public static var `default`: Self { .labeled }
}
