import Foundation

public enum SecureMacroError: Error {
    case unsupportedPeerDeclaration
}

extension SecureMacroError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unsupportedPeerDeclaration:
            "Secure macro can only be attached to `let` or `var` declarations of type `String`."
        }
    }
}
